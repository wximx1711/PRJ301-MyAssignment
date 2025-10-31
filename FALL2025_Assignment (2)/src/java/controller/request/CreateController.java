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
        req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        Date from = Date.valueOf(req.getParameter("from"));
        Date to   = Date.valueOf(req.getParameter("to"));
        String reason = req.getParameter("reason");

        try {
            new RequestForLeaveDBContext().create(user.getUid(), from, to, reason);
            resp.sendRedirect(req.getContextPath() + "/request/list");
        } catch (RuntimeException ex) {
            req.setAttribute("message", ex.getMessage());
            req.getRequestDispatcher("/view/auth/message.jsp").forward(req, resp);
        }
    }
}
