package dal;

import dal.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportDBContext extends DBContext {
    
    public List<Map<String, Object>> getLeaveStatisticsByDepartment(int year) throws SQLException {
        List<Map<String, Object>> statistics = new ArrayList<>();
        String sql = "SELECT * FROM vw_LeaveStatisticsByDepartment WHERE year = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, year);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("departmentId", rs.getInt("department_id"));
                    stat.put("departmentName", rs.getString("department_name"));
                    stat.put("leaveTypeId", rs.getInt("leave_type_id"));
                    stat.put("leaveTypeName", rs.getString("leave_type_name"));
                    stat.put("year", rs.getInt("year"));
                    stat.put("totalRequests", rs.getInt("total_requests"));
                    stat.put("approvedDays", rs.getInt("approved_days"));
                    stat.put("pendingDays", rs.getInt("pending_days"));
                    stat.put("rejectedDays", rs.getInt("rejected_days"));
                    statistics.add(stat);
                }
            }
        }
        return statistics;
    }
    
    public List<Map<String, Object>> getLeaveUsageTrends(int year) throws SQLException {
        List<Map<String, Object>> trends = new ArrayList<>();
        String sql = "SELECT MONTH(start_date) as month, " +
                    "SUM(duration_days) as total_days, " +
                    "COUNT(*) as total_requests " +
                    "FROM Requests " +
                    "WHERE YEAR(start_date) = ? AND status = 'APPROVED' " +
                    "GROUP BY MONTH(start_date) " +
                    "ORDER BY month";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, year);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> trend = new HashMap<>();
                    trend.put("month", rs.getInt("month"));
                    trend.put("totalDays", rs.getInt("total_days"));
                    trend.put("totalRequests", rs.getInt("total_requests"));
                    trends.add(trend);
                }
            }
        }
        return trends;
    }
    
    public Map<String, Object> getLeaveSummary(int year) throws SQLException {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT " +
                    "COUNT(*) as total_requests, " +
                    "SUM(CASE WHEN status = 'APPROVED' THEN duration_days ELSE 0 END) as approved_days, " +
                    "SUM(CASE WHEN status = 'INPROGRESS' THEN duration_days ELSE 0 END) as pending_days, " +
                    "SUM(CASE WHEN status = 'REJECTED' THEN duration_days ELSE 0 END) as rejected_days " +
                    "FROM Requests " +
                    "WHERE YEAR(start_date) = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, year);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.put("totalRequests", rs.getInt("total_requests"));
                    summary.put("approvedDays", rs.getInt("approved_days"));
                    summary.put("pendingDays", rs.getInt("pending_days"));
                    summary.put("rejectedDays", rs.getInt("rejected_days"));
                }
            }
        }
        return summary;
    }

    public Map<String, Object> getSummary() {
        int year = java.time.LocalDate.now().getYear();
        try {
            Map<String, Object> res = new HashMap<>();
            res.put("summary", getLeaveSummary(year));
            res.put("trends", getLeaveUsageTrends(year));
            res.put("types", getChartData(year));
            return res;
        } catch (SQLException e) {
            throw new RuntimeException("Error building report overview", e);
        }
    }
    
    public List<Map<String, Object>> getChartData(int year) throws SQLException {
        List<Map<String, Object>> chartData = new ArrayList<>();
        String sql = "SELECT lt.name as leave_type_name, " +
                    "COUNT(*) as count, " +
                    "SUM(duration_days) as total_days " +
                    "FROM Requests r " +
                    "JOIN LeaveTypes lt ON r.type_id = lt.id " +
                    "WHERE YEAR(r.start_date) = ? " +
                    "GROUP BY lt.name";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, year);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("leaveTypeName", rs.getString("leave_type_name"));
                    data.put("count", rs.getInt("count"));
                    data.put("totalDays", rs.getInt("total_days"));
                    chartData.add(data);
                }
            }
        }
        return chartData;
    }
}

