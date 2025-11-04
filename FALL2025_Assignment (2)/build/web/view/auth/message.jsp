<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html><head>
  <meta charset="UTF-8"><title>Thông báo</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
</head>
<body>
  <div class="container">
    <div class="cards">
      <div class="card">
        <h3 style="margin:0 0 8px">Thông báo</h3>
        <p style="color:#cbd5e1"><%= request.getAttribute("message")==null?"":request.getAttribute("message") %></p>
        <p><a class="btn" href="<%=request.getContextPath()%>/home">Về trang chủ</a></p>
      </div>
    </div>
  </div>
</body></html>
