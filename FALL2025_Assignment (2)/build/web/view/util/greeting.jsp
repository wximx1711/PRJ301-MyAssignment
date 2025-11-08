<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Trang chủ" />

<!-- Hero Section - Modern Design -->
<section class="modern-hero">
  <div class="hero-background">
    <div class="hero-gradient"></div>
    <div class="hero-pattern"></div>
  </div>
  
  <div class="container-fluid">
    <div class="row align-items-center min-vh-50">
      <div class="col-lg-6 hero-content-left">
        <div class="hero-badge mb-3">
          <i class="bi bi-calendar-check me-2"></i>
          <span>Hệ thống Quản lý Phép</span>
        </div>
        <h1 class="hero-title">
          Chào mừng trở lại,<br/>
          <span class="text-gradient">${user.displayname}</span>
        </h1>
        <p class="hero-description">
          Quản lý đơn nghỉ phép một cách thông minh và hiệu quả. 
          Theo dõi số dư, tạo đơn nhanh chóng và xem lịch sử nghỉ phép của bạn.
        </p>
        <div class="hero-stats mt-4">
          <div class="stat-item">
            <div class="stat-icon bg-warning-subtle">
              <i class="bi bi-hourglass-split text-warning"></i>
            </div>
            <div class="stat-info">
              <div class="stat-number">
                <c:choose>
                  <c:when test="${user.role.code eq 'ADMIN' or user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">${pendingRequests}</c:when>
                  <c:otherwise>${myPendingRequests}</c:otherwise>
                </c:choose>
              </div>
              <div class="stat-label">Đơn chờ duyệt</div>
            </div>
          </div>
          <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
            <div class="stat-item">
              <div class="stat-icon bg-success-subtle">
                <i class="bi bi-people text-success"></i>
              </div>
              <div class="stat-info">
                <div class="stat-number">${totalSubordinates != null ? totalSubordinates : 0}</div>
                <div class="stat-label">Cấp dưới</div>
              </div>
            </div>
          </c:if>
        </div>
      </div>
      
      <div class="col-lg-6 hero-content-right">
        <div class="hero-card">
          <div class="card-header-modern">
            <div class="user-info">
              <div class="user-avatar">
                <i class="bi bi-person-circle"></i>
              </div>
              <div class="user-details">
                <h5 class="user-name">${user.displayname}</h5>
                <p class="user-role">${user.department.name} • ${user.role.name}</p>
              </div>
            </div>
          </div>
          
          <div class="card-body-modern">
            <h6 class="section-title">Thao tác nhanh</h6>
            <div class="quick-actions-grid">
              <a href="${pageContext.request.contextPath}/request/create" class="action-btn action-primary">
                <div class="action-icon">
                  <i class="bi bi-plus-circle-fill"></i>
                </div>
                <div class="action-text">
                  <span class="action-title">Tạo đơn nghỉ phép</span>
                  <span class="action-desc">Gửi yêu cầu nghỉ phép mới</span>
                </div>
                <i class="bi bi-arrow-right action-arrow"></i>
              </a>
              
              <a href="${pageContext.request.contextPath}/request/list" class="action-btn action-secondary">
                <div class="action-icon">
                  <i class="bi bi-list-ul"></i>
                </div>
                <div class="action-text">
                  <span class="action-title">Danh sách đơn</span>
                  <span class="action-desc">Xem tất cả đơn nghỉ phép</span>
                </div>
                <i class="bi bi-arrow-right action-arrow"></i>
              </a>
              
              <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/request/review" class="action-btn action-success">
                  <div class="action-icon">
                    <i class="bi bi-check-circle-fill"></i>
                  </div>
                  <div class="action-text">
                    <span class="action-title">Duyệt đơn</span>
                    <span class="action-desc">Xem và duyệt đơn nghỉ phép</span>
                  </div>
                  <i class="bi bi-arrow-right action-arrow"></i>
                </a>
              </c:if>
              
              <a href="${pageContext.request.contextPath}/balance" class="action-btn action-info">
                <div class="action-icon">
                  <i class="bi bi-wallet2"></i>
                </div>
                <div class="action-text">
                  <span class="action-title">Số dư phép</span>
                  <span class="action-desc">Kiểm tra số ngày phép còn lại</span>
                </div>
                <i class="bi bi-arrow-right action-arrow"></i>
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Bottom Navigation Section -->
<section class="bottom-nav-section">
  <div class="container-fluid">
    <div class="bottom-nav">
      <a href="${pageContext.request.contextPath}/home" class="nav-item active">
        <i class="bi bi-house"></i>
        <span>Trang chủ</span>
      </a>
      <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
        <i class="bi bi-speedometer2"></i>
        <span>Dashboard</span>
      </a>
      <a href="${pageContext.request.contextPath}/request/list" class="nav-item">
        <i class="bi bi-list-ul"></i>
        <span>Đơn nghỉ phép</span>
      </a>
      <a href="${pageContext.request.contextPath}/request/create" class="nav-item">
        <i class="bi bi-plus-circle"></i>
        <span>Tạo đơn</span>
      </a>
      <a href="${pageContext.request.contextPath}/balance" class="nav-item">
        <i class="bi bi-wallet2"></i>
        <span>Số dư phép</span>
      </a>
      <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
        <a href="${pageContext.request.contextPath}/request/review" class="nav-item">
          <i class="bi bi-check-circle"></i>
          <span>Duyệt đơn</span>
        </a>
      </c:if>
      <c:if test="${user.role.code eq 'ADMIN'}">
        <a href="${pageContext.request.contextPath}/reports" class="nav-item">
          <i class="bi bi-graph-up"></i>
          <span>Báo cáo</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/users/create" class="nav-item">
          <i class="bi bi-person-plus"></i>
          <span>Tạo user</span>
        </a>
      </c:if>
      <div class="nav-item nav-user">
        <div class="user-menu-trigger">
          <i class="bi bi-person-circle"></i>
          <span>${user.displayname}</span>
          <i class="bi bi-chevron-down"></i>
        </div>
        <div class="user-menu-dropdown">
          <a href="${pageContext.request.contextPath}/notifications" class="menu-item">
            <i class="bi bi-bell"></i>
            <span>Thông báo</span>
            <span class="badge bg-warning rounded-pill" id="notificationCount">0</span>
          </a>
          <a href="${pageContext.request.contextPath}/profile" class="menu-item">
            <i class="bi bi-person"></i>
            <span>Hồ sơ</span>
          </a>
          <a href="${pageContext.request.contextPath}/settings" class="menu-item">
            <i class="bi bi-gear"></i>
            <span>Cài đặt</span>
          </a>
          <c:if test="${user.role.code eq 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/iam/password-requests" class="menu-item">
              <i class="bi bi-shield-lock"></i>
              <span>Service</span>
            </a>
          </c:if>
          <hr class="menu-divider">
          <a href="${pageContext.request.contextPath}/logout" class="menu-item menu-item-danger">
            <i class="bi bi-box-arrow-right"></i>
            <span>Đăng xuất</span>
          </a>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Stats Cards Section - Modern Design -->
<section class="stats-section">
  <div class="container-fluid">
    <div class="section-header mb-4">
      <h2 class="section-title-modern">Thống kê tổng quan</h2>
      <p class="section-subtitle">Tổng hợp các chỉ số quan trọng của hệ thống</p>
    </div>

    <div class="row g-4">
      <!-- Card 1: Pending Requests -->
      <div class="col-md-6 col-lg-3">
        <div class="stat-card stat-card-warning">
          <div class="stat-card-header">
            <div class="stat-card-icon">
              <i class="bi bi-hourglass-split"></i>
            </div>
            <div class="stat-card-trend">
              <i class="bi bi-arrow-up"></i>
            </div>
          </div>
          <div class="stat-card-body">
            <div class="stat-card-number">
              <c:choose>
                <c:when test="${user.role.code eq 'ADMIN' or user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
                  ${pendingRequests}
                </c:when>
                <c:otherwise>
                  ${myPendingRequests}
                </c:otherwise>
              </c:choose>
            </div>
            <div class="stat-card-label">Đơn chờ duyệt</div>
            <div class="stat-card-desc">Các đơn đang chờ xử lý</div>
          </div>
          <div class="stat-card-footer">
            <a href="${pageContext.request.contextPath}/request/list" class="stat-card-link">
              Xem chi tiết <i class="bi bi-arrow-right"></i>
            </a>
          </div>
        </div>
      </div>

      <!-- Card 2: Employees on Leave -->
      <c:if test="${user.role.code eq 'ADMIN' or user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
        <div class="col-md-6 col-lg-3">
          <div class="stat-card stat-card-info">
            <div class="stat-card-header">
              <div class="stat-card-icon">
                <i class="bi bi-people"></i>
              </div>
              <div class="stat-card-trend">
                <i class="bi bi-arrow-up"></i>
              </div>
            </div>
            <div class="stat-card-body">
              <div class="stat-card-number">${employeesOnLeave != null ? employeesOnLeave : 0}</div>
              <div class="stat-card-label">Nhân viên đang nghỉ</div>
              <div class="stat-card-desc">Số nhân viên đã nghỉ phép</div>
            </div>
            <div class="stat-card-footer">
              <a href="${pageContext.request.contextPath}/division/agenda" class="stat-card-link">
                Xem lịch <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
      </c:if>

      <!-- Card 3: Total Subordinates (Manager/Leader) -->
      <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
        <div class="col-md-6 col-lg-3">
          <div class="stat-card stat-card-success">
            <div class="stat-card-header">
              <div class="stat-card-icon">
                <i class="bi bi-person-check"></i>
              </div>
              <div class="stat-card-trend">
                <i class="bi bi-arrow-up"></i>
              </div>
            </div>
            <div class="stat-card-body">
              <div class="stat-card-number">${totalSubordinates != null ? totalSubordinates : 0}</div>
              <div class="stat-card-label">Tổng số nhân viên</div>
              <div class="stat-card-desc">Số lượng cấp dưới</div>
            </div>
            <div class="stat-card-footer">
              <a href="${pageContext.request.contextPath}/request/list" class="stat-card-link">
                Xem danh sách <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
      </c:if>

      <!-- Card 4: Approved Requests (Employee) -->
      <c:if test="${user.role.code eq 'EMPLOYEE'}">
        <div class="col-md-6 col-lg-3">
          <div class="stat-card stat-card-success">
            <div class="stat-card-header">
              <div class="stat-card-icon">
                <i class="bi bi-check-circle"></i>
              </div>
              <div class="stat-card-trend">
                <i class="bi bi-arrow-up"></i>
              </div>
            </div>
            <div class="stat-card-body">
              <div class="stat-card-number">${myApprovedRequests != null ? myApprovedRequests : 0}</div>
              <div class="stat-card-label">Đơn đã duyệt</div>
              <div class="stat-card-desc">Các đơn đã được phê duyệt</div>
            </div>
            <div class="stat-card-footer">
              <a href="${pageContext.request.contextPath}/request/list" class="stat-card-link">
                Xem chi tiết <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
      </c:if>

      <!-- Card 5: Total Users (Admin) -->
      <c:if test="${user.role.code eq 'ADMIN'}">
        <div class="col-md-6 col-lg-3">
          <div class="stat-card stat-card-primary">
            <div class="stat-card-header">
              <div class="stat-card-icon">
                <i class="bi bi-people-fill"></i>
              </div>
              <div class="stat-card-trend">
                <i class="bi bi-arrow-up"></i>
              </div>
            </div>
            <div class="stat-card-body">
              <div class="stat-card-number">${totalUsers != null ? totalUsers : 0}</div>
              <div class="stat-card-label">Tổng số người dùng</div>
              <div class="stat-card-desc">Tất cả users trong hệ thống</div>
            </div>
            <div class="stat-card-footer">
              <a href="${pageContext.request.contextPath}/reports" class="stat-card-link">
                Xem báo cáo <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</section>
            
<!-- Quick Actions Section - Part 3 -->
<section class="quick-actions-section">
  <div class="container-fluid">
    <div class="section-header mb-4">
      <h2 class="section-title-modern">Thao tác nhanh</h2>
      <p class="section-subtitle">Truy cập các tính năng quan trọng một cách nhanh chóng</p>
    </div>
    
    <div class="row g-4">
      <!-- Main Actions Grid -->
      <div class="col-lg-8">
        <div class="actions-grid">
          <a href="${pageContext.request.contextPath}/request/create" class="action-card action-card-primary">
            <div class="action-card-icon">
              <i class="bi bi-plus-circle-fill"></i>
            </div>
            <div class="action-card-content">
              <h5 class="action-card-title">Tạo đơn nghỉ phép</h5>
              <p class="action-card-desc">Gửi yêu cầu nghỉ phép mới</p>
            </div>
            <div class="action-card-arrow">
              <i class="bi bi-arrow-right"></i>
            </div>
          </a>
          
          <a href="${pageContext.request.contextPath}/request/list" class="action-card action-card-secondary">
            <div class="action-card-icon">
              <i class="bi bi-list-ul"></i>
            </div>
            <div class="action-card-content">
              <h5 class="action-card-title">Danh sách đơn</h5>
              <p class="action-card-desc">Xem tất cả đơn nghỉ phép</p>
            </div>
            <div class="action-card-arrow">
              <i class="bi bi-arrow-right"></i>
            </div>
          </a>
          
          <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/request/review" class="action-card action-card-success">
              <div class="action-card-icon">
                <i class="bi bi-check-circle-fill"></i>
              </div>
              <div class="action-card-content">
                <h5 class="action-card-title">Duyệt đơn</h5>
                <p class="action-card-desc">Xem và duyệt đơn nghỉ phép</p>
              </div>
              <div class="action-card-arrow">
                <i class="bi bi-arrow-right"></i>
              </div>
            </a>
          </c:if>
          
          <a href="${pageContext.request.contextPath}/balance" class="action-card action-card-info">
            <div class="action-card-icon">
              <i class="bi bi-wallet2"></i>
            </div>
            <div class="action-card-content">
              <h5 class="action-card-title">Số dư phép</h5>
              <p class="action-card-desc">Kiểm tra số ngày phép còn lại</p>
            </div>
            <div class="action-card-arrow">
              <i class="bi bi-arrow-right"></i>
            </div>
          </a>
        </div>
      </div>
      
      <!-- Quick Links Sidebar -->
      <div class="col-lg-4">
        <div class="quick-links-card">
          <div class="quick-links-header">
            <h5 class="quick-links-title">
              <i class="bi bi-link-45deg me-2"></i>
              Truy cập nhanh
            </h5>
          </div>
          <div class="quick-links-body">
            <a href="${pageContext.request.contextPath}/dashboard" class="quick-link-item">
              <div class="quick-link-icon bg-primary-subtle">
                <i class="bi bi-speedometer2 text-primary"></i>
              </div>
              <span class="quick-link-text">Dashboard</span>
              <i class="bi bi-chevron-right quick-link-arrow"></i>
            </a>
            
            <a href="${pageContext.request.contextPath}/notifications" class="quick-link-item">
              <div class="quick-link-icon bg-warning-subtle">
                <i class="bi bi-bell text-warning"></i>
              </div>
              <span class="quick-link-text">Thông báo</span>
              <span class="badge bg-warning rounded-pill ms-auto" id="notificationCountSidebar">0</span>
              <i class="bi bi-chevron-right quick-link-arrow"></i>
            </a>
            
            <a href="${pageContext.request.contextPath}/balance" class="quick-link-item">
              <div class="quick-link-icon bg-success-subtle">
                <i class="bi bi-wallet2 text-success"></i>
              </div>
              <span class="quick-link-text">Số dư phép</span>
              <i class="bi bi-chevron-right quick-link-arrow"></i>
            </a>
            
            <c:if test="${user.role.code eq 'ADMIN'}">
              <a href="${pageContext.request.contextPath}/reports" class="quick-link-item">
                <div class="quick-link-icon bg-info-subtle">
                  <i class="bi bi-graph-up text-info"></i>
                </div>
                <span class="quick-link-text">Báo cáo</span>
                <i class="bi bi-chevron-right quick-link-arrow"></i>
              </a>
            </c:if>
            
            <a href="${pageContext.request.contextPath}/division/agenda" class="quick-link-item">
              <div class="quick-link-icon bg-danger-subtle">
                <i class="bi bi-calendar-range text-danger"></i>
              </div>
              <span class="quick-link-text">Lịch phép</span>
              <i class="bi bi-chevron-right quick-link-arrow"></i>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

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

    /* ============================================
       MODERN HERO SECTION - PART 1
       ============================================ */
    .modern-hero {
        position: relative;
        min-height: 70vh;
        padding: 60px 0;
        overflow: hidden;
        font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
    }
    
    .hero-background {
        position: absolute;
        inset: 0;
        z-index: 0;
    }
    
    .hero-gradient {
        position: absolute;
        inset: 0;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #667eea 100%);
        background-size: 200% 200%;
        animation: gradientShift 15s ease infinite;
    }
    
    @keyframes gradientShift {
        0%, 100% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
    }
    
    .hero-pattern {
        position: absolute;
        inset: 0;
        background-image: 
            radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
            radial-gradient(circle at 80% 80%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
        opacity: 0.5;
    }
    
    .modern-hero .container-fluid {
        position: relative;
        z-index: 1;
    }
    
    .min-vh-50 {
        min-height: 50vh;
    }
    
    /* Hero Content Left */
    .hero-content-left {
        color: #fff;
        padding: 40px 20px;
    }
    
    .hero-badge {
        display: inline-flex;
        align-items: center;
        padding: 8px 16px;
        background: rgba(255, 255, 255, 0.15);
        backdrop-filter: blur(10px);
        border-radius: 50px;
        font-size: 0.875rem;
        font-weight: 600;
        color: #fff;
        border: 1px solid rgba(255, 255, 255, 0.2);
    }
    
    .hero-title {
        font-size: 3.5rem;
        font-weight: 800;
        line-height: 1.2;
        margin: 24px 0;
        color: #fff;
        font-family: 'Inter', sans-serif !important;
    }
    
    .text-gradient {
        background: linear-gradient(135deg, #ffd700 0%, #ff6600 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    .hero-description {
        font-size: 1.125rem;
        line-height: 1.8;
        color: rgba(255, 255, 255, 0.9);
        max-width: 540px;
        margin-bottom: 32px;
    }
    
    /* Hero Stats */
    .hero-stats {
        display: flex;
        gap: 24px;
        flex-wrap: wrap;
    }
    
    .stat-item {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px 20px;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
        border-radius: 16px;
        border: 1px solid rgba(255, 255, 255, 0.2);
        transition: all 0.3s ease;
    }
    
    .stat-item:hover {
        background: rgba(255, 255, 255, 0.15);
        transform: translateY(-2px);
    }
    
    .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
    }
    
    .stat-info {
        display: flex;
        flex-direction: column;
    }
    
    .stat-number {
        font-size: 1.75rem;
        font-weight: 700;
        color: #fff;
        line-height: 1;
    }
    
    .stat-label {
        font-size: 0.875rem;
        color: rgba(255, 255, 255, 0.8);
        margin-top: 4px;
    }
    
    /* Hero Content Right - Card */
    .hero-content-right {
        padding: 40px 20px;
    }
    
    .hero-card {
        background: rgba(255, 255, 255, 0.98);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border-radius: 24px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
        border: 1px solid rgba(255, 255, 255, 0.5);
        overflow: hidden;
        transition: all 0.3s ease;
    }
    
    .hero-card:hover {
        box-shadow: 0 25px 80px rgba(0, 0, 0, 0.2);
        transform: translateY(-4px);
    }
    
    .card-header-modern {
        padding: 24px;
        background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
        border-bottom: 1px solid rgba(0, 0, 0, 0.05);
    }
    
    .user-info {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    
    .user-avatar {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        font-size: 1.75rem;
    }
    
    .user-details {
        flex: 1;
    }
    
    .user-name {
        font-size: 1.125rem;
        font-weight: 700;
        color: #1a1a1a;
        margin: 0;
    }
    
    .user-role {
        font-size: 0.875rem;
        color: #6c757d;
        margin: 4px 0 0 0;
    }
    
    .card-body-modern {
        padding: 24px;
    }
    
    .section-title {
        font-size: 0.875rem;
        font-weight: 600;
        color: #6c757d;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 20px;
    }
    
    /* Quick Actions Grid */
    .quick-actions-grid {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    
    .action-btn {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px 20px;
        border-radius: 14px;
        text-decoration: none;
        transition: all 0.3s ease;
        border: 1px solid transparent;
        position: relative;
        overflow: hidden;
    }
    
    .action-btn::before {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(135deg, transparent 0%, rgba(255, 255, 255, 0.1) 100%);
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .action-btn:hover::before {
        opacity: 1;
    }
    
    .action-btn:hover {
        transform: translateX(4px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
    
    .action-primary {
        background: linear-gradient(135deg, #ff6600 0%, #e65100 100%);
        color: #fff;
    }
    
    .action-primary:hover {
        background: linear-gradient(135deg, #e65100 0%, #cc4400 100%);
        color: #fff;
    }
    
    .action-secondary {
        background: #f8f9fa;
        color: #667eea;
        border-color: #e9ecef;
    }
    
    .action-secondary:hover {
        background: #e9ecef;
        color: #667eea;
    }
    
    .action-success {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: #fff;
    }
    
    .action-success:hover {
        background: linear-gradient(135deg, #059669 0%, #047857 100%);
        color: #fff;
    }
    
    .action-info {
        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        color: #fff;
    }
    
    .action-info:hover {
        background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
        color: #fff;
    }
    
    .action-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        flex-shrink: 0;
    }
    
    .action-primary .action-icon {
        background: rgba(255, 255, 255, 0.2);
    }
    
    .action-secondary .action-icon {
        background: rgba(102, 126, 234, 0.1);
    }
    
    .action-success .action-icon,
    .action-info .action-icon {
        background: rgba(255, 255, 255, 0.2);
    }
    
    .action-text {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    
    .action-title {
        font-size: 1rem;
        font-weight: 600;
        display: block;
    }
    
    .action-desc {
        font-size: 0.875rem;
        opacity: 0.8;
        display: block;
    }
    
    .action-arrow {
        font-size: 1.25rem;
        opacity: 0.6;
        transition: all 0.3s ease;
    }
    
    .action-btn:hover .action-arrow {
        opacity: 1;
        transform: translateX(4px);
    }
    
    /* Responsive */
    @media (max-width: 992px) {
        .hero-title {
            font-size: 2.5rem;
        }
        
        .hero-stats {
            flex-direction: column;
        }
        
        .hero-content-left,
        .hero-content-right {
            padding: 20px;
        }
    }
    
    @media (max-width: 768px) {
        .modern-hero {
            min-height: auto;
            padding: 40px 0;
        }
        
        .hero-title {
            font-size: 2rem;
        }
        
        .hero-description {
            font-size: 1rem;
        }
    }
    
    /* ============================================
       STATS CARDS SECTION - PART 2
       ============================================ */
    .stats-section {
        padding: 60px 0;
        background: #f8f9fa;
        font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
    }
    
    .section-header {
        text-align: center;
        margin-bottom: 48px;
    }
    
    .section-title-modern {
        font-size: 2rem;
        font-weight: 700;
        color: #1a1a1a;
        margin-bottom: 8px;
        font-family: 'Inter', sans-serif !important;
    }
    
    .section-subtitle {
        font-size: 1rem;
        color: #6c757d;
        margin: 0;
    }
    
    /* Stat Card Base */
    .stat-card {
        background: #fff;
        border-radius: 20px;
        padding: 24px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        border: 1px solid rgba(0, 0, 0, 0.05);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
        height: 100%;
        display: flex;
        flex-direction: column;
    }
    
    .stat-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, transparent, currentColor, transparent);
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .stat-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
    }
    
    .stat-card:hover::before {
        opacity: 1;
    }
    
    /* Stat Card Variants */
    .stat-card-warning {
        border-top: 4px solid #f59e0b;
    }
    
    .stat-card-warning .stat-card-icon {
        background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
        color: #f59e0b;
    }
    
    .stat-card-info {
        border-top: 4px solid #3b82f6;
    }
    
    .stat-card-info .stat-card-icon {
        background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
        color: #3b82f6;
    }
    
    .stat-card-success {
        border-top: 4px solid #10b981;
    }
    
    .stat-card-success .stat-card-icon {
        background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
        color: #10b981;
    }
    
    .stat-card-primary {
        border-top: 4px solid #667eea;
    }
    
    .stat-card-primary .stat-card-icon {
        background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
        color: #667eea;
    }
    
    /* Stat Card Header */
    .stat-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }
    
    .stat-card-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        transition: all 0.3s ease;
    }
    
    .stat-card:hover .stat-card-icon {
        transform: scale(1.1) rotate(5deg);
    }
    
    .stat-card-trend {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        background: rgba(0, 0, 0, 0.05);
        display: flex;
        align-items: center;
        justify-content: center;
        color: #10b981;
        font-size: 0.875rem;
    }
    
    /* Stat Card Body */
    .stat-card-body {
        flex: 1;
        margin-bottom: 20px;
    }
    
    .stat-card-number {
        font-size: 2.5rem;
        font-weight: 800;
        color: #1a1a1a;
        line-height: 1;
        margin-bottom: 8px;
        font-family: 'Inter', sans-serif !important;
    }
    
    .stat-card-label {
        font-size: 1rem;
        font-weight: 600;
        color: #1a1a1a;
        margin-bottom: 4px;
    }
    
    .stat-card-desc {
        font-size: 0.875rem;
        color: #6c757d;
        line-height: 1.5;
    }
    
    /* Stat Card Footer */
    .stat-card-footer {
        padding-top: 16px;
        border-top: 1px solid rgba(0, 0, 0, 0.05);
    }
    
    .stat-card-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-size: 0.875rem;
        font-weight: 600;
        color: #667eea;
        text-decoration: none;
        transition: all 0.3s ease;
    }
    
    .stat-card-link:hover {
        color: #ff6600;
        gap: 12px;
    }
    
    .stat-card-link i {
        transition: transform 0.3s ease;
    }
    
    .stat-card-link:hover i {
        transform: translateX(4px);
    }
    
    /* Responsive */
    @media (max-width: 992px) {
        .stats-section {
            padding: 40px 0;
        }
        
        .section-title-modern {
            font-size: 1.75rem;
        }
        
        .stat-card-number {
            font-size: 2rem;
        }
    }
    
    @media (max-width: 768px) {
        .stats-section {
            padding: 32px 0;
        }
        
        .section-header {
            margin-bottom: 32px;
        }
        
        .section-title-modern {
            font-size: 1.5rem;
        }
        
        .stat-card {
            padding: 20px;
        }
        
        .stat-card-icon {
            width: 48px;
            height: 48px;
            font-size: 1.25rem;
        }
        
        .stat-card-number {
            font-size: 1.75rem;
        }
    }
    
    /* ============================================
       BOTTOM NAVIGATION SECTION
       ============================================ */
    .bottom-nav-section {
        padding: 20px 0;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        box-shadow: 0 -4px 20px rgba(102, 126, 234, 0.3);
        font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
    }
    
    .bottom-nav {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        flex-wrap: wrap;
        padding: 0 20px;
    }
    
    .bottom-nav .nav-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 4px;
        padding: 12px 16px;
        color: rgba(255, 255, 255, 0.8);
        text-decoration: none;
        border-radius: 12px;
        transition: all 0.3s ease;
        font-size: 0.875rem;
        font-weight: 500;
        min-width: 80px;
    }
    
    .bottom-nav .nav-item i {
        font-size: 1.25rem;
    }
    
    .bottom-nav .nav-item span {
        font-size: 0.75rem;
    }
    
    .bottom-nav .nav-item:hover,
    .bottom-nav .nav-item.active {
        background: rgba(255, 255, 255, 0.15);
        color: #fff;
        transform: translateY(-2px);
    }
    
    .bottom-nav .nav-user {
        position: relative;
        margin-left: auto;
    }
    
    .user-menu-trigger {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px 16px;
        color: rgba(255, 255, 255, 0.9);
        cursor: pointer;
        border-radius: 12px;
        transition: all 0.3s ease;
        font-size: 0.875rem;
        font-weight: 500;
    }
    
    .user-menu-trigger:hover {
        background: rgba(255, 255, 255, 0.15);
        color: #fff;
    }
    
    .user-menu-dropdown {
        position: absolute;
        bottom: 100%;
        right: 0;
        margin-bottom: 8px;
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
        min-width: 200px;
        opacity: 0;
        visibility: hidden;
        transform: translateY(10px);
        transition: all 0.3s ease;
        z-index: 1000;
        padding: 8px;
    }
    
    .nav-user:hover .user-menu-dropdown {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }
    
    .menu-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        color: #1a1a1a;
        text-decoration: none;
        border-radius: 8px;
        transition: all 0.2s ease;
        font-size: 0.875rem;
        font-weight: 500;
    }
    
    .menu-item:hover {
        background: #f8f9fa;
        color: #667eea;
    }
    
    .menu-item i {
        width: 20px;
        text-align: center;
    }
    
    .menu-item .badge {
        margin-left: auto;
    }
    
    .menu-item-danger {
        color: #dc3545;
    }
    
    .menu-item-danger:hover {
        background: #fee;
        color: #dc3545;
    }
    
    .menu-divider {
        margin: 8px 0;
        border: none;
        border-top: 1px solid #e9ecef;
    }
    
    /* ============================================
       QUICK ACTIONS SECTION - PART 3
       ============================================ */
    .quick-actions-section {
        padding: 60px 0;
        background: #fff;
        font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
    }
    
    .actions-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
    }
    
    .action-card {
        display: flex;
        align-items: center;
        gap: 20px;
        padding: 24px;
        border-radius: 16px;
        text-decoration: none;
        transition: all 0.3s ease;
        border: 1px solid rgba(0, 0, 0, 0.05);
        position: relative;
        overflow: hidden;
    }
    
    .action-card::before {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(135deg, transparent 0%, rgba(255, 255, 255, 0.1) 100%);
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .action-card:hover::before {
        opacity: 1;
    }
    
    .action-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
    }
    
    .action-card-primary {
        background: linear-gradient(135deg, #ff6600 0%, #e65100 100%);
        color: #fff;
    }
    
    .action-card-secondary {
        background: #f8f9fa;
        color: #667eea;
        border-color: #e9ecef;
    }
    
    .action-card-success {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: #fff;
    }
    
    .action-card-info {
        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        color: #fff;
    }
    
    .action-card-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        flex-shrink: 0;
    }
    
    .action-card-primary .action-card-icon,
    .action-card-success .action-card-icon,
    .action-card-info .action-card-icon {
        background: rgba(255, 255, 255, 0.2);
    }
    
    .action-card-secondary .action-card-icon {
        background: rgba(102, 126, 234, 0.1);
        color: #667eea;
    }
    
    .action-card-content {
        flex: 1;
    }
    
    .action-card-title {
        font-size: 1.125rem;
        font-weight: 700;
        margin: 0 0 4px 0;
        color: inherit;
    }
    
    .action-card-desc {
        font-size: 0.875rem;
        opacity: 0.8;
        margin: 0;
        color: inherit;
    }
    
    .action-card-arrow {
        font-size: 1.25rem;
        opacity: 0.6;
        transition: all 0.3s ease;
    }
    
    .action-card:hover .action-card-arrow {
        opacity: 1;
        transform: translateX(4px);
    }
    
    /* Quick Links Card */
    .quick-links-card {
        background: #fff;
        border-radius: 20px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        border: 1px solid rgba(0, 0, 0, 0.05);
        overflow: hidden;
    }
    
    .quick-links-header {
        padding: 20px 24px;
        background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
        border-bottom: 1px solid rgba(0, 0, 0, 0.05);
    }
    
    .quick-links-title {
        font-size: 1rem;
        font-weight: 700;
        color: #1a1a1a;
        margin: 0;
        display: flex;
        align-items: center;
    }
    
    .quick-links-body {
        padding: 16px;
    }
    
    .quick-link-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        border-radius: 12px;
        text-decoration: none;
        color: #1a1a1a;
        transition: all 0.2s ease;
        margin-bottom: 4px;
    }
    
    .quick-link-item:hover {
        background: #f8f9fa;
        color: #667eea;
    }
    
    .quick-link-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.125rem;
        flex-shrink: 0;
    }
    
    .quick-link-text {
        flex: 1;
        font-size: 0.875rem;
        font-weight: 500;
    }
    
    .quick-link-arrow {
        font-size: 0.875rem;
        color: #6c757d;
        transition: all 0.2s ease;
    }
    
    .quick-link-item:hover .quick-link-arrow {
        color: #667eea;
        transform: translateX(4px);
    }
    
    /* Responsive */
    @media (max-width: 992px) {
        .quick-actions-section {
            padding: 40px 0;
        }
        
        .actions-grid {
            grid-template-columns: 1fr;
        }
        
        .bottom-nav {
            justify-content: flex-start;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }
        
        .bottom-nav .nav-item {
            min-width: 70px;
        }
        
        .nav-user {
            margin-left: 0;
        }
    }
    
    @media (max-width: 768px) {
        .quick-actions-section {
            padding: 32px 0;
        }
        
        .action-card {
            padding: 20px;
        }
        
        .action-card-icon {
            width: 48px;
            height: 48px;
            font-size: 1.25rem;
        }
        
        .bottom-nav .nav-item span {
            display: none;
        }
        
        .bottom-nav .nav-item {
            min-width: 50px;
            padding: 12px;
        }
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
                $('#notificationCountSidebar').text(count).show();
            } else {
                $('#notificationCount').hide();
                $('#notificationCountSidebar').hide();
            }
        },
        error: function() {
            $('#notificationCount').hide();
            $('#notificationCountSidebar').hide();
        }
    });
    
    // Set active nav item based on current URL
    const currentPath = window.location.pathname;
    $('.bottom-nav .nav-item').each(function() {
        const href = $(this).attr('href');
        if (href && currentPath.includes(href.split('/').pop())) {
            $(this).addClass('active');
        }
    });
});
</script>

<%@ include file="../layout/footer.jsp" %>
