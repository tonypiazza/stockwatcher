<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
[[<c:forEach var="trade" varStatus="status" items="${trades}">
	['<fmt:formatDate pattern="hh:mm:ss a" value="${trade.timestamp}"/>', ${trade.sharePrice}]${status.last ? "" : ","}
</c:forEach>]]