package controller.index;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.iam.User;

@WebServlet(value = {"/", ""})
public class IndexController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Check if user is already logged in
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        
        if (user != null) {
            // User is already logged in, redirect to home
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            // User is not logged in, redirect to login page
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}

