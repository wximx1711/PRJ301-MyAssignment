package model;

import java.sql.Timestamp;

public class ApprovalWorkflow {
    private int id;
    private int requestId;
    private int approverId;
    private int stepOrder;
    private String status; // PENDING, APPROVED, REJECTED
    private String note;
    private Timestamp approvedAt;
    
    // Display fields
    private String approverName;
    private String requestTitle;
    
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
    
    public int getApproverId() {
        return approverId;
    }
    
    public void setApproverId(int approverId) {
        this.approverId = approverId;
    }
    
    public int getStepOrder() {
        return stepOrder;
    }
    
    public void setStepOrder(int stepOrder) {
        this.stepOrder = stepOrder;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getNote() {
        return note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
    
    public Timestamp getApprovedAt() {
        return approvedAt;
    }
    
    public void setApprovedAt(Timestamp approvedAt) {
        this.approvedAt = approvedAt;
    }
    
    public String getApproverName() {
        return approverName;
    }
    
    public void setApproverName(String approverName) {
        this.approverName = approverName;
    }
    
    public String getRequestTitle() {
        return requestTitle;
    }
    
    public void setRequestTitle(String requestTitle) {
        this.requestTitle = requestTitle;
    }
}

