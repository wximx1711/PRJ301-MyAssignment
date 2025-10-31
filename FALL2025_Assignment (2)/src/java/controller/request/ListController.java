package controller.request;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/request/list")
public class ListController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) { return "/request/list"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        RequestForLeaveDBContext db = new RequestForLeaveDBContext();
        int myEid = db.getMyEid(user.getUid());
        req.setAttribute("mine", db.listMine(myEid));
        req.setAttribute("subs", db.listOfSubordinates(myEid));
        req.getRequestDispatcher("/view/request/list.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { }
}
