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

import java.util.Currency;

/**
 * A domain class that represents a service where investors can buy and sell 
 * shares of listed stocks. Each stock is traded on a single exchange.
 * 
 * @author Tony Piazza
 */
public class Exchange implements Comparable<Exchange> {
	private String exchangeId;
	private String name;
	private Currency currency;
	private boolean active;

	public Exchange(String exchangeId, String name, Currency currency) {
		this(exchangeId, name, currency, true);
	}

	public Exchange(String exchangeId, String name, Currency currency, 
		boolean active) {
		this.exchangeId = exchangeId;
		this.name = name;
		this.currency = currency;
		this.active = active;
	}

	public String getId() {
		return exchangeId;
	}

	public String getExchangeId() {
		return exchangeId;
	}

	public String getName() {
		return name;
	}

	public Currency getCurrency() {
		return currency;
	}

	public boolean isActive() {
		return active;
	}

	@Override
	public int compareTo(Exchange other) {
		return exchangeId.compareTo(other.exchangeId);
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