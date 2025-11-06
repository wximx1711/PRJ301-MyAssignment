<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Agenda phòng ban" />

<div class="container-fluid">
  <div class="card border-0 shadow-sm mb-3">
    <div class="card-body">
      <form class="row g-3" method="get" action="${pageContext.request.contextPath}/division/agenda">
        <div class="col-md-3">
          <label class="form-label">Phòng ban</label>
          <select class="form-select" name="did">
            <c:forEach items="${departments}" var="d">
              <option value="${d.id}" ${did == d.id ? 'selected' : ''}>${d.name}</option>
            </c:forEach>
          </select>
        </div>
        <div class="col-md-3">
          <label class="form-label">Từ ngày</label>
          <input type="date" name="from" class="form-control" value="${from}"/>
        </div>
        <div class="col-md-3">
          <label class="form-label">Đến ngày</label>
          <input type="date" name="to" class="form-control" value="${to}"/>
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button class="btn btn-primary w-100"><i class="bi bi-search"></i> Xem</button>
        </div>
      </form>
    </div>
  </div>

  <div class="card border-0 shadow-sm">
    <div class="card-body">
      <div id="calendar"></div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/locales/vi.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    var calendarEl = document.getElementById('calendar');
    var calendar = new FullCalendar.Calendar(calendarEl, {
      locale: 'vi',
      initialView: 'dayGridMonth',
      headerToolbar: { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek' },
      events: [
        <c:forEach items="${rows}" var="r" varStatus="i">
        {
          title: '${r.ename} nghỉ',
          start: '${r.day}',
          allDay: true,
          color: '#ff6b6b'
        }<c:if test="${!i.last}">,</c:if>
        </c:forEach>
      ]
    });
    calendar.render();
  });
</script>

<%@ include file="../layout/footer.jsp" %>


