<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
</head>
<body>
    <main class="card">
        <div class="topbrand">
            <h1>Đăng nhập</h1>
        </div>

        <form method="post" action="<%=request.getContextPath()%>/login">
            <div class="field">
                <label>Tên đăng nhập</label>
                <input class="input" name="username" placeholder="vd: mrb" required autofocus>
            </div>

            <div class="field">
                <label>Mật khẩu</label>
                <input class="input" type="password" name="password" placeholder="••••••" required>
            </div>

            <button class="btn" type="submit">Đăng nhập</button>

            <% if (msg != null) { %>
            <div class="msg"><%= msg %></div>
            <% } %>

            <div class="hint">
                <a href="#">Quên mật khẩu?</a>
            </div>
        </form>
    </main>
</body>
</html>
