<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.RequestForLeave" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Duyệt đơn" />

<%
    RequestForLeave r = (RequestForLeave) request.getAttribute("request");
%>

<div class="container-fluid">
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white">
            <h4 class="mb-0"><i class="bi bi-check-circle"></i> Duyệt đơn nghỉ phép</h4>
        </div>
        <div class="card-body">
            <c:if test="${not empty message}">
                <div class="alert alert-danger">${message}</div>
            </c:if>
            <c:if test="${empty message}">
                <dl class="row mb-4">
                    <dt class="col-sm-3">Mã đơn</dt>
                    <dd class="col-sm-9"><%= r != null ? r.getRid() : "" %></dd>

                    <dt class="col-sm-3">Nhân viên</dt>
                    <dd class="col-sm-9"><%= r != null && r.getCreatedByName()!=null ? r.getCreatedByName() : "N/A" %></dd>

                    <dt class="col-sm-3">Từ ngày</dt>
                    <dd class="col-sm-9"><%= r!=null && r.getFromDate()!=null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getFromDate()) : "" %></dd>

                    <dt class="col-sm-3">Đến ngày</dt>
                    <dd class="col-sm-9"><%= r!=null && r.getToDate()!=null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getToDate()) : "" %></dd>

                    <dt class="col-sm-3">Lý do</dt>
                    <dd class="col-sm-9"><%= r!=null ? r.getReason() : "" %></dd>
                </dl>

                <form method="post" action="${pageContext.request.contextPath}/request/review">
                    <input type="hidden" name="rid" value="<%= r!=null ? r.getRid() : 0 %>">
                    <div class="mb-3">
                        <label class="form-label">Ghi chú</label>
                        <textarea name="note" class="form-control" rows="3" placeholder="Ghi chú cho quyết định"></textarea>
                    </div>
                    <div class="d-flex gap-2">
                        <button name="status" value="2" class="btn btn-success"><i class="bi bi-check2"></i> Phê duyệt</button>
                        <button name="status" value="3" class="btn btn-danger"><i class="bi bi-x"></i> Từ chối</button>
                        <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-secondary">Quay lại</a>
                    </div>
                </form>
            </c:if>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
