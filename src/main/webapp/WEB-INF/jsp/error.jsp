<!DOCTYPE html>
<html lang="en">
  <head>
	<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/"/>
    <meta charset="utf-8">
    <title>$tockWatcher - Error</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="The $tockWatcher Application">
    <meta name="author" content="Tony Piazza">

	<link href="img/favicon.ico" rel="shortcut icon"/>

    <link href="css/bootstrap.css" rel="stylesheet">
    <link href="css/stockwatcher.css" rel="stylesheet">
    <style type="text/css">
    	footer> p.pull-right {
			margin-right: 30px;
		}
		.main {
		 	margin-left: auto;
		 	margin-right: auto;
		 	width: 60%;
		}
		#error-msg {
			font-size: 140%;
			padding-top: 20px;
			height: 300px;
			margin-top: 100px;
		}
    </style>

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="js/html5shiv.js"></script>
    <![endif]-->

    <script src="js/jquery.js" type="text/javascript"></script>
    <script src="js/jquery-ui.custom.js" type="text/javascript"></script>
    <script src="js/bootstrap.js"></script>
  </head>
  <body>
    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <div class="nav-collapse collapse">
            <ul class="nav">
              <li><a href="main/home">Home</a></li>
              <li><a href="main/users">Users</a></li>
              <li><a href="main/stocks">Stocks</a></li>
              <li><a href="main/watchlists">Watch Lists</a></li>
              <li><a href="main/about">About</a></li>
            </ul>
            <a class="brand" href="#">$tockWatcher</a>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container">
		<div class="main">
			<img class="pull-left" src="img/warning.png" height="75" width="75"/>
			<p id="error-msg">Something unexpected has occurred while processing the most recent request. 
			Please try again later.</p>
		</div>
		<footer>
			<p class="pull-right">&copy; DataStax, Inc.</p>
		</footer>
    </div> <!-- /container -->
  </body>
</html>