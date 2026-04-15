<%@ page import="model.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Student> students = (List<Student>) request.getAttribute("students");
    List<Instructor> instructors = (List<Instructor>) request.getAttribute("instructors");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
    List<Lesson> upcomingLessons = (List<Lesson>) request.getAttribute("upcomingLessons");
    String selectedDate = (String) request.getAttribute("selectedDate");
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    if (selectedDate == null) selectedDate = LocalDate.now().toString();
    DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    LocalDate currentDate = LocalDate.parse(selectedDate);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lesson Scheduling - Driving School</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .header {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            padding: 30px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .header h2 {
            font-size: 28px;
            font-weight: 700;
        }

        .add-btn {
            padding: 12px 24px;
            background: white;
            color: #d97706;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .add-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .nav-bar {
            background: #f8f9fa;
            padding: 15px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e9ecef;
        }

        .nav-links {
            display: flex;
            gap: 15px;
        }

        .nav-btn {
            padding: 8px 20px;
            background: white;
            border: 2px solid #f59e0b;
            color: #f59e0b;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .nav-btn:hover {
            background: #f59e0b;
            color: white;
        }

        .alert {
            padding: 15px 40px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
        }

        .alert-error {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Booking Form */
        .booking-form-section {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            padding: 30px 40px;
            border-bottom: 1px solid #e9ecef;
        }

        .booking-form {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .booking-form h3 {
            font-size: 20px;
            margin-bottom: 20px;
            color: #374151;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-weight: 600;
            font-size: 13px;
            color: #374151;
            margin-bottom: 6px;
        }

        .form-group select, .form-group input {
            padding: 10px 14px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .form-group select:focus, .form-group input:focus {
            outline: none;
            border-color: #f59e0b;
        }

        .schedule-btn {
            padding: 12px 30px;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
            font-size: 16px;
        }

        .schedule-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(245, 158, 11, 0.3);
        }

        /* Calendar Navigation */
        .calendar-nav {
            padding: 20px 40px;
            background: #f8f9fa;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e9ecef;
        }

        .calendar-nav h3 {
            font-size: 20px;
            color: #374151;
        }

        .nav-date-buttons {
            display: flex;
            gap: 10px;
        }

        .date-nav-btn {
            padding: 8px 16px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            color: #374151;
            transition: all 0.3s ease;
        }

        .date-nav-btn:hover {
            background: #f59e0b;
            color: white;
            border-color: #f59e0b;
        }

        /* Lesson Table */
        .lesson-table-section {
            padding: 30px 40px;
        }

        .section-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            color: #374151;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .table-container {
            overflow-x: auto;
            border-radius: 16px;
            border: 1px solid #e5e7eb;
            margin-bottom: 30px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
        }

        th, td {
            padding: 12px 15px;
            text-align: left;
        }

        tr {
            border-bottom: 1px solid #e5e7eb;
        }

        tr:hover {
            background: #fef3c7;
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .status-scheduled {
            background: #dbeafe;
            color: #1e40af;
        }

        .status-completed {
            background: #d1fae5;
            color: #065f46;
        }

        .status-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }

        .action-btn {
            padding: 5px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            margin: 0 3px;
            display: inline-block;
        }

        .btn-reschedule {
            background: #dbeafe;
            color: #1e40af;
        }

        .btn-cancel {
            background: #fee2e2;
            color: #991b1b;
        }

        .empty-state {
            text-align: center;
            padding: 40px;
            color: #6b7280;
        }

        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .header, .nav-bar, .booking-form-section, .calendar-nav, .lesson-table-section {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-calendar-alt"></i> Lesson Scheduling</h2>
        <a href="<%= request.getContextPath() %>/lessons?action=add-form" class="add-btn">
            <i class="fas fa-plus-circle"></i> Book New Lesson
        </a>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
        <div>
            <i class="fas fa-calendar-check" style="color: #f59e0b;"></i>
            <span style="font-size: 14px; color: #6b7280;">Schedule Management</span>
        </div>
    </div>

    <% if ("added".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson scheduled successfully!</div>
    <% } else if ("cancelled".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson cancelled successfully!</div>
    <% } else if ("completed".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson marked as completed!</div>
    <% } else if ("rescheduled".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson rescheduled successfully!</div>
    <% } else if ("conflict".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Schedule conflict! The instructor or vehicle is not available at this time.</div>
    <% } %>

    <!-- Quick Booking Form -->
    <div class="booking-form-section">
        <form action="<%= request.getContextPath() %>/lessons" method="post" class="booking-form">
            <input type="hidden" name="action" value="add">
            <h3><i class="fas fa-plus-circle"></i> Quick Book a Lesson</h3>
            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-user-graduate"></i> Student Name *</label>
                    <select name="studentId" required>
                        <option value="">-- Select Student --</option>
                        <% if (students != null) {
                            for (Student student : students) { %>
                        <option value="<%= student.getStudentId() %>"><%= student.getName() %> (<%= student.getStudentId() %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-chalkboard-teacher"></i> Instructor Name *</label>
                    <select name="instructorId" id="instructorSelect" required>
                        <option value="">-- Select Instructor --</option>
                        <% if (instructors != null) {
                            for (Instructor instructor : instructors) { %>
                        <option value="<%= instructor.getInstructorId() %>"><%= instructor.getName() %> (<%= instructor.getSpecialization() %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-car"></i> Vehicle *</label>
                    <select name="vehicleId" id="vehicleSelect" required>
                        <option value="">-- Select Vehicle --</option>
                        <% if (vehicles != null) {
                            for (Vehicle vehicle : vehicles) { %>
                        <option value="<%= vehicle.getVehicleId() %>" data-transmission="<%= vehicle.getTransmissionType() %>">
                            <%= vehicle.getRegistrationNumber() %> - <%= vehicle.getVehicleModel() %> (<%= vehicle.getTransmissionType() %>)
                        </option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-calendar"></i> Lesson Date *</label>
                    <input type="date" name="lessonDate" min="<%= LocalDate.now().toString() %>" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-clock"></i> Lesson Time *</label>
                    <select name="lessonTime" required>
                        <option value="">-- Select Time --</option>
                        <option value="09:00">09:00 AM</option>
                        <option value="10:00">10:00 AM</option>
                        <option value="11:00">11:00 AM</option>
                        <option value="13:00">01:00 PM</option>
                        <option value="14:00">02:00 PM</option>
                        <option value="15:00">03:00 PM</option>
                        <option value="16:00">04:00 PM</option>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-hourglass-half"></i> Duration *</label>
                    <select name="duration" required>
                        <option value="1">1 Hour</option>
                        <option value="2">2 Hours</option>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-chart-line"></i> Lesson Type *</label>
                    <select name="lessonType" required>
                        <option value="Regular">Regular</option>
                        <option value="Intensive">Intensive</option>
                        <option value="Refresher">Refresher</option>
                    </select>
                </div>
            </div>
            <button type="submit" class="schedule-btn">
                <i class="fas fa-calendar-plus"></i> Schedule Lesson
            </button>
        </form>
    </div>

    <!-- Calendar Navigation -->
    <div class="calendar-nav">
        <div class="nav-date-buttons">
            <a href="<%= request.getContextPath() %>/lessons?date=<%= currentDate.minusDays(1).toString() %>" class="date-nav-btn">
                <i class="fas fa-chevron-left"></i> Previous Day
            </a>
            <a href="<%= request.getContextPath() %>/lessons" class="date-nav-btn">
                <i class="fas fa-calendar-day"></i> Today
            </a>
            <a href="<%= request.getContextPath() %>/lessons?date=<%= currentDate.plusDays(1).toString() %>" class="date-nav-btn">
                Next Day <i class="fas fa-chevron-right"></i>
            </a>
        </div>
        <h3><i class="fas fa-calendar-alt"></i> <%= currentDate.format(displayFormatter) %></h3>
    </div>

    <!-- Lessons for Selected Date -->
    <div class="lesson-table-section">
        <div class="section-title">
            <i class="fas fa-clock"></i> Scheduled Lessons for Today
        </div>
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Time</th>
                    <th>Student</th>
                    <th>Instructor</th>
                    <th>Vehicle</th>
                    <th>Duration</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (lessons != null && !lessons.isEmpty()) {
                    for (Lesson lesson : lessons) { %>
                <tr>
                    <td><strong><%= lesson.getLessonTime() %></strong></td>
                    <td><%= lesson.getStudentName() %></td>
                    <td><%= lesson.getInstructorName() %></td>
                    <td><%= lesson.getVehicleDisplay() %></td>
                    <td><%= lesson.getDuration() %> hour(s)</td>
                    <td><%= lesson.getLessonType() %></td>
                    <td>
                                    <span class="status-badge status-<%= lesson.getStatus().toLowerCase() %>">
                                        <%= lesson.getStatus() %>
                                    </span>
                    </td>
                    <td>
                        <% if ("Scheduled".equals(lesson.getStatus())) { %>
                        <a href="<%= request.getContextPath() %>/lessons?action=reschedule&id=<%= lesson.getLessonId() %>"
                           class="action-btn btn-reschedule">
                            <i class="fas fa-calendar-alt"></i> Reschedule
                        </a>
                        <a href="<%= request.getContextPath() %>/lessons?action=cancel&id=<%= lesson.getLessonId() %>"
                           class="action-btn btn-cancel"
                           onclick="return confirm('Are you sure you want to cancel this lesson?')">
                            <i class="fas fa-times-circle"></i> Cancel
                        </a>
                        <% } else if ("Completed".equals(lesson.getStatus())) { %>
                        <span style="color: #10b981;"><i class="fas fa-check-circle"></i> Completed</span>
                        <% } else { %>
                        <span style="color: #ef4444;"><i class="fas fa-ban"></i> Cancelled</span>
                        <% } %>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr>
                    <td colspan="8">
                        <div class="empty-state">
                            <i class="fas fa-calendar-day"></i>
                            <p>No lessons scheduled for this day</p>
                            <p style="font-size: 12px;">Use the form above to book a lesson</p>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- Upcoming Lessons -->
        <div class="section-title" style="margin-top: 30px;">
            <i class="fas fa-calendar-week"></i> Upcoming Lessons
        </div>
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Student</th>
                    <th>Instructor</th>
                    <th>Vehicle</th>
                    <th>Type</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (upcomingLessons != null && !upcomingLessons.isEmpty()) {
                    for (Lesson lesson : upcomingLessons) { %>
                <tr>
                    <td><%= lesson.getLessonDate() %></td>
                    <td><%= lesson.getLessonTime() %></td>
                    <td><%= lesson.getStudentName() %></td>
                    <td><%= lesson.getInstructorName() %></td>
                    <td><%= lesson.getVehicleDisplay() %></td>
                    <td><%= lesson.getLessonType() %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/lessons?action=reschedule&id=<%= lesson.getLessonId() %>"
                           class="action-btn btn-reschedule">
                            <i class="fas fa-calendar-alt"></i> Reschedule
                        </a>
                        <a href="<%= request.getContextPath() %>/lessons?action=cancel&id=<%= lesson.getLessonId() %>"
                           class="action-btn btn-cancel"
                           onclick="return confirm('Are you sure you want to cancel this lesson?')">
                            <i class="fas fa-times-circle"></i> Cancel
                        </a>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr>
                    <td colspan="7">
                        <div class="empty-state">
                            <i class="fas fa-calendar-week"></i>
                            <p>No upcoming lessons scheduled</p>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    // Vehicle filtering based on instructor's specialization
    const instructorSelect = document.getElementById('instructorSelect');
    const vehicleSelect = document.getElementById('vehicleSelect');

    function filterVehicles() {
        const selectedInstructor = instructorSelect.options[instructorSelect.selectedIndex];
        const instructorSpecialization = selectedInstructor.text.includes('Manual') ? 'Manual' :
            selectedInstructor.text.includes('Automatic') ? 'Automatic' : 'Both';

        for (let i = 0; i < vehicleSelect.options.length; i++) {
            const option = vehicleSelect.options[i];
            if (option.value === "") continue;

            const transmission = option.getAttribute('data-transmission');

            if (instructorSpecialization === 'Both') {
                option.style.display = '';
                option.disabled = false;
            } else if (transmission === instructorSpecialization) {
                option.style.display = '';
                option.disabled = false;
            } else {
                option.style.display = 'none';
                option.disabled = true;
            }
        }

        // Reset selection if current selection is hidden
        if (vehicleSelect.options[vehicleSelect.selectedIndex].disabled) {
            vehicleSelect.value = "";
        }
    }

    instructorSelect.addEventListener('change', filterVehicles);

    // Set min date for lesson date picker
    const dateInput = document.querySelector('input[name="lessonDate"]');
    if (dateInput) {
        dateInput.min = new Date().toISOString().split('T')[0];
    }
</script>

</body>
</html>