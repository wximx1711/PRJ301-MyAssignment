package dal;

import java.sql.*;

public class DBContext implements AutoCloseable {
    protected Connection connection;

    public DBContext() {
        try {
            String user = "sa";
            String pass = "123";
            String url  = "jdbc:sqlserver://localhost:1433;databaseName=FALL25_Assignment;encrypt=false";
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            throw new RuntimeException("DB connect error: " + e.getMessage(), e);
        }
    }

    public Connection getConnection() { return connection; }

    @Override
    public void close() {
        try { if (connection != null && !connection.isClosed()) connection.close(); }
        catch (SQLException ignored) {}
    }
}
