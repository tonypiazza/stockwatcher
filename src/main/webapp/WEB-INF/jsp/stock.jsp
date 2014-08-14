<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
	<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/"/>
	<meta charset="utf-8">
	<title>$tockWatcher - Stock Symbol ${stock.symbol}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="The $tockWatcher Application">
	<meta name="author" content="Tony Piazza">

	<link href="img/favicon.ico" rel="shortcut icon"/>

    <link href="css/bootstrap.css" rel="stylesheet">
    <link href="css/stockwatcher.css" rel="stylesheet">
    <link href="css/jquery.jqplot.css" rel="stylesheet">
    <link href="css/jquery.comment.css" rel="stylesheet"/>

	<style type="text/css">
		div#chartdiv {
			padding: 62px 10px 20px 10px;
		}
		div#chart {
			width: 100%;
			height: 475px;
			margin-bottom: 10px;
		}
		div#no-data {
			min-width: 400px;
			min-height: 200px;
			padding-top: 100px;
			text-align: center;
		}
		div#summary {
			padding: 50px 5px 20px 5px;
		}
		td#company-name {
			width: 25%; 
			padding-right: 20px; 
			white-space: nowrap;
		}
		button#refresh-button {
			width: 120px;
			text-align: left;
		}
		button#reset-zoom {
			margin-right: 40px;
		}
		.alert-info {
			margin-top: 25px;
			margin-right: 20px;
		}
		.center-horizontal {
			position: relative;
			left: 50%;
			transform: translate(-50%, 0);
		}
		#summaryTabs {
			margin-bottom: 0;
		}
		.nav-tabs > li {
			border-top: 1px solid rgb(221, 221, 221);
			border-right: 1px solid rgb(221, 221, 221);
			border-left: 1px solid rgb(221, 221, 221);
		}
		.tab-content {
			border-right: 1px solid rgb(221, 221, 221);
			border-bottom: 1px solid rgb(221, 221, 221);
			border-left: 1px solid rgb(221, 221, 221);
			padding: 10px;
			background-color: white;
		}
		#detailsTab {
			height: 400px;
		}
		#commentSection {
			height: 400px;
		}
		.newComment {
			margin-right: 10px;
		}
		.commentsBlock .comment .commentText {
			word-wrap: normal;
			word-break: normal;
		}
	</style>

	<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
	<!--[if lt IE 9]>
	      <script src="js/html5shiv.js"></script>
	      <script language="javascript" type="text/javascript" src="excanvas.js"></script>
    <![endif]-->

    <script src="js/jquery.js"></script>
	<script src="js/jquery-ui.custom.js"></script>
	<script src="js/jquery.jqplot.js"></script>
	<script src="js/jqplot.cursor.js"></script>
	<script src="js/jqplot.dateAxisRenderer.js"></script>
    <script src="js/bootstrap.js"></script>
    <script src="js/jquery.comment.js"></script>
    <script type="text/javascript">
    	var commentRefreshTimer;

    	function startCommentRefreshTimer() {
    		return setInterval('refreshComments();', 10000);
    	}

		var refreshRate = 10;

		function startChartRefreshTimer() {
			return setInterval('refreshChart();', refreshRate * 1000);
		}

		var chartRefreshTimer = startChartRefreshTimer();

    	var trades = <c:import url="trades.jsp"/>;
    	var chart1 = null;

    	function createChart() {
 	    	chart1 = $.jqplot('chart', trades, {
    			seriesDefaults: {
    				shadow: false,
    				color: '#1a5488',
    				fillAndStroke: true,
    				fillColor: '#d6e7f2',
    				fill: true,
    				showMarker: false,
    				yaxis: 'y2axis',
    				lineWidth: 1
    			},
    			axes: {
    				xaxis: {
    					renderer: $.jqplot.DateAxisRenderer,
    					tickOptions: {
    						formatString: '%#I:%M:%S %p'
    					}, 
    					tickInterval: '${elapsedTime < 3600 ? "5 minutes" : elapsedTime < 7200 ? "15 minutes" : elapsedTime < 14400 ? "30 minutes" : "60 minutes"}'
    				}
    			}, 
    			title: '<strong>${stock.companyName}&nbsp;(${stock.symbol})</strong>',
    			y2axis: {
    				label: 'axis2',
    		        tickOptions: {
    		        	formatString: "$%'d"
    		        }
    			},
    			cursor: {
    		        show: refreshRate == 0,
    		        zoom: refreshRate == 0,
    		        showTooltip: false
    		    }
    		} );
		}

    	function refreshChart() {
    		var get = $.get( 'main/stocks/${stock.symbol}/trades');
			get.done(function(data) {
				trades = eval(data);
				if(trades[0].length > 0) {
					if(chart1) {
						chart1.destroy();
					}
					createChart();
	    			$('#refresh-dropdown').show();
				} else {
	    			$('#refresh-dropdown').hide();
				}
			} );
		}

    	function refreshComments() {
			$("#commentSection").comments("refresh");
		}

    	$(document).ready(function() {
    		<c:if test="${liveTrading and (elapsedTime > 0)}">
 	    	createChart();
			</c:if>
			<c:if test="${!liveTrading}">
			$('#refresh-dropdown').hide();
			</c:if>
			$('#reset-zoom').hide();	    			
 	    	$(window).resize(function() { chart1.replot( { resetAxes: true } ); });
 	    	$('#reset-zoom').click(function() { chart1.resetZoom(); } );
 	    	$("#watchListId").change(function() {
 	    		$("input[name='displayName']").prop('disabled', (this.selectedIndex > 0));
 	    	});
	    	$('#addForm').submit(function(event) {
	    		event.preventDefault();
	    		var id = $("#watchListId"); 
	    		if(id.prop("selectedIndex") == 0 && 
	    		   $("input[name='displayName']").val().length == 0) {
	    			alert("Watch List Name must be specified");
	    			return;
	    		} 
 	    		var posting = $.post( 'main/watchlists/addtowatchlist', $(this).serialize());
				posting.done(function(data) {
					$("#watchListId").html(data);
				} );
				$('#modalAdd').modal('hide');
	    	} );
	    	$('#modalAdd').on('hidden.bs.modal', function () {
	    		$("#watchListId").prop("selectedIndex", 0);
	    		var displayName = $("input[name='displayName']");
	    		displayName.prop('disabled', false);
	    		displayName.val('');
    		});
	    	$('.refresh').click(function() {
	    		if(refreshRate > 0) {
		    		clearInterval(chartRefreshTimer);
	    		}
	    		$('#refresh-' + refreshRate).removeClass('active');
	    		refreshRate = $(this).attr('data-confirm');
				console.log('set refreshRate = ' + refreshRate);
    			refreshChart();
	    		$('#refresh-button').html( $(this).html() );
	    		$(this).addClass('active');
	    		if(refreshRate > 0) {
	    			chartRefreshTimer = startChartRefreshTimer();
					$('#reset-zoom').hide();	    			
	    		} else {
					$('#reset-zoom').show();
	    		}
	    		$(this).removeClass('open');
 	    	});
            $("#commentSection").comments({
                getCommentsUrl: 'main/stocks/${stock.symbol}/getcomments',
                postCommentUrl: 'main/stocks/${stock.symbol}/postcomment',
                deleteCommentUrl: 'main/stocks/${stock.symbol}/deletecomment',
                readOnly: ${empty user},
                displayHeader: false
            });
            $('a[data-toggle="tab"]').on('shown', function (e) {
            	if(e.target.toString().endsWith('#commentsTab')) {
            		refreshComments();
            		commentRefreshTimer = startCommentRefreshTimer();
            	} else {
            		clearInterval(commentRefreshTimer);
            	}
            });
	    	$('#summaryTabs a:first').tab('show');
	    });
    </script>

</head>

<body>

	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">
				<button type="button" class="btn btn-navbar" data-toggle="collapse"
					data-target=".nav-collapse">
					<span class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
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
				</div>	<!--/.nav-collapse -->
			</div>
		</div>
	</div>

	<div class="container-fluid">
		<div class="row-fluid">
			<div id="summary" class="span4">
				<ul class="nav nav-tabs" id="summaryTabs">
				  <li class="active"><a data-toggle="tab" href="#detailsTab">Details</a></li>
				  <li><a data-toggle="tab" href="#commentsTab">Comments</a></li>
				</ul>
				<div class="tab-content">
				  <div class="tab-pane active" id="detailsTab">
					<table style="width: 100%;">
						<tr>
							<td id="company-name">Company Name:</td>
							<td>${stock.companyName}</td>
						</tr>
						<tr>
							<td>Stock Symbol:</td>
							<td>${stock.symbol}</td>
						</tr>
						<tr>
							<td>Sector:</td>
							<td>${stock.industry.sector.name}</td>
						</tr>
						<tr>
							<td>Industry:</td>
							<td>${stock.industry.name}</td>
						</tr>
						<tr>
							<td>Exchange:</td>
							<td>${stock.exchangeId}</td>
						</tr>
						<tr>
							<td>Last Close:</td>
							<td>${lastClosePrice}</td>
						</tr>
						<tr>
							<td>Watch Count:</td>
							<td>${watchCount}</td>
						</tr>
					</table>
				  </div>
				  <div class="tab-pane" id="commentsTab">
					<div id="commentSection"></div>
				  </div>
				</div>
			</div>
			<div id="chartdiv" class="span8">
				<div id="chart">
					<c:if test="${empty trades}">
					<div id="no-data"><strong>No data for this stock chart</strong></div>
					</c:if>
				</div>
				<c:if test="${!empty user}">
					<a id="watchlists" data-toggle="modal" href="#modalAdd" class="btn btn-inverse btn-mini">Add to Watch List</a>
				</c:if>
				<div id="refresh-dropdown" class="btn-group dropup center-horizontal" data-toggle="dropdown">
					<button id="refresh-button" type="button" class="btn btn-inverse btn-mini">Refresh: 10 seconds</button>
					<button type="button" class="btn btn-inverse btn-mini dropdown-toggle" data-toggle="dropdown">
						<span class="caret"></span>
					</button>
					<ul class="dropdown-menu">
						<li id="refresh-10"><a href="#" class="refresh" data-confirm="10">Refresh: 10 seconds</a></li>
						<li id="refresh-20"><a href="#" class="refresh" data-confirm="20">Refresh: 20 seconds</a></li>
						<li id="refresh-30"><a href="#" class="refresh" data-confirm="30">Refresh: 30 seconds</a></li>
						<li id="refresh-60"><a href="#" class="refresh" data-confirm="60">Refresh: 1 minute</a></li>
						<li class="divider"></li>
						<li id="refresh-0"><a href="#" class="refresh" data-confirm="0">Refresh: Off</a></li>
					</ul>
				</div>
				<button id="reset-zoom" type="button" class="btn btn-inverse btn-mini pull-right hide">Reset Zoom</button>
			</div>
			<c:if test="${!empty user}">
			<div class="modal fade" id="modalAdd">
				<div class="modal-dialog">
					<div class="modal-content">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal">&times;</button>
							<h4 class="alert alert-info">Add Stock Symbol ${stock.symbol} to Watch List</h4>
						</div>
						<div class="modal-body">
							<form id="addForm" class="form-horizontal">
								<input type="hidden" name="stockSymbol" value="${stock.symbol}">
								<select id="watchListId" name="watchListId">
									<c:import url="watchListOptions.jsp"/>
								</select>
								<input type="text" name="displayName" placeholder="Watch List Name">
								<button type="submit" class="btn btn-inverse">
									<i class="icon-plus icon-white"></i>&nbsp;Add</button>
							</form>
						</div>
					</div>
				</div>
			</div>
			</c:if>
		</div>
		<footer>
			<p class="pull-right">Powered by <a href="http://cassandra.apache.org/" target="_blank">Apache Cassandra</a></p>
		</footer>

	</div>	<!-- /container -->

</body>
</html>