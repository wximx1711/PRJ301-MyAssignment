<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Số dư phép" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1><i class="bi bi-wallet2"></i> Số dư phép năm ${year}</h1>
        <div>
            <select id="yearSelect" class="form-select" style="width: 150px;">
                <c:forEach var="y" begin="2020" end="2030">
                    <option value="${y}" ${y eq year ? 'selected' : ''}>${y}</option>
                </c:forEach>
            </select>
        </div>
    </div>
    
    <div class="row mb-4">
        <c:forEach var="balance" items="${balances}">
            <div class="col-md-4 mb-3">
                <div class="card h-100">
                    <div class="card-body">
                        <h5 class="card-title">${balance.leaveTypeName}</h5>
                        <div class="progress mb-2" style="height: 30px;">
                            <div class="progress-bar ${balance.remainingDays > 0 ? 'bg-success' : 'bg-danger'}" 
                                 role="progressbar" 
                                 style="width: ${(balance.remainingDays / balance.totalDays) * 100}%"
                                 aria-valuenow="${balance.remainingDays}" 
                                 aria-valuemin="0" 
                                 aria-valuemax="${balance.totalDays}">
                                ${balance.remainingDays}/${balance.totalDays} ngày
                            </div>
                        </div>
                        <div class="row text-center mt-3">
                            <div class="col-4">
                                <div class="text-muted small">Tổng</div>
                                <div class="fw-bold">${balance.totalDays}</div>
                            </div>
                            <div class="col-4">
                                <div class="text-muted small">Đã dùng</div>
                                <div class="fw-bold text-danger">${balance.usedDays}</div>
                            </div>
                            <div class="col-4">
                                <div class="text-muted small">Còn lại</div>
                                <div class="fw-bold text-success">${balance.remainingDays}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0"><i class="bi bi-bar-chart"></i> Biểu đồ số dư</h5>
        </div>
        <div class="card-body">
            <canvas id="balanceChart" style="max-height: 400px;"></canvas>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('#yearSelect').select2({
        theme: 'bootstrap-5'
    }).on('change', function() {
        window.location.href = '${pageContext.request.contextPath}/balance?year=' + $(this).val();
    });
    
    // Balance Chart
    const balanceCtx = document.getElementById('balanceChart').getContext('2d');
    const balanceData = {
        labels: [
            <c:forEach var="balance" items="${balances}" varStatus="status">
                '${balance.leaveTypeName}'<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ],
        datasets: [{
            label: 'Đã dùng',
            data: [
                <c:forEach var="balance" items="${balances}" varStatus="status">
                    ${balance.usedDays}<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ],
            backgroundColor: 'rgba(255, 99, 132, 0.8)'
        }, {
            label: 'Còn lại',
            data: [
                <c:forEach var="balance" items="${balances}" varStatus="status">
                    ${balance.remainingDays}<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ],
            backgroundColor: 'rgba(75, 192, 192, 0.8)'
        }]
    };
    
    new Chart(balanceCtx, {
        type: 'bar',
        data: balanceData,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            }
        }
    });
});
</script>

<%@ include file="../layout/footer.jsp" %>

