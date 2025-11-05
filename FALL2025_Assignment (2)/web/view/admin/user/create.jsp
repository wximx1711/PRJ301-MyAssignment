<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../../layout/header.jsp" %>

<c:set var="pageTitle" value="Tạo người dùng" />

<div class="container-fluid">
  <div class="row justify-content-center">
    <div class="col-lg-8">
      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white">
          <h4 class="mb-0"><i class="bi bi-person-plus"></i> Tạo người dùng (Admin)</h4>
        </div>
        <div class="card-body">
          <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
          </c:if>
          <c:if test="${not empty success}">
            <div class="alert alert-success">${success}</div>
          </c:if>

          <form method="post" action="${pageContext.request.contextPath}/admin/users/create">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label">Tên đăng nhập</label>
                <input class="form-control" name="username" required />
              </div>
              <div class="col-md-6">
                <label class="form-label">Mật khẩu</label>
                <input type="password" class="form-control" name="password" required />
              </div>
              <div class="col-md-12">
                <label class="form-label">Họ tên</label>
                <input class="form-control" name="fullName" required />
              </div>
              <div class="col-md-4">
                <label class="form-label">Phòng ban</label>
                <select name="deptId" class="form-select" required>
                  <c:forEach items="${departments}" var="d">
                    <option value="${d.id}">${d.name}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Vai trò</label>
                <select name="roleId" class="form-select" required>
                  <c:forEach items="${roles}" var="r">
                    <option value="${r.id}">${r.name} (${r.code})</option>
                  </c:forEach>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Quản lý trực tiếp (tuỳ chọn)</label>
                <select name="managerId" class="form-select">
                  <option value="">-- Không --</option>
                  <c:forEach items="${managers}" var="m">
                    <option value="${m.id}">${m.fullName}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="col-md-12">
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" name="active" id="active" checked>
                  <label class="form-check-label" for="active">Kích hoạt</label>
                </div>
              </div>
            </div>
            <div class="mt-3 d-flex gap-2">
              <button class="btn btn-primary"><i class="bi bi-save"></i> Tạo</button>
              <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary">Về trang chủ</a>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="../../layout/footer.jsp" %>


