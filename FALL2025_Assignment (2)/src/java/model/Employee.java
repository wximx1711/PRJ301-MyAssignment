package model;

public class Employee extends BaseModel {
    private int eid;
    private String ename;
    private int did;
    private Integer supervisorId;
    
    public int getEid() { return eid; }
    public void setEid(int eid) { this.eid = eid; }
    
    public String getEname() { return ename; }
    public void setEname(String ename) { this.ename = ename; }
    
    public int getDid() { return did; }
    public void setDid(int did) { this.did = did; }
    
    public Integer getSupervisorId() { return supervisorId; }
    public void setSupervisorId(Integer supervisorId) { this.supervisorId = supervisorId; }
}
