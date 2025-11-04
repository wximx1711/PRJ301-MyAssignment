package model;

import java.sql.Timestamp;

public class LeaveBalance {
    private int id;
    private int userId;
    private int leaveTypeId;
    private int year;
    private int totalDays;
    private int usedDays;
    private int remainingDays;
    private Timestamp updatedAt;
    
    // Display fields
    private String userName;
    private String leaveTypeName;
    private String leaveTypeCode;
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public int getLeaveTypeId() {
        return leaveTypeId;
    }
    
    public void setLeaveTypeId(int leaveTypeId) {
        this.leaveTypeId = leaveTypeId;
    }
    
    public int getYear() {
        return year;
    }
    
    public void setYear(int year) {
        this.year = year;
    }
    
    public int getTotalDays() {
        return totalDays;
    }
    
    public void setTotalDays(int totalDays) {
        this.totalDays = totalDays;
    }
    
    public int getUsedDays() {
        return usedDays;
    }
    
    public void setUsedDays(int usedDays) {
        this.usedDays = usedDays;
    }
    
    public int getRemainingDays() {
        return remainingDays;
    }
    
    public void setRemainingDays(int remainingDays) {
        this.remainingDays = remainingDays;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public String getLeaveTypeName() {
        return leaveTypeName;
    }
    
    public void setLeaveTypeName(String leaveTypeName) {
        this.leaveTypeName = leaveTypeName;
    }
    
    public String getLeaveTypeCode() {
        return leaveTypeCode;
    }
    
    public void setLeaveTypeCode(String leaveTypeCode) {
        this.leaveTypeCode = leaveTypeCode;
    }
}

