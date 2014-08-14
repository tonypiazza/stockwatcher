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

import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

/**
 * DAO interface that provides methods for reading application properties.
 * 
 * @author Tony Piazza
 */
public interface ApplicationPropertyDAO {
	boolean getBoolean(String propertyName) throws DAOException;
	int getInt(String propertyName) throws DAOException;
	long getLong(String propertyName) throws DAOException;
	Date getDate(String propertyName) throws DAOException;
	float getFloat(String propertyName) throws DAOException;
	double getDouble(String propertyName) throws DAOException;
	BigDecimal getDecimal(String propertyName) throws DAOException;
	UUID getUUID(String propertyName) throws DAOException;
	String getString(String propertyName) throws DAOException;
}