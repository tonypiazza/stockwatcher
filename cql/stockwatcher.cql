DROP KEYSPACE IF EXISTS StockWatcher;

CREATE KEYSPACE StockWatcher WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': '2'
};

USE StockWatcher;

CREATE TABLE stockwatcher.ApplicationProperty (
  property_name VARCHAR,
  property_value_int INT,
  property_value_bigint BIGINT,
  property_value_boolean BOOLEAN,
  property_value_timestamp TIMESTAMP,
  property_value_float FLOAT,
  property_value_double DOUBLE,
  property_value_decimal DECIMAL,
  property_value_uuid UUID,
  property_value_varchar VARCHAR,
  updated TIMESTAMP,
  PRIMARY KEY (property_name)
);

CREATE TABLE stockwatcher.DailySummary (
  stock_symbol VARCHAR,
  trade_date TIMESTAMP,
  price_open DECIMAL,
  price_close DECIMAL,
  price_high DECIMAL,
  price_low DECIMAL,
  share_volume INT,
  PRIMARY KEY (stock_symbol, trade_date)
) WITH CLUSTERING ORDER BY (trade_date DESC);

CREATE TABLE stockwatcher.Exchange (
  exchange_id VARCHAR,
  exchange_name VARCHAR,
  currency_code VARCHAR,
  active BOOLEAN,
  PRIMARY KEY (exchange_id)
);

CREATE TABLE stockwatcher.Industry (
  industry_id INT,
  industry_name VARCHAR,
  sector_id INT,
  sector_name VARCHAR,
  PRIMARY KEY (industry_id)
);

CREATE TABLE stockwatcher.Sector (
  sector_id INT,
  sector_name VARCHAR,
  PRIMARY KEY (sector_id)
);

CREATE TABLE stockwatcher.Stock (
  stock_symbol VARCHAR,
  active BOOLEAN,
  company_name VARCHAR,
  exchange_id VARCHAR,
  industry_id INT,
  industry_name VARCHAR,
  sector_id INT,
  sector_name VARCHAR,
  current_price DECIMAL,
  price_updated TIMESTAMP,
  PRIMARY KEY (stock_symbol)
) WITH COMPACTION={'class': 'LeveledCompactionStrategy'};

CREATE TABLE stockwatcher.StockCommentBySymbol (
  stock_symbol VARCHAR,
  comment_id TIMEUUID,
  company_name VARCHAR,
  user_id TIMEUUID,
  user_display_name VARCHAR,
  comment VARCHAR,
  active BOOLEAN,
  PRIMARY KEY (stock_symbol, comment_id)
) WITH CLUSTERING ORDER BY (comment_id DESC);

CREATE TABLE stockwatcher.StockCommentByUser (
  stock_symbol VARCHAR,
  comment_id TIMEUUID,
  user_id TIMEUUID,
  user_display_name VARCHAR STATIC,
  comment VARCHAR,
  active BOOLEAN,
  PRIMARY KEY (user_id, comment_id)
) WITH CLUSTERING ORDER BY (comment_id DESC);

CREATE TABLE stockwatcher.StockCount (
  stock_symbol VARCHAR,
  watch_count COUNTER,
  view_count COUNTER,
  PRIMARY KEY (stock_symbol)
);

CREATE TABLE stockwatcher.StockSearch (
  industry_id INT,
  exchange_id VARCHAR,
  stock_symbol VARCHAR,
  PRIMARY KEY (industry_id, exchange_id, stock_symbol)
);

CREATE TABLE stockwatcher.Trade (
  stock_symbol VARCHAR,
  trade_id TIMEUUID,
  trade_date TIMESTAMP,
  trade_timestamp TIMESTAMP,
  exchange_id VARCHAR,
  share_price DECIMAL,
  share_quantity INT,
  PRIMARY KEY ((stock_symbol, trade_date), trade_timestamp, trade_id)
);

CREATE TABLE stockwatcher.User (
  user_id TIMEUUID,
  first_name VARCHAR,
  last_name VARCHAR,
  display_name VARCHAR,
  email_address VARCHAR,
  postal_code VARCHAR,
  active BOOLEAN,
  updated TIMESTAMP,
  PRIMARY KEY (user_id)
);

CREATE TABLE stockwatcher.WatchList (
  watchlist_id TIMEUUID,
  user_id TIMEUUID,
  display_name VARCHAR,
  visibility VARCHAR,
  active BOOLEAN,
  updated TIMESTAMP,
  PRIMARY KEY (watchlist_id)
);

CREATE TABLE stockwatcher.WatchListItem (
  watchlist_id TIMEUUID,
  stock_symbol VARCHAR,
  start_price DECIMAL,
  created TIMESTAMP,
  PRIMARY KEY (watchlist_id, stock_symbol)
);

CREATE INDEX ON stockwatcher.Exchange (active);
CREATE INDEX ON stockwatcher.Industry (sector_id);
CREATE INDEX ON stockwatcher.Stock (active);
CREATE INDEX ON stockwatcher.Stock (exchange_id);
CREATE INDEX ON stockwatcher.WatchList (user_id);

INSERT INTO stockwatcher.ApplicationProperty (property_name, property_value_timestamp, updated) VALUES ('last_trade_date', '2013-08-15', dateOf(now()));
INSERT INTO stockwatcher.ApplicationProperty (property_name, property_value_boolean, updated) VALUES ('trading_is_live', false, dateOf(now()));

INSERT INTO stockwatcher.Exchange (exchange_id, exchange_name, active, currency_code) VALUES ('AMEX','American Stock Exchange', true, 'USD');
INSERT INTO stockwatcher.Exchange (exchange_id, exchange_name, active, currency_code) VALUES ('NASDAQ','NASDAQ Stock Exchange', true, 'USD');
INSERT INTO stockwatcher.Exchange (exchange_id, exchange_name, active, currency_code) VALUES ('NYSE','New York Stock Exchange', true, 'USD');

INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (1,'Basic Materials');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (2,'Conglomerates');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (3,'Consumer Goods');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (4,'Financial');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (5,'Healthcare');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (6,'Industrial Goods');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (7,'Services');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (8,'Technology');
INSERT INTO stockwatcher.Sector (sector_id, sector_name) VALUES (9,'Utilities');

INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EPAM', now(), dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger Woods', true, 'This stock rocks!');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('GEVA', now(), dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger Woods', true, 'This stock stinks!');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EFT', now(), dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger Woods', true, 'This stock is overpriced.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('THM', now(), dfdf8001-d6b4-11e2-992a-238715b9803d, 'The Ex-Governator', true, 'This stock has huge potential.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('BHD', now(), dfdf8001-d6b4-11e2-992a-238715b9803d, 'The Ex-Governator', true, 'This stock is undervalued.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CVR', now(), dfdf8001-d6b4-11e2-992a-238715b9803d, 'The Ex-Governator', true, 'This stock is going nowhere.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('BGS', now(), dfdf8002-d6b4-11e2-992a-238715b9803d, 'Sister of Venus', true, 'This stock is poised to explode!');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('TKR', now(), dfdf8002-d6b4-11e2-992a-238715b9803d, 'Sister of Venus', true, 'I wouldn not own this stock if they paid me.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('LSTR', now(), dfdf8002-d6b4-11e2-992a-238715b9803d, 'Sister of Venus', true, 'This stock is a dog.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CBEY', now(), dfdf8003-d6b4-11e2-992a-238715b9803d, 'Doctor Liberty', true, 'This stock will eventually make money.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('NSSC', now(), dfdf8003-d6b4-11e2-992a-238715b9803d, 'Doctor Liberty', true, 'I would avoid this one.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CJJD', now(), dfdf8003-d6b4-11e2-992a-238715b9803d, 'Doctor Liberty', true, 'Hard to tell how this stock will do.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HHC', now(), dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard of Wall Street', true, 'Avoid this stock at all costs!');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EXC', now(), dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard of Wall Street', true, 'Could be a big winner.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HCOM', now(), dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard of Wall Street', true, 'Rumors are swirling about a merger with their main competitor.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HOLL', now(), dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend with Benefits', true, 'I would suggest a buy and hold on this one.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('INFI', now(), dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend with Benefits', true, 'Stay away from this dog.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('ATRI', now(), dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend with Benefits', true, 'Not worth your money.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('DGLY', now(), dfdf8006-d6b4-11e2-992a-238715b9803d, 'Child of Destiny', true, 'Huge risk on this stock but also huge potential if they survive.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HYF', now(), dfdf8006-d6b4-11e2-992a-238715b9803d, 'Child of Destiny', true, 'I like this one but am not ready to buy it just yet.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HRS', now(), dfdf8006-d6b4-11e2-992a-238715b9803d, 'Child of Destiny', true, 'Not a chance I would own this stock.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('OGEN', now(), dfdf8007-d6b4-11e2-992a-238715b9803d, 'King James', true, 'I have this one on my radar.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('SNCR', now(), dfdf8007-d6b4-11e2-992a-238715b9803d, 'King James', true, 'Interesting value proposition but too early to know if they will survive.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CMRE', now(), dfdf8007-d6b4-11e2-992a-238715b9803d, 'King James', true, 'I like this one but would suggest waiting a few months.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('PZN', now(), dfdf8008-d6b4-11e2-992a-238715b9803d, 'Two-Time World Series Winner', true, 'Not obvious yet but this stock is gonna be a huge winner.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('FISI', now(), dfdf8008-d6b4-11e2-992a-238715b9803d, 'Two-Time World Series Winner', true, 'Buy it now before the rush.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('FLIC', now(), dfdf8008-d6b4-11e2-992a-238715b9803d, 'Two-Time World Series Winner', true, 'Dump this one fast!');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('GLUU', now(), dfdf8009-d6b4-11e2-992a-238715b9803d, 'Two-Time Super Bowl Winner', true, 'This one scares me a bit.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EDAP', now(), dfdf8009-d6b4-11e2-992a-238715b9803d, 'Two-Time Super Bowl Winner', true, 'I like their approach but think it is overpriced right now.');
INSERT INTO stockwatcher.StockCommentBySymbol (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('AAPL', now(), dfdf8009-d6b4-11e2-992a-238715b9803d, 'Two-Time Super Bowl Winner', true, 'Still a great company that will continue to win.');

INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EPAM', now(), dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger Woods', true, 'This stock rocks!');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('GEVA', now(), dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger Woods', true, 'This stock stinks!');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EFT', now(), dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger Woods', true, 'This stock is overpriced.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('THM', now(), dfdf8001-d6b4-11e2-992a-238715b9803d, 'The Ex-Governator', true, 'This stock has huge potential.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('BHD', now(), dfdf8001-d6b4-11e2-992a-238715b9803d, 'The Ex-Governator', true, 'This stock is undervalued.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CVR', now(), dfdf8001-d6b4-11e2-992a-238715b9803d, 'The Ex-Governator', true, 'This stock is going nowhere.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('BGS', now(), dfdf8002-d6b4-11e2-992a-238715b9803d, 'Sister of Venus', true, 'This stock is poised to explode!');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('TKR', now(), dfdf8002-d6b4-11e2-992a-238715b9803d, 'Sister of Venus', true, 'I would not own this stock if they paid me.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('LSTR', now(), dfdf8002-d6b4-11e2-992a-238715b9803d, 'Sister of Venus', true, 'This stock is a dog.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CBEY', now(), dfdf8003-d6b4-11e2-992a-238715b9803d, 'Doctor Liberty', true, 'This stock will eventually make money.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('NSSC', now(), dfdf8003-d6b4-11e2-992a-238715b9803d, 'Doctor Liberty', true, 'I would avoid this one.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CJJD', now(), dfdf8003-d6b4-11e2-992a-238715b9803d, 'Doctor Liberty', true, 'Hard to tell how this stock will do.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HHC', now(), dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard of Wall Street', true, 'Avoid this stock at all costs!');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EXC', now(), dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard of Wall Street', true, 'Could be a big winner.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HCOM', now(), dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard of Wall Street', true, 'Rumors are swirling about a merger with their main competitor.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HOLL', now(), dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend with Benefits', true, 'I would suggest a buy and hold on this one.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('INFI', now(), dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend with Benefits', true, 'Stay away from this dog.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('ATRI', now(), dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend with Benefits', true, 'Not worth your money.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('DGLY', now(), dfdf8006-d6b4-11e2-992a-238715b9803d, 'Child of Destiny', true, 'Huge risk on this stock but also huge potential if they survive.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HYF', now(), dfdf8006-d6b4-11e2-992a-238715b9803d, 'Child of Destiny', true, 'I like this one but am not ready to buy it just yet.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('HRS', now(), dfdf8006-d6b4-11e2-992a-238715b9803d, 'Child of Destiny', true, 'Not a chance I would own this stock.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('OGEN', now(), dfdf8007-d6b4-11e2-992a-238715b9803d, 'King James', true, 'I have this one on my radar.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('SNCR', now(), dfdf8007-d6b4-11e2-992a-238715b9803d, 'King James', true, 'Interesting value proposition but too early to know if they will survive.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('CMRE', now(), dfdf8007-d6b4-11e2-992a-238715b9803d, 'King James', true, 'I like this one but would suggest waiting a few months.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('PZN', now(), dfdf8008-d6b4-11e2-992a-238715b9803d, 'Two-Time World Series Winner', true, 'Not obvious yet but this stock is gonna be a huge winner.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('FISI', now(), dfdf8008-d6b4-11e2-992a-238715b9803d, 'Two-Time World Series Winner', true, 'Buy it now before the rush.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('FLIC', now(), dfdf8008-d6b4-11e2-992a-238715b9803d, 'Two-Time World Series Winner', true, 'Dump this one fast!');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('GLUU', now(), dfdf8009-d6b4-11e2-992a-238715b9803d, 'Two-Time Super Bowl Winner', true, 'This one scares me a bit.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('EDAP', now(), dfdf8009-d6b4-11e2-992a-238715b9803d, 'Two-Time Super Bowl Winner', true, 'I like their approach but think it is overpriced right now.');
INSERT INTO stockwatcher.StockCommentByUser (stock_symbol, comment_id, user_id, user_display_name, active, comment) VALUES ('AAPL', now(), dfdf8009-d6b4-11e2-992a-238715b9803d, 'Two-Time Super Bowl Winner', true, 'Still a great company that will continue to win.');

INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8000-d6b4-11e2-992a-238715b9803d, 'Eldrick', 'Woods', 'Tiger Woods', 'user01@stockwatcher.org', '33455', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8001-d6b4-11e2-992a-238715b9803d, 'Arnold', 'Schwarzenegger', 'The Ex-Governator', 'user02@stockwatcher.org', '90049', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8002-d6b4-11e2-992a-238715b9803d, 'Serena', 'Williams', 'Sister of Venus', 'user03@stockwatcher.org', '33403', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8003-d6b4-11e2-992a-238715b9803d, 'Ron', 'Paul', 'Doctor Liberty', 'user04@stockwatcher.org', '77566', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8004-d6b4-11e2-992a-238715b9803d, 'Warren', 'Buffett', 'Wizard of Wall Street', 'user05@stockwatcher.org', '68132', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8005-d6b4-11e2-992a-238715b9803d, 'Justin', 'Timberlake', 'Friend with Benefits', 'user06@stockwatcher.org', '90210', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8006-d6b4-11e2-992a-238715b9803d, 'Beyonce', 'Knowles', 'Child of Destiny', 'user07@stockwatcher.org', '10001', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8007-d6b4-11e2-992a-238715b9803d, 'Lebron', 'James', 'King James', 'user08@stockwatcher.org', '33141', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8008-d6b4-11e2-992a-238715b9803d, 'Buster', 'Posey', 'Two-Time World Series Winner', 'user09@stockwatcher.org', '94107', true, dateOf(now()));
INSERT INTO stockwatcher.User (user_id, first_name, last_name, display_name, email_address, postal_code, active, updated) VALUES (dfdf8009-d6b4-11e2-992a-238715b9803d, 'Eli', 'Manning', 'Two-Time Super Bowl Winner', 'user10@stockwatcher.org', '07073', true, dateOf(now()));

INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee20-d8a7-11e2-a440-85054b6a0b99, dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee21-d8a7-11e2-a440-85054b6a0b99, dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee22-d8a7-11e2-a440-85054b6a0b99, dfdf8000-d6b4-11e2-992a-238715b9803d, 'Tiger list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee23-d8a7-11e2-a440-85054b6a0b99, dfdf8001-d6b4-11e2-992a-238715b9803d, 'Ex-Governator list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee24-d8a7-11e2-a440-85054b6a0b99, dfdf8001-d6b4-11e2-992a-238715b9803d, 'Ex-Governator list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee25-d8a7-11e2-a440-85054b6a0b99, dfdf8001-d6b4-11e2-992a-238715b9803d, 'Ex-Governator list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee26-d8a7-11e2-a440-85054b6a0b99, dfdf8002-d6b4-11e2-992a-238715b9803d, 'Serena list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee27-d8a7-11e2-a440-85054b6a0b99, dfdf8002-d6b4-11e2-992a-238715b9803d, 'Serena list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee28-d8a7-11e2-a440-85054b6a0b99, dfdf8002-d6b4-11e2-992a-238715b9803d, 'Serena list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee29-d8a7-11e2-a440-85054b6a0b99, dfdf8003-d6b4-11e2-992a-238715b9803d, 'Liberty list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee2a-d8a7-11e2-a440-85054b6a0b99, dfdf8003-d6b4-11e2-992a-238715b9803d, 'Liberty list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee2b-d8a7-11e2-a440-85054b6a0b99, dfdf8003-d6b4-11e2-992a-238715b9803d, 'Liberty list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee2c-d8a7-11e2-a440-85054b6a0b99, dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee2d-d8a7-11e2-a440-85054b6a0b99, dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee2e-d8a7-11e2-a440-85054b6a0b99, dfdf8004-d6b4-11e2-992a-238715b9803d, 'Wizard list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee2f-d8a7-11e2-a440-85054b6a0b99, dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee30-d8a7-11e2-a440-85054b6a0b99, dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee31-d8a7-11e2-a440-85054b6a0b99, dfdf8005-d6b4-11e2-992a-238715b9803d, 'Friend list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee32-d8a7-11e2-a440-85054b6a0b99, dfdf8006-d6b4-11e2-992a-238715b9803d, 'Destiny list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee33-d8a7-11e2-a440-85054b6a0b99, dfdf8006-d6b4-11e2-992a-238715b9803d, 'Destiny list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee34-d8a7-11e2-a440-85054b6a0b99, dfdf8006-d6b4-11e2-992a-238715b9803d, 'Destiny list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee35-d8a7-11e2-a440-85054b6a0b99, dfdf8007-d6b4-11e2-992a-238715b9803d, 'LBJ list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee36-d8a7-11e2-a440-85054b6a0b99, dfdf8007-d6b4-11e2-992a-238715b9803d, 'LBJ list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee37-d8a7-11e2-a440-85054b6a0b99, dfdf8007-d6b4-11e2-992a-238715b9803d, 'LBJ list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee38-d8a7-11e2-a440-85054b6a0b99, dfdf8008-d6b4-11e2-992a-238715b9803d, 'Catcher list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee39-d8a7-11e2-a440-85054b6a0b99, dfdf8008-d6b4-11e2-992a-238715b9803d, 'Catcher list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee3a-d8a7-11e2-a440-85054b6a0b99, dfdf8008-d6b4-11e2-992a-238715b9803d, 'Catcher list 3', 'PUBLIC', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee3b-d8a7-11e2-a440-85054b6a0b99, dfdf8009-d6b4-11e2-992a-238715b9803d, 'QB list 1', 'PRIVATE', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee3c-d8a7-11e2-a440-85054b6a0b99, dfdf8009-d6b4-11e2-992a-238715b9803d, 'QB list 2', 'PROTECTED', true, '2013-08-15');
INSERT INTO stockwatcher.WatchList (watchlist_id, user_id, display_name, visibility, active, updated) VALUES (ca58ee3d-d8a7-11e2-a440-85054b6a0b99, dfdf8009-d6b4-11e2-992a-238715b9803d, 'QB list 3', 'PUBLIC', true, '2013-08-15');

INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee20-d8a7-11e2-a440-85054b6a0b99,'GLUU',2.80,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee20-d8a7-11e2-a440-85054b6a0b99,'NCI',13.28,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee20-d8a7-11e2-a440-85054b6a0b99,'PENN',56.48,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee21-d8a7-11e2-a440-85054b6a0b99,'EDAP',3.90,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee21-d8a7-11e2-a440-85054b6a0b99,'NCBC',6.37,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee21-d8a7-11e2-a440-85054b6a0b99,'BDSI',4.50,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee22-d8a7-11e2-a440-85054b6a0b99,'NETE',4.94,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee22-d8a7-11e2-a440-85054b6a0b99,'AKS',3.51,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee22-d8a7-11e2-a440-85054b6a0b99,'AAPL',497.91,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee23-d8a7-11e2-a440-85054b6a0b99,'EPAM',23.32,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee23-d8a7-11e2-a440-85054b6a0b99,'AMCX',67.03,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee23-d8a7-11e2-a440-85054b6a0b99,'VCBI',13.65,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee24-d8a7-11e2-a440-85054b6a0b99,'EFT',16.94,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee24-d8a7-11e2-a440-85054b6a0b99,'HAST',3.00,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee24-d8a7-11e2-a440-85054b6a0b99,'BKI',37.29,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee25-d8a7-11e2-a440-85054b6a0b99,'GEVA',40.96,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee25-d8a7-11e2-a440-85054b6a0b99,'MEMP',19.52,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee25-d8a7-11e2-a440-85054b6a0b99,'MJN',84.87,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee26-d8a7-11e2-a440-85054b6a0b99,'THM',0.84,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee26-d8a7-11e2-a440-85054b6a0b99,'CBOE',40.72,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee26-d8a7-11e2-a440-85054b6a0b99,'ESBF',12.55,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee27-d8a7-11e2-a440-85054b6a0b99,'BHD',14.05,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee27-d8a7-11e2-a440-85054b6a0b99,'RRD',12.98,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee27-d8a7-11e2-a440-85054b6a0b99,'IIVI',16.73,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee28-d8a7-11e2-a440-85054b6a0b99,'CVR',25.90,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee28-d8a7-11e2-a440-85054b6a0b99,'GUT',6.56,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee28-d8a7-11e2-a440-85054b6a0b99,'BOBE',46.51,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee29-d8a7-11e2-a440-85054b6a0b99,'BGS',29.46,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee29-d8a7-11e2-a440-85054b6a0b99,'CIFC',8.06,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee29-d8a7-11e2-a440-85054b6a0b99,'LABC',16.65,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2a-d8a7-11e2-a440-85054b6a0b99,'TKR',56.89,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2a-d8a7-11e2-a440-85054b6a0b99,'BIOS',13.89,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2a-d8a7-11e2-a440-85054b6a0b99,'FOE',7.08,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2b-d8a7-11e2-a440-85054b6a0b99,'LSTR',52.55,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2b-d8a7-11e2-a440-85054b6a0b99,'CPT',69.88,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2b-d8a7-11e2-a440-85054b6a0b99,'BDGE',21.19,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2c-d8a7-11e2-a440-85054b6a0b99,'CBEY',8.75,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2c-d8a7-11e2-a440-85054b6a0b99,'FOLD',3.47,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2c-d8a7-11e2-a440-85054b6a0b99,'NTLS',15.70,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2d-d8a7-11e2-a440-85054b6a0b99,'NSSC',4.38,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2d-d8a7-11e2-a440-85054b6a0b99,'SWX',47.38,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2d-d8a7-11e2-a440-85054b6a0b99,'HMN',24.58,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2e-d8a7-11e2-a440-85054b6a0b99,'CJJD',0.63,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2e-d8a7-11e2-a440-85054b6a0b99,'IDTI',8.19,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2e-d8a7-11e2-a440-85054b6a0b99,'TTMI',8.18,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2f-d8a7-11e2-a440-85054b6a0b99,'HHC',101.97,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2f-d8a7-11e2-a440-85054b6a0b99,'FFNW',9.98,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee2f-d8a7-11e2-a440-85054b6a0b99,'RXN',19.53,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee30-d8a7-11e2-a440-85054b6a0b99,'EXC',31.86,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee30-d8a7-11e2-a440-85054b6a0b99,'CRDC',1.29,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee30-d8a7-11e2-a440-85054b6a0b99,'LDL',14.70,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee31-d8a7-11e2-a440-85054b6a0b99,'HCOM',24.50,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee31-d8a7-11e2-a440-85054b6a0b99,'UIS',19.89,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee31-d8a7-11e2-a440-85054b6a0b99,'IBIO',0.44,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee32-d8a7-11e2-a440-85054b6a0b99,'HOLL',1.44,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee32-d8a7-11e2-a440-85054b6a0b99,'JEC',56.25,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee32-d8a7-11e2-a440-85054b6a0b99,'GPX',25.04,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee33-d8a7-11e2-a440-85054b6a0b99,'INFI',27.36,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee33-d8a7-11e2-a440-85054b6a0b99,'URZ',1.31,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee33-d8a7-11e2-a440-85054b6a0b99,'TWIN',25.27,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee34-d8a7-11e2-a440-85054b6a0b99,'ATRI',219.39,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee34-d8a7-11e2-a440-85054b6a0b99,'STEL',15.83,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee34-d8a7-11e2-a440-85054b6a0b99,'BANF',43.50,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee35-d8a7-11e2-a440-85054b6a0b99,'DGLY',6.04,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee35-d8a7-11e2-a440-85054b6a0b99,'IIN',3.92,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee35-d8a7-11e2-a440-85054b6a0b99,'AIMC',29.59,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee36-d8a7-11e2-a440-85054b6a0b99,'HYF',2.16,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee36-d8a7-11e2-a440-85054b6a0b99,'SIAL',84.37,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee36-d8a7-11e2-a440-85054b6a0b99,'MNI',2.55,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee37-d8a7-11e2-a440-85054b6a0b99,'HRS',51.06,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee37-d8a7-11e2-a440-85054b6a0b99,'LVB',27.89,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee37-d8a7-11e2-a440-85054b6a0b99,'MMYT',12.83,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee38-d8a7-11e2-a440-85054b6a0b99,'OGEN',3.00,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee38-d8a7-11e2-a440-85054b6a0b99,'ITC',86.83,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee38-d8a7-11e2-a440-85054b6a0b99,'XRAY',41.71,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee39-d8a7-11e2-a440-85054b6a0b99,'SNCR',31.47,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee39-d8a7-11e2-a440-85054b6a0b99,'PPC',12.33,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee39-d8a7-11e2-a440-85054b6a0b99,'ETRM',1.06,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3a-d8a7-11e2-a440-85054b6a0b99,'CMRE',16.88,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3a-d8a7-11e2-a440-85054b6a0b99,'NYT',10.75,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3a-d8a7-11e2-a440-85054b6a0b99,'BANC',13.52,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3b-d8a7-11e2-a440-85054b6a0b99,'PZN',6.75,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3b-d8a7-11e2-a440-85054b6a0b99,'UNTK',2.01,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3b-d8a7-11e2-a440-85054b6a0b99,'ADEP',3.66,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3c-d8a7-11e2-a440-85054b6a0b99,'FISI',19.69,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3c-d8a7-11e2-a440-85054b6a0b99,'EC',44.88,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3c-d8a7-11e2-a440-85054b6a0b99,'ICE',171.30,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3d-d8a7-11e2-a440-85054b6a0b99,'FLIC',32.10,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3d-d8a7-11e2-a440-85054b6a0b99,'IMGN',18.03,'2013-08-15');
INSERT INTO stockwatcher.WatchListItem (watchlist_id,stock_symbol,start_price,created) VALUES (ca58ee3d-d8a7-11e2-a440-85054b6a0b99,'ETE',59.28,'2013-08-15');

COPY stockwatcher.dailysummary (stock_symbol, trade_date, price_close, price_high, price_low, price_open, share_volume) from 'csv/dailysummaries.csv';
COPY stockwatcher.industry (industry_id, industry_name, sector_id, sector_name) from 'csv/industries.csv';
COPY stockwatcher.stock (stock_symbol, active, company_name, current_price, exchange_id, industry_id, industry_name, price_updated, sector_id, sector_name) from 'csv/stocks.csv';
COPY stockwatcher.stocksearch (industry_id, exchange_id, stock_symbol) from 'csv/stocksearch.csv';

UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='GLUU';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='NCI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='PENN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='EDAP';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='NCBC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BDSI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='NETE';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='AKS';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ASCA';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='EPAM';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='AMCX';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='VCBI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='EFT';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='HAST';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BKI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='GEVA';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='MEMP';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='MJN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='THM';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CBOE';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ESBF';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BHD';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='RRD';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='IIVI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CVR';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='GUT';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BOBE';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BGS';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CIFC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='LABC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='TKR';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BIOS';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='FOE';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='LSTR';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CPT';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BDGE';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CBEY';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='FOLD';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='NTLS';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='NSSC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='SWX';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='HMN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CJJD';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='IDTI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='TTMI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='HHC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='FFNW';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='RXN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='EXC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CRDC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='LDL';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='HCOM';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='UIS';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='IBIO';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='HOLL';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='JEC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='GPX';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='INFI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='URZ';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='TWIN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ATRI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='STEL';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BANF';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='DGLY';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='IIN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='AIMC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='HYF';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='SIAL';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='MNI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='HRS';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='LVB';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='MMYT';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='OGEN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ITC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='XRAY';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='SNCR';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='PPC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ETRM';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='CMRE';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='NYT';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='BANC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='PZN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='UNTK';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ADEP';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='FISI';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='EC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ICE';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='FLIC';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='IMGN';
UPDATE stockwatcher.StockCount SET watch_count=watch_count+1 WHERE stock_symbol='ETE';
