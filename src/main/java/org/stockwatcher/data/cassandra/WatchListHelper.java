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

import java.util.Date;

import org.stockwatcher.domain.Stock;
import org.stockwatcher.domain.WatchList;
import org.stockwatcher.domain.WatchList.Visibility;
import org.stockwatcher.domain.WatchListItem;

import com.datastax.driver.core.Row;
import com.datastax.driver.core.utils.UUIDs;

/**
 * Utility class that provides a static method for watch lists and 
 * watch list items from data returned by a query.
 * 
 * @author Tony Piazza
 */
public final class WatchListHelper {
	private WatchListHelper() {
		// prevents instantiation
	}

	public static WatchList createWatchList(Row row, int itemCount) {
		WatchList watchList = new WatchList();
		watchList.setId(row.getUUID("watchlist_id"));
		watchList.setUserId(row.getUUID("user_id"));
		watchList.setDisplayName(row.getString("display_name"));
		watchList.setVisibility(Visibility.valueOf(row.getString("visibility")));
		watchList.setActive(row.getBool("active"));
		watchList.setCreated(new Date(UUIDs.unixTimestamp(watchList.getId())));
		watchList.setUpdated(row.getDate("updated"));
		watchList.setItemCount(itemCount);
		return watchList;
	}

	public static WatchListItem createWatchListItem(Row row, Stock stock) {
		WatchListItem item = new WatchListItem(stock);
		item.setWatchListId(row.getUUID("watchlist_id"));
		item.setCreated(row.getDate("created"));
		item.setStartPrice(row.getDecimal("start_price"));
		return item;
	}
}