<%@ page import="model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Lesson lesson = (Lesson) request.getAttribute("lesson");
    List<Student> students = (List<Student>) request.getAttribute("students");
    List<Instructor> instructors = (List<Instructor>) request.getAttribute("instructors");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    String error = request.getParameter("error");
    boolean isAdd = (lesson == null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isAdd ? "Book New Lesson" : "Edit Lesson" %> - Driving School</title>
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
            max-width: 800px;
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
        }

        .header h2 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .nav-bar {
            background: #f8f9fa;
            padding: 15px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e9ecef;
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

        .form-content {
            padding: 40px;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-error {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            color: #991b1b;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            font-weight: 600;
            font-size: 14px;
            color: #374151;
            margin-bottom: 8px;
            display: block;
        }

        select, input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        select:focus, input:focus {
            outline: none;
            border-color: #f59e0b;
            box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .submit-btn {
            margin-top: 20px;
            padding: 14px 30px;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .info-box {
            background: #fef3c7;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            border-left: 4px solid #f59e0b;
        }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            .header, .nav-bar, .form-content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-<%= isAdd ? "calendar-plus" : "calendar-edit" %>"></i> <%= isAdd ? "Book New Lesson" : "Edit Lesson" %></h2>
        <p><%= isAdd ? "Schedule a driving lesson for a student" : "Update lesson details" %></p>
    </div>

    <div class="nav-bar">
        <a href="<%= request.getContextPath() %>/lessons" class="nav-btn">
            <i class="fas fa-arrow-left"></i> Back to Schedule
        </a>
        <a href="<%= request.getContextPath() %>/home" class="nav-btn">
            <i class="fas fa-home"></i> Dashboard
        </a>
    </div>

    <div class="form-content">
        <% if ("empty".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Please fill in all required fields.</div>
        <% } else if ("conflict".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Schedule conflict! The instructor or vehicle is not available at this time.</div>
        <% } %>

        <div class="info-box">
            <i class="fas fa-info-circle"></i> Please ensure the instructor and vehicle are available for the selected date and time.
        </div>

        <form action="<%= request.getContextPath() %>/lessons" method="post">
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %>
            <input type="hidden" name="lessonId" value="<%= lesson.getLessonId() %>">
            <% } %>

            <div class="form-group">
                <label><i class="fas fa-user-graduate"></i> Student Name *</label>
                <select name="studentId" required>
                    <option value="">-- Select Student --</option>
                    <% if (students != null) {
                        for (Student student : students) { %>
                    <option value="<%= student.getStudentId() %>"
                            <%= !isAdd && student.getStudentId().equals(lesson.getStudentId()) ? "selected" : "" %>>
                        <%= student.getName() %> (<%= student.getStudentId() %>)
                    </option>
                    <% }} %>
                </select>
            </div>

            <div class="form-group">
                <label><i class="fas fa-chalkboard-teacher"></i> Instructor Name *</label>
                <select name="instructorId" id="instructorSelect" required>
                    <option value="">-- Select Instructor --</option>
                    <% if (instructors != null) {
                        for (Instructor instructor : instructors) { %>
                    <option value="<%= instructor.getInstructorId() %>"
                            data-specialization="<%= instructor.getSpecialization() %>"
                            <%= !isAdd && instructor.getInstructorId().equals(lesson.getInstructorId()) ? "selected" : "" %>>
                        <%= instructor.getName() %> - <%= instructor.getSpecialization() %> (<%= instructor.getAvailability() %>)
                    </option>
                    <% }} %>
                </select>
            </div>

            <div class="form-group">
                <label><i class="fas fa-car"></i> Vehicle *</label>
                <select name="vehicleId" id="vehicleSelect" required>
                    <option value="">-- Select Vehicle --</option>
                    <% if (vehicles != null) {
                        for (Vehicle vehicle : vehicles) { %>
                    <option value="<%= vehicle.getVehicleId() %>"
                            data-transmission="<%= vehicle.getTransmissionType() %>"
                            data-status="<%= vehicle.getStatus() %>"
                            <%= !isAdd && vehicle.getVehicleId().equals(lesson.getVehicleId()) ? "selected" : "" %>>
                        <%= vehicle.getRegistrationNumber() %> - <%= vehicle.getVehicleModel() %>
                        (<%= vehicle.getTransmissionType() %>) - <%= vehicle.getStatus() %>
                    </option>
                    <% }} %>
                </select>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label><i class="fas fa-calendar"></i> Lesson Date *</label>
                    <input type="date" name="lessonDate"
                           value="<%= isAdd ? "" : lesson.getLessonDate() %>"
                           min="<%= LocalDate.now().toString() %>" required>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-clock"></i> Lesson Time *</label>
                    <select name="lessonTime" required>
                        <option value="">-- Select Time --</option>
                        <option value="09:00" <%= !isAdd && "09:00".equals(lesson.getLessonTime()) ? "selected" : "" %>>09:00 AM</option>
                        <option value="10:00" <%= !isAdd && "10:00".equals(lesson.getLessonTime()) ? "selected" : "" %>>10:00 AM</option>
                        <option value="11:00" <%= !isAdd && "11:00".equals(lesson.getLessonTime()) ? "selected" : "" %>>11:00 AM</option>
                        <option value="13:00" <%= !isAdd && "13:00".equals(lesson.getLessonTime()) ? "selected" : "" %>>01:00 PM</option>
                        <option value="14:00" <%= !isAdd && "14:00".equals(lesson.getLessonTime()) ? "selected" : "" %>>02:00 PM</option>
                        <option value="15:00" <%= !isAdd && "15:00".equals(lesson.getLessonTime()) ? "selected" : "" %>>03:00 PM</option>
                        <option value="16:00" <%= !isAdd && "16:00".equals(lesson.getLessonTime()) ? "selected" : "" %>>04:00 PM</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label><i class="fas fa-hourglass-half"></i> Duration *</label>
                    <select name="duration" required>
                        <option value="1" <%= !isAdd && lesson.getDuration() == 1 ? "selected" : "" %>>1 Hour</option>
                        <option value="2" <%= !isAdd && lesson.getDuration() == 2 ? "selected" : "" %>>2 Hours</option>
                    </select>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-chart-line"></i> Lesson Type *</label>
                    <select name="lessonType" required>
                        <option value="Regular" <%= !isAdd && "Regular".equals(lesson.getLessonType()) ? "selected" : "" %>>Regular</option>
                        <option value="Intensive" <%= !isAdd && "Intensive".equals(lesson.getLessonType()) ? "selected" : "" %>>Intensive</option>
                        <option value="Refresher" <%= !isAdd && "Refresher".equals(lesson.getLessonType()) ? "selected" : "" %>>Refresher</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-<%= isAdd ? "calendar-plus" : "save" %>"></i>
                <%= isAdd ? "Schedule Lesson" : "Update Lesson" %>
            </button>
        </form>
    </div>
</div>

<script>
    const instructorSelect = document.getElementById('instructorSelect');
    const vehicleSelect = document.getElementById('vehicleSelect');

    function filterVehicles() {
        const selectedOption = instructorSelect.options[instructorSelect.selectedIndex];
        const specialization = selectedOption.getAttribute('data-specialization');

        for (let i = 0; i < vehicleSelect.options.length; i++) {
            const option = vehicleSelect.options[i];
            if (option.value === "") continue;

            const transmission = option.getAttribute('data-transmission');
            const status = option.getAttribute('data-status');

            // Only show available vehicles and match transmission type
            if (status === 'Available' && (specialization === 'Both' || transmission === specialization)) {
                option.style.display = '';
                option.disabled = false;
            } else {
                option.style.display = 'none';
                option.disabled = true;
            }
        }

        if (vehicleSelect.options[vehicleSelect.selectedIndex] &&
            vehicleSelect.options[vehicleSelect.selectedIndex].disabled) {
            vehicleSelect.value = "";
        }
    }

    instructorSelect.addEventListener('change', filterVehicles);

    // Initial filter
    filterVehicles();
</script>

</body>
</html>