package dal;

import model.Notification;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDBContext extends DBContext {
    
    public List<Notification> getUserNotifications(int userId) throws SQLException {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT n.*, u.full_name as user_name " +
                    "FROM Notifications n " +
                    "LEFT JOIN Users u ON n.user_id = u.id " +
                    "WHERE n.user_id = ? " +
                    "ORDER BY n.created_at DESC";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Notification notif = new Notification();
                    notif.setId(rs.getInt("id"));
                    notif.setUserId(rs.getInt("user_id"));
                    notif.setType(rs.getString("type"));
                    notif.setTitle(rs.getString("title"));
                    notif.setMessage(rs.getString("message"));
                    notif.setRelatedType(rs.getString("related_type"));
                    Integer relatedId = rs.getObject("related_id", Integer.class);
                    notif.setRelatedId(relatedId);
                    notif.setRead(rs.getBoolean("is_read"));
                    notif.setCreatedAt(rs.getTimestamp("created_at"));
                    Timestamp readAt = rs.getTimestamp("read_at");
                    notif.setReadAt(readAt);
                    notif.setUserName(rs.getString("user_name"));
                    notifications.add(notif);
                }
            }
        }
        return notifications;
    }
    
    public int getUnreadCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Notifications WHERE user_id = ? AND is_read = 0";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }
    
    public void markAsRead(int notificationId, int userId) throws SQLException {
        String sql = "UPDATE Notifications SET is_read = 1, read_at = SYSUTCDATETIME() " +
                    "WHERE id = ? AND user_id = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, notificationId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        }
    }
    
    public void createNotification(int userId, String type, String title, String message, 
                                   String relatedType, Integer relatedId) throws SQLException {
        String sql = "INSERT INTO Notifications (user_id, type, title, message, related_type, related_id) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
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

    public void markAllRead(int userId) {
        String sql = "UPDATE Notifications SET is_read = 1, read_at = SYSUTCDATETIME() WHERE user_id = ? AND is_read = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error marking notifications read", e);
        }
    }
}

