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

import static com.datastax.driver.core.querybuilder.QueryBuilder.eq;
import static com.datastax.driver.core.querybuilder.QueryBuilder.set;
import static com.datastax.driver.core.querybuilder.QueryBuilder.update;
import static org.stockwatcher.data.cassandra.UserHelper.createUser;

import java.util.Date;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.UUID;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.stockwatcher.data.DAOException;
import org.stockwatcher.domain.User;

import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Statement;
import com.datastax.driver.core.exceptions.DriverException;

/**
 * Implementation of the UserDAO interface for Apache Cassandra.
 * 
 * @author Tony Piazza
 */
@Repository
public class UserDAOImpl extends CassandraDAO implements UserDAO {
	@Autowired
	private WatchListDAO watchListDAO;

	private PreparedStatement selectUserById;
	private PreparedStatement selectUsers;

	@PostConstruct
	public void init() {
		selectUserById = prepare("SELECT user_id, first_name, last_name, display_name, postal_code, email_address, active, updated FROM User WHERE user_id=?");
		selectUsers = prepare("SELECT user_id, first_name, last_name, display_name, postal_code, email_address, active, updated FROM User");
	}

	@Override
	public SortedSet<User> getUsers() {
		return getUsers(getDefaultOptions());
	}

	@Override
	public SortedSet<User> getUsers(StatementOptions options) {
		SortedSet<User> users = new TreeSet<User>();
		try {
			BoundStatement bs = selectUsers.bind();
			for(Row row : execute(bs, options)) {
				UUID userId = row.getUUID("user_id");
				users.add(createUser(row,  
						watchListDAO.getWatchListCountByUserId(options, userId)));
			}
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		return users;
	}

	@Override
	public User getUser(UUID id) {
		return getUser(getDefaultOptions(), id);
	}

	@Override
	public User getUser(StatementOptions options, UUID id) {
		if(id == null) {
			throw new IllegalArgumentException("id is null");
		}
		try {
			BoundStatement bs = selectUserById.bind();
			bs.setUUID("user_id", id);
			Row row = execute(bs, options).one();
			if(row == null) {
				throw new DAOException("no user found with specified id");
			}
			return createUser(row, 
				watchListDAO.getWatchListCountByUserId(options, id));
		} catch(DriverException e) {
			throw new DAOException(e);
		}
	}

	@Override
	public User updateUser(User user) {
		return updateUser(getDefaultOptions(), user);
	}

	@Override
	public User updateUser(StatementOptions options, User user) {
		if(user == null) {
			throw new IllegalArgumentException("user is null");
		}
		final UUID id = user.getId();
		if(id == null) {
			throw new IllegalStateException("id property is null");
		}

		// We assume that if the user_id is present, that it is valid

		Date now = new Date();
		try {
			Statement statement = update("User")
				.with(set("first_name", user.getFirstName()))
				.and(set("last_name", user.getLastName()))
				.and(set("display_name", user.getDisplayName()))
				.and(set("email_address", user.getEmailAddress()))
				.and(set("postal_code", user.getPostalCode()))
				.and(set("updated", now))
				.where(eq("user_id", id));
			execute(statement, options);
		} catch(DriverException e) {
			throw new DAOException(e);
		}
		user.setUpdated(now);
		return user;
	}
}