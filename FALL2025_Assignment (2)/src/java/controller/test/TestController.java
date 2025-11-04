package controller.test;

import dal.DBContext;
import dal.UserDBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.Statement;
import model.iam.User;

@WebServlet("/test")
public class TestController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Test Page</title></head><body>");
        out.println("<h1>Database Connection Test</h1>");
        
        try {
            // Test database connection
            out.println("<h2>1. Testing Database Connection...</h2>");
            DBContext db = new DBContext();
            out.println("<p style='color:green'>✓ Database connection successful!</p>");
            
            // Test query users
            out.println("<h2>2. Testing User Query...</h2>");
            String sql = "SELECT TOP 5 id, username, password_hash, full_name, is_active FROM Users";
            Statement stmt = db.getConnection().createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            
            out.println("<table border='1' cellpadding='5'>");
            out.println("<tr><th>ID</th><th>Username</th><th>Password Hash</th><th>Full Name</th><th>Active</th></tr>");
            
            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("id") + "</td>");
                out.println("<td>" + rs.getString("username") + "</td>");
                out.println("<td>" + rs.getString("password_hash") + "</td>");
                out.println("<td>" + rs.getString("full_name") + "</td>");
                out.println("<td>" + rs.getBoolean("is_active") + "</td>");
                out.println("</tr>");
            }
            
            out.println("</table>");
            rs.close();
            stmt.close();
            
            // Test login with specific user
            out.println("<h2>3. Testing Login Function...</h2>");
            UserDBContext userDB = new UserDBContext();
            
            String[] testUsers = {"admin", "bob", "mike", "alice", "carl", "eva"};
            for (String username : testUsers) {
                User user = userDB.get(username, "123");
                if (user != null) {
                    out.println("<p style='color:green'>✓ " + username + "/123 - Login successful! (ID: " + user.getId() + ", Name: " + user.getFullName() + ")</p>");
                } else {
                    out.println("<p style='color:red'>✗ " + username + "/123 - Login failed!</p>");
                }
            }
            
            db.close();
            
        } catch (Exception e) {
            out.println("<p style='color:red'>✗ Error: " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
        }
        
        out.println("<hr>");
        out.println("<p><a href='" + req.getContextPath() + "/login'>Go to Login Page</a></p>");
        out.println("</body></html>");
    }
}

