package controller.request;

import controller.iam.BaseRequiredAuthenticationController;
import dal.NotificationDAO;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.SQLException;
import model.RequestForLeave;
import model.User;

@WebServlet(name = "CancelRequestController", urlPatterns = {"/request/cancel"})
public class CancelRequestController extends BaseRequiredAuthenticationController {

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/request/list");
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Get user from session
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Check if user is ADMIN
        if (!"ADMIN".equals(user.getRole().getCode())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only administrators can cancel requests");
            return;
        }

        // Get request ID
        String rId = req.getParameter("rid");
        if (rId == null || rId.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Request ID is required");
            return;
        }

        try {
            int requestId = Integer.parseInt(rId);
            RequestForLeaveDBContext requestDAO = new RequestForLeaveDBContext();
            
            // Get the request to find its creator
            RequestForLeave request = requestDAO.getById(requestId);
            if (request == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Request not found");
                return;
            }

            // Check if request can be cancelled (only INPROGRESS requests)
            if (request.getStatus() != 1) { // 1 = INPROGRESS
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Only pending requests can be cancelled");
                return;
            }

            // Cancel the request
            requestDAO.cancelRequest(requestId, user.getId(), "Cancelled by administrator");

            // Add notification to request creator
            NotificationDAO notificationDAO = new NotificationDAO();
            String title = "Yêu cầu nghỉ phép đã bị hủy";
            String message = String.format("Yêu cầu nghỉ phép của bạn đã bị hủy bởi %s.", user.getFullName());
            notificationDAO.create(request.getCreatedBy(), "IN_APP", title, message, "REQUEST", requestId);

            // Set success message 
            session.setAttribute("successMessage", "Request cancelled successfully");

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request ID format");
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Failed to cancel request: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/request/list");
    }
}