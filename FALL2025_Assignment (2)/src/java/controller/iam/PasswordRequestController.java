package controller.iam;

import dal.PasswordResetDBContext;
import model.iam.PasswordResetRequest;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/iam/password-requests")
public class PasswordRequestController extends BaseRequiredAuthorizationController {

    protected String featureUrl(HttpServletRequest req) {
        return "/iam/password-requests";
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            PasswordResetDBContext db = new PasswordResetDBContext();
            List<PasswordResetRequest> list = db.listRequests();
            req.setAttribute("requests", list);
            req.getRequestDispatcher("/view/iam/password_requests.jsp").forward(req, resp);
        } catch (RuntimeException ex) {
            req.setAttribute("message", "Error loading requests: " + ex.getMessage());
            req.getRequestDispatcher("/view/auth/message.jsp").forward(req, resp);
        }
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        int requestId = Integer.parseInt(req.getParameter("requestId"));
        var user = (model.iam.User) req.getSession().getAttribute("user");
        try {
            PasswordResetDBContext db = new PasswordResetDBContext();
            if ("process".equals(action) || "resetDefault".equals(action)) {
                String newPassword = req.getParameter("newPassword");
                // If action indicates reset default or newPassword is empty, use default '123'
                if ("resetDefault".equals(action) || newPassword == null || newPassword.trim().isEmpty()) {
                    db.processRequest(requestId, user.getUid(), "123");
                    req.setAttribute("msg", "Yêu cầu đã được xử lý và mật khẩu đã được đặt về mặc định (123).");
                } else {
                    db.processRequest(requestId, user.getUid(), newPassword.trim());
                    req.setAttribute("msg", "Yêu cầu đã được xử lý và mật khẩu đã được cập nhật.");
                }
            }
            // refresh list
            req.setAttribute("requests", db.listRequests());
            req.getRequestDispatcher("/view/iam/password_requests.jsp").forward(req, resp);
        } catch (RuntimeException ex) {
            req.setAttribute("error", ex.getMessage());
            req.getRequestDispatcher("/view/iam/password_requests.jsp").forward(req, resp);
        }
    }
}
