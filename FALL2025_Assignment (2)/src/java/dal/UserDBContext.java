package dal;

import java.sql.*;
import model.iam.Department;
import model.iam.Role;
import model.iam.User;

public class UserDBContext extends DBContext {

    public User get(String username, String password) {
        String sql = """
            SELECT TOP 1 u.id, u.username, u.full_name, u.role_id, u.department_id,
                   r.code as role_code, r.name as role_name,
                   d.name as department_name
            FROM Users u 
            JOIN Roles r ON r.id = u.role_id
            JOIN Departments d ON d.id = u.department_id
            WHERE u.username = ? AND u.password_hash = ? AND u.is_active = 1
        """;
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, username.trim());
            stm.setString(2, password.trim());
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                
                Role role = new Role();
                role.setId(rs.getInt("role_id"));
                role.setCode(rs.getString("role_code"));
                role.setName(rs.getString("role_name"));
                u.setRole(role);
                
                Department dept = new Department();
                dept.setId(rs.getInt("department_id"));
                dept.setName(rs.getString("department_name"));
                u.setDepartment(dept);
                
                u.setActive(true); // Since we filter is_active=1 in SQL
                
                return u;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Error retrieving user", e);
        }
    }
    
    public int countSubordinates(int managerId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Users WHERE manager_id = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, managerId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }
    
    public int countAllUsers() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Users";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }
    
    public int countActiveUsers() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Users WHERE is_active = 1";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }
}
