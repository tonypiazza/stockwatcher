<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="base" value="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/"/>
<option value="0">--- Create New Watch List ---</option>
<c:forEach var="watchList" items="${watchLists}"><option value="${watchList.id}">${watchList.displayName}</option></c:forEach>