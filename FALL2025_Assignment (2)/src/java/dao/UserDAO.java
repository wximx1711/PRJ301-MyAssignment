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

    // Get user by email stored in UserSettings.email
    public User getByEmail(String email) throws SQLException {
        String sql = "SELECT u.*, r.code as role_code, r.name as role_name, d.name as department_name " +
                    "FROM Users u " +
                    "JOIN Roles r ON r.id = u.role_id " +
                    "JOIN Departments d ON d.id = u.department_id " +
                    "JOIN UserSettings s ON s.user_id = u.id " +
                    "WHERE s.email = ? AND u.is_active = 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    // Create a new user (Employee role, default department) from Google sign-in
    // Returns the created User object
    public User createUserFromGoogle(String email, String fullName) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // find EMPLOYEE role id
            int roleId = -1;
            String qRole = "SELECT id FROM Roles WHERE code = 'EMPLOYEE'";
            try (PreparedStatement prs = conn.prepareStatement(qRole);
                 ResultSet rsr = prs.executeQuery()) {
                if (rsr.next()) {
                    roleId = rsr.getInt("id");
                }
            }

            // find default department (IT) or fallback to first department
            int deptId = -1;
            String qDept = "SELECT id FROM Departments WHERE name = 'IT'";
            try (PreparedStatement pds = conn.prepareStatement(qDept);
                 ResultSet rsd = pds.executeQuery()) {
                if (rsd.next()) {
                    deptId = rsd.getInt("id");
                }
            }
            if (deptId == -1) {
                String qDept2 = "SELECT TOP 1 id FROM Departments";
                try (PreparedStatement pds2 = conn.prepareStatement(qDept2);
                     ResultSet rsd2 = pds2.executeQuery()) {
                    if (rsd2.next()) deptId = rsd2.getInt("id");
                }
            }

            // create username from email local part and ensure uniqueness
            String username = email.split("@")[0];
            String checkUserSql = "SELECT COUNT(*) cnt FROM Users WHERE username = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkUserSql)) {
                int suffix = 0;
                String candidate;
                while (true) {
                    candidate = username + (suffix == 0 ? "" : String.valueOf(suffix));
                    psCheck.setString(1, candidate);
                    try (ResultSet r = psCheck.executeQuery()) {
                        if (r.next() && r.getInt("cnt") == 0) {
                            username = candidate;
                            break;
                        }
                    }
                    suffix++;
                }
            }

            String insertUser = "INSERT INTO Users(username,password_hash,full_name,role_id,department_id,manager_id) " +
                                "VALUES (?, ?, ?, ?, ?, NULL)";
            try (PreparedStatement psIns = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {
                psIns.setString(1, username);
                psIns.setString(2, "GOOGLE_OAUTH"); // placeholder password hash
                psIns.setString(3, fullName != null ? fullName : username);
                psIns.setInt(4, roleId == -1 ? 1 : roleId);
                psIns.setInt(5, deptId == -1 ? 1 : deptId);
                psIns.executeUpdate();

                try (ResultSet gk = psIns.getGeneratedKeys()) {
                    if (gk.next()) {
                        int newId = gk.getInt(1);

                        // insert into UserSettings
                        String insSetting = "INSERT INTO UserSettings(user_id, email, phone, email_notifications, sms_notifications, in_app_notifications) " +
                                            "VALUES (?, ?, NULL, 1, 0, 1)";
                        try (PreparedStatement psSet = conn.prepareStatement(insSetting)) {
                            psSet.setInt(1, newId);
                            psSet.setString(2, email);
                            psSet.executeUpdate();
                        }

                        conn.commit();
                        return getById(newId);
                    }
                }
            }
            conn.rollback();
        }
        return null;
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