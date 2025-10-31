<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home - Leave Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Welcome, ${user.displayname}</h1>
            <nav>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/request/list">My Requests</a></li>
                    <li><a href="${pageContext.request.contextPath}/request/create">New Request</a></li>
                    <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER'}">
                        <li><a href="${pageContext.request.contextPath}/approvals">Approvals</a></li>
                    </c:if>
                    <c:if test="${user.role.code eq 'ADMIN'}">
                        <li><a href="${pageContext.request.contextPath}/admin">Admin Panel</a></li>
                    </c:if>
                    <li><a href="${pageContext.request.contextPath}/profile">Profile</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <section class="summary">
                <h2>Quick Summary</h2>
                <div class="stats">
                    <div class="stat-card">
                        <h3>Pending Requests</h3>
                        <p>${pendingRequests}</p>
                    </div>
                    <div class="stat-card">
                        <h3>Leave Balance</h3>
                        <p>${leaveBalance} days</p>
                    </div>
                </div>
            </section>
            
            <section class="recent-activities">
                <h2>Recent Activities</h2>
                <c:if test="${not empty activities}">
                    <ul class="activity-list">
                        <c:forEach var="activity" items="${activities}">
                            <li>
                                <span class="activity-date">${activity.formattedDate}</span>
                                <span class="activity-desc">${activity.description}</span>
                            </li>
                        </c:forEach>
                    </ul>
                </c:if>
                <c:if test="${empty activities}">
                    <p>No recent activities</p>
                </c:if>
            </section>
        </main>
    </div>
</body>
</html>