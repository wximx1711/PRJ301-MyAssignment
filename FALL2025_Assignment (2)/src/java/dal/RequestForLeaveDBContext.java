package dal;

import model.RequestForLeave;
import java.sql.*;
import java.util.*;

public class RequestForLeaveDBContext extends DBContext {

    // Lấy danh sách đơn nghỉ phép của người dùng và cấp dưới
    public List<RequestForLeave> listMine(int myEid) {
        String sql = """
            SELECT r.rid, r.created_by, r.created_time, r.from_date, r.to_date,
                   r.reason, r.status, r.processed_by,
                   ce.ename AS created_by_name, pe.ename AS processed_by_name
            FROM RequestForLeave r
            JOIN Employee ce ON ce.eid = r.created_by
            LEFT JOIN Employee pe ON pe.eid = r.processed_by
            WHERE r.created_by=?
            ORDER BY r.created_time DESC
        """;
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, myEid);
            ResultSet rs = stm.executeQuery();
            return mapWithNames(rs);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    // Lấy danh sách đơn của cấp dưới
    public List<RequestForLeave> listOfSubordinates(int managerEid) {
        String sql = """
            SELECT r.rid, r.created_by, r.created_time, r.from_date, r.to_date,
                   r.reason, r.status, r.processed_by,
                   ce.ename AS created_by_name, pe.ename AS processed_by_name
            FROM RequestForLeave r
            JOIN Employee ce ON ce.eid = r.created_by
            LEFT JOIN Employee pe ON pe.eid = r.processed_by
            WHERE r.created_by IN (SELECT eid FROM dbo.fn_Subordinates(?))
            ORDER BY r.created_time DESC
        """;
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, managerEid);
            ResultSet rs = stm.executeQuery();
            return mapWithNames(rs);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    // Hàm map dữ liệu từ ResultSet vào đối tượng RequestForLeave
    private List<RequestForLeave> mapWithNames(ResultSet rs) throws SQLException {
        List<RequestForLeave> list = new ArrayList<>();
        while (rs.next()) {
            RequestForLeave r = new RequestForLeave();
            r.setRid(rs.getInt("rid"));
            r.setCreatedBy(rs.getInt("created_by"));
            r.setCreatedTime(rs.getTimestamp("created_time"));
            r.setFromDate(rs.getDate("from_date"));
            r.setToDate(rs.getDate("to_date"));
            r.setReason(rs.getString("reason"));
            r.setStatus(rs.getInt("status"));
            int pb = rs.getInt("processed_by");
            r.setProcessedBy(rs.wasNull() ? null : pb);
            r.setCreatedByName(rs.getString("created_by_name"));
            r.setProcessedByName(rs.getString("processed_by_name"));
            list.add(r);
        }
        return list;
    }
}
