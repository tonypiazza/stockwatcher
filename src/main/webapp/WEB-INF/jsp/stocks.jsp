<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
	<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/"/>
	<meta charset="utf-8">
	<title>$tockWatcher - Stocks</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="The $tockWatcher Application">
	<meta name="author" content="Tony Piazza">

	<link href="img/favicon.ico" rel="shortcut icon"/>

    <link href="css/bootstrap.css" rel="stylesheet">
	<link href="css/skin/ui.dynatree.css" rel="stylesheet">
    <link href="css/DT_bootstrap.css" rel="stylesheet">
    <link href="css/stockwatcher.css" rel="stylesheet">
	<style type="text/css">
		.checkbox {
			margin-left: 10px;
		}
		.container-fluid {
			padding-right: 10px;
			padding-left: 10px;
		}
		div#tree {
			height: 190px;
			margin: 0;
		}
		div#criteria {
			padding: 60px 5px 20px 5px;
		}
		div#matchingstocks {
			padding: 60px 10px 20px 10px;
		}
		input.price {
			width: 70px; 
			display: inline; 
			text-align: right;
		}
		div.dataTables_length select {
			margin-left: 20px;
		}
		div.dataTables_info {
			margin-left: 20px;
		}
	</style>


    <script src="js/jquery.js"></script>
	<script src="js/jquery-ui.custom.js" type="text/javascript"></script>
    <script src="js/jquery.dataTables.js"></script>
    <script src="js/bootstrap.js"></script>
    <script src="js/DT_bootstrap.js"></script>
	<script src="js/jquery.dynatree.js" type="text/javascript"></script>

	<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
	<!--[if lt IE 9]>
	      <script src="js/html5shiv.js"></script>
    <![endif]-->

    <script type="text/javascript">
    	function styleStockTable() {
	    	$('#stocks').dataTable( {
	    		"sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
	    		"sPaginationType": "bootstrap",
	    		"oLanguage": {
	    			"sLengthMenu": "_MENU_ records per page"
	    		},
	    		"aoColumns": [ 
					null, null, null, null,
 					{ "sType": "numeric" }
 				]
	    	} );
    	}

 	    $(document).ready(function() {
	    	styleStockTable();
	    	$("#searchForm").submit(function(event) {
	    		event.preventDefault();
	    		if($("input[name='exchangeIds']:checked").length == 0) {
	    			alert('No exchanges selected');
	    			return;
	    		}
	    		if($("input[name='industryIds']").val().length == 0) {
	    			alert('No industries selected');
	    			return;
	    		}
	    		var minRegex = /^\s*(\+|-)?((\d+(\.\d{0,2})?)|(\.\d{0,2}))\s*$/;
	    		var minPrice = $("input[name='minimumPrice']").val();
	    		if(minPrice.length > 0 && !minRegex.test(minPrice)) {
	    			alert('Invalid minimum price: ' + minPrice);
	    			$("input[name='minimumPrice']").val('');
	    			return;
	    		}
	    		var maxRegex = /^\s*(\+|-)?((\d+(\.\d{0,2})?)|(\.\d{0,2}))\s*$/;
	    		var maxPrice = $("input[name='maximumPrice']").val();
	    		if(maxPrice.length > 0 && !maxRegex.test(maxPrice)) {
	    			alert('Invalid maximum price: ' + maxPrice);
	    			$("input[name='maximumPrice']").val('');
	    			return;
	    		}
	    		if(parseFloat(minPrice) >= parseFloat(maxPrice)) {
	    			alert('The minimum price must be less than the maximum price');
	    			return;
	    		}
	    		$('#matchingstocks').empty().append('<h4>Searching...</h4>');
	    		var posting = $.post( 'main/stocks/find', $(this).serialize());
				posting.done(function(data) {
					$('#matchingstocks').empty().append('<h3>Matching Stocks</h3>').append(data);
					styleStockTable();
				} );	    		
	    	} );
	    } );

		$(function() {
			$("#tree").dynatree( {
				checkbox : true,
				selectMode : 3,
				onSelect : function(select, node) {
					// Get a list of all selected nodes
					var selKeys = $.map(node.tree.getSelectedNodes(),
						function(node) {
							return node.data.key.charAt(0) == 's' ? null :
								node.data.key.substring(1);
						});
					$("input[name='industryIds']").val(selKeys.join(", "));
				},
				onDblClick : function(node, event) {
					node.toggleSelect();
				},
				onKeydown : function(node, event) {
					if (event.which == 32) {
						node.toggleSelect();
						return false;
					}
				}
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
					<span class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
				</button>
				<div class="nav-collapse collapse">
					<ul class="nav">
						<li><a href="main/home">Home</a></li>
						<li><a href="main/users">Users</a></li>
						<li class="active"><a href="main/stocks">Stocks</a></li>
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
			<div id="criteria" class="span4">
				<h3>Criteria</h3>	
				<form id="searchForm" class="form-horizontal">
					<label>Exchanges:</label>
					<c:forEach var="exchange" items="${exchanges}">
					<label class="checkbox">
						<input type="checkbox" name="exchangeIds" checked="checked" value="${exchange.id}">${exchange.id}
					</label>
					</c:forEach>
					<br><label>Sectors&nbsp;/&nbsp;Industries:</label>
					<div id="tree">
						<ul>
							<c:set var="prevSectorId" value="0"/>
							<c:forEach var="industry" items="${industries}">
								<c:if test="${industry.sector.id != prevSectorId}">
									<c:if test="${prevSectorId != 0}">
										${'</ul>'}		<%-- Hack to prevent editor from complaining --%>
									</c:if>
									<li id="s${industry.sector.id}" class="folder">${industry.sector.name}
										${'<ul>'}		<%-- Hack to prevent editor from complaining --%>
								</c:if>
								<li id="i${industry.id}"><span>${industry.name}</span></li>
								<c:set var="prevSectorId" value="${industry.sector.id}"/>
							</c:forEach>
						</ul>
					</div>
					<input type="hidden" name="industryIds"><br>
					<label for="minimumPrice" style="display: inline;">Price:$</label>
					<input type="text" class="price" name="minimumPrice" placeholder="minimum">
					<label for="maximumPrice" style="margin-left: 10px; display: inline;">to:&nbsp;$</label>
					<input type="text" class="price" name="maximumPrice" placeholder="maximum"><br> <br>
					<button type="submit" class="btn-inverse pull-right">
						<i class="icon-search icon-white"></i>&nbsp;Search</button>
				</form>
			</div>
			<div id="matchingstocks" class="span8">
				<h3>Matching Stocks</h3>
				<table id="stocks" class="table table-hover table-bordered table-condensed">
					<thead>
						<tr>
							<th class="text-left">Symbol</th>
							<th class="text-left">Company Name</th>
							<th class="text-center">Exchange</th>
							<th class="text-center">Industry</th>
							<th class="text-left">Current Price</th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>
		<footer>
			<p class="pull-right">&copy; DataStax, Inc.</p>
		</footer>

	</div>	<!-- /container -->

</body>
</html>