<%@ page import="model.*" %>
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
    boolean isAdmin = "admin".equalsIgnoreCase(userRole);
    boolean isInstructor = "instructor".equalsIgnoreCase(userRole);

    String username = String.valueOf(session.getAttribute("loggedInUser"));
    String initial = (!username.isEmpty()) ? String.valueOf(username.charAt(0)).toUpperCase() : "U";

    // resolvedInstructorName set by servlet for instructor role
    String resolvedInstructorName = (String) request.getAttribute("resolvedInstructorName");

    List<Student> students = (List<Student>) request.getAttribute("students");
    List<Instructor> instructors = (List<Instructor>) request.getAttribute("instructors");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
    List<Lesson> upcomingLessons = (List<Lesson>) request.getAttribute("upcomingLessons");
    String selectedDate = (String) request.getAttribute("selectedDate");
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    if (selectedDate == null) selectedDate = LocalDate.now().toString();
    DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    LocalDate currentDate = LocalDate.parse(selectedDate);

    // Filter lessons by role
    if (!isAdmin) {
        if (isInstructor && resolvedInstructorName != null) {
            // Instructor sees their own lessons (matched by instructor name)
            if (lessons != null) {
                List<Lesson> myLessons = new ArrayList<>();
                for (Lesson l : lessons) {
                    if (resolvedInstructorName.equalsIgnoreCase(l.getInstructorName())) myLessons.add(l);
                }
                lessons = myLessons;
            }
            if (upcomingLessons != null) {
                List<Lesson> myUpcoming = new ArrayList<>();
                for (Lesson l : upcomingLessons) {
                    if (resolvedInstructorName.equalsIgnoreCase(l.getInstructorName())) myUpcoming.add(l);
                }
                upcomingLessons = myUpcoming;
            }
        } else {
            // Student sees their own lessons (matched by student name)
            if (lessons != null) {
                List<Lesson> myLessons = new ArrayList<>();
                for (Lesson l : lessons) {
                    if (username.equalsIgnoreCase(l.getStudentName())) myLessons.add(l);
                }
                lessons = myLessons;
            }
            if (upcomingLessons != null) {
                List<Lesson> myUpcoming = new ArrayList<>();
                for (Lesson l : upcomingLessons) {
                    if (username.equalsIgnoreCase(l.getStudentName())) myUpcoming.add(l);
                }
                upcomingLessons = myUpcoming;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isAdmin ? "Lesson Scheduling" : "My Lessons" %> - DriveMaster Academy</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        html, body {
            height: 100%;
            font-family: 'Poppins', sans-serif;
            background: #0a0e1a;
            color: #f0f0f5;
        }

        /* ── TOPBAR ── */
        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 28px;
            background: rgba(10,14,26,0.97);
            border-bottom: 1px solid rgba(255,255,255,0.06);
            position: sticky;
            top: 0;
            z-index: 200;
            backdrop-filter: blur(20px);
            gap: 16px;
        }
        .brand { display: flex; align-items: center; gap: 11px; flex-shrink: 0; }
        .brand-name { font-size: 17px; font-weight: 800; color: #fff; }
        .brand-name span { color: #f59e0b; }
        .brand-tag { font-size: 9px; color: #3a3a5a; text-transform: uppercase; letter-spacing: 2px; }
        .nav-links { display: flex; gap: 2px; flex: 1; justify-content: center; }
        .nl {
            padding: 7px 11px;
            color: #4a4a6a;
            text-decoration: none;
            border-radius: 9px;
            font-size: 12px;
            font-weight: 500;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .nl:hover, .nl.active { background: rgba(245,158,11,0.08); color: #f59e0b; }
        .hdr-right { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
        .u-chip {
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.07);
            border-radius: 30px;
            padding: 5px 12px 5px 5px;
        }
        .u-av {
            width: 30px; height: 30px;
            background: linear-gradient(135deg, #f59e0b, #ef4444);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 13px; color: white;
        }
        .u-role { font-size: 9px; color: #3a3a5a; text-transform: uppercase; letter-spacing: 1px; }
        .u-name { font-size: 12px; font-weight: 600; color: #c0c0d8; }
        .logout-btn {
            padding: 8px 16px;
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 12px;
            display: flex; align-items: center; gap: 6px;
            transition: all 0.2s;
        }
        .logout-btn:hover { transform: translateY(-1px); box-shadow: 0 6px 16px #ef444444; }

        /* ── LOGO SVG ── */
        .logo-svg { animation: logoBounce 3s ease-in-out infinite; }
        @keyframes logoBounce { 0%,100%{transform:translateY(0);} 50%{transform:translateY(-3px);} }

        /* ── MAIN WRAP ── */
        .main-wrap {
            background: #0a0e1a;
            min-height: calc(100vh - 65px);
            padding: 28px;
        }

        /* ── PAGE HERO ── */
        .page-hero {
            background: linear-gradient(135deg, rgba(245,158,11,0.12), rgba(239,68,68,0.08));
            border: 1px solid rgba(245,158,11,0.2);
            border-radius: 20px;
            padding: 28px 36px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            animation: fadeUp 0.5s ease both;
        }
        .hero-title { font-size: 24px; font-weight: 800; color: #fff; margin-bottom: 4px; }
        .hero-title span { color: #f59e0b; }
        .hero-sub { font-size: 13px; color: rgba(255,255,255,0.45); }
        .hero-icon {
            width: 56px; height: 56px;
            background: rgba(245,158,11,0.12);
            border: 1px solid rgba(245,158,11,0.25);
            border-radius: 16px;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px; color: #f59e0b;
        }

        /* ── ALERT ── */
        .alert {
            padding: 12px 18px;
            border-radius: 12px;
            margin-bottom: 20px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: fadeUp 0.3s ease;
        }
        .alert-success { background: rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.25); color: #6ee7b7; }
        .alert-error   { background: rgba(239,68,68,0.1);  border: 1px solid rgba(239,68,68,0.25);  color: #fca5a5; }

        /* ── BOOKING FORM (admin only) ── */
        .booking-section {
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.07);
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 24px;
            animation: fadeUp 0.5s 0.05s ease both;
        }
        .section-header {
            font-size: 15px;
            font-weight: 700;
            color: #f0f0f5;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-header i { color: #f59e0b; }
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 18px;
        }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group label {
            font-size: 10px;
            font-weight: 600;
            color: #3a3a5a;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .form-group select, .form-group input {
            padding: 10px 14px;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 10px;
            color: #f0f0f5;
            font-size: 13px;
            font-family: 'Poppins', sans-serif;
            transition: all 0.2s;
        }
        .form-group select:focus, .form-group input:focus {
            outline: none;
            border-color: rgba(245,158,11,0.4);
            background: rgba(245,158,11,0.04);
        }
        .form-group select option { background: #1a1e2e; color: #f0f0f5; }
        .schedule-btn {
            padding: 13px 30px;
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 14px;
            font-family: 'Poppins', sans-serif;
            cursor: pointer;
            transition: all 0.25s;
            width: 100%;
            display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .schedule-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(245,158,11,0.3); }

        /* ── DATE NAV ── */
        .date-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 16px;
            padding: 14px 20px;
            margin-bottom: 20px;
            animation: fadeUp 0.5s 0.1s ease both;
        }
        .date-nav-btns { display: flex; gap: 8px; }
        .date-btn {
            padding: 7px 14px;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 9px;
            color: #c0c0d8;
            text-decoration: none;
            font-size: 12px;
            font-weight: 500;
            transition: all 0.2s;
            display: flex; align-items: center; gap: 6px;
        }
        .date-btn:hover { background: rgba(245,158,11,0.1); border-color: rgba(245,158,11,0.3); color: #f59e0b; }
        .date-label { font-size: 14px; font-weight: 700; color: #f0f0f5; display: flex; align-items: center; gap: 8px; }
        .date-label i { color: #f59e0b; }

        /* ── TABLE SECTIONS ── */
        .table-section {
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 20px;
            overflow: hidden;
            margin-bottom: 24px;
            animation: fadeUp 0.5s 0.15s ease both;
        }
        .table-section-header {
            padding: 16px 22px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
            font-size: 14px;
            font-weight: 700;
            color: #f0f0f5;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .table-section-header i { color: #f59e0b; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: rgba(255,255,255,0.04); border-bottom: 1px solid rgba(255,255,255,0.08); }
        th {
            padding: 12px 16px;
            text-align: left;
            font-size: 10px;
            font-weight: 700;
            color: #4a5278;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        td {
            padding: 13px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.04);
            font-size: 13px;
            color: #c0c0d8;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: rgba(245,158,11,0.04); }
        td strong { color: #f0f0f5; }

        /* ── STATUS BADGES ── */
        .status-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .status-scheduled  { background: rgba(59,130,246,0.15); color: #93c5fd; border: 1px solid rgba(59,130,246,0.25); }
        .status-completed  { background: rgba(16,185,129,0.15); color: #6ee7b7; border: 1px solid rgba(16,185,129,0.25); }
        .status-cancelled  { background: rgba(239,68,68,0.15);  color: #fca5a5; border: 1px solid rgba(239,68,68,0.25); }

        /* ── ACTION BUTTONS (admin only) ── */
        .action-btn {
            padding: 5px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 11px;
            font-weight: 600;
            margin: 0 3px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s;
        }
        .btn-reschedule { background: rgba(59,130,246,0.15); color: #93c5fd; border: 1px solid rgba(59,130,246,0.2); }
        .btn-reschedule:hover { background: rgba(59,130,246,0.25); }
        .btn-cancel     { background: rgba(239,68,68,0.15);  color: #fca5a5; border: 1px solid rgba(239,68,68,0.2); }
        .btn-cancel:hover { background: rgba(239,68,68,0.25); }
        .btn-complete   { background: rgba(16,185,129,0.15); color: #6ee7b7; border: 1px solid rgba(16,185,129,0.2); }
        .btn-complete:hover { background: rgba(16,185,129,0.25); }

        /* ── EMPTY STATE ── */
        .empty-state {
            text-align: center;
            padding: 48px 20px;
            color: #2a2a4a;
        }
        .empty-state i { font-size: 40px; margin-bottom: 12px; display: block; color: #1a1a3a; }
        .empty-state p { font-size: 14px; margin-bottom: 4px; color: #3a3a5a; }
        .empty-state span { font-size: 12px; color: #2a2a4a; }

        /* ── FOOTER ── */
        .footer {
            text-align: center;
            padding: 14px;
            color: #1a1a2a;
            font-size: 11px;
            border-top: 1px solid rgba(255,255,255,0.03);
            background: #07090f;
        }

        @keyframes fadeUp { from{opacity:0;transform:translateY(16px);} to{opacity:1;transform:translateY(0);} }

        @media (max-width: 768px) {
            .main-wrap { padding: 16px; }
            .page-hero { flex-direction: column; gap: 16px; text-align: center; }
            .form-grid { grid-template-columns: 1fr; }
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
        <a href="<%= request.getContextPath() %>/students" class="nl"><i class="fas fa-user-graduate"></i><span>Students</span></a>
        <a href="<%= request.getContextPath() %>/instructors" class="nl"><i class="fas fa-chalkboard-teacher"></i><span>Instructors</span></a>
        <a href="<%= request.getContextPath() %>/vehicles" class="nl"><i class="fas fa-car"></i><span>Vehicles</span></a>
        <a href="<%= request.getContextPath() %>/lessons" class="nl active"><i class="fas fa-calendar-check"></i><span>Lessons</span></a>
        <a href="<%= request.getContextPath() %>/tests" class="nl"><i class="fas fa-clipboard-list"></i><span>Tests</span></a>
        <a href="<%= request.getContextPath() %>/payments" class="nl"><i class="fas fa-money-bill-wave"></i><span>Payments</span></a>
        <% } else if (isInstructor) { %>
        <a href="<%= request.getContextPath() %>/lessons" class="nl active"><i class="fas fa-calendar-check"></i><span>My Lessons</span></a>
        <a href="<%= request.getContextPath() %>/tests" class="nl"><i class="fas fa-clipboard-list"></i><span>My Tests</span></a>
        <% } else { %>
        <a href="<%= request.getContextPath() %>/lessons" class="nl active"><i class="fas fa-calendar-check"></i><span>My Lessons</span></a>
        <a href="<%= request.getContextPath() %>/tests" class="nl"><i class="fas fa-clipboard-list"></i><span>My Tests</span></a>
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
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson scheduled successfully!</div>
    <% } else if ("cancelled".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson cancelled successfully!</div>
    <% } else if ("completed".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson marked as completed!</div>
    <% } else if ("rescheduled".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lesson rescheduled successfully!</div>
    <% } else if ("conflict".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Schedule conflict! The instructor or vehicle is not available at this time.</div>
    <% } %>

    <!-- Page Hero -->
    <div class="page-hero">
        <div>
            <div class="hero-title">
                <i class="fas fa-calendar-alt" style="color:#f59e0b; margin-right:8px;"></i>
                <%= isAdmin ? "Lesson <span>Scheduling</span>" : "My <span>Lessons</span>" %>
            </div>
            <div class="hero-sub">
                <%= isAdmin ? "Manage and schedule all driving lessons" : "View your upcoming and today's driving lessons" %>
            </div>
        </div>
        <div class="hero-icon"><i class="fas fa-calendar-check"></i></div>
    </div>

    <!-- ── ADMIN ONLY: Booking Form ── -->
    <% if (isAdmin) { %>
    <div class="booking-section">
        <div class="section-header"><i class="fas fa-plus-circle"></i> Quick Book a Lesson</div>
        <form action="<%= request.getContextPath() %>/lessons" method="post">
            <input type="hidden" name="action" value="add">
            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-user-graduate"></i> Student Name *</label>
                    <select name="studentId" required>
                        <option value="">-- Select Student --</option>
                        <% if (students != null) { for (Student s : students) { %>
                        <option value="<%= s.getStudentId() %>"><%= s.getName() %> (<%= s.getStudentId() %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-chalkboard-teacher"></i> Instructor Name *</label>
                    <select name="instructorId" id="instructorSelect" required>
                        <option value="">-- Select Instructor --</option>
                        <% if (instructors != null) { for (Instructor ins : instructors) { %>
                        <option value="<%= ins.getInstructorId() %>"><%= ins.getName() %> (<%= ins.getSpecialization() %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-car"></i> Vehicle *</label>
                    <select name="vehicleId" id="vehicleSelect" required>
                        <option value="">-- Select Vehicle --</option>
                        <% if (vehicles != null) { for (Vehicle v : vehicles) { %>
                        <option value="<%= v.getVehicleId() %>" data-transmission="<%= v.getTransmissionType() %>">
                            <%= v.getRegistrationNumber() %> - <%= v.getVehicleModel() %> (<%= v.getTransmissionType() %>)
                        </option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-calendar"></i> Lesson Date *</label>
                    <input type="date" name="lessonDate" min="<%= LocalDate.now().toString() %>" required>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-clock"></i> Lesson Time *</label>
                    <select name="lessonTime" required>
                        <option value="">-- Select Time --</option>
                        <option value="09:00">09:00 AM</option>
                        <option value="10:00">10:00 AM</option>
                        <option value="11:00">11:00 AM</option>
                        <option value="13:00">01:00 PM</option>
                        <option value="14:00">02:00 PM</option>
                        <option value="15:00">03:00 PM</option>
                        <option value="16:00">04:00 PM</option>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-hourglass-half"></i> Duration *</label>
                    <select name="duration" required>
                        <option value="1">1 Hour</option>
                        <option value="2">2 Hours</option>
                    </select>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-chart-line"></i> Lesson Type *</label>
                    <select name="lessonType" required>
                        <option value="Regular">Regular</option>
                        <option value="Intensive">Intensive</option>
                        <option value="Refresher">Refresher</option>
                    </select>
                </div>
            </div>
            <button type="submit" class="schedule-btn">
                <i class="fas fa-calendar-plus"></i> Schedule Lesson
            </button>
        </form>
    </div>
    <% } %>

    <!-- Date Navigation -->
    <div class="date-nav">
        <div class="date-nav-btns">
            <a href="<%= request.getContextPath() %>/lessons?date=<%= currentDate.minusDays(1).toString() %>" class="date-btn">
                <i class="fas fa-chevron-left"></i> Previous Day
            </a>
            <a href="<%= request.getContextPath() %>/lessons" class="date-btn">
                <i class="fas fa-calendar-day"></i> Today
            </a>
            <a href="<%= request.getContextPath() %>/lessons?date=<%= currentDate.plusDays(1).toString() %>" class="date-btn">
                Next Day <i class="fas fa-chevron-right"></i>
            </a>
        </div>
        <div class="date-label">
            <i class="fas fa-calendar-alt"></i>
            <%= currentDate.format(displayFormatter) %>
        </div>
    </div>

    <!-- Today's Lessons -->
    <div class="table-section">
        <div class="table-section-header">
            <i class="fas fa-clock"></i>
            <%= isAdmin ? "Scheduled Lessons for Today" : "My Lessons for Today" %>
        </div>
        <table>
            <thead>
            <tr>
                <th>Time</th>
                <% if (isAdmin) { %><th>Student</th><% } %>
                <% if (isInstructor) { %><th>Student</th><% } %>
                <th>Instructor</th>
                <th>Vehicle</th>
                <th>Duration</th>
                <th>Type</th>
                <th>Status</th>
                <% if (isAdmin) { %><th>Actions</th><% } %>
            </tr>
            </thead>
            <tbody>
            <% if (lessons != null && !lessons.isEmpty()) {
                for (Lesson lesson : lessons) { %>
            <tr>
                <td><strong><%= lesson.getLessonTime() %></strong></td>
                <% if (isAdmin || isInstructor) { %><td><%= lesson.getStudentName() %></td><% } %>
                <td><%= lesson.getInstructorName() %></td>
                <td><%= lesson.getVehicleDisplay() %></td>
                <td><%= lesson.getDuration() %> hour(s)</td>
                <td><%= lesson.getLessonType() %></td>
                <td>
                    <span class="status-badge status-<%= lesson.getStatus().toLowerCase() %>">
                        <%= lesson.getStatus() %>
                    </span>
                </td>
                <% if (isAdmin) { %>
                <td>
                    <% if ("Scheduled".equals(lesson.getStatus())) { %>
                    <a href="<%= request.getContextPath() %>/lessons?action=reschedule&id=<%= lesson.getLessonId() %>" class="action-btn btn-reschedule">
                        <i class="fas fa-calendar-alt"></i> Reschedule
                    </a>
                    <a href="<%= request.getContextPath() %>/lessons?action=cancel&id=<%= lesson.getLessonId() %>" class="action-btn btn-cancel"
                       onclick="return confirm('Are you sure you want to cancel this lesson?')">
                        <i class="fas fa-times-circle"></i> Cancel
                    </a>
                    <% } else if ("Completed".equals(lesson.getStatus())) { %>
                    <span style="color:#6ee7b7; font-size:12px;"><i class="fas fa-check-circle"></i> Completed</span>
                    <% } else { %>
                    <span style="color:#fca5a5; font-size:12px;"><i class="fas fa-ban"></i> Cancelled</span>
                    <% } %>
                </td>
                <% } %>
            </tr>
            <% } } else { %>
            <tr>
                <td colspan="<%= isAdmin ? 8 : (isInstructor ? 6 : 5) %>">
                    <div class="empty-state">
                        <i class="fas fa-calendar-day"></i>
                        <p>No lessons scheduled for this day</p>
                        <% if (!isAdmin) { %><span><%= isInstructor ? "No lessons assigned to you today" : "Your admin will schedule lessons for you" %></span><% } %>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <!-- Upcoming Lessons -->
    <div class="table-section" style="animation-delay:0.2s;">
        <div class="table-section-header">
            <i class="fas fa-calendar-week"></i>
            <%= isAdmin ? "Upcoming Lessons" : "My Upcoming Lessons" %>
        </div>
        <table>
            <thead>
            <tr>
                <th>Date</th>
                <th>Time</th>
                <% if (isAdmin || isInstructor) { %><th>Student</th><% } %>
                <th>Instructor</th>
                <th>Vehicle</th>
                <th>Type</th>
                <% if (isAdmin) { %><th>Actions</th><% } %>
            </tr>
            </thead>
            <tbody>
            <% if (upcomingLessons != null && !upcomingLessons.isEmpty()) {
                for (Lesson lesson : upcomingLessons) { %>
            <tr>
                <td><%= lesson.getLessonDate() %></td>
                <td><strong><%= lesson.getLessonTime() %></strong></td>
                <% if (isAdmin || isInstructor) { %><td><%= lesson.getStudentName() %></td><% } %>
                <td><%= lesson.getInstructorName() %></td>
                <td><%= lesson.getVehicleDisplay() %></td>
                <td><%= lesson.getLessonType() %></td>
                <% if (isAdmin) { %>
                <td>
                    <a href="<%= request.getContextPath() %>/lessons?action=reschedule&id=<%= lesson.getLessonId() %>" class="action-btn btn-reschedule">
                        <i class="fas fa-calendar-alt"></i> Reschedule
                    </a>
                    <a href="<%= request.getContextPath() %>/lessons?action=cancel&id=<%= lesson.getLessonId() %>" class="action-btn btn-cancel"
                       onclick="return confirm('Are you sure you want to cancel this lesson?')">
                        <i class="fas fa-times-circle"></i> Cancel
                    </a>
                </td>
                <% } %>
            </tr>
            <% } } else { %>
            <tr>
                <td colspan="<%= isAdmin ? 7 : (isInstructor ? 6 : 5) %>">
                    <div class="empty-state">
                        <i class="fas fa-calendar-week"></i>
                        <p>No upcoming lessons scheduled</p>
                        <% if (!isAdmin) { %><span><%= isInstructor ? "No upcoming lessons assigned to you" : "Check back later for your upcoming lessons" %></span><% } %>
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

<% if (isAdmin) { %>
<script>
    const instructorSelect = document.getElementById('instructorSelect');
    const vehicleSelect = document.getElementById('vehicleSelect');

    function filterVehicles() {
        const selectedInstructor = instructorSelect.options[instructorSelect.selectedIndex];
        const instructorSpecialization = selectedInstructor.text.includes('Manual') ? 'Manual' :
            selectedInstructor.text.includes('Automatic') ? 'Automatic' : 'Both';

        for (let i = 0; i < vehicleSelect.options.length; i++) {
            const option = vehicleSelect.options[i];
            if (option.value === "") continue;
            const transmission = option.getAttribute('data-transmission');
            if (instructorSpecialization === 'Both') {
                option.style.display = ''; option.disabled = false;
            } else if (transmission === instructorSpecialization) {
                option.style.display = ''; option.disabled = false;
            } else {
                option.style.display = 'none'; option.disabled = true;
            }
        }
        if (vehicleSelect.options[vehicleSelect.selectedIndex].disabled) vehicleSelect.value = "";
    }

    instructorSelect.addEventListener('change', filterVehicles);
</script>
<% } %>

</body>
</html>
