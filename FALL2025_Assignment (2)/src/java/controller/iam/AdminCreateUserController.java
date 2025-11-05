package controller.iam;

import dal.UserDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/users/create")
public class AdminCreateUserController extends BaseRequiredAuthorizationController {

    private boolean isAdmin(HttpServletRequest req){
        model.iam.User u = (model.iam.User) req.getSession().getAttribute("user");
        return u != null && u.getRole() != null && "ADMIN".equals(u.getRole().getCode());
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
        UserDBContext db = new UserDBContext();
        req.setAttribute("departments", db.listDepartments());
        req.setAttribute("roles", db.listRoles());
        req.setAttribute("managers", db.listManagers());
        req.getRequestDispatcher("/view/admin/user/create.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String fullName = req.getParameter("fullName");
        int roleId = Integer.parseInt(req.getParameter("roleId"));
        int deptId = Integer.parseInt(req.getParameter("deptId"));
        String manager = req.getParameter("managerId");
        Integer managerId = (manager == null || manager.isBlank()) ? null : Integer.valueOf(manager);
        boolean active = "on".equals(req.getParameter("active"));

        try {
            new UserDBContext().createUser(username, password, fullName, roleId, deptId, managerId, active);
            req.setAttribute("success", "Tạo người dùng thành công");
        } catch (RuntimeException ex) {
            req.setAttribute("error", ex.getMessage());
        }

        // Re-load lists for the form
        UserDBContext db = new UserDBContext();
        req.setAttribute("departments", db.listDepartments());
        req.setAttribute("roles", db.listRoles());
        req.setAttribute("managers", db.listManagers());
        req.getRequestDispatcher("/view/admin/user/create.jsp").forward(req, resp);
    }
}


