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

import java.util.SortedSet;
import java.util.UUID;

import org.stockwatcher.data.DAOException;
import org.stockwatcher.domain.WatchList;
import org.stockwatcher.domain.WatchListItem;

/**
 * Cassandra-specific DAO interface that provides methods for creating, 
 * reading, updating and deleting watch lists and watch list items. 
 * 
 * @author Tony Piazza
 */
public interface CassandraWatchListDAO extends org.stockwatcher.data.WatchListDAO {
	void insertWatchList(StatementOptions options, WatchList watchList) throws DAOException;
	void deleteWatchList(StatementOptions options, UUID id) throws DAOException;
	void updateWatchList(StatementOptions options, WatchList watchList) throws DAOException;
	WatchList getWatchList(StatementOptions options, UUID id) throws DAOException;
	SortedSet<WatchList> getWatchListsByUserId(StatementOptions options, UUID userId) throws DAOException;
	SortedSet<String> getWatchListStockSymbols(StatementOptions options, UUID id) throws DAOException;
	SortedSet<WatchListItem> getWatchListItems(StatementOptions options, UUID id) throws DAOException;
	void addWatchListStock(StatementOptions options, UUID id, String stockSymbol) throws DAOException;
	void removeWatchListStock(StatementOptions options, UUID id, String stockSymbol) throws DAOException;
	int getWatchCount(StatementOptions options, String symbol) throws DAOException;
	int getWatchListCountByUserId(StatementOptions options, UUID userId) throws DAOException;
}