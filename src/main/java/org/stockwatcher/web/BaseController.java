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
package org.stockwatcher.web;

import java.util.UUID;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.stockwatcher.data.UserDAO;
import org.stockwatcher.domain.User;

/**
 * Base controller class that provides common functionality for all controller
 * classes.
 * 
 * @author Tony Piazza
 */
public abstract class BaseController {
	private static final Logger LOGGER = LoggerFactory.getLogger(BaseController.class);
	@Autowired
	private UserDAO userDAO;

	protected User getUser(String userId) {
		User user = null;
		if(userId == null) {
			throw new IllegalArgumentException("userId is null or zero length");
		}
		try {
			UUID id = UUID.fromString(userId); 
			user = userDAO.getUser(id);
		} catch(Exception e) {
			LOGGER.debug("Invalid userId ({}) specified", userId);
		}
		return user;
	}

	protected String getRequestParameter(HttpServletRequest request, String name) {
		String parameter = request.getParameter(name);
		if(parameter == null || parameter.length() == 0) {
			throw new IllegalArgumentException(parameter + 
				" parameter is null or zero length");
		}
		return parameter;
	}
}