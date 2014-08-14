/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.stockwatcher.web;

import java.io.IOException;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.StringArrayPropertyEditor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.stockwatcher.data.ApplicationProperties;
import org.stockwatcher.data.StockCriteria;
import org.stockwatcher.data.StockDAO;
import org.stockwatcher.data.WatchListDAO;
import org.stockwatcher.domain.Comment;
import org.stockwatcher.domain.Industry;
import org.stockwatcher.domain.Trade;
import org.stockwatcher.domain.User;

/**
 * Controller class for all Stock-related web requests. Uses DAO classes to 
 * interact with the database.
 * 
 * @author Tony Piazza
 */
@Controller
@RequestMapping("/stocks")
public class StockController extends BaseController {
	private static final Logger LOGGER = LoggerFactory.getLogger(StockController.class);
	private static final int MOST_WATCHED_LIMIT = 25;
	private static final int COMMENT_LIMIT = 100;
	@Autowired
	private StockDAO dao;
	@Autowired
	private WatchListDAO watchListDao;
	@Autowired
	private ApplicationProperties applicationProps;
	
	@RequestMapping(method=RequestMethod.GET)
	public String displayStockSearch(Model model) {
		model.addAttribute("exchanges", dao.getExchanges());
		Set<Industry> industries = 
			new TreeSet<Industry>(INDUSTRY_NAME_COMPARATOR);
		industries.addAll(dao.getIndustries());
		model.addAttribute("industries", industries);
		return "stocks";
	}

	@RequestMapping(value="/find", method=RequestMethod.POST)
	public String findStocks(Model model, HttpServletRequest request) {
		StockCriteria criteria = getCriteria(request);
		model.addAttribute("stocks", dao.findStocks(criteria));
		return "matchingStocks";
	}

	private StockCriteria getCriteria(HttpServletRequest request) {
		StockCriteria criteria = new StockCriteria();
		ServletRequestDataBinder binder = new ServletRequestDataBinder(criteria);
		binder.registerCustomEditor(Integer[].class, "industryIds", 
			new StringArrayPropertyEditor());
		binder.bind(request);
		return criteria;
	}

	@RequestMapping(value="/{symbol}", method=RequestMethod.GET)
	public String displayStockDetail(@PathVariable String symbol, Model model, 
		HttpServletRequest request) {
		model.addAttribute("stock", dao.getStockBySymbol(symbol));
		Date tradeDate = applicationProps.getLastTradeDate();
		SortedSet<Trade> trades = dao.getTradesBySymbolAndDate(symbol, tradeDate);
		model.addAttribute("trades", getUniqueTrades(trades));
		long elapsedTime = trades.size() == 0 ? 0 : 
			getElapsedTime(trades.first().getTimestamp(), 
				trades.last().getTimestamp());
		User user = (User)request.getSession().getAttribute("user");
		model.addAttribute("watchLists", user == null ? Collections.EMPTY_SET :
			watchListDao.getWatchListsByUserId(user.getId()));
		model.addAttribute("lastClosePrice", dao.getLastClosePriceForSymbol(symbol));
		model.addAttribute("elapsedTime", elapsedTime);
		model.addAttribute("liveTrading", applicationProps.isTradingLive());
		model.addAttribute("watchCount", watchListDao.getWatchCount(symbol));
		dao.incrementStockViewCount(symbol);
		return "stock";
	}

	@RequestMapping(value="/{symbol}/trades", method=RequestMethod.GET)
	public String getStockTrades(@PathVariable String symbol, Model model) {
		Date tradeDate = applicationProps.getLastTradeDate();
		SortedSet<Trade> trades = dao.getTradesBySymbolAndDate(symbol, tradeDate);
		model.addAttribute("trades", getUniqueTrades(trades));
		return "trades";
	}

	@RequestMapping(value="/mostwatched/rss", method=RequestMethod.GET)
	public String getMostWatchedStocks(Model model) {
		model.addAttribute("stocks", dao.getMostWatchedStocks(MOST_WATCHED_LIMIT));
		return "mostWatched.rss";
	}

	@RequestMapping(value="/{symbol}/getcomments", method=RequestMethod.GET)
	public String getComments(@PathVariable String symbol, 
		HttpServletRequest request, Model model) {
		model.addAttribute("user", request.getSession().getAttribute("user"));
		model.addAttribute("comments", dao.getStockCommentsBySymbol(symbol, COMMENT_LIMIT));
		return "stockComments";
	}

	@RequestMapping(value="/{symbol}/postcomment", method=RequestMethod.POST)
	public String postComment(@PathVariable String symbol, 
		HttpServletRequest request, Model model) {
		User user = (User)request.getSession().getAttribute("user");
		model.addAttribute("user", user);
		Comment comment = new Comment();
		comment.setCreated(new Date());
		comment.setText(getRequestParameter(request, "comment"));
		comment.setUserId(user.getId());
		comment.setUserDisplayName(user.getDisplayName());
		dao.insertStockComment(symbol, comment);
		model.addAttribute("comment", comment);
		LOGGER.info("User {} posted comment on stock symbol {}", 
			user.getId(), symbol);
		return "stockComment";
	}

	@ResponseBody
	@RequestMapping(value="/{symbol}/deletecomment", method=RequestMethod.POST)
	public void deleteComment(@PathVariable String symbol, 
		HttpServletRequest request, HttpServletResponse response, Model model)
		throws IOException {
		UUID userId = 
			((User)request.getSession().getAttribute("user")).getId();
		UUID commentId = UUID.fromString(getRequestParameter(request, "commentId"));
		dao.deleteStockComment(symbol, userId, commentId);
		response.setContentType("application/json");
		response.getWriter().print("\"" + commentId + "\"");
		LOGGER.info("User {} deleted comment on stock symbol {}", userId, 
			symbol);
	}

	private long getElapsedTime(Date first, Date last) {
		return (last.getTime() - first.getTime()) / 1000;
	}

	private Collection<Trade> getUniqueTrades(SortedSet<Trade> source) {
		Map<Date, Trade> trades = new TreeMap<Date, Trade>();
		for(Trade trade : source) {
			trades.put(trade.getTimestamp(), trade);
		}
		return trades.values();
	}

	private static final Comparator<Industry> INDUSTRY_NAME_COMPARATOR = 
		new Comparator<Industry>() {
		@Override
		public int compare(Industry i1, Industry i2) {
			int sectorCompareTo = i1.getSector().compareTo(i2.getSector());
			return sectorCompareTo == 0 ? i1.getName().compareTo(i2.getName()) : 
				sectorCompareTo;
		}
	};
}