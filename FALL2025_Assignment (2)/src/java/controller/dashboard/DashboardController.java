package controller.dashboard;

import controller.iam.BaseRequiredAuthenticationController;
import dal.RequestForLeaveDBContext;
import dal.UserDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.iam.User;

@WebServlet("/dashboard")
public class DashboardController extends BaseRequiredAuthenticationController {
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User user = (User) req.getSession().getAttribute("user");
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            
            RequestForLeaveDBContext requestDB = new RequestForLeaveDBContext();
            UserDBContext userDB = new UserDBContext();
            
            // Dashboard data based on role
            String roleCode = user.getRole().getCode();
            
            if ("MANAGER".equals(roleCode) || "LEADER".equals(roleCode)) {
                // Manager Dashboard
                int pendingRequests = requestDB.countPendingRequestsForManager(user.getUid());
                int upcomingApprovals = requestDB.countUpcomingApprovals(user.getUid());
                int totalSubordinates = userDB.countSubordinates(user.getUid());
                
                req.setAttribute("pendingRequests", pendingRequests);
                req.setAttribute("upcomingApprovals", upcomingApprovals);
                req.setAttribute("totalSubordinates", totalSubordinates);
                req.setAttribute("dashboardType", "manager");
                
            } else if ("ADMIN".equals(roleCode)) {
                // Admin Dashboard
                int totalRequests = requestDB.countAllRequests();
                int pendingRequests = requestDB.countPendingRequests();
                int totalUsers = userDB.countAllUsers();
                int activeUsers = userDB.countActiveUsers();
                
                req.setAttribute("totalRequests", totalRequests);
                req.setAttribute("pendingRequests", pendingRequests);
                req.setAttribute("totalUsers", totalUsers);
                req.setAttribute("activeUsers", activeUsers);
                req.setAttribute("dashboardType", "admin");
                
            } else {
                // Employee Dashboard
                int myPendingRequests = requestDB.countMyPendingRequests(user.getUid());
                int myApprovedRequests = requestDB.countMyApprovedRequests(user.getUid());
                
                req.setAttribute("myPendingRequests", myPendingRequests);
                req.setAttribute("myApprovedRequests", myApprovedRequests);
                req.setAttribute("dashboardType", "employee");
            }
            
            req.getRequestDispatcher("/view/dashboard/dashboard.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processGet(req, resp);
    }
}

