<%@ page import="model.Instructor" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Instructor instructor = (Instructor) request.getAttribute("instructor");
    String error = request.getParameter("error");
    boolean isAdd = (instructor == null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isAdd ? "Add New Instructor" : "Edit Instructor" %> - Driving School</title>
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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            max-width: 1000px;
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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 30px 40px;
            text-align: center;
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

        .nav-links {
            display: flex;
            gap: 15px;
        }

        .nav-btn {
            padding: 8px 20px;
            background: white;
            border: 2px solid #f5576c;
            color: #f5576c;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .nav-btn:hover {
            background: #f5576c;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(245, 87, 108, 0.3);
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

        .alert i {
            font-size: 20px;
        }

        .alert-error {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            color: #991b1b;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 24px;
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
            border-color: #f5576c;
            box-shadow: 0 0 0 3px rgba(245, 87, 108, 0.1);
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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
            box-shadow: 0 10px 25px rgba(245, 87, 108, 0.3);
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
        <h2><i class="fas fa-<%= isAdd ? "user-plus" : "user-edit" %>"></i> <%= isAdd ? "Add New Instructor" : "Edit Instructor" %></h2>
        <p><%= isAdd ? "Register a new driving instructor" : "Update instructor information" %></p>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/instructors" class="nav-btn">
                <i class="fas fa-list"></i> Instructor List
            </a>
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
        <div>
            <i class="fas fa-chalkboard-teacher" style="color: #f5576c;"></i>
            <span style="font-size: 14px; color: #6b7280;">Instructor Management</span>
        </div>
    </div>

    <div class="form-content">
        <% if ("empty".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i><span>Please fill in all required fields.</span></div>
        <% } else if ("experience".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i><span>Experience must be between 0 and 50 years.</span></div>
        <% } else if ("nicExists".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i><span>NIC number already exists in the system.</span></div>
        <% } else if ("licenseExists".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i><span>License number already exists in the system.</span></div>
        <% } %>

        <form id="instructorForm" action="<%= request.getContextPath() %>/instructors" method="post" novalidate>
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %>
            <input type="hidden" name="instructorId" value="<%= instructor.getInstructorId() %>">
            <% } %>

            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> Instructor ID <span class="required">*</span></label>
                    <input type="text" value="<%= isAdd ? "Auto-generated" : instructor.getInstructorId() %>" readonly>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-user"></i> Full Name <span class="required">*</span></label>
                    <input type="text" id="name" name="name" value="<%= isAdd ? "" : instructor.getName() %>"
                           placeholder="Enter full name" required pattern="[A-Za-z ]{3,}">
                    <div class="error-message" id="nameError"></div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> NIC Number <span class="required">*</span></label>
                    <input type="text" id="nic" name="nic" value="<%= isAdd ? "" : instructor.getNic() %>"
                           placeholder="123456789V or 200012345678" maxlength="12" required>
                    <div class="error-message" id="nicError"></div>
                    <div class="hint"><i class="fas fa-info-circle"></i> Format: 9 digits + V OR 12 digits</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-phone"></i> Contact Number <span class="required">*</span></label>
                    <input type="tel" id="phone" name="phone" value="<%= isAdd ? "" : instructor.getPhone() %>"
                           placeholder="0712345678" maxlength="10" required>
                    <div class="error-message" id="phoneError"></div>
                    <div class="hint"><i class="fas fa-info-circle"></i> 10 digits starting with 07</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-envelope"></i> Email Address <span class="required">*</span></label>
                    <input type="email" id="email" name="email" value="<%= isAdd ? "" : instructor.getEmail() %>"
                           placeholder="instructor@example.com" required>
                    <div class="error-message" id="emailError"></div>
                </div>

                <div class="form-group-full">
                    <label><i class="fas fa-map-marker-alt"></i> Address <span class="required">*</span></label>
                    <textarea id="address" name="address" rows="2" required><%= isAdd ? "" : instructor.getAddress() %></textarea>
                </div>

                <div class="form-group-full">
                    <label><i class="fas fa-lock"></i> Password <span class="required">*</span></label>
                    <% if (isAdd) { %>
                    <input type="text" id="username" name="username"
                           placeholder="Username for login" required
                           style="margin-bottom:8px;">
                    <div style="font-size:11px;color:#6b7280;margin-bottom:12px;">
                        <i class="fas fa-info-circle"></i> Instructor uses this to login
                    </div>
                    <% } %>
                    <input type="password" id="password" name="password"
                           placeholder="<%= isAdd ? "Create password (min 6 chars)" : "Leave blank to keep current" %>"
                        <%= isAdd ? "required" : "" %>>
                    <div class="error-message" id="passwordError"></div>
                    <div class="hint"><i class="fas fa-info-circle"></i> Minimum 6 characters with letters and numbers</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> License Number <span class="required">*</span></label>
                    <input type="text" id="licenseNumber" name="licenseNumber"
                           value="<%= isAdd ? "" : instructor.getLicenseNumber() %>"
                           placeholder="INS/DL/12345" pattern="INS/DL/[0-9]{5}" required>
                    <div class="error-message" id="licenseError"></div>
                    <div class="hint"><i class="fas fa-info-circle"></i> Format: INS/DL/xxxxx (5 digits)</div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-cogs"></i> Specialization <span class="required">*</span></label>
                    <select id="specialization" name="specialization" required>
                        <option value="">-- Select Specialization --</option>
                        <option value="Manual" <%= !isAdd && "Manual".equals(instructor.getSpecialization()) ? "selected" : "" %>>Manual</option>
                        <option value="Automatic" <%= !isAdd && "Automatic".equals(instructor.getSpecialization()) ? "selected" : "" %>>Automatic</option>
                        <option value="Both" <%= !isAdd && "Both".equals(instructor.getSpecialization()) ? "selected" : "" %>>Both (Manual & Automatic)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-chart-line"></i> Experience (Years) <span class="required">*</span></label>
                    <input type="number" id="experience" name="experience"
                           value="<%= isAdd ? "" : instructor.getExperience() %>"
                           placeholder="0-50" min="0" max="50" required>
                    <div class="error-message" id="experienceError"></div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-clock"></i> Availability <span class="required">*</span></label>
                    <select id="availability" name="availability" required>
                        <option value="">-- Select Availability --</option>
                        <option value="Available" <%= !isAdd && "Available".equals(instructor.getAvailability()) ? "selected" : "" %>>Available</option>
                        <option value="Busy" <%= !isAdd && "Busy".equals(instructor.getAvailability()) ? "selected" : "" %>>Busy</option>
                        <option value="On Leave" <%= !isAdd && "On Leave".equals(instructor.getAvailability()) ? "selected" : "" %>>On Leave</option>
                    </select>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-venus-mars"></i> Gender <span class="required">*</span></label>
                    <select id="gender" name="gender" required>
                        <option value="">-- Select Gender --</option>
                        <option value="Male" <%= !isAdd && "Male".equals(instructor.getGender()) ? "selected" : "" %>>Male</option>
                        <option value="Female" <%= !isAdd && "Female".equals(instructor.getGender()) ? "selected" : "" %>>Female</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-<%= isAdd ? "save" : "sync-alt" %>"></i>
                <%= isAdd ? "Register Instructor" : "Update Information" %>
            </button>
        </form>
    </div>
</div>

<script>
    // Real-time validation functions
    const form = document.getElementById('instructorForm');

    // Name validation
    const nameInput = document.getElementById('name');
    nameInput.addEventListener('input', () => {
        const name = nameInput.value;
        const errorDiv = document.getElementById('nameError');
        if (name.trim().length < 3) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Name must be at least 3 characters';
            nameInput.classList.add('error');
        } else if (!/^[A-Za-z\s]+$/.test(name)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Name can only contain letters and spaces';
            nameInput.classList.add('error');
        } else {
            errorDiv.innerHTML = '';
            nameInput.classList.remove('error');
        }
    });

    // NIC validation
    const nicInput = document.getElementById('nic');
    nicInput.addEventListener('input', (e) => {
        nicInput.value = nicInput.value.replace(/[^0-9Vv]/g, '');
        if (nicInput.value.length > 12) nicInput.value = nicInput.value.slice(0, 12);
        validateNIC();
    });

    function validateNIC() {
        const nic = nicInput.value;
        const errorDiv = document.getElementById('nicError');
        const patternOld = /^[0-9]{9}[Vv]$/;
        const patternNew = /^[0-9]{12}$/;
        if (nic && !patternOld.test(nic) && !patternNew.test(nic)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Invalid NIC format';
            nicInput.classList.add('error');
            return false;
        }