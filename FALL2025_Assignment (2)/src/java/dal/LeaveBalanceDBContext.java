package dal;

import model.LeaveBalance;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveBalanceDBContext extends DBContext {
    
    public List<LeaveBalance> getUserBalances(int userId, int year) throws SQLException {
        List<LeaveBalance> balances = new ArrayList<>();
        String sql = "SELECT lb.*, u.full_name as user_name, lt.name as leave_type_name, lt.code as leave_type_code " +
                    "FROM LeaveBalances lb " +
                    "JOIN Users u ON lb.user_id = u.id " +
                    "JOIN LeaveTypes lt ON lb.leave_type_id = lt.id " +
                    "WHERE lb.user_id = ? AND lb.year = ? " +
                    "ORDER BY lt.code";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, year);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    LeaveBalance balance = new LeaveBalance();
                    balance.setId(rs.getInt("id"));
                    balance.setUserId(rs.getInt("user_id"));
                    balance.setLeaveTypeId(rs.getInt("leave_type_id"));
                    balance.setYear(rs.getInt("year"));
                    balance.setTotalDays(rs.getInt("total_days"));
                    balance.setUsedDays(rs.getInt("used_days"));
                    balance.setRemainingDays(rs.getInt("remaining_days"));
                    balance.setUpdatedAt(rs.getTimestamp("updated_at"));
                    balance.setUserName(rs.getString("user_name"));
                    balance.setLeaveTypeName(rs.getString("leave_type_name"));
                    balance.setLeaveTypeCode(rs.getString("leave_type_code"));
                    balances.add(balance);
                }
            }
        }
        return balances;
    }
    
    public void updateUsedDays(int userId, int leaveTypeId, int year, int days) throws SQLException {
        String sql = "UPDATE LeaveBalances SET used_days = used_days + ?, updated_at = SYSUTCDATETIME() " +
                    "WHERE user_id = ? AND leave_type_id = ? AND year = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, days);
            stmt.setInt(2, userId);
            stmt.setInt(3, leaveTypeId);
            stmt.setInt(4, year);
            stmt.executeUpdate();
        }
    }
    
    public LeaveBalance getBalance(int userId, int leaveTypeId, int year) throws SQLException {
        String sql = "SELECT * FROM LeaveBalances WHERE user_id = ? AND leave_type_id = ? AND year = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, leaveTypeId);
            stmt.setInt(3, year);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    LeaveBalance balance = new LeaveBalance();
                    balance.setId(rs.getInt("id"));
                    balance.setUserId(rs.getInt("user_id"));
                    balance.setLeaveTypeId(rs.getInt("leave_type_id"));
                    balance.setYear(rs.getInt("year"));
                    balance.setTotalDays(rs.getInt("total_days"));
                    balance.setUsedDays(rs.getInt("used_days"));
                    balance.setRemainingDays(rs.getInt("remaining_days"));
                    balance.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return balance;
                }
            }
        }
        return null;
    }
}

