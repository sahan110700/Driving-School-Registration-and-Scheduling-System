package servlet;

import dao.StudentDAO;
import dao.InstructorDAO;
import dao.VehicleDAO;
import dao.LessonDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final InstructorDAO instructorDAO = new InstructorDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html; charset=UTF-8");
        // Prevent browser caching — stops back-button access after logout
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        boolean loggedIn = req.getSession(false) != null &&
                req.getSession(false).getAttribute("loggedInUser") != null;

        String username = "";
        if (loggedIn) {
            username = String.valueOf(req.getSession(false).getAttribute("loggedInUser"));
        }

        String welcomeLine;
        if (loggedIn) {
            String initial = username.isEmpty() ? "U" : String.valueOf(username.charAt(0)).toUpperCase();
            welcomeLine = "<div class='welcome-row'>" +
                    "<div class='user-avatar'>" + escape(initial) + "</div>" +
                    "<div><div style='font-size:11px;color:#9ca3af;font-weight:500;'>Logged in as</div>" +
                    "<strong style='color:#667eea;font-size:15px;'>" + escape(username) + "</strong></div>" +
                    "</div>";
        } else {
            welcomeLine = "<div class='welcome'>Welcome! Please login to access all features</div>";
        }

        // FIX: Get role from session to show correct cards
        String role = "";
        if (loggedIn) {
            Object roleObj = req.getSession(false).getAttribute("userRole");
            role = (roleObj != null) ? roleObj.toString() : "student";
        }

        String cards;
        if (loggedIn && "admin".equalsIgnoreCase(role)) {
            // ADMIN sees all management cards
            cards =
                    "<div class='cards-grid'>" +

                            "<div class='card student-card'>" +
                            "<div class='card-icon'><i class='fas fa-user-graduate'></i></div>" +
                            "<h3>Student Management</h3>" +
                            "<p>Manage student registrations, profiles, and academic records with ease.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Active Students</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/students'>Access Portal <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card instructor-card'>" +
                            "<div class='card-icon'><i class='fas fa-chalkboard-teacher'></i></div>" +
                            "<h3>Instructor Management</h3>" +
                            "<p>Track instructor availability, qualifications, and assigned lessons.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Active Instructors</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/instructors'>Access Portal <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card vehicle-card'>" +
                            "<div class='card-icon'><i class='fas fa-car'></i></div>" +
                            "<h3>Vehicle Management</h3>" +
                            "<p>Maintain fleet records, track maintenance, and monitor vehicle usage.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Active Vehicles</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/vehicles'>Access Portal <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card lesson-card'>" +
                            "<div class='card-icon'><i class='fas fa-calendar-check'></i></div>" +
                            "<h3>Lesson Scheduling</h3>" +
                            "<p>Schedule and manage practical driving lessons efficiently.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Upcoming Lessons</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/lessons'>Access Portal <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card payment-card'>" +
                            "<div class='card-icon'><i class='fas fa-money-bill-wave'></i></div>" +
                            "<h3>Payment Management</h3>" +
                            "<p>Track payments, manage balances, and generate financial reports.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Total Revenue</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/payments'>Access Portal <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card test-card'>" +
                            "<div class='card-icon'><i class='fas fa-clipboard-list'></i></div>" +
                            "<h3>Test Management</h3>" +
                            "<p>Schedule driving tests, record results, and track student progress.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Upcoming Tests</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/tests'>Access Portal <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "</div>";

        } else if (loggedIn) {
            // STUDENT sees only their own relevant cards: lessons, tests, payments, logout
            cards =
                    "<div class='cards-grid'>" +

                            "<div class='card lesson-card'>" +
                            "<div class='card-icon'><i class='fas fa-calendar-check'></i></div>" +
                            "<h3>My Lessons</h3>" +
                            "<p>View your upcoming and past driving lessons.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Upcoming Lessons</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/lessons'>View Lessons <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card test-card'>" +
                            "<div class='card-icon'><i class='fas fa-clipboard-list'></i></div>" +
                            "<h3>My Tests</h3>" +
                            "<p>Check your driving test schedule and results.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Upcoming Tests</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/tests'>View Tests <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card payment-card'>" +
                            "<div class='card-icon'><i class='fas fa-money-bill-wave'></i></div>" +
                            "<h3>My Payments</h3>" +
                            "<p>View your payment history and outstanding balances.</p>" +
                            "<div class='card-stats'><span class='stat-badge'>Payment History</span></div>" +
                            "<div class='btn-row'><a class='btn primary' href='" + req.getContextPath() + "/payments'>View Payments <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "</div>";
        } else {
            String errorParam = req.getParameter("error");
            String errorMsg = "";
            if ("empty".equals(errorParam)) {
                errorMsg = "<div class=\'login-error\'><i class=\'fas fa-exclamation-circle\'></i> Please enter username and password.</div>";
            } else if ("invalid".equals(errorParam)) {
                errorMsg = "<div class=\'login-error\'><i class=\'fas fa-exclamation-circle\'></i> Invalid username or password.</div>";
            }

            cards =
                    "<div class=\'login-hero-wrap\'>" +
                            "<div class=\'login-features\'>" +
                            "<div class=\'login-tag\'><i class=\'fas fa-shield-alt\'></i> Secure &amp; Reliable Platform</div>" +
                            "<h2 class=\'login-headline\'>Your Journey<br><span>Starts Here</span></h2>" +
                            "<p class=\'login-sub\'>Roadify&#39;s comprehensive management system helps you streamline student registrations, instructor assignments, vehicle tracking, payments, and driving tests — all in one place.</p>" +
                            "<div class=\'feat-list\'>" +
                            "<div class=\'feat-item\'><i class=\'fas fa-users\'></i> Student &amp; Instructor Management</div>" +
                            "<div class=\'feat-item\'><i class=\'fas fa-car\'></i> Vehicle Fleet Tracking</div>" +
                            "<div class=\'feat-item\'><i class=\'fas fa-calendar-check\'></i> Lesson &amp; Test Scheduling</div>" +
                            "<div class=\'feat-item\'><i class=\'fas fa-credit-card\'></i> Payment Processing</div>" +
                            "</div>" +
                            "</div>" +
                            "<div class=\'login-form-card\'>" +
                            "<div class=\'lfc-header\'>" +
                            "<div class=\'lfc-avatar\'><i class=\'fas fa-user-circle\'></i></div>" +
                            "<h3>Welcome Back</h3>" +
                            "<p>Sign in to access your dashboard</p>" +
                            "</div>" +
                            errorMsg +
                            "<form action=\'" + req.getContextPath() + "/login\' method=\'post\'>" +
                            "<div class=\'lfc-group\'>" +
                            "<label>Username</label>" +
                            "<div class=\'lfc-input-wrap\'><i class=\'fas fa-user\'></i><input type=\'text\' name=\'username\' placeholder=\'Enter your username\' required></div>" +
                            "</div>" +
                            "<div class=\'lfc-group\'>" +
                            "<label>Password</label>" +
                            "<div class=\'lfc-input-wrap\'><i class=\'fas fa-lock\'></i><input type=\'password\' name=\'password\' placeholder=\'Enter your password\' required></div>" +
                            "</div>" +
                            "<button type=\'submit\' class=\'lfc-btn\'><i class=\'fas fa-sign-in-alt\'></i> Login to Dashboard</button>" +
                            "</form>" +
                            "</div>" +
                            "</div>";
        }

        String html =
                "<!DOCTYPE html>" +
                        "<html lang='en'>" +
                        "<head>" +
                        "<meta charset='UTF-8'>" +
                        "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                        "<title>Driving School Management System</title>" +
                        "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>" +
                        "<link href='https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap' rel='stylesheet'>" +
                        "<style>" +
                        "* {" +
                        "  margin: 0;" +
                        "  padding: 0;" +
                        "  box-sizing: border-box;" +
                        "}" +
                        "" +
                        "body {" +
                        "  font-family: 'Inter', sans-serif;" +
                        "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" +
                        "  height: 100vh;" +
                        "  overflow: hidden;" +
                        "}" +
                        "" +
                        "/* Main Layout - Fixed Header, Scrollable Content */" +
                        ".app-container {" +
                        "  height: 100vh;" +
                        "  display: flex;" +
                        "  flex-direction: column;" +
                        "  overflow: hidden;" +
                        "}" +
                        "" +
                        "/* Fixed Header Section */" +
                        ".fixed-header {" +
                        "  flex-shrink: 0;" +
                        "  padding: 20px;" +
                        "  background: transparent;" +
                        "}" +
                        "" +
                        ".header {" +
                        "  background: rgba(255,255,255,0.97);" +
                        "  backdrop-filter: blur(16px);" +
                        "  border-radius: 20px;" +
                        "  padding: 16px 28px;" +
                        "  box-shadow: 0 8px 32px rgba(0,0,0,0.12), 0 1px 0 rgba(255,255,255,0.8) inset;" +
                        "  display: flex;" +
                        "  justify-content: space-between;" +
                        "  align-items: center;" +
                        "  flex-wrap: wrap;" +
                        "  gap: 16px;" +
                        "  animation: slideDown 0.5s ease;" +
                        "  border: 1px solid rgba(255,255,255,0.6);" +
                        "}" +
                        "" +
                        "@keyframes slideDown {" +
                        "  from {" +
                        "    opacity: 0;" +
                        "    transform: translateY(-30px);" +
                        "  }" +
                        "  to {" +
                        "    opacity: 1;" +
                        "    transform: translateY(0);" +
                        "  }" +
                        "}" +
                        "" +
                        ".brand {" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  gap: 15px;" +
                        "}" +
                        "" +
                        ".logo {" +
                        "  width: 50px;" +
                        "  height: 50px;" +
                        "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" +
                        "  border-radius: 15px;" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  justify-content: center;" +
                        "}" +
                        "" +
                        ".logo i {" +
                        "  font-size: 28px;" +
                        "  color: white;" +
                        "}" +
                        "" +
                        ".brand-info h1 {" +
                        "  font-size: 20px;" +
                        "  font-weight: 700;" +
                        "  color: #1f2937;" +
                        "  margin-bottom: 5px;" +
                        "}" +
                        "" +
                        ".welcome {" +
                        "  font-size: 14px;" +
                        "  color: #4b5563;" +
                        "  font-weight: 500;" +
                        "}" +
                        "" +
                        ".welcome strong {" +
                        "  color: #667eea;" +
                        "  font-weight: 700;" +
                        "}" +
                        "" +
                        ".system-badge {" +
                        "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" +
                        "  color: white;" +
                        "  padding: 8px 16px;" +
                        "  border-radius: 20px;" +
                        "  font-size: 12px;" +
                        "  font-weight: 600;" +
                        "}" +
                        "" +
                        "/* Scrollable Content Area */" +
                        ".scrollable-content {" +
                        "  flex: 1;" +
                        "  overflow-y: auto;" +
                        "  padding: 0 20px 20px 20px;" +
                        "}" +
                        "" +
                        ".scrollable-content::-webkit-scrollbar {" +
                        "  width: 8px;" +
                        "}" +
                        "" +
                        ".scrollable-content::-webkit-scrollbar-track {" +
                        "  background: rgba(255, 255, 255, 0.1);" +
                        "  border-radius: 10px;" +
                        "}" +
                        "" +
                        ".scrollable-content::-webkit-scrollbar-thumb {" +
                        "  background: rgba(255, 255, 255, 0.3);" +
                        "  border-radius: 10px;" +
                        "}" +
                        "" +
                        ".scrollable-content::-webkit-scrollbar-thumb:hover {" +
                        "  background: rgba(255, 255, 255, 0.5);" +
                        "}" +
                        "" +
                        "/* Hero Section */" +
                        ".hero {" +
                        "  background: linear-gradient(135deg, rgba(102, 126, 234, 0.15) 0%, rgba(118, 75, 162, 0.15) 100%);" +
                        "  backdrop-filter: blur(10px);" +
                        "  border-radius: 24px;" +
                        "  padding: 40px;" +
                        "  margin-bottom: 30px;" +
                        "  text-align: center;" +
                        "  animation: fadeInUp 0.6s ease;" +
                        "}" +
                        "" +
                        "@keyframes fadeInUp {" +
                        "  from {" +
                        "    opacity: 0;" +
                        "    transform: translateY(30px);" +
                        "  }" +
                        "  to {" +
                        "    opacity: 1;" +
                        "    transform: translateY(0);" +
                        "  }" +
                        "}" +
                        "" +
                        ".hero h2 {" +
                        "  font-size: 36px;" +
                        "  font-weight: 800;" +
                        "  background: linear-gradient(135deg, #fff 0%, #e0e7ff 100%);" +
                        "  -webkit-background-clip: text;" +
                        "  -webkit-text-fill-color: transparent;" +
                        "  background-clip: text;" +
                        "  margin-bottom: 15px;" +
                        "}" +
                        "" +
                        ".hero p {" +
                        "  font-size: 16px;" +
                        "  color: rgba(255, 255, 255, 0.9);" +
                        "  max-width: 600px;" +
                        "  margin: 0 auto;" +
                        "  line-height: 1.6;" +
                        "}" +
                        "" +
                        "/* Stats Section */" +
                        ".stats-section {" +
                        "  display: grid;" +
                        "  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));" +
                        "  gap: 20px;" +
                        "  margin-bottom: 30px;" +
                        "}" +
                        "" +
                        ".stat-card {" +
                        "  background: rgba(255, 255, 255, 0.95);" +
                        "  border-radius: 20px;" +
                        "  padding: 20px;" +
                        "  text-align: center;" +
                        "  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);" +
                        "  transition: transform 0.3s ease, box-shadow 0.3s ease;" +
                        "}" +
                        "" +
                        ".stat-card:hover {" +
                        "  transform: translateY(-5px);" +
                        "  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);" +
                        "}" +
                        "" +
                        ".stat-card i {" +
                        "  font-size: 40px;" +
                        "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" +
                        "  -webkit-background-clip: text;" +
                        "  -webkit-text-fill-color: transparent;" +
                        "  margin-bottom: 10px;" +
                        "}" +
                        "" +
                        ".stat-number {" +
                        "  font-size: 32px;" +
                        "  font-weight: 800;" +
                        "  color: #1f2937;" +
                        "  margin-bottom: 5px;" +
                        "}" +
                        "" +
                        ".stat-label {" +
                        "  font-size: 14px;" +
                        "  color: #6b7280;" +
                        "}" +
                        "" +
                        "/* Cards Grid */" +
                        ".cards-grid {" +
                        "  display: grid;" +
                        "  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));" +
                        "  gap: 25px;" +
                        "}" +
                        "" +
                        ".card {" +
                        "  background: white;" +
                        "  border-radius: 24px;" +
                        "  padding: 25px;" +
                        "  transition: all 0.3s ease;" +
                        "  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);" +
                        "  position: relative;" +
                        "  overflow: hidden;" +
                        "}" +
                        "" +
                        ".card:hover {" +
                        "  transform: translateY(-8px);" +
                        "  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);" +
                        "}" +
                        "" +
                        ".card::before {" +
                        "  content: '';" +
                        "  position: absolute;" +
                        "  top: 0;" +
                        "  left: 0;" +
                        "  right: 0;" +
                        "  height: 4px;" +
                        "  background: linear-gradient(90deg, #667eea, #764ba2);" +
                        "  transform: scaleX(0);" +
                        "  transition: transform 0.3s ease;" +
                        "}" +
                        "" +
                        ".card:hover::before {" +
                        "  transform: scaleX(1);" +
                        "}" +
                        "" +
                        ".card-icon {" +
                        "  width: 60px;" +
                        "  height: 60px;" +
                        "  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);" +
                        "  border-radius: 15px;" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  justify-content: center;" +
                        "  margin-bottom: 20px;" +
                        "}" +
                        "" +
                        ".card-icon i {" +
                        "  font-size: 28px;" +
                        "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" +
                        "  -webkit-background-clip: text;" +
                        "  -webkit-text-fill-color: transparent;" +
                        "}" +
                        "" +
                        ".card h3 {" +
                        "  font-size: 20px;" +
                        "  font-weight: 700;" +
                        "  margin-bottom: 12px;" +
                        "  color: #1f2937;" +
                        "}" +
                        "" +
                        ".card p {" +
                        "  font-size: 14px;" +
                        "  color: #6b7280;" +
                        "  line-height: 1.5;" +
                        "  margin-bottom: 20px;" +
                        "}" +
                        "" +
                        ".card-stats {" +
                        "  margin-bottom: 20px;" +
                        "}" +
                        "" +
                        ".stat-badge {" +
                        "  background: #f3f4f6;" +
                        "  padding: 5px 12px;" +
                        "  border-radius: 20px;" +
                        "  font-size: 12px;" +
                        "  color: #6b7280;" +
                        "  display: inline-block;" +
                        "}" +
                        "" +
                        ".btn-row {" +
                        "  display: flex;" +
                        "  justify-content: flex-end;" +
                        "}" +
                        "" +
                        ".btn {" +
                        "  display: inline-flex;" +
                        "  align-items: center;" +
                        "  gap: 8px;" +
                        "  padding: 10px 20px;" +
                        "  border-radius: 12px;" +
                        "  font-weight: 600;" +
                        "  font-size: 14px;" +
                        "  text-decoration: none;" +
                        "  transition: all 0.3s ease;" +
                        "  cursor: pointer;" +
                        "  border: none;" +
                        "}" +
                        "" +
                        ".btn.primary {" +
                        "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" +
                        "  color: white;" +
                        "}" +
                        "" +
                        ".btn.primary:hover {" +
                        "  transform: translateX(5px);" +
                        "  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);" +
                        "}" +
                        "" +
                        ".btn.secondary {" +
                        "  background: #f3f4f6;" +
                        "  color: #667eea;" +
                        "}" +
                        "" +
                        ".btn.secondary:hover {" +
                        "  background: #e5e7eb;" +
                        "}" +
                        "" +
                        ".btn.danger {" +
                        "  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);" +
                        "  color: white;" +
                        "}" +
                        "" +
                        ".btn.danger:hover {" +
                        "  transform: translateX(5px);" +
                        "  box-shadow: 0 5px 15px rgba(239, 68, 68, 0.4);" +
                        "}" +
                        "" +
                        "/* Footer */" +
                        ".footer {" +
                        "  margin-top: 30px;" +
                        "  text-align: center;" +
                        "  padding: 20px;" +
                        "  background: rgba(255, 255, 255, 0.1);" +
                        "  backdrop-filter: blur(10px);" +
                        "  border-radius: 20px;" +
                        "  color: rgba(255, 255, 255, 0.9);" +
                        "  font-size: 13px;" +
                        "}" +
                        "" +
                        "/* Login Hero Layout */" +
                        ".login-hero-wrap {" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  gap: 60px;" +
                        "  padding: 20px 0 40px 0;" +
                        "}" +
                        ".login-features {" +
                        "  flex: 1;" +
                        "  color: white;" +
                        "}" +
                        ".login-tag {" +
                        "  display: inline-flex;" +
                        "  align-items: center;" +
                        "  gap: 8px;" +
                        "  background: rgba(255,255,255,0.15);" +
                        "  border: 1px solid rgba(255,255,255,0.25);" +
                        "  color: white;" +
                        "  padding: 6px 16px;" +
                        "  border-radius: 20px;" +
                        "  font-size: 13px;" +
                        "  font-weight: 600;" +
                        "  margin-bottom: 24px;" +
                        "}" +
                        ".login-headline {" +
                        "  font-size: 48px !important;" +
                        "  font-weight: 800 !important;" +
                        "  line-height: 1.1 !important;" +
                        "  margin-bottom: 20px !important;" +
                        "  -webkit-text-fill-color: white !important;" +
                        "  background: none !important;" +
                        "}" +
                        ".login-headline span {" +
                        "  color: #e9d5ff;" +
                        "  -webkit-text-fill-color: #e9d5ff;" +
                        "}" +
                        ".login-sub {" +
                        "  font-size: 16px;" +
                        "  line-height: 1.7;" +
                        "  color: rgba(255,255,255,0.85);" +
                        "  margin-bottom: 32px;" +
                        "}" +
                        ".feat-list {" +
                        "  display: flex;" +
                        "  flex-direction: column;" +
                        "  gap: 12px;" +
                        "}" +
                        ".feat-item {" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  gap: 12px;" +
                        "  color: rgba(255,255,255,0.9);" +
                        "  font-size: 15px;" +
                        "  font-weight: 500;" +
                        "}" +
                        ".feat-item i {" +
                        "  width: 34px;" +
                        "  height: 34px;" +
                        "  background: rgba(255,255,255,0.15);" +
                        "  border-radius: 8px;" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  justify-content: center;" +
                        "  font-size: 14px;" +
                        "  flex-shrink: 0;" +
                        "}" +
                        ".login-form-card {" +
                        "  background: white;" +
                        "  border-radius: 24px;" +
                        "  padding: 44px 40px;" +
                        "  width: 400px;" +
                        "  flex-shrink: 0;" +
                        "  box-shadow: 0 24px 64px rgba(0,0,0,0.25);" +
                        "}" +
                        ".lfc-header {" +
                        "  text-align: center;" +
                        "  margin-bottom: 28px;" +
                        "}" +
                        ".lfc-avatar {" +
                        "  width: 64px;" +
                        "  height: 64px;" +
                        "  background: linear-gradient(135deg, #667eea, #764ba2);" +
                        "  border-radius: 18px;" +
                        "  display: inline-flex;" +
                        "  align-items: center;" +
                        "  justify-content: center;" +
                        "  font-size: 28px;" +
                        "  color: white;" +
                        "  margin-bottom: 14px;" +
                        "}" +
                        ".lfc-header h3 {" +
                        "  font-size: 22px;" +
                        "  font-weight: 800;" +
                        "  color: #1f2937;" +
                        "  margin-bottom: 4px;" +
                        "}" +
                        ".lfc-header p {" +
                        "  color: #6b7280;" +
                        "  font-size: 14px;" +
                        "  margin-bottom: 0;" +
                        "}" +
                        ".login-error {" +
                        "  background: #fee2e2;" +
                        "  color: #991b1b;" +
                        "  border: 1px solid #fca5a5;" +
                        "  padding: 10px 14px;" +
                        "  border-radius: 10px;" +
                        "  font-size: 13px;" +
                        "  margin-bottom: 18px;" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  gap: 8px;" +
                        "}" +
                        ".lfc-group {" +
                        "  margin-bottom: 16px;" +
                        "}" +
                        ".lfc-group label {" +
                        "  display: block;" +
                        "  font-size: 13px;" +
                        "  font-weight: 600;" +
                        "  color: #374151;" +
                        "  margin-bottom: 7px;" +
                        "}" +
                        ".lfc-input-wrap {" +
                        "  position: relative;" +
                        "}" +
                        ".lfc-input-wrap i {" +
                        "  position: absolute;" +
                        "  left: 13px;" +
                        "  top: 50%;" +
                        "  transform: translateY(-50%);" +
                        "  color: #9ca3af;" +
                        "  font-size: 14px;" +
                        "}" +
                        ".lfc-input-wrap input {" +
                        "  width: 100%;" +
                        "  padding: 11px 14px 11px 38px;" +
                        "  border: 2px solid #e5e7eb;" +
                        "  border-radius: 11px;" +
                        "  font-size: 14px;" +
                        "  font-family: inherit;" +
                        "  color: #1f2937;" +
                        "  transition: border-color 0.2s;" +
                        "}" +
                        ".lfc-input-wrap input:focus {" +
                        "  outline: none;" +
                        "  border-color: #667eea;" +
                        "}" +
                        ".lfc-btn {" +
                        "  width: 100%;" +
                        "  margin-top: 8px;" +
                        "  padding: 13px;" +
                        "  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" +
                        "  color: white;" +
                        "  border: none;" +
                        "  border-radius: 12px;" +
                        "  font-size: 15px;" +
                        "  font-weight: 700;" +
                        "  cursor: pointer;" +
                        "  font-family: inherit;" +
                        "  display: flex;" +
                        "  align-items: center;" +
                        "  justify-content: center;" +
                        "  gap: 8px;" +
                        "  transition: opacity 0.2s, transform 0.1s;" +
                        "}" +
                        ".lfc-btn:hover { opacity: 0.9; transform: translateY(-1px); }" +
                        "@media (max-width: 900px) {" +
                        "  .login-hero-wrap { flex-direction: column; gap: 30px; }" +
                        "  .login-form-card { width: 100%; max-width: 420px; }" +
                        "  .login-headline { font-size: 32px !important; text-align: center; }" +
                        "  .login-features { text-align: center; }" +
                        "  .feat-list { align-items: center; }" +
                        "}" +
                        "" +
                        "/* Responsive */" +
                        "@media (max-width: 768px) {" +
                        "  .fixed-header {" +
                        "    padding: 15px;" +
                        "  }" +
                        "  .header {" +
                        "    flex-direction: column;" +
                        "    text-align: center;" +
                        "  }" +
                        "  .hero {" +
                        "    padding: 30px 20px;" +
                        "  }" +
                        "  .hero h2 {" +
                        "    font-size: 28px;" +
                        "  }" +
                        "  .cards-grid {" +
                        "    grid-template-columns: 1fr;" +
                        "  }" +
                        "  .scrollable-content {" +
                        "    padding: 0 15px 15px 15px;" +
                        "  }" +
                        "}" +
                        "@keyframes floatUp {" +"  0% { opacity:0; transform: translateY(40px); }" +"  100% { opacity:1; transform: translateY(0); }" +"}" +"@keyframes fadeInLeft {" +"  0% { opacity:0; transform: translateX(-40px); }" +"  100% { opacity:1; transform: translateX(0); }" +"}" +"@keyframes fadeInRight {" +"  0% { opacity:0; transform: translateX(40px); }" +"  100% { opacity:1; transform: translateX(0); }" +"}" +"@keyframes pulse { 0%,100% { box-shadow: 0 0 0 0 rgba(102,126,234,0.4); } 50% { box-shadow: 0 0 0 12px rgba(102,126,234,0); } }" +".login-hero-wrap { animation: floatUp 0.7s ease both; }" +".login-features { animation: fadeInLeft 0.8s ease 0.1s both; }" +".login-form-card { animation: fadeInRight 0.8s ease 0.2s both; transition: box-shadow 0.3s; }" +".login-form-card:hover { box-shadow: 0 28px 72px rgba(0,0,0,0.3); }" +".lfc-avatar { animation: pulse 2.5s infinite 1s; }" +".feat-item { transition: transform 0.2s ease; }" +".feat-item:hover { transform: translateX(6px); }" +".logo { width:52px; height:52px; background: linear-gradient(135deg,#667eea,#764ba2); border-radius:16px; display:flex; align-items:center; justify-content:center; box-shadow:0 4px 15px rgba(102,126,234,0.4); transition: transform 0.3s; }" +".logo:hover { transform: rotate(10deg) scale(1.1); }" +".logo i { font-size:26px; color:white; }" +".brand-info h1 { font-size:22px; font-weight:800; letter-spacing:-0.5px; }" +".cards-grid .card:nth-child(1){animation:floatUp 0.5s 0.05s ease both;}" +".cards-grid .card:nth-child(2){animation:floatUp 0.5s 0.1s ease both;}" +".cards-grid .card:nth-child(3){animation:floatUp 0.5s 0.15s ease both;}" +".cards-grid .card:nth-child(4){animation:floatUp 0.5s 0.2s ease both;}" +".cards-grid .card:nth-child(5){animation:floatUp 0.5s 0.25s ease both;}" +".cards-grid .card:nth-child(6){animation:floatUp 0.5s 0.3s ease both;}" +".cards-grid .card:nth-child(7){animation:floatUp 0.5s 0.35s ease both;}" +".stats-section .stat-card:nth-child(1){animation:floatUp 0.5s 0.05s ease both;}" +".stats-section .stat-card:nth-child(2){animation:floatUp 0.5s 0.12s ease both;}" +".stats-section .stat-card:nth-child(3){animation:floatUp 0.5s 0.19s ease both;}" +".stats-section .stat-card:nth-child(4){animation:floatUp 0.5s 0.26s ease both;}" +".lfc-btn:hover { box-shadow: 0 8px 24px rgba(102,126,234,0.45); opacity:0.92; transform:translateY(-1px); }" +
                        ".welcome-row { display:flex; align-items:center; gap:10px; }" +".user-avatar { width:36px; height:36px; background:linear-gradient(135deg,#667eea,#764ba2); border-radius:50%; display:flex; align-items:center; justify-content:center; color:white; font-weight:700; font-size:15px; flex-shrink:0; box-shadow:0 2px 8px rgba(102,126,234,0.4); }" +
                        ".header-logout-btn {" +"  display: inline-flex; align-items: center; gap: 8px;" +"  padding: 10px 20px;" +"  background: linear-gradient(135deg, #ef4444, #dc2626);" +"  color: white;" +"  text-decoration: none;" +"  border-radius: 12px;" +"  font-weight: 600;" +"  font-size: 14px;" +"  transition: all 0.2s ease;" +"  box-shadow: 0 3px 12px rgba(239,68,68,0.3);" +"}" +".header-logout-btn:hover {" +"  transform: translateY(-2px);" +"  box-shadow: 0 6px 20px rgba(239,68,68,0.4);" +"  opacity: 0.92;" +"}" +
                        "</style>" +
                        "</head>" +
                        "<body>" +
                        "<div class='app-container'>" +
                        "" +
                        "<!-- Fixed Header -->" +
                        "<div class='fixed-header'>" +
                        "<header class='header'>" +
                        "<div class='brand'>" +
                        "<div class='logo'><i class='fas fa-road'></i></div>" +
                        "<div class='brand-info'>" +
                        "<h1>Road<span style=\"color:#667eea\">ify</span></h1>" +
                        welcomeLine +
                        "</div>" +
                        "</div>" +
                        (loggedIn ? "<a href='" + req.getContextPath() + "/logout' class='header-logout-btn'><i class='fas fa-sign-out-alt'></i> Logout</a>" : "") +
                        "</header>" +
                        "</div>" +
                        "" +
                        "<!-- Scrollable Content -->" +
                        "<div class='scrollable-content'>" +
                        "" +
                        "<!-- Hero Section (logged in only) -->" +
                        (loggedIn ? "<section class='hero'><h2>Welcome to Your Dashboard</h2><p>Manage all aspects of your driving school from one central dashboard. Track students, instructors, vehicles, and more.</p></section>" : "") +
                        "" +
                        "<!-- Stats Section (only for logged in users) -->" +
                        (loggedIn ?
                                "<div class='stats-section'>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-users'></i>" +
                                "<div class='stat-number'>" + studentDAO.getAllStudents().size() + "</div>" +
                                "<div class='stat-label'>Total Students</div>" +
                                "</div>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-chalkboard-teacher'></i>" +
                                "<div class='stat-number'>" + instructorDAO.getAllActiveInstructors().size() + "</div>" +
                                "<div class='stat-label'>Active Instructors</div>" +
                                "</div>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-car'></i>" +
                                "<div class='stat-number'>" + vehicleDAO.getAllActiveVehicles().size() + "</div>" +
                                "<div class='stat-label'>Active Vehicles</div>" +
                                "</div>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-calendar-check'></i>" +
                                "<div class='stat-number'>" + lessonDAO.getLessonsByDate(java.time.LocalDate.now().toString()).size() + "</div>" +
                                "<div class='stat-label'>Today's Lessons</div>" +
                                "</div>" +
                                "</div>" : "") +
                        "" +
                        "<!-- Cards Grid -->" +
                        cards +
                        "" +
                        "<!-- Footer -->" +
                        "<footer class='footer'>" +
                        "<p>© 2024 Roadify - Driving School Management System | All Rights Reserved</p>" +
                        "<p style='margin-top: 10px; font-size: 12px;'><i class='fas fa-shield-alt'></i> Secure & Reliable | <i class='fas fa-chart-line'></i> Real-time Updates | <i class='fas fa-headset'></i> 24/7 Support</p>" +
                        "</footer>" +
                        "</div>" +
                        "</div>" +
                        "</body>" +
                        "</html>";

        resp.getWriter().println(html);
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}