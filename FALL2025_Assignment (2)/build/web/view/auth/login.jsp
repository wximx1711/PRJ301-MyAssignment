<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%
    String msg = (String) request.getAttribute("msg");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Leave Management System</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts (Inter) -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Toastr CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            text-rendering: optimizeLegibility;
        }
        
        .login-container {
            min-height: 100vh;
            display: flex;
            position: relative;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            background-image: url('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
        }
        
        .login-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(0, 0, 0, 0.5) 0%, rgba(0, 0, 0, 0.3) 100%);
        }
        
        .login-wrapper {
            position: relative;
            z-index: 1;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }
        
        .login-content {
            max-width: 1200px;
            width: 100%;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: center;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 30px;
            padding: 60px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        /* Left Section - Welcome */
        .welcome-section {
            color: white;
        }
        
        .welcome-title {
            font-size: 4rem;
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 30px;
            color: white;
        }
        
        .welcome-description {
            font-size: 1.1rem;
            line-height: 1.8;
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 40px;
            max-width: 500px;
        }
        
        .welcome-description .highlight {
            color: #ff6600;
        }
        
        .social-icons {
            display: flex;
            gap: 20px;
            margin-top: 50px;
        }
        
        .social-icon {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.2rem;
            text-decoration: none;
            transition: all 0.3s;
            border: 2px solid rgba(255, 255, 255, 0.2);
        }
        
        .social-icon:hover {
            background: rgba(255, 102, 0, 0.8);
            border-color: #ff6600;
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(255, 102, 0, 0.4);
        }
        
        /* Right Section - Login Form */
        .login-form-section {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 50px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
        }
        
        .form-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 10px;
        }
        
        .form-subtitle {
            color: #666;
            font-size: 0.95rem;
            margin-bottom: 35px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 10px;
            color: #333;
            font-weight: 600;
            font-size: 0.95rem;
        }
        
        .form-control {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s;
            background: white;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #ff6600;
            box-shadow: 0 0 0 4px rgba(255, 102, 0, 0.1);
        }
        
        .form-check {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 25px;
        }
        
        .form-check-input {
            width: 20px;
            height: 20px;
            border: 2px solid #e0e0e0;
            border-radius: 4px;
            cursor: pointer;
            accent-color: #ff6600;
        }
        
        .form-check-label {
            color: #666;
            font-size: 0.9rem;
            cursor: pointer;
        }
        
        .btn-submit {
            width: 100%;
            background: linear-gradient(135deg, #ff6600 0%, #e65100 100%);
            color: white;
            border: none;
            padding: 16px;
            border-radius: 12px;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(255, 102, 0, 0.3);
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 102, 0, 0.4);
        }
        
        .btn-submit:active {
            transform: translateY(0);
        }
        
        .forgot-password {
            text-align: center;
            margin-bottom: 25px;
        }
        
        .forgot-password a {
            color: #ff6600;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            transition: color 0.3s;
        }
        
        .forgot-password a:hover {
            color: #e65100;
            text-decoration: underline;
        }
        
        .terms {
            text-align: center;
            font-size: 0.85rem;
            color: #666;
            line-height: 1.6;
            margin-top: 20px;
        }
        
        .terms a {
            color: #ff6600;
            text-decoration: none;
            font-weight: 500;
        }
        
        .terms a:hover {
            text-decoration: underline;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-danger {
            background-color: #fee;
            color: #c33;
            border: 1px solid #fcc;
        }
        
        .alert-info {
            background-color: #e3f2fd;
            color: #1976d2;
            border: 1px solid #bbdefb;
        }
        
        .alert-success {
            background-color: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }
        
        /* Responsive */
        @media (max-width: 992px) {
            .login-content {
                grid-template-columns: 1fr;
                gap: 40px;
                padding: 40px;
            }
            
            .welcome-title {
                font-size: 3rem;
            }
            
            .login-form-section {
                padding: 40px;
            }
        }
        
        @media (max-width: 768px) {
            .login-content {
                padding: 30px 20px;
            }
            
            .welcome-title {
                font-size: 2.5rem;
            }
            
            .welcome-description {
                font-size: 1rem;
            }
            
            .login-form-section {
                padding: 30px 20px;
            }
            
            .form-title {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-wrapper">
            <div class="login-content">
                <!-- Left Section - Welcome -->
                <div class="welcome-section">
                    <h1 class="welcome-title">
                        Chào mừng<br>
                        trở lại
                    </h1>
                    <p class="welcome-description">
                        Hệ thống Quản lý Phép là giải pháp toàn diện giúp bạn quản lý đơn nghỉ phép một cách hiệu quả. 
                        Với giao diện thân thiện và các tính năng mạnh mẽ, bạn có thể dễ dàng theo dõi số dư phép, 
                        tạo đơn nghỉ phép, và xem lịch sử của mình. Hệ thống hỗ trợ đầy đủ các loại phép như 
                        <span class="highlight">phép năm, nghỉ ốm, nghỉ cưới</span> và nhiều loại khác.
                    </p>
                    
                    <div class="social-icons">
                        <a href="#" class="social-icon" title="Facebook">
                            <i class="bi bi-facebook"></i>
                        </a>
                        <a href="#" class="social-icon" title="Twitter">
                            <i class="bi bi-twitter"></i>
                        </a>
                        <a href="#" class="social-icon" title="Instagram">
                            <i class="bi bi-instagram"></i>
                        </a>
                        <a href="#" class="social-icon" title="YouTube">
                            <i class="bi bi-youtube"></i>
                        </a>
                    </div>
                </div>
                
                <!-- Right Section - Login Form -->
                <div class="login-form-section">
                    <h2 class="form-title">Đăng nhập</h2>
                    <p class="form-subtitle">Vui lòng đăng nhập để tiếp tục</p>
                    
                    <% if (error != null) { %>
                        <div class="alert alert-danger">
                            <i class="bi bi-exclamation-circle"></i>
                            <span><%= error %></span>
                        </div>
                    <% } %>
                    
                    <% if (msg != null) { %>
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle"></i>
                            <span><%= msg %></span>
                        </div>
                    <% } %>
                    
                    <form method="post" action="<%=request.getContextPath()%>/login" id="loginForm">
                        <div class="form-group">
                            <label for="username" class="form-label">
                                <i class="bi bi-person"></i> Tên đăng nhập
                            </label>
                            <input 
                                type="text" 
                                class="form-control" 
                                id="username" 
                                name="username" 
                                placeholder="Nhập tên đăng nhập" 
                                required 
                                autofocus>
                        </div>
                        
                        <div class="form-group">
                            <label for="password" class="form-label">
                                <i class="bi bi-lock"></i> Mật khẩu
                            </label>
                            <input 
                                type="password" 
                                class="form-control" 
                                id="password" 
                                name="password" 
                                placeholder="Nhập mật khẩu" 
                                required>
                        </div>
                        
                        <div class="form-check">
                            <input 
                                type="checkbox" 
                                class="form-check-input" 
                                id="rememberMe" 
                                name="rememberMe">
                            <label class="form-check-label" for="rememberMe">
                                Ghi nhớ đăng nhập
                            </label>
                        </div>
                        
                        <button type="submit" class="btn-submit">
                            <i class="bi bi-box-arrow-in-right"></i> Đăng nhập ngay
                        </button>

                        <div style="text-align:center; margin: 15px 0;">
                            <span style="color:#888; font-size:0.9rem;">hoặc</span>
                        </div>

                        <div style="display:flex; gap:10px;">
                            <a href="<%=request.getContextPath()%>/auth/google" class="btn btn-outline-secondary" style="flex:1; display:flex; align-items:center; justify-content:center; gap:8px; padding:12px; border-radius:10px;">
                                <i class="bi bi-google" style="font-size:1.2rem; color:#db4437;"></i>
                                <span style="font-weight:600; color:#333;">Đăng nhập bằng Google</span>
                            </a>
                        </div>
                        
                        <div class="forgot-password">
                            <a href="<%=request.getContextPath()%>/auth/forgot">Quên mật khẩu?</a>
                        </div>
                        
                        <div class="terms">
                            Bằng cách nhấp vào 'Đăng nhập ngay', bạn đồng ý với 
                            <a href="#">Điều khoản Dịch vụ</a> | 
                            <a href="#">Chính sách Bảo mật</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Toastr JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
    
    <script>
        // Configure Toastr
        toastr.options = {
            "closeButton": true,
            "debug": false,
            "newestOnTop": true,
            "progressBar": true,
            "positionClass": "toast-top-right",
            "preventDuplicates": false,
            "onclick": null,
            "showDuration": "300",
            "hideDuration": "1000",
            "timeOut": "5000",
            "extendedTimeOut": "1000",
            "showEasing": "swing",
            "hideEasing": "linear",
            "showMethod": "fadeIn",
            "hideMethod": "fadeOut"
        };
        
        // Form validation
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            const username = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value;
            
            if (!username || !password) {
                e.preventDefault();
                toastr.error('Vui lòng điền đầy đủ thông tin đăng nhập');
                return false;
            }
            
            if (username.length < 3) {
                e.preventDefault();
                toastr.error('Tên đăng nhập phải có ít nhất 3 ký tự');
                return false;
            }
            
            if (password.length < 3) {
                e.preventDefault();
                toastr.error('Mật khẩu phải có ít nhất 3 ký tự');
                return false;
            }
        });
        
        // Auto focus on username if empty
        window.addEventListener('load', function() {
            const username = document.getElementById('username');
            if (!username.value) {
                username.focus();
            }
        });
    </script>
</body>
</html>
