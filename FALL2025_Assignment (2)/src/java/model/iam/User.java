package model.iam;

import model.Employee;  // Đảm bảo rằng Employee được import đúng

public class User {
    private int uid;
    private String username;
    private String displayname;
    private Employee employee;  // Thêm thuộc tính Employee

    // Getter và Setter cho uid, username, displayname
    public int getUid() { return uid; }
    public void setUid(int uid) { this.uid = uid; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getDisplayname() { return displayname; }
    public void setDisplayname(String displayname) { this.displayname = displayname; }

    // Thêm Getter và Setter cho Employee
    public Employee getEmployee() {
        return employee;
    }

    public void setEmployee(Employee employee) {
        this.employee = employee;
    }
}
