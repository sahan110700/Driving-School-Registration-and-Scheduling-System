<%@ page import="java.util.List" %>
<%@ page import="model.Student" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add & View Students</title>
    <style>
        :root {
            --primary: #2563eb;
            --primary2: #06b6d4;
            --bg: #f4f6f9;
            --card-bg: #ffffff;
            --radius: 12px;
            --shadow: 0 4px 15px rgba(0,0,0,0.1);
            --success: #d1fae5;
            --success-text: #065f46;
            --error: #fee2e2;
            --error-text: #b91c1c;
        }

        body { font-family: Arial; margin:0; padding:20px; background: var(--bg); color: #0f172a; }
        .container { max-width: 1000px; margin:auto; background: var(--card-bg); padding:20px; border-radius: var(--radius); box-shadow: var(--shadow);}
        h2 { text-align:center; color: var(--primary); margin-bottom:20px; }

        form { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:30px; }
        input, select { padding:10px; border-radius: var(--radius); border:1px solid #ccc; width:100%; box-sizing:border-box; }
        .full-width { grid-column: span 2; }
        button { grid-column: span 2; padding:12px; background: var(--primary); color:#fff; border:none; border-radius: var(--radius); font-weight:bold; cursor:pointer; font-size:15px; }
        button:hover { background: var(--primary2); }

        .section-label { grid-column: span 2; font-weight: bold; color: var(--primary); border-bottom: 2px solid var(--primary2); padding-bottom: 5px; margin-top: 10px; }

        .message { padding:12px; border-radius: var(--radius); margin-bottom:15px; text-align:center; font-weight:bold; }
        .success { background: var(--success); color: var(--success-text);}
        .error-msg { background: var(--error); color: var(--error-text); }

        .cards { display:grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap:15px; }
        .card { background: var(--card-bg); border-radius: var(--radius); padding:15px; box-shadow: var(--shadow); transition: transform 0.2s; }
        .card:hover { transform: translateY(-3px); }
        .card h3 { margin:0 0 8px 0; color: var(--primary); }
        .card p { margin:2px 0; color:#475569; font-size:13px; }
        .actions { margin-top:10px; }
        .actions a { padding:6px 10px; border-radius: var(--radius); color:#fff; text-decoration:none; font-weight:bold; margin-right:5px; font-size:13px; }
        .edit { background:#22c55e; }
        .delete { background:#ef4444; }

        .top-links { display:flex; justify-content:flex-end; margin-bottom:15px; gap:10px; }
        .top-links a { text-decoration:none; padding:6px 12px; border-radius: var(--radius); background: var(--primary2); color:#fff; font-weight:bold; }

        @media (max-width:768px){ form { grid-template-columns:1fr; } .full-width { grid-column: span 1; } button { grid-column: span 1; } }
    </style>
</head>
<body>

<div class="container">
    <h2>Add New Student</h2>

    <div class="top-links">
        <a href="<%= request.getContextPath() %>/home">Home</a>
        <a href="<%= request.getContextPath() %>/students">View Students</a>
    </div>

    <% if ("empty".equals(error)) { %>
    <div class="message error-msg">Please fill in all required fields.</div>
    <% } else if ("age".equals(error)) { %>
    <div class="message error-msg">Age must be a valid number.</div>
    <% } else if ("usernameExists".equals(error)) { %>
    <div class="message error-msg">Username already exists. Please choose another.</div>
    <% } else if ("failed".equals(error)) { %>
    <div class="message error-msg">Failed to add student. Try again.</div>
    <% } else if ("added".equals(success)) { %>
    <div class="message success">Student added successfully! They can now login.</div>
    <% } else if ("deleted".equals(success)) { %>
    <div class="message success">Student deleted successfully.</div>
    <% } %>

    <!-- Add Student Form -->
    <form action="<%= request.getContextPath() %>/students" method="post">
        <input type="hidden" name="action" value="add">

        <div class="section-label">Personal Details</div>
        <input type="text" name="name" placeholder="Full Name *" required>
        <input type="text" name="nic" placeholder="NIC Number *" required>
        <input type="text" name="phone" placeholder="Phone Number *" required>
        <input type="email" name="email" placeholder="Email Address *" required>
        <input type="number" name="age" placeholder="Age *" min="16" max="100" required>
        <select name="gender" required>
            <option value="">-- Select Gender *--</option>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
        </select>
        <input type="text" name="address" placeholder="Address *" class="full-width" required>

        <div class="section-label">Course Details</div>
        <select name="licenseType" required>
            <option value="">-- License Type * --</option>
            <option value="Manual">Manual</option>
            <option value="Automatic">Automatic</option>
            <option value="Both">Both</option>
        </select>
        <select name="coursePackage" required>
            <option value="">-- Course Package * --</option>
            <option value="Basic">Basic</option>
            <option value="Standard">Standard</option>
            <option value="Premium">Premium</option>
        </select>
        <input type="date" name="registrationDate" required>
        <input type="text" name="placeholder" style="visibility:hidden;">

        <div class="section-label">Login Credentials (Student uses these to login)</div>
        <input type="text" name="username" placeholder="Username * (for login)" required>
        <input type="password" name="password" placeholder="Password * (for login)" required>

        <button type="submit">Add Student</button>
    </form>

    <!-- Student List -->
    <h2>Existing Students</h2>
    <% if (studentList != null && !studentList.isEmpty()) { %>
    <div class="cards">
        <% for (Student s : studentList) { %>
        <div class="card">
            <h3><%= s.getName() %> (<%= s.getStudentId() %>)</h3>
            <p><strong>Email:</strong> <%= s.getEmail() %></p>
            <p><strong>NIC:</strong> <%= s.getNic() %></p>
            <p><strong>Phone:</strong> <%= s.getPhone() %></p>
            <p><strong>Age:</strong> <%= s.getAge() %> | <strong>Gender:</strong> <%= s.getGender() %></p>
            <p><strong>License:</strong> <%= s.getLicenseType() %> | <strong>Package:</strong> <%= s.getCoursePackage() %></p>
            <p><strong>Registered:</strong> <%= s.getRegistrationDate() %></p>
            <div class="actions">
                <a class="edit" href="<%= request.getContextPath() %>/students?action=edit&id=<%= s.getStudentId() %>">Edit</a>
                <a class="delete" href="<%= request.getContextPath() %>/students?action=delete&id=<%= s.getStudentId() %>" onclick="return confirm('Delete this student?');">Delete</a>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <p style="text-align:center; color:#888;">No students found. Add one above.</p>
    <% } %>

</div>
</body>
</html>
