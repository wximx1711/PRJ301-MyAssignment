package model;

public class Department extends BaseModel {
    private int did;
    private String dname;

    // Getter và Setter cho did và dname
    public int getDid() {
        return did;
    }

    public void setDid(int did) {
        this.did = did;
    }

    public String getDname() {
        return dname;
    }

    public void setDname(String dname) {
        this.dname = dname;
    }
}
