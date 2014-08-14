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
package org.stockwatcher.data;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.UUID;

import org.stockwatcher.domain.Comment;
import org.stockwatcher.domain.Exchange;
import org.stockwatcher.domain.Industry;
import org.stockwatcher.domain.Stock;
import org.stockwatcher.domain.Trade;

/**
 * DAO interface that provides methods for reading stocks, industries, 
 * sectors and trades.
 * 
 * @author Tony Piazza
 */
public interface StockDAO {
	Stock getStockBySymbol(String symbol) throws DAOException;
	SortedSet<Industry> getIndustries() throws DAOException;
	SortedSet<Exchange> getExchanges() throws DAOException;
	SortedSet<Stock> findStocks(StockCriteria criteria) throws DAOException;
	SortedSet<Trade> getTradesBySymbolAndDate(String symbol, Date tradeDate) throws DAOException;
	Map<String, BigDecimal> getCurrentPriceForSymbols(String... symbols) throws DAOException;
	BigDecimal getLastClosePriceForSymbol(String symbol) throws DAOException;
	List<Stock> getMostWatchedStocks(int limit) throws DAOException;
	SortedSet<Comment> getStockCommentsBySymbol(String symbol, int limit) throws DAOException;
	void insertStockComment(String symbol, Comment comment) throws DAOException;
	void deleteStockComment(String symbol, UUID userId, UUID commentId) throws DAOException;
	void incrementStockViewCount(String symbol) throws DAOException;
}