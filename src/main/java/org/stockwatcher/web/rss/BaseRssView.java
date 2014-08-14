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
package org.stockwatcher.web.rss;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Required;
import org.springframework.web.servlet.view.feed.AbstractRssFeedView;

/**
 * Base view class that provides common functionality used by all RSS view 
 * classes. 
 * 
 * @author Tony Piazza
 */
public abstract class BaseRssView extends AbstractRssFeedView {
	protected String feedGenerator;
	protected String feedLink;
	protected String itemAuthor;

	public BaseRssView() {
		super();
	}

	@Required
	public void setFeedGenerator(String feedGenerator) {
		this.feedGenerator = feedGenerator;
	}

	@Required
	public void setFeedLink(String feedLink) {
	    this.feedLink = feedLink;
	}

	@Required
	public void setItemAuthor(String itemAuthor) {
		this.itemAuthor = itemAuthor;
	}

	protected String getStockLink(HttpServletRequest request, String symbol) {
		StringBuilder link = new StringBuilder(request.getScheme());
		link.append("://");
		link.append(request.getServerName());
		link.append(":");
		link.append(request.getServerPort());
		link.append(request.getContextPath());
		link.append("/main/stocks/");
		link.append(symbol);
		return link.toString();
	}
}