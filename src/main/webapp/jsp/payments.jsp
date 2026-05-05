<%@ page import="model.Student" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Map<String, Object>> paymentSummary = (List<Map<String, Object>>) request.getAttribute("paymentSummary");
    List<Student> students = (List<Student>) request.getAttribute("students");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchStudent = (String) request.getAttribute("searchStudent");
    String filterStatus = (String) request.getAttribute("filterStatus");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    Map<String, Double> revenueByMethod = (Map<String, Double>) request.getAttribute("revenueByMethod");
    Map<String, Double> monthlyRevenue = (Map<String, Double>) request.getAttribute("monthlyRevenue");

    if (searchStudent == null) searchStudent = "";
    if (filterStatus == null) filterStatus = "All";

    DecimalFormat currencyFormat = new DecimalFormat("LKR #,###.00");

    long completedCount = 0, partialCount = 0, pendingCount = 0;
    double totalCollected = 0;
    if (paymentSummary != null) {
        for (Map<String, Object> s : paymentSummary) {
            String st = (String) s.get("status");
            if ("Completed".equals(st)) completedCount++;
            else if ("Partial".equals(st)) partialCount++;
            else if ("Pending".equals(st)) pendingCount++;
            totalCollected += (Double) s.get("totalPaid");
        }
    }
    String ctx = request.getContextPath();
    String role = session != null && session.getAttribute("userRole") != null
            ? session.getAttribute("userRole").toString() : "";
    Boolean isAdminAttr = (Boolean) request.getAttribute("isAdminView");
    boolean isAdmin = isAdminAttr != null ? isAdminAttr : "admin".equalsIgnoreCase(role);
%>
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Payments - DriveMaster</title>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    *,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
    html,body{font-family:'DM Sans',sans-serif;background:#0a0e1a;color:#f0f0f5;min-height:100vh;}

    /* NAV */
    .top-nav{position:sticky;top:0;z-index:200;display:flex;align-items:center;justify-content:space-between;padding:12px 28px;background:rgba(10,14,26,0.97);border-bottom:1px solid #1e1e2e;backdrop-filter:blur(20px);gap:16px;}
    .nav-brand{display:flex;align-items:center;gap:10px;text-decoration:none;}
    .nav-name{font-family:'Syne',sans-serif;font-size:17px;font-weight:800;color:#fff;}
    .nav-name span{color:#f59e0b;}
    .nav-links{display:flex;gap:3px;flex:1;justify-content:center;}
    .nav-link{padding:7px 12px;color:#4a4a6a;text-decoration:none;border-radius:9px;font-size:12px;font-weight:500;transition:all 0.2s;display:flex;align-items:center;gap:5px;}
    .nav-link:hover,.nav-link.active{background:rgba(245,158,11,0.08);color:#f59e0b;}
    .nav-logout{padding:8px 16px;background:linear-gradient(135deg,#ef4444,#dc2626);color:white;text-decoration:none;border-radius:10px;font-weight:600;font-size:12px;display:flex;align-items:center;gap:6px;transition:all 0.2s;}
    .nav-logout:hover{transform:translateY(-1px);box-shadow:0 6px 16px #ef444444;}

    /* PAGE */
    .page{max-width:1200px;margin:0 auto;padding:32px 28px 80px;}
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;animation:fadeUp 0.5s ease both;}
    .page-title{font-family:'Syne',sans-serif;font-size:26px;font-weight:800;color:#fff;}
    .page-sub{color:#3a3a5a;font-size:13px;margin-top:3px;}
    .btn-primary{display:inline-flex;align-items:center;gap:7px;padding:10px 20px;background:linear-gradient(135deg,#f59e0b,#ef4444);color:white;text-decoration:none;border-radius:11px;font-weight:600;font-size:13px;transition:all 0.2s;border:none;cursor:pointer;font-family:'DM Sans',sans-serif;}
    .btn-primary:hover{transform:translateY(-2px);box-shadow:0 8px 20px #f59e0b33;}

    /* ALERTS */
    .alert{padding:13px 16px;border-radius:11px;margin-bottom:18px;font-size:13px;display:flex;align-items:center;gap:9px;animation:fadeUp 0.4s ease both;}
    .alert-success{background:#10b98115;border:1px solid #10b98130;color:#6ee7b7;}
    .alert-error{background:#ef444415;border:1px solid #ef444430;color:#fca5a5;}

    /* STATS */
    .stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;}
    .stat{background:#111118;border:1px solid #1e1e2e;border-radius:15px;padding:20px;transition:all 0.2s;animation:fadeUp 0.4s ease both;border-top:3px solid var(--sc);}
    .stat:hover{transform:translateY(-3px);}
    .stat-ico{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:16px;color:var(--sc);background:var(--sc)15;margin-bottom:10px;}
    .stat-val{font-family:'Syne',sans-serif;font-size:28px;font-weight:800;color:#fff;line-height:1;}
    .stat-lbl{font-size:10px;color:#3a3a5a;text-transform:uppercase;letter-spacing:1px;margin-top:4px;}

    /* FILTER */
    .filter-card{background:#111118;border:1px solid #1e1e2e;border-radius:14px;padding:18px 20px;margin-bottom:20px;animation:fadeUp 0.4s ease both;}
    .filter-row{display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;}
    .fg{display:flex;flex-direction:column;gap:5px;flex:1;min-width:180px;}
    .fg label{font-size:10px;font-weight:600;color:#3a3a5a;text-transform:uppercase;letter-spacing:1px;}
    .fg input,.fg select{padding:10px 12px;background:#0d0d14;border:1px solid #1e1e2e;border-radius:10px;color:#f0f0f5;font-size:13px;font-family:'DM Sans',sans-serif;outline:none;transition:border-color 0.2s;width:100%;}
    .fg input:focus,.fg select:focus{border-color:#f59e0b44;}
    .fg input::placeholder{color:#2a2a3a;}
    .fg select option{background:#111118;}
    .btn-filter{padding:10px 18px;background:#111118;border:1px solid #1e1e2e;border-radius:10px;color:#9ca3af;font-family:'DM Sans',sans-serif;font-size:13px;cursor:pointer;transition:all 0.2s;display:flex;align-items:center;gap:6px;}
    .btn-filter:hover{border-color:#f59e0b44;color:#f59e0b;}
    .btn-clear{padding:10px 16px;background:transparent;border:1px solid #1e1e2e;border-radius:10px;color:#4a4a6a;font-size:13px;text-decoration:none;display:flex;align-items:center;gap:5px;transition:all 0.2s;}
    .btn-clear:hover{color:#ef4444;border-color:#ef444430;}

    /* REVENUE CARDS */
    .revenue-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:24px;}
    .rev-card{background:#111118;border:1px solid #1e1e2e;border-radius:14px;padding:20px;animation:fadeUp 0.5s ease both;}
    .rev-card h4{font-family:'Syne',sans-serif;font-size:13px;font-weight:700;color:#9ca3af;text-transform:uppercase;letter-spacing:1px;margin-bottom:14px;display:flex;align-items:center;gap:7px;}
    .rev-card h4 i{color:#eab308;}
    .rev-row{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid #161622;font-size:13px;}
    .rev-row:last-child{border-bottom:none;}
    .rev-row span{color:#6b7280;}
    .rev-row strong{color:#f0f0f5;}
    .no-data{color:#2a2a3a;font-size:13px;text-align:center;padding:16px 0;}

    /* TABLE */
    .data-card{background:#111118;border:1px solid #1e1e2e;border-radius:16px;overflow:hidden;animation:fadeUp 0.5s ease both;}
    .data-card-header{padding:14px 18px;border-bottom:1px solid #1e1e2e;font-family:'Syne',sans-serif;font-size:13px;font-weight:700;color:#9ca3af;text-transform:uppercase;letter-spacing:1px;display:flex;align-items:center;gap:7px;}
    .data-card-header i{color:#eab308;}
    .data-table{width:100%;border-collapse:collapse;}
    .data-table th{padding:11px 16px;background:#0d0d14;color:#3a3a5a;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:1px;text-align:left;border-bottom:1px solid #1e1e2e;}
    .data-table td{padding:13px 16px;border-bottom:1px solid #161622;font-size:13px;vertical-align:middle;}
    .data-table tr:last-child td{border-bottom:none;}
    .data-table tr:hover td{background:#141420;}
    .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;}
    .badge-green{background:#10b98115;color:#6ee7b7;border:1px solid #10b98125;}
    .badge-yellow{background:#f59e0b15;color:#fcd34d;border:1px solid #f59e0b25;}
    .badge-red{background:#ef444415;color:#fca5a5;border:1px solid #ef444425;}
    .badge-blue{background:#3b82f615;color:#93c5fd;border:1px solid #3b82f625;}
    .progress-bar{width:90px;height:5px;background:#1e1e2e;border-radius:3px;overflow:hidden;margin-bottom:3px;}
    .progress-fill{height:100%;background:linear-gradient(90deg,#10b981,#f59e0b);border-radius:3px;}
    .prog-txt{font-size:10px;color:#3a3a5a;}
    .btn-pay{display:inline-flex;align-items:center;gap:5px;padding:6px 12px;background:#eab30815;color:#eab308;border:1px solid #eab30830;text-decoration:none;border-radius:9px;font-size:12px;font-weight:600;transition:all 0.2s;}
    .btn-pay:hover{background:#eab30825;}
    .empty-state{text-align:center;padding:48px 20px;color:#2a2a3a;}
    .empty-state i{font-size:40px;margin-bottom:14px;display:block;}
    .empty-state p{font-size:13px;}
    @keyframes fadeUp{from{opacity:0;transform:translateY(14px);}to{opacity:1;transform:translateY(0);}}
    @media(max-width:768px){.top-nav{padding:10px 14px;}.nav-links{display:none;}.stats-row{grid-template-columns:repeat(2,1fr);}.revenue-grid{grid-template-columns:1fr;}.filter-row{flex-direction:column;}}
</style>
</head><body>

<!-- NAV -->
<nav class="top-nav">
    <a href="<%= ctx %>/home" class="nav-brand">
        <svg width="36" height="36" viewBox="0 0 44 44" fill="none">
            <rect width="44" height="44" rx="11" fill="url(#pg)"/>
            <defs><linearGradient id="pg" x1="0" y1="0" x2="44" y2="44"><stop offset="0%" stop-color="#f59e0b"/><stop offset="100%" stop-color="#ef4444"/></linearGradient></defs>
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
        boolean __isAdmin = "admin".equalsIgnoreCase(role);
    %>
    <div class="nav-links">
        <% if (__isAdmin) { %>
        <a href="<%= ctx %>/students"    class="nav-link"><i class="fas fa-user-graduate"></i> Students</a>
        <a href="<%= ctx %>/instructors" class="nav-link"><i class="fas fa-chalkboard-teacher"></i> Instructors</a>
        <a href="<%= ctx %>/vehicles"    class="nav-link"><i class="fas fa-car"></i> Vehicles</a>
        <a href="<%= ctx %>/lessons"     class="nav-link"><i class="fas fa-calendar-check"></i> Lessons</a>
        <a href="<%= ctx %>/payments"    class="nav-link active"><i class="fas fa-money-bill-wave"></i> Payments</a>
        <a href="<%= ctx %>/tests"       class="nav-link"><i class="fas fa-clipboard-list"></i> Tests</a>
        <% } else { %>
        <a href="<%= ctx %>/lessons"  class="nav-link"><i class="fas fa-calendar-check"></i> My Lessons</a>
        <a href="<%= ctx %>/tests"    class="nav-link"><i class="fas fa-clipboard-list"></i> My Tests</a>
        <a href="<%= ctx %>/payments" class="nav-link active"><i class="fas fa-money-bill-wave"></i> My Payments</a>
        <% } %>
    </div>
    <a href="<%= ctx %>/logout" class="nav-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
</nav>

<div class="page">
    <!-- Header -->
    <div class="page-header">
        <div>
            <div class="page-title"><i class="fas fa-money-bill-wave" style="color:#eab308"></i> Payment Management</div>
            <div class="page-sub">Track all student payments and financial records</div>
        </div>
        <% if (isAdmin) { %>
        <a href="<%= ctx %>/payments?action=add-form" class="btn-primary"><i class="fas fa-plus"></i> Record Payment</a>
        <% } %>
    </div>

    <!-- Alerts -->
    <% if ("added".equals(success)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Payment recorded successfully!</div><% }
else if ("deleted".equals(success)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Payment deleted.</div><% }
else if ("empty".equals(error)) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please fill in all required fields.</div><% }
else if ("invalidAmount".equals(error)) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Invalid payment amount.</div><% } %>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat" style="--sc:#10b981"><div class="stat-ico"><i class="fas fa-check-circle"></i></div><div class="stat-val"><%= completedCount %></div><div class="stat-lbl">Fully Paid</div></div>
        <div class="stat" style="--sc:#f59e0b"><div class="stat-ico"><i class="fas fa-chart-line"></i></div><div class="stat-val"><%= partialCount %></div><div class="stat-lbl">Partial</div></div>
        <div class="stat" style="--sc:#ef4444"><div class="stat-ico"><i class="fas fa-clock"></i></div><div class="stat-val"><%= pendingCount %></div><div class="stat-lbl">Pending</div></div>
        <div class="stat" style="--sc:#eab308"><div class="stat-ico"><i class="fas fa-coins"></i></div><div class="stat-val" style="font-size:18px"><%= currencyFormat.format(totalCollected) %></div><div class="stat-lbl">Total Collected</div></div>
    </div>

    <!-- Search Filter (admin only) -->
    <% if (isAdmin) { %>
    <div class="filter-card">
        <form method="get" action="<%= ctx %>/payments" class="filter-row">
            <div class="fg"><label><i class="fas fa-search"></i> Search Student</label>
                <input type="text" name="searchStudent" value="<%= searchStudent %>" placeholder="Enter student name..."></div>
            <div class="fg"><label><i class="fas fa-filter"></i> Filter Status</label>
                <select name="filterStatus">
                    <option value="All" <%= "All".equals(filterStatus)?"selected":"" %>>All Status</option>
                    <option value="Completed" <%= "Completed".equals(filterStatus)?"selected":"" %>>Completed</option>
                    <option value="Partial" <%= "Partial".equals(filterStatus)?"selected":"" %>>Partial</option>
                    <option value="Pending" <%= "Pending".equals(filterStatus)?"selected":"" %>>Pending</option>
                </select></div>
            <button type="submit" class="btn-filter"><i class="fas fa-filter"></i> Apply</button>
            <a href="<%= ctx %>/payments" class="btn-clear"><i class="fas fa-times"></i> Clear</a>
        </form>
    </div>
    <% } %>

    <!-- Revenue Summary (admin only) -->
    <% if (isAdmin) { %>
    <div class="revenue-grid">
        <div class="rev-card">
            <h4><i class="fas fa-credit-card"></i> By Payment Method</h4>
            <% if (revenueByMethod != null && !revenueByMethod.isEmpty()) {
                for (Map.Entry<String,Double> e : revenueByMethod.entrySet()) { %>
            <div class="rev-row"><span><%= e.getKey() %></span><strong><%= currencyFormat.format(e.getValue()) %></strong></div>
            <% } } else { %><div class="no-data">No data yet</div><% } %>
        </div>
        <div class="rev-card">
            <h4><i class="fas fa-calendar-alt"></i> Monthly Revenue</h4>
            <% if (monthlyRevenue != null && !monthlyRevenue.isEmpty()) {
                List<Map.Entry<String,Double>> sorted = new ArrayList<>(monthlyRevenue.entrySet());
                sorted.sort(Map.Entry.comparingByKey());
                Collections.reverse(sorted);
                for (Map.Entry<String,Double> e : sorted.subList(0, Math.min(3, sorted.size()))) { %>
            <div class="rev-row"><span><%= e.getKey() %></span><strong><%= currencyFormat.format(e.getValue()) %></strong></div>
            <% } } else { %><div class="no-data">No data yet</div><% } %>
        </div>
    </div>
    <% } %>

    <!-- Payment Table -->
    <div class="data-card">
        <div class="data-card-header"><i class="fas fa-table"></i> Payment Summary</div>
        <% if (paymentSummary != null && !paymentSummary.isEmpty()) { %>
        <table class="data-table">
            <thead><tr>
                <th>Student</th><th>Package</th><th>Total Fee</th><th>Paid</th><th>Balance</th><th>Progress</th><th>Status</th>
                <% if (isAdmin) { %><th>Action</th><% } %>
            </tr></thead>
            <tbody>
            <% for (Map<String,Object> s : paymentSummary) {
                double tf = (Double) s.get("totalFee");
                double tp = (Double) s.get("totalPaid");
                double bd = (Double) s.get("balanceDue");
                String st = (String) s.get("status");
                double prog = tf > 0 ? (tp/tf)*100 : 0;
                String badgeCls = "Completed".equals(st) ? "badge-green" : "Partial".equals(st) ? "badge-yellow" : "badge-red";
            %>
            <tr>
                <td><strong><%= s.get("studentName") %></strong></td>
                <td><span class="badge badge-blue"><%= s.get("packageType") %></span></td>
                <td><%= currencyFormat.format(tf) %></td>
                <td><strong style="color:#10b981"><%= currencyFormat.format(tp) %></strong></td>
                <td><strong style="color:<%= bd > 0 ? "#ef4444" : "#10b981" %>"><%= currencyFormat.format(bd) %></strong></td>
                <td>
                    <div class="progress-bar"><div class="progress-fill" style="width:<%= prog %>%"></div></div>
                    <div class="prog-txt"><%= String.format("%.1f", prog) %>%</div>
                </td>
                <td><span class="badge <%= badgeCls %>"><i class="fas <%= "Completed".equals(st)?"fa-check-circle":"Partial".equals(st)?"fa-chart-line":"fa-clock" %>"></i> <%= st %></span></td>
                <% if (isAdmin) { %>
                <td><a href="<%= ctx %>/payments?action=add-form&studentId=<%= s.get("studentId") %>" class="btn-pay"><i class="fas fa-plus"></i> Pay</a></td>
                <% } %>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state"><i class="fas fa-receipt"></i><p>No payment records found.</p></div>
        <% } %>
    </div>
</div>

<script>
    setTimeout(()=>{document.querySelectorAll('.alert').forEach(a=>{a.style.opacity='0';setTimeout(()=>a.remove(),300);});},5000);
</script>
</body></html>
