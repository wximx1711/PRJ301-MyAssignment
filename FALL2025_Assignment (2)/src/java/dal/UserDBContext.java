package dal;

import java.sql.*;
import model.iam.Department;
import model.iam.Role;
import model.iam.User;

public class UserDBContext extends DBContext {

    public User get(String username, String password) {
        if (username == null || password == null) {
            System.err.println("UserDBContext.get(): username or password is null");
            return null;
        }
        
        String trimmedUsername = username.trim();
        String trimmedPassword = password.trim();
        
        System.out.println("UserDBContext.get(): Attempting login with username='" + trimmedUsername + "', password='" + trimmedPassword + "'");
        
        String sql = """
            SELECT TOP 1 u.id, u.username, u.full_name, u.role_id, u.department_id,
                   r.code as role_code, r.name as role_name,
                   d.name as department_name
            FROM Users u 
            JOIN Roles r ON r.id = u.role_id
            JOIN Departments d ON d.id = u.department_id
            WHERE u.username = ? AND u.password_hash = ? AND u.is_active = 1
        """;
        
        PreparedStatement stm = null;
        ResultSet rs = null;
        
        try {
            stm = connection.prepareStatement(sql);
            stm.setString(1, trimmedUsername);
            stm.setString(2, trimmedPassword);
            
            System.out.println("UserDBContext.get(): Executing query...");
            rs = stm.executeQuery();
            
            if (rs.next()) {
                System.out.println("UserDBContext.get(): User found! ID=" + rs.getInt("id"));
                
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
                
                u.setActive(true);
                
                return u;
            } else {
                System.out.println("UserDBContext.get(): No user found with username='" + trimmedUsername + "' and password='" + trimmedPassword + "'");
                
                // Debug: Check if user exists
                try {
                    String debugSql = "SELECT username, password_hash, is_active FROM Users WHERE username = ?";
                    PreparedStatement debugStm = connection.prepareStatement(debugSql);
                    debugStm.setString(1, trimmedUsername);
                    ResultSet debugRs = debugStm.executeQuery();
                    
                    if (debugRs.next()) {
                        System.out.println("UserDBContext.get(): DEBUG - User exists: username='" + debugRs.getString("username") 
                            + "', password_hash='" + debugRs.getString("password_hash") 
                            + "', is_active=" + debugRs.getBoolean("is_active"));
                    } else {
                        System.out.println("UserDBContext.get(): DEBUG - User does not exist with username='" + trimmedUsername + "'");
                    }
                    debugRs.close();
                    debugStm.close();
                } catch (Exception debugE) {
                    System.err.println("UserDBContext.get(): DEBUG query failed: " + debugE.getMessage());
                }
            }
            
            return null;
            
        } catch (SQLException e) {
            System.err.println("UserDBContext.get(): SQLException: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error retrieving user: " + e.getMessage(), e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (stm != null) stm.close();
            } catch (SQLException e) {
                System.err.println("Error closing resources: " + e.getMessage());
            }
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
