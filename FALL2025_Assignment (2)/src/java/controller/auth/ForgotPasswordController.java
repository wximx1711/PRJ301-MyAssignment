package controller.auth;

import controller.iam.BaseRequiredAuthorizationController;
import dal.PasswordResetDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/auth/forgot")
public class ForgotPasswordController extends controller.iam.BaseRequiredAuthorizationController {

    protected String featureUrl(HttpServletRequest req) {
        return "/auth/forgot";
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/view/auth/forgot.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String note = req.getParameter("note");
        try {
            PasswordResetDBContext db = new PasswordResetDBContext();
            db.createRequestByUsername(username, note != null ? note : "");
            req.setAttribute("msg", "Yêu cầu đã được gửi đến quản trị viên. Vui lòng chờ họ xử lý.");
            req.getRequestDispatcher("/view/auth/forgot.jsp").forward(req, resp);
        } catch (RuntimeException ex) {
            req.setAttribute("error", "Không thể gửi yêu cầu: " + ex.getMessage());
            req.getRequestDispatcher("/view/auth/forgot.jsp").forward(req, resp);
        }
    }
}
