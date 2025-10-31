package dal;

import model.iam.User;
import model.Employee;
import java.sql.*;

public class UserDBContext extends DBContext {

    public User get(String username, String password) {
        String sql = """
            SELECT TOP 1 u.uid, u.username, u.displayname, 
                   e.eid, e.ename, e.did 
            FROM [User] u 
            LEFT JOIN Enrollment en ON en.uid = u.uid AND en.active = 1
            LEFT JOIN Employee e ON e.eid = en.eid 
            WHERE u.username = ? AND u.password = ?
        """;
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, username.trim());
            stm.setString(2, password.trim());
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUid(rs.getInt("uid"));
                u.setUsername(rs.getString("username"));
                u.setDisplayname(rs.getString("displayname"));

                int eid = rs.getInt("eid");
                if (!rs.wasNull()) {
                    Employee e = new Employee();
                    e.setEid(eid);
                    e.setEname(rs.getString("ename"));
                    e.setDid(rs.getInt("did"));
                    u.setEmployee(e);  // Gán Employee vào User
                }

                return u;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Error retrieving user", e);
        }
    }
}
