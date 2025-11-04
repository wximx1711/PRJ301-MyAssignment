package controller.report;

import controller.iam.BaseRequiredAuthenticationController;
import dal.ReportDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.iam.User;

@WebServlet("/reports")
public class ReportController extends BaseRequiredAuthenticationController {
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User user = (User) req.getSession().getAttribute("user");
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            
            ReportDBContext reportDB = new ReportDBContext();
            String reportType = req.getParameter("type");
            int year = req.getParameter("year") != null ? 
                Integer.parseInt(req.getParameter("year")) : 
                java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
            
            if ("statistics".equals(reportType)) {
                // Leave statistics by department
                List<Map<String, Object>> statistics = reportDB.getLeaveStatisticsByDepartment(year);
                req.setAttribute("statistics", statistics);
                req.setAttribute("reportType", "statistics");
            } else if ("usage".equals(reportType)) {
                // Leave usage trends
                List<Map<String, Object>> usage = reportDB.getLeaveUsageTrends(year);
                req.setAttribute("usage", usage);
                req.setAttribute("reportType", "usage");
            } else {
                // Default dashboard report
                Map<String, Object> summary = reportDB.getLeaveSummary(year);
                req.setAttribute("summary", summary);
                req.setAttribute("reportType", "summary");
            }
            
            req.setAttribute("year", year);
            req.getRequestDispatcher("/view/report/reports.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processGet(req, resp);
    }
}

