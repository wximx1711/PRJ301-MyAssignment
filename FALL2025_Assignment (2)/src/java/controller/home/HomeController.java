package controller.home;

import controller.iam.BaseRequiredAuthenticationController;
import dal.RequestForLeaveDBContext;
import dal.UserDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import model.iam.User;

@WebServlet("/home")
public class HomeController extends BaseRequiredAuthenticationController {

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
            
            String roleCode = user.getRole().getCode();
            
            // Lấy dữ liệu thống kê theo role
            if ("ADMIN".equals(roleCode)) {
                // Admin stats
                int totalRequests = requestDB.countAllRequests();
                int pendingRequests = requestDB.countPendingRequests();
                int totalUsers = userDB.countAllUsers();
                
                req.setAttribute("pendingRequests", pendingRequests);
                req.setAttribute("totalRequests", totalRequests);
                req.setAttribute("totalUsers", totalUsers);
                req.setAttribute("employeesOnLeave", 50); // Placeholder
                
            } else if ("MANAGER".equals(roleCode) || "LEADER".equals(roleCode)) {
                // Manager stats
                int pendingRequests = requestDB.countPendingRequestsForManager(user.getId());
                int totalSubordinates = userDB.countSubordinates(user.getId());
                
                req.setAttribute("pendingRequests", pendingRequests);
                req.setAttribute("totalSubordinates", totalSubordinates);
                req.setAttribute("employeesOnLeave", 0); // Placeholder
                
            } else {
                // Employee stats
                int myPendingRequests = requestDB.countMyPendingRequests(user.getId());
                int myApprovedRequests = requestDB.countMyApprovedRequests(user.getId());
                
                req.setAttribute("myPendingRequests", myPendingRequests);
                req.setAttribute("myApprovedRequests", myApprovedRequests);
            }
            
            req.getRequestDispatcher("/view/util/greeting.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processGet(req, resp);
    }
}
