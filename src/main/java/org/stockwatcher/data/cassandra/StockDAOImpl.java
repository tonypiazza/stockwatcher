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
package org.stockwatcher.data.cassandra;

import static com.datastax.driver.core.querybuilder.QueryBuilder.eq;
import static com.datastax.driver.core.querybuilder.QueryBuilder.in;
import static com.datastax.driver.core.querybuilder.QueryBuilder.select;
import static org.stockwatcher.data.cassandra.StockHelper.createComment;
import static org.stockwatcher.data.cassandra.StockHelper.createExchange;
import static org.stockwatcher.data.cassandra.StockHelper.createIndustry;
import static org.stockwatcher.data.cassandra.StockHelper.createStock;
import static org.stockwatcher.data.cassandra.StockHelper.createTrade;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.UUID;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.stockwatcher.data.DAOException;
import org.stockwatcher.data.StockCriteria;
import org.stockwatcher.domain.Comment;
import org.stockwatcher.domain.Exchange;
import org.stockwatcher.domain.Industry;
import org.stockwatcher.domain.Stock;
import org.stockwatcher.domain.Trade;

import com.datastax.driver.core.BatchStatement;
import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.ResultSetFuture;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Statement;
import com.datastax.driver.core.exceptions.DriverException;
import com.datastax.driver.core.querybuilder.Clause;
import com.datastax.driver.core.utils.UUIDs;

/**
 * Implementation of the StockDAO interface for Apache Cassandra.
 * 
 * @author Tony Piazza
 */
@Repository
public class StockDAOImpl extends CassandraDAO implements StockDAO {
	@Autowired
	private UserDAO userDAO;

	private PreparedStatement selectTradesBySymbolAndDate;
	private PreparedStatement selectStockWatchCounts;
	private PreparedStatement selectStockBySymbol;
	private PreparedStatement selectStockCommentsBySymbol;
	private PreparedStatement deleteStockCommentBySymbol;
	private PreparedStatement deleteStockCommentByUser;
	private PreparedStatement insertStockCommentBySymbol;
	private PreparedStatement insertStockCommentByUser;
	private PreparedStatement selectLastClosePrice;
	private PreparedStatement updateStockViewCount;

	@PostConstruct
	public void init() {
		selectTradesBySymbolAndDate = prepare("SELECT stock_symbol, trade_id, trade_date, trade_timestamp, exchange_id, share_price, share_quantity FROM Trade WHERE stock_symbol = ? AND trade_date = ?");
		selectStockWatchCounts = prepare("SELECT stock_symbol, watch_count FROM StockCount");
		selectStockBySymbol = prepare("SELECT stock_symbol, company_name, exchange_id, current_price, price_updated, active, industry_id, industry_name, sector_id, sector_name FROM Stock WHERE stock_symbol = ?");
		selectStockCommentsBySymbol = prepare("SELECT stock_symbol, comment_id, user_id, user_display_name, comment, active FROM StockCommentBySymbol WHERE stock_symbol = ?");
		deleteStockCommentBySymbol = prepare("UPDATE StockCommentBySymbol SET active=false WHERE stock_symbol=? AND comment_id=?");
		deleteStockCommentByUser = prepare("UPDATE StockCommentByUser SET active=false WHERE user_id=? AND comment_id=?");
		insertStockCommentBySymbol = prepare("INSERT INTO StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, comment, active) VALUES (?, ?, ?, ?, ?, ?)");
		insertStockCommentByUser = prepare("INSERT INTO StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, comment, active) VALUES (?, ?, ?, ?, ?, ?)");
		selectLastClosePrice = prepare("SELECT price_close FROM DailySummary WHERE stock_symbol=? LIMIT 1");
		updateStockViewCount = prepare("UPDATE StockCount SET view_count=view_count+1 WHERE stock_symbol=?");
	}

	@Override
	public SortedSet<Industry> getIndustries() {
		return getIndustries(getDefaultOptions());
	}

	@Override
	public SortedSet<Industry> getIndustries(StatementOptions options) {
		SortedSet<Industry> industries = new TreeSet<Industry>();
		try{
			Statement statement = select()
					.column("industry_id")
					.column("industry_name")
					.column("sector_id")
					.column("sector_name")
				.from("Industry");
			for(Row row : execute(statement, options)) {
				industries.add(createIndustry(row));
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		if(industries.isEmpty()) {
			throw new DAOException("no industries found");
		}
		return industries;
	}

	@Override
	public Stock getStockBySymbol(String symbol) {
		return getStockBySymbol(getDefaultOptions(), symbol);
	}

	@Override
	public Stock getStockBySymbol(StatementOptions options, String symbol) {
		if(symbol == null) {
			throw new IllegalArgumentException("symbol is null");
		}
		try {
			Clause where = eq("stock_symbol", symbol);
			Row row = getStockResultSet(options, where).one();
			if(row == null) {
				throw new DAOException("no stock found with specified symbol");
			}
			return createStock(row);
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public Map<String, BigDecimal> getCurrentPriceForSymbols(String... symbols) {
		return getCurrentPriceForSymbols(getDefaultOptions(), symbols);
	}

	@Override
	public Map<String, BigDecimal> getCurrentPriceForSymbols(StatementOptions options, String... symbols) {
		if(symbols == null || symbols.length == 0) {
			throw new IllegalArgumentException("symbols argument is null or zero length");
		}
		Map<String, BigDecimal> priceMap = new TreeMap<String, BigDecimal>();
		try {
			Statement statement = select()
					.column("stock_symbol")
					.column("current_price")
					.column("active")
				.from("Stock")
				.where(in("stock_symbol", (Object[])symbols));
			for(Row row : execute(statement, options)) {
				if(row.getBool("active")) {
					priceMap.put(row.getString("stock_symbol"), row.getDecimal("current_price"));
				}
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return priceMap;
	}

	/**
	 * Internal method used to execute a query for Stocks that match the 
	 * specified where clause.
	 * 
	 * @param cl ConsistencyLevel to use for executing the query
	 * @param where Clause to use for filtering the rows
	 * @return ResultSet
	 */
	private ResultSet getStockResultSet(StatementOptions options, Clause whereClause) {
		Statement statement = select()
				.column("stock_symbol")
				.column("company_name")
				.column("exchange_id")
				.column("current_price")
				.column("price_updated")
				.column("active")
				.column("industry_id")
				.column("industry_name")
				.column("sector_id")
				.column("sector_name")
			.from("Stock")
			.where(whereClause);
		return execute(statement, options);
	}

	@Override
	public SortedSet<Exchange> getExchanges() {
		return getExchanges(getDefaultOptions());
	}

	@Override
	public SortedSet<Exchange> getExchanges(StatementOptions options) {
		SortedSet<Exchange> exchanges = new TreeSet<Exchange>();
		try {
			Statement statement = select()
					.column("exchange_id")
					.column("exchange_name")
					.column("currency_code")
				.from("Exchange")
				.where(eq("active", true));
			for(Row row : execute(statement, options)) {
				exchanges.add(createExchange(row));
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		if(exchanges.isEmpty()) {
			throw new DAOException("no active exchanges found");
		}
		return exchanges;
	}

	@Override
	public SortedSet<Stock> findStocks(StockCriteria criteria) {
		return findStocks(getDefaultOptions(), criteria);
	}

	@Override
	public SortedSet<Stock> findStocks(StatementOptions options,
		StockCriteria criteria) {
		validateCriteria(criteria);
		Integer[] industries = criteria.getIndustryIds();
		Set<String> exchanges = 
			new HashSet<String>(Arrays.asList(criteria.getExchangeIds()));
		BigDecimal minPrice = criteria.getMinimumPrice();
		BigDecimal maxPrice = criteria.getMaximumPrice();
		SortedSet<Stock> stocks = new TreeSet<Stock>();
		try {
			Set<String> symbols = getMatchingSymbols(options, industries, exchanges);
			Clause where = in("stock_symbol", symbols.toArray());
			for(Row row : getStockResultSet(options, where)) {
				BigDecimal curPrice = row.getDecimal("current_price");
				if(row.getBool("active") && (minPrice.compareTo(curPrice) <= 0) && 
					(maxPrice.compareTo(curPrice) >= 0)) {
					stocks.add(createStock(row));
				}
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return stocks;
	}

	private Set<String> getMatchingSymbols(StatementOptions options, 
		Integer[] industries, Set<String> exchanges) {
		Set<String> symbols = new HashSet<String>();
		Statement statement = select()
				.column("stock_symbol")
				.column("exchange_id")
			.from("StockSearch")
			.where(in("industry_id", (Object[])industries));
		for(Row row : execute(statement, options)) {
			if(exchanges.contains(row.getString("exchange_id"))) {
				symbols.add(row.getString("stock_symbol"));
			}
		}
		return symbols;
	}

	private void validateCriteria(StockCriteria criteria) {
		if(criteria == null) {
			throw new IllegalArgumentException("criteria is null");
		}
		Integer[] industryIds = criteria.getIndustryIds();
		if(industryIds == null || industryIds.length == 0) {
			throw new IllegalArgumentException("industryIds is null or empty");
		}
		String[] exchangeIds = criteria.getExchangeIds();
		if(exchangeIds == null || exchangeIds.length == 0) {
			throw new IllegalArgumentException("exchangeIds is null or empty");
		}
	}

	@Override
	public SortedSet<Trade> getTradesBySymbolAndDate(String symbol, Date tradeDate) {
		return getTradesBySymbolAndDate(getDefaultOptions(), symbol, tradeDate);
	}

	@Override
	public SortedSet<Trade> getTradesBySymbolAndDate(StatementOptions options,
			String symbol, Date tradeDate) {
		if(symbol == null || symbol.length() == 0) {
			throw new IllegalArgumentException("symbol is null or zero length");
		}
		if(tradeDate == null) {
			throw new IllegalArgumentException("tradeDate is null");
		}
		SortedSet<Trade> trades = new TreeSet<Trade>();
		try {
			BoundStatement bs = selectTradesBySymbolAndDate.bind();
			bs.setString("stock_symbol", symbol);
			bs.setDate("trade_date", tradeDate);
			for(Row row : execute(bs, options)) {
				trades.add(createTrade(row));
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return trades;
	}

	@Override
	public List<Stock> getMostWatchedStocks(int limit) {
		return getMostWatchedStocks(getDefaultOptions(), limit);
	}

	@Override
	public List<Stock> getMostWatchedStocks(StatementOptions options, int limit) {
		List<Stock> stocks = new ArrayList<Stock>(limit);
		try {
			BoundStatement bs = selectStockWatchCounts.bind();
			Map<Long, Set<String>> map = 
				new TreeMap<Long, Set<String>>(Collections.reverseOrder());
			for(Row row : execute(bs, options)) { 
				long watchCount = row.getLong("watch_count");
				if(watchCount > 0) {
					Set<String> values = map.get(watchCount);
					if(values == null) {
						values = new HashSet<String>();
						map.put(watchCount, values);
					}
					values.add(row.getString("stock_symbol"));
				}
			}
			int count = 0;
			List<ResultSetFuture> futures = new ArrayList<ResultSetFuture>(limit);
			for(long i : map.keySet()) {
				Iterator<String> iter = map.get(i).iterator();
				while(iter.hasNext() && count++ < limit) {
					bs = selectStockBySymbol.bind();
					bs.setString("stock_symbol", iter.next());
					futures.add(executeAsync(bs, options));
				}
			}
			for(ResultSetFuture future : futures) {
				stocks.add(createStock(future.getUninterruptibly().one()));
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return stocks;
	}

	@Override
	public void insertStockComment(String symbol, Comment comment) {
		insertStockComment(getDefaultOptions(), symbol, comment);
	}

	@Override
	public void insertStockComment(StatementOptions options, String symbol, 
		Comment comment) {
		try {
			UUID commentId = UUIDs.timeBased();
			comment.setId(commentId);
			BoundStatement bs1 = insertStockCommentBySymbol.bind();
			bs1.setString("stock_symbol", symbol);
			bs1.setUUID("comment_id", commentId);
			bs1.setUUID("user_id", comment.getUserId());
			bs1.setString("user_display_name", comment.getUserDisplayName());
			bs1.setString("comment", comment.getText());
			bs1.setBool("active", comment.isActive());
			BoundStatement bs2 = insertStockCommentByUser.bind();
			bs2.setString("stock_symbol", symbol);
			bs2.setUUID("comment_id", commentId);
			bs2.setUUID("user_id", comment.getUserId());
			bs2.setString("user_display_name", comment.getUserDisplayName());
			bs2.setString("comment", comment.getText());
			bs2.setBool("active", comment.isActive());

			// Create a batch for the two inserts, then execute (atomically)
			BatchStatement batch = new BatchStatement();
			batch.add(bs1);
			batch.add(bs2);
			execute(batch,options);

			/*
			// Example Without batch			
			execute(bs1, options);
			execute(bs2, options);
			*/
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public void deleteStockComment(String symbol, UUID userId, UUID commentId) {
		deleteStockComment(getDefaultOptions(), symbol, userId, commentId);
	}

	@Override
	public void deleteStockComment(StatementOptions options, String symbol, 
			UUID userId, UUID commentId) {
		try {
			BoundStatement bs1 = deleteStockCommentBySymbol.bind();
			bs1.setString("stock_symbol", symbol);
			bs1.setUUID("comment_id", commentId);
			BoundStatement bs2 = deleteStockCommentByUser.bind();
			bs2.setUUID("user_id", userId);
			bs2.setUUID("comment_id", commentId);
			BatchStatement batch = new BatchStatement();
			batch.add(bs1);
			batch.add(bs2);
			execute(batch,options);
/*			
			// Example Without batch			
			execute(bs1, options);
			execute(bs2, options);
*/			
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public SortedSet<Comment> getStockCommentsBySymbol(String symbol, int limit) {
		return getStockCommentsBySymbol(getDefaultOptions(), symbol, limit);
	}

	@Override
	public SortedSet<Comment> getStockCommentsBySymbol(StatementOptions options, 
		String symbol, int limit) {
		SortedSet<Comment> comments = new TreeSet<Comment>();
		try {
			BoundStatement bs = selectStockCommentsBySymbol.bind();
			bs.setString("stock_symbol", symbol);
			int count = 0;
			for(Row row : execute(bs, options)) {
				if(row.getBool("active")) {
					Comment comment = createComment(row);
					comments.add(comment);
					if(++count >= limit) {
						break;
					}
				}
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return comments;
	}

	@Override
	public BigDecimal getLastClosePriceForSymbol(String symbol) {
		return getLastClosePriceForSymbol(getDefaultOptions(), symbol);
	}

	@Override
	public BigDecimal getLastClosePriceForSymbol(StatementOptions options,
			String symbol) {
		try {
			BoundStatement bs = selectLastClosePrice.bind();
			bs.setString("stock_symbol", symbol);
			return execute(bs, options).one().getDecimal("price_close");
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public void incrementStockViewCount(String symbol) {
		incrementStockViewCount(getDefaultOptions(), symbol);
	}

	@Override
	public void incrementStockViewCount(StatementOptions options, String symbol) {
		try {
			BoundStatement bs = updateStockViewCount.bind();
			bs.setString("stock_symbol", symbol);
			execute(bs, options);
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}
}