<%@ page import="java.util.List" %>
<%@ page import="model.Student" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    String error   = request.getParameter("error");
    String success = request.getParameter("success");
    String ctx = request.getContextPath();
    String __role = (session != null && session.getAttribute("userRole") != null)
            ? session.getAttribute("userRole").toString() : "";
    boolean isAdmin = "admin".equalsIgnoreCase(__role);
    if (!isAdmin) { response.sendRedirect(ctx + "/home"); return; }
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Students — DriveMaster</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{--bg:#0a0c14;--bg2:#111420;--bg3:#181c2c;--border:rgba(255,255,255,0.07);--border2:rgba(255,255,255,0.11);--text:#f0f2ff;--text2:#8b93b8;--text3:#4a5278;--accent:#f59e0b;--accent2:#ef4444;--blue:#3b82f6;--green:#10b981;--shadow:0 8px 32px rgba(0,0,0,0.4);--nav-h:60px}
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
        .page{max-width:1200px;margin:0 auto;padding:32px 24px 60px}
        .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;animation:fadeUp .45s ease both}
        .page-title{font-size:22px;font-weight:800;color:var(--text);display:flex;align-items:center;gap:10px}
        .page-sub{font-size:12px;color:var(--text3);margin-top:3px}
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:10px;font-size:13px;font-weight:600;font-family:'Inter',sans-serif;cursor:pointer;text-decoration:none;border:none;transition:all .2s}
        .btn-primary{background:linear-gradient(135deg,var(--accent),var(--accent2));color:#fff}
        .btn-primary:hover{transform:translateY(-2px);box-shadow:0 8px 22px rgba(245,158,11,.32)}
        .btn-sm{padding:6px 12px;font-size:12px;border-radius:8px}
        .btn-blue{background:rgba(59,130,246,.1);color:var(--blue);border:1px solid rgba(59,130,246,.22)}
        .btn-blue:hover{background:rgba(59,130,246,.18)}
        .btn-red{background:rgba(239,68,68,.1);color:var(--accent2);border:1px solid rgba(239,68,68,.22)}
        .btn-red:hover{background:rgba(239,68,68,.18)}
        .alert{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:11px;margin-bottom:18px;font-size:13px;font-weight:500;animation:fadeUp .4s ease both}
        .alert-error{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.25);color:#fca5a5}
        .alert-success{background:rgba(16,185,129,.1);border:1px solid rgba(16,185,129,.25);color:#6ee7b7}
        .card{background:var(--bg2);border:1px solid var(--border);border-radius:16px;overflow:hidden;box-shadow:var(--shadow);animation:fadeUp .5s ease both}
        .data-table{width:100%;border-collapse:collapse}
        .data-table th{padding:12px 16px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--text3);text-align:left;background:var(--bg3);border-bottom:1px solid var(--border)}
        .data-table td{padding:13px 16px;font-size:13px;border-bottom:1px solid var(--border);vertical-align:middle}
        .data-table tr:last-child td{border-bottom:none}
        .data-table tr:hover td{background:rgba(255,255,255,.02)}
        [data-theme="light"] .data-table tr:hover td{background:rgba(0,0,0,.02)}
        .actions{display:flex;gap:5px}
        .badge{display:inline-flex;align-items:center;gap:4px;padding:3px 9px;border-radius:20px;font-size:10.5px;font-weight:600}
        .badge-blue{background:rgba(59,130,246,.12);color:#93c5fd;border:1px solid rgba(59,130,246,.2)}
        .badge-green{background:rgba(16,185,129,.12);color:#6ee7b7;border:1px solid rgba(16,185,129,.2)}
        .badge-red{background:rgba(239,68,68,.12);color:#fca5a5;border:1px solid rgba(239,68,68,.2)}
        .badge-yellow{background:rgba(245,158,11,.12);color:#fcd34d;border:1px solid rgba(245,158,11,.2)}
        .empty-state{text-align:center;padding:60px 20px;color:var(--text3)}
        .empty-state i{font-size:44px;margin-bottom:16px;display:block;opacity:.4}
        .empty-state p{font-size:14px}
        .name-cell strong{font-size:14px;font-weight:600;color:var(--text)}
        @keyframes fadeUp{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:translateY(0)}}
        @media(max-width:800px){.topbar{padding:0 14px}.nav-links{display:none}.page{padding:18px 12px 50px}.page-header{flex-direction:column;align-items:flex-start;gap:10px}}
    </style>
</head>
<body>
<nav class="topbar">
    <a href="<%= ctx %>/home" class="brand">
        <div class="brand-logo"><i class="fas fa-car"></i></div>
        <div><div class="brand-name">Drive<span>Master</span></div><div class="brand-sub">Driving Academy</div></div>
    </a>
    <div class="nav-links">
        <a href="<%= ctx %>/students"    class="nl active"><i class="fas fa-user-graduate"></i><span>Students</span></a>
        <a href="<%= ctx %>/instructors" class="nl"><i class="fas fa-chalkboard-teacher"></i><span>Instructors</span></a>
        <a href="<%= ctx %>/vehicles"    class="nl"><i class="fas fa-car"></i><span>Vehicles</span></a>
        <a href="<%= ctx %>/lessons"     class="nl"><i class="fas fa-calendar-check"></i><span>Lessons</span></a>
        <a href="<%= ctx %>/payments"    class="nl"><i class="fas fa-money-bill-wave"></i><span>Payments</span></a>
        <a href="<%= ctx %>/tests"       class="nl"><i class="fas fa-clipboard-list"></i><span>Tests</span></a>
    </div>
    <div class="topbar-right">
        <button class="theme-btn" id="themeBtn" title="Toggle theme"><i class="fas fa-moon" id="themeIcon"></i></button>
        <a href="<%= ctx %>/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</nav>

<div class="page">
    <div class="page-header">
        <div>
            <div class="page-title"><i class="fas fa-user-graduate" style="color:var(--blue)"></i> Student Management</div>
            <div class="page-sub">Manage all student registrations and profiles</div>
        </div>
        <a href="<%= ctx %>/students?action=add-form" class="btn btn-primary"><i class="fas fa-plus"></i> Add Student</a>
    </div>

    <% if ("added".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Student added successfully!</div>
    <% } else if ("updated".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Student updated.</div>
    <% } else if ("deleted".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Student deleted.</div>
    <% } else if ("usernameExists".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Username already exists.</div>
    <% } else if ("empty".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please fill in all required fields.</div>
    <% } else if ("failed".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Action failed. Please try again.</div>
    <% } %>

    <div class="card">
        <% if (studentList != null && !studentList.isEmpty()) { %>
        <table class="data-table">
            <thead>
            <tr>
                <th>ID</th><th>Name</th><th>NIC</th><th>Phone</th>
                <th>Email</th><th>License</th><th>Package</th><th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% for (Student s : studentList) { %>
            <tr>
                <td><span class="badge badge-blue"><%= s.getStudentId() %></span></td>
                <td><div class="name-cell"><strong><%= s.getName() %></strong></div></td>
                <td style="font-size:12px;color:var(--text2)"><%= s.getNic() %></td>
                <td><%= s.getPhone() %></td>
                <td style="font-size:12px;color:var(--text2)"><%= s.getEmail() %></td>
                <td><span class="badge badge-green"><%= s.getLicenseType() %></span></td>
                <td><span class="badge badge-yellow"><%= s.getCoursePackage() %></span></td>
                <td><div class="actions">
                    <a href="<%= ctx %>/students?action=edit&id=<%= s.getStudentId() %>" class="btn btn-sm btn-blue"><i class="fas fa-pen"></i> Edit</a>
                    <a href="<%= ctx %>/students?action=delete&id=<%= s.getStudentId() %>" class="btn btn-sm btn-red"
                       onclick="return confirm('Delete this student?')"><i class="fas fa-trash"></i></a>
                </div></td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state"><i class="fas fa-user-graduate"></i><p>No students found.</p></div>
        <% } %>
    </div>
</div>

<script>
    (function(){
        var h=document.documentElement,b=document.getElementById("themeBtn"),ic=document.getElementById("themeIcon");
        var t=localStorage.getItem("dm-theme")||"dark";
        h.setAttribute("data-theme",t);ic.className=t==="dark"?"fas fa-moon":"fas fa-sun";
        b.addEventListener("click",function(){
            var n=h.getAttribute("data-theme")==="dark"?"light":"dark";
            h.setAttribute("data-theme",n);localStorage.setItem("dm-theme",n);
            ic.className=n==="dark"?"fas fa-moon":"fas fa-sun";
        });
    })();
</script>
</body>
</html>
