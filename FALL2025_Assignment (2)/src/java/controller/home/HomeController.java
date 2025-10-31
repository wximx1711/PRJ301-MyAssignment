package controller.home;

import controller.iam.BaseRequiredAuthenticationController;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/home") // Trang chính sau khi đăng nhập
public class HomeController extends BaseRequiredAuthenticationController {
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var user = (model.iam.User) req.getSession().getAttribute("user");
        
        // Kiểm tra nếu người dùng chưa đăng nhập
        if (user == null) {
            // Nếu chưa đăng nhập, chuyển hướng tới trang login
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Nếu người dùng đã đăng nhập, tiếp tục vào trang chính (dashboard)
        req.getRequestDispatcher("/view/util/greeting.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { }
}
