<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%
    String msg = (String) request.getAttribute("msg");
    String error = (String) request.getAttribute("error");
%>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Quên mật khẩu" />

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card">
                <div class="card-body">
                    <h3>Yêu cầu quên mật khẩu</h3>
                    <p>Nhập tên đăng nhập của bạn. Yêu cầu sẽ được gửi tới quản trị viên để xử lý (admin sẽ chỉ đặt mật khẩu mới).</p>

                    <% if (error != null) { %>
                        <div class="alert alert-danger"><%= error %></div>
                    <% } %>
                    <% if (msg != null) { %>
                        <div class="alert alert-success"><%= msg %></div>
                    <% } %>

                    <form method="post" action="<%= pageContext.getRequest().getContextPath() %>/auth/forgot">
                        <div class="mb-3">
                            <label class="form-label">Tên đăng nhập</label>
                            <input type="text" name="username" class="form-control" required />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Ghi chú (tùy chọn)</label>
                            <input type="text" name="note" class="form-control" />
                        </div>
                        <div class="d-flex gap-2">
                            <button class="btn btn-primary" type="submit">Gửi yêu cầu</button>
                            <a class="btn btn-secondary" href="<%= pageContext.getRequest().getContextPath() %>/login">Quay lại đăng nhập</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>
