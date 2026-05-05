<%@ page import="model.Test" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Auth check
    if (session == null || session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }

    Object roleObj = session.getAttribute("userRole");
    String userRole = (roleObj != null) ? roleObj.toString() : "student";
    boolean isAdmin      = "admin".equalsIgnoreCase(userRole);
    boolean isInstructor = "instructor".equalsIgnoreCase(userRole);

    String username = String.valueOf(session.getAttribute("loggedInUser"));
    String initial = (!username.isEmpty()) ? String.valueOf(username.charAt(0)).toUpperCase() : "U";

    List<Test> upcomingTests = (List<Test>) request.getAttribute("upcomingTests");
    List<Test> testsByDate  = (List<Test>) request.getAttribute("testsByDate");
    Map<String, Object> statistics = (Map<String, Object>) request.getAttribute("statistics");
    String selectedDate = (String) request.getAttribute("selectedDate");
    String success = request.getParameter("success");
    String error   = request.getParameter("error");

    if (selectedDate == null) selectedDate = LocalDate.now().toString();
    DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    LocalDate currentDate = LocalDate.parse(selectedDate);

    long totalTests   = statistics != null ? (Long) statistics.get("totalTests")   : 0;
    long passedTests  = statistics != null ? (Long) statistics.get("passedTests")  : 0;
    long failedTests  = statistics != null ? (Long) statistics.get("failedTests")  : 0;
    double passRate   = statistics != null ? (Double) statistics.get("passRate")   : 0;
    double averageScore = statistics != null ? (Double) statistics.get("averageScore") : 0;

    // Servlet-layae filter pannirukom - JSP-la filter vendam
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isAdmin ? "Test Management" : (isInstructor ? "My Students Tests" : "My Tests") %> - DriveMaster Academy</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; font-family: 'Poppins', sans-serif; background: #0a0e1a; color: #f0f0f5; }

        /* ── TOPBAR ── */
        .topbar {
            display: flex; align-items: center; justify-content: space-between;
            padding: 12px 28px;
            background: rgba(10,14,26,0.97);
            border-bottom: 1px solid rgba(255,255,255,0.06);
            position: sticky; top: 0; z-index: 200;
            backdrop-filter: blur(20px); gap: 16px;
        }
        .brand { display: flex; align-items: center; gap: 11px; flex-shrink: 0; }
        .brand-name { font-size: 17px; font-weight: 800; color: #fff; }
        .brand-name span { color: #f59e0b; }
        .brand-tag { font-size: 9px; color: #3a3a5a; text-transform: uppercase; letter-spacing: 2px; }
        .nav-links { display: flex; gap: 2px; flex: 1; justify-content: center; }
        .nl {
            padding: 7px 11px; color: #4a4a6a; text-decoration: none;
            border-radius: 9px; font-size: 12px; font-weight: 500;
            transition: all 0.2s; display: flex; align-items: center; gap: 5px;
        }
        .nl:hover, .nl.active { background: rgba(245,158,11,0.08); color: #f59e0b; }
        .hdr-right { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
        .u-chip {
            display: flex; align-items: center; gap: 8px;
            background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.07);
            border-radius: 30px; padding: 5px 12px 5px 5px;
        }
        .u-av {
            width: 30px; height: 30px;
            background: linear-gradient(135deg, #f59e0b, #ef4444);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 13px; color: white;
        }
        .u-role { font-size: 9px; color: #3a3a5a; text-transform: uppercase; letter-spacing: 1px; }
        .u-name { font-size: 12px; font-weight: 600; color: #c0c0d8; }
        .logout-btn {
            padding: 8px 16px; background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white; text-decoration: none; border-radius: 10px;
            font-weight: 600; font-size: 12px; display: flex; align-items: center; gap: 6px; transition: all 0.2s;
        }
        .logout-btn:hover { transform: translateY(-1px); box-shadow: 0 6px 16px #ef444444; }
        .logo-svg { animation: logoBounce 3s ease-in-out infinite; }
        @keyframes logoBounce { 0%,100%{transform:translateY(0);} 50%{transform:translateY(-3px);} }

        /* ── MAIN ── */
        .main-wrap { background: #0a0e1a; min-height: calc(100vh - 65px); padding: 28px; }

        /* ── PAGE HERO ── */
        .page-hero {
            background: linear-gradient(135deg, rgba(139,92,246,0.12), rgba(109,40,217,0.08));
            border: 1px solid rgba(139,92,246,0.25);
            border-radius: 20px; padding: 28px 36px; margin-bottom: 24px;
            display: flex; justify-content: space-between; align-items: center;
            animation: fadeUp 0.5s ease both;
        }
        .hero-title { font-size: 24px; font-weight: 800; color: #fff; margin-bottom: 4px; }
        .hero-title span { color: #a78bfa; }
        .hero-sub { font-size: 13px; color: rgba(255,255,255,0.45); }
        .hero-icon {
            width: 56px; height: 56px;
            background: rgba(139,92,246,0.12); border: 1px solid rgba(139,92,246,0.25);
            border-radius: 16px; display: flex; align-items: center; justify-content: center;
            font-size: 24px; color: #a78bfa;
        }

        /* ── ALERTS ── */
        .alert {
            padding: 12px 18px; border-radius: 12px; margin-bottom: 20px;
            font-size: 13px; display: flex; align-items: center; gap: 10px; animation: fadeUp 0.3s ease;
        }
        .alert-success { background: rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.25); color: #6ee7b7; }
        .alert-error   { background: rgba(239,68,68,0.1);  border: 1px solid rgba(239,68,68,0.25);  color: #fca5a5; }

        /* ── STATS CARDS (admin only) ── */
        .stats-grid {
            display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin-bottom: 24px;
            animation: fadeUp 0.5s 0.05s ease both;
        }
        .stat-card {
            background: rgba(139,92,246,0.08); border: 1px solid rgba(139,92,246,0.2);
            border-top: 3px solid #8b5cf6;
            border-radius: 15px; padding: 20px; text-align: center; transition: all 0.2s;
        }
        .stat-card:hover { transform: translateY(-3px); background: rgba(139,92,246,0.12); }
        .stat-icon { font-size: 20px; color: #a78bfa; margin-bottom: 10px; }
        .stat-number { font-size: 32px; font-weight: 800; color: #fff; line-height: 1; }
        .stat-label  { font-size: 11px; color: #3a3a5a; text-transform: uppercase; letter-spacing: 1px; margin-top: 4px; }

        /* ── DATE NAV ── */
        .date-nav {
            display: flex; justify-content: space-between; align-items: center;
            background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.06);
            border-radius: 16px; padding: 14px 20px; margin-bottom: 20px;
            animation: fadeUp 0.5s 0.1s ease both;
        }
        .date-nav-btns { display: flex; gap: 8px; }
        .date-btn {
            padding: 7px 14px; background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08); border-radius: 9px;
            color: #c0c0d8; text-decoration: none; font-size: 12px; font-weight: 500;
            transition: all 0.2s; display: flex; align-items: center; gap: 6px;
        }
        .date-btn:hover { background: rgba(139,92,246,0.1); border-color: rgba(139,92,246,0.3); color: #a78bfa; }
        .date-label { font-size: 14px; font-weight: 700; color: #f0f0f5; display: flex; align-items: center; gap: 8px; }
        .date-label i { color: #a78bfa; }

        /* ── TABLE SECTIONS ── */
        .table-section {
            background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.06);
            border-radius: 20px; overflow: hidden; margin-bottom: 24px;
            animation: fadeUp 0.5s 0.15s ease both;
        }
        .table-section-header {
            padding: 16px 22px; border-bottom: 1px solid rgba(255,255,255,0.06);
            font-size: 14px; font-weight: 700; color: #f0f0f5;
            display: flex; align-items: center; gap: 10px;
        }
        .table-section-header i { color: #a78bfa; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #8b5cf6, #6d28d9); }
        th {
            padding: 12px 16px; text-align: left; font-size: 11px;
            font-weight: 600; color: white; text-transform: uppercase; letter-spacing: 0.5px;
        }
        td { padding: 13px 16px; border-bottom: 1px solid rgba(255,255,255,0.04); font-size: 13px; color: #c0c0d8; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: rgba(139,92,246,0.04); }
        td strong { color: #f0f0f5; }

        /* ── STATUS / RESULT BADGES ── */
        .badge {
            padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; display: inline-block;
        }
        .status-scheduled { background: rgba(59,130,246,0.15); color: #93c5fd; border: 1px solid rgba(59,130,246,0.25); }
        .status-completed { background: rgba(16,185,129,0.15); color: #6ee7b7; border: 1px solid rgba(16,185,129,0.25); }
        .status-cancelled { background: rgba(239,68,68,0.15);  color: #fca5a5; border: 1px solid rgba(239,68,68,0.25); }
        .result-pass    { background: rgba(16,185,129,0.15); color: #6ee7b7; border: 1px solid rgba(16,185,129,0.25); }
        .result-fail    { background: rgba(239,68,68,0.15);  color: #fca5a5; border: 1px solid rgba(239,68,68,0.25); }
        .result-pending { background: rgba(245,158,11,0.15); color: #fcd34d; border: 1px solid rgba(245,158,11,0.25); }

        /* ── ACTION BUTTONS (admin only) ── */
        .action-btn {
            padding: 5px 12px; border-radius: 8px; text-decoration: none;
            font-size: 11px; font-weight: 600; margin: 0 3px;
            display: inline-flex; align-items: center; gap: 5px; transition: all 0.2s;
        }
        .btn-results    { background: rgba(16,185,129,0.15); color: #6ee7b7; border: 1px solid rgba(16,185,129,0.2); }
        .btn-results:hover { background: rgba(16,185,129,0.25); }
        .btn-reschedule { background: rgba(59,130,246,0.15); color: #93c5fd; border: 1px solid rgba(59,130,246,0.2); }
        .btn-reschedule:hover { background: rgba(59,130,246,0.25); }
        .btn-cancel     { background: rgba(239,68,68,0.15);  color: #fca5a5; border: 1px solid rgba(239,68,68,0.2); }
        .btn-cancel:hover { background: rgba(239,68,68,0.25); }

        /* ── EMPTY STATE ── */
        .empty-state { text-align: center; padding: 48px 20px; color: #2a2a4a; }
        .empty-state i { font-size: 40px; margin-bottom: 12px; display: block; color: #1a1a3a; }
        .empty-state p { font-size: 14px; margin-bottom: 4px; color: #3a3a5a; }
        .empty-state span { font-size: 12px; color: #2a2a4a; }

        /* ── FOOTER ── */
        .footer { text-align: center; padding: 14px; color: #1a1a2a; font-size: 11px; border-top: 1px solid rgba(255,255,255,0.03); background: #07090f; }

        @keyframes fadeUp { from{opacity:0;transform:translateY(16px);} to{opacity:1;transform:translateY(0);} }

        @media (max-width: 768px) {
            .main-wrap { padding: 16px; }
            .stats-grid { grid-template-columns: repeat(2,1fr); }
            .page-hero { flex-direction: column; gap: 16px; }
            .date-nav { flex-direction: column; gap: 12px; }
            .nav-links { display: none; }
        }
    </style>
</head>
<body>

<!-- ── TOPBAR ── -->
<header class="topbar">
    <div class="brand">
        <svg width="44" height="44" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg" class="logo-svg">
            <rect width="44" height="44" rx="12" fill="url(#lg)"/>
            <defs><linearGradient id="lg" x1="0" y1="0" x2="44" y2="44"><stop offset="0%" stop-color="#f59e0b"/><stop offset="100%" stop-color="#ef4444"/></linearGradient></defs>
            <rect x="4" y="28" width="36" height="10" rx="3" fill="rgba(0,0,0,0.35)"/>
            <rect x="10" y="32" width="6" height="2" rx="1" fill="#fbbf24" opacity="0.8"/>
            <rect x="21" y="32" width="6" height="2" rx="1" fill="#fbbf24" opacity="0.8"/>
            <rect x="32" y="32" width="6" height="2" rx="1" fill="#fbbf24" opacity="0.8"/>
            <rect x="9" y="17" width="26" height="11" rx="4" fill="white"/>
            <rect x="13" y="12" width="16" height="9" rx="3" fill="white" opacity="0.9"/>
            <rect x="15" y="13.5" width="6" height="5.5" rx="1.5" fill="#93c5fd" opacity="0.8"/>
            <rect x="23" y="13.5" width="6" height="5.5" rx="1.5" fill="#93c5fd" opacity="0.8"/>
            <circle cx="15" cy="28.5" r="3.5" fill="#1f2937"/><circle cx="15" cy="28.5" r="1.5" fill="#9ca3af"/>
            <circle cx="30" cy="28.5" r="3.5" fill="#1f2937"/><circle cx="30" cy="28.5" r="1.5" fill="#9ca3af"/>
            <rect x="33" y="20" width="3" height="2" rx="1" fill="#fef3c7"/>
            <rect x="8" y="20" width="3" height="2" rx="1" fill="#fca5a5"/>
        </svg>
        <div>
            <div class="brand-name">Drive<span>Master</span></div>
            <div class="brand-tag">Driving Academy</div>
        </div>
    </div>

    <nav class="nav-links">
        <% if (isAdmin) { %>
        <a href="<%= request.getContextPath() %>/students"    class="nl"><i class="fas fa-user-graduate"></i><span>Students</span></a>
        <a href="<%= request.getContextPath() %>/instructors" class="nl"><i class="fas fa-chalkboard-teacher"></i><span>Instructors</span></a>
        <a href="<%= request.getContextPath() %>/vehicles"    class="nl"><i class="fas fa-car"></i><span>Vehicles</span></a>
        <a href="<%= request.getContextPath() %>/lessons"     class="nl"><i class="fas fa-calendar-check"></i><span>Lessons</span></a>
        <a href="<%= request.getContextPath() %>/tests"       class="nl active"><i class="fas fa-clipboard-list"></i><span>Tests</span></a>
        <a href="<%= request.getContextPath() %>/payments"    class="nl"><i class="fas fa-money-bill-wave"></i><span>Payments</span></a>
        <% } else { %>
        <a href="<%= request.getContextPath() %>/lessons"  class="nl"><i class="fas fa-calendar-check"></i><span>My Lessons</span></a>
        <a href="<%= request.getContextPath() %>/tests"    class="nl active"><i class="fas fa-clipboard-list"></i><span>My Tests</span></a>
        <a href="<%= request.getContextPath() %>/payments" class="nl"><i class="fas fa-money-bill-wave"></i><span>My Payments</span></a>
        <% } %>
    </nav>

    <div class="hdr-right">
        <div class="u-chip">
            <div class="u-av"><%= initial %></div>
            <div>
                <div class="u-role"><%= isAdmin ? "Administrator" : (isInstructor ? "Instructor" : "Student") %></div>
                <div class="u-name"><%= username %></div>
            </div>
        </div>
        <a href="<%= request.getContextPath() %>/logout" class="logout-btn">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>

<!-- ── MAIN ── -->
<div class="main-wrap">

    <!-- Alerts -->
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

    <!-- Page Hero -->
    <div class="page-hero">
        <div>
            <div class="hero-title">
                <i class="fas fa-clipboard-list" style="color:#a78bfa; margin-right:8px;"></i>
                <%= isAdmin ? "Test <span>Management</span>" : (isInstructor ? "My <span>Students Tests</span>" : "My <span>Tests</span>") %>
            </div>
            <div class="hero-sub">
                <%= isAdmin ? "Schedule, manage and record all driving tests" : (isInstructor ? "View and submit results for your assigned students" : "View your scheduled and completed driving tests") %>
            </div>
        </div>
        <div style="display:flex; gap:12px; align-items:center;">
            <% if (isAdmin) { %>
            <a href="<%= request.getContextPath() %>/tests?view=calendar" style="
                padding: 9px 18px; background: rgba(139,92,246,0.12);
                border: 1px solid rgba(139,92,246,0.3); border-radius: 10px;
                color: #a78bfa; text-decoration: none; font-size: 13px; font-weight: 600;
                display: flex; align-items: center; gap: 7px; transition: all 0.2s;">
                <i class="fas fa-calendar-alt"></i> Calendar
            </a>
            <a href="<%= request.getContextPath() %>/tests?action=add-form" style="
                padding: 9px 18px; background: linear-gradient(135deg,#8b5cf6,#6d28d9);
                border-radius: 10px; color: white; text-decoration: none;
                font-size: 13px; font-weight: 600; display: flex; align-items: center; gap: 7px;">
                <i class="fas fa-plus-circle"></i> Schedule Test
            </a>
            <% } else { %>
            <div class="hero-icon"><i class="fas fa-clipboard-list"></i></div>
            <% } %>
        </div>
    </div>

    <!-- Stats Cards — admin sees all-time stats, students see nothing here -->
    <% if (isAdmin) { %>
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-clipboard-list"></i></div>
            <div class="stat-number"><%= totalTests %></div>
            <div class="stat-label">Total Completed</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
            <div class="stat-number"><%= passedTests %></div>
            <div class="stat-label">Passed</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-times-circle"></i></div>
            <div class="stat-number"><%= failedTests %></div>
            <div class="stat-label">Failed</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-star"></i></div>
            <div class="stat-number"><%= String.format("%.1f", averageScore) %></div>
            <div class="stat-label">Average Score</div>
        </div>
    </div>
    <% } %>

    <!-- Date Navigation -->
    <div class="date-nav">
        <div class="date-nav-btns">
            <a href="<%= request.getContextPath() %>/tests?date=<%= currentDate.minusDays(1).toString() %>" class="date-btn">
                <i class="fas fa-chevron-left"></i> Previous Day
            </a>
            <a href="<%= request.getContextPath() %>/tests" class="date-btn">
                <i class="fas fa-calendar-day"></i> Today
            </a>
            <a href="<%= request.getContextPath() %>/tests?date=<%= currentDate.plusDays(1).toString() %>" class="date-btn">
                Next Day <i class="fas fa-chevron-right"></i>
            </a>
        </div>
        <div class="date-label">
            <i class="fas fa-calendar-alt"></i> <%= currentDate.format(displayFormatter) %>
        </div>
    </div>

    <!-- Tests for Selected Date -->
    <div class="table-section">
        <div class="table-section-header">
            <i class="fas fa-clock"></i>
            <%= isAdmin ? "Tests Scheduled for Today" : "My Tests for Today" %>
        </div>
        <table>
            <thead>
            <tr>
                <th>Time</th>
                <% if (isAdmin || isInstructor) { %><th>Student</th><% } %>
                <th>Test Type</th>
                <% if (!isInstructor) { %><th>Examiner</th><% } %>
                <th>Result</th>
                <th>Status</th>
                <% if (isAdmin || isInstructor) { %><th>Actions</th><% } %>
            </tr>
            </thead>
            <tbody>
            <% if (testsByDate != null && !testsByDate.isEmpty()) {
                for (Test test : testsByDate) { %>
            <tr>
                <td><strong><%= test.getFormattedTime() %></strong></td>
                <% if (isAdmin || isInstructor) { %><td><%= test.getStudentName() %></td><% } %>
                <td><%= test.getTestType() %></td>
                <% if (!isInstructor) { %><td><%= test.getExaminerName() %></td><% } %>
                <td>
                    <span class="badge result-<%= test.getResult().toLowerCase() %>">
                        <%= test.getResult() %>
                        <% if (test.getScore() > 0) { %> (<%= test.getScore() %>)<% } %>
                    </span>
                </td>
                <td>
                    <span class="badge status-<%= test.getStatus().toLowerCase() %>">
                        <%= test.getStatus() %>
                    </span>
                </td>
                <% if (isAdmin || isInstructor) { %>
                <td>
                    <% if ("Scheduled".equals(test.getStatus())) { %>
                    <%-- Instructor மட்டும் Results submit பண்ணலாம் --%>
                    <% if (isInstructor) { %>
                    <a href="<%= request.getContextPath() %>/tests?action=results&id=<%= test.getTestId() %>" class="action-btn btn-results">
                        <i class="fas fa-star"></i> Results
                    </a>
                    <% } %>
                    <%-- Admin மட்டும் Reschedule & Cancel பண்ணலாம் --%>
                    <% if (isAdmin) { %>
                    <a href="<%= request.getContextPath() %>/tests?action=edit&id=<%= test.getTestId() %>" class="action-btn btn-reschedule">
                        <i class="fas fa-calendar-alt"></i> Reschedule
                    </a>
                    <a href="<%= request.getContextPath() %>/tests?action=cancel&id=<%= test.getTestId() %>" class="action-btn btn-cancel"
                       onclick="return confirm('Cancel this test?')">
                        <i class="fas fa-times-circle"></i> Cancel
                    </a>
                    <% } %>
                    <% } else if ("Completed".equals(test.getStatus())) { %>
                    <span style="color:#6ee7b7; font-size:12px;"><i class="fas fa-check-circle"></i> Completed</span>
                    <% } else { %>
                    <span style="color:#fca5a5; font-size:12px;"><i class="fas fa-ban"></i> Cancelled</span>
                    <% } %>
                </td>
                <% } %>
            </tr>
            <% } } else { %>
            <tr>
                <td colspan="<%= isAdmin ? 7 : (isInstructor ? 6 : 5) %>">
                    <div class="empty-state">
                        <i class="fas fa-calendar-day"></i>
                        <p>No tests scheduled for this day</p>
                        <% if (!isAdmin) { %><span>Your admin will schedule tests for you</span><% } %>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <!-- Upcoming Tests -->
    <div class="table-section" style="animation-delay:0.2s;">
        <div class="table-section-header">
            <i class="fas fa-calendar-week"></i>
            <%= isAdmin ? "Upcoming Tests" : "My Upcoming Tests" %>
        </div>
        <table>
            <thead>
            <tr>
                <th>Date</th>
                <th>Time</th>
                <% if (isAdmin || isInstructor) { %><th>Student</th><% } %>
                <th>Test Type</th>
                <% if (!isInstructor) { %><th>Examiner</th><% } %>
                <th>Result</th>
                <th>Status</th>
                <% if (isAdmin || isInstructor) { %><th>Actions</th><% } %>
            </tr>
            </thead>
            <tbody>
            <% if (upcomingTests != null && !upcomingTests.isEmpty()) {
                for (Test test : upcomingTests) { %>
            <tr>
                <td><%= test.getTestDate() %></td>
                <td><strong><%= test.getFormattedTime() %></strong></td>
                <% if (isAdmin || isInstructor) { %><td><%= test.getStudentName() %></td><% } %>
                <td><%= test.getTestType() %></td>
                <% if (!isInstructor) { %><td><%= test.getExaminerName() %></td><% } %>
                <td>
                    <% if ("Pass".equals(test.getResult())) { %>
                    <span style="color:#16a34a; font-weight:700;"><i class="fas fa-check-circle"></i> Pass</span>
                    <% } else if ("Fail".equals(test.getResult())) { %>
                    <span style="color:#dc2626; font-weight:700;"><i class="fas fa-times-circle"></i> Fail</span>
                    <% } else { %>
                    <span style="color:#9ca3af;">-</span>
                    <% } %>
                </td>
                <td>
                    <span class="badge status-<%= test.getStatus().toLowerCase() %>">
                        <%= test.getStatus() %>
                    </span>
                </td>
                <% if (isAdmin || isInstructor) { %>
                <td>
                    <% if ("Scheduled".equals(test.getStatus())) { %>
                    <% if (isInstructor) { %>
                    <a href="<%= request.getContextPath() %>/tests?action=results&id=<%= test.getTestId() %>" class="action-btn btn-results">
                        <i class="fas fa-star"></i> Results
                    </a>
                    <% } %>
                    <% if (isAdmin) { %>
                    <a href="<%= request.getContextPath() %>/tests?action=edit&id=<%= test.getTestId() %>" class="action-btn btn-reschedule">
                        <i class="fas fa-calendar-alt"></i> Reschedule
                    </a>
                    <a href="<%= request.getContextPath() %>/tests?action=cancel&id=<%= test.getTestId() %>" class="action-btn btn-cancel"
                       onclick="return confirm('Cancel this test?')">
                        <i class="fas fa-times-circle"></i> Cancel
                    </a>
                    <% } %>
                    <% } else if ("Completed".equals(test.getStatus())) { %>
                    <span style="color:#6ee7b7; font-size:12px;"><i class="fas fa-check-circle"></i> Done</span>
                    <% } else { %>
                    <span style="color:#fca5a5; font-size:12px;"><i class="fas fa-ban"></i> Cancelled</span>
                    <% } %>
                </td>
                <% } %>
            </tr>
            <% } } else { %>
            <tr>
                <td colspan="<%= isAdmin ? 8 : (isInstructor ? 7 : 6) %>">
                    <div class="empty-state">
                        <i class="fas fa-calendar-week"></i>
                        <p><%= isAdmin ? "No tests found" : (isInstructor ? "No student tests found" : "No tests found") %></p>
                        <% if (!isAdmin) { %><span>Check back later</span><% } %>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

</div>

<footer class="footer">
    <p>&copy; 2025 DriveMaster Academy &mdash; Sri Lanka's Premier Driving School</p>
</footer>

<script>
    setTimeout(() => {
        document.querySelectorAll('.alert').forEach(a => {
            a.style.transition = 'opacity 0.3s';
            a.style.opacity = '0';
            setTimeout(() => a.remove(), 300);
        });
    }, 5000);
</script>

</body>
</html>
