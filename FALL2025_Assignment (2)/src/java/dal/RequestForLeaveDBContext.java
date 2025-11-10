package dal;

import java.sql.*;
import java.sql.Date;
import java.util.*;
import model.RequestForLeave;

public class RequestForLeaveDBContext extends DBContext {

    // Lấy lịch làm việc cho phòng ban và khoảng thời gian từ view chuẩn
    public List<Map<String, Object>> getAgenda(int did, Date from, Date to) {
        String sql = "SELECT user_id, full_name, work_date FROM vw_Agenda WHERE work_date BETWEEN ? AND ? AND user_id IN (SELECT id FROM Users WHERE department_id = ?) ORDER BY full_name, work_date";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            ps.setInt(3, did);
            ResultSet rs = ps.executeQuery();
            List<Map<String, Object>> rows = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("eid", rs.getInt("user_id"));
                m.put("ename", rs.getString("full_name"));
                m.put("day", rs.getDate("work_date"));
                m.put("isLeave", 1);
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
            // Audit log
            insertAudit(uid, "APPROVE_REJECT", "REQUEST", rid,
                    null,
                    "{\"status\":\"" + newStatus + "\",\"note\":\"" + (note==null?"":note.replace("\"","'") ) + "\"}");
        } catch (SQLException ex) {
            throw new RuntimeException("Error approving/rejecting request", ex);
        }
    }

    public int create(int uid, Date from, Date to, String reason) {
        // Insert trực tiếp theo schema mới
        // Chọn type_id mặc định là ANNUAL
        String sql = """
            INSERT INTO Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)
            VALUES (?, (SELECT TOP 1 id FROM LeaveTypes WHERE code = N'ANNUAL'), N'Nghỉ phép', ?, ?, ?, N'INPROGRESS', ?)
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, uid);
            ps.setString(2, reason);
            ps.setDate(3, from);
            ps.setDate(4, to);
            ps.setInt(5, uid);
            ps.executeUpdate();
            int rid = 0; try (ResultSet g = ps.getGeneratedKeys()) { if (g.next()) rid = g.getInt(1); }
            insertAudit(uid, "CREATE", "REQUEST", rid, null,
                    "{\"from\":\""+from+"\",\"to\":\""+to+"\"}");
            return rid;
        } catch (SQLException ex) {
            throw new RuntimeException("Error creating leave request", ex);
        }
    }

    // Admin: list all requests with paging
    public List<RequestForLeave> listAllPage(int offset, int pageSize) {
        String sql = """
            SELECT r.id AS rid, r.employee_id, r.title, r.reason, r.start_date AS from_date, r.end_date AS to_date,
                   r.status, r.created_at AS created_time, r.created_by, r.processed_by,
                   u.full_name as created_by_name, p.full_name as processed_by_name
            FROM Requests r
            JOIN Users u ON u.id = r.created_by
            LEFT JOIN Users p ON p.id = r.processed_by
            ORDER BY r.created_at DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;
        List<RequestForLeave> requests = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
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
            throw new RuntimeException("Error retrieving all requests (paged)", ex);
        }
    }

    public List<RequestForLeave> listAllPageFiltered(java.sql.Date from, java.sql.Date to, String statusText, Integer typeId, int offset, int pageSize) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT r.id AS rid, r.employee_id, r.title, r.reason, r.start_date AS from_date, r.end_date AS to_date, ");
        sb.append("r.status, r.created_at AS created_time, r.created_by, r.processed_by, u.full_name as created_by_name, p.full_name as processed_by_name ");
        sb.append("FROM Requests r JOIN Users u ON u.id = r.created_by LEFT JOIN Users p ON p.id = r.processed_by WHERE 1=1 ");
        if (from != null) sb.append("AND r.start_date >= ? ");
        if (to != null) sb.append("AND r.end_date <= ? ");
        if (statusText != null && !statusText.isBlank()) sb.append("AND r.status = ? ");
        if (typeId != null) sb.append("AND r.type_id = ? ");
        sb.append("ORDER BY r.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<RequestForLeave> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sb.toString())) {
            int idx = 1;
            if (from != null) ps.setDate(idx++, from);
            if (to != null) ps.setDate(idx++, to);
            if (statusText != null && !statusText.isBlank()) ps.setString(idx++, statusText);
            if (typeId != null) ps.setInt(idx++, typeId);
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
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
                list.add(r);
            }
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving filtered all requests", ex);
        }
        return list;
    }

    public int countAllFiltered(java.sql.Date from, java.sql.Date to, String statusText, Integer typeId) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT COUNT(*) as cnt FROM Requests r WHERE 1=1 ");
        if (from != null) sb.append("AND r.start_date >= ? ");
        if (to != null) sb.append("AND r.end_date <= ? ");
        if (statusText != null && !statusText.isBlank()) sb.append("AND r.status = ? ");
        if (typeId != null) sb.append("AND r.type_id = ? ");
        try (PreparedStatement ps = connection.prepareStatement(sb.toString())) {
            int idx = 1;
            if (from != null) ps.setDate(idx++, from);
            if (to != null) ps.setDate(idx++, to);
            if (statusText != null && !statusText.isBlank()) ps.setString(idx++, statusText);
            if (typeId != null) ps.setInt(idx++, typeId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt("cnt"); }
            return 0;
        } catch (SQLException ex) { throw new RuntimeException("Error counting filtered all requests", ex); }
    }

    private void insertAudit(Integer userId, String action, String entityType, Integer entityId, String oldValues, String newValues) {
        String sql = "INSERT INTO AuditLogs(user_id, action, entity_type, entity_id, old_values, new_values, created_at) VALUES(?,?,?,?,?,?, SYSUTCDATETIME())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (userId == null) ps.setNull(1, Types.INTEGER); else ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, entityType);
            if (entityId == null) ps.setNull(4, Types.INTEGER); else ps.setInt(4, entityId);
            if (oldValues == null) ps.setNull(5, Types.NVARCHAR); else ps.setString(5, oldValues);
            if (newValues == null) ps.setNull(6, Types.NVARCHAR); else ps.setString(6, newValues);
            ps.executeUpdate();
        } catch (SQLException ignored) { }
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
        return switch (statusText) {
            case "INPROGRESS" -> 1;
            case "APPROVED" -> 2;
            case "REJECTED" -> 3;
            default -> 0;
        };
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

    // ====== Filters (from, to, status, type) ======
    public List<RequestForLeave> listMinePageFiltered(int myEid, java.sql.Date from, java.sql.Date to, String statusText, Integer typeId, int offset, int pageSize) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT r.id AS rid, r.employee_id, r.title, r.reason, r.start_date AS from_date, r.end_date AS to_date, ");
        sb.append("r.status, r.created_at AS created_time, r.created_by, r.processed_by, u.full_name as created_by_name, p.full_name as processed_by_name ");
        sb.append("FROM Requests r JOIN Users u ON u.id = r.created_by LEFT JOIN Users p ON p.id = r.processed_by WHERE r.employee_id = ? ");
        if (from != null) sb.append("AND r.start_date >= ? ");
        if (to != null) sb.append("AND r.end_date <= ? ");
        if (statusText != null && !statusText.isBlank()) sb.append("AND r.status = ? ");
        if (typeId != null) sb.append("AND r.type_id = ? ");
        sb.append("ORDER BY r.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<RequestForLeave> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sb.toString())) {
            int idx = 1;
            ps.setInt(idx++, myEid);
            if (from != null) ps.setDate(idx++, from);
            if (to != null) ps.setDate(idx++, to);
            if (statusText != null && !statusText.isBlank()) ps.setString(idx++, statusText);
            if (typeId != null) ps.setInt(idx++, typeId);
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
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
                list.add(r);
            }
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving filtered my requests", ex);
        }
        return list;
    }

    public int countMineFiltered(int myEid, java.sql.Date from, java.sql.Date to, String statusText, Integer typeId) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT COUNT(*) as cnt FROM Requests r WHERE r.employee_id = ? ");
        if (from != null) sb.append("AND r.start_date >= ? ");
        if (to != null) sb.append("AND r.end_date <= ? ");
        if (statusText != null && !statusText.isBlank()) sb.append("AND r.status = ? ");
        if (typeId != null) sb.append("AND r.type_id = ? ");
        try (PreparedStatement ps = connection.prepareStatement(sb.toString())) {
            int idx = 1;
            ps.setInt(idx++, myEid);
            if (from != null) ps.setDate(idx++, from);
            if (to != null) ps.setDate(idx++, to);
            if (statusText != null && !statusText.isBlank()) ps.setString(idx++, statusText);
            if (typeId != null) ps.setInt(idx++, typeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("cnt");
            return 0;
        } catch (SQLException ex) {
            throw new RuntimeException("Error counting filtered my requests", ex);
        }
    }

    public List<RequestForLeave> listOfSubordinatesPageFiltered(int myEid, java.sql.Date from, java.sql.Date to, String statusText, Integer typeId, int offset, int pageSize) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT r.id AS rid, r.employee_id, r.title, r.reason, r.start_date AS from_date, r.end_date AS to_date, r.status, r.created_at AS created_time, r.created_by, r.processed_by, u.full_name as created_by_name, p.full_name as processed_by_name ");
        sb.append("FROM Requests r JOIN Users u ON u.id = r.created_by LEFT JOIN Users p ON p.id = r.processed_by WHERE r.created_by IN (SELECT id FROM Users WHERE manager_id = ?) ");
        if (from != null) sb.append("AND r.start_date >= ? ");
        if (to != null) sb.append("AND r.end_date <= ? ");
        if (statusText != null && !statusText.isBlank()) sb.append("AND r.status = ? ");
        if (typeId != null) sb.append("AND r.type_id = ? ");
        sb.append("ORDER BY r.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        List<RequestForLeave> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sb.toString())) {
            int idx = 1;
            ps.setInt(idx++, myEid);
            if (from != null) ps.setDate(idx++, from);
            if (to != null) ps.setDate(idx++, to);
            if (statusText != null && !statusText.isBlank()) ps.setString(idx++, statusText);
            if (typeId != null) ps.setInt(idx++, typeId);
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);
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
                list.add(r);
            }
        } catch (SQLException ex) {
            throw new RuntimeException("Error retrieving filtered subordinate requests", ex);
        }
        return list;
    }

    public int countSubordinatesFiltered(int myEid, java.sql.Date from, java.sql.Date to, String statusText, Integer typeId) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT COUNT(*) as cnt FROM Requests r WHERE r.created_by IN (SELECT id FROM Users WHERE manager_id = ?) ");
        if (from != null) sb.append("AND r.start_date >= ? ");
        if (to != null) sb.append("AND r.end_date <= ? ");
        if (statusText != null && !statusText.isBlank()) sb.append("AND r.status = ? ");
        if (typeId != null) sb.append("AND r.type_id = ? ");
        try (PreparedStatement ps = connection.prepareStatement(sb.toString())) {
            int idx = 1;
            ps.setInt(idx++, myEid);
            if (from != null) ps.setDate(idx++, from);
            if (to != null) ps.setDate(idx++, to);
            if (statusText != null && !statusText.isBlank()) ps.setString(idx++, statusText);
            if (typeId != null) ps.setInt(idx++, typeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("cnt");
            return 0;
        } catch (SQLException ex) {
            throw new RuntimeException("Error counting filtered subordinate requests", ex);
        }
    }

    public List<Map<String, Object>> listLeaveTypes() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, code, name FROM LeaveTypes ORDER BY id";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("code", rs.getString("code"));
                m.put("name", rs.getString("name"));
                list.add(m);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading leave types", e);
        }
        return list;
    }

    // ===== Attachments =====
    public void insertAttachment(int rid, String fileName, String filePath, int uploaderId) {
        String sql = "INSERT INTO Attachments(request_id, file_name, file_path, uploaded_by) VALUES(?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rid);
            ps.setString(2, fileName);
            ps.setString(3, filePath);
            ps.setInt(4, uploaderId);
            ps.executeUpdate();
            insertAudit(uploaderId, "UPLOAD", "ATTACHMENT", rid, null, "{\"file\":\"" + fileName.replace("\"","'") + "\"}");
        } catch (SQLException e) {
            throw new RuntimeException("Error inserting attachment", e);
        }
    }

    public List<Map<String, Object>> listAttachments(int rid) {
        String sql = "SELECT id, file_name, file_path, uploaded_at FROM Attachments WHERE request_id = ? ORDER BY id DESC";
        List<Map<String, Object>> res = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("file_name", rs.getString("file_name"));
                    m.put("file_path", rs.getString("file_path"));
                    m.put("uploaded_at", rs.getTimestamp("uploaded_at"));
                    res.add(m);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error listing attachments", e);
        }
        return res;
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
    
    public int countAllRequests() {
        String sql = "SELECT COUNT(*) as count FROM Requests";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
            return 0;
        } catch (SQLException ex) {
            throw new RuntimeException("Error counting all requests", ex);
        }
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

    public void cancelRequest(int requestId, int cancelledBy, String note) {
        String sql = "UPDATE Requests SET status = 'CANCELLED', processed_by = ?, processed_at = SYSUTCDATETIME(), manager_note = ? WHERE id = ? AND status = 'INPROGRESS'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, cancelledBy);
            ps.setString(2, note);
            ps.setInt(3, requestId);
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                // Add to audit log
                insertAudit(cancelledBy, "CANCEL", "REQUEST", requestId,
                    "{\"status\":\"INPROGRESS\"}",
                    "{\"status\":\"CANCELLED\",\"note\":\"" + (note == null ? "" : note.replace("\"","'")) + "\"}");
            } else {
                throw new RuntimeException("Request not found or not in INPROGRESS status");
            }
        } catch (SQLException ex) {
            throw new RuntimeException("Error cancelling request", ex);
        }
    }
}
