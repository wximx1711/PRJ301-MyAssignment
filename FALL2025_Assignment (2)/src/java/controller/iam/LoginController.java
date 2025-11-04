package controller.iam;

import dal.UserDBContext;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import model.iam.User;

@WebServlet("/login")
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp); // Hiển thị trang đăng nhập
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Validate input
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu");
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            // Lấy thông tin người dùng từ database
            System.out.println("LoginController: Attempting login for username='" + username + "'");
            UserDBContext userDB = new UserDBContext();
            User user = userDB.get(username.trim(), password.trim());

            if (user == null) {
                System.out.println("LoginController: Login failed for username='" + username + "'");
                req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng. Vui lòng thử lại!");
                req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                return;
            }
            
            System.out.println("LoginController: Login successful for user: " + user.getFullName() + " (ID: " + user.getId() + ")");

            // Lưu thông tin người dùng vào session
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            // Chuyển hướng đến trang chính sau khi đăng nhập
            resp.sendRedirect(req.getContextPath() + "/home");
            
        } catch (RuntimeException e) {
            // Database connection error
            String errorMsg = e.getMessage();
            System.err.println("LoginController: Database error - " + errorMsg);
            e.printStackTrace();
            
            // User-friendly error message
            String userMessage;
            if (errorMsg.contains("không tồn tại") || errorMsg.contains("Cannot open database")) {
                userMessage = "Database chưa được tạo! Vui lòng chạy file SQL script 'leave_management_setup_v2.sql' để tạo database trước.";
            } else if (errorMsg.contains("Login failed") || errorMsg.contains("Đăng nhập")) {
                userMessage = "Lỗi kết nối SQL Server! Vui lòng kiểm tra SQL Server đang chạy và thông tin đăng nhập.";
            } else if (errorMsg.contains("connection refused") || errorMsg.contains("connect")) {
                userMessage = "Không thể kết nối đến SQL Server! Vui lòng kiểm tra SQL Server đang chạy.";
            } else {
                userMessage = "Lỗi hệ thống: " + errorMsg;
            }
            
            req.setAttribute("error", userMessage);
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
        } catch (Exception e) {
            // Other unexpected errors
            System.err.println("LoginController: Unexpected error - " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống không xác định: " + e.getMessage() + ". Vui lòng liên hệ quản trị viên.");
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
        }
    }
}
