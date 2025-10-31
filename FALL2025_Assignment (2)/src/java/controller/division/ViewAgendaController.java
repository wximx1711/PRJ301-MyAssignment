package controller.division;

import controller.iam.BaseRequiredAuthorizationController;
import dal.DBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/division/agenda")
public class ViewAgendaController extends BaseRequiredAuthorizationController {
    @Override protected String featureUrl(HttpServletRequest req) { return "/division/agenda"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/view/division/agenda.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        java.sql.Date from = java.sql.Date.valueOf(req.getParameter("from"));
        java.sql.Date to   = java.sql.Date.valueOf(req.getParameter("to"));
        int did            = Integer.parseInt(req.getParameter("did"));

        final String sql = """
            WITH Dates AS (
              SELECT ? AS d
              UNION ALL SELECT DATEADD(DAY,1,d) FROM Dates WHERE d < ?
            ),
            Emp AS ( SELECT eid, ename FROM Employee WHERE did=? ),
            EmpDate AS ( SELECT e.eid, e.ename, d.d FROM Emp e CROSS JOIN Dates d ),
            Marked AS (
              SELECT ed.eid, ed.ename, ed.d,
                     CASE WHEN EXISTS (
                       SELECT 1 FROM RequestForLeave r
                       WHERE r.created_by = ed.eid AND r.status=1
                         AND ed.d BETWEEN r.from_date AND r.to_date
                     ) THEN 1 ELSE 0 END AS isLeave
              FROM EmpDate ed
            )
            SELECT eid, ename, d, isLeave FROM Marked OPTION (MAXRECURSION 32767);
        """;

        try (DBContext db = new DBContext();
             PreparedStatement ps = db.getConnection().prepareStatement(sql)) {
            ps.setDate(1, from); ps.setDate(2, to); ps.setInt(3, did);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String,Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("eid", rs.getInt("eid"));
                    m.put("ename", rs.getString("ename"));
                    m.put("day", rs.getDate("d"));
                    m.put("isLeave", rs.getInt("isLeave"));
                    rows.add(m);
                }
                req.setAttribute("rows", rows);
            }
            req.getRequestDispatcher("/view/division/agenda.jsp").forward(req, resp);
        } catch (SQLException e) { throw new ServletException("Load agenda failed: " + e.getMessage(), e); }
    }
}
