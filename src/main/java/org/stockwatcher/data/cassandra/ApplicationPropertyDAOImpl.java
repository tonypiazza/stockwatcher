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

import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

import javax.annotation.PostConstruct;

import org.springframework.stereotype.Repository;

import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.Row;

/**
 * Implementation of the ApplicationPropertyDAO interface for Apache Cassandra.
 * 
 * @author Tony Piazza
 */
@Repository
public class ApplicationPropertyDAOImpl extends CassandraDAO implements ApplicationPropertyDAO {
	public String[] DATE_FORMATS = {"yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm:ssZ"};

	private PreparedStatement selectBooleanProperty;
	private PreparedStatement selectIntProperty;
	private PreparedStatement selectBigIntProperty;
	private PreparedStatement selectFloatProperty;
	private PreparedStatement selectDoubleProperty;
	private PreparedStatement selectDecimalProperty;
	private PreparedStatement selectUUIDProperty;
	private PreparedStatement selectTextProperty;
	private PreparedStatement selectTimestampProperty;

	@PostConstruct
	public void init() {
		selectBooleanProperty = prepare("SELECT property_value_boolean FROM ApplicationProperty WHERE property_name=?");
		selectIntProperty = prepare("SELECT property_value_int FROM ApplicationProperty WHERE property_name=?");
		selectBigIntProperty = prepare("SELECT property_value_bigint FROM ApplicationProperty WHERE property_name=?");
		selectFloatProperty = prepare("SELECT property_value_float FROM ApplicationProperty WHERE property_name=?");
		selectDoubleProperty = prepare("SELECT property_value_double FROM ApplicationProperty WHERE property_name=?");
		selectDecimalProperty = prepare("SELECT property_value_decimal FROM ApplicationProperty WHERE property_name=?");
		selectUUIDProperty = prepare("SELECT property_value_uuid FROM ApplicationProperty WHERE property_name=?");
		selectTextProperty = prepare("SELECT property_value_varchar FROM ApplicationProperty WHERE property_name=?");
		selectTimestampProperty = prepare("SELECT property_value_timestamp FROM ApplicationProperty WHERE property_name=?");
	}

	private Row getRow(StatementOptions options, PreparedStatement statement, 
		String propertyName) {
		return execute(statement.bind(propertyName), options).one();
	}

	@Override
	public boolean getBoolean(String propertyName) {
		return getBoolean(getDefaultOptions(), propertyName);
	}

	@Override
	public boolean getBoolean(StatementOptions options, String propertyName) {
		return getRow(options, selectBooleanProperty, propertyName).getBool(0);
	}

	@Override
	public int getInt(String propertyName) {
		return getInt(getDefaultOptions(), propertyName);
	}

	@Override
	public int getInt(StatementOptions options, String propertyName) {
		return getRow(options, selectIntProperty, propertyName).getInt(0);
	}

	@Override
	public long getLong(String propertyName) {
		return getLong(getDefaultOptions(), propertyName);
	}

	@Override
	public long getLong(StatementOptions options, String propertyName) {
		return getRow(options, selectBigIntProperty, propertyName).getLong(0);
	}

	@Override
	public Date getDate(String propertyName) {
		return getDate(getDefaultOptions(), propertyName);
	}

	@Override
	public Date getDate(StatementOptions options, String propertyName) {
		return getRow(options, selectTimestampProperty, propertyName).getDate(0);
	}

	@Override
	public float getFloat(String propertyName) {
		return getFloat(getDefaultOptions(), propertyName);
	}

	@Override
	public float getFloat(StatementOptions options, String propertyName) {
		return getRow(options, selectFloatProperty, propertyName).getFloat(0);
	}

	@Override
	public double getDouble(String propertyName) {
		return getDouble(getDefaultOptions(), propertyName);
	}

	@Override
	public double getDouble(StatementOptions options, String propertyName) {
		return getRow(options, selectDoubleProperty, propertyName).getDouble(0);
	}

	@Override
	public BigDecimal getDecimal(String propertyName) {
		return getDecimal(getDefaultOptions(), propertyName);
	}

	@Override
	public BigDecimal getDecimal(StatementOptions options, String propertyName) {
		return getRow(options, selectDecimalProperty, propertyName).getDecimal(0);
	}

	@Override
	public UUID getUUID(String propertyName) {
		return getUUID(getDefaultOptions(), propertyName);
	}

	@Override
	public UUID getUUID(StatementOptions options, String propertyName) {
		return getRow(options, selectUUIDProperty, propertyName).getUUID(0);
	}

	@Override
	public String getString(String propertyName) {
		return getString(getDefaultOptions(), propertyName);
	}

	@Override
	public String getString(StatementOptions options, String propertyName) {
		return getRow(options, selectTextProperty, propertyName).getString(0);
	}
}