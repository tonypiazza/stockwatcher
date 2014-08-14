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

import org.apache.commons.lang.builder.ToStringStyle;

/**
 * A domain class that represents a stock that is traded on an exchange. 
 * Stocks are identified by their symbol. The source of this data is the 
 * Yahoo Finance site (http://finance.yahoo.com).
 * 
 * @author Tony Piazza
 */
public class Stock implements Comparable<Stock> {
	private String symbol;
	private String companyName;
	private String exchangeId;
	private Industry industry;
	private transient BigDecimal currentPrice;
	private transient Date priceUpdated;
	private boolean active;

	public Stock(String symbol, String companyName, String exchangeId, 
		Industry industry, BigDecimal currentPrice, Date priceUpdated) {
		this(symbol, companyName, exchangeId, industry, currentPrice, 
			priceUpdated, true);
	}

	public Stock(String symbol, String companyName, String exchangeId, 
		Industry industry, BigDecimal currentPrice, Date priceUpdated, 
		boolean active) {
		this.symbol = symbol;
		this.companyName = companyName;
		this.exchangeId = exchangeId;
		this.industry = industry;
		this.currentPrice = currentPrice;
		this.priceUpdated = priceUpdated;
		this.active = active;
	}

	/**
	 * Copy construcor
	 * @param stock
	 */
	protected Stock(Stock stock) {
		this(stock.getSymbol(), stock.companyName, stock.exchangeId, 
			stock.industry, stock.currentPrice, stock.priceUpdated, 
			stock.active);
	}

	public String getSymbol() {
		return symbol;
	}

	public String getCompanyName() {
		return companyName;
	}

	public String getExchangeId() {
		return exchangeId;
	}

	public Industry getIndustry() {
		return industry;
	}

	public BigDecimal getCurrentPrice() {
		return currentPrice;
	}

	public Date getPriceUpdated() {
		return priceUpdated;
	}

	public boolean isActive() {
		return active;
	}

	@Override
	public int compareTo(Stock other) {
		return symbol.compareTo(other.symbol);
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
		return reflectionToString(this, ToStringStyle.SHORT_PREFIX_STYLE, true);
	}
}