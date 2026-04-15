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

        /* Form styles */
        form { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:30px; }
        input, select { padding:10px; border-radius: var(--radius); border:1px solid #ccc; }
        button { grid-column: span 2; padding:12px; background: var(--primary); color:#fff; border:none; border-radius: var(--radius); font-weight:bold; cursor:pointer; }
        button:hover { background: var(--primary2); }

        /* Messages */
        .message { padding:12px; border-radius: var(--radius); margin-bottom:15px; text-align:center; font-weight:bold; }
        .success { background: var(--success); color: var(--success-text);}
        .error { background: var(--error); color: var(--error-text); }

        /* Student cards */
        .cards { display:grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap:15px; }
        .card { background: var(--card-bg); border-radius: var(--radius); padding:15px; box-shadow: var(--shadow); transition: transform 0.2s; }
        .card:hover { transform: translateY(-3px); }
        .card h3 { margin:0 0 8px 0; color: var(--primary); }
        .card p { margin:2px 0; color:#475569; }
        .actions { margin-top:10px; }
        .actions a { padding:6px 10px; border-radius: var(--radius); color:#fff; text-decoration:none; font-weight:bold; margin-right:5px; font-size:13px; }
        .edit { background:#22c55e; }
        .delete { background:#ef4444; }

        .top-links { display:flex; justify-content:flex-end; margin-bottom:15px; gap:10px; }
        .top-links a { text-decoration:none; padding:6px 12px; border-radius: var(--radius); background: var(--primary2); color:#fff; font-weight:bold; }

        @media (max-width:768px){ form { grid-template-columns:1fr; } }
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
    <div class="message error">Please fill all fields.</div>
    <% } else if ("age".equals(error)) { %>
    <div class="message error">Age must be a valid number.</div>
    <% } else if ("added".equals(success)) { %>
    <div class="message success">Student added successfully!</div>
    <% } else if ("failed".equals(error)) { %>
    <div class="message error">Failed to add student. Try again.</div>
    <% } %>

    <!-- Add Student Form -->
    <form action="<%= request.getContextPath() %>/students" method="post">
        <input type="hidden" name="action" value="add">
        <input type="text" name="name" placeholder="Student Name">
        <input type="email" name="email" placeholder="Email">
        <input type="text" name="password" placeholder="Password">
        <select name="licenseType">
            <option value="Manual">Manual</option>
            <option value="Automatic">Automatic</option>
        </select>
        <input type="text" name="phone" placeholder="Phone">
        <input type="text" name="age" placeholder="Age">
        <button type="submit">Add Student</button>
    </form>

    <!-- Student Cards -->
    <h2>Existing Students</h2>
    <% if (studentList != null && !studentList.isEmpty()) { %>
    <div class="cards">
        <% for (Student s : studentList) { %>
        <div class="card">
            <h3><%= s.getName() %> (<%= s.getStudentId() %>)</h3>
            <p>Email: <%= s.getEmail() %></p>
            <p>License: <%= s.getLicenseType() %> | Phone: <%= s.getPhone() %> | Age: <%= s.getAge() %></p>
            <div class="actions">
                <a class="edit" href="<%= request.getContextPath() %>/students?action=edit&id=<%= s.getStudentId() %>">Edit</a>
                <a class="delete" href="<%= request.getContextPath() %>/students?action=delete&id=<%= s.getStudentId() %>" onclick="return confirm('Are you sure?');">Delete</a>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <p>No students found.</p>
    <% } %>

</div>
</body>
</html>