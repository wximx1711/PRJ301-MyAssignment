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
            UserDBContext userDB = new UserDBContext();
            User user = userDB.get(username.trim(), password.trim());

            if (user == null) {
                req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng. Vui lòng thử lại!");
                req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                return;
            }

            // Lưu thông tin người dùng vào session
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            // Chuyển hướng đến trang chính sau khi đăng nhập
            resp.sendRedirect(req.getContextPath() + "/home");
            
        } catch (Exception e) {
            e.printStackTrace(); // Log error for debugging
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage() + ". Vui lòng liên hệ quản trị viên.");
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
        }
    }
}
