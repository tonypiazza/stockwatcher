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
 * A domain class that represents a comment made by a user on a stock. 
 * 
 * @author Tony Piazza
 */
public class Comment implements Comparable<Comment> {
	private UUID id;
	private UUID userId;
	private Date created;
	private boolean active = true;
	private String text;
	private String userDisplayName;

	public UUID getId() {
		return id;
	}

	public void setId(UUID id) {
		if(this.id != null) {
			throw new IllegalStateException("id has already been initialized");
		}
		this.id = id;
	}

	public UUID getUserId() {
		return userId;
	}

	public void setUserId(UUID userId) {
		if(this.userId != null) {
			throw new IllegalStateException("userId has already been initialized");
		}
		this.userId = userId;
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

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public String getUserDisplayName() {
		return userDisplayName;
	}

	public void setUserDisplayName(String userDisplayName) {
		this.userDisplayName = userDisplayName;
	}

	@Override
	public int compareTo(Comment other) {
		return created.compareTo(other.created);
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