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
package org.stockwatcher.domain;

import static org.apache.commons.lang.builder.EqualsBuilder.reflectionEquals;
import static org.apache.commons.lang.builder.HashCodeBuilder.reflectionHashCode;
import static org.apache.commons.lang.builder.ToStringBuilder.reflectionToString;

import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

/**
 * A domain class that represents a transaction on a stock exchange. 
 * 
 * @author Tony Piazza
 */
public class Trade implements Comparable<Trade> {
	private UUID id;
	private Date timestamp;
	private String exchangeId;
	private String stockSymbol;
	private BigDecimal sharePrice;
	private int shareQuantity;

	public Trade(UUID id, Date timestamp, String exchangeId, 
		String stockSymbol, BigDecimal sharePrice, int shareQuantity) {
		if(id == null) {
			throw new IllegalArgumentException("id is null");
		}
		this.id = id;
		if(timestamp == null) {
			throw new IllegalArgumentException("timestamp is null");
		}
		this.timestamp = timestamp;
		if(exchangeId == null || exchangeId.length() == 0) {
			throw new IllegalArgumentException("exchangeId is null or zero length");
		}
		this.exchangeId = exchangeId;
		if(stockSymbol == null || stockSymbol.length() == 0) {
			throw new IllegalArgumentException("stockSymbol is null or zero length");
		}
		this.stockSymbol = stockSymbol;
		if(sharePrice == null) {
			throw new IllegalArgumentException("sharePrice is null");
		}
		this.sharePrice = sharePrice;
		this.shareQuantity = shareQuantity;
	}

	public UUID getId() {
		return id;
	}

	public Date getTimestamp() {
		return timestamp;
	}

	public String getExchangeId() {
		return exchangeId;
	}

	public String getStockSymbol() {
		return stockSymbol;
	}

	public BigDecimal getSharePrice() {
		return sharePrice;
	}

	public int getShareQuantity() {
		return shareQuantity;
	}

	@Override
	public int compareTo(Trade other) {
		return id.compareTo(other.id);
	}

	@Override
	public boolean equals(Object other) {
		return reflectionEquals(this, other, false);
	}

	@Override
	public int hashCode() {
		return reflectionHashCode(this, false);
	}

	@Override
	public String toString() {
		return reflectionToString(this);
	}
}