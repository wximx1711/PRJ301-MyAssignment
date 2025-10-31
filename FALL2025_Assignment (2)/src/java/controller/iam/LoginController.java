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
        req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String u = req.getParameter("username");
        String p = req.getParameter("password");

        User user = new UserDBContext().get(u, p);
        if (user == null) {
            req.setAttribute("msg", "Sai tài khoản hoặc mật khẩu");
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
            return;
        }
        req.getSession(true).setAttribute("user", user);
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
