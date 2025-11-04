package dal;

import java.sql.*;

public class DBContext implements AutoCloseable {
    protected Connection connection;
    private static final String DB_NAME = "FALL25_Assignment";
    private static final String SERVER = "localhost";
    private static final int PORT = 1433;
    private static final String USER = "sa";
    private static final String PASS = "123";

    public DBContext() {
        try {
            // First, connect to master database to check if target database exists
            String masterUrl = String.format("jdbc:sqlserver://%s:%d;databaseName=master;encrypt=false;trustServerCertificate=true", SERVER, PORT);
            
            System.out.println("DBContext: Step 1 - Connecting to SQL Server (master database)...");
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection masterConnection = DriverManager.getConnection(masterUrl, USER, PASS);
            System.out.println("DBContext: Connected to SQL Server successfully!");
            
            // Check if database exists
            System.out.println("DBContext: Step 2 - Checking if database '" + DB_NAME + "' exists...");
            boolean dbExists = checkDatabaseExists(masterConnection, DB_NAME);
            
            if (!dbExists) {
                masterConnection.close();
                String errorMsg = String.format(
                    "Database '%s' không tồn tại! Vui lòng chạy file SQL script 'leave_management_setup_v2.sql' để tạo database.",
                    DB_NAME
                );
                System.err.println("DBContext: ERROR - " + errorMsg);
                throw new RuntimeException(errorMsg);
            }
            
            masterConnection.close();
            System.out.println("DBContext: Database '" + DB_NAME + "' exists!");
            
            // Now connect to the target database
            System.out.println("DBContext: Step 3 - Connecting to database '" + DB_NAME + "'...");
            String targetUrl = String.format(
                "jdbc:sqlserver://%s:%d;databaseName=%s;encrypt=false;trustServerCertificate=true",
                SERVER, PORT, DB_NAME
            );
            
            connection = DriverManager.getConnection(targetUrl, USER, PASS);
            System.out.println("DBContext: Connected to database '" + DB_NAME + "' successfully!");
            
            // Verify connection
            try (java.sql.Statement testStmt = connection.createStatement()) {
                java.sql.ResultSet testRs = testStmt.executeQuery("SELECT DB_NAME() as dbname, USER_NAME() as username");
                if (testRs.next()) {
                    System.out.println("DBContext: Verified - Connected to: " + testRs.getString("dbname"));
                    System.out.println("DBContext: Verified - User: " + testRs.getString("username"));
                }
                testRs.close();
            }
            
        } catch (ClassNotFoundException e) {
            String errorMsg = "SQL Server JDBC Driver không tìm thấy! Vui lòng kiểm tra file mssql-jdbc-*.jar trong thư mục libs.";
            System.err.println("DBContext: ERROR - " + errorMsg);
            throw new RuntimeException(errorMsg, e);
        } catch (SQLException e) {
            String errorMsg;
            String errorCode = String.valueOf(e.getErrorCode());
            
            if (e.getMessage().contains("Cannot open database")) {
                errorMsg = String.format(
                    "Không thể mở database '%s'. Vui lòng:\n" +
                    "1. Kiểm tra SQL Server đang chạy\n" +
                    "2. Chạy file SQL script 'leave_management_setup_v2.sql' để tạo database\n" +
                    "3. Kiểm tra username/password SQL Server (hiện tại: %s/%s)",
                    DB_NAME, USER, PASS
                );
            } else if (e.getMessage().contains("Login failed")) {
                errorMsg = String.format(
                    "Đăng nhập SQL Server thất bại! Vui lòng kiểm tra:\n" +
                    "1. SQL Server đang chạy\n" +
                    "2. Username/Password đúng (hiện tại: %s/%s)\n" +
                    "3. SQL Server Authentication đã được bật",
                    USER, PASS
                );
            } else if (e.getMessage().contains("connection refused") || e.getMessage().contains("connect")) {
                errorMsg = String.format(
                    "Không thể kết nối đến SQL Server! Vui lòng kiểm tra:\n" +
                    "1. SQL Server đang chạy trên %s:%d\n" +
                    "2. SQL Server Browser service đang chạy\n" +
                    "3. Firewall cho phép kết nối đến port %d",
                    SERVER, PORT, PORT
                );
            } else {
                errorMsg = "Lỗi kết nối database: " + e.getMessage() + " (Error Code: " + errorCode + ")";
            }
            
            System.err.println("DBContext: ERROR - " + errorMsg);
            e.printStackTrace();
            throw new RuntimeException(errorMsg, e);
        } catch (Exception e) {
            String errorMsg = "Lỗi không xác định: " + e.getMessage();
            System.err.println("DBContext: ERROR - " + errorMsg);
            e.printStackTrace();
            throw new RuntimeException(errorMsg, e);
        }
    }
    
    private boolean checkDatabaseExists(Connection connection, String dbName) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM sys.databases WHERE name = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, dbName);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        }
        return false;
    }

    public Connection getConnection() { return connection; }

    @Override
    public void close() {
        try { if (connection != null && !connection.isClosed()) connection.close(); }
        catch (SQLException ignored) {}
    }
}
