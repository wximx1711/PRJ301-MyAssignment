package controller.division;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.*;

@WebServlet("/division/agenda")
public class ViewAgendaController extends BaseRequiredAuthorizationController {

    protected String featureUrl(HttpServletRequest req) { return "/division/agenda"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // Validate and parse input parameters
            String fromStr = req.getParameter("from");
            String toStr = req.getParameter("to");
            String didStr = req.getParameter("did");

            if (fromStr == null || toStr == null || didStr == null) {
                throw new IllegalArgumentException("Missing required parameters: from, to, and did are required");
            }

            Date from, to;
            int did;
            try {
                from = Date.valueOf(fromStr);
                to = Date.valueOf(toStr);
                did = Integer.parseInt(didStr);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid date format or department ID");
            }

            // Validate date range
            if (from.after(to)) {
                throw new IllegalArgumentException("Start date must be before or equal to end date");
            }

            // Fetch data from DB
            RequestForLeaveDBContext db = new RequestForLeaveDBContext();
            List<Map<String, Object>> rows = db.getAgenda(did, from, to);

            // Pass data to JSP
            req.setAttribute("rows", rows);
            req.getRequestDispatcher("/view/division/agenda.jsp").forward(req, resp);
            
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/view/auth/message.jsp").forward(req, resp);
        } catch (RuntimeException e) {
            req.setAttribute("error", "System error: " + e.getMessage());
            req.getRequestDispatcher("/view/auth/message.jsp").forward(req, resp);
        }
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Lấy tham số từ form
        Date from = Date.valueOf(req.getParameter("from"));
        Date to = Date.valueOf(req.getParameter("to"));
        int did = Integer.parseInt(req.getParameter("did"));

        // Gọi phương thức để lấy dữ liệu từ DB
        RequestForLeaveDBContext db = new RequestForLeaveDBContext();
        List<Map<String, Object>> rows = db.getAgenda(did, from, to);

        // Truyền dữ liệu sang trang JSP
        req.setAttribute("rows", rows);
        req.getRequestDispatcher("/view/division/agenda.jsp").forward(req, resp);
    }
}
