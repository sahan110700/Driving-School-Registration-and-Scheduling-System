package servlet;

import dao.InstructorDAO;
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Check authentication
        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // Handle delete
        if ("delete".equals(action)) {
            String instructorId = req.getParameter("id");
            if (instructorId != null) {
                instructorDAO.deleteInstructor(instructorId);
            }
            resp.sendRedirect(req.getContextPath() + "/instructors?success=deleted");
            return;
        }

        // Handle edit form
        if ("edit".equals(action)) {
            String instructorId = req.getParameter("id");
            Instructor instructor = instructorDAO.getInstructorById(instructorId);
            req.setAttribute("instructor", instructor);
            req.getRequestDispatcher("/jsp/edit-instructor.jsp").forward(req, resp);
            return;
        }

        // Handle add form
        if ("add-form".equals(action)) {
            req.setAttribute("instructor", null);
            req.getRequestDispatcher("/jsp/edit-instructor.jsp").forward(req, resp);
            return;
        }

        // Handle search/filter
        String searchName = req.getParameter("searchName");
        String specialization = req.getParameter("specialization");
        String availability = req.getParameter("availability");

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

        // Check authentication
        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        // Get form data
        String name = req.getParameter("name");
        String nic = req.getParameter("nic");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String address = req.getParameter("address");
        String password = req.getParameter("password");
        String licenseNumber = req.getParameter("licenseNumber");
        String specialization = req.getParameter("specialization");
        String availability = req.getParameter("availability");
        String gender = req.getParameter("gender");
        String experienceText = req.getParameter("experience");

        // Validate required fields
        if (name == null || name.isEmpty() ||
                nic == null || nic.isEmpty() ||
                phone == null || phone.isEmpty() ||
                email == null || email.isEmpty() ||
                address == null || address.isEmpty() ||
                licenseNumber == null || licenseNumber.isEmpty() ||
                specialization == null || specialization.isEmpty() ||
                availability == null || availability.isEmpty() ||
                gender == null || gender.isEmpty() ||
                experienceText == null || experienceText.isEmpty()) {

            String redirect = ("update".equals(action)) ?
                    "/instructors?action=edit&id=" + req.getParameter("instructorId") + "&error=empty" :
                    "/instructors?action=add-form&error=empty";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // Validate experience
        int experience;
        try {
            experience = Integer.parseInt(experienceText);
            if (experience < 0 || experience > 50) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            String redirect = ("update".equals(action)) ?
                    "/instructors?action=edit&id=" + req.getParameter("instructorId") + "&error=experience" :
                    "/instructors?action=add-form&error=experience";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // Handle update
        if ("update".equals(action)) {
            String instructorId = req.getParameter("instructorId");

            // Check uniqueness for update
            if (instructorDAO.isNicExists(nic, instructorId)) {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=edit&id=" + instructorId + "&error=nicExists");
                return;
            }

            if (instructorDAO.isLicenseNumberExists(licenseNumber, instructorId)) {
                resp.sendRedirect(req.getContextPath() + "/instructors?action=edit&id=" + instructorId + "&error=licenseExists");
                return;
            }

            Instructor existingInstructor = instructorDAO.getInstructorById(instructorId);
            if (existingInstructor != null && (password == null || password.isEmpty())) {
                password = existingInstructor.getPassword();
            }

            Instructor instructor = new Instructor(
                    instructorId, name, nic, phone, email, address, password,
                    licenseNumber, specialization, experience, availability,
                    gender, "ACTIVE", existingInstructor.getJoinDate()
            );

            boolean success = instructorDAO.updateInstructor(instructor);
            resp.sendRedirect(req.getContextPath() + "/instructors" +
                    (success ? "?success=updated" : "?error=failed"));
            return;
        }

        // Handle add
        if ("add".equals(action)) {
            // Check uniqueness for new instructor
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
                    instructorId, name, nic, phone, email, address, password,
                    licenseNumber, specialization, experience, availability,
                    gender, "ACTIVE", joinDate
            );

            boolean success = instructorDAO.addInstructor(instructor);
            resp.sendRedirect(req.getContextPath() + "/instructors" +
                    (success ? "?success=added" : "?action=add-form&error=failed"));
        }
    }
}