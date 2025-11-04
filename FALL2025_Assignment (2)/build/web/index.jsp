<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%
    // Check if user is already logged in
    Object user = session.getAttribute("user");
    if (user != null) {
        // User is already logged in, redirect to home
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    // User is not logged in, redirect to login page
    response.sendRedirect(request.getContextPath() + "/login");
%>

