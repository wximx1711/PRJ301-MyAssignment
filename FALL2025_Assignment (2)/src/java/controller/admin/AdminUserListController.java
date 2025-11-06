package controller.admin;

import controller.iam.BaseRequiredAuthorizationController;
import dal.UserDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/users")
public class AdminUserListController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) { return "/admin/users"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserDBContext db = new UserDBContext();
        req.setAttribute("users", db.listAll());
        req.getRequestDispatcher("/view/admin/user/list.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        int uid = Integer.parseInt(req.getParameter("uid"));
        UserDBContext db = new UserDBContext();
        if ("deactivate".equals(action)) {
            db.setActive(uid, false);
        } else if ("activate".equals(action)) {
            db.setActive(uid, true);
        } else if ("reset".equals(action)) {
            db.resetPassword(uid, "123");
        }
        resp.sendRedirect(req.getContextPath()+"/admin/users");
    }
}


