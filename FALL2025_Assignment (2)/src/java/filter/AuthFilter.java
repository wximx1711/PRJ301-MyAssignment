package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;
import model.Role;

public class AuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        
        String path = req.getRequestURI().substring(req.getContextPath().length());
        
        // Public paths that don't require authentication
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }
        
        // Get the user from session
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        
        // Check if user is authenticated
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        // Add user info to request for easy access in servlets/JSPs
        req.setAttribute("currentUser", user);
        req.setAttribute("userRole", user.getRole().getCode());
        req.setAttribute("isManager", isManager(user));
        req.setAttribute("isAdmin", isAdmin(user));
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
    
    private boolean isPublicPath(String path) {
        return path.equals("/login") || 
               path.equals("/logout") ||
               path.startsWith("/css/") ||
               path.startsWith("/js/") ||
               path.startsWith("/img/") ||
               path.equals("/__health");
    }
    
    private boolean isManager(User user) {
        String role = user.getRole().getCode();
        return "MANAGER".equals(role) || "LEADER".equals(role);
    }
    
    private boolean isAdmin(User user) {
        return "ADMIN".equals(user.getRole().getCode());
    }
}