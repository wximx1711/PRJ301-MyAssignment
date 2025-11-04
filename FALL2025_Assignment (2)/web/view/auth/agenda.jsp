<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    // Lấy dữ liệu từ request attribute
    List<Map<String, Object>> rows = (List<Map<String, Object>>) request.getAttribute("rows");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch Làm Việc</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css"> <!-- Kết nối với CSS -->
    <style>
        /* Cải thiện giao diện bảng */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 12px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        /* Form tìm kiếm */
        .search-container {
            margin: 20px 0;
            text-align: center;
        }
        .search-container input {
            padding: 8px;
            font-size: 16px;
            width: 30%;
            margin-right: 10px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        .search-container button {
            padding: 8px 16px;
            font-size: 16px;
            background-color: #4e73df;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-container button:hover {
            background-color: #3e5abf;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 style="text-align: center;">Lịch Làm Việc - Phòng ban</h1>

        <!-- Form tìm kiếm và lọc -->
        <div class="search-container">
            <form action="<%= request.getContextPath() %>/division/agenda" method="get">
                <input type="date" name="from" placeholder="Từ ngày" required>
                <input type="date" name="to" placeholder="Đến ngày" required>
                <button type="submit">Tìm kiếm</button>
            </form>
        </div>

        <!-- Bảng hiển thị lịch làm việc -->
        <table>
            <thead>
                <tr>
                    <th>ID Nhân Viên</th>
                    <th>Tên Nhân Viên</th>
                    <th>Ngày</th>
                    <th>Trạng Thái Nghỉ</th>
                </tr>
            </thead>
            <tbody>
                <% if (rows != null && !rows.isEmpty()) { %>
                    <% for (Map<String, Object> row : rows) { %>
                        <tr>
                            <td><%= row.get("eid") %></td>
                            <td><%= row.get("ename") %></td>
                            <td><%= row.get("day") %></td>
                            <td>
                                <% 
                                    int isLeave = (int) row.get("isLeave");
                                    String status = (isLeave == 1) ? "Đã nghỉ" : "Không nghỉ";
                                %>
                                <%= status %>
                            </td>
                        </tr>
                    <% } %>
                <% } else { %>
                    <tr><td colspan="4">Không có dữ liệu.</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
</body>
</html>
