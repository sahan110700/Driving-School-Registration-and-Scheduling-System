<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Always redirect to home which handles login display
    String error = request.getParameter("error");
    String redirect = request.getContextPath() + "/home";
    if (error != null && !error.isEmpty()) {
        redirect += "?error=" + error;
    }
    response.sendRedirect(redirect);
%>