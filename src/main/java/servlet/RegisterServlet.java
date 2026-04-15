package servlet;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/jsp/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {

            resp.sendRedirect(req.getContextPath() + "/jsp/register.jsp?error=empty");
            return;
        }

        if (userDAO.usernameExists(username)) {
            resp.sendRedirect(req.getContextPath() + "/jsp/register.jsp?error=exists");
            return;
        }

        boolean success = userDAO.registerUser(username, email, password);

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp?success=registered");
        } else {
            resp.sendRedirect(req.getContextPath() + "/jsp/register.jsp?error=failed");
        }
    }
}