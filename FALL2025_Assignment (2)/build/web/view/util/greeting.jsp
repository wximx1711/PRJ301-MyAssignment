<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Set" %>
<%
  model.iam.User u = (model.iam.User) session.getAttribute("user");
  Set<String> features = (Set<String>) request.getAttribute("features");
  boolean canCreate = features!=null && features.contains("/request/create");
  boolean canList   = features!=null && features.contains("/request/list");
  boolean canReview = features!=null && features.contains("/request/review");
  boolean canAgenda = features!=null && features.contains("/division/agenda");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Dashboard</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
</head>
<body>
  <div class="nav">
    <div class="nav-inner">
      <div class="brand">
        <div class="logo"></div><span>LM System</span>
      </div>
      <div class="nav-links">
        <% if (canList) { %><a href="<%=request.getContextPath()%>/request/list">Danh sách</a><% } %>
        <% if (canAgenda) { %><a href="<%=request.getContextPath()%>/division/agenda">Agenda</a><% } %>
      </div>
      <div class="grow"></div>
      <div class="search">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M21 21l-4.3-4.3M10.5 18a7.5 7.5 0 1 1 0-15 7.5 7.5 0 0 1 0 15Z" stroke="#94a3b8" stroke-width="2" stroke-linecap="round"/></svg>
        <input placeholder="Tìm kiếm nhanh...">
      </div>
      <div class="actions">
        <span class="badge"><%= u.getUsername() %></span>
        <a class="btn" href="<%=request.getContextPath()%>/logout">Đăng xuất</a>
      </div>
    </div>
  </div>

  <div class="container">
    <div class="hi">
      <div>
        <h2 style="margin:0;">PRJ301 • Xin chào, <%= u.getDisplayname() %></h2>
        <div class="sub">Bảng điều khiển & tác vụ nhanh</div>
      </div>
    </div>

    <div class="grid">
      <% if (canList) { %>
        <a class="tile" href="<%=request.getContextPath()%>/request/list">
          <h3>Danh sách đơn</h3><p>Xem đơn của bạn & cấp dưới</p>
        </a>
      <% } %>
      <% if (canCreate) { %>
        <a class="tile" href="<%=request.getContextPath()%>/request/create">
          <h3>Tạo đơn nghỉ</h3><p>Tạo mới trong 10 giây</p>
        </a>
      <% } %>
      <% if (canReview) { %>
        <a class="tile" href="<%=request.getContextPath()%>/request/list#review">
          <h3>Duyệt đơn</h3><p>Approve/Reject nhanh</p>
        </a>
      <% } %>
      <% if (canAgenda) { %>
        <a class="tile" href="<%=request.getContextPath()%>/division/agenda">
          <h3>Lịch phòng ban</h3><p>OFF/ON theo ngày</p>
        </a>
      <% } %>
    </div>

    <!-- KPI demo: có thể thay bằng số thật -->
    <div class="cards">
      <div class="card"><div class="row"><div><div class="sub">Đơn của tôi (tháng này)</div><div class="kpi">3</div></div><span class="tag ok">0 bị từ chối</span></div></div>
      <div class="card"><div class="row"><div><div class="sub">Đơn chờ duyệt</div><div class="kpi">5</div></div><span class="tag warn">Cần xử lý</span></div></div>
      <div class="card"><div class="row"><div><div class="sub">OFF tuần này</div><div class="kpi">2 người</div></div><span class="tag">IT Dept</span></div></div>
    </div>
  </div>
</body>
</html>
