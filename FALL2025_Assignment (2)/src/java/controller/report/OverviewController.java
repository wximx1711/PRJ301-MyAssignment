package controller.report;

import controller.iam.BaseRequiredAuthorizationController;
import dal.ReportDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/reports/overview")
public class OverviewController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) { return "/reports"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ReportDBContext db = new ReportDBContext();
        Map<String, Object> data = db.getSummary();
        req.setAttribute("summary", data);
        req.getRequestDispatcher("/view/report/overview.jsp").forward(req, resp);
    }
}


