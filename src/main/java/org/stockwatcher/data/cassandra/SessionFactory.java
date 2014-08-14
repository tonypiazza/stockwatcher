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

import static java.util.concurrent.TimeUnit.SECONDS;

import java.util.Set;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.stereotype.Component;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Cluster.Builder;
import com.datastax.driver.core.Host;
import com.datastax.driver.core.Session;

/**
 * Factory class that creates instances of the Session class. class requires an
 * existing keyspace and at least one node to access the cluster. 
 *  
 * @author Tony Piazza
 */
@Component
public class SessionFactory {
	private static final Logger LOGGER = LoggerFactory.getLogger(SessionFactory.class);
	private static final long SHUTDOWN_TIMEOUT = 10;

	private String[] nodes;
	private String keyspace;
	private Cluster cluster;
	private Session session;

	@Required
	public void setNodes(String[] nodes) {
		this.nodes = nodes;
	}

	@Required
	public void setKeyspace(String keyspace) {
		this.keyspace = keyspace;
	}

	@PostConstruct
	public void startup() {
		if(cluster == null) {
			if(nodes == null || nodes.length == 0) {
				throw new IllegalStateException("no nodes specified");
			}
			Builder builder = Cluster.builder();
			builder.addContactPoints(nodes);
			cluster = builder.build();
			session = cluster.connect(keyspace);
			for(Host host : getAllHosts()) {
				LOGGER.info("Cluster node: {}", host);
			}
		}
	}

	@PreDestroy
	public void shutdown() {
		if(cluster != null) {
			try {
				// Close asynchronously, then get with our timeout value
				// get will throw exception if timeout exceeded, or close fails 
				cluster.closeAsync().get(SHUTDOWN_TIMEOUT, SECONDS);
			} catch (Exception e) {
				LOGGER.error("Unable to shutdown cluster", e);
			}
		}
	}

	public String getKeyspace() {
		return keyspace;
	}

	public Set<Host> getAllHosts() {
		return cluster.getMetadata().getAllHosts();
	}

	public Session getSession() {
		return session;
	}
}