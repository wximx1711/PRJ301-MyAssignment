package controller.notification;

import controller.iam.BaseRequiredAuthenticationController;
import dal.NotificationDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.Notification;
import model.iam.User;

@WebServlet("/notifications")
public class NotificationController extends BaseRequiredAuthenticationController {
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User user = (User) req.getSession().getAttribute("user");
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            
            NotificationDBContext notificationDB = new NotificationDBContext();
            String action = req.getParameter("action");
            
            if ("mark-read".equals(action)) {
                String notificationId = req.getParameter("id");
                if (notificationId != null) {
                    notificationDB.markAsRead(Integer.parseInt(notificationId), user.getUid());
                }
                resp.sendRedirect(req.getContextPath() + "/notifications");
                return;
            }
            
            List<Notification> notifications = notificationDB.getUserNotifications(user.getUid());
            int unreadCount = notificationDB.getUnreadCount(user.getUid());
            
            req.setAttribute("notifications", notifications);
            req.setAttribute("unreadCount", unreadCount);
            req.getRequestDispatcher("/view/notification/notifications.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processGet(req, resp);
    }
}

