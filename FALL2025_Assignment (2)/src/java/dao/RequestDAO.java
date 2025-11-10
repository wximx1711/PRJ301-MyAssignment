package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Request;
import util.DBConnection;

public class RequestDAO {
    public void create(Request request) throws SQLException {
        String sql = "INSERT INTO Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by) " +
                    "VALUES (?, ?, ?, ?, ?, ?, 'INPROGRESS', ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, request.getEmployeeId());
            ps.setInt(2, request.getTypeId());
            ps.setString(3, request.getTitle());
            ps.setString(4, request.getReason());
            ps.setDate(5, request.getStartDate());
            ps.setDate(6, request.getEndDate());
            ps.setInt(7, request.getCreatedBy());
            
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    request.setId(rs.getInt(1));
                }
            }
        }
    }
    
    public void updateStatus(int requestId, String status, Integer processedBy, String managerNote) throws SQLException {
        String sql = "UPDATE Requests SET status = ?, processed_by = ?, manager_note = ?, processed_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            if (processedBy != null) {
                ps.setInt(2, processedBy);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, managerNote);
            ps.setInt(4, requestId);
            
            ps.executeUpdate();
        }
    }
    
    public Request getById(int id) throws SQLException {
        String sql = "SELECT r.*, u.full_name as employee_name, lt.name as type_name, " +
                    "d.name as department_name, c.full_name as created_by_name, " +
                    "p.full_name as processed_by_name " +
                    "FROM Requests r " +
                    "JOIN Users u ON u.id = r.employee_id " +
                    "JOIN LeaveTypes lt ON lt.id = r.type_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "JOIN Users c ON c.id = r.created_by " +
                    "LEFT JOIN Users p ON p.id = r.processed_by " +
                    "WHERE r.id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRequest(rs);
                }
            }
        }
        return null;
    }
    
    public List<Request> getByEmployeeId(int employeeId) throws SQLException {
        String sql = "SELECT r.*, u.full_name as employee_name, lt.name as type_name, " +
                    "d.name as department_name, c.full_name as created_by_name, " +
                    "p.full_name as processed_by_name " +
                    "FROM Requests r " +
                    "JOIN Users u ON u.id = r.employee_id " +
                    "JOIN LeaveTypes lt ON lt.id = r.type_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "JOIN Users c ON c.id = r.created_by " +
                    "LEFT JOIN Users p ON p.id = r.processed_by " +
                    "WHERE r.employee_id = ? " +
                    "ORDER BY r.created_at DESC";
        
        List<Request> requests = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, employeeId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRequest(rs));
                }
            }
        }
        return requests;
    }
    
    public List<Request> getPendingByManagerId(int managerId) throws SQLException {
        String sql = "SELECT r.*, u.full_name as employee_name, lt.name as type_name, " +
                    "d.name as department_name, c.full_name as created_by_name, " +
                    "p.full_name as processed_by_name " +
                    "FROM Requests r " +
                    "JOIN Users u ON u.id = r.employee_id " +
                    "JOIN LeaveTypes lt ON lt.id = r.type_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "JOIN Users c ON c.id = r.created_by " +
                    "LEFT JOIN Users p ON p.id = r.processed_by " +
                    "WHERE u.manager_id = ? AND r.status = 'INPROGRESS' " +
                    "ORDER BY r.created_at DESC";
        
        List<Request> requests = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, managerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRequest(rs));
                }
            }
        }
        return requests;
    }
    
    private Request mapRequest(ResultSet rs) throws SQLException {
        Request request = new Request();
        request.setId(rs.getInt("id"));
        request.setEmployeeId(rs.getInt("employee_id"));
        request.setTypeId(rs.getInt("type_id"));
        request.setTitle(rs.getString("title"));
        request.setReason(rs.getString("reason"));
        request.setStartDate(rs.getDate("start_date"));
        request.setEndDate(rs.getDate("end_date"));
        request.setStatus(rs.getString("status"));
        request.setManagerNote(rs.getString("manager_note"));
        request.setCreatedAt(rs.getTimestamp("created_at"));
        request.setCreatedBy(rs.getInt("created_by"));
        request.setProcessedAt(rs.getTimestamp("processed_at"));
        
        Integer processedBy = rs.getInt("processed_by");
        if (!rs.wasNull()) {
            request.setProcessedBy(processedBy);
        }
        
        request.setDurationDays(rs.getInt("duration_days"));
        request.setEmployeeName(rs.getString("employee_name"));
        request.setTypeName(rs.getString("type_name"));
        request.setDepartmentName(rs.getString("department_name"));
        request.setCreatedByName(rs.getString("created_by_name"));
        request.setProcessedByName(rs.getString("processed_by_name"));
        
        return request;
    }

    public Request get(int requestId) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    public void delete(int requestId) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}