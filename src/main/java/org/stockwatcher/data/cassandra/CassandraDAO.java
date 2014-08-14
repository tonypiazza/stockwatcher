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

import org.springframework.beans.factory.annotation.Autowired;

import com.datastax.driver.core.ConsistencyLevel;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.ResultSetFuture;
import com.datastax.driver.core.Session;
import com.datastax.driver.core.Statement;
import com.datastax.driver.core.policies.RetryPolicy;

/**
 * Base class that provides common functionality for DAO classes that 
 * access an Apache Cassandra cluster.
 * 
 * @author Tony Piazza
 */
public abstract class CassandraDAO {
	@Autowired
	private SessionFactory sessionFactory;
	private Session session;
	private StatementOptions options = new StatementOptions();

	protected Session getSession() {
		if(session == null) {
			session = sessionFactory.getSession();
		}
		return session;
	}

	protected ResultSet execute(Statement statement, StatementOptions options) {
		return getSession().execute(setOptions(statement, options));
	}

	protected ResultSetFuture executeAsync(Statement statement, StatementOptions options) {
		return getSession().executeAsync(setOptions(statement, options));
	}

	protected PreparedStatement prepare(String statement) {
		return getSession().prepare(statement);
	}

	private Statement setOptions(Statement statement, StatementOptions options) {
		if(options != null) {
			ConsistencyLevel consistencyLevel = options.getConsistencyLevel();
			if(consistencyLevel != null) {
				statement.setConsistencyLevel(consistencyLevel);
			}
			if(options.isTracing()) {
				statement.enableTracing();
			} else {
				statement.disableTracing();
			}
			RetryPolicy retryPolicy = options.getRetryPolicy();
			if(retryPolicy != null) {
				statement.setRetryPolicy(retryPolicy);
			}
		}
		return statement;
	}

	public StatementOptions getDefaultOptions() {
		return options;
	}

	public void setDefaultOptions(StatementOptions options) {
		this.options = options;
	}
}