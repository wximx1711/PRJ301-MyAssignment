package controller.iam;

import dal.RoleDBContext;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.iam.User;

public abstract class BaseRequiredAuthorizationController extends BaseRequiredAuthenticationController {

    protected abstract String featureUrl(HttpServletRequest req);

    private boolean check(HttpServletRequest req) {
        User u = (User) req.getSession().getAttribute("user");
        try (RoleDBContext roleDB = new RoleDBContext()) {
            return roleDB.hasFeature(u.getUid(), featureUrl(req));
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = (User) req.getSession().getAttribute("user");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!check(req)) {
            req.setAttribute("message", "Access denied");
            req.getRequestDispatcher("/view/auth/message.jsp").forward(req, resp);
            return;
        }
        super.doGet(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = (User) req.getSession().getAttribute("user");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!check(req)) {
            req.setAttribute("message", "Access denied");
            req.getRequestDispatcher("/view/auth/message.jsp").forward(req, resp);
            return;
        }
        super.doPost(req, resp);
    }
}
