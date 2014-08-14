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

import java.util.Date;
import java.util.UUID;

import org.apache.commons.lang.builder.ToStringStyle;

/**
 * A domain class that represents a user of the StockWatcher application. 
 * Users are identified by their email address.
 * 
 * @author Tony Piazza
 */
public class User implements Comparable<User> {
	private UUID id;
	private String firstName;
	private String lastName;
	private String displayName;
	private String emailAddress;
	private String postalCode;
	private Date created;
	private Date updated;
	private boolean active;
	private transient int watchListCount;

	public UUID getId() {
		return id;
	}

	public void setId(UUID id) {
		if(this.id != null) {
			throw new IllegalStateException("id has already been initialized");
		}
		this.id = id;
	}

	public int getWatchListCount() {
		return watchListCount;
	}

	public void setWatchListCount(int watchListCount) {
		this.watchListCount = watchListCount;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public String getDisplayName() {
		return displayName;
	}

	public void setDisplayName(String displayName) {
		this.displayName = displayName;
	}

	public String getEmailAddress() {
		return emailAddress;
	}

	public void setEmailAddress(String emailAddress) {
		this.emailAddress = emailAddress;
	}

	public String getPostalCode() {
		return postalCode;
	}

	public void setPostalCode(String postalCode) {
		this.postalCode = postalCode;
	}

	public Date getCreated() {
		return created;
	}

	public void setCreated(Date created) {
		if(this.created != null) {
			throw new IllegalStateException("created has already been initialized");
		}
		this.created = created;
	}

	public Date getUpdated() {
		return updated;
	}

	public void setUpdated(Date updated) {
		this.updated = updated;
	}

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}

	@Override
	public int compareTo(User other) {
		return lastName.compareTo(other.lastName);
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