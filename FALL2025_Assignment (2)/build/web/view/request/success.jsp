<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String msg = (String) request.getAttribute("successMsg");
    if (msg == null) msg = "Yêu cầu đã được gửi thành công.";
%>
<%@ include file="../layout/header.jsp" %>

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-body text-center">
                    <h4 class="card-title text-success"><i class="bi bi-check-circle"></i> Thành công</h4>
                    <p class="card-text"><%= msg %></p>

                    <div class="d-flex justify-content-center gap-2">
                        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Về trang chủ</a>
                        <a href="${pageContext.request.contextPath}/request/list" class="btn btn-outline-secondary">Xem danh sách đơn</a>
                    </div>

                    <div class="mt-3">
                        <a href="${pageContext.request.contextPath}/request/create" class="btn btn-link">Tạo đơn khác</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
