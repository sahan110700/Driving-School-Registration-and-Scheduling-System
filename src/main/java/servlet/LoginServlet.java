package servlet;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Check empty fields
        if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp?error=empty");
            return;
        }

        // FIX: use validateLoginAndGetRole instead of validateLogin
        String role = userDAO.validateLoginAndGetRole(username.trim(), password.trim());

        if (role != null) {
            // Login success — store both username and role in session
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", username.trim());
            session.setAttribute("userRole", role);

            // FIX: redirect admin and student to different pages
            if ("admin".equalsIgnoreCase(role)) {
                resp.sendRedirect(req.getContextPath() + "/home");
            } else {
                resp.sendRedirect(req.getContextPath() + "/home");
            }

        } else {
            // Login failed
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp?error=invalid");
        }
    }
}