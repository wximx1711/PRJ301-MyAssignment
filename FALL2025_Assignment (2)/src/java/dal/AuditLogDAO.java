package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import util.DBConnection;

public class AuditLogDAO {

    public void insert(Integer userId, String action, String entityType, Integer entityId, String oldValues, String newValues) {
        String sql = "INSERT INTO AuditLogs(user_id, action, entity_type, entity_id, old_values, new_values, created_at) VALUES(?,?,?,?,?,?, SYSUTCDATETIME())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId == null) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, userId);
            }
            ps.setString(2, action);
            ps.setString(3, entityType);
            if (entityId == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, entityId);
            }
            if (oldValues == null) {
                ps.setNull(5, Types.NVARCHAR);
            } else {
                ps.setString(5, oldValues);
            }
            if (newValues == null) {
                ps.setNull(6, Types.NVARCHAR);
            } else {
                ps.setString(6, newValues);
            }
            ps.executeUpdate();
        } catch (SQLException ignored) {
        }
    }
}