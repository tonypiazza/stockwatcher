<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/" />
	<meta charset="utf-8">
	<title>$tockWatcher - Home</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="The $tockWatcher Application">
	<meta name="author" content="Tony Piazza">

	<link href="img/favicon.ico" rel="shortcut icon"/>

	<link href="css/bootstrap.css" rel="stylesheet">
	<link href="css/stockwatcher.css" rel="stylesheet">
	<link href="css/webticker.css" rel="stylesheet">
	<style type="text/css">
		footer > p.pull-right {
			margin-right: 30px;
		}
		span#mwlabel {
			background-color: black;
			color: white;
			padding: 5px;
			float: left;
		}
		p {
			text-align: justify;
		}
	</style>

	<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
	<!--[if lt IE 9]>
	      <script src="js/html5shiv.js"></script>
	    <![endif]-->
	
	<script src="js/jquery.js" type="text/javascript"></script>
	<script src="js/jquery-ui.custom.js" type="text/javascript"></script>
	<script src="js/jquery.webticker.js" type="text/javascript"></script>
	<script src="js/bootstrap.js"></script>
	<script type="text/javascript">
	    $(document).ready(function() {
	    	jQuery("#most-watched").webTicker( {
	    	    speed: 30,
	    	    direction: "left",
	    	    moving: true,
	    	    startEmpty: true,
	    	    duplicate: false,
	    	    rssurl: 'main/stocks/mostwatched/rss',
	    	    rssfrequency: 5,
	    	    updatetype: "reset"
	    	}); 
	    });
	</script>

</head>
<body>
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">
				<button type="button" class="btn btn-navbar" data-toggle="collapse"
					data-target=".nav-collapse">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
				<div class="nav-collapse collapse">
					<ul class="nav">
						<li class="active"><a href="main/home">Home</a></li>
						<li><a href="main/users">Users</a></li>
						<li><a href="main/stocks">Stocks</a></li>
						<li><a href="main/watchlists">Watch Lists</a></li>
						<li><a href="main/about">About</a></li>
					</ul>
					<a class="brand" href="#">$tockWatcher</a>
				</div>
				<!--/.nav-collapse -->
			</div>
		</div>
	</div>
	<div class="container">
		<div class="main">
			<h3>Welcome to $tockWatcher</h3>
			<p><strong>$tockWatcher</strong> is a tool for investors who want to quickly find stocks 
				and keep track of them. It was built as a proof on concept and was well received
				by our beta testers. After incorporating their feedback we launced version 1.0
				in September 2013. We hope you find $tockWatcher to be a useful tool and welcome
				your feedback.</p>
			<img src="img/nyse.jpg">
		</div>
		<footer>
			<span id="mwlabel"><i class="icon-star icon-white"></i>&nbsp;Most Watched Stocks</span>
			<ul id="most-watched" class="newsticker"></ul>
		</footer>
	</div>	<!-- /container -->
</body>
</html>