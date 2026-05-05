<%@ page import="model.Vehicle" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Vehicle vehicle = (Vehicle) request.getAttribute("vehicle");
    String error = request.getParameter("error");
    boolean isAdd = (vehicle == null);
    String ctx = request.getContextPath();
    String __role = (session != null && session.getAttribute("userRole") != null)
            ? session.getAttribute("userRole").toString() : "";
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title><%= isAdd ? "Add Vehicle" : "Edit Vehicle" %> — DriveMaster</title>
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
        .form-input,.form-select{padding:11px 13px;background:var(--bg);border:1px solid var(--border2);border-radius:10px;color:var(--text);font-size:13.5px;font-family:'Inter',sans-serif;outline:none;width:100%;transition:border-color .2s,box-shadow .2s}
        .form-input:focus,.form-select:focus{border-color:rgba(245,158,11,.45);box-shadow:0 0 0 3px rgba(245,158,11,.07)}
        .form-input::placeholder{color:var(--text3)}
        .form-input[readonly]{opacity:.55;cursor:not-allowed}
        .form-select option{background:var(--bg2)}
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
        <a href="<%= ctx %>/vehicles"    class="nl active"><i class="fas fa-car"></i><span>Vehicles</span></a>
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
        <div class="page-title">
            <i class="fas fa-car" style="color:var(--accent)"></i>
            <%= isAdd ? "Add Vehicle" : "Edit Vehicle" %>
        </div>
        <a href="<%= ctx %>/vehicles" class="btn btn-ghost"><i class="fas fa-arrow-left"></i> Back</a>
    </div>

    <% if ("empty".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please fill in all required fields.</div>
    <% } else if ("regExists".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Registration number already exists.</div>
    <% } else if ("mileage".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please enter a valid mileage (positive number).</div>
    <% } %>

    <div class="form-card">
        <form id="vehicleForm" action="<%= ctx %>/vehicles" method="post">
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %><input type="hidden" name="vehicleId" value="<%= vehicle.getVehicleId() %>"><% } %>

            <div class="section-title"><i class="fas fa-car"></i> Vehicle Information</div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Vehicle ID</label>
                    <input type="text" class="form-input" value="<%= isAdd ? "Auto-generated" : vehicle.getVehicleId() %>" readonly>
                </div>
                <div class="form-group">
                    <label class="form-label">Registration Number <span>*</span></label>
                    <input type="text" id="regNumber" name="registrationNumber" class="form-input"
                           placeholder="ABC-1234"
                           value="<%= isAdd ? "" : vehicle.getRegistrationNumber() %>" required>
                    <div class="form-hint">Format: ABC-1234 (5–10 chars)</div>
                    <div class="form-err" id="regError"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Vehicle Model <span>*</span></label>
                    <input type="text" name="vehicleModel" class="form-input" placeholder="Toyota Corolla"
                           value="<%= isAdd ? "" : vehicle.getVehicleModel() %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Transmission Type <span>*</span></label>
                    <select name="transmissionType" class="form-select" required>
                        <option value="">— Select —</option>
                        <option value="Manual"    <%= !isAdd && "Manual".equals(vehicle.getTransmissionType())    ? "selected" : "" %>>Manual</option>
                        <option value="Automatic" <%= !isAdd && "Automatic".equals(vehicle.getTransmissionType()) ? "selected" : "" %>>Automatic</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Fuel Type <span>*</span></label>
                    <select name="fuelType" class="form-select" required>
                        <option value="">— Select —</option>
                        <option value="Petrol"   <%= !isAdd && "Petrol".equals(vehicle.getFuelType())   ? "selected" : "" %>>Petrol</option>
                        <option value="Diesel"   <%= !isAdd && "Diesel".equals(vehicle.getFuelType())   ? "selected" : "" %>>Diesel</option>
                        <option value="Hybrid"   <%= !isAdd && "Hybrid".equals(vehicle.getFuelType())   ? "selected" : "" %>>Hybrid</option>
                        <option value="Electric" <%= !isAdd && "Electric".equals(vehicle.getFuelType()) ? "selected" : "" %>>Electric</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Status <span>*</span></label>
                    <select name="status" class="form-select" required>
                        <option value="">— Select —</option>
                        <option value="Available"   <%= !isAdd && "Available".equals(vehicle.getStatus())   ? "selected" : "" %>>Available</option>
                        <option value="In-Use"      <%= !isAdd && "In-Use".equals(vehicle.getStatus())      ? "selected" : "" %>>In-Use</option>
                        <option value="Maintenance" <%= !isAdd && "Maintenance".equals(vehicle.getStatus()) ? "selected" : "" %>>Maintenance</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Mileage (km) <span>*</span></label>
                    <input type="number" id="mileage" name="mileage" class="form-input" placeholder="0" min="0"
                           value="<%= isAdd ? "" : vehicle.getMileage() %>" required>
                    <div class="form-err" id="mileageError"></div>
                </div>
                <div class="form-group">
                    <label class="form-label">Last Maintenance Date</label>
                    <input type="date" id="lastMaintenance" name="lastMaintenanceDate" class="form-input"
                           value="<%= isAdd ? "" : vehicle.getLastMaintenanceDate() %>">
                    <div class="form-hint">Leave blank if not applicable</div>
                </div>
                <div class="form-group full">
                    <label class="form-label">Assigned Instructor</label>
                    <input type="text" name="assignedInstructor" class="form-input"
                           placeholder="Instructor name (if assigned)"
                           value="<%= isAdd ? "" : vehicle.getAssignedInstructor() %>">
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> <%= isAdd ? "Add Vehicle" : "Update Vehicle" %>
                </button>
                <a href="<%= ctx %>/vehicles" class="btn btn-ghost"><i class="fas fa-times"></i> Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
    (function(){
        var h=document.documentElement,b=document.getElementById("themeBtn"),ic=document.getElementById("themeIcon");
        var t=localStorage.getItem("dm-theme")||"dark";
        h.setAttribute("data-theme",t);ic.className=t==="dark"?"fas fa-moon":"fas fa-sun";
        b.addEventListener("click",function(){var n=h.getAttribute("data-theme")==="dark"?"light":"dark";h.setAttribute("data-theme",n);localStorage.setItem("dm-theme",n);ic.className=n==="dark"?"fas fa-moon":"fas fa-sun";});

        // Set max date for maintenance
        var md=document.getElementById("lastMaintenance");
        if(md) md.max=new Date().toISOString().split("T")[0];

        // Reg number uppercase
        var rn=document.getElementById("regNumber");
        if(rn){rn.addEventListener("input",function(){this.value=this.value.toUpperCase().replace(/[^A-Z0-9-]/g,"");});
            rn.addEventListener("blur",function(){var e=document.getElementById("regError");if(this.value&&!/^[A-Z0-9-]{5,10}$/.test(this.value)){e.textContent="Must be 5–10 chars (letters, numbers, hyphens)";}else e.textContent="";});}

        // Mileage validation
        var ml=document.getElementById("mileage");
        if(ml)ml.addEventListener("blur",function(){var e=document.getElementById("mileageError");if(this.value&&parseInt(this.value)<0){e.textContent="Mileage cannot be negative";}else e.textContent="";});
    })();
</script>
</body>
</html>
