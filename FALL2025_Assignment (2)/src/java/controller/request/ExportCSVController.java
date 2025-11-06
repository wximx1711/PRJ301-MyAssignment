package controller.request;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;
import model.RequestForLeave;

@WebServlet("/request/export")
public class ExportCSVController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) { return "/request/list"; }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        RequestForLeaveDBContext db = new RequestForLeaveDBContext();
        int myEid = db.getMyEid(user.getUid());

        String status = req.getParameter("status");
        Integer typeId = null; try { if (req.getParameter("typeId") != null && !req.getParameter("typeId").isBlank()) typeId = Integer.parseInt(req.getParameter("typeId")); } catch (Exception ignore) {}
        java.sql.Date from = null; try { if (req.getParameter("from") != null && !req.getParameter("from").isBlank()) from = java.sql.Date.valueOf(req.getParameter("from")); } catch (Exception ignore) {}
        java.sql.Date to = null; try { if (req.getParameter("to") != null && !req.getParameter("to").isBlank()) to = java.sql.Date.valueOf(req.getParameter("to")); } catch (Exception ignore) {}

        List<RequestForLeave> data = db.listMinePageFiltered(myEid, from, to, status, typeId, 0, 10000);

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=leave_requests.csv");
        try (PrintWriter out = resp.getWriter()) {
            out.println("ID,Title,Reason,From,To,Status,CreatedBy,ProcessedBy");
            for (RequestForLeave r : data) {
                String s = switch (r.getStatus()) { case 1 -> "INPROGRESS"; case 2 -> "APPROVED"; case 3 -> "REJECTED"; default -> "UNKNOWN"; };
                out.printf(Locale.US, "%d,%s,%s,%tF,%tF,%s,%s,%s%n",
                        r.getRid(),
                        safe(r.getReason() != null ? r.getReason() : "Nghỉ phép"),
                        safe(r.getReason()),
                        r.getFromDate(), r.getToDate(),
                        s,
                        safe(r.getCreatedByName()), safe(r.getProcessedByName()));
            }
        }
    }

    private String safe(String v) { return v == null ? "" : '"' + v.replace("\"", "''") + '"'; }
}


