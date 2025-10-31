package controller.iam;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.iam.User;

public abstract class BaseRequiredAuthenticationController extends HttpServlet {

    protected abstract void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException;
    protected abstract void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = (User) req.getSession().getAttribute("user");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        processGet(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = (User) req.getSession().getAttribute("user");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        processPost(req, resp);
    }
}
