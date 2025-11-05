<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Trang chủ" />

<!-- Hero section matching login style -->
<section class="home-hero">
  <div class="home-hero__overlay"></div>
  <div class="home-hero__wrap">
    <div class="home-hero__content">
      <div class="welcome text-white">
        <h1 class="welcome-title">Chào mừng<br/>trở lại</h1>
        <p class="welcome-desc">Hệ thống Quản lý Phép giúp bạn quản lý đơn nghỉ phép hiệu quả, theo dõi số dư, tạo đơn và xem lịch sử.</p>
      </div>
      <div class="glass-card">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <div>
            <h4 class="mb-1"><i class="bi bi-person-circle me-2"></i>${user.displayname}</h4>
            <div class="text-muted small">${user.department.name} • ${user.role.name}</div>
          </div>
        </div>
        <div class="row g-3 mb-3">
          <div class="col-6">
            <div class="mini-stat bg-warning-subtle">
              <div class="mini-icon text-warning"><i class="bi bi-hourglass-split"></i></div>
              <div>
                <div class="h4 mb-0">
                  <c:choose>
                    <c:when test="${user.role.code eq 'ADMIN' or user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">${pendingRequests}</c:when>
                    <c:otherwise>${myPendingRequests}</c:otherwise>
                  </c:choose>
                </div>
                <div class="text-muted small">Đơn chờ duyệt</div>
              </div>
            </div>
          </div>
          <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
            <div class="col-6">
              <div class="mini-stat bg-success-subtle">
                <div class="mini-icon text-success"><i class="bi bi-people"></i></div>
                <div>
                  <div class="h4 mb-0">${totalSubordinates != null ? totalSubordinates : 0}</div>
                  <div class="text-muted small">Cấp dưới</div>
                </div>
              </div>
            </div>
          </c:if>
        </div>
        <div class="row g-2">
          <div class="col-12 col-md-6">
            <a href="${pageContext.request.contextPath}/request/create" class="btn btn-primary w-100 p-3"><i class="bi bi-plus-circle me-2"></i>Tạo đơn nghỉ phép</a>
          </div>
          <div class="col-12 col-md-6">
            <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-primary w-100 p-3"><i class="bi bi-list-ul me-2"></i>Danh sách đơn</a>
          </div>
          <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
            <div class="col-12">
              <a href="${pageContext.request.contextPath}/request/review" class="btn btn-success w-100 p-3"><i class="bi bi-check-circle me-2"></i>Duyệt đơn</a>
            </div>
          </c:if>
        </div>
      </div>
    </div>
  </div>
</section>

    <!-- Quick Stats Cards -->
    <div class="row g-4 mb-4 mt-4">
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

    /* Hero styles to match login */
    /* Softer, readable hero background with gradient instead of photo */
    .home-hero{position:relative;min-height:56vh;background:linear-gradient(135deg,#667eea 0%, #764ba2 60%, #3f3d56 100%);display:flex;align-items:center}
    .home-hero__overlay{position:absolute;inset:0;background:linear-gradient(135deg,rgba(0,0,0,.15) 0%,rgba(0,0,0,.1) 100%)}
    .home-hero__wrap{position:relative;z-index:1;width:100%;padding:40px 20px;display:flex;justify-content:center}
    .home-hero__content{max-width:1200px;width:100%;display:grid;grid-template-columns:1fr 1fr;gap:60px;align-items:center}
    .glass-card{background:rgba(255,255,255,.95);backdrop-filter:blur(20px);border-radius:20px;padding:32px;box-shadow:0 10px 40px rgba(0,0,0,.2)}
    .welcome-title{font-size:3.5rem;font-weight:800;line-height:1.1;margin-bottom:10px}
    .welcome-desc{color:rgba(255,255,255,.9);max-width:520px}
    .mini-stat{display:flex;gap:12px;align-items:center;border-radius:14px;padding:12px 14px}
    .mini-icon{font-size:1.5rem}
    @media (max-width: 992px){.home-hero__content{grid-template-columns:1fr;gap:30px}}
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
