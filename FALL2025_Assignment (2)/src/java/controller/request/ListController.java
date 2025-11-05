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
        // paging parameters for 'mine' tab
        int pageMine = 1;
        int sizeMine = 10;
        try { String p = req.getParameter("pageMine"); if (p != null) pageMine = Integer.parseInt(p); } catch (Exception e) { pageMine = 1; }
        try { String s = req.getParameter("sizeMine"); if (s != null) sizeMine = Integer.parseInt(s); } catch (Exception e) { sizeMine = 10; }
        int offsetMine = (pageMine - 1) * sizeMine;
        int totalMine = db.countMine(myEid);
        int totalPagesMine = (totalMine + sizeMine - 1) / sizeMine;
        req.setAttribute("mine", db.listMinePage(myEid, offsetMine, sizeMine));
        req.setAttribute("pageMine", pageMine);
        req.setAttribute("sizeMine", sizeMine);
        req.setAttribute("totalPagesMine", totalPagesMine);
        req.setAttribute("totalMine", totalMine);

        // paging parameters for 'subs' tab (visible to managers/leaders/admins)
        int pageSubs = 1;
        int sizeSubs = 10;
        try { String p2 = req.getParameter("pageSubs"); if (p2 != null) pageSubs = Integer.parseInt(p2); } catch (Exception e) { pageSubs = 1; }
        try { String s2 = req.getParameter("sizeSubs"); if (s2 != null) sizeSubs = Integer.parseInt(s2); } catch (Exception e) { sizeSubs = 10; }
        int offsetSubs = (pageSubs - 1) * sizeSubs;
        int totalSubs = db.countSubordinates(myEid);
        int totalPagesSubs = (totalSubs + sizeSubs - 1) / sizeSubs;
        req.setAttribute("subs", db.listOfSubordinatesPage(myEid, offsetSubs, sizeSubs));
        req.setAttribute("pageSubs", pageSubs);
        req.setAttribute("sizeSubs", sizeSubs);
        req.setAttribute("totalPagesSubs", totalPagesSubs);
        req.setAttribute("totalSubs", totalSubs);
        req.getRequestDispatcher("/view/request/list.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { }
}
