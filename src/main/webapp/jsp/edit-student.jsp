<%@ page import="model.Student" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Student student = (Student) request.getAttribute("student");
    String error = request.getParameter("error");
    boolean isAdd = (student == null);
    String ctx = request.getContextPath();
    String __role = (session != null && session.getAttribute("userRole") != null)
            ? session.getAttribute("userRole").toString() : "";
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title><%= isAdd ? "Add Student" : "Edit Student" %> — DriveMaster</title>
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
        .form-err{font-size:11px;color:#fca5a5;margin-top:3px;display:none}
        .form-input.err{border-color:rgba(239,68,68,.5)}
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
        <% if ("admin".equalsIgnoreCase(__role)) { %>
        <a href="<%= ctx %>/students"    class="nl active"><i class="fas fa-user-graduate"></i><span>Students</span></a>
        <a href="<%= ctx %>/instructors" class="nl"><i class="fas fa-chalkboard-teacher"></i><span>Instructors</span></a>
        <a href="<%= ctx %>/vehicles"    class="nl"><i class="fas fa-car"></i><span>Vehicles</span></a>
        <a href="<%= ctx %>/lessons"     class="nl"><i class="fas fa-calendar-check"></i><span>Lessons</span></a>
        <a href="<%= ctx %>/payments"    class="nl"><i class="fas fa-money-bill-wave"></i><span>Payments</span></a>
        <a href="<%= ctx %>/tests"       class="nl"><i class="fas fa-clipboard-list"></i><span>Tests</span></a>
        <% } else { %>
        <a href="<%= ctx %>/lessons"  class="nl"><i class="fas fa-calendar-check"></i><span>My Lessons</span></a>
        <a href="<%= ctx %>/tests"    class="nl"><i class="fas fa-clipboard-list"></i><span>My Tests</span></a>
        <a href="<%= ctx %>/payments" class="nl"><i class="fas fa-money-bill-wave"></i><span>My Payments</span></a>
        <% } %>
    </div>
    <div class="topbar-right">
        <button class="theme-btn" id="themeBtn" title="Toggle theme"><i class="fas fa-moon" id="themeIcon"></i></button>
        <a href="<%= ctx %>/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</nav>

<div class="page">
    <div class="page-header">
        <div class="page-title">
            <i class="fas fa-user-graduate" style="color:var(--blue)"></i>
            <%= isAdd ? "Add Student" : "Edit Student" %>
        </div>
        <a href="<%= ctx %>/students" class="btn btn-ghost"><i class="fas fa-arrow-left"></i> Back</a>
    </div>

    <% if ("empty".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please fill in all required fields.</div>
    <% } else if ("age".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Age must be a valid number between 16 and 100.</div>
    <% } else if ("usernameExists".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Username already taken.</div>
    <% } %>

    <div class="form-card">
        <form id="studentForm" action="<%= ctx %>/students" method="post">
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %><input type="hidden" name="studentId" value="<%= student.getStudentId() %>"><% } %>

            <div class="section-title"><i class="fas fa-user"></i> Personal Information</div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Student ID</label>
                    <input type="text" class="form-input" value="<%= isAdd ? "Auto-generated" : student.getStudentId() %>" readonly>
                </div>
                <div class="form-group">
                    <label class="form-label">Full Name <span>*</span></label>
                    <input type="text" id="name" name="name" class="form-input" placeholder="Full name"
                           value="<%= isAdd ? "" : student.getName() %>" required>
                    <div class="form-err" id="nameErr"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">NIC Number <span>*</span></label>
                    <input type="text" id="nic" name="nic" class="form-input" placeholder="123456789V or 200012345678"
                           value="<%= isAdd ? "" : student.getNic() %>" maxlength="12" required>
                    <div class="form-hint">9 digits + V (old) or 12 digits (new)</div>
                    <div class="form-err" id="nicErr"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone <span>*</span></label>
                    <input type="tel" id="phone" name="phone" class="form-input" placeholder="0712345678"
                           value="<%= isAdd ? "" : student.getPhone() %>" maxlength="10" required>
                    <div class="form-hint">10 digits starting with 07</div>
                    <div class="form-err" id="phoneErr"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Email <span>*</span></label>
                    <input type="email" id="email" name="email" class="form-input" placeholder="student@example.com"
                           value="<%= isAdd ? "" : student.getEmail() %>" required>
                    <div class="form-err" id="emailErr"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Gender <span>*</span></label>
                    <select id="gender" name="gender" class="form-select" required>
                        <option value="">— Select —</option>
                        <option value="Male"   <%= !isAdd && "Male".equals(student.getGender())   ? "selected" : "" %>>Male</option>
                        <option value="Female" <%= !isAdd && "Female".equals(student.getGender()) ? "selected" : "" %>>Female</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Age <span>*</span></label>
                    <input type="number" id="age" name="age" class="form-input" placeholder="Age (min 16)"
                           value="<%= isAdd ? "" : student.getAge() %>" min="16" max="100" required>
                    <div class="form-err" id="ageErr"></div>
                </div>
                <div class="form-group full">
                    <label class="form-label">Address <span>*</span></label>
                    <textarea id="address" name="address" class="form-textarea" placeholder="Residential address" required><%= isAdd ? "" : student.getAddress() %></textarea>
                </div>
            </div>

            <div class="section-title"><i class="fas fa-graduation-cap"></i> Course Details</div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">License Type <span>*</span></label>
                    <select name="licenseType" class="form-select" required>
                        <option value="">— Select —</option>
                        <option value="Heavy Vehicle" <%= !isAdd && "Heavy Vehicle".equals(student.getLicenseType()) ? "selected" : "" %>>Heavy Vehicle</option>
                        <option value="Light Vehicle" <%= !isAdd && "Light Vehicle".equals(student.getLicenseType()) ? "selected" : "" %>>Light Vehicle</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Course Package <span>*</span></label>
                    <select name="coursePackage" class="form-select" required>
                        <option value="">— Select —</option>
                        <option value="Basic"    <%= !isAdd && "Basic".equals(student.getCoursePackage())    ? "selected" : "" %>>Basic</option>
                        <option value="Standard" <%= !isAdd && "Standard".equals(student.getCoursePackage()) ? "selected" : "" %>>Standard</option>
                        <option value="Premium"  <%= !isAdd && "Premium".equals(student.getCoursePackage())  ? "selected" : "" %>>Premium</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Registration Date <span>*</span></label>
                    <input type="date" id="regDate" name="registrationDate" class="form-input"
                           value="<%= isAdd ? "" : student.getRegistrationDate() %>" required>
                    <div class="form-err" id="dateErr"></div>
                </div>
            </div>

            <div class="section-title"><i class="fas fa-key"></i> Login Credentials</div>
            <div class="form-grid">
                <% if (isAdd) { %>
                <div class="form-group">
                    <label class="form-label">Username <span>*</span></label>
                    <input type="text" id="username" name="username" class="form-input" placeholder="Login username" required>
                </div>
                <% } %>
                <div class="form-group">
                    <label class="form-label">Password <span><%= isAdd ? "*" : "" %></span> <%= !isAdd ? "<small style='font-weight:400;text-transform:none'>(leave blank to keep)</small>" : "" %></label>
                    <input type="password" id="password" name="password" class="form-input"
                           placeholder="<%= isAdd ? "Min 6 characters" : "Leave blank to keep current" %>"
                        <%= isAdd ? "required" : "" %>>
                    <div class="form-err" id="passErr"></div>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> <%= isAdd ? "Register Student" : "Update Student" %>
                </button>
                <a href="<%= ctx %>/students" class="btn btn-ghost"><i class="fas fa-times"></i> Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
    (function(){
        /* Theme toggle */
        var h=document.documentElement,b=document.getElementById("themeBtn"),ic=document.getElementById("themeIcon");
        var t=localStorage.getItem("dm-theme")||"dark";
        h.setAttribute("data-theme",t);ic.className=t==="dark"?"fas fa-moon":"fas fa-sun";
        b.addEventListener("click",function(){
            var n=h.getAttribute("data-theme")==="dark"?"light":"dark";
            h.setAttribute("data-theme",n);localStorage.setItem("dm-theme",n);
            ic.className=n==="dark"?"fas fa-moon":"fas fa-sun";
        });

        /* Set today as max & default for reg date */
        var today=new Date().toISOString().split("T")[0];
        var rd=document.getElementById("regDate");
        if(rd){rd.max=today; <% if(isAdd){%>rd.value=today;<% } %>}

        /* Helpers */
        function showErr(id,msg){var e=document.getElementById(id);if(e){e.textContent=msg;e.style.display=msg?"block":"none";}}
        function clearErr(id){showErr(id,"");}

        /* NIC */
        var nic=document.getElementById("nic");
        if(nic){nic.addEventListener("input",function(){this.value=this.value.replace(/[^0-9Vv]/g,"").slice(0,12);});
            nic.addEventListener("blur",function(){var v=this.value;if(v&&!/^[0-9]{9}[Vv]$|^[0-9]{12}$/.test(v))showErr("nicErr","Invalid NIC format");else clearErr("nicErr");});}

        /* Phone */
        var ph=document.getElementById("phone");
        if(ph){ph.addEventListener("input",function(){this.value=this.value.replace(/\D/g,"").slice(0,10);});
            ph.addEventListener("blur",function(){var v=this.value;if(v&&!/^07[0-9]{8}$/.test(v))showErr("phoneErr","Must be 10 digits starting with 07");else clearErr("phoneErr");});}

        /* Age */
        var age=document.getElementById("age");
        if(age)age.addEventListener("blur",function(){var v=parseInt(this.value);if(this.value&&(isNaN(v)||v<16||v>100))showErr("ageErr","Age must be between 16 and 100");else clearErr("ageErr");});

        /* Email */
        var em=document.getElementById("email");
        if(em)em.addEventListener("blur",function(){var v=this.value;if(v&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v))showErr("emailErr","Enter a valid email address");else clearErr("emailErr");});

        /* Name */
        var nm=document.getElementById("name");
        if(nm)nm.addEventListener("blur",function(){var v=this.value.trim();if(v&&v.length<3)showErr("nameErr","Name must be at least 3 characters");else clearErr("nameErr");});

        /* Date */
        if(rd)rd.addEventListener("change",function(){if(this.value>today)showErr("dateErr","Cannot be a future date");else clearErr("dateErr");});
    })();
</script>
</body>
</html>
