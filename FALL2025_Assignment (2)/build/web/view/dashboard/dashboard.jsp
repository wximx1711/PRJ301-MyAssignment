<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Dashboard" />

<div class="container-fluid">
    <h1 class="mb-4"><i class="bi bi-speedometer2"></i> Dashboard</h1>
    
    <c:choose>
        <c:when test="${dashboardType eq 'manager'}">
            <!-- Manager Dashboard -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card text-white bg-primary">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Đơn chờ duyệt</h6>
                                    <h2 class="mb-0">${pendingRequests}</h2>
                                </div>
                                <i class="bi bi-hourglass-split fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-info">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Sắp tới</h6>
                                    <h2 class="mb-0">${upcomingApprovals}</h2>
                                </div>
                                <i class="bi bi-calendar-event fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-success">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Nhân viên</h6>
                                    <h2 class="mb-0">${totalSubordinates}</h2>
                                </div>
                                <i class="bi bi-people fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-warning">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Cần xử lý</h6>
                                    <h2 class="mb-0">${pendingRequests + upcomingApprovals}</h2>
                                </div>
                                <i class="bi bi-exclamation-triangle fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-graph-up"></i> Thống kê phép theo tháng</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="monthlyChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-pie-chart"></i> Phân loại phép</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="leaveTypeChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
        </c:when>
        <c:when test="${dashboardType eq 'admin'}">
            <!-- Admin Dashboard -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card text-white bg-primary">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Tổng đơn</h6>
                                    <h2 class="mb-0">${totalRequests}</h2>
                                </div>
                                <i class="bi bi-file-earmark-text fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-warning">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Chờ duyệt</h6>
                                    <h2 class="mb-0">${pendingRequests}</h2>
                                </div>
                                <i class="bi bi-hourglass-split fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-info">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Tổng người dùng</h6>
                                    <h2 class="mb-0">${totalUsers}</h2>
                                </div>
                                <i class="bi bi-people fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-success">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Đang hoạt động</h6>
                                    <h2 class="mb-0">${activeUsers}</h2>
                                </div>
                                <i class="bi bi-person-check fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-bar-chart"></i> Phép theo phòng ban</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="departmentChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-calendar-range"></i> Lịch phép</h5>
                        </div>
                        <div class="card-body">
                            <div id="calendar"></div>
                        </div>
                    </div>
                </div>
            </div>
            
        </c:when>
        <c:otherwise>
            <!-- Employee Dashboard -->
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card text-white bg-warning">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Đơn chờ duyệt</h6>
                                    <h2 class="mb-0">${myPendingRequests}</h2>
                                </div>
                                <i class="bi bi-hourglass-split fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card text-white bg-success">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Đơn đã duyệt</h6>
                                    <h2 class="mb-0">${myApprovedRequests}</h2>
                                </div>
                                <i class="bi bi-check-circle fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-wallet2"></i> Số dư phép năm ${year}</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="balanceChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-calendar-range"></i> Lịch phép của tôi</h5>
                        </div>
                        <div class="card-body">
                            <div id="myCalendar"></div>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
$(document).ready(function() {
    <c:if test="${dashboardType eq 'manager'}">
        // Monthly Chart
        const monthlyCtx = document.getElementById('monthlyChart').getContext('2d');
        new Chart(monthlyCtx, {
            type: 'line',
            data: {
                labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6'],
                datasets: [{
                    label: 'Số ngày phép',
                    data: [12, 19, 15, 25, 22, 30],
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: true
                    }
                }
            }
        });
        
        // Leave Type Chart
        const leaveTypeCtx = document.getElementById('leaveTypeChart').getContext('2d');
        new Chart(leaveTypeCtx, {
            type: 'doughnut',
            data: {
                labels: ['Phép năm', 'Nghỉ ốm', 'Nghỉ cưới'],
                datasets: [{
                    data: [60, 25, 15],
                    backgroundColor: [
                        'rgba(54, 162, 235, 0.8)',
                        'rgba(255, 99, 132, 0.8)',
                        'rgba(255, 206, 86, 0.8)'
                    ]
                }]
            }
        });
    </c:if>
    
    <c:if test="${dashboardType eq 'admin'}">
        // Department Chart
        const deptCtx = document.getElementById('departmentChart').getContext('2d');
        new Chart(deptCtx, {
            type: 'bar',
            data: {
                labels: ['IT', 'QA', 'HR', 'Finance'],
                datasets: [{
                    label: 'Số ngày phép',
                    data: [120, 90, 75, 60],
                    backgroundColor: 'rgba(54, 162, 235, 0.8)'
                }]
            },
            options: {
                responsive: true
            }
        });
        
        // Calendar
        const calendarEl = document.getElementById('calendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            locale: 'vi',
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay'
            },
            events: []
        });
        calendar.render();
    </c:if>
    
    <c:if test="${dashboardType eq 'employee'}">
        // Balance Chart
        const balanceCtx = document.getElementById('balanceChart').getContext('2d');
        new Chart(balanceCtx, {
            type: 'bar',
            data: {
                labels: ['Phép năm', 'Nghỉ ốm', 'Nghỉ cưới'],
                datasets: [{
                    label: 'Đã dùng',
                    data: [5, 2, 0],
                    backgroundColor: 'rgba(255, 99, 132, 0.8)'
                }, {
                    label: 'Còn lại',
                    data: [7, 3, 3],
                    backgroundColor: 'rgba(75, 192, 192, 0.8)'
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
        
        // My Calendar
        const myCalendarEl = document.getElementById('myCalendar');
        const myCalendar = new FullCalendar.Calendar(myCalendarEl, {
            locale: 'vi',
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,listWeek'
            },
            events: []
        });
        myCalendar.render();
    </c:if>
});
</script>

<%@ include file="../layout/footer.jsp" %>

