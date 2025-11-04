<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.Date" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String msg = (String) request.getAttribute("msg");
%>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Tạo đơn nghỉ phép" />

<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><i class="bi bi-file-earmark-plus"></i> Tạo Đơn Nghỉ Phép</h4>
                    <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-secondary btn-sm">Quay lại</a>
                </div>
                <div class="card-body">
                    <% if (msg != null) { %>
                        <div class="alert alert-danger"><%= msg %></div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/request/create" method="post" class="row g-3">
                        <div class="col-md-6">
                            <label for="from" class="form-label">Ngày bắt đầu</label>
                            <input type="date" class="form-control" id="from" name="from" required>
                        </div>

                        <div class="col-md-6">
                            <label for="to" class="form-label">Ngày kết thúc</label>
                            <input type="date" class="form-control" id="to" name="to" required>
                        </div>

                        <div class="col-12">
                            <label for="reason" class="form-label">Lý do nghỉ</label>
                            <textarea id="reason" name="reason" class="form-control" rows="5" required></textarea>
                        </div>

                        <div class="col-12 d-flex gap-2">
                            <button type="submit" class="btn btn-primary">Tạo Đơn Nghỉ</button>
                            <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-secondary">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
