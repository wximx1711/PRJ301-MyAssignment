<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.RequestForLeave" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<RequestForLeave> mine = (List<RequestForLeave>) request.getAttribute("mine");
    List<RequestForLeave> subs = (List<RequestForLeave>) request.getAttribute("subs");
    model.iam.User __u = (model.iam.User) session.getAttribute("user");
%>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Danh sách đơn nghỉ phép" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1><i class="bi bi-list-ul"></i> Danh sách đơn nghỉ phép</h1>
        <a href="${pageContext.request.contextPath}/request/create" class="btn btn-primary">
            <i class="bi bi-plus-circle"></i> Tạo đơn mới
        </a>
    </div>
    
    <ul class="nav nav-tabs mb-4" id="requestTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="mine-tab" data-bs-toggle="tab" data-bs-target="#mine" type="button">
                <i class="bi bi-person"></i> Đơn của tôi (<%= request.getAttribute("totalMine") != null ? request.getAttribute("totalMine") : 0 %>)
            </button>
        </li>
        <c:if test="${user.role.code eq 'MANAGER' or user.role.code eq 'LEADER' or user.role.code eq 'ADMIN'}">
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="subs-tab" data-bs-toggle="tab" data-bs-target="#subs" type="button">
                    <i class="bi bi-people"></i> Đơn cần duyệt (<%= request.getAttribute("totalSubs") != null ? request.getAttribute("totalSubs") : 0 %>)
                </button>
            </li>
        </c:if>
    </ul>

    <div class="tab-content" id="requestTabsContent">
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
                                <% if (mine != null) { %>
                                    <% for (RequestForLeave r : mine) { %>
                                        <tr>
                                            <td><%= r.getRid() %></td>
                                            <td><%= r.getReason() != null ? r.getReason() : "Nghỉ phép" %></td>
                                            <td><%= r.getReason() %></td>
                                            <td><%= r.getFromDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getFromDate()) : "" %></td>
                                            <td><%= r.getToDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getToDate()) : "" %></td>
                                            <td>
                                                <%= (r.getFromDate() != null && r.getToDate() != null) ? ((int)((r.getToDate().getTime() - r.getFromDate().getTime()) / (1000*60*60*24) + 1)) : 0 %> ngày
                                            </td>
                                            <td>
                                                <% if (r.getStatus() == 1) { %>
                                                    <span class="badge bg-warning">Chờ duyệt</span>
                                                <% } else if (r.getStatus() == 2) { %>
                                                    <span class="badge bg-success">Đã duyệt</span>
                                                <% } else if (r.getStatus() == 3) { %>
                                                    <span class="badge bg-danger">Đã từ chối</span>
                                                <% } else { %>
                                                    <span class="badge bg-secondary">Không rõ</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                    <% if (r.getStatus() == 1 && __u != null && __u.getRole() != null && "ADMIN".equals(__u.getRole().getCode())) { %>
                                                        <button class="btn btn-sm btn-outline-danger" data-id="<%= r.getRid() %>" onclick="cancelRequest(this.dataset.id)">
                                                            <i class="bi bi-x-circle"></i> Hủy
                                                        </button>
                                                    <% } %>
                                                    <button class="btn btn-sm btn-outline-info" data-id="<%= r.getRid() %>" onclick="viewDetails(this.dataset.id)">
                                                        <i class="bi bi-eye"></i> Xem
                                                    </button>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } %>
                            </tbody>
                        </table>
                        <!-- Paging for mine -->
                        <nav aria-label="Page navigation mine">
                            <ul class="pagination justify-content-center mt-2">
                                <li class="page-item <%= (Integer)request.getAttribute("pageMine") == 1 ? "disabled" : "" %>">
                                    <a class="page-link" href="?pageMine=<%= Math.max(1, (Integer)request.getAttribute("pageMine") - 1) %>&sizeMine=<%=request.getAttribute("sizeMine")%>">Prev</a>
                                </li>
                                <% int tpMine = (request.getAttribute("totalPagesMine") != null) ? (Integer)request.getAttribute("totalPagesMine") : 1; int curMine = (request.getAttribute("pageMine") != null) ? (Integer)request.getAttribute("pageMine") : 1; %>
                                <% for (int i = 1; i <= tpMine; i++) { %>
                                    <li class="page-item <%= (i == curMine) ? "active" : "" %>"><a class="page-link" href="?pageMine=<%=i%>&sizeMine=<%=request.getAttribute("sizeMine")%>"><%=i%></a></li>
                                <% } %>
                                <li class="page-item <%= curMine >= tpMine ? "disabled" : "" %>">
                                    <a class="page-link" href="?pageMine=<%= Math.min(tpMine, curMine + 1) %>&sizeMine=<%=request.getAttribute("sizeMine")%>">Next</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </div>
        </div>
        
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
                                    <% if (subs != null) { %>
                                        <% for (RequestForLeave r : subs) { %>
                                            <tr>
                                                <td><%= r.getRid() %></td>
                                                <td><%= r.getCreatedByName() != null ? r.getCreatedByName() : "N/A" %></td>
                                                <td><%= r.getReason() != null ? r.getReason() : "Nghỉ phép" %></td>
                                                <td><%= r.getFromDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getFromDate()) : "" %></td>
                                                <td><%= r.getToDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getToDate()) : "" %></td>
                                                <td><%= (r.getFromDate() != null && r.getToDate() != null) ? ((int)((r.getToDate().getTime() - r.getFromDate().getTime()) / (1000*60*60*24) + 1)) : 0 %> ngày</td>
                                                <td>
                                                    <% if (r.getStatus() == 1) { %>
                                                        <span class="badge bg-warning">Chờ duyệt</span>
                                                    <% } else if (r.getStatus() == 2) { %>
                                                        <span class="badge bg-success">Đã duyệt</span>
                                                    <% } else if (r.getStatus() == 3) { %>
                                                        <span class="badge bg-danger">Đã từ chối</span>
                                                    <% } else { %>
                                                        <span class="badge bg-secondary">Không rõ</span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <% if (r.getStatus() == 1 && __u != null && __u.getRole() != null && "ADMIN".equals(__u.getRole().getCode())) { %>
                                                        <div class="btn-group" role="group">
                                                            <button class="btn btn-sm btn-success" onclick="approve(<%= r.getRid() %>, 2)">
                                                                <i class="bi bi-check2"></i> Duyệt
                                                            </button>
                                                            <button class="btn btn-sm btn-danger" onclick="approve(<%= r.getRid() %>, 3)">
                                                                <i class="bi bi-x"></i> Từ chối
                                                            </button>
                                                        </div>
                                                    <% } %>
                                                    <button class="btn btn-sm btn-outline-info" data-id="<%= r.getRid() %>" onclick="viewDetails(this.dataset.id)">
                                                        <i class="bi bi-eye"></i> Xem
                                                    </button>
                                                </td>
                                            </tr>
                                        <% } %>
                                    <% } %>
                                </tbody>
                            </table>
                            <!-- Paging for subs -->
                            <nav aria-label="Page navigation subs">
                                <ul class="pagination justify-content-center mt-2">
                                    <li class="page-item <%= (Integer)request.getAttribute("pageSubs") == 1 ? "disabled" : "" %>">
                                        <a class="page-link" href="?pageSubs=<%= Math.max(1, (Integer)request.getAttribute("pageSubs") - 1) %>&sizeSubs=<%=request.getAttribute("sizeSubs")%>">Prev</a>
                                    </li>
                                    <% int tpSubs = (request.getAttribute("totalPagesSubs") != null) ? (Integer)request.getAttribute("totalPagesSubs") : 1; int curSubs = (request.getAttribute("pageSubs") != null) ? (Integer)request.getAttribute("pageSubs") : 1; %>
                                    <% for (int i = 1; i <= tpSubs; i++) { %>
                                        <li class="page-item <%= (i == curSubs) ? "active" : "" %>"><a class="page-link" href="?pageSubs=<%=i%>&sizeSubs=<%=request.getAttribute("sizeSubs")%>"><%=i%></a></li>
                                    <% } %>
                                    <li class="page-item <%= curSubs >= tpSubs ? "disabled" : "" %>">
                                        <a class="page-link" href="?pageSubs=<%= Math.min(tpSubs, curSubs + 1) %>&sizeSubs=<%=request.getAttribute("sizeSubs")%>">Next</a>
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
// Optional: you can enable client-side table enhancement here (DataTables) but
// server-side paging is used for the requests tables. Keeping tables plain
// ensures predictable pagination controlled by the server.

function cancelRequest(requestId) {
    if (confirm('Bạn có chắc chắn muốn hủy đơn này?')) {
        // Implementation for canceling request
        toastr.info('Tính năng đang phát triển');
    }
}

function viewDetails(requestId) {
    window.location.href = '${pageContext.request.contextPath}/request/view?id=' + requestId;
}

function approve(rid, status) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/request/review';
    const idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'rid';
    idInput.value = rid;
    const statusInput = document.createElement('input');
    statusInput.type = 'hidden';
    statusInput.name = 'status';
    statusInput.value = status;
    const noteInput = document.createElement('input');
    noteInput.type = 'hidden';
    noteInput.name = 'note';
    noteInput.value = '';
    form.appendChild(idInput);
    form.appendChild(statusInput);
    form.appendChild(noteInput);
    document.body.appendChild(form);
    form.submit();
}
</script>

<%@ include file="../layout/footer.jsp" %>
