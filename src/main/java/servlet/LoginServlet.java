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
        resp.sendRedirect(req.getContextPath() + "/home");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Prevent browser caching so back button never shows authenticated pages
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home?error=empty");
            return;
        }

        String role = userDAO.validateLoginAndGetRole(username.trim(), password.trim());

        if (role != null) {
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", username.trim());
            session.setAttribute("userRole", role);
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            // Could be wrong credentials OR account deleted by admin
            resp.sendRedirect(req.getContextPath() + "/home?error=invalid");
        }
    }
}