package model;

public class LeaveType {
    private int id;
    private String code;
    private String name;
    private boolean requiresDocument;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isRequiresDocument() {
        return requiresDocument;
    }

    public void setRequiresDocument(boolean requiresDocument) {
        this.requiresDocument = requiresDocument;
    }
}