<%@ page import="model.Test" %>
<%@ page import="model.Student" %>
<%@ page import="model.Instructor" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Test test = (Test) request.getAttribute("test");
    List<Student> students = (List<Student>) request.getAttribute("students");
    List<Instructor> examiners = (List<Instructor>) request.getAttribute("examiners");
    String error = request.getParameter("error");
    boolean isAdd = (test == null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isAdd ? "Schedule New Test" : "Edit Test" %> - Driving School</title>
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
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
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
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: white;
            padding: 30px 40px;
        }

        .header h2 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .header p {
            font-size: 14px;
            opacity: 0.9;
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
            border: 2px solid #8b5cf6;
            color: #8b5cf6;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .nav-btn:hover {
            background: #8b5cf6;
            color: white;
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
            animation: slideIn 0.3s ease;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .alert-error {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            color: #991b1b;
        }

        .alert-info {
            background: #dbeafe;
            border-left: 4px solid #3b82f6;
            color: #1e40af;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group-full {
            grid-column: span 2;
        }

        label {
            font-weight: 600;
            font-size: 14px;
            color: #374151;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .required {
            color: #ef4444;
            font-size: 12px;
        }

        input, select, textarea {
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 14px;
            font-family: 'Inter', sans-serif;
            transition: all 0.3s ease;
        }

        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #8b5cf6;
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
        }

        input.error, select.error, textarea.error {
            border-color: #ef4444;
            background: #fef2f2;
        }

        .error-message {
            font-size: 12px;
            color: #ef4444;
            margin-top: 6px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .hint {
            font-size: 11px;
            color: #6b7280;
            margin-top: 6px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        input[readonly] {
            background: #f3f4f6;
            cursor: not-allowed;
        }

        .submit-btn {
            margin-top: 30px;
            padding: 14px 30px;
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(139, 92, 246, 0.3);
        }

        .info-box {
            background: #f5f3ff;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            border-left: 4px solid #8b5cf6;
        }

        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .form-group-full {
                grid-column: span 1;
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
        <h2><i class="fas fa-<%= isAdd ? "calendar-plus" : "calendar-edit" %>"></i> <%= isAdd ? "Schedule New Test" : "Edit Test" %></h2>
        <p><%= isAdd ? "Schedule a driving test for a student" : "Update test details" %></p>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/tests" class="nav-btn">
                <i class="fas fa-arrow-left"></i> Back to Tests
            </a>
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
    </div>

    <div class="form-content">
        <% if ("empty".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Please fill in all required fields.</span>
        </div>
        <% } else if ("conflict".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Schedule conflict! The examiner or student is not available at this time.</span>
        </div>
        <% } else if ("invalidTime".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Test time must be between 8:00 AM and 5:00 PM.</span>
        </div>
        <% } else if ("pastDate".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Test date cannot be in the past.</span>
        </div>
        <% } %>

        <div class="info-box">
            <i class="fas fa-info-circle"></i>
            <strong>Test Guidelines:</strong>
            <ul style="margin-top: 8px; margin-left: 20px; font-size: 13px;">
                <li>Tests are available Monday to Friday, 8:00 AM - 5:00 PM</li>
                <li>Each test takes approximately 1 hour</li>
                <li>Examiner must be available during the selected time</li>
                <li>Students can only take one test per day</li>
            </ul>
        </div>

        <form id="testForm" action="<%= request.getContextPath() %>/tests" method="post" novalidate>
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %>
            <input type="hidden" name="testId" value="<%= test.getTestId() %>">
            <% } %>

            <div class="form-grid">
                <!-- Test ID (Auto-generated) -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-id-card"></i> Test ID
                        <span class="required">*</span>
                    </label>
                    <input type="text" value="<%= isAdd ? "Auto-generated" : test.getTestId() %>" readonly>
                </div>

                <!-- Student Name -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-user-graduate"></i> Student Name
                        <span class="required">*</span>
                    </label>
                    <select id="studentSelect" name="studentId" required>
                        <option value="">-- Select Student --</option>
                        <% if (students != null) {
                            for (Student student : students) { %>
                        <option value="<%= student.getStudentId() %>"
                                <%= !isAdd && student.getStudentId().equals(test.getStudentId()) ? "selected" : "" %>>
                            <%= student.getName() %> - <%= student.getCoursePackage() %> Package
                        </option>
                        <% }} %>
                    </select>
                </div>

                <!-- Test Type -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-clipboard-list"></i> Test Type
                        <span class="required">*</span>
                    </label>
                    <select id="testType" name="testType" required>
                        <option value="">-- Select Test Type --</option>
                        <option value="Theory Test" <%= !isAdd && "Theory Test".equals(test.getTestType()) ? "selected" : "" %>>Theory Test</option>
                        <option value="Practical Test" <%= !isAdd && "Practical Test".equals(test.getTestType()) ? "selected" : "" %>>Practical Test</option>
                    </select>
                </div>

                <!-- Examiner -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-chalkboard-teacher"></i> Examiner
                        <span class="required">*</span>
                    </label>
                    <select id="examinerSelect" name="examinerId" required>
                        <option value="">-- Select Examiner --</option>
                        <% if (examiners != null) {
                            for (Instructor examiner : examiners) { %>
                        <option value="<%= examiner.getInstructorId() %>"
                                <%= !isAdd && examiner.getInstructorId().equals(test.getExaminerId()) ? "selected" : "" %>
                                data-specialization="<%= examiner.getSpecialization() %>">
                            <%= examiner.getName() %> - <%= examiner.getSpecialization() %> (<%= examiner.getAvailability() %>)
                        </option>
                        <% }} %>
                    </select>
                </div>

                <!-- Test Date -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-calendar"></i> Test Date
                        <span class="required">*</span>
                    </label>
                    <input type="date" id="testDate" name="testDate"
                           value="<%= isAdd ? "" : test.getTestDate() %>"
                           min="<%= LocalDate.now().toString() %>"
                           required>
                    <div class="error-message" id="dateError"></div>
                </div>

                <!-- Test Time -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-clock"></i> Test Time
                        <span class="required">*</span>
                    </label>
                    <select id="testTime" name="testTime" required>
                        <option value="">-- Select Time --</option>
                        <option value="09:00" <%= !isAdd && "09:00".equals(test.getTestTime()) ? "selected" : "" %>>09:00 AM</option>
                        <option value="10:00" <%= !isAdd && "10:00".equals(test.getTestTime()) ? "selected" : "" %>>10:00 AM</option>
                        <option value="11:00" <%= !isAdd && "11:00".equals(test.getTestTime()) ? "selected" : "" %>>11:00 AM</option>
                        <option value="13:00" <%= !isAdd && "13:00".equals(test.getTestTime()) ? "selected" : "" %>>01:00 PM</option>
                        <option value="14:00" <%= !isAdd && "14:00".equals(test.getTestTime()) ? "selected" : "" %>>02:00 PM</option>
                        <option value="15:00" <%= !isAdd && "15:00".equals(test.getTestTime()) ? "selected" : "" %>>03:00 PM</option>
                        <option value="16:00" <%= !isAdd && "16:00".equals(test.getTestTime()) ? "selected" : "" %>>04:00 PM</option>
                    </select>
                    <div class="hint">
                        <i class="fas fa-info-circle"></i> Available slots: 9:00 AM - 4:00 PM
                    </div>
                </div>

                <!-- Notes -->
                <div class="form-group-full">
                    <label>
                        <i class="fas fa-pen"></i> Notes (Optional)
                    </label>
                    <textarea name="notes" rows="3" placeholder="Any special instructions or notes..."><%= !isAdd && test.getNotes() != null ? test.getNotes() : "" %></textarea>
                </div>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-<%= isAdd ? "calendar-plus" : "save" %>"></i>
                <%= isAdd ? "Schedule Test" : "Update Test" %>
            </button>
        </form>
    </div>
</div>

<script>
    // Get form elements
    const form = document.getElementById('testForm');
    const testDate = document.getElementById('testDate');
    const testTime = document.getElementById('testTime');
    const examinerSelect = document.getElementById('examinerSelect');
    const testType = document.getElementById('testType');
    const studentSelect = document.getElementById('studentSelect');

    // Set min date for test date
    if (testDate) {
        testDate.min = new Date().toISOString().split('T')[0];

        // Validate date
        testDate.addEventListener('change', function() {
            const selectedDate = this.value;
            const today = new Date().toISOString().split('T')[0];
            const errorDiv = document.getElementById('dateError');

            if (selectedDate < today) {
                errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Test date cannot be in the past';
                testDate.classList.add('error');
            } else {
                errorDiv.innerHTML = '';
                testDate.classList.remove('error');
            }
        });
    }

    // Filter examiners based on test type (for practical tests, only examiners who can teach that type)
    function filterExaminers() {
        const selectedTestType = testType.value;
        const options = examinerSelect.options;

        for (let i = 0; i < options.length; i++) {
            const option = options[i];
            if (option.value === "") continue;

            if (selectedTestType === "Practical Test") {
                // For practical tests, all examiners are eligible
                option.style.display = '';
                option.disabled = false;
            } else {
                // For theory tests, all examiners can conduct
                option.style.display = '';
                option.disabled = false;
            }
        }

        // Reset selection if current is hidden
        if (examinerSelect.options[examinerSelect.selectedIndex] &&
            examinerSelect.options[examinerSelect.selectedIndex].disabled) {
            examinerSelect.value = "";
        }
    }

    testType.addEventListener('change', filterExaminers);

    // Form validation
    form.addEventListener('submit', function(e) {
        // Validate date
        const selectedDate = testDate.value;
        const today = new Date().toISOString().split('T')[0];

        if (selectedDate < today) {
            e.preventDefault();
            alert('Test date cannot be in the past!');
            return false;
        }

        // Validate time is selected
        if (!testTime.value) {
            e.preventDefault();
            alert('Please select a test time!');
            return false;
        }

        // Validate student is selected
        if (!studentSelect.value) {
            e.preventDefault();
            alert('Please select a student!');
            return false;
        }

        // Validate examiner is selected
        if (!examinerSelect.value) {
            e.preventDefault();
            alert('Please select an examiner!');
            return false;
        }

        // Validate test type is selected
        if (!testType.value) {
            e.preventDefault();
            alert('Please select a test type!');
            return false;
        }

        return true;
    });

    // Initial filter
    filterExaminers();
</script>

</body>
</html>