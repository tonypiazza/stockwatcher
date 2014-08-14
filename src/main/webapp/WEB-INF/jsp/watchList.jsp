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
	<link href="css/DT_bootstrap.css" rel="stylesheet">
	<link href="css/stockwatcher.css" rel="stylesheet">
	<style type="text/css">
		#summary {
			margin-bottom: 20px;
		}
		.change-up {
			color: green;
		}
		.change-down {
			color: red;
		}
	</style>

	<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
	<!--[if lt IE 9]>
	      <script src="js/html5shiv.js"></script>
	      <script language="javascript" type="text/javascript" src="excanvas.js"></script>
    <![endif]-->

    <script src="js/jquery.js"></script>
    <script src="js/jquery.dataTables.js"></script>
    <script src="js/bootstrap.js"></script>
    <script src="js/DT_bootstrap.js"></script>

    <script type="text/javascript">
	    $(document).ready(function() {
			var itemTable = $('#watchlistitems').dataTable( {
				"sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
				"sPaginationType": "bootstrap",
				"oLanguage": {
					"sLengthMenu": "_MENU_ records per page"
				},
				"aoColumns": [ 
					{ "bSortable": false },
					null, null, null, null, null, null, null, null
				]
			} );
    		$('#cancel-button').click(function(event) {
    			$('#modalDelete').modal('hide');
    		} );
	    	$('.remove').click(function() {
	    		var id = this.id;
	    		$('#message').html('<strong>Confirm you want to remove this stock:</strong>' + 
	    			'<br><br>' + $(this).attr('data-confirm'));
	    		$('#ok-button').click(function(event) {
		    		var posting = $.post('main/watchlists/removefromwatchlist',
	    				'stockSymbol=' + id + '&watchListId=${watchList.id}');
	    			posting.done(function() {
	    				itemTable.fnDeleteRow($('#row-' + id).prop('rowIndex')-1);
	    				$('#modalDelete').modal('hide');
	    			} );
	    		} );
	    		$('#modalDelete').modal('show');
	    	} );
	    } );
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

	<div class="container">
		<div class="main">
			<c:if test="${!empty user}">
			<div id="summary">
				<h3>Watch List: ${watchList.displayName}</h3>
				<table>
					<tr>
						<td>Created:</td>
						<td><fmt:formatDate value="${watchList.created}" pattern="yyyy-MM-dd"/></td>
					</tr>
					<tr>
						<td>Last Updated:</td>
						<td><fmt:formatDate value="${watchList.updated}" pattern="yyyy-MM-dd"/></td>
					</tr>
				</table>
			</div>
			<div id="detail">
				<table id="watchlistitems" class="table table-hover table-bordered table-condensed">
					<thead>
						<tr>
							<th style="width: 20px;">&nbsp;</th>
							<th class="text-left">Symbol</th>
							<th class="text-left">Company Name</th>
							<th class="text-center">Exchange</th>
							<th class="text-center">Industry</th>
							<th class="text-center">Date Added</th>
							<th class="text-center">Start Price</th>
							<th class="text-center">Current Price</th>
							<th class="text-center">Change</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="item" items="${watchListItems}">
						<tr id="row-${item.symbol}">
							<td class="text-center"><a id="${item.symbol}" class="remove btn btn-inverse btn-mini" 
								data-confirm="${item.companyName}&nbsp;(${item.symbol})"><i class="icon-trash icon-white"></i></a>
							<td>${item.symbol}</td>
							<td><a href="${base}main/stocks/${item.symbol}" target="_blank">${item.companyName}</a></td>
							<td class="text-center">${item.exchangeId}</td>
							<td class="text-center">${item.industry.name}</td>
							<td><fmt:formatDate value="${item.created}" pattern="yyyy-MM-dd"/></td>
							<td class="text-right"><fmt:formatNumber value="${item.startPrice}" pattern="0.00"/></td>
							<td class="text-right"><fmt:formatNumber value="${item.currentPrice}" pattern="0.00"/></td>
							<td class="text-right ${item.rateOfReturn > 0 ? 'change-up' : item.rateOfReturn < 0 ? 'change-down' : ''}"><fmt:formatNumber value="${item.rateOfReturn * 100}" pattern="0.0"/>%</td>
						</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
			<div class="modal fade" id="modalDelete">
				<div class="modal-dialog">
					<div class="modal-content">
						<div class="modal-header">
							<h4 class="alert alert-danger">Warning</h4>
						</div>
						<div class="modal-body">
							<p id="message"></p>
							<div class="pull-right">
								<button id="ok-button" type="button" class="btn btn-inverse">
									<i class="icon-ok icon-white"></i>&nbsp;OK</button>
								<button id="cancel-button" type="button" class="btn btn-inverse">
									<i class="icon-remove icon-white"></i>&nbsp;Cancel</button>
							</div>
						</div>
					</div>
				</div>
			</div>
			</c:if>
		</div>
		<footer>
			<p class="pull-left"><a href="main/watchlists/${watchList.id}/rss" target="_blank"><img src="img/feedicon.png"/></a></p>
			<p class="pull-right">&copy; DataStax, Inc.</p>
		</footer>

	</div>	<!-- /container -->

</body>
</html>