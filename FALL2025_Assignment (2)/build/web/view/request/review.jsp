<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.List" %>
<%@ page import="model.RequestForLeave" %>
<%
    List<RequestForLeave> requests = (List<RequestForLeave>) request.getAttribute("requests");
%>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Duyệt đơn" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1><i class="bi bi-check-circle"></i> Duyệt đơn</h1>
        <div>
            <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Quay lại danh sách
            </a>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Người tạo</th>
                            <th>Lý do</th>
                            <th>Từ ngày</th>
                            <th>Đến ngày</th>
                            <th>Số ngày</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${not empty requests}">
                            <c:forEach var="r" items="${requests}">
                                <tr>
                                    <td>${r.rid}</td>
                                    <td>${r.createdByName}</td>
                                    <td>${r.reason}</td>
                                    <td><c:out value="${r.fromDate}"/></td>
                                    <td><c:out value="${r.toDate}"/></td>
                                    <td>
                                        <% 
                                            java.util.Date fd = (java.util.Date) r.getFromDate();
                                            java.util.Date td = (java.util.Date) r.getToDate();
                                            int days = 0;
                                            if (fd != null && td != null) {
                                                long diff = td.getTime() - fd.getTime();
                                                days = (int)(diff / (1000L*60L*60L*24L)) + 1;
                                            }
                                        %>
                                        <%= days %>
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
                                        <form method="post" action="${pageContext.request.contextPath}/request/review" class="d-flex gap-2 align-items-start">
                                            <input type="hidden" name="rid" value="${r.rid}" />
                                            <select name="status" class="form-select form-select-sm" style="width:120px;">
                                                <option value="2">Duyệt</option>
                                                <option value="3">Từ chối</option>
                                            </select>
                                            <input type="text" name="note" class="form-control form-control-sm" placeholder="Ghi chú (tùy chọn)" />
                                            <button type="submit" class="btn btn-sm btn-primary">Gửi</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:if>
                        <c:if test="${empty requests}">
                            <tr><td colspan="8" class="text-center">Không có đơn cần duyệt</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
