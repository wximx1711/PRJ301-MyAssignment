<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../layout/header.jsp" %>
<c:set var="pageTitle" value="Danh sách đơn nghỉ phép" />

<div class="container-fluid">

  <!-- Bộ lọc -->
  <div class="card border-0 shadow-sm mb-3">
    <div class="card-body">
      <form class="row g-3" method="get" action="${pageContext.request.requestURI}">
        <div class="col-md-2">
          <label class="form-label">Từ ngày</label>
          <input type="date" class="form-control" name="from" value="${from}" />
        </div>
        <div class="col-md-2">
          <label class="form-label">Đến ngày</label>
          <input type="date" class="form-control" name="to" value="${to}" />
        </div>
        <div class="col-md-3">
          <label class="form-label">Trạng thái</label>
          <select class="form-select" name="status">
            <option value="">-- Tất cả --</option>
            <option value="INPROGRESS" ${status eq 'INPROGRESS' ? 'selected' : ''}>Chờ duyệt</option>
            <option value="APPROVED" ${status eq 'APPROVED' ? 'selected' : ''}>Đã duyệt</option>
            <option value="REJECTED" ${status eq 'REJECTED' ? 'selected' : ''}>Đã từ chối</option>
          </select>
        </div>
        <div class="col-md-3">
         
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button class="btn btn-primary w-100"><i class="bi bi-filter"></i> Lọc</button>
        </div>
      </form>
    </div>
  </div>

  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1><i class="bi bi-list-ul"></i> Danh sách đơn nghỉ phép</h1>
    <a href="${pageContext.request.contextPath}/request/create" class="btn btn-primary">
      <i class="bi bi-plus-circle"></i> Tạo đơn mới
    </a>
  </div>

  <!-- Tabs -->
  <ul class="nav nav-tabs mb-4" id="requestTabs" role="tablist">
    <li class="nav-item" role="presentation">
      <button class="nav-link active" id="mine-tab" data-bs-toggle="tab" data-bs-target="#mine" type="button">
        <i class="bi bi-person"></i>
        Đơn của tôi
        (<c:out value="${empty totalMine ? 0 : totalMine}"/>)
      </button>
    </li>
    <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="subs-tab" data-bs-toggle="tab" data-bs-target="#subs" type="button">
          <i class="bi bi-people"></i>
          Đơn cần duyệt
          (<c:out value="${empty totalSubs ? 0 : totalSubs}"/>)
        </button>
      </li>
    </c:if>
  </ul>

  <div class="tab-content" id="requestTabsContent">

    <!-- Mine -->
    <div class="tab-pane fade show active" id="mine" role="tabpanel">
      <div class="card">
        <div class="card-body">
          <div class="table-responsive">
            <table id="myRequestsTable" class="table table-hover table-striped">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Tiêu đề</th>
                  <th>Lý do</th>
                  <th>Từ ngày</th>
                  <th>Đến ngày</th>
                  <th>Số ngày</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach items="${mine}" var="r">
                  <tr>
                    <td>${r.rid}</td>
                    <td><c:out value="${empty r.reason ? 'Nghỉ phép' : r.reason}"/></td>
                    <td>${r.reason}</td>
                    <td><fmt:formatDate value="${r.fromDate}" pattern="dd/MM/yyyy"/></td>
                    <td><fmt:formatDate value="${r.toDate}" pattern="dd/MM/yyyy"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty r.fromDate and not empty r.toDate}">
                          <fmt:formatNumber value="${(r.toDate.time - r.fromDate.time) / (1000*60*60*24) + 1}" type="number"/>
                          ngày
                        </c:when>
                        <c:otherwise>0 ngày</c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.status == 1}"><span class="badge bg-warning">Chờ duyệt</span></c:when>
                        <c:when test="${r.status == 2}"><span class="badge bg-success">Đã duyệt</span></c:when>
                        <c:when test="${r.status == 3}"><span class="badge bg-danger">Đã từ chối</span></c:when>
                        <c:otherwise><span class="badge bg-secondary">Không rõ</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${r.status == 1 and user.role.code eq 'ADMIN'}">
                        <button class="btn btn-sm btn-outline-danger" data-id="${r.rid}" onclick="cancelRequest(this.dataset.id)">
                          <i class="bi bi-x-circle"></i> Hủy
                        </button>
                      </c:if>
                      <button class="btn btn-sm btn-outline-info" data-id="${r.rid}" onclick="viewDetails(this.dataset.id)">
                        <i class="bi bi-eye"></i> Xem
                      </button>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>

            <!-- Paging (mine) -->
            <c:set var="curMine" value="${empty pageMine ? 1 : pageMine}" />
            <c:set var="tpMine"  value="${empty totalPagesMine ? 1 : totalPagesMine}" />
            <nav aria-label="Page navigation mine">
              <ul class="pagination justify-content-center mt-2">
                <li class="page-item ${curMine == 1 ? 'disabled' : ''}">
                  <a class="page-link" href="?pageMine=${curMine-1}&sizeMine=${sizeMine}">Prev</a>
                </li>
                <c:forEach begin="1" end="${tpMine}" var="i">
                  <li class="page-item ${i == curMine ? 'active' : ''}">
                    <a class="page-link" href="?pageMine=${i}&sizeMine=${sizeMine}">${i}</a>
                  </li>
                </c:forEach>
                <li class="page-item ${curMine >= tpMine ? 'disabled' : ''}">
                  <a class="page-link" href="?pageMine=${curMine+1 > tpMine ? tpMine : curMine+1}&sizeMine=${sizeMine}">Next</a>
                </li>
              </ul>
            </nav>

          </div>
        </div>
      </div>
    </div>

    <!-- Subs (for Manager/Leader/Admin) -->
    <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
      <div class="tab-pane fade" id="subs" role="tabpanel">
        <div class="card">
          <div class="card-body">
            <div class="table-responsive">
              <table id="subsRequestsTable" class="table table-hover table-striped">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Nhân viên</th>
                    <th>Tiêu đề</th>
                    <th>Lý do</th>
                    <th>Từ ngày</th>
                    <th>Đến ngày</th>
                    <th>Số ngày</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach items="${subs}" var="r">
                    <tr>
                      <td>${r.rid}</td>
                      <td><c:out value="${empty r.createdByName ? 'N/A' : r.createdByName}"/></td>
                      <td><c:out value="${empty r.reason ? 'Nghỉ phép' : r.reason}"/></td>
                      <td><fmt:formatDate value="${r.fromDate}" pattern="dd/MM/yyyy"/></td>
                      <td><fmt:formatDate value="${r.toDate}" pattern="dd/MM/yyyy"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${not empty r.fromDate and not empty r.toDate}">
                            <fmt:formatNumber value="${(r.toDate.time - r.fromDate.time) / (1000*60*60*24) + 1}" type="number"/>
                            ngày
                          </c:when>
                          <c:otherwise>0 ngày</c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${r.status == 1}"><span class="badge bg-warning">Chờ duyệt</span></c:when>
                          <c:when test="${r.status == 2}"><span class="badge bg-success">Đã duyệt</span></c:when>
                          <c:when test="${r.status == 3}"><span class="badge bg-danger">Đã từ chối</span></c:when>
                          <c:otherwise><span class="badge bg-secondary">Không rõ</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <c:if test="${r.status == 1 and user.role.code eq 'ADMIN'}">
                          <div class="btn-group" role="group">
                            <button class="btn btn-sm btn-success" onclick="approve(${r.rid}, 2)">
                              <i class="bi bi-check2"></i> Duyệt
                            </button>
                            <button class="btn btn-sm btn-danger" onclick="approve(${r.rid}, 3)">
                              <i class="bi bi-x"></i> Từ chối
                            </button>
                          </div>
                        </c:if>
                        <button class="btn btn-sm btn-outline-info" data-id="${r.rid}" onclick="viewDetails(this.dataset.id)">
                          <i class="bi bi-eye"></i> Xem
                        </button>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>

              <!-- Paging (subs) -->
              <c:set var="curSubs" value="${empty pageSubs ? 1 : pageSubs}" />
              <c:set var="tpSubs"  value="${empty totalPagesSubs ? 1 : totalPagesSubs}" />
              <nav aria-label="Page navigation subs">
                <ul class="pagination justify-content-center mt-2">
                  <li class="page-item ${curSubs == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?pageSubs=${curSubs-1}&sizeSubs=${sizeSubs}">Prev</a>
                  </li>
                  <c:forEach begin="1" end="${tpSubs}" var="i">
                    <li class="page-item ${i == curSubs ? 'active' : ''}">
                      <a class="page-link" href="?pageSubs=${i}&sizeSubs=${sizeSubs}">${i}</a>
                    </li>
                  </c:forEach>
                  <li class="page-item ${curSubs >= tpSubs ? 'disabled' : ''}">
                    <a class="page-link" href="?pageSubs=${curSubs+1 > tpSubs ? tpSubs : curSubs+1}&sizeSubs=${sizeSubs}">Next</a>
                  </li>
                </ul>
              </nav>

            </div>
          </div>
        </div>
      </div>
    </c:if>

  </div>
</div>

<script>
function cancelRequest(requestId) {
  if (confirm('Bạn có chắc chắn muốn hủy đơn này?')) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/request/cancel';
    form.innerHTML = '<input type="hidden" name="rid" value="' + requestId + '"/>';
    document.body.appendChild(form);
    form.submit();
  }
}
function viewDetails(requestId) {
  window.location.href = '${pageContext.request.contextPath}/request/view?id=' + requestId;
}
function approve(rid, status) {
  if (!window.Swal) return submitApprove(rid,status);
  Swal.fire({
    title: status==2?'Duyệt đơn?':'Từ chối đơn?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Xác nhận'
  }).then(r=>{ if(r.isConfirmed) submitApprove(rid,status); });
}
function submitApprove(rid,status){
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/request/review';
  form.innerHTML =
    '<input type="hidden" name="rid" value="'+rid+'"/>' +
    '<input type="hidden" name="status" value="'+status+'"/>' +
    '<input type="hidden" name="note" value=""/>';
  document.body.appendChild(form);
  form.submit();
}
</script>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script>flatpickr("input[type=date]", {});</script>

<%@ include file="../layout/footer.jsp" %>
