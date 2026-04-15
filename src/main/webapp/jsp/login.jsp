<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Driving School Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f9;
            margin: 0;
            padding: 0;
        }

        .login-box {
            width: 400px;
            margin: 80px auto;
            background: #ffffff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.15);
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
            color: #333333;
        }

        label {
            display: block;
            margin-top: 12px;
            margin-bottom: 6px;
            font-weight: bold;
            color: #444444;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #cccccc;
            border-radius: 5px;
            box-sizing: border-box;
        }

        button {
            width: 100%;
            margin-top: 20px;
            padding: 12px;
            background-color: #007bff;
            border: none;
            color: white;
            font-size: 16px;
            border-radius: 5px;
            cursor: pointer;
        }

        button:hover {
            background-color: #0056b3;
        }

        .message {
            text-align: center;
            margin-bottom: 15px;
            font-size: 14px;
        }

        .error {
            color: red;
        }

        .success {
            color: green;
        }

        .link-box {
            text-align: center;
            margin-top: 15px;
        }

        .link-box a {
            text-decoration: none;
            color: #007bff;
        }

        .link-box a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="login-box">
    <h2>Driving School Login</h2>

    <%
        String error = request.getParameter("error");
        String success = request.getParameter("success");

        if ("empty".equals(error)) {
    %>
    <div class="message error">Please enter username and password.</div>
    <%
    } else if ("invalid".equals(error)) {
    %>
    <div class="message error">Invalid username or password.</div>
    <%
        }

        if ("registered".equals(success)) {
    %>
    <div class="message success">Registration successful. Please login.</div>
    <%
        }
    %>

    <form action="<%= request.getContextPath() %>/login" method="post">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" placeholder="Enter username">

        <label for="password">Password</label>
        <input type="password" id="password" name="password" placeholder="Enter password">

        <button type="submit">Login</button>
    </form>

    <div class="link-box">
        <p>Do not have an account? <a href="<%= request.getContextPath() %>/jsp/register.jsp">Register here</a></p>
    </div>
</div>

</body>
</html>