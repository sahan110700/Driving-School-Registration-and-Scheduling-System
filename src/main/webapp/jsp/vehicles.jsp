<%@ page import="model.Vehicle" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Vehicle> vehicleList = (List<Vehicle>) request.getAttribute("vehicleList");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");

    if (searchKeyword == null) searchKeyword = "";
    if (selectedStatus == null) selectedStatus = "All";

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Management - Driving School</title>
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
            background: linear-gradient(135deg, #00b4db 0%, #0083b0 100%);
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

        /* Header */
        .header {
            background: linear-gradient(135deg, #00b4db 0%, #0083b0 100%);
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

        .header h2 i {
            margin-right: 12px;
        }

        .add-btn {
            padding: 12px 24px;
            background: white;
            color: #0083b0;
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

        /* Navigation Bar */
        .nav-bar {
            background: #f8f9fa;
            padding: 15px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e9ecef;
            flex-wrap: wrap;
            gap: 15px;
        }

        .nav-links {
            display: flex;
            gap: 15px;
        }

        .nav-btn {
            padding: 8px 20px;
            background: white;
            border: 2px solid #00b4db;
            color: #00b4db;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .nav-btn:hover {
            background: #00b4db;
            color: white;
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
            transition: all 0.3s ease;
        }

        .search-group input:focus, .search-group select:focus {
            outline: none;
            border-color: #00b4db;
        }

        .search-btn {
            padding: 10px 24px;
            background: linear-gradient(135deg, #00b4db 0%, #0083b0 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        /* Alert Messages */
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
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            padding: 30px 40px 0 40px;
        }

        .stat-card {
            background: linear-gradient(135deg, #00b4db 0%, #0083b0 100%);
            color: white;
            padding: 20px;
            border-radius: 16px;
            text-align: center;
        }

        .stat-number {
            font-size: 32px;
            font-weight: 700;
        }

        .stat-label {
            font-size: 14px;
            opacity: 0.9;
            margin-top: 5px;
        }

        /* Vehicle Cards Grid */
        .vehicles-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
            padding: 30px 40px;
        }

        .vehicle-card {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            border: 1px solid #e9ecef;
        }

        .vehicle-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }

        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            position: relative;
        }

        .card-header h3 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .card-header p {
            font-size: 14px;
            opacity: 0.9;
        }

        .status-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-available {
            background: #10b981;
            color: white;
        }

        .status-inuse {
            background: #f59e0b;
            color: white;
        }

        .status-maintenance {
            background: #ef4444;
            color: white;
        }

        .card-body {
            padding: 20px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #f0f0f0;
        }

        .info-label {
            font-weight: 600;
            color: #6b7280;
        }

        .info-value {
            color: #374151;
        }

        .transmission-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .transmission-manual {
            background: #dbeafe;
            color: #1e40af;
        }

        .transmission-automatic {
            background: #fef3c7;
            color: #92400e;
        }

        .fuel-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            background: #e0e7ff;
            color: #3730a3;
        }

        .card-actions {
            display: flex;
            gap: 10px;
            padding: 15px 20px 20px;
            border-top: 1px solid #f0f0f0;
        }

        .action-btn {
            flex: 1;
            padding: 8px;
            text-align: center;
            text-decoration: none;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }

        .btn-edit {
            background: #dbeafe;
            color: #1e40af;
        }

        .btn-edit:hover {
            background: #1e40af;
            color: white;
        }

        .btn-assign {
            background: #d1fae5;
            color: #065f46;
        }

        .btn-assign:hover {
            background: #065f46;
            color: white;
        }

        .btn-return {
            background: #fed7aa;
            color: #9b2c1d;
        }

        .btn-delete {
            background: #fee2e2;
            color: #991b1b;
        }

        .empty-state {
            text-align: center;
            padding: 60px;
            color: #6b7280;
        }

        .empty-state i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        @media (max-width: 768px) {
            .vehicles-grid {
                grid-template-columns: 1fr;
                padding: 20px;
            }
            .stats-cards {
                padding: 20px;
            }
            .search-section {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-car"></i> Vehicle Management</h2>
        <a href="<%= request.getContextPath() %>/vehicles?action=add-form" class="add-btn">
            <i class="fas fa-plus-circle"></i> Add New Vehicle
        </a>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
        <div>
            <i class="fas fa-car" style="color: #00b4db;"></i>
            <span style="font-size: 14px; color: #6b7280;">Total Vehicles: <%= vehicleList != null ? vehicleList.size() : 0 %></span>
        </div>
    </div>

    <!-- Alert Messages -->
        <% if ("added".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle added successfully!</div>
        <% } else if ("updated".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle updated successfully!</div>
        <% } else if ("deleted".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle deactivated successfully!</div>
        <% } else if ("assigned".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle assigned successfully!</div>
        <% } else if ("returned".equals(success)) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Vehicle returned successfully!</div>
        <% } else if ("failed".equals(error)) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Operation failed. Please try again.</div>
        <% } %>

    <!-- Search Section -->
    <div class="search-section">
        <form method="get" action="<%= request.getContextPath() %>/vehicles" class="search-form">
            <div class="search-group">
                <label><i class="fas fa-search"></i> Search by Reg Number / Model</label>
                <input type="text" name="search" value="<%= searchKeyword %>" placeholder="ABC-1234 or Toyota...">
            </div>
            <div class="search-group">
                <label><i class="fas fa-filter"></i> Filter by Status</label>
                <select name="status">
                    <option value="All" <%= "All".equals(selectedStatus) ? "selected" : "" %>>All Status</option>
                    <option value="Available" <%= "Available".equals(selectedStatus) ? "selected" : "" %>>Available</option>
                    <option value="In-Use" <%= "In-Use".equals(selectedStatus) ? "selected" : "" %>>In-Use</option>
                    <option value="Maintenance" <%= "Maintenance".equals(selectedStatus) ? "selected" : "" %>>Maintenance</option>
                </select>
            </div>
            <button type="submit" class="search-btn">
                <i class="fas fa-filter"></i> Apply Filters
            </button>
        </form>
    </div>

    <!-- Statistics Cards -->
        <% if (vehicleList != null) {
        long availableCount = vehicleList.stream().filter(v -> "Available".equals(v.getStatus())).count();
        long inUseCount = vehicleList.stream().filter(v -> "In-Use".equals(v.getStatus())).count();
        long maintenanceCount = vehicleList.stream().filter(v -> "Maintenance".equals(v.getStatus())).count();
        long manualCount = vehicleList.stream().filter(v -> "Manual".equals(v.getTransmissionType())).count();
    %>
    <div class="stats-cards">
        <div class="stat-card">
            <div class="stat-number"><%= availableCount %></div>
            <div class="stat-label">Available Vehicles</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= inUseCount %></div>
            <div class="stat-label">In-Use Vehicles</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= maintenanceCount %></div>
            <div class="stat-label">Under Maintenance</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= manualCount %></div>
            <div class="stat-label">Manual Vehicles</div>
        </div>
    </div>
        <% } %>

    <!-- Vehicle Cards Grid -->
    <div class="vehicles-grid">
        <% if (vehicleList != null && !vehicleList.isEmpty()) {
            for (Vehicle vehicle : vehicleList) {
                // Calculate maintenance status
                boolean maintenanceDue = false;
                if (vehicle.getLastMaintenanceDate() != null && !vehicle.getLastMaintenanceDate().isEmpty()) {
                    LocalDate lastMaintenance = LocalDate.parse(vehicle.getLastMaintenanceDate());
                    LocalDate today = LocalDate.now();
                    long daysSinceMaintenance = java.time.temporal.ChronoUnit.DAYS.between(lastMaintenance, today);
                    maintenanceDue = daysSinceMaintenance >= 90;
                }
        %>
        <div class="vehicle-card">
            <div class="card-header">
                <h3><i class="fas fa-car"></i> <%= vehicle.getRegistrationNumber() %></h3>
                <p><%= vehicle.getVehicleModel() %></p>
                <span class="status-badge status-<%= vehicle.getStatus().toLowerCase().replace("-", "") %>">
                        <i class="fas <%= "Available".equals(vehicle.getStatus()) ? "fa-check-circle" :
                                         "In-Use".equals(vehicle.getStatus()) ? "fa-play-circle" :
                                         "fa-wrench" %>"></i>
                        <%= vehicle.getStatus() %>
                    </span>
            </div>
            <div class="card-body">
                <div class="info-row">
                    <span class="info-label"><i class="fas fa-cog"></i> Transmission:</span>
                    <span class="info-value">
                            <span class="transmission-badge transmission-<%= vehicle.getTransmissionType().toLowerCase() %>">
                                <%= vehicle.getTransmissionType() %>
                            </span>
                        </span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="fas fa-gas-pump"></i> Fuel Type:</span>
                    <span class="info-value">
                            <span class="fuel-badge">
                                <%= vehicle.getFuelType() %>
                            </span>
                        </span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="fas fa-calendar-alt"></i> Last Maintenance:</span>
                    <span class="info-value">
                            <%= vehicle.getLastMaintenanceDate() != null && !vehicle.getLastMaintenanceDate().isEmpty() ?
                                    vehicle.getLastMaintenanceDate() : "Not recorded" %>
                            <% if (maintenanceDue) { %>
                                <span style="color: #ef4444; margin-left: 5px;">
                                    <i class="fas fa-exclamation-triangle"></i> Due!
                                </span>
                            <% } %>
                        </span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="fas fa-chalkboard-teacher"></i> Assigned Instructor:</span>
                    <span class="info-value">
                            <%= vehicle.getAssignedInstructor() != null && !vehicle.getAssignedInstructor().isEmpty() ?
                                    vehicle.getAssignedInstructor() : "Not assigned" %>
                        </span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="fas fa-tachometer-alt"></i> Mileage:</span>
                    <span class="info-value"><%= String.format("%,d", vehicle.getMileage()) %> km</span>
                </div>
                <div class="info-row">
                    <span class="info-label"><i class="fas fa-calendar-plus"></i> Added Date:</span>
                    <span class="info-value"><%= vehicle.getAddedDate() %></span>
                </div>
            </div>
            <div class="card-actions">
                <a href="<%= request.getContextPath() %>/vehicles?action=edit&id=<%= vehicle.getVehicleId() %>"
                   class="action-btn btn-edit">
                    <i class="fas fa-edit"></i> Edit
                </a>
                <% if ("Available".equals(vehicle.getStatus())) { %>
                <a href="<%= request.getContextPath() %>/vehicles?action=assign&id=<%= vehicle.getVehicleId() %>"
                   class="action-btn btn-assign">
                    <i class="fas fa-user-plus"></i> Assign
                </a>
                <% } else if ("In-Use".equals(vehicle.getStatus())) { %>
                <a href="<%= request.getContextPath() %>/vehicles?action=return&id=<%= vehicle.getVehicleId() %>"
                   class="action-btn btn-return"
                   onclick="return confirm('Return this vehicle to available pool?')">
                    <i class="fas fa-undo-alt"></i> Return
                </a>
                <% } %>
                <a href="<%= request.getContextPath() %>/vehicles?action=delete&id=<%= vehicle.getVehicleId() %>"
                   class="action-btn btn-delete"
                   onclick="return confirm('Are you sure you want to deactivate this vehicle?')">
                    <i class="fas fa-trash-alt"></i> Delete
                </a>
            </div>
        </div>
        <% }
        } else { %>
        <div class="empty-state" style="grid-column: 1/-1;">
            <i class="fas fa-car-side"></i>
            <h3>No Vehicles Found</h3>
            <p>Click the "Add New Vehicle" button to register a vehicle.</p>
        </div>
        <% } %>
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

    // Maintenance alert for vehicles due for service
    <% if (vehicleList != null) {
        for (Vehicle vehicle : vehicleList) {
            if (vehicle.getLastMaintenanceDate() != null && !vehicle.getLastMaintenanceDate().isEmpty()) {
                LocalDate lastMaintenance = LocalDate.parse(vehicle.getLastMaintenanceDate());
                LocalDate today = LocalDate.now();
                long daysSinceMaintenance = java.time.temporal.ChronoUnit.DAYS.between(lastMaintenance, today);
                if (daysSinceMaintenance >= 90) { %>
    console.log("Vehicle <%= vehicle.getRegistrationNumber() %> is due for maintenance!");
    <% }
}
}
} %>
</script>

</body>
</html>