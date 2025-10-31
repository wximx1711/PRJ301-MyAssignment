<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"><title>Đăng nhập</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
</head>
<body>
  <main class="card">
    <div class="topbrand">
      <div class="logo"></div>
      <div>
        <h1 class="title">Đăng nhập</h1>
        <div class="sub">Quản lý đơn nghỉ phép</div>
      </div>
    </div>

    <form method="post" action="<%=request.getContextPath()%>/login" autocomplete="on">
      <div class="field">
        <label>Tên đăng nhập</label>
        <input class="input" name="username" placeholder="vd: mrb" required autofocus>
      </div>

      <div class="field pwdwrap">
        <label>Mật khẩu</label>
        <input class="input" id="pwd" type="password" name="password" placeholder="••••••" required>
        <button type="button" class="toggle" onclick="togglePwd()">Hiện</button>
        <small class="hint">Tài khoản mẫu: mrb / 123</small>
      </div>

      <button class="btn" type="submit">Đăng nhập</button>
      <div style="margin-top:10px;text-align:center">
        <a class="muted-link" href="#">Quên mật khẩu?</a>
      </div>

      <% if (msg != null) { %>
      <div class="msg"><%= msg %></div>
      <% } %>
    </form>
  </main>

  <script>
    function togglePwd(){
      const i = document.getElementById('pwd');
      const btn = event.currentTarget;
      if(i.type === 'password'){ i.type='text'; btn.textContent='Ẩn'; }
      else { i.type='password'; btn.textContent='Hiện'; }
    }
  </script>
</body>
</html>
