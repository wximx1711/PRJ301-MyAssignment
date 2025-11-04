package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.iam.PasswordResetRequest;

public class PasswordResetDBContext extends DBContext {

    public void createRequestByUsername(String username, String note) {
        String findSql = "SELECT id FROM Users WHERE username = ?";
        try (PreparedStatement st = connection.prepareStatement(findSql)) {
            st.setString(1, username);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    int uid = rs.getInt("id");
                    String insert = "INSERT INTO PasswordResetRequests(user_id, note, status, created_at) VALUES (?, ?, 0, GETDATE())";
                    try (PreparedStatement insertSt = connection.prepareStatement(insert)) {
                        insertSt.setInt(1, uid);
                        insertSt.setString(2, note);
                        insertSt.executeUpdate();
                    }
                } else {
                    // user not found, still create a generic request (optionally) or throw
                    String insert = "INSERT INTO PasswordResetRequests(user_id, note, status, created_at) VALUES (NULL, ?, 0, GETDATE())";
                    try (PreparedStatement insertSt = connection.prepareStatement(insert)) {
                        insertSt.setString(1, "Username not found: " + username + ". " + note);
                        insertSt.executeUpdate();
                    }
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public List<PasswordResetRequest> listRequests() {
        List<PasswordResetRequest> list = new ArrayList<>();
        String sql = "SELECT pr.id, pr.user_id, u.username, u.full_name, pr.note, pr.status, pr.processed_by, pr.created_at, pr.processed_at, pb.full_name as processed_by_name " +
                     "FROM PasswordResetRequests pr LEFT JOIN Users u ON pr.user_id = u.id LEFT JOIN Users pb ON pr.processed_by = pb.id ORDER BY pr.created_at DESC";
        try (PreparedStatement st = connection.prepareStatement(sql); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                PasswordResetRequest p = new PasswordResetRequest();
                p.setId(rs.getInt("id"));
                p.setUserId(rs.getInt("user_id"));
                p.setUsername(rs.getString("username"));
                p.setFullName(rs.getString("full_name"));
                p.setNote(rs.getString("note"));
                p.setStatus(rs.getInt("status"));
                p.setProcessedBy(rs.getInt("processed_by"));
                p.setProcessedByName(rs.getString("processed_by_name"));
                p.setCreatedAt(rs.getTimestamp("created_at"));
                p.setProcessedAt(rs.getTimestamp("processed_at"));
                list.add(p);
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Process a request: set new password for the user and mark request as processed.
     * Note: this method stores the provided password directly into Users.password_hash to
     * remain compatible with the current login logic. Strongly consider hashing and migrating.
     */
    public void processRequest(int requestId, int adminUserId, String newPassword) {
        String find = "SELECT user_id FROM PasswordResetRequests WHERE id = ?";
        try (PreparedStatement st = connection.prepareStatement(find)) {
            st.setInt(1, requestId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Integer userId = rs.getObject("user_id") != null ? rs.getInt("user_id") : null;
                    // If admin didn't provide a new password, default to '123'
                    String pwdToSet = (newPassword == null || newPassword.trim().isEmpty()) ? "123" : newPassword;
                    if (userId != null) {
                        // Update user password_hash (note: no hashing here to keep compatibility)
                        String up = "UPDATE Users SET password_hash = ? WHERE id = ?";
                        try (PreparedStatement upSt = connection.prepareStatement(up)) {
                            upSt.setString(1, pwdToSet);
                            upSt.setInt(2, userId);
                            upSt.executeUpdate();
                        }
                    }
                    String mark = "UPDATE PasswordResetRequests SET status = 1, processed_by = ?, processed_at = GETDATE() WHERE id = ?";
                    try (PreparedStatement markSt = connection.prepareStatement(mark)) {
                        markSt.setInt(1, adminUserId);
                        markSt.setInt(2, requestId);
                        markSt.executeUpdate();
                    }
                } else {
                    throw new RuntimeException("Request not found");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
