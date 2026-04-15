package servlet;

import dao.LessonDAO;
import dao.StudentDAO;
import dao.InstructorDAO;
import dao.VehicleDAO;
import model.Lesson;
import model.Student;
import model.Instructor;
import model.Vehicle;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/lessons")
public class LessonServlet extends HttpServlet {

    private final LessonDAO lessonDAO = new LessonDAO();
    private final StudentDAO studentDAO = new StudentDAO();
    private final InstructorDAO instructorDAO = new InstructorDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Check authentication
        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // Handle cancel
        if ("cancel".equals(action)) {
            String lessonId = req.getParameter("id");
            if (lessonId != null && lessonDAO.cancelLesson(lessonId)) {
                resp.sendRedirect(req.getContextPath() + "/lessons?success=cancelled");
            } else {
                resp.sendRedirect(req.getContextPath() + "/lessons?error=cancelFailed");
            }
            return;
        }

        // Handle complete
        if ("complete".equals(action)) {
            String lessonId = req.getParameter("id");
            if (lessonId != null && lessonDAO.completeLesson(lessonId)) {
                resp.sendRedirect(req.getContextPath() + "/lessons?success=completed");
            } else {
                resp.sendRedirect(req.getContextPath() + "/lessons?error=completeFailed");
            }
            return;
        }

        // Handle reschedule form
        if ("reschedule".equals(action)) {
            String lessonId = req.getParameter("id");
            Lesson lesson = lessonDAO.getLessonById(lessonId);
            req.setAttribute("lesson", lesson);
            req.setAttribute("students", studentDAO.getAllActiveStudents());
            req.setAttribute("instructors", instructorDAO.getAllActiveInstructors());
            req.setAttribute("vehicles", vehicleDAO.getAllActiveVehicles());
            req.getRequestDispatcher("/jsp/reschedule-lesson.jsp").forward(req, resp);
            return;
        }

        // Handle add form
        if ("add-form".equals(action)) {
            req.setAttribute("lesson", null);
            req.setAttribute("students", studentDAO.getAllActiveStudents());
            req.setAttribute("instructors", instructorDAO.getAllActiveInstructors());
            req.setAttribute("vehicles", vehicleDAO.getAllActiveVehicles());
            req.getRequestDispatcher("/jsp/edit-lesson.jsp").forward(req, resp);
            return;
        }

        // Get all students, instructors, vehicles for the main page
        req.setAttribute("students", studentDAO.getAllActiveStudents());
        req.setAttribute("instructors", instructorDAO.getAllActiveInstructors());
        req.setAttribute("vehicles", vehicleDAO.getAllActiveVehicles());

        // Get lessons
        String date = req.getParameter("date");
        if (date == null || date.isEmpty()) {
            date = LocalDate.now().toString();
        }

        List<Lesson> lessons = lessonDAO.getLessonsByDate(date);
        List<Lesson> upcomingLessons = lessonDAO.getUpcomingLessons();

        req.setAttribute("selectedDate", date);
        req.setAttribute("lessons", lessons);
        req.setAttribute("upcomingLessons", upcomingLessons);
        req.getRequestDispatcher("/jsp/lessons.jsp").forward(req, resp);
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

        // Handle reschedule
        if ("reschedule".equals(action)) {
            String lessonId = req.getParameter("lessonId");
            String lessonDate = req.getParameter("lessonDate");
            String lessonTime = req.getParameter("lessonTime");
            String durationStr = req.getParameter("duration");

            if (lessonId == null || lessonDate == null || lessonTime == null || durationStr == null) {
                resp.sendRedirect(req.getContextPath() + "/lessons?error=invalidData");
                return;
            }

            int duration = Integer.parseInt(durationStr);
            Lesson lesson = lessonDAO.getLessonById(lessonId);

            if (lesson != null) {
                lesson.setLessonDate(lessonDate);
                lesson.setLessonTime(lessonTime);
                lesson.setDuration(duration);

                if (lessonDAO.updateLesson(lesson)) {
                    resp.sendRedirect(req.getContextPath() + "/lessons?success=rescheduled");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/lessons?error=rescheduleFailed");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/lessons?error=lessonNotFound");
            }
            return;
        }

        // Get form data
        String studentId = req.getParameter("studentId");
        String instructorId = req.getParameter("instructorId");
        String vehicleId = req.getParameter("vehicleId");
        String lessonDate = req.getParameter("lessonDate");
        String lessonTime = req.getParameter("lessonTime");
        String durationStr = req.getParameter("duration");
        String lessonType = req.getParameter("lessonType");

        // Validate required fields
        if (studentId == null || studentId.isEmpty() ||
                instructorId == null || instructorId.isEmpty() ||
                vehicleId == null || vehicleId.isEmpty() ||
                lessonDate == null || lessonDate.isEmpty() ||
                lessonTime == null || lessonTime.isEmpty() ||
                durationStr == null || durationStr.isEmpty() ||
                lessonType == null || lessonType.isEmpty()) {

            resp.sendRedirect(req.getContextPath() + "/lessons?action=add-form&error=empty");
            return;
        }

        int duration = Integer.parseInt(durationStr);

        // Get details from IDs
        Student student = studentDAO.getStudentById(studentId);
        Instructor instructor = instructorDAO.getInstructorById(instructorId);
        Vehicle vehicle = vehicleDAO.getVehicleById(vehicleId);

        if (student == null || instructor == null || vehicle == null) {
            resp.sendRedirect(req.getContextPath() + "/lessons?action=add-form&error=invalidData");
            return;
        }

        String lessonId = lessonDAO.generateNextLessonId();
        String bookedDate = LocalDate.now().toString();

        Lesson lesson = new Lesson(
                lessonId, studentId, student.getName(),
                instructorId, instructor.getName(),
                vehicleId, vehicle.getRegistrationNumber(), vehicle.getVehicleModel(),
                lessonDate, lessonTime, duration,
                lessonType, "Scheduled", bookedDate
        );

        boolean success = lessonDAO.addLesson(lesson);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/lessons?success=added");
        } else {
            resp.sendRedirect(req.getContextPath() + "/lessons?action=add-form&error=conflict");
        }
    }
}