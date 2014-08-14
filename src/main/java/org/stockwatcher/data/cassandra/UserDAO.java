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

import java.util.SortedSet;
import java.util.UUID;

import org.stockwatcher.data.DAOException;
import org.stockwatcher.domain.User;

/**
 * Cassandra-specific DAO interface that provides methods for reading 
 * and updating users.
 * 
 * @author Tony Piazza
 */
public interface UserDAO extends org.stockwatcher.data.UserDAO {
	SortedSet<User> getUsers(StatementOptions options) throws DAOException;
	User getUser(StatementOptions options, UUID id) throws DAOException;
	User updateUser(StatementOptions options, User user) throws DAOException;
}