<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../../layout/header.jsp" %>

<c:set var="pageTitle" value="Quản trị người dùng" />
<div class="container-fluid">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3><i class="bi bi-people"></i> Danh sách người dùng</h3>
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/user/create"><i class="bi bi-person-plus"></i> Tạo user</a>
  </div>
  <div class="card border-0 shadow-sm">
    <div class="card-body table-responsive">
      <table class="table table-striped align-middle">
        <thead><tr><th>ID</th><th>Username</th><th>Họ tên</th><th>Role</th><th>Phòng ban</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
        <tbody>
        <c:forEach items="${users}" var="u">
          <tr>
            <td>${u.id}</td>
            <td>${u.username}</td>
            <td>${u.fullName}</td>
            <td>${u.role.code}</td>
            <td>${u.department.name}</td>
            <td>
              <span class="badge ${u.active ? 'bg-success' : 'bg-secondary'}">${u.active ? 'Active' : 'Inactive'}</span>
            </td>
            <td>
              <form method="post" class="d-inline" action="${pageContext.request.contextPath}/admin/users" onsubmit="return confirm('Xác nhận?')">
                <input type="hidden" name="uid" value="${u.id}" />
                <input type="hidden" name="action" value="${u.active ? 'deactivate' : 'activate'}" />
                <button class="btn btn-sm ${u.active ? 'btn-outline-warning' : 'btn-outline-success'}">${u.active ? 'Deactivate' : 'Activate'}</button>
              </form>
              <form method="post" class="d-inline" action="${pageContext.request.contextPath}/admin/users" onsubmit="return confirm('Reset mật khẩu về 123?')">
                <input type="hidden" name="uid" value="${u.id}" />
                <input type="hidden" name="action" value="reset" />
                <button class="btn btn-sm btn-outline-danger">Reset PW</button>
              </form>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%@ include file="../../layout/footer.jsp" %>


