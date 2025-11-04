<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/header.jsp" %>

<c:set var="pageTitle" value="Thông báo" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1><i class="bi bi-bell"></i> Thông báo</h1>
        <div>
            <button class="btn btn-primary" onclick="markAllAsRead()">
                <i class="bi bi-check-all"></i> Đánh dấu tất cả đã đọc
            </button>
        </div>
    </div>
    
    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table id="notificationsTable" class="table table-hover">
                    <thead>
                        <tr>
                            <th>Trạng thái</th>
                            <th>Tiêu đề</th>
                            <th>Nội dung</th>
                            <th>Thời gian</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="notif" items="${notifications}">
                            <tr class="${notif.read ? '' : 'table-warning'}">
                                <td>
                                    <c:if test="${not notif.read}">
                                        <span class="badge bg-danger">Mới</span>
                                    </c:if>
                                    <c:if test="${notif.read}">
                                        <span class="badge bg-secondary">Đã đọc</span>
                                    </c:if>
                                </td>
                                <td><strong>${notif.title}</strong></td>
                                <td>${notif.message}</td>
                                <td>
                                    <script>
                                        document.write(moment('${notif.createdAt}').format('DD/MM/YYYY HH:mm'));
                                    </script>
                                </td>
                                <td>
                                    <c:if test="${not notif.read}">
                                        <button class="btn btn-sm btn-outline-primary" onclick="markAsRead(${notif.id})">
                                            <i class="bi bi-check"></i> Đánh dấu đã đọc
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('#notificationsTable').DataTable({
        language: {
            url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/vi.json'
        },
        order: [[3, 'desc']],
        pageLength: 25
    });
});

function markAsRead(notificationId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/api/notifications',
        type: 'POST',
        data: {
            action: 'mark-read',
            id: notificationId
        },
        success: function() {
            toastr.success('Đã đánh dấu đã đọc');
            location.reload();
        },
        error: function() {
            toastr.error('Có lỗi xảy ra');
        }
    });
}

function markAllAsRead() {
    // Implementation for marking all as read
    toastr.info('Tính năng đang phát triển');
}
</script>

<%@ include file="../layout/footer.jsp" %>

