<%@ page import="java.util.List,java.util.Map" %>
<%@ page import="model.Vehicle" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link href='https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@400;500;600&display=swap' rel='stylesheet'>
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>
<style>
    *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
    html, body { font-family:'DM Sans',sans-serif; background:#0f0f13; color:#f0f0f5; min-height:100vh; }
    .top-nav { position:sticky; top:0; z-index:200; display:flex; align-items:center; justify-content:space-between; padding:12px 28px; background:rgba(10,10,15,0.97); border-bottom:1px solid #1e1e2e; backdrop-filter:blur(20px); gap:16px; }
    .nav-brand { display:flex; align-items:center; gap:10px; text-decoration:none; }
    .nav-name { font-family:'Syne',sans-serif; font-size:17px; font-weight:800; color:#fff; }
    .nav-name span { color:#f59e0b; }
    .nav-links { display:flex; gap:3px; flex:1; justify-content:center; }
    .nav-link { padding:7px 12px; color:#4a4a6a; text-decoration:none; border-radius:9px; font-size:12px; font-weight:500; transition:all 0.2s; display:flex; align-items:center; gap:5px; }
    .nav-link:hover, .nav-link.active { background:rgba(245,158,11,0.08); color:#f59e0b; }
    .nav-logout { padding:8px 16px; background:linear-gradient(135deg,#ef4444,#dc2626); color:white; text-decoration:none; border-radius:10px; font-weight:600; font-size:12px; display:flex; align-items:center; gap:6px; transition:all 0.2s; white-space:nowrap; }
    .nav-logout:hover { transform:translateY(-1px); box-shadow:0 6px 16px #ef444444; }
    .page { max-width:1200px; margin:0 auto; padding:32px 28px 80px; }
    .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; animation:fadeUp 0.5s ease both; }
    .page-title { font-family:'Syne',sans-serif; font-size:26px; font-weight:800; color:#fff; }
    .page-sub { color:#3a3a5a; font-size:13px; margin-top:3px; }
    .btn-primary { display:inline-flex; align-items:center; gap:7px; padding:10px 20px; background:linear-gradient(135deg,#f59e0b,#ef4444); color:white; text-decoration:none; border-radius:11px; font-weight:600; font-size:13px; transition:all 0.2s; border:none; cursor:pointer; font-family:'DM Sans',sans-serif; }
    .btn-primary:hover { transform:translateY(-2px); box-shadow:0 8px 20px #f59e0b33; }
    .btn-secondary { display:inline-flex; align-items:center; gap:7px; padding:10px 18px; background:#111118; color:#9ca3af; text-decoration:none; border-radius:11px; font-weight:600; font-size:13px; border:1px solid #1e1e2e; transition:all 0.2s; cursor:pointer; font-family:'DM Sans',sans-serif; }
    .btn-secondary:hover { border-color:#f59e0b44; color:#f59e0b; }
    .btn-danger { display:inline-flex; align-items:center; gap:5px; padding:7px 13px; background:#ef444415; color:#ef4444; border:1px solid #ef444430; text-decoration:none; border-radius:9px; font-size:12px; font-weight:600; transition:all 0.2s; cursor:pointer; font-family:'DM Sans',sans-serif; }
    .btn-danger:hover { background:#ef444425; }
    .btn-edit { display:inline-flex; align-items:center; gap:5px; padding:7px 13px; background:#3b82f615; color:#3b82f6; border:1px solid #3b82f630; text-decoration:none; border-radius:9px; font-size:12px; font-weight:600; transition:all 0.2s; }
    .btn-edit:hover { background:#3b82f625; }
    .btn-success { display:inline-flex; align-items:center; gap:5px; padding:7px 13px; background:#10b98115; color:#10b981; border:1px solid #10b98130; text-decoration:none; border-radius:9px; font-size:12px; font-weight:600; transition:all 0.2s; }
    .btn-success:hover { background:#10b98125; }
    .alert { padding:13px 16px; border-radius:11px; margin-bottom:18px; font-size:13px; display:flex; align-items:center; gap:9px; animation:fadeUp 0.4s ease both; }
    .alert-success { background:#10b98115; border:1px solid #10b98130; color:#6ee7b7; }
    .alert-error { background:#ef444415; border:1px solid #ef444430; color:#fca5a5; }
    .alert-warning { background:#f59e0b15; border:1px solid #f59e0b30; color:#fcd34d; }
    .data-card { background:#111118; border:1px solid #1e1e2e; border-radius:16px; overflow:hidden; animation:fadeUp 0.5s ease both; }
    .data-table { width:100%; border-collapse:collapse; }
    .data-table th { padding:12px 16px; background:#0d0d14; color:#3a3a5a; font-size:10px; font-weight:600; text-transform:uppercase; letter-spacing:1px; text-align:left; border-bottom:1px solid #1e1e2e; }
    .data-table td { padding:13px 16px; border-bottom:1px solid #161622; font-size:13px; vertical-align:middle; }
    .data-table tr:last-child td { border-bottom:none; }
    .data-table tr:hover td { background:#141420; }
    .actions { display:flex; gap:5px; }
    .badge { display:inline-block; padding:2px 9px; border-radius:20px; font-size:10px; font-weight:600; }
    .badge-green { background:#10b98115; color:#6ee7b7; border:1px solid #10b98125; }
    .badge-red { background:#ef444415; color:#fca5a5; border:1px solid #ef444425; }
    .badge-yellow { background:#f59e0b15; color:#fcd34d; border:1px solid #f59e0b25; }
    .badge-blue { background:#3b82f615; color:#93c5fd; border:1px solid #3b82f625; }
    .badge-gray { background:#37415115; color:#9ca3af; border:1px solid #37415125; }
    .filter-bar { display:flex; gap:8px; margin-bottom:18px; flex-wrap:wrap; }
    .filter-input { padding:9px 14px; background:#111118; border:1px solid #1e1e2e; border-radius:10px; color:#f0f0f5; font-size:13px; font-family:'DM Sans',sans-serif; outline:none; transition:border-color 0.2s; }
    .filter-input:focus { border-color:#f59e0b44; }
    .filter-input::placeholder { color:#2a2a3a; }
    .form-card { background:#111118; border:1px solid #1e1e2e; border-radius:18px; padding:28px; animation:fadeUp 0.5s ease both; }
    .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
    .form-group { display:flex; flex-direction:column; gap:5px; }
    .form-group.full { grid-column:span 2; }
    .form-label { font-size:10px; font-weight:600; color:#3a3a5a; text-transform:uppercase; letter-spacing:1px; }
    .form-input, .form-select, .form-textarea { padding:11px 13px; background:#0d0d14; border:1px solid #1e1e2e; border-radius:10px; color:#f0f0f5; font-size:13px; font-family:'DM Sans',sans-serif; outline:none; transition:border-color 0.2s; width:100%; }
    .form-input:focus, .form-select:focus, .form-textarea:focus { border-color:#f59e0b44; }
    .form-input::placeholder, .form-textarea::placeholder { color:#2a2a3a; }
    .form-select option { background:#111118; }
    .form-textarea { resize:vertical; min-height:80px; }
    .form-actions { display:flex; gap:10px; margin-top:6px; padding-top:18px; border-top:1px solid #1e1e2e; grid-column:span 2; }
    .section-divider { grid-column:span 2; padding:5px 0; border-bottom:1px solid #1e1e2e; color:#f59e0b; font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:1.5px; margin-top:6px; }
    .mini-stats { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:22px; }
    .mini-stat { background:#111118; border:1px solid #1e1e2e; border-radius:13px; padding:16px; text-align:center; animation:fadeUp 0.4s ease both; }
    .mini-stat-val { font-family:'Syne',sans-serif; font-size:26px; font-weight:800; color:#fff; }
    .mini-stat-lbl { font-size:10px; color:#3a3a5a; text-transform:uppercase; letter-spacing:1px; margin-top:3px; }
    .empty-state { text-align:center; padding:50px 20px; color:#2a2a3a; }
    .empty-state i { font-size:42px; margin-bottom:14px; display:block; }
    .empty-state p { font-size:14px; }
    @keyframes fadeUp { from{opacity:0;transform:translateY(14px);} to{opacity:1;transform:translateY(0);} }
    @media(max-width:768px){
        .top-nav{padding:10px 14px;} .nav-links{display:none;}
        .page{padding:18px 12px 80px;}
        .form-grid{grid-template-columns:1fr;}
        .form-group.full{grid-column:span 1;}
        .section-divider{grid-column:span 1;}
        .form-actions{grid-column:span 1;}
        .mini-stats{grid-template-columns:repeat(2,1fr);}
        .page-header{flex-direction:column;align-items:flex-start;gap:10px;}
    }
</style>
<%
    List<Vehicle> vehicleList = (List<Vehicle>) request.getAttribute("vehicleList");
    Map<String,Long> stats = (Map<String,Long>) request.getAttribute("vehicleStats");
    String error = request.getParameter("error"); String success = request.getParameter("success");
    String ctx = request.getContextPath();
    String role2 = session != null && session.getAttribute("userRole") != null ? session.getAttribute("userRole").toString() : "";
    boolean isAdmin2 = "admin".equalsIgnoreCase(role2);
    if (!isAdmin2) { response.sendRedirect(ctx + "/home"); return; }
    long total = stats!=null&&stats.get("total")!=null?stats.get("total"):0;
    long available = stats!=null&&stats.get("available")!=null?stats.get("available"):0;
    long inUse = stats!=null&&stats.get("inUse")!=null?stats.get("inUse"):0;
    long maintenance = stats!=null&&stats.get("maintenance")!=null?stats.get("maintenance"):0;
%>
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>Vehicles - DriveMaster</title></head><body>
<nav class="top-nav">
    <a href="<%= request.getContextPath() %>/home" class="nav-brand">
        <svg width="36" height="36" viewBox="0 0 44 44" fill="none" style="flex-shrink:0">
            <rect width="44" height="44" rx="11" fill="url(#nlg)"/>
            <defs><linearGradient id="nlg" x1="0" y1="0" x2="44" y2="44"><stop offset="0%" stop-color="#f59e0b"/><stop offset="100%" stop-color="#ef4444"/></linearGradient></defs>
            <rect x="4" y="28" width="36" height="10" rx="3" fill="rgba(0,0,0,0.3)"/>
            <rect x="8" y="32" width="5" height="2" rx="1" fill="#fbbf24"/><rect x="20" y="32" width="5" height="2" rx="1" fill="#fbbf24"/><rect x="31" y="32" width="5" height="2" rx="1" fill="#fbbf24"/>
            <rect x="9" y="17" width="26" height="11" rx="4" fill="white"/>
            <rect x="13" y="12" width="16" height="9" rx="3" fill="white" opacity="0.9"/>
            <rect x="15" y="13.5" width="6" height="5.5" rx="1.5" fill="#bfdbfe" opacity="0.85"/>
            <rect x="23" y="13.5" width="6" height="5.5" rx="1.5" fill="#bfdbfe" opacity="0.85"/>
            <circle cx="15" cy="28.5" r="3.5" fill="#1f2937"/><circle cx="15" cy="28.5" r="1.5" fill="#9ca3af"/>
            <circle cx="30" cy="28.5" r="3.5" fill="#1f2937"/><circle cx="30" cy="28.5" r="1.5" fill="#9ca3af"/>
        </svg>
        <div class="nav-name">Drive<span>Master</span></div>
    </a>
    <%
        String __role = "";
        if (session != null && session.getAttribute("userRole") != null)
            __role = session.getAttribute("userRole").toString();
        boolean __isAdmin = "admin".equalsIgnoreCase(__role);
    %>
    <div class="nav-links">
        <% if (__isAdmin) { %>
        <a href="<%= request.getContextPath() %>/students" class="nav-link"><i class="fas fa-user-graduate"></i> Students</a><a href="<%= request.getContextPath() %>/instructors" class="nav-link"><i class="fas fa-chalkboard-teacher"></i> Instructors</a><a href="<%= request.getContextPath() %>/vehicles" class="nav-link active"><i class="fas fa-car"></i> Vehicles</a><a href="<%= request.getContextPath() %>/lessons" class="nav-link"><i class="fas fa-calendar-check"></i> Lessons</a><a href="<%= request.getContextPath() %>/payments" class="nav-link"><i class="fas fa-money-bill-wave"></i> Payments</a><a href="<%= request.getContextPath() %>/tests" class="nav-link"><i class="fas fa-clipboard-list"></i> Tests</a>
        <% } else { %>
        <a href="<%= request.getContextPath() %>/lessons" class="nav-link"><i class="fas fa-calendar-check"></i> My Lessons</a><a href="<%= request.getContextPath() %>/tests" class="nav-link"><i class="fas fa-clipboard-list"></i> My Tests</a><a href="<%= request.getContextPath() %>/payments" class="nav-link"><i class="fas fa-money-bill-wave"></i> My Payments</a>
        <% } %>
    </div>
    <a href="<%= request.getContextPath() %>/logout" class="nav-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
</nav>
<div class="page">
    <div class="page-header">
        <div><div class="page-title"><i class="fas fa-car" style="color:#f59e0b"></i> Vehicle Management</div><div class="page-sub">Fleet records and vehicle monitoring</div></div>
        <a href="<%= ctx %>/vehicles?action=add-form" class="btn-primary"><i class="fas fa-plus"></i> Add Vehicle</a>
    </div>
    <% if ("added".equals(success)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle added!</div><% }
else if ("updated".equals(success)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle updated.</div><% }
else if ("deleted".equals(success)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle decommissioned.</div><% } %>
    <div class="mini-stats">
        <div class="mini-stat"><div class="mini-stat-val"><%= total %></div><div class="mini-stat-lbl">Total Vehicles</div></div>
        <div class="mini-stat"><div class="mini-stat-val" style="color:#10b981"><%= available %></div><div class="mini-stat-lbl">Available</div></div>
        <div class="mini-stat"><div class="mini-stat-val" style="color:#f59e0b"><%= inUse %></div><div class="mini-stat-lbl">In Use</div></div>
        <div class="mini-stat"><div class="mini-stat-val" style="color:#ef4444"><%= maintenance %></div><div class="mini-stat-lbl">Maintenance</div></div>
    </div>
    <div class="data-card">
        <% if (vehicleList != null && !vehicleList.isEmpty()) { %>
        <table class="data-table"><thead><tr><th>ID</th><th>Registration</th><th>Model</th><th>Transmission</th><th>Fuel</th><th>Status</th><th>Assigned To</th><th>Actions</th></tr></thead><tbody>
        <% for (Vehicle v : vehicleList) { %>
        <tr>
            <td><span class="badge badge-blue"><%= v.getVehicleId() %></span></td>
            <td><strong><%= v.getRegistrationNumber() %></strong></td>
            <td><%= v.getVehicleModel() %></td>
            <td><span class="badge badge-yellow"><%= v.getTransmissionType() %></span></td>
            <td><%= v.getFuelType() %></td>
            <td><span class="badge <%= "Available".equals(v.getStatus())?"badge-green":"In-Use".equals(v.getStatus())?"badge-yellow":"badge-red" %>"><%= v.getStatus() %></span></td>
            <td><%= v.getAssignedInstructor()!=null&&!v.getAssignedInstructor().isEmpty()?v.getAssignedInstructor():"-" %></td>
            <td><div class="actions">
                <a href="<%= ctx %>/vehicles?action=edit&id=<%= v.getVehicleId() %>" class="btn-edit"><i class="fas fa-pen"></i></a>
                <a href="<%= ctx %>/vehicles?action=delete&id=<%= v.getVehicleId() %>" class="btn-danger" onclick="return confirm('Decommission?')"><i class="fas fa-trash"></i></a>
            </div></td>
        </tr>
        <% } %>
        </tbody></table>
        <% } else { %><div class="empty-state"><i class="fas fa-car"></i><p>No vehicles found.</p></div><% } %>
    </div>
</div></body></html>