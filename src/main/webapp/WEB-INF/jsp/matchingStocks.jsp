<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="base" value="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/"/>
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
		<c:forEach var="stock" items="${stocks}">
		<tr>
			<td>${stock.symbol}</td>
			<td><a href="${base}main/stocks/${stock.symbol}" target="_blank">${stock.companyName}</a></td>
			<td class="text-center">${stock.exchangeId}</td>
			<td class="text-center">${stock.industry.name}</td>
			<td class="text-right"><fmt:formatNumber value="${stock.currentPrice}" pattern="0.00"/></td>
		</tr>
		</c:forEach>
	</tbody>
</table>