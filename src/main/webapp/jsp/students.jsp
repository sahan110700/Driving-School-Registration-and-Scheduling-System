<%@ page import="java.util.List" %>
<%@ page import="model.Student" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        :root {
            --primary: #2563eb;
            --primary2: #06b6d4;
            --bg: #f4f6f9;
            --card-bg: #ffffff;
            --success: #d1fae5;
            --success-text: #065f46;
            --error: #fee2e2;
            --error-text: #b91c1c;
            --text: #0f172a;
            --muted: #475569;
            --radius: 12px;
            --shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: var(--bg);
            color: var(--text);
        }

        h1 {
            text-align: center;
            margin-bottom: 20px;
        }

        .message {
            padding: 12px;
            margin-bottom: 15px;
            border-radius: var(--radius);
            font-weight: bold;
        }

        .success { background-color: var(--success); color: var(--success-text);}
        .error { background-color: var(--error); color: var(--error-text);}

        .container {
            max-width: 1000px;
            margin: auto;
        }

        .card {
            background: var(--card-bg);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 20px;
            margin-bottom: 20px;
            transition: transform 0.2s;
        }

        .card:hover { transform: translateY(-3px); }

        .card h3 {
            margin: 0 0 10px 0;
            color: var(--primary);
        }

        .card p { color: var(--muted); margin-bottom: 10px; }

        .actions {
            margin-top: 10px;
        }

        .actions a {
            padding: 6px 12px;
            border-radius: var(--radius);
            font-size: 13px;
            font-weight: bold;
            text-decoration: none;
            color: #fff;
            margin-right: 5px;
        }

        .edit { background: #22c55e; }
        .delete { background: #ef4444; }
        .add-new { background: var(--primary); }

        .top-links {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .top-links a {
            text-decoration: none;
            padding: 8px 14px;
            border-radius: var(--radius);
            background: var(--primary2);
            color: #fff;
            font-weight: bold;
        }

        @media (max-width: 768px) {
            .top-links { flex-direction: column; gap: 10px; }
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Student List</h1>

    <div class="top-links">
        <a href="<%= request.getContextPath() %>/home">Home</a>
        <!-- Updated Add New Student link -->
        <a href="<%= request.getContextPath() %>/students?action=add-form">Add New Student</a>
    </div>

    <% if ("added".equals(success)) { %>
    <div class="message success">Student added successfully!</div>
    <% } else if ("updated".equals(success)) { %>
    <div class="message success">Student updated successfully!</div>
    <% } else if ("deleted".equals(success)) { %>
    <div class="message success">Student deleted successfully!</div>
    <% } else if ("empty".equals(error)) { %>
    <div class="message error">Please fill all fields.</div>
    <% } else if ("age".equals(error)) { %>
    <div class="message error">Age must be a valid number.</div>
    <% } else if ("failed".equals(error)) { %>
    <div class="message error">Action failed. Try again.</div>
    <% } %>

    <% if (studentList != null && !studentList.isEmpty()) {
        for (Student s : studentList) { %>
    <div class="card">
        <h3><%= s.getName() %> (<%= s.getStudentId() %>)</h3>
        <p>Email: <%= s.getEmail() %></p>
        <p>License: <%= s.getLicenseType() %> | Phone: <%= s.getPhone() %> | Age: <%= s.getAge() %></p>
        <div class="actions">
            <a class="edit" href="<%= request.getContextPath() %>/students?action=edit&id=<%= s.getStudentId() %>">Edit</a>
            <a class="delete" href="<%= request.getContextPath() %>/students?action=delete&id=<%= s.getStudentId() %>" onclick="return confirm('Are you sure?');">Delete</a>
            <a class="add-new" href="<%= request.getContextPath() %>/students?action=add-form">Add New</a>
        </div>
    </div>
    <%  }
    } else { %>
    <p>No students found.</p>
    <% } %>
</div>
</body>
</html>