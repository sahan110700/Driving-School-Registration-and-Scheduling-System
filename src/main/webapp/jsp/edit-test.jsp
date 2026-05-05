<%@ page import="model.Test" %>
<%@ page import="model.Student" %>
<%@ page import="model.Instructor" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Test test = (Test) request.getAttribute("test");
    List<Student> students = (List<Student>) request.getAttribute("students");
    List<Instructor> examiners = (List<Instructor>) request.getAttribute("examiners");
    String error = request.getParameter("error");
    boolean isAdd = (test == null);
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title><%= isAdd ? "Schedule Test" : "Edit Test" %> — DriveMaster</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{--bg:#0a0c14;--bg2:#111420;--bg3:#181c2c;--border:rgba(255,255,255,0.07);--border2:rgba(255,255,255,0.11);--text:#f0f2ff;--text2:#8b93b8;--text3:#4a5278;--accent:#f59e0b;--accent2:#ef4444;--blue:#3b82f6;--green:#10b981;--purple:#8b5cf6;--shadow:0 8px 32px rgba(0,0,0,0.4);--nav-h:60px}
        [data-theme="light"]{--bg:#f0f2fa;--bg2:#ffffff;--bg3:#e8eaf4;--border:rgba(0,0,0,0.07);--border2:rgba(0,0,0,0.13);--text:#0d0f1a;--text2:#4a5278;--text3:#9ba3c8;--shadow:0 8px 32px rgba(0,0,0,0.07)}
        *,*::before,*::after{margin:0;padding:0;box-sizing:border-box}
        html,body{font-family:'Inter',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;transition:background .25s,color .25s}
        .topbar{position:sticky;top:0;z-index:300;height:var(--nav-h);display:flex;align-items:center;justify-content:space-between;padding:0 28px;gap:12px;background:rgba(10,12,20,.97);border-bottom:1px solid var(--border);backdrop-filter:blur(22px)}
        [data-theme="light"] .topbar{background:rgba(255,255,255,.97)}
        .brand{display:flex;align-items:center;gap:10px;text-decoration:none;flex-shrink:0}
        .brand-logo{width:38px;height:38px;border-radius:10px;background:linear-gradient(135deg,var(--accent),var(--accent2));display:flex;align-items:center;justify-content:center;font-size:17px;color:#fff;box-shadow:0 3px 10px rgba(245,158,11,.28)}
        .brand-name{font-size:16px;font-weight:800;color:var(--text);line-height:1.1}.brand-name span{color:var(--accent)}
        .brand-sub{font-size:8.5px;color:var(--text3);text-transform:uppercase;letter-spacing:2px}
        .nav-links{display:flex;gap:2px;flex:1;justify-content:center}
        .nl{display:flex;align-items:center;gap:5px;padding:7px 11px;border-radius:9px;font-size:12px;font-weight:500;color:var(--text3);text-decoration:none;transition:all .18s;white-space:nowrap}
        .nl i{font-size:12px}.nl:hover{background:rgba(245,158,11,.08);color:var(--accent)}.nl.active{background:rgba(245,158,11,.12);color:var(--accent);font-weight:600}
        .topbar-right{display:flex;align-items:center;gap:8px;flex-shrink:0}
        .theme-btn{width:35px;height:35px;border-radius:9px;border:1px solid var(--border2);background:var(--bg3);color:var(--text2);cursor:pointer;font-size:13px;display:flex;align-items:center;justify-content:center;transition:all .2s}
        .theme-btn:hover{color:var(--accent);border-color:rgba(245,158,11,.3)}
        .logout-btn{display:flex;align-items:center;gap:7px;padding:8px 15px;border-radius:10px;background:linear-gradient(135deg,var(--accent2),#c21b1b);color:#fff;text-decoration:none;font-size:12px;font-weight:600;transition:all .2s}
        .logout-btn:hover{transform:translateY(-1px);box-shadow:0 5px 16px rgba(239,68,68,.35)}
        .page{max-width:900px;margin:0 auto;padding:32px 24px 60px}
        .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;animation:fadeUp .45s ease both}
        .page-title{font-size:22px;font-weight:800;color:var(--text);display:flex;align-items:center;gap:10px}
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:10px;font-size:13px;font-weight:600;font-family:'Inter',sans-serif;cursor:pointer;text-decoration:none;border:none;transition:all .2s}
        .btn-primary{background:linear-gradient(135deg,var(--accent),var(--accent2));color:#fff}
        .btn-primary:hover{transform:translateY(-2px);box-shadow:0 8px 22px rgba(245,158,11,.32)}
        .btn-ghost{background:var(--bg3);color:var(--text2);border:1px solid var(--border2)}
        .btn-ghost:hover{color:var(--accent);border-color:rgba(245,158,11,.3)}
        .alert{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:11px;margin-bottom:18px;font-size:13px;font-weight:500;animation:fadeUp .4s ease both}
        .alert-error{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.25);color:#fca5a5}
        .guide-box{background:rgba(139,92,246,.07);border:1px solid rgba(139,92,246,.2);border-radius:12px;padding:14px 16px;margin-bottom:18px;font-size:12.5px;color:var(--text2);line-height:1.6;animation:fadeUp .4s ease both}
        .guide-box strong{color:var(--purple)}
        .guide-box ul{margin-top:6px;margin-left:18px}
        .form-card{background:var(--bg2);border:1px solid var(--border);border-radius:18px;padding:28px;box-shadow:var(--shadow);animation:fadeUp .5s ease .05s both}
        .section-title{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1.5px;color:var(--accent);padding-bottom:10px;margin-bottom:16px;margin-top:22px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:7px}
        .section-title:first-child{margin-top:0}
        .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
        .form-group{display:flex;flex-direction:column;gap:5px}
        .form-group.full{grid-column:span 2}
        .form-label{font-size:10.5px;font-weight:600;color:var(--text2);text-transform:uppercase;letter-spacing:.7px}
        .form-label span{color:var(--accent2)}
        .form-input,.form-select,.form-textarea{padding:11px 13px;background:var(--bg);border:1px solid var(--border2);border-radius:10px;color:var(--text);font-size:13.5px;font-family:'Inter',sans-serif;outline:none;width:100%;transition:border-color .2s,box-shadow .2s}
        .form-input:focus,.form-select:focus,.form-textarea:focus{border-color:rgba(245,158,11,.45);box-shadow:0 0 0 3px rgba(245,158,11,.07)}
        .form-input::placeholder,.form-textarea::placeholder{color:var(--text3)}
        .form-input[readonly]{opacity:.55;cursor:not-allowed}
        .form-select option{background:var(--bg2)}
        .form-textarea{resize:vertical;min-height:80px}
        .form-hint{font-size:11px;color:var(--text3);margin-top:3px}
        .form-err{font-size:11px;color:#fca5a5;margin-top:3px}
        .form-actions{display:flex;gap:12px;margin-top:24px;padding-top:20px;border-top:1px solid var(--border)}
        @keyframes fadeUp{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:translateY(0)}}
        @media(max-width:800px){.topbar{padding:0 14px}.nav-links{display:none}.page{padding:18px 12px 50px}.form-grid{grid-template-columns:1fr}.form-group.full{grid-column:span 1}.page-header{flex-direction:column;align-items:flex-start;gap:10px}}
    </style>
</head>
<body>
<nav class="topbar">
    <a href="<%= ctx %>/home" class="brand">
        <div class="brand-logo"><i class="fas fa-car"></i></div>
        <div><div class="brand-name">Drive<span>Master</span></div><div class="brand-sub">Driving Academy</div></div>
    </a>
    <div class="nav-links">
        <a href="<%= ctx %>/students"    class="nl"><i class="fas fa-user-graduate"></i><span>Students</span></a>
        <a href="<%= ctx %>/instructors" class="nl"><i class="fas fa-chalkboard-teacher"></i><span>Instructors</span></a>
        <a href="<%= ctx %>/vehicles"    class="nl"><i class="fas fa-car"></i><span>Vehicles</span></a>
        <a href="<%= ctx %>/lessons"     class="nl"><i class="fas fa-calendar-check"></i><span>Lessons</span></a>
        <a href="<%= ctx %>/payments"    class="nl"><i class="fas fa-money-bill-wave"></i><span>Payments</span></a>
        <a href="<%= ctx %>/tests"       class="nl active"><i class="fas fa-clipboard-list"></i><span>Tests</span></a>
    </div>
    <div class="topbar-right">
        <button class="theme-btn" id="themeBtn" title="Toggle theme"><i class="fas fa-moon" id="themeIcon"></i></button>
        <a href="<%= ctx %>/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</nav>

<div class="page">
    <div class="page-header">
        <div class="page-title">
            <i class="fas fa-clipboard-list" style="color:var(--purple)"></i>
            <%= isAdd ? "Schedule Test" : "Edit Test" %>
        </div>
        <a href="<%= ctx %>/tests" class="btn btn-ghost"><i class="fas fa-arrow-left"></i> Back</a>
    </div>

    <% if ("empty".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please fill in all required fields.</div>
    <% } else if ("conflict".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Schedule conflict — examiner or student is not available at this time.</div>
    <% } else if ("invalidTime".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Test time must be between 8:00 AM and 5:00 PM.</div>
    <% } else if ("pastDate".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Test date cannot be in the past.</div>
    <% } %>

    <div class="guide-box">
        <strong><i class="fas fa-info-circle"></i> Test Guidelines</strong>
        <ul>
            <li>Available Monday to Friday, 8:00 AM – 5:00 PM</li>
            <li>Each test takes approximately 1 hour</li>
            <li>Examiner must be available during the selected time</li>
            <li>Students can only take one test per day</li>
        </ul>
    </div>

    <div class="form-card">
        <form id="testForm" action="<%= ctx %>/tests" method="post">
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %><input type="hidden" name="testId" value="<%= test.getTestId() %>"><% } %>

            <div class="section-title"><i class="fas fa-user-graduate"></i> Test Details</div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Test ID</label>
                    <input type="text" class="form-input" value="<%= isAdd ? "Auto-generated" : test.getTestId() %>" readonly>
                </div>
                <div class="form-group">
                    <label class="form-label">Student <span>*</span></label>
                    <select id="studentSelect" name="studentId" class="form-select" required>
                        <option value="">— Select Student —</option>
                        <% if (students != null) { for (Student s : students) { %>
                        <option value="<%= s.getStudentId() %>"
                                <%= !isAdd && s.getStudentId().equals(test.getStudentId()) ? "selected" : "" %>>
                            <%= s.getName() %> — <%= s.getCoursePackage() %>
                        </option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Test Type <span>*</span></label>
                    <select id="testType" name="testType" class="form-select" required>
                        <option value="">— Select Type —</option>
                        <option value="Theory Test"    <%= !isAdd && "Theory Test".equals(test.getTestType())    ? "selected" : "" %>>Theory Test</option>
                        <option value="Practical Test" <%= !isAdd && "Practical Test".equals(test.getTestType()) ? "selected" : "" %>>Practical Test</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Examiner <span>*</span></label>
                    <select id="examinerSelect" name="examinerId" class="form-select" required>
                        <option value="">— Select Examiner —</option>
                        <% if (examiners != null) { for (Instructor ex : examiners) { %>
                        <option value="<%= ex.getInstructorId() %>"
                                <%= !isAdd && ex.getInstructorId().equals(test.getExaminerId()) ? "selected" : "" %>>
                            <%= ex.getName() %> — <%= ex.getSpecialization() %> (<%= ex.getAvailability() %>)
                        </option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Test Date <span>*</span></label>
                    <input type="date" id="testDate" name="testDate" class="form-input"
                           value="<%= isAdd ? "" : test.getTestDate() %>"
                           min="<%= LocalDate.now().toString() %>" required>
                    <div class="form-err" id="dateError"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Test Time <span>*</span></label>
                    <select name="testTime" class="form-select" required>
                        <option value="">— Select Time —</option>
                        <option value="09:00" <%= !isAdd && "09:00".equals(test.getTestTime()) ? "selected" : "" %>>09:00 AM</option>
                        <option value="10:00" <%= !isAdd && "10:00".equals(test.getTestTime()) ? "selected" : "" %>>10:00 AM</option>
                        <option value="11:00" <%= !isAdd && "11:00".equals(test.getTestTime()) ? "selected" : "" %>>11:00 AM</option>
                        <option value="13:00" <%= !isAdd && "13:00".equals(test.getTestTime()) ? "selected" : "" %>>01:00 PM</option>
                        <option value="14:00" <%= !isAdd && "14:00".equals(test.getTestTime()) ? "selected" : "" %>>02:00 PM</option>
                        <option value="15:00" <%= !isAdd && "15:00".equals(test.getTestTime()) ? "selected" : "" %>>03:00 PM</option>
                        <option value="16:00" <%= !isAdd && "16:00".equals(test.getTestTime()) ? "selected" : "" %>>04:00 PM</option>
                    </select>
                    <div class="form-hint">Available: 9:00 AM – 4:00 PM</div>
                </div>
                <div class="form-group full">
                    <label class="form-label">Notes <small style="font-weight:400;text-transform:none">(optional)</small></label>
                    <textarea name="notes" class="form-textarea" rows="3"
                              placeholder="Any special instructions or notes..."><%= !isAdd && test.getNotes() != null ? test.getNotes() : "" %></textarea>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-<%= isAdd ? "calendar-plus" : "save" %>"></i>
                    <%= isAdd ? "Schedule Test" : "Update Test" %>
                </button>
                <a href="<%= ctx %>/tests" class="btn btn-ghost"><i class="fas fa-times"></i> Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
    (function(){
        // Theme toggle
        var h=document.documentElement,b=document.getElementById("themeBtn"),ic=document.getElementById("themeIcon");
        var t=localStorage.getItem("dm-theme")||"dark";
        h.setAttribute("data-theme",t);ic.className=t==="dark"?"fas fa-moon":"fas fa-sun";
        b.addEventListener("click",function(){var n=h.getAttribute("data-theme")==="dark"?"light":"dark";h.setAttribute("data-theme",n);localStorage.setItem("dm-theme",n);ic.className=n==="dark"?"fas fa-moon":"fas fa-sun";});

        // Date validation
        var td=document.getElementById("testDate");
        if(td){
            td.min=new Date().toISOString().split("T")[0];
            td.addEventListener("change",function(){
                var e=document.getElementById("dateError");
                if(this.value<new Date().toISOString().split("T")[0]){e.textContent="Test date cannot be in the past";}
                else e.textContent="";
            });
        }

        // Form validation
        document.getElementById("testForm").addEventListener("submit",function(e){
            var td2=document.getElementById("testDate");
            if(td2&&td2.value<new Date().toISOString().split("T")[0]){e.preventDefault();alert("Test date cannot be in the past!");return;}
        });
    })();
</script>
</body>
</html>
