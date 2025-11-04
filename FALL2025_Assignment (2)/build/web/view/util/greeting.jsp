<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Trang chủ" />

<div class="container-fluid">
    <!-- Welcome Section -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm bg-gradient-primary text-white" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h1 class="mb-2">
                                <i class="bi bi-person-circle me-2"></i>
                                Chào mừng, ${user.displayname}!
                            </h1>
                            <p class="mb-1 opacity-75">
                                <i class="bi bi-person-badge me-2"></i>
                                Tài khoản của bạn: <strong>${user.username}</strong>
                            </p>
                            <p class="mb-0 opacity-75">
                                <i class="bi bi-building me-2"></i>
                                Phòng ban: <strong>${user.department.name}</strong>
                            </p>
                        </div>
                        <div class="text-end mt-3 mt-md-0">
                            <span class="badge bg-light text-dark px-3 py-2 fs-6">
                                <i class="bi bi-shield-check me-1"></i>
                                ${user.role.name}
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Stats Cards -->
    <div class="row g-4 mb-4">
        <!-- Card 1: Pending Requests -->
        <div class="col-md-6 col-lg-3">
            <div class="card h-100 border-0 shadow-sm hover-card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div class="card-icon bg-warning bg-opacity-10">
                            <i class="bi bi-hourglass-split text-warning fs-2"></i>
                        </div>
                        <div class="text-end">
                            <h2 class="mb-0 text-primary fw-bold">
                                <c:choose>
                                    <c:when test="${user.role.code eq 'ADMIN' or user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
                                        ${pendingRequests}
                                    </c:when>
                                    <c:otherwise>
                                        ${myPendingRequests}
                                    </c:otherwise>
                                </c:choose>
                            </h2>
                        </div>
                    </div>
                    <h5 class="card-title mb-2">Đơn nghỉ phép chờ duyệt</h5>
                    <p class="text-muted small mb-3">Các đơn đang chờ xử lý</p>
                    <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-primary btn-sm w-100">
                        <i class="bi bi-arrow-right me-1"></i> Xem chi tiết
                    </a>
                </div>
            </div>
        </div>

        <!-- Card 2: Employees on Leave -->
        <c:if test="${user.role.code eq 'ADMIN' or user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
            <div class="col-md-6 col-lg-3">
                <div class="card h-100 border-0 shadow-sm hover-card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="card-icon bg-info bg-opacity-10">
                                <i class="bi bi-people text-info fs-2"></i>
                            </div>
                            <div class="text-end">
                                <h2 class="mb-0 text-primary fw-bold">${employeesOnLeave != null ? employeesOnLeave : 0}</h2>
                            </div>
                        </div>
                        <h5 class="card-title mb-2">Nhân viên đang nghỉ</h5>
                        <p class="text-muted small mb-3">Số nhân viên đã nghỉ phép</p>
                        <a href="${pageContext.request.contextPath}/division/agenda" class="btn btn-outline-info btn-sm w-100">
                            <i class="bi bi-calendar-check me-1"></i> Xem lịch
                        </a>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Card 3: Total Subordinates (Manager/Leader) -->
        <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
            <div class="col-md-6 col-lg-3">
                <div class="card h-100 border-0 shadow-sm hover-card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="card-icon bg-success bg-opacity-10">
                                <i class="bi bi-person-check text-success fs-2"></i>
                            </div>
                            <div class="text-end">
                                <h2 class="mb-0 text-primary fw-bold">${totalSubordinates != null ? totalSubordinates : 0}</h2>
                            </div>
                        </div>
                        <h5 class="card-title mb-2">Tổng số nhân viên</h5>
                        <p class="text-muted small mb-3">Số lượng cấp dưới</p>
                        <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-success btn-sm w-100">
                            <i class="bi bi-list-ul me-1"></i> Xem danh sách
                        </a>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Card 4: Approved Requests (Employee) -->
        <c:if test="${user.role.code eq 'EMPLOYEE'}">
            <div class="col-md-6 col-lg-3">
                <div class="card h-100 border-0 shadow-sm hover-card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="card-icon bg-success bg-opacity-10">
                                <i class="bi bi-check-circle text-success fs-2"></i>
                            </div>
                            <div class="text-end">
                                <h2 class="mb-0 text-primary fw-bold">${myApprovedRequests != null ? myApprovedRequests : 0}</h2>
                            </div>
                        </div>
                        <h5 class="card-title mb-2">Đơn đã duyệt</h5>
                        <p class="text-muted small mb-3">Các đơn đã được phê duyệt</p>
                        <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-success btn-sm w-100">
                            <i class="bi bi-arrow-right me-1"></i> Xem chi tiết
                        </a>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Card 5: Total Users (Admin) -->
        <c:if test="${user.role.code eq 'ADMIN'}">
            <div class="col-md-6 col-lg-3">
                <div class="card h-100 border-0 shadow-sm hover-card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="card-icon bg-primary bg-opacity-10">
                                <i class="bi bi-people-fill text-primary fs-2"></i>
                            </div>
                            <div class="text-end">
                                <h2 class="mb-0 text-primary fw-bold">${totalUsers != null ? totalUsers : 0}</h2>
                            </div>
                        </div>
                        <h5 class="card-title mb-2">Tổng số người dùng</h5>
                        <p class="text-muted small mb-3">Tất cả users trong hệ thống</p>
                        <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-primary btn-sm w-100">
                            <i class="bi bi-graph-up me-1"></i> Xem báo cáo
                        </a>
                    </div>
                </div>
            </div>
        </c:if>
    </div>

    <!-- Quick Actions Section -->
    <div class="row g-4">
        <!-- Left Column: Quick Actions -->
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white border-bottom">
                    <h4 class="mb-0">
                        <i class="bi bi-lightning-charge-fill text-warning me-2"></i>
                        Quản lý đơn nghỉ phép
                    </h4>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <a href="${pageContext.request.contextPath}/request/create" class="btn btn-primary w-100 p-3 d-flex align-items-center justify-content-center">
                                <i class="bi bi-plus-circle-fill fs-4 me-2"></i>
                                <span>Tạo đơn nghỉ phép</span>
                            </a>
                        </div>
                        <div class="col-md-6">
                            <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-primary w-100 p-3 d-flex align-items-center justify-content-center">
                                <i class="bi bi-list-ul fs-4 me-2"></i>
                                <span>Xem danh sách đơn</span>
                            </a>
                        </div>
                        <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
                            <div class="col-md-6">
                                <a href="${pageContext.request.contextPath}/request/review" class="btn btn-success w-100 p-3 d-flex align-items-center justify-content-center">
                                    <i class="bi bi-check-circle-fill fs-4 me-2"></i>
                                    <span>Duyệt đơn</span>
                                </a>
                            </div>
                        </c:if>
                        <div class="col-md-6">
                            <a href="${pageContext.request.contextPath}/balance" class="btn btn-info w-100 p-3 d-flex align-items-center justify-content-center">
                                <i class="bi bi-wallet2 fs-4 me-2"></i>
                                <span>Số dư phép</span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Quick Links -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white border-bottom">
                    <h4 class="mb-0">
                        <i class="bi bi-link-45deg text-primary me-2"></i>
                        Truy cập nhanh
                    </h4>
                </div>
                <div class="card-body">
                    <div class="list-group list-group-flush">
                        <a href="${pageContext.request.contextPath}/dashboard" class="list-group-item list-group-item-action border-0 px-0">
                            <i class="bi bi-speedometer2 text-primary me-2"></i>
                            Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/notifications" class="list-group-item list-group-item-action border-0 px-0">
                            <i class="bi bi-bell text-warning me-2"></i>
                            Thông báo
                            <span class="badge bg-warning rounded-pill float-end" id="notificationCount">0</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/balance" class="list-group-item list-group-item-action border-0 px-0">
                            <i class="bi bi-wallet2 text-success me-2"></i>
                            Số dư phép
                        </a>
                        <c:if test="${user.role.code eq 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/reports" class="list-group-item list-group-item-action border-0 px-0">
                                <i class="bi bi-graph-up text-info me-2"></i>
                                Báo cáo
                            </a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/division/agenda" class="list-group-item list-group-item-action border-0 px-0">
                            <i class="bi bi-calendar-range text-danger me-2"></i>
                            Lịch phép
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    .bg-gradient-primary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    .hover-card {
        transition: all 0.3s ease;
        cursor: pointer;
    }

    .hover-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15) !important;
    }

    .card-icon {
        width: 60px;
        height: 60px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .list-group-item {
        padding: 12px 0;
        transition: all 0.2s ease;
    }

    .list-group-item:hover {
        background-color: #f8f9fa;
        padding-left: 10px;
    }

    .btn {
        transition: all 0.3s ease;
    }

    .btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }
</style>

<script>
$(document).ready(function() {
    // Load notification count
    $.ajax({
        url: '${pageContext.request.contextPath}/api/notifications?action=count',
        type: 'GET',
        success: function(data) {
            const count = data.unreadCount || 0;
            if (count > 0) {
                $('#notificationCount').text(count).show();
            } else {
                $('#notificationCount').hide();
            }
        },
        error: function() {
            $('#notificationCount').hide();
        }
    });
});
</script>

<%@ include file="../layout/footer.jsp" %>
