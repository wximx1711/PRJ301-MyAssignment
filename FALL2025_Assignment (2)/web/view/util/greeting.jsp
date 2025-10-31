<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Set" %>
<%
    model.iam.User u = (model.iam.User) session.getAttribute("user");
    Set<String> features = (Set<String>) request.getAttribute("features");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
</head>
<body>
    <div class="navbar">
        <a href="<%=request.getContextPath()%>/home">Trang chủ</a>
        <div class="grow"></div>
        <a href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
    </div>

    <div class="container">
        <h1>Chào mừng, <%= u.getDisplayname() %>!</h1>
        <p>Tài khoản của bạn: <%= u.getUsername() %></p>
        <p>Thông tin nhân viên: <%= u.getEmployee() != null ? u.getEmployee().getEname() : "Chưa có thông tin" %></p>

        <div class="product-list">
            <div class="product-card">
                <h2>Thông tin nhanh</h2>
                <p class="kpi">12</p>
                <p class="kpi-title">Đơn nghỉ phép chờ duyệt</p>
                <a class="link" href="<%=request.getContextPath()%>/request/list">Xem chi tiết</a>
            </div>
            
            <div class="product-card">
                <h2>Thông tin nhân viên</h2>
                <p class="kpi">50</p>
                <p class="kpi-title">Số nhân viên đã nghỉ</p>
                <a class="link" href="<%=request.getContextPath()%>/division/agenda">Xem lịch</a>
            </div>
        </div>

        <div class="card">
            <h2>Quản lý đơn nghỉ phép</h2>
            <ul>
                <li><a class="link" href="<%=request.getContextPath()%>/request/create">Tạo đơn nghỉ phép</a></li>
                <li><a class="link" href="<%=request.getContextPath()%>/request/list">Xem danh sách đơn</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
