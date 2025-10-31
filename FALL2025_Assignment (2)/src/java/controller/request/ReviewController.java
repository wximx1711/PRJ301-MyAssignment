package controller.request;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/request/review")
public class ReviewController extends BaseRequiredAuthorizationController {
    @Override protected String featureUrl(HttpServletRequest req) { return "/request/review"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/request/list");
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        int rid = Integer.parseInt(req.getParameter("rid"));
        int status = Integer.parseInt(req.getParameter("status"));
        String note = req.getParameter("note");
        try {
            new RequestForLeaveDBContext().approveOrReject(user.getUid(), rid, status, note);
            resp.sendRedirect(req.getContextPath() + "/request/list");
        } catch (RuntimeException ex) {
            req.setAttribute("message", ex.getMessage());
            req.getRequestDispatcher("/view/auth/message.jsp").forward(req, resp);
        }
    }
}
