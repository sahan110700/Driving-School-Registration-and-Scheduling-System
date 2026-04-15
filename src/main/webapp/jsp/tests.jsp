<%@ page import="model.Test" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Test> upcomingTests = (List<Test>) request.getAttribute("upcomingTests");
    List<Test> testsByDate = (List<Test>) request.getAttribute("testsByDate");
    Map<String, Object> statistics = (Map<String, Object>) request.getAttribute("statistics");
    String selectedDate = (String) request.getAttribute("selectedDate");
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    if (selectedDate == null) selectedDate = LocalDate.now().toString();
    DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    LocalDate currentDate = LocalDate.parse(selectedDate);

    // Calculate statistics
    long totalTests = statistics != null ? (Long) statistics.get("totalTests") : 0;
    long passedTests = statistics != null ? (Long) statistics.get("passedTests") : 0;
    long failedTests = statistics != null ? (Long) statistics.get("failedTests") : 0;
    double passRate = statistics != null ? (Double) statistics.get("passRate") : 0;
    double averageScore = statistics != null ? (Double) statistics.get("averageScore") : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Management - Driving School</title>
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
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
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

        .header-buttons {
            display: flex;
            gap: 15px;
        }

        .btn-primary {
            padding: 12px 24px;
            background: white;
            color: #6d28d9;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-secondary {
            padding: 12px 24px;
            background: rgba(255,255,255,0.2);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
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

        /* Stats Cards */
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px 40px 0 40px;
        }

        .stat-card {
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: white;
            padding: 20px;
            border-radius: 16px;
            text-align: center;
        }

        .stat-number {
            font-size: 32px;
            font-weight: 700;
        }

        .stat-label {
            font-size: 14px;
            opacity: 0.9;
            margin-top: 5px;
        }

        /* Date Navigation */
        .date-nav {
            padding: 20px 40px;
            background: #f8f9fa;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e9ecef;
        }

        .date-nav-buttons {
            display: flex;
            gap: 10px;
        }

        .date-nav-btn {
            padding: 8px 16px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            text-decoration: none;
            color: #374151;
            transition: all 0.3s ease;
        }

        .date-nav-btn:hover {
            background: #8b5cf6;
            color: white;
        }

        /* Test Table */
        .test-section {
            padding: 30px 40px;
        }

        .section-title {
            font-size: 20px;
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
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
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
            background: #f5f3ff;
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

        .result-pass {
            background: #d1fae5;
            color: #065f46;
        }

        .result-fail {
            background: #fee2e2;
            color: #991b1b;
        }

        .result-pending {
            background: #fef3c7;
            color: #92400e;
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

        .btn-results {
            background: #d1fae5;
            color: #065f46;
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
            padding: 60px;
            color: #6b7280;
        }

        @media (max-width: 768px) {
            .stats-cards, .test-section, .date-nav {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-clipboard-list"></i> Test Management</h2>
        <div class="header-buttons">
            <a href="<%= request.getContextPath() %>/tests?view=calendar" class="btn-secondary">
                <i class="fas fa-calendar-alt"></i> Calendar View
            </a>
            <a href="<%= request.getContextPath() %>/tests?action=add-form" class="btn-primary">
                <i class="fas fa-plus-circle"></i> Schedule Test
            </a>
        </div>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
        <div>
            <i class="fas fa-chart-line" style="color: #8b5cf6;"></i>
            <span style="font-size: 14px; color: #6b7280;">Pass Rate: <%= String.format("%.1f", passRate) %>%</span>
        </div>
    </div>

    <!-- Alert Messages -->
    <% if ("added".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Test scheduled successfully!</div>
    <% } else if ("updated".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Test updated successfully!</div>
    <% } else if ("cancelled".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Test cancelled successfully!</div>
    <% } else if ("resultsUpdated".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Test results submitted successfully!</div>
    <% } else if ("conflict".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Schedule conflict! Examiner or student not available.</div>
    <% } else if ("invalidTime".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Test time must be between 8:00 AM and 5:00 PM.</div>
    <% } else if ("pastDate".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Test date cannot be in the past.</div>
    <% } %>

    <!-- Statistics Cards -->
    <div class="stats-cards">
        <div class="stat-card">
            <div class="stat-number"><%= totalTests %></div>
            <div class="stat-label">Total Tests</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= passedTests %></div>
            <div class="stat-label">Passed</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= failedTests %></div>
            <div class="stat-label">Failed</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= String.format("%.1f", averageScore) %></div>
            <div class="stat-label">Average Score</div>
        </div>
    </div>

    <!-- Date Navigation -->
    <div class="date-nav">
        <div class="date-nav-buttons">
            <a href="<%= request.getContextPath() %>/tests?date=<%= currentDate.minusDays(1).toString() %>" class="date-nav-btn">
                <i class="fas fa-chevron-left"></i> Previous Day
            </a>
            <a href="<%= request.getContextPath() %>/tests" class="date-nav-btn">
                <i class="fas fa-calendar-day"></i> Today
            </a>
            <a href="<%= request.getContextPath() %>/tests?date=<%= currentDate.plusDays(1).toString() %>" class="date-nav-btn">
                Next Day <i class="fas fa-chevron-right"></i>
            </a>
        </div>
        <h3><i class="fas fa-calendar-alt"></i> <%= currentDate.format(displayFormatter) %></h3>
    </div>

    <!-- Tests for Selected Date -->
    <div class="test-section">
        <div class="section-title">
            <i class="fas fa-clock"></i> Tests Scheduled
        </div>
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Time</th>
                    <th>Student</th>
                    <th>Test Type</th>
                    <th>Examiner</th>
                    <th>Result</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (testsByDate != null && !testsByDate.isEmpty()) {
                    for (Test test : testsByDate) { %>
                <tr>
                    <td><strong><%= test.getFormattedTime() %></strong></td>
                    <td><%= test.getStudentName() %></td>
                    <td><%= test.getTestType() %></td>
                    <td><%= test.getExaminerName() %></td>
                    <td>
                                    <span class="status-badge result-<%= test.getResult().toLowerCase() %>">
                                        <%= test.getResult() %>
                                        <% if (test.getScore() > 0) { %>
                                            (<%= test.getScore() %>)
                                        <% } %>
                                    </span>
                    </td>
                    <td>
                                    <span class="status-badge status-<%= test.getStatus().toLowerCase() %>">
                                        <%= test.getStatus() %>
                                    </span>
                    </td>
                    <td>
                        <% if ("Scheduled".equals(test.getStatus())) { %>
                        <a href="<%= request.getContextPath() %>/tests?action=results&id=<%= test.getTestId() %>"
                           class="action-btn btn-results">
                            <i class="fas fa-star"></i> Enter Results
                        </a>
                        <a href="<%= request.getContextPath() %>/tests?action=edit&id=<%= test.getTestId() %>"
                           class="action-btn btn-reschedule">
                            <i class="fas fa-calendar-alt"></i> Reschedule
                        </a>
                        <a href="<%= request.getContextPath() %>/tests?action=cancel&id=<%= test.getTestId() %>"
                           class="action-btn btn-cancel"
                           onclick="return confirm('Cancel this test?')">
                            <i class="fas fa-times-circle"></i> Cancel
                        </a>
                        <% } else if ("Completed".equals(test.getStatus())) { %>
                        <span style="color: #10b981;"><i class="fas fa-check-circle"></i> Completed</span>
                        <% } else { %>
                        <span style="color: #ef4444;"><i class="fas fa-ban"></i> Cancelled</span>
                        <% } %>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr>
                    <td colspan="7">
                        <div class="empty-state">
                            <i class="fas fa-calendar-day"></i>
                            <p>No tests scheduled for this day</p>
                            <p style="font-size: 12px;">Click "Schedule Test" to book a test</p>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- Upcoming Tests -->
        <div class="section-title" style="margin-top: 30px;">
            <i class="fas fa-calendar-week"></i> Upcoming Tests
        </div>
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Student</th>
                    <th>Test Type</th>
                    <th>Examiner</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (upcomingTests != null && !upcomingTests.isEmpty()) {
                    for (Test test : upcomingTests) { %>
                <tr>
                    <td><%= test.getTestDate() %></td>
                    <td><%= test.getFormattedTime() %></td>
                    <td><%= test.getStudentName() %></td>
                    <td><%= test.getTestType() %></td>
                    <td><%= test.getExaminerName() %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/tests?action=edit&id=<%= test.getTestId() %>"
                           class="action-btn btn-reschedule">
                            <i class="fas fa-calendar-alt"></i> Reschedule
                        </a>
                        <a href="<%= request.getContextPath() %>/tests?action=cancel&id=<%= test.getTestId() %>"
                           class="action-btn btn-cancel"
                           onclick="return confirm('Cancel this test?')">
                            <i class="fas fa-times-circle"></i> Cancel
                        </a>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr>
                    <td colspan="6">
                        <div class="empty-state">
                            <i class="fas fa-calendar-week"></i>
                            <p>No upcoming tests scheduled</p>
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
    setTimeout(() => {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            alert.style.opacity = '0';
            setTimeout(() => alert.remove(), 300);
        });
    }, 5000);
</script>

</body>
</html>