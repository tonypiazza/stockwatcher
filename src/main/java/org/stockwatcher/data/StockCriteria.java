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

import static org.apache.commons.lang.builder.EqualsBuilder.reflectionEquals;
import static org.apache.commons.lang.builder.HashCodeBuilder.reflectionHashCode;
import static org.apache.commons.lang.builder.ToStringBuilder.reflectionToString;

import java.math.BigDecimal;

import org.apache.commons.lang.builder.ToStringStyle;

/**
 * A class that represents search criteria for stocks. Intended for passing
 * data between an HTML form and the findStocks method in the StockDAO 
 * interface. Data validation is done in the DAO.
 * 
 * @author Tony Piazza
 */
public class StockCriteria {
	private String[] exchangeIds;
	private Integer[] industryIds;
	private BigDecimal minimumPrice;
	private BigDecimal maximumPrice;

	public String[] getExchangeIds() {
		return exchangeIds;
	}

	public void setExchangeIds(String[] exchangeIds) {
		this.exchangeIds = exchangeIds;
	}

	public Integer[] getIndustryIds() {
		return industryIds;
	}

	public void setIndustryIds(Integer[] industryIds) {
		this.industryIds = industryIds;
	}

	public BigDecimal getMinimumPrice() {
		return minimumPrice == null ? BigDecimal.ZERO : minimumPrice;
	}

	public void setMinimumPrice(BigDecimal minimumPrice) {
		this.minimumPrice = minimumPrice;
	}

	public BigDecimal getMaximumPrice() {
		return maximumPrice == null ? BigDecimal.valueOf(Long.MAX_VALUE) : 
			maximumPrice;
	}

	public void setMaximumPrice(BigDecimal maximumPrice) {
		this.maximumPrice = maximumPrice;
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