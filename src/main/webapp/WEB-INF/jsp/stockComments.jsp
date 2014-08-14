<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="application/json" %>
<c:set var="commentDateFormat" value="dd MMM yyyy 'at' HH:mm:ss"/>
[<c:forEach var="comment" varStatus="status" items="${comments}">
{"Id":"${comment.id}" ,
"Author":"${comment.userDisplayName}",
"Comment":"${comment.text}",
"ParentId":null ,
"CanDelete":${user.id == comment.userId},
"CanReply":false,
"Date":"<fmt:formatDate value='${comment.created}' pattern='${commentDateFormat}'/>"
}${status.last ? "" : ","}
</c:forEach>]