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

/**
 * A domain class that represents the industry stocks are categorized under. 
 * Each stock is categorized under a single industry. The source of this data
 * is the Yahoo Finance site (http://finance.yahoo.com).
 * 
 * @author Tony Piazza
 */
public class Industry implements Comparable<Industry> {
	private Integer id;
	private Sector sector;
	private String name;

	public Integer getId() {
		return id;
	}

	public Industry(Integer id, String name, Sector sector) {
		if(id == null) {
			throw new IllegalArgumentException("id is null");
		}
		if(name == null || name.length() == 0) {
			throw new IllegalArgumentException("name is null or zero length");
		}
		if(sector == null) {
			throw new IllegalArgumentException("sector is null");
		}
		this.id = id;
		this.name = name;
		this.sector = sector;
	}

	public Sector getSector() {
		return sector;
	}

	public String getName() {
		return name;
	}

	@Override
	public int compareTo(Industry other) {
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