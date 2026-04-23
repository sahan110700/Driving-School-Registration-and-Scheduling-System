package servlet;

import dao.InstructorDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Instructor;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/instructors")
public class InstructorServlet extends HttpServlet {

    private final InstructorDAO instructorDAO = new InstructorDAO();
    private final UserDAO userDAO = new UserDAO(); // FIX: to save login credentials

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            String instructorId = req.getParameter("id");
            if (instructorId != null) instructorDAO.deleteInstructor(instructorId);
            resp.sendRedirect(req.getContextPath() + "/instructors?success=deleted");
            return;
        }

        if ("edit".equals(action)) {
            String instructorId = req.getParameter("id");
            Instructor instructor = instructorDAO.getInstructorById(instructorId);
            req.setAttribute("instructor", instructor);
            req.getRequestDispatcher("/jsp/edit-instructor.jsp").forward(req, resp);
            return;
        }

        if ("add-form".equals(action)) {
            req.setAttribute("instructor", null);
            req.getRequestDispatcher("/jsp/edit-instructor.jsp").forward(req, resp);
            return;
        }

        String searchName     = req.getParameter("searchName");
        String specialization = req.getParameter("specialization");
        String availability   = req.getParameter("availability");

        List<Instructor> instructorList;
        if ((searchName != null && !searchName.isEmpty()) ||
                (specialization != null && !specialization.isEmpty()) ||
                (availability != null && !availability.isEmpty())) {
            instructorList = instructorDAO.searchInstructors(searchName, specialization, availability);
            req.setAttribute("searchName", searchName);
            req.setAttribute("selectedSpecialization", specialization);
            req.setAttribute("selectedAvailability", availability);
        } else {
            instructorList = instructorDAO.getAllActiveInstructors();
        }

        req.setAttribute("instructorList", instructorList);
        req.getRequestDispatcher("/jsp/instructors.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        String action         = req.getParameter("action");
        String name           = req.getParameter("name");
        String nic            = req.getParameter("nic");
        String phone          = req.getParameter("phone");
        String email          = req.getParameter("email");
        String address        = req.getParameter("address");
        String password       = req.getParameter("password");
        String licenseNumber  = req.getParameter("licenseNumber");
        String specialization = req.getParameter("specialization");
        String availability   = req.getParameter("availability");
        String gender         = req.getParameter("gender");
        String experienceText = req.getParameter("experience");
        String username       = req.getParameter("username"); // FIX: for login

        // Validate required fields
        if (isEmpty(name) || isEmpty(nic) || isEmpty(phone) || isEmpty(email) ||
                isEmpty(address) || isEmpty(licenseNumber) || isEmpty(specialization) ||
                isEmpty(availability) || isEmpty(gender) || isEmpty(experienceText)) {

            String redirect = "update".equals(action)
                    ? "/instructors?action=edit&id=" + req.getParameter("instructorId") + "&error=empty"
                    : "/instructors?action=add-form&error=empty";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // FIX: For ADD also require username and password
        if ("add".equals(action) && (isEmpty(username) || isEmpty(password))) {
            resp.sendRedirect(req.getContextPath() + "/instructors?action=add-form&error=empty");
            return;
        }

        // Validate experience
        int experience;
        try {
            experience = Integer.parseInt(experienceText.trim());
            if (experience < 0 || experience > 50) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            String redirect = "update".equals(action)
                    ? "/instructors?action=edit&id=" + req.getParameter("instructorId") + "&error=experience"
                    : "/instructors?action=add-form&error=experience";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // ── UPDATE ──
        if ("update".equals(action)) {
            String instructorId = req.getParameter("instructorId");

            if (instructorDAO.isNicExists(nic, instructorId)) {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=edit&id=" + instructorId + "&error=nicExists");
                return;
            }
            if (instructorDAO.isLicenseNumberExists(licenseNumber, instructorId)) {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=edit&id=" + instructorId + "&error=licenseExists");
                return;
            }

            Instructor existing = instructorDAO.getInstructorById(instructorId);
            // Keep old password if blank
            String finalPassword = isEmpty(password) ? existing.getPassword() : password.trim();

            Instructor instructor = new Instructor(
                    instructorId, name.trim(), nic.trim(), phone.trim(), email.trim(),
                    address.trim(), finalPassword, licenseNumber.trim(), specialization.trim(),
                    experience, availability.trim(), gender.trim(), "ACTIVE", existing.getJoinDate()
            );

            boolean success = instructorDAO.updateInstructor(instructor);
            resp.sendRedirect(req.getContextPath() + "/instructors" + (success ? "?success=updated" : "?error=failed"));
            return;
        }

        // ── ADD ──
        if ("add".equals(action)) {
            // FIX: Check username not already taken
            if (userDAO.usernameExists(username.trim())) {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=add-form&error=usernameExists");
                return;
            }
            if (instructorDAO.isNicExists(nic, "")) {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=add-form&error=nicExists");
                return;
            }
            if (instructorDAO.isLicenseNumberExists(licenseNumber, "")) {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=add-form&error=licenseExists");
                return;
            }

            String instructorId = instructorDAO.generateNextInstructorId();
            String joinDate = LocalDate.now().toString();

            Instructor instructor = new Instructor(
                    instructorId, name.trim(), nic.trim(), phone.trim(), email.trim(),
                    address.trim(), password.trim(), licenseNumber.trim(), specialization.trim(),
                    experience, availability.trim(), gender.trim(), "ACTIVE", joinDate
            );

            boolean success = instructorDAO.addInstructor(instructor);

            if (success) {
                // FIX: Save to users.txt so instructor can login with role "instructor"
                userDAO.registerUser(username.trim(), email.trim(), password.trim());
                resp.sendRedirect(req.getContextPath() + "/instructors?success=added");
            } else {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=add-form&error=failed");
            }
        }
    }

    private boolean isEmpty(String val) {
        return val == null || val.trim().isEmpty();
    }
}