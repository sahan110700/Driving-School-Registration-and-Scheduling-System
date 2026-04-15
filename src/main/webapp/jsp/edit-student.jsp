<%@ page import="model.Student" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Student student = (Student) request.getAttribute("student");
    String error = request.getParameter("error");
    boolean isAdd = (student == null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isAdd ? "Add New Student" : "Edit Student" %> - Driving School Management</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            max-width: 900px;
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

        /* Header */
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

        /* Navigation Bar */
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
            border: 2px solid #667eea;
            color: #667eea;
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
            background: #667eea;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        /* Form Content */
        .form-content {
            padding: 40px;
        }

        /* Alert Messages */
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

        .alert-success {
            background: #d1fae5;
            border-left: 4px solid #10b981;
            color: #065f46;
        }

        /* Form Grid */
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
            background: white;
        }

        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
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

        .success-message {
            font-size: 12px;
            color: #10b981;
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

        .hint i {
            font-size: 10px;
        }

        input[readonly] {
            background: #f3f4f6;
            cursor: not-allowed;
            font-weight: 500;
            color: #374151;
        }

        /* Submit Button */
        .submit-btn {
            margin-top: 30px;
            padding: 14px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }

        .submit-btn:active {
            transform: translateY(0);
        }

        /* Character Counter */
        .char-counter {
            font-size: 11px;
            color: #6b7280;
            margin-top: 6px;
            text-align: right;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-group-full {
                grid-column: span 1;
            }

            .container {
                margin: 0 15px;
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
        <h2><i class="fas fa-<%= isAdd ? "user-plus" : "user-edit" %>"></i> <%= isAdd ? "Register New Student" : "Edit Student Information" %></h2>
        <p><%= isAdd ? "Please fill in all required details to register a new student" : "Update the student's information as needed" %></p>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/students" class="nav-btn">
                <i class="fas fa-list"></i> Student List
            </a>
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
        <div>
            <i class="fas fa-graduation-cap" style="color: #667eea;"></i>
            <span style="font-size: 14px; color: #6b7280;">Driving School Management</span>
        </div>
    </div>

    <div class="form-content">
        <% if ("empty".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Please fill in all required fields before submitting.</span>
        </div>
        <% } else if ("age".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Age must be a valid number between 16 and 100.</span>
        </div>
        <% } else if ("password".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Password is required and must be at least 6 characters long.</span>
        </div>
        <% } %>

        <form id="studentForm" action="<%= request.getContextPath() %>/students" method="post" novalidate>
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %>
            <input type="hidden" name="studentId" value="<%= student.getStudentId() %>">
            <% } %>

            <div class="form-grid">
                <!-- Student ID (Auto-generated) -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-id-card"></i> Student ID
                        <span class="required">*</span>
                    </label>
                    <input type="text" value="<%= isAdd ? "Will be auto-generated" : student.getStudentId() %>" readonly>
                </div>

                <!-- Full Name -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-user"></i> Full Name
                        <span class="required">*</span>
                    </label>
                    <input type="text" id="name" name="name"
                           value="<%= isAdd ? "" : student.getName() %>"
                           placeholder="Enter full name"
                           required>
                    <div class="error-message" id="nameError"></div>
                </div>

                <!-- NIC -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-id-card"></i> NIC Number
                        <span class="required">*</span>
                    </label>
                    <input type="text" id="nic" name="nic"
                           value="<%= isAdd ? "" : student.getNic() %>"
                           placeholder="123456789V or 200012345678"
                           maxlength="12" required>
                    <div class="error-message" id="nicError"></div>
                    <div class="hint">
                        <i class="fas fa-info-circle"></i> Format: 9 digits + V (old) OR 12 digits (new)
                    </div>
                </div>

                <!-- Phone -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-phone"></i> Contact Number
                        <span class="required">*</span>
                    </label>
                    <input type="tel" id="phone" name="phone"
                           value="<%= isAdd ? "" : student.getPhone() %>"
                           placeholder="0712345678"
                           maxlength="10" required>
                    <div class="error-message" id="phoneError"></div>
                    <div class="hint">
                        <i class="fas fa-info-circle"></i> 10 digits starting with 07
                    </div>
                </div>

                <!-- Email -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-envelope"></i> Email Address
                        <span class="required">*</span>
                    </label>
                    <input type="email" id="email" name="email"
                           value="<%= isAdd ? "" : student.getEmail() %>"
                           placeholder="student@example.com"
                           required>
                    <div class="error-message" id="emailError"></div>
                </div>

                <!-- Address (Full Width) -->
                <div class="form-group-full">
                    <label>
                        <i class="fas fa-map-marker-alt"></i> Residential Address
                        <span class="required">*</span>
                    </label>
                    <textarea id="address" name="address" rows="3"
                              placeholder="Enter full address" required><%= isAdd ? "" : student.getAddress() %></textarea>
                    <div class="char-counter">
                        <span id="charCount">0</span> characters
                    </div>
                </div>

                <!-- Password -->
                <div class="form-group-full">
                    <label>
                        <i class="fas fa-lock"></i> Password
                        <span class="required">*</span>
                    </label>
                    <input type="password" id="password" name="password"
                           placeholder="<%= isAdd ? "Create a password (min 6 characters)" : "Leave blank to keep current password" %>"
                        <%= isAdd ? "required" : "" %>>
                    <div class="error-message" id="passwordError"></div>
                    <div class="hint">
                        <i class="fas fa-info-circle"></i> Minimum 6 characters, at least one number and one letter
                    </div>
                </div>

                <!-- Gender -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-venus-mars"></i> Gender
                        <span class="required">*</span>
                    </label>
                    <select id="gender" name="gender" required>
                        <option value="">-- Select Gender --</option>
                        <option value="Male" <%= !isAdd && "Male".equals(student.getGender()) ? "selected" : "" %>>Male</option>
                        <option value="Female" <%= !isAdd && "Female".equals(student.getGender()) ? "selected" : "" %>>Female</option>
                    </select>
                </div>

                <!-- Age -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-calendar-alt"></i> Age
                        <span class="required">*</span>
                    </label>
                    <input type="number" id="age" name="age"
                           value="<%= isAdd ? "" : student.getAge() %>"
                           placeholder="Age"
                           min="16" max="100" required>
                    <div class="error-message" id="ageError"></div>
                    <div class="hint">
                        <i class="fas fa-info-circle"></i> Minimum 16 years for license eligibility
                    </div>
                </div>

                <!-- License Type -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-id-card"></i> License Type
                        <span class="required">*</span>
                    </label>
                    <select id="licenseType" name="licenseType" required>
                        <option value="">-- Select License Type --</option>
                        <option value="Heavy Vehicle" <%= !isAdd && "Heavy Vehicle".equals(student.getLicenseType()) ? "selected" : "" %>>Heavy Vehicle</option>
                        <option value="Light Vehicle" <%= !isAdd && "Light Vehicle".equals(student.getLicenseType()) ? "selected" : "" %>>Light Vehicle</option>
                    </select>
                </div>

                <!-- Course Package -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-graduation-cap"></i> Course Package
                        <span class="required">*</span>
                    </label>
                    <select id="coursePackage" name="coursePackage" required>
                        <option value="">-- Select Course Package --</option>
                        <option value="Basic" <%= !isAdd && "Basic".equals(student.getCoursePackage()) ? "selected" : "" %>>Basic - $299</option>
                        <option value="Standard" <%= !isAdd && "Standard".equals(student.getCoursePackage()) ? "selected" : "" %>>Standard - $499</option>
                        <option value="Premium" <%= !isAdd && "Premium".equals(student.getCoursePackage()) ? "selected" : "" %>>Premium - $799</option>
                    </select>
                </div>

                <!-- Registration Date -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-calendar-plus"></i> Registration Date
                        <span class="required">*</span>
                    </label>
                    <input type="date" id="regDate" name="registrationDate"
                           value="<%= isAdd ? "" : student.getRegistrationDate() %>" required>
                    <div class="error-message" id="dateError"></div>
                </div>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-<%= isAdd ? "save" : "sync-alt" %>"></i>
                <%= isAdd ? "Register Student" : "Update Information" %>
            </button>
        </form>
    </div>
</div>

<script>
    // Get DOM elements
    const form = document.getElementById('studentForm');
    const nameInput = document.getElementById('name');
    const nicInput = document.getElementById('nic');
    const phoneInput = document.getElementById('phone');
    const emailInput = document.getElementById('email');
    const addressInput = document.getElementById('address');
    const passwordInput = document.getElementById('password');
    const ageInput = document.getElementById('age');
    const regDateInput = document.getElementById('regDate');

    // Set max date for registration (no future dates)
    const today = new Date().toISOString().split('T')[0];
    regDateInput.max = today;

    // Set default registration date to today for new students
    <% if (isAdd && student == null) { %>
    regDateInput.value = today;
    <% } %>

    // Character counter for address
    if (addressInput) {
        addressInput.addEventListener('input', function() {
            const count = this.value.length;
            document.getElementById('charCount').textContent = count;
        });
        // Trigger initial count
        addressInput.dispatchEvent(new Event('input'));
    }

    // NIC validation - restrict to 12 characters
    nicInput.addEventListener('input', function(e) {
        // Allow only digits and V/v
        this.value = this.value.replace(/[^0-9Vv]/g, '');

        // Limit to 12 characters
        if (this.value.length > 12) {
            this.value = this.value.slice(0, 12);
        }

        // Validate format
        validateNIC();
    });

    nicInput.addEventListener('blur', validateNIC);

    function validateNIC() {
        const nic = nicInput.value;
        const errorDiv = document.getElementById('nicError');
        const nicPatternOld = /^[0-9]{9}[Vv]$/;
        const nicPatternNew = /^[0-9]{12}$/;

        if (nic && !nicPatternOld.test(nic) && !nicPatternNew.test(nic)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Invalid NIC format. Use 9 digits + V or 12 digits';
            nicInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            nicInput.classList.remove('error');
            return true;
        }
    }

    // Phone validation - restrict to 10 digits, starts with 07
    phoneInput.addEventListener('input', function(e) {
        // Allow only digits
        this.value = this.value.replace(/[^0-9]/g, '');

        // Limit to 10 digits
        if (this.value.length > 10) {
            this.value = this.value.slice(0, 10);
        }

        validatePhone();
    });

    phoneInput.addEventListener('blur', validatePhone);

    function validatePhone() {
        const phone = phoneInput.value;
        const errorDiv = document.getElementById('phoneError');
        const phonePattern = /^07[0-9]{8}$/;

        if (phone && !phonePattern.test(phone)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Phone must be 10 digits starting with 07';
            phoneInput.classList.add('error');
            return false;
        } else if (phone && phone.length !== 10) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Phone must be exactly 10 digits';
            phoneInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            phoneInput.classList.remove('error');
            return true;
        }
    }

    // Email validation
    emailInput.addEventListener('input', validateEmail);
    emailInput.addEventListener('blur', validateEmail);

    function validateEmail() {
        const email = emailInput.value;
        const errorDiv = document.getElementById('emailError');
        const emailPattern = /^[^\s@]+@([^\s@]+\.)+[^\s@]+$/;

        if (email && !emailPattern.test(email)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Enter a valid email address (e.g., name@domain.com)';
            emailInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            emailInput.classList.remove('error');
            return true;
        }
    }

    // Age validation
    ageInput.addEventListener('input', validateAge);
    ageInput.addEventListener('blur', validateAge);

    function validateAge() {
        const age = parseInt(ageInput.value);
        const errorDiv = document.getElementById('ageError');

        if (ageInput.value && (isNaN(age) || age < 16 || age > 100)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Age must be between 16 and 100';
            ageInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            ageInput.classList.remove('error');
            return true;
        }
    }

    // Password validation
    if (passwordInput) {
        passwordInput.addEventListener('input', validatePassword);
        passwordInput.addEventListener('blur', validatePassword);
    }

    function validatePassword() {
        const password = passwordInput.value;
        const errorDiv = document.getElementById('passwordError');

        <% if (isAdd) { %>
        if (password && password.length < 6) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Password must be at least 6 characters';
            passwordInput.classList.add('error');
            return false;
        } else if (password && !/(?=.*[A-Za-z])(?=.*\d)/.test(password)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Password must contain at least one letter and one number';
            passwordInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            passwordInput.classList.remove('error');
            return true;
        }
        <% } else { %>
        // For edit, password is optional
        if (password && password.length > 0 && password.length < 6) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Password must be at least 6 characters';
            passwordInput.classList.add('error');
            return false;
        } else if (password && password.length > 0 && !/(?=.*[A-Za-z])(?=.*\d)/.test(password)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Password must contain at least one letter and one number';
            passwordInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            passwordInput.classList.remove('error');
            return true;
        }
        <% } %>
    }

    // Name validation
    nameInput.addEventListener('input', validateName);
    nameInput.addEventListener('blur', validateName);

    function validateName() {
        const name = nameInput.value;
        const errorDiv = document.getElementById('nameError');

        if (name && name.trim().length < 3) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Name must be at least 3 characters';
            nameInput.classList.add('error');
            return false;
        } else if (name && !/^[A-Za-z\s]+$/.test(name)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Name can only contain letters and spaces';
            nameInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            nameInput.classList.remove('error');
            return true;
        }
    }

    // Registration date validation
    regDateInput.addEventListener('change', validateDate);

    function validateDate() {
        const selectedDate = regDateInput.value;
        const errorDiv = document.getElementById('dateError');

        if (selectedDate > today) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Registration date cannot be in the future';
            regDateInput.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            regDateInput.classList.remove('error');
            return true;
        }
    }

    // Form submission validation
    form.addEventListener('submit', function(e) {
        // Run all validations
        const isNameValid = validateName();
        const isNICValid = validateNIC();
        const isPhoneValid = validatePhone();
        const isEmailValid = validateEmail();
        const isAgeValid = validateAge();
        const isPasswordValid = validatePassword();
        const isDateValid = validateDate();

        // Check if all validations pass
        if (!isNameValid || !isNICValid || !isPhoneValid || !isEmailValid ||
            !isAgeValid || !isPasswordValid || !isDateValid) {
            e.preventDefault();

            // Scroll to first error
            const firstError = document.querySelector('.error');
            if (firstError) {
                firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }

            // Show alert
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-error';
            alertDiv.innerHTML = '<i class="fas fa-exclamation-triangle"></i><span>Please fix the errors before submitting.</span>';
            form.insertBefore(alertDiv, form.firstChild);

            setTimeout(() => {
                alertDiv.remove();
            }, 3000);

            return false;
        }

        return true;
    });

    // Real-time validation for all fields
    document.querySelectorAll('input, select, textarea').forEach(field => {
        field.addEventListener('input', function() {
            this.classList.remove('error');
            const errorDiv = this.parentElement.querySelector('.error-message');
            if (errorDiv) errorDiv.innerHTML = '';
        });
    });
</script>

</body>
</html>