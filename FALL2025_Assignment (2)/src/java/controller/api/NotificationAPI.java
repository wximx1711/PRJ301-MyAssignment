package controller.api;

import controller.iam.BaseRequiredAuthenticationController;
import dal.NotificationDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import model.Notification;
import model.iam.User;

@WebServlet("/api/notifications")
public class NotificationAPI extends BaseRequiredAuthenticationController {
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User user = (User) req.getSession().getAttribute("user");
            if (user == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            
            NotificationDBContext notificationDB = new NotificationDBContext();
            String action = req.getParameter("action");
            
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();
            
            if ("count".equals(action)) {
                int unreadCount = notificationDB.getUnreadCount(user.getUid());
                out.print("{\"unreadCount\":" + unreadCount + "}");
            } else {
                List<Notification> notifications = notificationDB.getUserNotifications(user.getUid());
                // Simple JSON serialization
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < notifications.size(); i++) {
                    Notification n = notifications.get(i);
                    if (i > 0) json.append(",");
                    json.append("{")
                        .append("\"id\":").append(n.getId()).append(",")
                        .append("\"userId\":").append(n.getUserId()).append(",")
                        .append("\"type\":\"").append(escapeJson(n.getType())).append("\",")
                        .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                        .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
                        .append("\"isRead\":").append(n.isRead()).append(",")
                        .append("\"createdAt\":\"").append(n.getCreatedAt() != null ? n.getCreatedAt().toString() : "").append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            }
            
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().print("{\"error\":\"Database error\"}");
        }
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User user = (User) req.getSession().getAttribute("user");
            if (user == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            
            String action = req.getParameter("action");
            String notificationId = req.getParameter("id");
            
            NotificationDBContext notificationDB = new NotificationDBContext();
            
            if ("mark-read".equals(action) && notificationId != null) {
                notificationDB.markAsRead(Integer.parseInt(notificationId), user.getUid());
                resp.setContentType("application/json");
                resp.getWriter().print("{\"success\":true}");
            }
            
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().print("{\"error\":\"Database error\"}");
        }
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

