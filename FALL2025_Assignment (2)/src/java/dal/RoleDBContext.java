package dal;

import java.sql.*;
import java.util.HashSet;
import java.util.Set;

public class RoleDBContext extends DBContext {

    public boolean hasFeature(int uid, String url) {
        String sql = "SELECT 1 FROM v_UserFeatures WHERE uid=? AND [url]=?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, uid);
            stm.setString(2, url);
            try (ResultSet rs = stm.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { throw new RuntimeException(e); }
    }

    public Set<String> getFeatureUrls(int uid) {
        String sql = "SELECT DISTINCT [url] FROM v_UserFeatures WHERE uid=?";
        Set<String> urls = new HashSet<>();
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, uid);
            try (ResultSet rs = stm.executeQuery()) {
                while (rs.next()) urls.add(rs.getString(1));
            }
        } catch (SQLException e) { throw new RuntimeException(e); }
        return urls;
    }
}
