<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Báo cáo tổng quan" />
<div class="container-fluid">
  <div class="row g-3">
    <div class="col-md-4">
      <div class="card border-0 shadow-sm">
        <div class="card-body">
          <h5 class="card-title">Tổng quan năm nay</h5>
          <c:set var="s" value="${summary.summary}" />
          <ul class="list-unstyled mb-0">
            <li><b>Tổng đơn:</b> ${s.totalRequests}</li>
            <li><b>Ngày đã duyệt:</b> ${s.approvedDays}</li>
            <li><b>Ngày chờ duyệt:</b> ${s.pendingDays}</li>
            <li><b>Ngày bị từ chối:</b> ${s.rejectedDays}</li>
          </ul>
        </div>
      </div>
    </div>
    <div class="col-md-8">
      <div class="card border-0 shadow-sm">
        <div class="card-body">
          <canvas id="chartTypes" height="120"></canvas>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  const types = ${summary.types};
  const labels = types.map(t => t.leaveTypeName);
  const counts = types.map(t => t.count);
  new Chart(document.getElementById('chartTypes'), {
    type: 'bar',
    data: { labels, datasets: [{ label: 'Số đơn', data: counts, backgroundColor: '#4dabf7' }] },
    options: { responsive: true, plugins: { legend: { display:false } } }
  });
</script>

<%@ include file="../layout/footer.jsp" %>


