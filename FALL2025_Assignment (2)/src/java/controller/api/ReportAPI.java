package controller.api;

import controller.iam.BaseRequiredAuthenticationController;
import dal.ReportDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/api/reports")
public class ReportAPI extends BaseRequiredAuthenticationController {
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String reportType = req.getParameter("type");
            int year = req.getParameter("year") != null ? 
                Integer.parseInt(req.getParameter("year")) : 
                java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
            
            ReportDBContext reportDB = new ReportDBContext();
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();
            
            if ("statistics".equals(reportType)) {
                List<Map<String, Object>> statistics = reportDB.getLeaveStatisticsByDepartment(year);
                out.print(convertToJson(statistics));
            } else if ("usage".equals(reportType)) {
                List<Map<String, Object>> usage = reportDB.getLeaveUsageTrends(year);
                out.print(convertToJson(usage));
            } else if ("chart".equals(reportType)) {
                List<Map<String, Object>> chartData = reportDB.getChartData(year);
                out.print(convertToJson(chartData));
            }
            
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().print("{\"error\":\"Database error\"}");
        }
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processGet(req, resp);
    }
    
    private String convertToJson(List<Map<String, Object>> list) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) json.append(",");
            json.append("{");
            Map<String, Object> map = list.get(i);
            int j = 0;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                if (j > 0) json.append(",");
                json.append("\"").append(entry.getKey()).append("\":");
                Object value = entry.getValue();
                if (value instanceof String) {
                    json.append("\"").append(escapeJson(value.toString())).append("\"");
                } else if (value instanceof Number || value instanceof Boolean) {
                    json.append(value);
                } else {
                    json.append("\"").append(escapeJson(String.valueOf(value))).append("\"");
                }
                j++;
            }
            json.append("}");
        }
        json.append("]");
        return json.toString();
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

