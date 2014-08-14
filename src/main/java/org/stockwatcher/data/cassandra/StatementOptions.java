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

import com.datastax.driver.core.ConsistencyLevel;
import com.datastax.driver.core.policies.DefaultRetryPolicy;
import com.datastax.driver.core.policies.RetryPolicy;

/**
 * Class that encapsulates the options that can be specified when executing
 * a statement with the DataStax Java Driver.
 *  
 * @author Tony Piazza
 */
public class StatementOptions {
	private boolean tracing;
	private ConsistencyLevel consistencyLevel = ConsistencyLevel.ONE;
	private RetryPolicy retryPolicy = DefaultRetryPolicy.INSTANCE;

	public StatementOptions() {
		// nothing here
	}

	public StatementOptions(boolean tracing) {
		this.tracing = tracing;
	}

	public StatementOptions(ConsistencyLevel consistencyLevel) {
		setConsistencyLevel(consistencyLevel);
	}

	public StatementOptions(RetryPolicy retryPolicy) {
		setRetryPolicy(retryPolicy);
	}

	public StatementOptions(ConsistencyLevel consistencyLevel, 
		RetryPolicy retryPolicy) {
		setConsistencyLevel(consistencyLevel);
		setRetryPolicy(retryPolicy);
	}

	public void enableTracing() {
		tracing = true;
	}

	public void disableTracing() {
		tracing = false;
	}

	public boolean isTracing() {
		return tracing;
	}

	public ConsistencyLevel getConsistencyLevel() {
		return consistencyLevel;
	}

	public void setConsistencyLevel(ConsistencyLevel consistencyLevel) {
		if(consistencyLevel == null) {
			throw new IllegalArgumentException("consistencyLevel is null");
		}
		this.consistencyLevel = consistencyLevel;
	}

	public RetryPolicy getRetryPolicy() {
		return retryPolicy;
	}

	public void setRetryPolicy(RetryPolicy retryPolicy) {
		if(retryPolicy == null) {
			throw new IllegalArgumentException("retryPolicy is null");
		}
		this.retryPolicy = retryPolicy;
	}
}