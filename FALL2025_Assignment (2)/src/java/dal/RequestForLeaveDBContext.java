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
        String sql = "{call dbo.sp_Request_ApproveReject(?, ?, ?, ?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            cs.setInt(1, uid);
            cs.setInt(2, rid);
            cs.setInt(3, status);
            cs.setString(4, note);
            cs.execute();
        } catch (SQLException ex) {
            throw new RuntimeException("Error approving/rejecting request", ex);
        }
    }

    public void create(int uid, Date from, Date to, String reason) {
        String sql = "{call dbo.sp_Request_Create(?, ?, ?, ?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            cs.setInt(1, uid);
            cs.setDate(2, from);
            cs.setDate(3, to);
            cs.setString(4, reason);
            cs.execute();
        } catch (SQLException ex) {
            throw new RuntimeException("Error creating leave request", ex);
        }
    }

    public List<RequestForLeave> listMine(int myEid) {
        String sql = """
            SELECT r.*, e.ename as created_by_name, p.ename as processed_by_name
            FROM RequestForLeave r
            JOIN Employee e ON e.eid = r.created_by
            LEFT JOIN Employee p ON p.eid = r.processed_by
            WHERE r.created_by = ?
            ORDER BY r.created_time DESC
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
                r.setStatus(rs.getInt("status"));
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

    public int getMyEid(int uid) {
        String sql = "SELECT eid FROM v_UserCurrentEnrollment WHERE uid = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, uid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("eid");
            }
            throw new RuntimeException("No active enrollment found for user");
        } catch (SQLException ex) {
            throw new RuntimeException("Error getting employee ID", ex);
        }
    }

    public List<RequestForLeave> listOfSubordinates(int myEid) {
        String sql = """
            WITH SubRequests AS (
                SELECT r.*, e.ename as created_by_name, p.ename as processed_by_name
                FROM RequestForLeave r
                JOIN Employee e ON e.eid = r.created_by
                LEFT JOIN Employee p ON p.eid = r.processed_by
                WHERE r.created_by IN (SELECT eid FROM dbo.fn_Subordinates(?))
                ORDER BY r.created_time DESC
            )
            SELECT * FROM SubRequests
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
                r.setStatus(rs.getInt("status"));
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
}
