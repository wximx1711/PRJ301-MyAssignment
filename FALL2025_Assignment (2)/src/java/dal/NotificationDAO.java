package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import util.DBConnection;

public class NotificationDAO {

    public void create(int userId, String type, String title, String message, String relatedType, Integer relatedId) throws SQLException {
        String sql = "INSERT INTO Notifications (user_id, type, title, message, related_type, related_id) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, type);
            stmt.setString(3, title);
            stmt.setString(4, message);
            stmt.setString(5, relatedType);
            if (relatedId != null) {
                stmt.setInt(6, relatedId);
            } else {
                stmt.setNull(6, Types.INTEGER);
            }
            stmt.executeUpdate();
        }
    }
}