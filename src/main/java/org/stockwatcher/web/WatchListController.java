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
import java.util.Collections;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.stockwatcher.data.UserDAO;
import org.stockwatcher.data.cassandra.StatementOptions;
import org.stockwatcher.data.cassandra.WatchListDAO;
import org.stockwatcher.domain.User;
import org.stockwatcher.domain.WatchList;

import com.datastax.driver.core.ConsistencyLevel;
import com.datastax.driver.core.policies.DowngradingConsistencyRetryPolicy;
import com.datastax.driver.core.policies.LoggingRetryPolicy;

/**
 * Controller class for all WatchList-related web requests. Uses DAO classes to 
 * interact with the database.
 * 
 * @author Tony Piazza
 */
@Controller
@RequestMapping("/watchlists")
public class WatchListController extends BaseController {
	private static final Logger LOGGER = LoggerFactory.getLogger(WatchListController.class);
	private static final String CREATE_NEW = "0";
	private static final StatementOptions DELETE_WATCHLIST_QUERYOPTIONS = 
		new StatementOptions(ConsistencyLevel.QUORUM, new LoggingRetryPolicy(
			DowngradingConsistencyRetryPolicy.INSTANCE));

	@Autowired
	private WatchListDAO watchListDAO;
	@Autowired
	private UserDAO userDAO;

	@RequestMapping(method=RequestMethod.GET)
	public String watchListsForUser(Model model, HttpServletRequest request) {
		User user = (User)request.getSession().getAttribute("user");
		model.addAttribute("watchLists", user == null ? Collections.EMPTY_SET : 
			watchListDAO.getWatchListsByUserId(user.getId()));
		return "watchLists";
	}

	@RequestMapping(value="/{watchListId}", method=RequestMethod.GET)
	public String displayWatchListDetail(@PathVariable String watchListId, 
		Model model, HttpServletRequest request) {
		UUID id = UUID.fromString(watchListId);
		model.addAttribute("watchList", watchListDAO.getWatchList(id));
		model.addAttribute("watchListItems", watchListDAO.getWatchListItems(id));
		return "watchList";
	}

	@RequestMapping(value="/{watchListId}/rss", method=RequestMethod.GET)
	public String displayWatchListDetailRss(@PathVariable String watchListId, 
		Model model, HttpServletRequest request) {
		UUID id = UUID.fromString(watchListId);
		model.addAttribute("watchListItems", watchListDAO.getWatchListItems(id));
		WatchList watchList = watchListDAO.getWatchList(id);
		model.addAttribute("watchList", watchList); 
		model.addAttribute("user", userDAO.getUser(watchList.getUserId()));
		return "watchList.rss";
	}

	@ResponseBody
	@RequestMapping(value="/delete", method=RequestMethod.POST)
	public void deleteWatchList(Model model, HttpServletRequest request,
		HttpServletResponse response) throws IOException {
		String id = getRequestParameter(request, "watchListId");
		UUID watchListId = UUID.fromString(id);
		WatchList watchList = watchListDAO.getWatchList(watchListId);
		User user = (User)request.getSession().getAttribute("user");
		if(watchList.getUserId().equals(user.getId())) {
			// Notice we are using the Cassandra-specific DAO method
			watchListDAO.deleteWatchList(DELETE_WATCHLIST_QUERYOPTIONS, 
				watchListId);
			LOGGER.info("Deleted watchList {}", watchListId);
		}
	}

	@RequestMapping(value="/addtowatchlist", method=RequestMethod.POST)
	public String addToWatchList(Model model, HttpServletRequest request) {
		String id = getRequestParameter(request, "watchListId");
		String stockSymbol = getRequestParameter(request, "stockSymbol");
		User user = (User)request.getSession().getAttribute("user");
		UUID watchListId = null;
		WatchList watchList = null;
		if(CREATE_NEW.equals(id)) {
			String displayName = getRequestParameter(request, "displayName");
			watchList = new WatchList(); 
			watchList.setDisplayName(displayName);
			watchList.setUserId(user.getId());
			watchListDAO.insertWatchList(watchList);
			watchListId = watchList.getId();
			LOGGER.info("Created watchList {}", watchListId);
		} else {
			watchListId = UUID.fromString(id);
			watchList = watchListDAO.getWatchList(watchListId);
		}
		// Make sure the user owns the watch list
		if(watchList.getUserId().equals(user.getId())) {
			watchListDAO.addWatchListStock(watchListId, stockSymbol);
			LOGGER.info("Added symbol {} to watchList {}", stockSymbol, 
				watchListId);
		} else {
			LOGGER.warn("Unable to add symbol {} to watchList {}", 
				stockSymbol, watchListId);
		}
		model.addAttribute("watchLists", user == null ? Collections.EMPTY_SET :
			watchListDAO.getWatchListsByUserId(user.getId()));
		return "watchListOptions";
	}

	@ResponseBody
	@RequestMapping(value="/removefromwatchlist", method=RequestMethod.POST)
	public void removeFromWatchList(Model model, HttpServletRequest request,
		HttpServletResponse response) {
		
		UUID watchListId = UUID.fromString(getRequestParameter(request, "watchListId"));
		String stockSymbol = getRequestParameter(request, "stockSymbol");
		User user = (User)request.getSession().getAttribute("user");
		WatchList watchList = watchListDAO.getWatchList(watchListId);
		// Make sure the user owns the watch list
		if(watchList.getUserId().equals(user.getId())) {
			watchListDAO.removeWatchListStock(watchListId, stockSymbol);
		} else {
			LOGGER.warn(
				"Attempt by {} to modify watchList {} owned by another user", 
				user.getId(), watchListId);
		}
	}
}