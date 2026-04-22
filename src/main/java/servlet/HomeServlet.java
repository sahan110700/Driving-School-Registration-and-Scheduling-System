package servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html; charset=UTF-8");

        boolean loggedIn = req.getSession(false) != null &&
                req.getSession(false).getAttribute("loggedInUser") != null;

        String username = "";
        if (loggedIn) {
            username = String.valueOf(req.getSession(false).getAttribute("loggedInUser"));
        }

        String welcomeLine;
        if (loggedIn) {
            welcomeLine = "<div class='welcome'>Welcome back, <strong>" + escape(username) + "</strong></div>";
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

                            "<div class='card logout-card'>" +
                            "<div class='card-icon'><i class='fas fa-sign-out-alt'></i></div>" +
                            "<h3>Logout</h3>" +
                            "<p>End your session securely and return to the login page.</p>" +
                            "<div class='btn-row'><a class='btn danger' href='" + req.getContextPath() + "/logout'>Logout <i class='fas fa-sign-out-alt'></i></a></div>" +
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

                            "<div class='card logout-card'>" +
                            "<div class='card-icon'><i class='fas fa-sign-out-alt'></i></div>" +
                            "<h3>Logout</h3>" +
                            "<p>End your session securely and return to the login page.</p>" +
                            "<div class='btn-row'><a class='btn danger' href='" + req.getContextPath() + "/logout'>Logout <i class='fas fa-sign-out-alt'></i></a></div>" +
                            "</div>" +

                            "</div>";
        } else {
            cards =
                    "<div class='cards-grid login-grid'>" +

                            "<div class='card login-card'>" +
                            "<div class='card-icon'><i class='fas fa-sign-in-alt'></i></div>" +
                            "<h3>Login to Your Account</h3>" +
                            "<p>Access your dashboard to manage students, instructors, vehicles, and more.</p>" +
                            "<div class='btn-row'><a class='btn primary' href='jsp/login.jsp'>Login <i class='fas fa-arrow-right'></i></a></div>" +
                            "</div>" +

                            "<div class='card register-card'>" +
                            "<div class='card-icon'><i class='fas fa-user-plus'></i></div>" +
                            "<h3>Create New Account</h3>" +
                            "<p>Register as a new user to start managing your driving school operations.</p>" +
                            "<div class='btn-row'><a class='btn secondary' href='jsp/register.jsp'>Register <i class='fas fa-user-plus'></i></a></div>" +
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
                        "  background: rgba(255, 255, 255, 0.95);" +
                        "  backdrop-filter: blur(10px);" +
                        "  border-radius: 24px;" +
                        "  padding: 20px 30px;" +
                        "  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);" +
                        "  display: flex;" +
                        "  justify-content: space-between;" +
                        "  align-items: center;" +
                        "  flex-wrap: wrap;" +
                        "  gap: 20px;" +
                        "  animation: slideDown 0.5s ease;" +
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
                        "</style>" +
                        "</head>" +
                        "<body>" +
                        "<div class='app-container'>" +
                        "" +
                        "<!-- Fixed Header -->" +
                        "<div class='fixed-header'>" +
                        "<header class='header'>" +
                        "<div class='brand'>" +
                        "<div class='logo'><i class='fas fa-car'></i></div>" +
                        "<div class='brand-info'>" +
                        "<h1>DriveMaster Academy</h1>" +
                        welcomeLine +
                        "</div>" +
                        "</div>" +
                        "<div class='system-badge'>" +
                        "<i class='fas fa-cog'></i> v2.0 | Jakarta Servlet + JSP" +
                        "</div>" +
                        "</header>" +
                        "</div>" +
                        "" +
                        "<!-- Scrollable Content -->" +
                        "<div class='scrollable-content'>" +
                        "" +
                        "<!-- Hero Section -->" +
                        "<section class='hero'>" +
                        "<h2>" + (loggedIn ? "Welcome to Your Dashboard" : "Your Journey Starts Here") + "</h2>" +
                        "<p>" + (loggedIn ? "Manage all aspects of your driving school from one central dashboard. Track students, instructors, vehicles, and more." : "DriveMaster Academy's comprehensive management system helps you streamline student registrations, instructor assignments, vehicle tracking, payments, and driving tests all in one place.") + "</p>" +
                        "</section>" +
                        "" +
                        "<!-- Stats Section (only for logged in users) -->" +
                        (loggedIn ?
                                "<div class='stats-section'>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-users'></i>" +
                                "<div class='stat-number'>0</div>" +
                                "<div class='stat-label'>Total Students</div>" +
                                "</div>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-chalkboard-teacher'></i>" +
                                "<div class='stat-number'>0</div>" +
                                "<div class='stat-label'>Active Instructors</div>" +
                                "</div>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-car'></i>" +
                                "<div class='stat-number'>0</div>" +
                                "<div class='stat-label'>Active Vehicles</div>" +
                                "</div>" +
                                "<div class='stat-card'>" +
                                "<i class='fas fa-calendar-check'></i>" +
                                "<div class='stat-number'>0</div>" +
                                "<div class='stat-label'>Today's Lessons</div>" +
                                "</div>" +
                                "</div>" : "") +
                        "" +
                        "<!-- Cards Grid -->" +
                        cards +
                        "" +
                        "<!-- Footer -->" +
                        "<footer class='footer'>" +
                        "<p>© 2024 DriveMaster Academy - Driving School Management System | All Rights Reserved</p>" +
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