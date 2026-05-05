<%@ page import="model.Student" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Student> students = (List<Student>) request.getAttribute("students");
    String error = request.getParameter("error");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Record Payment — DriveMaster</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{--bg:#0a0c14;--bg2:#111420;--bg3:#181c2c;--border:rgba(255,255,255,0.07);--border2:rgba(255,255,255,0.11);--text:#f0f2ff;--text2:#8b93b8;--text3:#4a5278;--accent:#f59e0b;--accent2:#ef4444;--green:#10b981;--shadow:0 8px 32px rgba(0,0,0,0.4);--nav-h:60px}
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
        .page{max-width:700px;margin:0 auto;padding:32px 24px 60px}
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
        .form-group{display:flex;flex-direction:column;gap:5px;margin-bottom:16px}
        .form-group:last-of-type{margin-bottom:0}
        .form-label{font-size:10.5px;font-weight:600;color:var(--text2);text-transform:uppercase;letter-spacing:.7px}
        .form-label span{color:var(--accent2)}
        .form-input,.form-select{padding:11px 13px;background:var(--bg);border:1px solid var(--border2);border-radius:10px;color:var(--text);font-size:13.5px;font-family:'Inter',sans-serif;outline:none;width:100%;transition:border-color .2s,box-shadow .2s}
        .form-input:focus,.form-select:focus{border-color:rgba(245,158,11,.45);box-shadow:0 0 0 3px rgba(245,158,11,.07)}
        .form-input::placeholder{color:var(--text3)}
        .form-input:disabled{opacity:.45;cursor:not-allowed}
        .form-select option{background:var(--bg2)}

        /* Student info box */
        .info-box{background:rgba(16,185,129,.06);border:1px solid rgba(16,185,129,.2);border-radius:12px;padding:16px;margin-bottom:18px;display:none}
        .info-box.show{display:block;animation:fadeUp .3s ease both}
        .info-row{display:flex;justify-content:space-between;padding:5px 0;font-size:13px;border-bottom:1px solid rgba(255,255,255,.05)}
        .info-row:last-child{border-bottom:none}
        .info-row span:first-child{color:var(--text2)}
        .info-row span:last-child{font-weight:600;color:var(--text)}
        .balance-zero{color:var(--green) !important}
        .balance-due{color:var(--accent2) !important}

        .form-actions{display:flex;gap:12px;margin-top:24px;padding-top:20px;border-top:1px solid var(--border)}
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
        <a href="<%= ctx %>/students"    class="nl"><i class="fas fa-user-graduate"></i><span>Students</span></a>
        <a href="<%= ctx %>/instructors" class="nl"><i class="fas fa-chalkboard-teacher"></i><span>Instructors</span></a>
        <a href="<%= ctx %>/vehicles"    class="nl"><i class="fas fa-car"></i><span>Vehicles</span></a>
        <a href="<%= ctx %>/lessons"     class="nl"><i class="fas fa-calendar-check"></i><span>Lessons</span></a>
        <a href="<%= ctx %>/payments"    class="nl active"><i class="fas fa-money-bill-wave"></i><span>Payments</span></a>
        <a href="<%= ctx %>/tests"       class="nl"><i class="fas fa-clipboard-list"></i><span>Tests</span></a>
    </div>
    <div class="topbar-right">
        <button class="theme-btn" id="themeBtn" title="Toggle theme"><i class="fas fa-moon" id="themeIcon"></i></button>
        <a href="<%= ctx %>/logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</nav>

<div class="page">
    <div class="page-header">
        <div class="page-title">
            <i class="fas fa-receipt" style="color:var(--green)"></i> Record Payment
        </div>
        <a href="<%= ctx %>/payments" class="btn btn-ghost"><i class="fas fa-arrow-left"></i> Back</a>
    </div>

    <% if ("empty".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please fill in all required fields.</div>
    <% } else if ("invalidAmount".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please enter a valid payment amount.</div>
    <% } else if ("studentNotFound".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Student not found. Please try again.</div>
    <% } %>

    <div class="form-card">
        <form id="paymentForm" action="<%= ctx %>/payments" method="post">
            <input type="hidden" name="action" value="add">

            <div class="section-title"><i class="fas fa-user-graduate"></i> Student Details</div>

            <div class="form-group">
                <label class="form-label">Select Student <span>*</span></label>
                <select id="studentSelect" name="studentId" class="form-select" required>
                    <option value="">— Select Student —</option>
                    <% if (students != null) { for (Student student : students) { %>
                    <option value="<%= student.getStudentId() %>"
                            data-package="<%= student.getCoursePackage() %>"
                            data-fee="<%= "Basic".equals(student.getCoursePackage()) ? 299 : "Standard".equals(student.getCoursePackage()) ? 499 : 799 %>">
                        <%= student.getName() %> — <%= student.getCoursePackage() %> Package
                    </option>
                    <% }} %>
                </select>
            </div>

            <div class="info-box" id="studentInfo">
                <div class="info-row"><span>Package</span><span id="infoPackage">—</span></div>
                <div class="info-row"><span>Total Fee</span><span id="infoTotalFee">—</span></div>
                <div class="info-row"><span>Already Paid</span><span id="infoPaid">—</span></div>
                <div class="info-row"><span>Balance Due</span><span id="infoBalance">—</span></div>
            </div>

            <div class="section-title"><i class="fas fa-money-bill-wave"></i> Payment Details</div>

            <div class="form-group">
                <label class="form-label">Payment Amount (LKR) <span>*</span></label>
                <input type="number" id="paymentAmount" name="paymentAmount" class="form-input"
                       step="0.01" min="0.01" placeholder="Enter amount" required>
            </div>
            <div class="form-group">
                <label class="form-label">Payment Method <span>*</span></label>
                <select name="paymentMethod" class="form-select" required>
                    <option value="">— Select Method —</option>
                    <option value="Cash">Cash</option>
                    <option value="Card">Card</option>
                    <option value="Bank Transfer">Bank Transfer</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Payment Date <span>*</span></label>
                <input type="date" name="paymentDate" class="form-input"
                       value="<%= LocalDate.now().toString() %>" required>
            </div>
            <div class="form-group">
                <label class="form-label">Reference Number <small style="font-weight:400;text-transform:none">(optional)</small></label>
                <input type="text" name="referenceNumber" class="form-input" placeholder="Receipt / Transaction number">
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary"><i class="fas fa-check-circle"></i> Process Payment</button>
                <a href="<%= ctx %>/payments" class="btn btn-ghost"><i class="fas fa-times"></i> Cancel</a>
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

        // Payment date max = today
        var pd=document.querySelector('input[name="paymentDate"]');
        if(pd) pd.max=new Date().toISOString().split("T")[0];

        // Student select info box
        var sel=document.getElementById("studentSelect");
        var infoBox=document.getElementById("studentInfo");
        var amtInput=document.getElementById("paymentAmount");

        sel.addEventListener("change",function(){
            var opt=sel.options[sel.selectedIndex];
            if(!opt.value){infoBox.classList.remove("show");amtInput.disabled=false;return;}
            var pkg=opt.getAttribute("data-package");
            var fee=parseFloat(opt.getAttribute("data-fee"));

            fetch('<%= ctx %>/api/student-payment?studentId='+opt.value)
                .then(function(r){return r.json();})
                .then(function(data){
                    var paid=data.totalPaid||0;
                    var bal=fee-paid;
                    document.getElementById("infoPackage").textContent=pkg;
                    document.getElementById("infoTotalFee").textContent="LKR "+fee.toLocaleString();
                    document.getElementById("infoPaid").textContent="LKR "+paid.toLocaleString();
                    var balEl=document.getElementById("infoBalance");
                    balEl.textContent="LKR "+bal.toLocaleString();
                    balEl.className=bal<=0?"balance-zero":"balance-due";
                    infoBox.classList.add("show");
                    if(bal>0){amtInput.max=bal;amtInput.placeholder="Max: LKR "+bal.toLocaleString();amtInput.disabled=false;}
                    else{amtInput.max=0;amtInput.disabled=true;amtInput.placeholder="No balance due";}
                })
                .catch(function(){
                    // If API not available, show basic info without paid amount
                    document.getElementById("infoPackage").textContent=pkg;
                    document.getElementById("infoTotalFee").textContent="LKR "+fee.toLocaleString();
                    document.getElementById("infoPaid").textContent="—";
                    document.getElementById("infoBalance").textContent="—";
                    infoBox.classList.add("show");
                    amtInput.disabled=false;
                });
        });

        amtInput.addEventListener("input",function(){
            var max=parseFloat(this.max);
            if(max>0&&parseFloat(this.value)>max){this.value=max;}
        });
    })();
</script>
</body>
</html>
