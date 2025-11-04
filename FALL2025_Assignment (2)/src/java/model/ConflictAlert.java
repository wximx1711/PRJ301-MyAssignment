package model;

import java.sql.Timestamp;

public class ConflictAlert {
    private int id;
    private int requestId;
    private String conflictType; // OVERLAP, DEPARTMENT_SHORTAGE, etc.
    private Integer conflictingRequestId;
    private Integer departmentId;
    private String message;
    private String severity; // LOW, MEDIUM, HIGH, CRITICAL
    private boolean isResolved;
    private Timestamp createdAt;
    private Timestamp resolvedAt;
    
    // Display fields
    private String requestTitle;
    private String departmentName;
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getRequestId() {
        return requestId;
    }
    
    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }
    
    public String getConflictType() {
        return conflictType;
    }
    
    public void setConflictType(String conflictType) {
        this.conflictType = conflictType;
    }
    
    public Integer getConflictingRequestId() {
        return conflictingRequestId;
    }
    
    public void setConflictingRequestId(Integer conflictingRequestId) {
        this.conflictingRequestId = conflictingRequestId;
    }
    
    public Integer getDepartmentId() {
        return departmentId;
    }
    
    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public String getSeverity() {
        return severity;
    }
    
    public void setSeverity(String severity) {
        this.severity = severity;
    }
    
    public boolean isResolved() {
        return isResolved;
    }
    
    public void setResolved(boolean isResolved) {
        this.isResolved = isResolved;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getResolvedAt() {
        return resolvedAt;
    }
    
    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt;
    }
    
    public String getRequestTitle() {
        return requestTitle;
    }
    
    public void setRequestTitle(String requestTitle) {
        this.requestTitle = requestTitle;
    }
    
    public String getDepartmentName() {
        return departmentName;
    }
    
    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }
}

