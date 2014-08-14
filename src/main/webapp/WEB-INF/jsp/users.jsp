<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
  <head>
 	<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/"/>
    <meta charset="utf-8">
    <title>$tockWatcher - Users</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="The $tockWatcher Application">
    <meta name="author" content="Tony Piazza">

	<link href="img/favicon.ico" rel="shortcut icon"/>

    <link href="css/bootstrap.css" rel="stylesheet">
    <link href="css/DT_bootstrap.css" rel="stylesheet">
    <link href="css/stockwatcher.css" rel="stylesheet">

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="js/html5shiv.js"></script>
    <![endif]-->

    <script src="js/jquery.js"></script>
    <script src="js/jquery.dataTables.js"></script>
    <script src="js/bootstrap.js"></script>
    <script src="js/DT_bootstrap.js"></script>
    <script type="text/javascript">
	    /* Table initialisation */
	    $(document).ready(function() {
	    	$('#users').dataTable( {
	    		"sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
	    		"sPaginationType": "bootstrap",
	    		"oLanguage": {
	    			"sLengthMenu": "_MENU_ records per page"
	    		},
	    		"aoColumns": [ 
					{ "bSortable": false },
					null, null, null, null, null, null
				]
	    	} );
	    } );
    </script>
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
              <li class="active"><a href="main/users">Users</a></li>
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
       	<h3>Users</h3>
		<c:if test="${empty user}">
			<h4>No user currently selected.</h4>
		</c:if>
        <div>
			<table id="users" class="table table-hover table-bordered table-condensed">
				<thead>
					<tr>
						<th class="">&nbsp;</th>
						<th class="text-left">First Name</th>
						<th class="text-left">Last Name</th>
						<th class="text-left">Nickname</th>
						<th class="text-center">Location</th>
						<th class="text-center">Member Since</th>
						<th># Watch Lists</th>
					</tr>
				</thead>
				<tbody>
					<c:set var="selectedUserId" value="${empty user ? '' : user.id}"/>
					<c:forEach var="user" items="${users}">
					<tr class="${user.id == selectedUserId ? 'active' : ''}">
						<td><a href="main/users/select/${user.id}" class="btn btn-inverse">Select</a></td>
						<td><c:out value="${user.firstName}"/></td>
						<td><c:out value="${user.lastName}"/></td>
						<td><c:out value="${user.displayName}"/></td>
						<td class="text-center"><c:out value="${user.postalCode}"/></td>
						<td class="text-center"><fmt:formatDate value="${user.created}"/></td>
						<td class="text-right"><c:out value="${user.watchListCount}"/></td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
        </div>
      </div>

      <footer>
        <p class="pull-right">&copy; DataStax, Inc.</p>
      </footer>

    </div> <!-- /container -->

  </body>
</html>