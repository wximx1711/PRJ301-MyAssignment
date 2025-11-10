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

            // Create leave request and return generated id
            RequestForLeaveDBContext db = new RequestForLeaveDBContext();
            int newRid = db.create(user.getUid(), from, to, reason);

            // Notify all admins so they can review immediately
            try {
                dal.UserDBContext udb = new dal.UserDBContext();
                dal.NotificationDBContext ndb = new dal.NotificationDBContext();
                java.util.List<Integer> admins = udb.listAdmins();
                String title = "Đơn nghỉ phép mới";
                String message = user.getFullName() + " vừa tạo đơn (ID: " + newRid + ") cần duyệt";
                for (Integer aid : admins) {
                    try { ndb.createNotification(aid, "IN_APP", title, message, "REQUEST", newRid); } catch (Exception ignore) {}
                }
            } catch (Exception ex) {
                // non-fatal: notifications failure shouldn't block create flow
            }

            // If the creator is ADMIN keep redirect to request list; otherwise redirect to list with focus so admins can review
            String roleCode = user.getRole() != null ? user.getRole().getCode() : "";
            if ("ADMIN".equalsIgnoreCase(roleCode)) {
                resp.sendRedirect(req.getContextPath() + "/request/list");
            } else {
                // redirect to list with a focus param (admins will see notification and can open review)
                resp.sendRedirect(req.getContextPath() + "/request/list?focus=" + newRid);
            }
        } catch (IllegalArgumentException e) {
            req.setAttribute("msg", e.getMessage());
            req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
        } catch (RuntimeException e) {
            req.setAttribute("msg", "System error: " + e.getMessage());
            req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
        }
    }
}
