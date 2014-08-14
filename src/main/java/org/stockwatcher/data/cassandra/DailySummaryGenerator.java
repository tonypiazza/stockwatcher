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

import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jmx.export.annotation.ManagedAttribute;
import org.springframework.jmx.export.annotation.ManagedOperation;
import org.springframework.jmx.export.annotation.ManagedResource;

import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.ResultSetFuture;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Session;

/**
 * Class that contains functionality for generating the daily stock summaries 
 * based on trade data for the most recent trade date. This class makes use of 
 * asynchronous query execution to spread the work across nodes in the cluster.
 * 
 * @author Tony Piazza
 */
@ManagedResource
public class DailySummaryGenerator {
	private static final Logger LOGGER = LoggerFactory.getLogger(DailySummaryGenerator.class);
	private static final DateFormat TRADE_DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");
	private static final int BATCH_SIZE = 250;

	private Date lastExecution = new Date(0);
	private Session session;
	private PreparedStatement selectActiveStockSymbols;
	private PreparedStatement selectTradesBySymbolAndDate;
	private PreparedStatement insertDailySummary;
	private PreparedStatement selectLastTradeDate;

	@Autowired
	private SessionFactory sessionFactory;

	@PostConstruct
	public void init() {
		session = sessionFactory.getSession();
		selectActiveStockSymbols = session.prepare("SELECT stock_symbol FROM Stock WHERE active=true");
		selectTradesBySymbolAndDate = session.prepare("SELECT stock_symbol, trade_id, trade_date, trade_timestamp, exchange_id, share_price, share_quantity FROM Trade WHERE stock_symbol = ? AND trade_date = ?");
		insertDailySummary = session.prepare("INSERT INTO DailySummary (stock_symbol, trade_date, price_open, price_close, price_high, price_low, share_volume) VALUES (?, ?, ?, ?, ?, ?, ?)");
		selectLastTradeDate = session.prepare("SELECT property_value_timestamp FROM ApplicationProperty WHERE property_name='last_trade_date'");
	}

	@ManagedOperation(description="Generates daily summaries for all active stocks")
	public void generateDailySummaries() {
		Date tradeDate = session.execute(selectLastTradeDate.bind())
			.one().getDate("property_value_timestamp");

		LOGGER.info("Started generating daily summaries for {}", 
			TRADE_DATE_FORMAT.format(tradeDate));

		List<ResultSetFuture> selectFutures = new ArrayList<ResultSetFuture>();
		List<ResultSetFuture> insertFutures = new ArrayList<ResultSetFuture>();
		int count = 0;
		for(Row row : session.execute(selectActiveStockSymbols.bind())) {		
			BoundStatement bs = selectTradesBySymbolAndDate.bind();
			bs.setString("stock_symbol", row.getString("stock_symbol"));
			bs.setDate("trade_date", tradeDate);
			selectFutures.add(session.executeAsync(bs));
			if(++count % BATCH_SIZE == 0) {
				insertFutures.addAll(processTradesForSymbol(selectFutures));
			}
		}
		// Process any remaining futures
		insertFutures.addAll(processTradesForSymbol(selectFutures));

		// Confirm the inserts were successful
		for(ResultSetFuture future : insertFutures) {
			future.getUninterruptibly();
		}

		LOGGER.info("Finished generating daily summaries for {}", 
			TRADE_DATE_FORMAT.format(tradeDate));
		lastExecution = new Date();
	}

	@ManagedAttribute(description="Last time this task was executed")
	public Date getLastExecution() {
		return lastExecution;
	}

	private List<ResultSetFuture> processTradesForSymbol(List<ResultSetFuture> selectFutures) {
		List<ResultSetFuture> insertFutures = new ArrayList<ResultSetFuture>();
		for(ResultSetFuture future : selectFutures) {
			String symbol = null;
			Date tradeDate = null;
			BigDecimal open = BigDecimal.ZERO;
			BigDecimal high = BigDecimal.ZERO;
			BigDecimal low = BigDecimal.valueOf(Long.MAX_VALUE);
			BigDecimal close = BigDecimal.ZERO;
			BigDecimal sharePrice = null;
			int volume = 0;
			for(Row row : future.getUninterruptibly()) {
				if(symbol == null) {
					symbol = row.getString("stock_symbol");
					tradeDate = row.getDate("trade_date");
					open = row.getDecimal("share_price");
					LOGGER.debug("Processing trades for symbol {} on {}", 
						symbol, tradeDate);
				}
				sharePrice = row.getDecimal("share_price");
				if(sharePrice.compareTo(high) > 0) {
					high = sharePrice;
				}
				if(sharePrice.compareTo(low) < 0) {
					low = sharePrice;
				}
				close = sharePrice;
				volume += row.getInt("share_quantity");				
			}
			if(volume > 0) {
				insertFutures.add(insert(symbol, tradeDate, open, high, low, close, volume));
			}
		}
		selectFutures.clear();
		return insertFutures;
	}

	private ResultSetFuture insert(String symbol, Date tradeDate, 
		BigDecimal open, BigDecimal high, BigDecimal low, BigDecimal close, 
		int volume) {
		BoundStatement bs = insertDailySummary.bind();
		bs.setString("stock_symbol", symbol);
		bs.setDate("trade_date", tradeDate);
		bs.setDecimal("price_open", open);
		bs.setDecimal("price_high", high);
		bs.setDecimal("price_low", low);
		bs.setDecimal("price_close", close);
		bs.setInt("share_volume", volume);
		return session.executeAsync(bs);
	}
}