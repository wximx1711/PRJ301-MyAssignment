<%-- header.jsp intentionally has no page directive to avoid duplicate contentType conflicts when included --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    model.iam.User user = (model.iam.User) session.getAttribute("user");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:if test="${not empty pageTitle}">${pageTitle} - </c:if>EzLeave</title>
    
    <!-- Google Fonts (Inter) - Load first for better font rendering -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />
    <!-- FullCalendar CSS -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.css" rel="stylesheet" />
    <!-- Toastr CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Moment.js -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/moment.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/locale/vi.min.js"></script>
    <!-- Toastr JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
    <!-- SweetAlert2 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.7.3/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.7.3/dist/sweetalert2.all.min.js"></script>
    <!-- Clipboard.js -->
    <script src="https://cdn.jsdelivr.net/npm/clipboard@2.0.11/dist/clipboard.min.js"></script>
    <!-- zxcvbn (password strength) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/zxcvbn/4.4.2/zxcvbn.js"></script>
    <!-- Choices.js (better select UI) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/choices.js/public/assets/styles/choices.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/choices.js/public/assets/scripts/choices.min.js"></script>
</head>
<body>
    <style>
      /* Đảm bảo Inter font được load và áp dụng cho toàn bộ, fix encoding tiếng Việt */
      @font-face {
        font-family: 'Inter';
        font-style: normal;
        font-weight: 400 800;
        font-display: swap;
        src: url('https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfAZ9hiJ-Ek-_EeA.woff2') format('woff2');
        unicode-range: U+0102-0103, U+0110-0111, U+0128-0129, U+0168-0169, U+01A0-01A1, U+01AF-01B0, U+0300-0301, U+0303-0304, U+0308-0309, U+0323, U+0329, U+1EA0-1EF9, U+20AB;
      }
      
      body, html {
        font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-rendering: optimizeLegibility;
        font-feature-settings: "liga" 1, "kern" 1;
      }
      
      /* Navbar gradient giống login - override Bootstrap mạnh */
      .navbar.bg-primary,
      nav.navbar.navbar-expand-lg.navbar-dark.bg-primary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
        background-color: transparent !important;
        backdrop-filter: saturate(180%) blur(10px) !important;
        -webkit-backdrop-filter: saturate(180%) blur(10px) !important;
        box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3) !important;
        border: none !important;
      }
      
      /* Fix font cho navbar và tất cả elements - override mạnh với UTF-8 support */
      .navbar,
      .navbar *,
      .nav-link,
      .navbar-brand,
      .dropdown-menu,
      .dropdown-item,
      .navbar-nav,
      .navbar-nav *,
      nav.navbar *,
      nav.navbar .nav-link,
      nav.navbar .navbar-brand,
      nav.navbar .btn {
        font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
        font-weight: 500 !important;
        letter-spacing: 0.01em !important;
        text-rendering: optimizeLegibility !important;
        -webkit-font-smoothing: antialiased !important;
        -moz-osx-font-smoothing: grayscale !important;
        font-feature-settings: "liga" 1, "kern" 1 !important;
        unicode-bidi: embed !important;
      }
      
      /* Đảm bảo text trong navbar hiển thị đúng UTF-8 */
      .navbar .nav-link,
      .navbar .navbar-brand,
      .navbar .btn {
        color: #fff !important;
        text-decoration: none !important;
        font-variant-ligatures: common-ligatures;
      }
      
      .navbar .nav-link:hover,
      .navbar .navbar-brand:hover {
        color: rgba(255, 255, 255, 0.9) !important;
        background-color: rgba(255, 255, 255, 0.1) !important;
        border-radius: 8px !important;
        transition: all 0.3s ease !important;
      }
    </style>
    <!-- Navbar hidden - moved to bottom navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary" style="display: none !important;">
    </nav>
    
    <main class="container-fluid p-0">
        <div class="row g-0">
            <div class="col-12">
