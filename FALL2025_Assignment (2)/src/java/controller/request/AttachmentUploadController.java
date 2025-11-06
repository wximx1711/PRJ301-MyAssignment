package controller.request;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;

@WebServlet("/request/attach")
@MultipartConfig
public class AttachmentUploadController extends BaseRequiredAuthorizationController {
    protected String featureUrl(HttpServletRequest req) { return "/request/list"; }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        int rid = Integer.parseInt(req.getParameter("rid"));
        Part file = req.getPart("file");
        if (file == null || file.getSize() == 0) {
            resp.sendRedirect(req.getContextPath()+"/request/view?id="+rid+"&msg=No%20file");
            return;
        }
        // Save to /uploads (under webapp real path)
        String uploads = req.getServletContext().getRealPath("/uploads");
        new File(uploads).mkdirs();
        String fileName = System.currentTimeMillis()+"_"+getFileName(file);
        File dest = new File(uploads, fileName);
        try (InputStream in = file.getInputStream(); OutputStream out = new FileOutputStream(dest)) {
            in.transferTo(out);
        }
        RequestForLeaveDBContext db = new RequestForLeaveDBContext();
        db.insertAttachment(rid, fileName, "/uploads/"+fileName, user.getUid());
        resp.sendRedirect(req.getContextPath()+"/request/view?id="+rid+"&msg=uploaded");
    }

    private String getFileName(Part part) {
        String cd = part.getHeader("content-disposition");
        if (cd == null) return "file";
        for (String s : cd.split(";")) {
            s = s.trim();
            if (s.startsWith("filename")) {
                return s.substring(s.indexOf('=')+1).replace("\"", "");
            }
        }
        return "file";
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}


