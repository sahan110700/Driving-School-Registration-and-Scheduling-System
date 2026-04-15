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

    // Calculate summary statistics
    long completedCount = 0;
    long partialCount = 0;
    long pendingCount = 0;
    double totalCollected = 0;

    if (paymentSummary != null) {
        for (Map<String, Object> summary : paymentSummary) {
            String status = (String) summary.get("status");
            if ("Completed".equals(status)) completedCount++;
            else if ("Partial".equals(status)) partialCount++;
            else if ("Pending".equals(status)) pendingCount++;
            totalCollected += (Double) summary.get("totalPaid");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Management - Driving School</title>
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
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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

        .add-btn {
            padding: 12px 24px;
            background: white;
            color: #059669;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .add-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
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
            border: 2px solid #10b981;
            color: #10b981;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .nav-btn:hover {
            background: #10b981;
            color: white;
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
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 20px;
            border-radius: 16px;
            text-align: center;
        }

        .stat-number {
            font-size: 28px;
            font-weight: 700;
        }

        .stat-label {
            font-size: 14px;
            opacity: 0.9;
            margin-top: 5px;
        }

        /* Search Section */
        .search-section {
            background: #f8f9fa;
            padding: 25px 40px;
            border-bottom: 1px solid #e9ecef;
        }

        .search-form {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: end;
        }

        .search-group {
            flex: 1;
            min-width: 200px;
        }

        .search-group label {
            font-weight: 600;
            font-size: 13px;
            color: #374151;
            margin-bottom: 6px;
            display: block;
        }

        .search-group input, .search-group select {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
        }

        .search-btn {
            padding: 10px 24px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        /* Revenue Summary */
        .revenue-section {
            padding: 30px 40px;
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
        }

        .revenue-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .revenue-card {
            background: white;
            padding: 20px;
            border-radius: 16px;
            border: 1px solid #e5e7eb;
        }

        .revenue-card h4 {
            color: #374151;
            margin-bottom: 15px;
            font-size: 16px;
        }

        /* Payment Table */
        .payment-table-section {
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
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
            background: #f0fdf4;
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .status-completed {
            background: #d1fae5;
            color: #065f46;
        }

        .status-partial {
            background: #fed7aa;
            color: #9b2c1d;
        }

        .status-pending {
            background: #fee2e2;
            color: #991b1b;
        }

        .progress-bar {
            width: 100px;
            height: 6px;
            background: #e5e7eb;
            border-radius: 3px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: #10b981;
            border-radius: 3px;
            transition: width 0.3s ease;
        }

        .empty-state {
            text-align: center;
            padding: 60px;
            color: #6b7280;
        }

        @media (max-width: 768px) {
            .stats-cards, .search-section, .revenue-section, .payment-table-section {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-money-bill-wave"></i> Payment Management</h2>
        <a href="<%= request.getContextPath() %>/payments?action=add-form" class="add-btn">
            <i class="fas fa-plus-circle"></i> Record Payment
        </a>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
        <div>
            <i class="fas fa-chart-line" style="color: #10b981;"></i>
            <span style="font-size: 14px; color: #6b7280;">Total Revenue: <%= currencyFormat.format(totalRevenue != null ? totalRevenue : 0) %></span>
        </div>
    </div>

    <!-- Alert Messages -->
    <% if ("added".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Payment recorded successfully!</div>
    <% } else if ("deleted".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Payment deleted successfully!</div>
    <% } else if ("empty".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Please fill in all required fields.</div>
    <% } else if ("invalidAmount".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Please enter a valid payment amount.</div>
    <% } %>

    <!-- Statistics Cards -->
    <div class="stats-cards">
        <div class="stat-card">
            <div class="stat-number"><%= completedCount %></div>
            <div class="stat-label">Fully Paid</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= partialCount %></div>
            <div class="stat-label">Partial Payments</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= pendingCount %></div>
            <div class="stat-label">Pending</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= currencyFormat.format(totalCollected) %></div>
            <div class="stat-label">Total Collected</div>
        </div>
    </div>

    <!-- Search and Filter -->
    <div class="search-section">
        <form method="get" action="<%= request.getContextPath() %>/payments" class="search-form">
            <div class="search-group">
                <label><i class="fas fa-search"></i> Search by Student Name</label>
                <input type="text" name="searchStudent" value="<%= searchStudent %>"
                       placeholder="Enter student name...">
            </div>
            <div class="search-group">
                <label><i class="fas fa-filter"></i> Filter by Payment Status</label>
                <select name="filterStatus">
                    <option value="All" <%= "All".equals(filterStatus) ? "selected" : "" %>>All Status</option>
                    <option value="Completed" <%= "Completed".equals(filterStatus) ? "selected" : "" %>>Completed</option>
                    <option value="Partial" <%= "Partial".equals(filterStatus) ? "selected" : "" %>>Partial</option>
                    <option value="Pending" <%= "Pending".equals(filterStatus) ? "selected" : "" %>>Pending</option>
                </select>
            </div>
            <button type="submit" class="search-btn">
                <i class="fas fa-filter"></i> Apply Filters
            </button>
        </form>
    </div>

    <!-- Revenue Summary -->
    <div class="revenue-section">
        <h3><i class="fas fa-chart-pie"></i> Revenue Summary</h3>
        <div class="revenue-grid">
            <div class="revenue-card">
                <h4><i class="fas fa-chart-line"></i> By Payment Method</h4>
                <% if (revenueByMethod != null && !revenueByMethod.isEmpty()) {
                    for (Map.Entry<String, Double> entry : revenueByMethod.entrySet()) { %>
                <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                    <span><%= entry.getKey() %></span>
                    <strong><%= currencyFormat.format(entry.getValue()) %></strong>
                </div>
                <% } } else { %>
                <p>No data available</p>
                <% } %>
            </div>
            <div class="revenue-card">
                <h4><i class="fas fa-calendar"></i> Monthly Revenue</h4>
                <% if (monthlyRevenue != null && !monthlyRevenue.isEmpty()) {
                    List<Map.Entry<String, Double>> sorted = new ArrayList<>(monthlyRevenue.entrySet());
                    sorted.sort(Map.Entry.comparingByKey());
                    Collections.reverse(sorted);
                    for (Map.Entry<String, Double> entry : sorted.subList(0, Math.min(3, sorted.size()))) { %>
                <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                    <span><%= entry.getKey() %></span>
                    <strong><%= currencyFormat.format(entry.getValue()) %></strong>
                </div>
                <% } } else { %>
                <p>No data available</p>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Payment Summary Table -->
    <div class="payment-table-section">
        <div class="section-title">
            <i class="fas fa-table"></i> Payment Summary
        </div>
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Package</th>
                    <th>Total Fee</th>
                    <th>Paid Amount</th>
                    <th>Balance Due</th>
                    <th>Progress</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>
                <% if (paymentSummary != null && !paymentSummary.isEmpty()) {
                    for (Map<String, Object> summary : paymentSummary) {
                        double totalFee = (Double) summary.get("totalFee");
                        double totalPaid = (Double) summary.get("totalPaid");
                        double balanceDue = (Double) summary.get("balanceDue");
                        String status = (String) summary.get("status");
                        double progress = totalFee > 0 ? (totalPaid / totalFee) * 100 : 0;
                %>
                <tr>
                    <td><strong><%= summary.get("studentName") %></strong></td>
                    <td><%= summary.get("packageType") %></td>
                    <td><%= currencyFormat.format(totalFee) %></td>
                    <td><%= currencyFormat.format(totalPaid) %></td>
                    <td><%= currencyFormat.format(balanceDue) %></td>
                    <td>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%= progress %>%"></div>
                        </div>
                        <small><%= String.format("%.1f", progress) %>%</small>
                    </td>
                    <td>
                                <span class="status-badge status-<%= status.toLowerCase() %>">
                                    <i class="fas <%= "Completed".equals(status) ? "fa-check-circle" :
                                                   "Partial".equals(status) ? "fa-chart-line" :
                                                   "fa-clock" %>"></i>
                                    <%= status %>
                                </span>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr>
                    <td colspan="7">
                        <div class="empty-state">
                            <i class="fas fa-receipt"></i>
                            <h3>No Payment Records Found</h3>
                            <p>Click the "Record Payment" button to add payments.</p>
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
    // Auto-dismiss alerts after 5 seconds
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