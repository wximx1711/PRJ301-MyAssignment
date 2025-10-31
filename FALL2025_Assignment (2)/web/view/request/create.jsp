<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.Date" %>
<%
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tạo đơn nghỉ phép</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css"> <!-- Kết nối với CSS -->
</head>
<body>
    <div class="container">
        <h1>Tạo Đơn Nghỉ Phép</h1>
        <% if (msg != null) { %>
            <div class="alert alert-danger"><%= msg %></div>
        <% } %>
        <form action="<%= request.getContextPath() %>/request/create" method="post">
            <div class="field">
                <label for="from">Ngày bắt đầu:</label>
                <input class="input" type="date" id="from" name="from" required>
            </div>

            <div class="field">
                <label for="to">Ngày kết thúc:</label>
                <input class="input" type="date" id="to" name="to" required>
            </div>

            <div class="field">
                <label for="reason">Lý do nghỉ:</label>
                <textarea class="input" id="reason" name="reason" rows="4" required></textarea>
            </div>

            <button class="btn" type="submit">Tạo Đơn Nghỉ</button>
        </form>
    </div>
</body>
</html>
