package controller.notification;

import controller.iam.BaseRequiredAuthorizationController;
import dal.NotificationDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/notification/mark-all")
public class MarkAllReadController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) { return "/notifications"; }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        NotificationDBContext db = new NotificationDBContext();
        db.markAllRead(user.getUid());
        resp.sendRedirect(req.getHeader("Referer") != null ? req.getHeader("Referer") : (req.getContextPath()+"/notifications"));
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}


