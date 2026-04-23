package servlet;

import dao.TestDAO;
import dao.StudentDAO;
import dao.InstructorDAO;
import model.Test;
import model.Student;
import model.Instructor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet("/tests")
public class TestServlet extends HttpServlet {

    private final TestDAO testDAO = new TestDAO();
    private final StudentDAO studentDAO = new StudentDAO();
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

        // Handle cancel
        if ("cancel".equals(action)) {
            String testId = req.getParameter("id");
            if (testId != null && testDAO.cancelTest(testId)) {
                resp.sendRedirect(req.getContextPath() + "/tests?success=cancelled");
            } else {
                resp.sendRedirect(req.getContextPath() + "/tests?error=cancelFailed");
            }
            return;
        }

        // Handle results form
        if ("results".equals(action)) {
            String testId = req.getParameter("id");
            Test test = testDAO.getTestById(testId);
            req.setAttribute("test", test);
            req.getRequestDispatcher("/jsp/test-results.jsp").forward(req, resp);
            return;
        }

        // Handle edit form
        if ("edit".equals(action)) {
            String testId = req.getParameter("id");
            Test test = testDAO.getTestById(testId);
            req.setAttribute("test", test);
            req.setAttribute("students", studentDAO.getAllActiveStudents());
            req.setAttribute("examiners", instructorDAO.getAllActiveInstructors());
            req.getRequestDispatcher("/jsp/edit-test.jsp").forward(req, resp);
            return;
        }

        // Handle add form
        if ("add-form".equals(action)) {
            req.setAttribute("test", null);
            req.setAttribute("students", studentDAO.getAllActiveStudents());
            req.setAttribute("examiners", instructorDAO.getAllActiveInstructors());
            req.getRequestDispatcher("/jsp/edit-test.jsp").forward(req, resp);
            return;
        }

        // Handle calendar view
        String view = req.getParameter("view");
        if ("calendar".equals(view)) {
            int year = LocalDate.now().getYear();
            int month = LocalDate.now().getMonthValue();

            String yearParam = req.getParameter("year");
            String monthParam = req.getParameter("month");

            if (yearParam != null) year = Integer.parseInt(yearParam);
            if (monthParam != null) month = Integer.parseInt(monthParam);

            Map<String, List<Test>> calendarData = testDAO.getTestsForMonth(year, month);
            req.setAttribute("calendarData", calendarData);
            req.setAttribute("currentYear", year);
            req.setAttribute("currentMonth", month);
            req.getRequestDispatcher("/jsp/test-calendar.jsp").forward(req, resp);
            return;
        }

        // Default list view
        String date = req.getParameter("date");
        if (date == null || date.isEmpty()) {
            date = LocalDate.now().toString();
        }

        List<Test> upcomingTests = testDAO.getUpcomingTests();
        List<Test> testsByDate = testDAO.getTestsByDate(date);
        Map<String, Object> statistics = testDAO.getTestStatistics();

        req.setAttribute("upcomingTests", upcomingTests);
        req.setAttribute("testsByDate", testsByDate);
        req.setAttribute("selectedDate", date);
        req.setAttribute("statistics", statistics);
        req.getRequestDispatcher("/jsp/tests.jsp").forward(req, resp);
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

        // Handle results submission
        if ("results".equals(action)) {
            String testId = req.getParameter("testId");
            String scoreStr = req.getParameter("score");
            String notes = req.getParameter("notes");
            String result = req.getParameter("result"); // "Pass" or "Fail"

            if (testId == null || result == null || (!result.equals("Pass") && !result.equals("Fail"))) {
                resp.sendRedirect(req.getContextPath() + "/tests?error=invalidData");
                return;
            }

            // Score is optional; default to 0 if not provided
            int score = 0;
            if (scoreStr != null && !scoreStr.trim().isEmpty()) {
                try {
                    score = Integer.parseInt(scoreStr.trim());
                    if (score < 0 || score > 100) throw new NumberFormatException();
                } catch (NumberFormatException e) {
                    resp.sendRedirect(req.getContextPath() + "/tests?action=results&id=" + testId + "&error=invalidScore");
                    return;
                }
            }

            if (testDAO.submitResults(testId, score, result, notes)) {
                resp.sendRedirect(req.getContextPath() + "/tests?success=resultsUpdated");
            } else {
                resp.sendRedirect(req.getContextPath() + "/tests?error=resultsFailed");
            }
            return;
        }

        // Handle add/update test
        String studentId = req.getParameter("studentId");
        String testType = req.getParameter("testType");
        String testDate = req.getParameter("testDate");
        String testTime = req.getParameter("testTime");
        String examinerId = req.getParameter("examinerId");
        String notes = req.getParameter("notes");

        // Validate required fields
        if (studentId == null || studentId.isEmpty() ||
                testType == null || testType.isEmpty() ||
                testDate == null || testDate.isEmpty() ||
                testTime == null || testTime.isEmpty() ||
                examinerId == null || examinerId.isEmpty()) {

            String redirect = ("update".equals(action)) ?
                    "/tests?action=edit&id=" + req.getParameter("testId") + "&error=empty" :
                    "/tests?action=add-form&error=empty";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // Validate test time (8am-5pm)
        if (!testDAO.isValidTestTime(testTime)) {
            String redirect = ("update".equals(action)) ?
                    "/tests?action=edit&id=" + req.getParameter("testId") + "&error=invalidTime" :
                    "/tests?action=add-form&error=invalidTime";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // Validate test date (cannot be past)
        if (testDate.compareTo(LocalDate.now().toString()) < 0) {
            String redirect = ("update".equals(action)) ?
                    "/tests?action=edit&id=" + req.getParameter("testId") + "&error=pastDate" :
                    "/tests?action=add-form&error=pastDate";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // Get details
        Student student = studentDAO.getStudentById(studentId);
        Instructor examiner = instructorDAO.getInstructorById(examinerId);

        if (student == null || examiner == null) {
            resp.sendRedirect(req.getContextPath() + "/tests?action=add-form&error=invalidData");
            return;
        }

        // Handle update
        if ("update".equals(action)) {
            String testId = req.getParameter("testId");

            Test existingTest = testDAO.getTestById(testId);
            if (existingTest == null) {
                resp.sendRedirect(req.getContextPath() + "/tests?error=notFound");
                return;
            }

            Test test = new Test(
                    testId, studentId, student.getName(),
                    testType, testDate, testTime,
                    examinerId, examiner.getName(),
                    0, "Pending", "Scheduled",
                    existingTest.getScheduledDate(), notes
            );

            if (testDAO.updateTest(test)) {
                resp.sendRedirect(req.getContextPath() + "/tests?success=updated");
            } else {
                resp.sendRedirect(req.getContextPath() + "/tests?action=edit&id=" + testId + "&error=conflict");
            }
            return;
        }

        // Handle add
        if ("add".equals(action)) {
            String testId = testDAO.generateNextTestId();
            String scheduledDate = LocalDate.now().toString();

            Test test = new Test(
                    testId, studentId, student.getName(),
                    testType, testDate, testTime,
                    examinerId, examiner.getName(),
                    0, "Pending", "Scheduled",
                    scheduledDate, notes
            );

            if (testDAO.addTest(test)) {
                resp.sendRedirect(req.getContextPath() + "/tests?success=added");
            } else {
                resp.sendRedirect(req.getContextPath() + "/tests?action=add-form&error=conflict");
            }
        }
    }
}