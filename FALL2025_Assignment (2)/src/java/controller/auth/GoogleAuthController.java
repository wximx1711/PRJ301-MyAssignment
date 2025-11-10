package controller.auth;

import dao.UserDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

// NOTE: This is a minimal controller to integrate Google OAuth 2.0 flow.
// It expects the application to be configured with Google OAuth client id/secret
// and redirect URI set to /auth/google/callback. For simplicity we will use
// the OAuth endpoints with a lightweight HTTP call and not include a full
// OAuth client library to keep dependencies minimal.

@WebServlet(urlPatterns = {"/auth/google", "/auth/google/callback"})
public class GoogleAuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // TODO: set these values in a secure config (web.xml or env)
    private static final String CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID";
    private static final String CLIENT_SECRET = "YOUR_GOOGLE_CLIENT_SECRET";
    private static final String REDIRECT_URI = "/FALL2025_Assignment/auth/google/callback"; // adjust if context path differs

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getRequestURI().substring(req.getContextPath().length());
        if (path.equals("/auth/google")) {
            // Redirect user to Google consent screen
            String state = "google_auth"; // for CSRF protection in production, generate and store per-session
        String authUrl = "https://accounts.google.com/o/oauth2/v2/auth" +
            "?client_id=" + CLIENT_ID +
            "&response_type=code" +
            "&scope=openid%20email%20profile" +
            "&redirect_uri=" + req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath() + "/auth/google/callback" +
            "&state=" + state;
        // Debug: print the full auth URL (useful to inspect redirect_uri and client_id)
        System.out.println("[GoogleAuth] Redirecting to Google auth URL: " + authUrl);
        resp.sendRedirect(authUrl);
            return;
        }

        if (path.equals("/auth/google/callback")) {
            // Handle callback from Google
            String code = req.getParameter("code");
            String error = req.getParameter("error");
            // Debug: log callback params
            System.out.println("[GoogleAuth] Callback received. code=" + code + ", error=" + error);
            if (error != null) {
                req.setAttribute("error", "Google sign-in cancelled or failed: " + error);
                req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                return;
            }
            if (code == null) {
                req.setAttribute("error", "Invalid Google sign-in response");
                req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                return;
            }

            // Exchange code for tokens and get userinfo
            try {
                // For brevity, use java.net to POST token request and GET userinfo
                // In production use a robust OAuth client and validate id_token signature
                String tokenEndpoint = "https://oauth2.googleapis.com/token";
                String params = "code=" + code +
                        "&client_id=" + CLIENT_ID +
                        "&client_secret=" + CLIENT_SECRET +
                        "&redirect_uri=" + req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath() + "/auth/google/callback" +
                        "&grant_type=authorization_code";

                // send POST to token endpoint
                java.net.URL url = new java.net.URL(tokenEndpoint);
                java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setDoOutput(true);
                conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                try (java.io.OutputStream os = conn.getOutputStream()) {
                    os.write(params.getBytes(java.nio.charset.StandardCharsets.UTF_8));
                }

                int codeResp = conn.getResponseCode();
                System.out.println("[GoogleAuth] Token endpoint response code: " + codeResp);
                if (codeResp != 200) {
                    java.io.InputStream es = conn.getErrorStream();
                    String errBody = es != null ? new String(es.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8) : "";
                    System.out.println("[GoogleAuth] Token endpoint error body: " + errBody);
                    req.setAttribute("error", "Google token exchange failed: HTTP " + codeResp + " - " + errBody);
                    req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                    return;
                }

                java.io.InputStream is = conn.getInputStream();
                String tokenJson = new String(is.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
                // parse JSON manually to extract access_token
                String accessToken = extractJsonField(tokenJson, "access_token");

                if (accessToken == null) {
                    req.setAttribute("error", "Failed to obtain access token from Google");
                    req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                    return;
                }

                // fetch userinfo
                java.net.URL ui = new java.net.URL("https://www.googleapis.com/oauth2/v3/userinfo");
                java.net.HttpURLConnection uc = (java.net.HttpURLConnection) ui.openConnection();
                uc.setRequestMethod("GET");
                uc.setRequestProperty("Authorization", "Bearer " + accessToken);
                int uiCode = uc.getResponseCode();
                if (uiCode != 200) {
                    req.setAttribute("error", "Failed to fetch Google user info: HTTP " + uiCode);
                    req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                    return;
                }
                String uiJson = new String(uc.getInputStream().readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
                String email = extractJsonField(uiJson, "email");
                String name = extractJsonField(uiJson, "name");

                if (email == null) {
                    req.setAttribute("error", "Google account did not return an email address");
                    req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                    return;
                }

                UserDAO userDao = new UserDAO();
                User user = userDao.getByEmail(email);
                if (user == null) {
                    // create new user
                    user = userDao.createUserFromGoogle(email, name);
                }

                if (user == null) {
                    req.setAttribute("error", "Unable to create or find user account for " + email);
                    req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
                    return;
                }

                // login user by storing in session
                HttpSession session = req.getSession(true);
                session.setAttribute("user", user);

                // redirect to home
                resp.sendRedirect(req.getContextPath() + "/");
                return;

            } catch (SQLException ex) {
                throw new ServletException(ex);
            }
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    // very simple JSON extraction for top-level string fields (not robust)
    private String extractJsonField(String json, String key) {
        String pat = "\"" + key + "\"\s*:\s*\"";
        int idx = json.indexOf(pat);
        if (idx == -1) return null;
        int start = idx + pat.length();
        int end = json.indexOf('"', start);
        if (end == -1) return null;
        return json.substring(start, end);
    }
}
