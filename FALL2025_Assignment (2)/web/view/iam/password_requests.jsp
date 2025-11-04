<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Yêu cầu đổi mật khẩu" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1><i class="bi bi-shield-lock"></i> Yêu cầu đổi mật khẩu</h1>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>
    <c:if test="${not empty msg}">
        <div class="alert alert-success">${msg}</div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Họ tên</th>
                            <th>Ghi chú</th>
                            <th>Thời gian</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${requests}">
                            <tr>
                                <td>${r.id}</td>
                                <td>${r.username}</td>
                                <td>${r.fullName}</td>
                                <td>${r.note}</td>
                                <td><c:out value="${r.createdAt}"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.status == 0}"><span class="badge bg-warning">Chờ</span></c:when>
                                        <c:when test="${r.status == 1}"><span class="badge bg-success">Đã xử lý</span></c:when>
                                        <c:when test="${r.status == 2}"><span class="badge bg-danger">Từ chối</span></c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex gap-2 align-items-center">
                                        <form method="post" class="d-flex gap-2 align-items-center">
                                            <input type="hidden" name="requestId" value="${r.id}" />
                                            <input type="password" name="newPassword" placeholder="Mật khẩu mới" class="form-control form-control-sm" style="width:220px;" />
                                            <input type="hidden" name="action" value="process" />
                                            <button class="btn btn-sm btn-primary" type="submit">Đặt mật khẩu</button>
                                        </form>

                                        <form method="post">
                                            <input type="hidden" name="requestId" value="${r.id}" />
                                            <input type="hidden" name="action" value="resetDefault" />
                                            <button class="btn btn-sm btn-danger" type="submit">Reset về 123</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
