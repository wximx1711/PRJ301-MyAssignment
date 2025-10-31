<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.RequestForLeave" %>
<%
    List<RequestForLeave> mine = (List<RequestForLeave>) request.getAttribute("mine");
    List<RequestForLeave> subs = (List<RequestForLeave>) request.getAttribute("subs");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh sách đơn nghỉ phép</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
</head>
<body>
    <h1>Danh sách đơn nghỉ phép của bạn</h1>
    
    <h2>Đơn của tôi</h2>
    <ul>
        <% for (RequestForLeave r : mine) { %>
            <li>Đơn ID: <%= r.getRid() %> - Lý do: <%= r.getReason() %> - Trạng thái: <%= r.getStatus() %></li>
        <% } %>
    </ul>

    <h2>Đơn của cấp dưới</h2>
    <ul>
        <% for (RequestForLeave r : subs) { %>
            <li>Đơn ID: <%= r.getRid() %> - Lý do: <%= r.getReason() %> - Trạng thái: <%= r.getStatus() %></li>
        <% } %>
    </ul>
</body>
</html>
