package controller.balance;

import controller.iam.BaseRequiredAuthenticationController;
import dal.LeaveBalanceDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.LeaveBalance;
import model.iam.User;

@WebServlet("/balance")
public class BalanceController extends BaseRequiredAuthenticationController {
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User user = (User) req.getSession().getAttribute("user");
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            
            LeaveBalanceDBContext balanceDB = new LeaveBalanceDBContext();
            int year = req.getParameter("year") != null ? 
                Integer.parseInt(req.getParameter("year")) : 
                java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
            
            List<LeaveBalance> balances = balanceDB.getUserBalances(user.getUid(), year);
            
            req.setAttribute("balances", balances);
            req.setAttribute("year", year);
            req.getRequestDispatcher("/view/balance/balance.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        processGet(req, resp);
    }
}

