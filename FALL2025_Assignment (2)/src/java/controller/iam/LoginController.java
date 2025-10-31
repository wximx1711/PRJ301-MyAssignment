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
        String u = req.getParameter("username");
        String p = req.getParameter("password");

        // Lấy thông tin người dùng từ database
        User user = new UserDBContext().get(u, p);

        if (user == null) {
            req.setAttribute("msg", "Sai tài khoản hoặc mật khẩu");
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp); // Nếu sai, quay lại trang đăng nhập
            return;
        }

        // Lưu thông tin người dùng vào session
        req.getSession(true).setAttribute("user", user);

        // Chuyển hướng đến trang chính sau khi đăng nhập
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
