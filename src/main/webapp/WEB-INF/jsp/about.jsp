<!DOCTYPE html>
<html lang="en">
  <head>
	<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/"/>
    <meta charset="utf-8">
    <title>$tockWatcher - About</title>
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
		table {
			margin-top: 40px;
		}
		td {
			padding: 10px;
		}
		.partner {
			vertical-align: top;
		}
		.main {
		 	margin-left: auto;
		 	margin-right: auto;
		 	width: 60%;
		}
		td.lp {
			border-top: solid thin black;
			padding-top: 30px;
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
              <li class="active"><a href="main/about">About</a></li>
            </ul>
            <a class="brand" href="#">$tockWatcher</a>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container">
		<div class="main">
			<p>The <strong>$tockWatcher</strong> application was developed by LearningPatterns for DataStax.</p>
			<table>
				<tr>
					<td class="partner"><a target="_blank" href="http://www.datastax.com/"><img src="img/datastax-logo.png"></a></td>
					<td style="text-align: right;">
						<address>
							<strong><a target="_blank" href="http://www.datastax.com/">DataStax Inc. HQ</a></strong><br>
							SAN FRANCISCO BAY AREA<br>
							3975 Freedom Circle<br>
							Santa Clara, CA 95054<br>
							USA<br>
							Phone: 650.389.6000 
						</address>
					</td>
				</tr>
				<tr>
					<td class="lp">
						<address>
							<strong><a target="_blank" href="http://learningpatterns.com/">LearningPatterns Inc.</a></strong><br>
							262 Main St. #12<br>
							Beacon, NY 12508-2734<br>
							Phone: 212.487.9064
						</address>
					</td>
					<td class="partner lp"><a target="_blank" href="http://learningpatterns.com/"><img src="img/learningpatterns-logo.jpg"></a></td>
				</tr>
			</table>
		</div>
		<footer>
			<p class="pull-right">&copy; DataStax, Inc.</p>
		</footer>
    </div> <!-- /container -->
  </body>
</html>