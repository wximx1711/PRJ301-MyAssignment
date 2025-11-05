package controller.request;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/request/review")
public class ReviewController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) {
        return "/request/review";
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String idParam = req.getParameter("id");
            if (idParam == null) {
                resp.sendRedirect(req.getContextPath() + "/request/list");
                return;
            }
            int rid = Integer.parseInt(idParam);
            RequestForLeaveDBContext db = new RequestForLeaveDBContext();
            var request = db.getById(rid);
            if (request == null) {
                req.setAttribute("message", "Không tìm thấy đơn yêu cầu");
            } else {
                req.setAttribute("request", request);
            }
            req.getRequestDispatcher("/view/request/review.jsp").forward(req, resp);
        } catch (RuntimeException ex) {
            req.setAttribute("message", "Error loading request: " + ex.getMessage());
            req.getRequestDispatcher("/view/request/review.jsp").forward(req, resp);
        }
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
            req.getRequestDispatcher("/view/request/review.jsp").forward(req, resp);
        }
    }
}
