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
import jakarta.servlet.http.HttpSession;

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

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        Object roleObj = session.getAttribute("userRole");
        String userRole = (roleObj != null) ? roleObj.toString() : "student";
        boolean isAdmin = "admin".equalsIgnoreCase(userRole);
        boolean isInstructor = "instructor".equalsIgnoreCase(userRole);

        String action = req.getParameter("action");

        // Instructor: results மட்டும் allow, student: எதுவும் கூடாது
        if (!isAdmin && !isInstructor && (
                "cancel".equals(action) ||
                        "results".equals(action) ||
                        "edit".equals(action) ||
                        "add-form".equals(action))) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        if (isInstructor && (
                "cancel".equals(action) ||
                        "edit".equals(action) ||
                        "add-form".equals(action))) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        if ("cancel".equals(action)) {
            String testId = req.getParameter("id");
            if (testId != null && testDAO.cancelTest(testId)) {
                resp.sendRedirect(req.getContextPath() + "/tests?success=cancelled");
            } else {
                resp.sendRedirect(req.getContextPath() + "/tests?error=cancelFailed");
            }
            return;
        }

        if ("results".equals(action)) {
            String testId = req.getParameter("id");
            Test test = testDAO.getTestById(testId);
            req.setAttribute("test", test);
            req.getRequestDispatcher("/jsp/test-results.jsp").forward(req, resp);
            return;
        }

        if ("edit".equals(action)) {
            String testId = req.getParameter("id");
            Test test = testDAO.getTestById(testId);
            req.setAttribute("test", test);
            req.setAttribute("students", studentDAO.getAllActiveStudents());
            req.setAttribute("examiners", instructorDAO.getAllActiveInstructors());
            req.getRequestDispatcher("/jsp/edit-test.jsp").forward(req, resp);
            return;
        }

        if ("add-form".equals(action)) {
            req.setAttribute("test", null);
            req.setAttribute("students", studentDAO.getAllActiveStudents());
            req.setAttribute("examiners", instructorDAO.getAllActiveInstructors());
            req.getRequestDispatcher("/jsp/edit-test.jsp").forward(req, resp);
            return;
        }

        String view = req.getParameter("view");
        if ("calendar".equals(view)) {
            // FIX: Instructor-um calendar paarkkalam, admin மட்டும் இல்லை
            if (!isAdmin && !isInstructor) {
                resp.sendRedirect(req.getContextPath() + "/tests");
                return;
            }

            int year  = LocalDate.now().getYear();
            int month = LocalDate.now().getMonthValue();

            String yearParam  = req.getParameter("year");
            String monthParam = req.getParameter("month");
            if (yearParam  != null && !yearParam.isEmpty())  year  = Integer.parseInt(yearParam);
            if (monthParam != null && !monthParam.isEmpty()) month = Integer.parseInt(monthParam);

            Map<String, List<Test>> calendarData;

            if (isAdmin) {
                // Admin: எல்லா tests-உம் காட்டு
                calendarData = testDAO.getTestsForMonth(year, month);
            } else {
                // Instructor: அவங்களோட tests மட்டும்
                // loggedInUser = email, அதை வச்சு instructorId find பண்றோம்
                String username = (String) session.getAttribute("loggedInUser");
                Instructor instructor = instructorDAO.getInstructorByUsername(username);
                String instructorId = (instructor != null) ? instructor.getInstructorId() : "";
                calendarData = testDAO.getTestsForMonthByExaminer(year, month, instructorId);
            }

            req.setAttribute("calendarData",  calendarData);
            req.setAttribute("currentYear",   year);
            req.setAttribute("currentMonth",  month);
            req.setAttribute("isAdmin",       isAdmin);
            req.getRequestDispatcher("/jsp/test-calendar.jsp").forward(req, resp);
            return;
        }

        String date = req.getParameter("date");
        if (date == null || date.isEmpty()) date = LocalDate.now().toString();

        String loggedInUser = (String) session.getAttribute("loggedInUser");

        List<Test> upcomingTests;
        List<Test> testsByDate;
        Map<String, Object> statistics = testDAO.getTestStatistics();

        if (isAdmin) {
            // Admin: எல்லா tests - Completed உட்பட எல்லாமே காட்டு
            upcomingTests = testDAO.getAllTestsSorted();
            testsByDate   = testDAO.getTestsByDate(date);
        } else if (isInstructor) {
            // Instructor: username=examinerName match - எல்லா tests (completed உட்பட)
            Instructor instr = instructorDAO.getInstructorByUsername(loggedInUser);
            String instrId = (instr != null) ? instr.getInstructorId() : "";
            upcomingTests = testDAO.getTestsByExaminer(instrId);
            testsByDate   = testDAO.getTestsByExaminerAndDate(instrId, date);
        } else {
            // Student: studentName match - எல்லா tests (completed உட்பட)
            upcomingTests = testDAO.getTestsByStudentName(loggedInUser);
            testsByDate   = testDAO.getTestsByStudentNameAndDate(loggedInUser, date);
        }

        req.setAttribute("upcomingTests", upcomingTests);
        req.setAttribute("testsByDate",   testsByDate);
        req.setAttribute("selectedDate",  date);
        req.setAttribute("statistics",    statistics);
        req.getRequestDispatcher("/jsp/tests.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        Object roleObj = session.getAttribute("userRole");
        String userRole = (roleObj != null) ? roleObj.toString() : "student";
        boolean isAdminPost = "admin".equalsIgnoreCase(userRole);
        boolean isInstructorPost = "instructor".equalsIgnoreCase(userRole);

        // Student: எதுவும் POST கூடாது
        if (!isAdminPost && !isInstructorPost) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        // Instructor: results மட்டும் submit பண்ணலாம்
        if (isInstructorPost && !"results".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // Admin: results submit கூடாது - instructor மட்டும்
        if (isAdminPost && "results".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/tests?error=notAllowed");
            return;
        }

        if ("results".equals(action)) {
            String testId   = req.getParameter("testId");
            String scoreStr = req.getParameter("score");
            String notes    = req.getParameter("notes");
            String result   = req.getParameter("result");

            if (testId == null || result == null ||
                    (!result.equals("Pass") && !result.equals("Fail"))) {
                resp.sendRedirect(req.getContextPath() + "/tests?error=invalidData");
                return;
            }

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

        String studentId  = req.getParameter("studentId");
        String testType   = req.getParameter("testType");
        String testDate   = req.getParameter("testDate");
        String testTime   = req.getParameter("testTime");
        String examinerId = req.getParameter("examinerId");
        String notes      = req.getParameter("notes");

        if (studentId == null || studentId.isEmpty() ||
                testType == null || testType.isEmpty() ||
                testDate == null || testDate.isEmpty() ||
                testTime == null || testTime.isEmpty() ||
                examinerId == null || examinerId.isEmpty()) {

            String redirect = "update".equals(action) ?
                    "/tests?action=edit&id=" + req.getParameter("testId") + "&error=empty" :
                    "/tests?action=add-form&error=empty";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        if (!testDAO.isValidTestTime(testTime)) {
            String redirect = "update".equals(action) ?
                    "/tests?action=edit&id=" + req.getParameter("testId") + "&error=invalidTime" :
                    "/tests?action=add-form&error=invalidTime";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        if (testDate.compareTo(LocalDate.now().toString()) < 0) {
            String redirect = "update".equals(action) ?
                    "/tests?action=edit&id=" + req.getParameter("testId") + "&error=pastDate" :
                    "/tests?action=add-form&error=pastDate";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        Student student     = studentDAO.getStudentById(studentId);
        Instructor examiner = instructorDAO.getInstructorById(examinerId);

        if (student == null || examiner == null) {
            resp.sendRedirect(req.getContextPath() + "/tests?action=add-form&error=invalidData");
            return;
        }

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

        if ("add".equals(action)) {
            String testId        = testDAO.generateNextTestId();
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