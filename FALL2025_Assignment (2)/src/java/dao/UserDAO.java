package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Role;
import model.User;
import util.DBConnection;

public class UserDAO {
    public User authenticate(String username, String passwordHash) throws SQLException {
        String sql = "SELECT u.*, r.code as role_code, r.name as role_name, d.name as department_name " +
                    "FROM Users u " +
                    "JOIN Roles r ON r.id = u.role_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "WHERE u.username = ? AND u.password_hash = ? AND u.is_active = 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }
    
    public User getById(int id) throws SQLException {
        String sql = "SELECT u.*, r.code as role_code, r.name as role_name, d.name as department_name " +
                    "FROM Users u " +
                    "JOIN Roles r ON r.id = u.role_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "WHERE u.id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }
    
    public List<User> getByDepartmentId(int departmentId) throws SQLException {
        String sql = "SELECT u.*, r.code as role_code, r.name as role_name, d.name as department_name " +
                    "FROM Users u " +
                    "JOIN Roles r ON r.id = u.role_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "WHERE u.department_id = ? AND u.is_active = 1";
        
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, departmentId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        }
        return users;
    }
    
    public List<User> getByManagerId(int managerId) throws SQLException {
        String sql = "SELECT u.*, r.code as role_code, r.name as role_name, d.name as department_name " +
                    "FROM Users u " +
                    "JOIN Roles r ON r.id = u.role_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "WHERE u.manager_id = ? AND u.is_active = 1";
        
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, managerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        }
        return users;
    }
    
    public void updatePassword(int userId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE Users SET password_hash = ? WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            
            ps.executeUpdate();
        }
    }
    
    public void toggleActive(int userId) throws SQLException {
        String sql = "UPDATE Users SET is_active = ~is_active WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
    
    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setFullName(rs.getString("full_name"));
        user.setDepartmentId(rs.getInt("department_id"));
        user.setDepartmentName(rs.getString("department_name"));
        
        Role role = new Role();
        role.setId(rs.getInt("role_id"));
        role.setCode(rs.getString("role_code"));
        role.setName(rs.getString("role_name"));
        user.setRole(role);
        
        Integer managerId = rs.getInt("manager_id");
        if (!rs.wasNull()) {
            user.setManagerId(managerId);
        }
        
        user.setActive(rs.getBoolean("is_active"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        
        return user;
    }
}