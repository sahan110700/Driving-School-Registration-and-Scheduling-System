package servlet;

import dao.StudentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Student;

import java.io.IOException;
import java.util.List;

@WebServlet("/students")
public class StudentServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            String studentId = req.getParameter("id");
            if (studentId != null) studentDAO.deleteStudent(studentId);
            resp.sendRedirect(req.getContextPath() + "/students?success=deleted");
            return;
        }

        if ("edit".equals(action)) {
            String studentId = req.getParameter("id");
            Student student = studentDAO.getStudentById(studentId);
            req.setAttribute("student", student);
            req.getRequestDispatcher("/jsp/edit-student.jsp").forward(req, resp);
            return;
        }

        if ("add-form".equals(action)) {
            req.setAttribute("student", null);
            req.getRequestDispatcher("/jsp/edit-student.jsp").forward(req, resp);
            return;
        }

        List<Student> studentList = studentDAO.getAllStudents();
        req.setAttribute("studentList", studentList);
        req.getRequestDispatcher("/jsp/students.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        String name = req.getParameter("name");
        String nic = req.getParameter("nic");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String address = req.getParameter("address");
        String password = req.getParameter("password");
        String licenseType = req.getParameter("licenseType");
        String coursePackage = req.getParameter("coursePackage");
        String registrationDate = req.getParameter("registrationDate");
        String gender = req.getParameter("gender");
        String ageText = req.getParameter("age");

        // Validate required fields
        if (name.isEmpty() || nic.isEmpty() || phone.isEmpty() || email.isEmpty() ||
                address.isEmpty() || password.isEmpty() || licenseType.isEmpty() ||
                coursePackage.isEmpty() || registrationDate.isEmpty() || gender.isEmpty() ||
                ageText.isEmpty()) {

            String redirect = ("update".equals(action)) ? "/students?action=edit&id=" + req.getParameter("studentId") + "&error=empty"
                    : "/students?action=add-form&error=empty";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        int age;
        try { age = Integer.parseInt(ageText); }
        catch (NumberFormatException e) {
            String redirect = ("update".equals(action)) ? "/students?action=edit&id=" + req.getParameter("studentId") + "&error=age"
                    : "/students?action=add-form&error=age";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        if ("update".equals(action)) {
            String studentId = req.getParameter("studentId");
            Student student = new Student(studentId, name, nic, phone, email, address, password, licenseType, coursePackage, registrationDate, age, gender);
            boolean success = studentDAO.updateStudent(student);
            resp.sendRedirect(req.getContextPath() + "/students" + (success ? "?success=updated" : "?error=failed"));
            return;
        }

        if ("add".equals(action)) {
            String studentId = studentDAO.generateNextStudentId();
            Student student = new Student(studentId, name, nic, phone, email, address, password, licenseType, coursePackage, registrationDate, age, gender);
            boolean success = studentDAO.addStudent(student);
            resp.sendRedirect(req.getContextPath() + "/students" + (success ? "?success=added" : "?action=add-form&error=failed"));
        }
    }
}