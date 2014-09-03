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

import static com.datastax.driver.core.querybuilder.QueryBuilder.batch;
import static com.datastax.driver.core.querybuilder.QueryBuilder.decr;
import static com.datastax.driver.core.querybuilder.QueryBuilder.delete;
import static com.datastax.driver.core.querybuilder.QueryBuilder.eq;
import static com.datastax.driver.core.querybuilder.QueryBuilder.in;
import static com.datastax.driver.core.querybuilder.QueryBuilder.insertInto;
import static com.datastax.driver.core.querybuilder.QueryBuilder.select;
import static com.datastax.driver.core.querybuilder.QueryBuilder.update;

import java.util.Date;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.UUID;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.stockwatcher.data.DAOException;
import org.stockwatcher.domain.Stock;
import org.stockwatcher.domain.WatchList;
import org.stockwatcher.domain.WatchListItem;

import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.RegularStatement;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Statement;
import com.datastax.driver.core.exceptions.DriverException;
import com.datastax.driver.core.querybuilder.Batch;
import com.datastax.driver.core.utils.UUIDs;

/**
 * Implementation of the WatchListDAO interface for Apache Cassandra.
 * 
 * NOTE: There are a few places in this class where we perform a read before 
 * write. As a general rule this is something we want to avoid. In the cases 
 * where we have done this we made a conscious decision to validate the data
 * being passed in so we can throw an appropriate exception. 
 * 
 * @author Tony Piazza
 */
@Repository
public class WatchListDAOImpl extends CassandraDAO implements CassandraWatchListDAO {

	@Autowired
	private CassandraStockDAO stockDAO;

	private PreparedStatement insertWatchListItem;
	private PreparedStatement selectWatchListById;
	private PreparedStatement selectWatchListsByUserId;
	private PreparedStatement selectWatchListItems;
	private PreparedStatement selectWatchListItemCount;
	private PreparedStatement selectWatchListCountByUserId;
	private PreparedStatement updateWatchListCount;
	private PreparedStatement updateWatchListById;

	@PostConstruct
	public void init() {
		insertWatchListItem = prepare("INSERT INTO WatchListItem (watchlist_id,stock_symbol, created, start_price) VALUES (?, ?, ?, ?) IF NOT EXISTS");
		selectWatchListById = prepare("SELECT watchlist_id, user_id, display_name, visibility, active, updated FROM WatchList WHERE watchlist_id=?");
		selectWatchListsByUserId = prepare("SELECT watchlist_id, user_id, display_name, visibility, active, updated FROM WatchList WHERE user_id=?");
		selectWatchListItems = prepare("SELECT watchlist_id, stock_symbol, start_price, created FROM WatchListItem WHERE watchlist_id=?");
		selectWatchListItemCount = prepare("SELECT COUNT(*) FROM WatchListItem WHERE watchlist_id=?");
		selectWatchListCountByUserId = prepare("SELECT COUNT(*) FROM WatchList WHERE user_id=?");
		updateWatchListCount = prepare("UPDATE StockCount SET watch_count = watch_count+1 WHERE stock_symbol = ?");
		updateWatchListById = prepare("UPDATE WatchList SET display_name=?, visibility=?, active=?, updated=? WHERE watchlist_id=?");
		
	}

	@Override
	public void deleteWatchList(UUID id) {
		deleteWatchList(getDefaultOptions(), id);
	}

	@Override
	public void deleteWatchList(StatementOptions options, UUID id) {
		if(id == null) {
			throw new IllegalArgumentException("id argument is null");
		}
		try {
			// Get the stock symbols before we delete them from the watch list
			SortedSet<String> symbols = getWatchListStockSymbols(options, id);
			RegularStatement statement1 = delete()
				.from("WatchListItem")
				.where(eq("watchlist_id", id));
			Batch batch = batch(statement1);
			RegularStatement statement2 = delete()
				.from("WatchList")
				.where(eq("watchlist_id", id));
			batch.add(statement2);
			execute(batch, options);
			// Statements with counter column families cannot be executed in a batch
			if(!symbols.isEmpty()) {
				Statement statement3 = update("StockCount")
					.with(decr("watch_count"))
					.where(in("stock_symbol", (Object[])symbols.toArray()));
				execute(statement3, options);
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	private int getWatchListItemCount(StatementOptions options, UUID id) {
		BoundStatement bs = selectWatchListItemCount.bind();
		bs.setUUID("watchlist_id", id);
		Row row = execute(bs, options).one();
		long count = row.getLong(0);
		if(count > Integer.MAX_VALUE) {
			throw new IllegalStateException("count is too big");
		}
		return (int)count;
	}

	@Override
	public WatchList getWatchList(UUID id) {
		return getWatchList(getDefaultOptions(), id);
	}

	@Override
	public WatchList getWatchList(StatementOptions options, UUID id) {
		if(id == null) {
			throw new IllegalArgumentException("id argument is null");
		}
		try {
			BoundStatement bs = selectWatchListById.bind();
			bs.setUUID("watchlist_id", id);
			Row watchListRow = execute(bs, options).one();
			if(watchListRow == null) {
				throw new DAOException("no watch list found for specified id");
			}
			return WatchListHelper.createWatchList(watchListRow, 
				getWatchListItemCount(options, id)); 
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public int getWatchListCountByUserId(UUID userId) {
		return getWatchListCountByUserId(getDefaultOptions(), userId);
	}

	@Override
	public int getWatchListCountByUserId(StatementOptions options, UUID userId) {
		try {
			BoundStatement bs = selectWatchListCountByUserId.bind();
			bs.setUUID("user_id", userId);
			Row row = execute(bs, options).one();
			long count = row.getLong(0);
			if(count > Integer.MAX_VALUE) {
				throw new IllegalStateException("count is too big");
			}
			return (int)count;
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public SortedSet<WatchList> getWatchListsByUserId(UUID userId) {
		return getWatchListsByUserId(getDefaultOptions(), userId);
	}

	@Override
	public SortedSet<WatchList> getWatchListsByUserId(StatementOptions options, UUID userId) {
		if(userId == null) {
			throw new IllegalArgumentException("userId argument is null");
		}
		SortedSet<WatchList> watchLists = new TreeSet<WatchList>();
		try {
			BoundStatement bs = selectWatchListsByUserId.bind();
			bs.setUUID("user_id", userId);
			for(Row row : execute(bs, options)) {
				UUID id = row.getUUID("watchlist_id"); 
				watchLists.add(WatchListHelper.createWatchList(row, 
					getWatchListItemCount(options, id))); 
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return watchLists;
	}

	@Override
	public SortedSet<String> getWatchListStockSymbols(UUID id) {
		return getWatchListStockSymbols(getDefaultOptions(), id);
	}

	@Override
	public SortedSet<String> getWatchListStockSymbols(StatementOptions options, UUID id) {
		if(id == null) {
			throw new IllegalArgumentException("id argument is null");
		}

		// We assume that the watchlist id is valid
		SortedSet<String> stocks = new TreeSet<String>();
		try {
			Statement statement = select()
					.column("stock_symbol")
				.from("WatchListItem")
				.where(eq("watchlist_id", id));
			for(Row row : execute(statement, options)) {
				stocks.add(row.getString("stock_symbol"));
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return stocks;
	}

	@Override
	public SortedSet<WatchListItem> getWatchListItems(UUID id) {
		return getWatchListItems(getDefaultOptions(), id);
	}

	@Override
	public SortedSet<WatchListItem> getWatchListItems(StatementOptions options, UUID id) {
		if(id == null) {
			throw new IllegalArgumentException("id argument is null");
		}

		// We assume that the watchlist id is valid
		SortedSet<WatchListItem> items = new TreeSet<WatchListItem>();
		try {
			BoundStatement bs = selectWatchListItems.bind();
			bs.setUUID("watchlist_id", id);
			for(Row row : execute(bs, options)) {
				items.add(WatchListHelper.createWatchListItem(row, 
					stockDAO.getStockBySymbol(options, 
						row.getString("stock_symbol"))));
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return items;
	}

	@Override
	public void insertWatchList(WatchList watchList) {
		insertWatchList(getDefaultOptions(), watchList);
	}

	@Override
	public void insertWatchList(StatementOptions options, WatchList watchList) {
		if(watchList == null) {
			throw new IllegalArgumentException("watchList argument is null");
		}
		UUID userId = watchList.getUserId();
		if(userId == null) {
			throw new IllegalArgumentException("userId property is null");
		}
		UUID id = UUIDs.timeBased();
		Date now = new Date(UUIDs.unixTimestamp(id));
		try {
			Statement statement = insertInto("WatchList")
				.value("watchlist_id", id)
				.value("user_id", watchList.getUserId())
				.value("display_name", watchList.getDisplayName())
				.value("visibility", watchList.getVisibility().name())
				.value("active", watchList.isActive())
				.value("updated", now);
			execute(statement, options);
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		watchList.setId(id);
		watchList.setCreated(now);
		watchList.setUpdated(now);
	}

	@Override
	public void updateWatchList(WatchList watchList) {
		updateWatchList(getDefaultOptions(), watchList);
	}

	@Override
	public void updateWatchList(StatementOptions options, WatchList watchList) {
		if(watchList == null) {
			throw new IllegalArgumentException("watchList is null");
		}
		final UUID id = watchList.getId();
		if(id == null) {
			throw new IllegalArgumentException("id property is null");
		}

		// We assume that the watchlist id is valid
		Date now = new Date();
		try {
			BoundStatement bs = updateWatchListById.bind();
			bs.setString("display_name", watchList.getDisplayName());
			bs.setString("visibility", watchList.getVisibility().name());
			bs.setBool("active", watchList.isActive());
			bs.setDate("updated", now);
			bs.setUUID("watchlist_id", id);
			execute(bs, options);
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		watchList.setUpdated(now);
	}

	@Override
	public void addWatchListStock(UUID id, String stockSymbol) {
		addWatchListStock(getDefaultOptions(), id, stockSymbol);
	}

	/**
	 * Add a stock to a watch list.  We assume that the passed
	 * in watch list id and the stock symbol are valid and exist
	 * 
	 * @param id  The watch list id
	 * @param stockSymbol The stock symbol to remove 
	 */
	@Override
	public void addWatchListStock(StatementOptions options, UUID id, 
		String stockSymbol) {
		if(id == null) {
			throw new IllegalArgumentException("id argument is null");
		}

		Stock stock = stockDAO.getStockBySymbol(options, stockSymbol);
		try {
			/*******
			 * Business requirement: Make sure the stock is not already on the 
			 * watch list, otherwise we upsert and lose the original created date.
			 * We do this using CAS in the prepared statement (using IF NOT EXISTS on the INSERT)
			 *******/
			Date now = new Date();
			BoundStatement bs = insertWatchListItem.bind();
			bs.setUUID("watchlist_id", id);
			bs.setString("stock_symbol", stockSymbol);
			bs.setDate("created", now);
			bs.setDecimal("start_price", stock.getCurrentPrice());

			/*******
			 * Statements with counter column families cannot be executed in a batch.
			 * However, we need to make sure that we only update the counter if 
			 * the insert succeeds - accordingly we get the result of the CAS [applied] 
			 * column which will be true if the update succeeded.
			 */
			Row insertResult = execute(bs, options).one();
			boolean applied = insertResult.getBool("[applied]");
			System.out.println("WLDAOImp.addWatchListStock applied = " + applied);
			if (applied) {
				BoundStatement bs2 = updateWatchListCount.bind();
				bs2.setString("stock_symbol", stockSymbol);
				execute(bs2, options);
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public void removeWatchListStock(UUID id, String stockSymbol) {
		removeWatchListStock(getDefaultOptions(), id, stockSymbol);
	}

	/**
	 * Remove a stock from a watch list.  We assume that the passed
	 * in watch list id, and the stock symbol are valid and exist
	 * 
	 * @param id  The watch list id
	 * @param stockSymbol The stock symbol to remove 
	 */
	@Override
	public void removeWatchListStock(StatementOptions options, UUID id, 
		String stockSymbol) {
		if(id == null) {
			throw new IllegalArgumentException("id argument is null");
		}

		try {
			// We need to know if the stock was actually on the watch list 
			// before we decrement the counters.
			Statement statement1 = select()
					.column("watchlist_id")
					.column("stock_symbol")
					.column("start_price")
					.column("created")
				.from("WatchListItem")
				.where(eq("watchlist_id", id))
					.and(eq("stock_symbol", stockSymbol));
			Row row = execute(statement1, options).one();
			if(row == null) {
				throw new IllegalArgumentException(
					"stock symbol is not on the specified watchList");
			}
			Statement statement2 = delete()
					.from("WatchListItem")
					.where(eq("watchlist_id", id))
						.and(eq("stock_symbol",stockSymbol));
			execute(statement2, options);
			// Statements with counter column families cannot be executed in a batch
			Statement statement3 = update("StockCount")
				.with(decr("watch_count"))
				.where(eq("stock_symbol", stockSymbol));
			execute(statement3, options);
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public int getWatchCount(String symbol) {
		return getWatchCount(getDefaultOptions(), symbol);
	}

	@Override
	public int getWatchCount(StatementOptions options, String symbol) {
		try {
			Statement statement = select().column("watch_count")
				.from("StockCount")
				.where(eq("stock_symbol", symbol));
			Row row = execute(statement, options).one();
			long result = row == null ? 0 : row.getLong("watch_count");
			if(result > Integer.MAX_VALUE) {
				throw new IllegalStateException("watch count is too big");
			}
			return (int)result;
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}
}