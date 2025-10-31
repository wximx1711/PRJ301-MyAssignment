package controller.request;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/request/create")
public class CreateController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) { return "/request/create"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Hiển thị trang tạo đơn nghỉ phép
        req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // Validate and parse input parameters
            String fromStr = req.getParameter("from");
            String toStr = req.getParameter("to");
            String reason = req.getParameter("reason");

            if (fromStr == null || toStr == null || reason == null || reason.trim().isEmpty()) {
                throw new IllegalArgumentException("Missing required fields: start date, end date, and reason are required");
            }

            Date from, to;
            try {
                from = Date.valueOf(fromStr);
                to = Date.valueOf(toStr);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid date format");
            }

            // Validate date range
            if (from.after(to)) {
                throw new IllegalArgumentException("Start date must be before or equal to end date");
            }

            // Get logged in user
            var user = (model.iam.User) req.getSession().getAttribute("user");
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            // Create leave request
            new RequestForLeaveDBContext().create(user.getUid(), from, to, reason);
            resp.sendRedirect(req.getContextPath() + "/request/list");
        } catch (IllegalArgumentException e) {
            req.setAttribute("msg", e.getMessage());
            req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
        } catch (RuntimeException e) {
            req.setAttribute("msg", "System error: " + e.getMessage());
            req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
        }
    }
}
