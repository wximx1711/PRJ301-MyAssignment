package controller.home;

import controller.iam.BaseRequiredAuthenticationController;
import dal.RoleDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Set;

@WebServlet("/home")
public class HomeController extends BaseRequiredAuthenticationController {
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        try (RoleDBContext rdb = new RoleDBContext()) {
            Set<String> features = rdb.getFeatureUrls(user.getUid());
            req.setAttribute("features", features);
        }
        req.getRequestDispatcher("/view/util/greeting.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { }
}
