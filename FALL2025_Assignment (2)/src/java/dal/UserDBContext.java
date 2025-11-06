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
    
    // ========== Admin helpers ==========
    public java.util.List<Department> listDepartments() {
        java.util.List<Department> list = new java.util.ArrayList<>();
        String sql = "SELECT id, name FROM Departments ORDER BY name";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Department d = new Department();
                d.setId(rs.getInt("id"));
                d.setName(rs.getString("name"));
                list.add(d);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading departments", e);
        }
        return list;
    }

    public java.util.List<Role> listRoles() {
        java.util.List<Role> list = new java.util.ArrayList<>();
        String sql = "SELECT id, code, name FROM Roles ORDER BY id";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role r = new Role();
                r.setId(rs.getInt("id"));
                r.setCode(rs.getString("code"));
                r.setName(rs.getString("name"));
                list.add(r);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading roles", e);
        }
        return list;
    }

    public java.util.List<User> listManagers() {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT u.id, u.full_name FROM Users u JOIN Roles r ON r.id = u.role_id WHERE r.code IN ('MANAGER','LEADER') AND u.is_active = 1 ORDER BY u.full_name";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setFullName(rs.getString("full_name"));
                list.add(u);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading managers", e);
        }
        return list;
    }

    public void createUser(String username, String password, String fullName, int roleId, int deptId, Integer managerId, boolean active) {
        if (username == null || username.isBlank() || password == null || password.isBlank() || fullName == null || fullName.isBlank()) {
            throw new IllegalArgumentException("Thiếu thông tin bắt buộc");
        }
        // Ensure unique username
        try (PreparedStatement check = connection.prepareStatement("SELECT 1 FROM Users WHERE username = ?")) {
            check.setString(1, username.trim());
            try (ResultSet rs = check.executeQuery()) {
                if (rs.next()) {
                    throw new RuntimeException("Username đã tồn tại");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra username", e);
        }

        String sql = "INSERT INTO Users(username, password_hash, full_name, role_id, department_id, manager_id, is_active) VALUES (?,?,?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password.trim()); // For assignment simplicity; production should hash
            ps.setString(3, fullName.trim());
            ps.setInt(4, roleId);
            ps.setInt(5, deptId);
            if (managerId == null) ps.setNull(6, java.sql.Types.INTEGER); else ps.setInt(6, managerId);
            ps.setBoolean(7, active);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tạo người dùng mới: " + e.getMessage(), e);
        }
    }

    // Admin list/reset/deactivate helpers
    public java.util.List<User> listAll() {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT u.id, u.username, u.full_name, u.is_active, r.code role_code, d.name dept FROM Users u JOIN Roles r ON r.id=u.role_id JOIN Departments d ON d.id=u.department_id ORDER BY u.id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setActive(rs.getBoolean("is_active"));
                Role r = new Role(); r.setCode(rs.getString("role_code")); u.setRole(r);
                Department d = new Department(); d.setName(rs.getString("dept")); u.setDepartment(d);
                list.add(u);
            }
        } catch (SQLException e) { throw new RuntimeException("Error listing users", e); }
        return list;
    }

    public void setActive(int uid, boolean active) {
        String sql = "UPDATE Users SET is_active = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) { ps.setBoolean(1, active); ps.setInt(2, uid); ps.executeUpdate(); }
        catch (SQLException e) { throw new RuntimeException("Error updating user active", e); }
    }

    public void resetPassword(int uid, String newPass) {
        String sql = "UPDATE Users SET password_hash = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) { ps.setString(1, newPass); ps.setInt(2, uid); ps.executeUpdate(); }
        catch (SQLException e) { throw new RuntimeException("Error resetting password", e); }
    }
}
