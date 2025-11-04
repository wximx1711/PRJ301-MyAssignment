<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Báo cáo" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1><i class="bi bi-graph-up"></i> Báo cáo và thống kê</h1>
        <div>
            <select id="yearSelect" class="form-select" style="width: 150px;">
                <c:forEach var="y" begin="2020" end="2030">
                    <option value="${y}" ${y eq year ? 'selected' : ''}>${y}</option>
                </c:forEach>
            </select>
        </div>
    </div>
    
    <ul class="nav nav-tabs mb-4" id="reportTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="summary-tab" data-bs-toggle="tab" data-bs-target="#summary" type="button">
                <i class="bi bi-bar-chart"></i> Tổng quan
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="statistics-tab" data-bs-toggle="tab" data-bs-target="#statistics" type="button">
                <i class="bi bi-pie-chart"></i> Thống kê
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="usage-tab" data-bs-toggle="tab" data-bs-target="#usage" type="button">
                <i class="bi bi-graph-up-arrow"></i> Xu hướng sử dụng
            </button>
        </li>
    </ul>
    
    <div class="tab-content" id="reportTabsContent">
        <div class="tab-pane fade show active" id="summary" role="tabpanel">
            <div class="row">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">Tổng quan</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="summaryChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">Phân loại phép</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="leaveTypePieChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="tab-pane fade" id="statistics" role="tabpanel">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Thống kê theo phòng ban</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table id="statisticsTable" class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Phòng ban</th>
                                    <th>Loại phép</th>
                                    <th>Tổng đơn</th>
                                    <th>Đã duyệt</th>
                                    <th>Chờ duyệt</th>
                                    <th>Đã từ chối</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="stat" items="${statistics}">
                                    <tr>
                                        <td>${stat.departmentName}</td>
                                        <td>${stat.leaveTypeName}</td>
                                        <td>${stat.totalRequests}</td>
                                        <td>${stat.approvedDays}</td>
                                        <td>${stat.pendingDays}</td>
                                        <td>${stat.rejectedDays}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="tab-pane fade" id="usage" role="tabpanel">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Xu hướng sử dụng phép</h5>
                </div>
                <div class="card-body">
                    <canvas id="usageChart"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('#yearSelect').select2({
        theme: 'bootstrap-5'
    }).on('change', function() {
        window.location.href = '${pageContext.request.contextPath}/reports?year=' + $(this).val();
    });
    
    $('#statisticsTable').DataTable({
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/vi.json'
        },
        order: [[0, 'asc']]
    });
    
    // Summary Chart
    const summaryCtx = document.getElementById('summaryChart').getContext('2d');
    new Chart(summaryCtx, {
        type: 'bar',
        data: {
            labels: ['Tổng đơn', 'Đã duyệt', 'Chờ duyệt', 'Đã từ chối'],
            datasets: [{
                label: 'Số lượng',
                data: [100, 70, 20, 10],
                backgroundColor: [
                    'rgba(54, 162, 235, 0.8)',
                    'rgba(75, 192, 192, 0.8)',
                    'rgba(255, 206, 86, 0.8)',
                    'rgba(255, 99, 132, 0.8)'
                ]
            }]
        },
        options: {
            responsive: true
        }
    });
    
    // Leave Type Pie Chart
    const pieCtx = document.getElementById('leaveTypePieChart').getContext('2d');
    new Chart(pieCtx, {
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
    
    // Usage Chart
    const usageCtx = document.getElementById('usageChart').getContext('2d');
    new Chart(usageCtx, {
        type: 'line',
        data: {
            labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6'],
            datasets: [{
                label: 'Số ngày phép',
                data: [12, 19, 15, 25, 22, 30],
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                tension: 0.1,
                fill: true
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
});
</script>

<%@ include file="../layout/footer.jsp" %>

