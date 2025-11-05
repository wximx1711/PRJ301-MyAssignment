package dal;

import java.sql.*;
import java.sql.Date;
import java.util.*;
import model.RequestForLeave;

public class RequestForLeaveDBContext extends DBContext {

    // Lấy lịch làm việc cho phòng ban và khoảng thời gian
    public List<Map<String, Object>> getAgenda(int did, Date from, Date to) {
        String sql = """
            WITH Dates AS (
              SELECT ? AS d
              UNION ALL SELECT DATEADD(DAY, 1, d) FROM Dates WHERE d < ?
            ),
            Emp AS ( 
                SELECT eid, ename 
                FROM Employee 
                WHERE did = ?
            ),
            EmpDate AS ( 
                SELECT e.eid, e.ename, d.d 
                FROM Emp e 
                CROSS JOIN Dates d 
            ),
            Marked AS (
              SELECT ed.eid, ed.ename, ed.d,
                     CASE WHEN EXISTS (
                         SELECT 1 
                         FROM RequestForLeave r 
                         WHERE r.created_by = ed.eid 
                           AND r.status = 1
                           AND ed.d BETWEEN r.from_date AND r.to_date
                     ) THEN 1 ELSE 0 END AS isLeave
              FROM EmpDate ed
            )
            SELECT eid, ename, d, isLeave 
            FROM Marked 
            OPTION (MAXRECURSION 32767);
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);  // Ngày bắt đầu
            ps.setDate(2, to);    // Ngày kết thúc
            ps.setInt(3, did);    // ID phòng ban

            ResultSet rs = ps.executeQuery();
            List<Map<String, Object>> rows = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("eid", rs.getInt("eid"));
                m.put("ename", rs.getString("ename"));
                m.put("day", rs.getDate("d"));
                m.put("isLeave", rs.getInt("isLeave"));
                rows.add(m);
            }
            return rows;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi khi lấy lịch làm việc", e);
        }
    }

    public void approveOrReject(int uid, int rid, int status, String note) {
        // status: 2 = APPROVED, 3 = REJECTED (kept for backward compatibility)
        String newStatus = (status == 2) ? "APPROVED" : (status == 3 ? "REJECTED" : "INPROGRESS");
        String sql = "UPDATE Requests SET status = ?, processed_by = ?, processed_at = SYSUTCDATETIME(), manager_note = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, uid);
            ps.setString(3, note);
            ps.setInt(4, rid);
            ps.executeUpdate();
        } catch (SQLException ex) {
            throw new RuntimeException("Error approving/rejecting request", ex);
        }
    }

    public void create(int uid, Date from, Date to, String reason) {
        // Insert trực tiếp theo schema mới
        // Chọn type_id mặc định là ANNUAL
        String sql = "INSERT INTO Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)\n" +
                     "VALUES (?, (SELECT TOP 1 id FROM LeaveTypes WHERE code = N'ANNUAL'), N'Nghỉ phép', ?, ?, ?, N'INPROGRESS', ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, uid);
            ps.setString(2, reason);
            ps.setDate(3, from);
            ps.setDate(4, to);
            ps.setInt(5, uid);
            ps.executeUpdate();
        } catch (SQLException ex) {
            throw new RuntimeException("Error creating leave request", ex);
        }
    }

    public RequestForLeave getById(int id) {
        String sql = """
            SELECT r.id AS rid, r.employee_id, r.title, r.reason, r.start_date AS from_date, r.end_date AS to_date,
                   r.status, r.created_at AS created_time, r.created_by, r.processed_by, r.manager_note,
                   u.full_name as created_by_name, p.full_name as processed_by_name
            FROM Requests r
            JOIN Users u ON u.id = r.created_by
            LEFT JOIN Users p ON p.id = r.processed_by
            WHERE r.id = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RequestForLeave r = new RequestForLeave();
                    r.setRid(rs.getInt("rid"));
                    r.setCreatedBy(rs.getInt("created_by"));
                    r.setCreatedTime(rs.getTimestamp("created_time"));
                    r.setFromDate(rs.getDate("from_date"));
                    r.setToDate(rs.getDate("to_date"));
                    r.setReason(rs.getString("reason"));
                    r.setStatus(mapStatus(rs.getString("status")));
                    r.setProcessedBy(rs.getInt("processed_by"));
                    r.setCreatedByName(rs.getString("created_by_name"));
                    r.setProcessedByName(rs.getString("processed_by_name"));
                    return r;
                }
            }
            return null;
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving request by id", ex);
        }
    }

    private int mapStatus(String statusText) {
        if (statusText == null) return 0;
        switch (statusText) {
            case "INPROGRESS": return 1;
            case "APPROVED": return 2;
            case "REJECTED": return 3;
            default: return 0;
        }
    }

    public List<RequestForLeave> listMine(int myEid) {
        // Updated to use new schema: Requests and Users
        String sql = """
            SELECT r.*, u.full_name as created_by_name, p.full_name as processed_by_name
            FROM Requests r
            JOIN Users u ON u.id = r.created_by
            LEFT JOIN Users p ON p.id = r.processed_by
            WHERE r.employee_id = ?
            ORDER BY r.created_at DESC
        """;
        
        List<RequestForLeave> requests = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, myEid);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RequestForLeave r = new RequestForLeave();
                r.setRid(rs.getInt("rid"));
                r.setCreatedBy(rs.getInt("created_by"));
                r.setCreatedTime(rs.getTimestamp("created_time"));
                r.setFromDate(rs.getDate("from_date"));
                r.setToDate(rs.getDate("to_date"));
                r.setReason(rs.getString("reason"));
                r.setStatus(mapStatus(rs.getString("status")));
                r.setProcessedBy(rs.getInt("processed_by"));
                r.setCreatedByName(rs.getString("created_by_name"));
                r.setProcessedByName(rs.getString("processed_by_name"));
                requests.add(r);
            }
            return requests;
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving leave requests", ex);
        }
    }

    // Server-side paging for 'mine' requests
    public List<RequestForLeave> listMinePage(int myEid, int offset, int pageSize) {
        String sql = """
            SELECT r.id AS rid, r.employee_id, r.title, r.reason, r.start_date AS from_date, r.end_date AS to_date,
                   r.status, r.created_at AS created_time, r.created_by, r.processed_by,
                   u.full_name as created_by_name, p.full_name as processed_by_name
            FROM Requests r
            JOIN Users u ON u.id = r.created_by
            LEFT JOIN Users p ON p.id = r.processed_by
            WHERE r.employee_id = ?
            ORDER BY r.created_at DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;
        List<RequestForLeave> requests = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, myEid);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RequestForLeave r = new RequestForLeave();
                r.setRid(rs.getInt("rid"));
                r.setCreatedBy(rs.getInt("created_by"));
                r.setCreatedTime(rs.getTimestamp("created_time"));
                r.setFromDate(rs.getDate("from_date"));
                r.setToDate(rs.getDate("to_date"));
                r.setReason(rs.getString("reason"));
                r.setStatus(mapStatus(rs.getString("status")));
                r.setProcessedBy(rs.getInt("processed_by"));
                r.setCreatedByName(rs.getString("created_by_name"));
                r.setProcessedByName(rs.getString("processed_by_name"));
                requests.add(r);
            }
            return requests;
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving leave requests (paged)", ex);
        }
    }

    public int countMine(int myEid) {
        String sql = "SELECT COUNT(*) as cnt FROM Requests WHERE employee_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, myEid);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }
            return 0;
        } catch (SQLException ex) {
            throw new RuntimeException("Error counting mine requests", ex);
        }
    }

    public int getMyEid(int uid) {
        // In the updated schema we use Users.id as the employee identifier.
        // Controllers already pass the authenticated user's id (uid),
        // so the employee id is the same as uid. Return uid directly to
        // remain compatible with existing controller logic.
        return uid;
    }

    public List<RequestForLeave> listOfSubordinates(int myEid) {
        // Find requests created by direct subordinates (manager_id relationship)
        String sql = """
            SELECT r.*, u.full_name as created_by_name, p.full_name as processed_by_name
            FROM Requests r
            JOIN Users u ON u.id = r.created_by
            LEFT JOIN Users p ON p.id = r.processed_by
            WHERE r.created_by IN (SELECT id FROM Users WHERE manager_id = ?)
            ORDER BY r.created_at DESC
        """;
        
        List<RequestForLeave> requests = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, myEid);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RequestForLeave r = new RequestForLeave();
                r.setRid(rs.getInt("rid"));
                r.setCreatedBy(rs.getInt("created_by"));
                r.setCreatedTime(rs.getTimestamp("created_time"));
                r.setFromDate(rs.getDate("from_date"));
                r.setToDate(rs.getDate("to_date"));
                r.setReason(rs.getString("reason"));
                r.setStatus(mapStatus(rs.getString("status")));
                r.setProcessedBy(rs.getInt("processed_by"));
                r.setCreatedByName(rs.getString("created_by_name"));
                r.setProcessedByName(rs.getString("processed_by_name"));
                requests.add(r);
            }
            return requests;
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving subordinate requests", ex);
        }
    }

    // Server-side paging for subordinate requests
    public List<RequestForLeave> listOfSubordinatesPage(int myEid, int offset, int pageSize) {
        String sql = """
            SELECT r.id AS rid, r.employee_id, r.title, r.reason, r.start_date AS from_date, r.end_date AS to_date,
                   r.status, r.created_at AS created_time, r.created_by, r.processed_by,
                   u.full_name as created_by_name, p.full_name as processed_by_name
            FROM Requests r
            JOIN Users u ON u.id = r.created_by
            LEFT JOIN Users p ON p.id = r.processed_by
            WHERE r.created_by IN (SELECT id FROM Users WHERE manager_id = ?)
            ORDER BY r.created_at DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;
        List<RequestForLeave> requests = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, myEid);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RequestForLeave r = new RequestForLeave();
                r.setRid(rs.getInt("rid"));
                r.setCreatedBy(rs.getInt("created_by"));
                r.setCreatedTime(rs.getTimestamp("created_time"));
                r.setFromDate(rs.getDate("from_date"));
                r.setToDate(rs.getDate("to_date"));
                r.setReason(rs.getString("reason"));
                r.setStatus(mapStatus(rs.getString("status")));
                r.setProcessedBy(rs.getInt("processed_by"));
                r.setCreatedByName(rs.getString("created_by_name"));
                r.setProcessedByName(rs.getString("processed_by_name"));
                requests.add(r);
            }
            return requests;
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving subordinate requests (paged)", ex);
        }
    }

    public int countSubordinates(int myEid) {
        String sql = "SELECT COUNT(*) as cnt FROM Requests WHERE created_by IN (SELECT id FROM Users WHERE manager_id = ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, myEid);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }
            return 0;
        } catch (SQLException ex) {
            throw new RuntimeException("Error counting subordinate requests", ex);
        }
    }
    
    public int countPendingRequestsForManager(int managerId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Requests r " +
                    "JOIN Users u ON r.employee_id = u.id " +
                    "WHERE u.manager_id = ? AND r.status = 'INPROGRESS'";
        
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
    
    public int countUpcomingApprovals(int managerId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Requests r " +
                    "JOIN Users u ON r.employee_id = u.id " +
                    "WHERE u.manager_id = ? AND r.status = 'APPROVED' " +
                    "AND r.start_date >= CAST(GETDATE() AS DATE)";
        
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
    
    public int countAllRequests() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Requests";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }
    
    public int countPendingRequests() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Requests WHERE status = 'INPROGRESS'";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }
    
    public int countMyPendingRequests(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Requests WHERE employee_id = ? AND status = 'INPROGRESS'";
        
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
    
    public int countMyApprovedRequests(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Requests WHERE employee_id = ? AND status = 'APPROVED'";
        
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
}
