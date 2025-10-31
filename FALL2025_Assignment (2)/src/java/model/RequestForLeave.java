package model;

import java.sql.Date;
import java.sql.Timestamp;

public class RequestForLeave extends BaseModel {
    private int rid;
    private int createdBy;
    private Timestamp createdTime;
    private Date fromDate;
    private Date toDate;
    private String reason;
    private int status;
    private Integer processedBy;
    private String createdByName;
    private String processedByName;

    // getters and setters
    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getProcessedByName() { return processedByName; }
    public void setProcessedByName(String processedByName) { this.processedByName = processedByName; }

    // Other getter/setters...
}
