StockWatcher
============

The StockWatcher application is the basis for a Java developer course on Apache Cassandra
that was built by DataStax.

Here are the steps you need to follow to launch the application for the first time:

(1) Launch cqlsh from the project folder and execute the following command:

source 'cql/stockwatcher.cql';

(2) Execute Maven using the following command:

mvn jetty:run

Once the application is up and running, you can launch a web browser with this URL:

[http://localhost:8080/stockwatcher/] (http://localhost:8080/stockwatcher/)

To stop the application, you can just Ctrl-C in the terminal window where you launched it.

After the first time, you only need to do step (2) above to run the application again.

