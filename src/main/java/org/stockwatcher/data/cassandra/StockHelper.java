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

import java.util.Currency;
import java.util.Date;
import java.util.UUID;

import org.stockwatcher.domain.Comment;
import org.stockwatcher.domain.Exchange;
import org.stockwatcher.domain.Industry;
import org.stockwatcher.domain.Sector;
import org.stockwatcher.domain.Stock;
import org.stockwatcher.domain.Trade;

import com.datastax.driver.core.Row;
import com.datastax.driver.core.utils.UUIDs;

/**
 * Utility class that provides static methods for creating stock and related 
 * domain objects from data returned by a query.
 * 
 * @author Tony Piazza
 */
public final class StockHelper {
	private StockHelper() {
		// prevents instantiation
	}

	public static Stock createStock(Row row) {
		return new Stock(
			row.getString("stock_symbol"), 
			row.getString("company_name"),
			row.getString("exchange_id"),
			createIndustry(row),
			row.getDecimal("current_price"),
			row.getDate("price_updated"));
	}

	public static Industry createIndustry(Row row) {
		return new Industry(
			row.getInt("industry_id"),
			row.getString("industry_name"),
			createSector(row));
	}

	public static Sector createSector(Row row) {
		return new Sector(
			row.getInt("sector_id"),
			row.getString("sector_name"));		
	}

	public static Exchange createExchange(Row row) {
		return new Exchange(
			row.getString("exchange_id"),
			row.getString("exchange_name"),
			Currency.getInstance(row.getString("currency_code")));
	}

	public static Trade createTrade(Row row) {
		return new Trade(
			row.getUUID("trade_id"),
			row.getDate("trade_timestamp"),
			row.getString("exchange_id"),
			row.getString("stock_symbol"),
			row.getDecimal("share_price"),
			row.getInt("share_quantity"));
	}

	public static Comment createComment(Row row) {
		Comment comment = new Comment();
		UUID commentId = row.getUUID("comment_id");
		comment.setId(commentId);
		comment.setUserId(row.getUUID("user_id"));
		comment.setUserDisplayName(row.getString("user_display_name"));
		comment.setCreated(new Date(UUIDs.unixTimestamp(commentId)));
		comment.setText(row.getString("comment"));
		return comment;
	}
}