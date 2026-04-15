<%@ page import="model.Vehicle" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Vehicle vehicle = (Vehicle) request.getAttribute("vehicle");
    String error = request.getParameter("error");
    boolean isAdd = (vehicle == null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isAdd ? "Add New Vehicle" : "Edit Vehicle" %> - Driving School</title>
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
            max-width: 800px;
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
            background: linear-gradient(135deg, #00b4db 0%, #0083b0 100%);
            color: white;
            padding: 30px 40px;
        }

        .header h2 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .header p {
            font-size: 14px;
            opacity: 0.9;
        }

        .nav-bar {
            background: #f8f9fa;
            padding: 15px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e9ecef;
        }

        .nav-btn {
            padding: 8px 20px;
            background: white;
            border: 2px solid #00b4db;
            color: #00b4db;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .nav-btn:hover {
            background: #00b4db;
            color: white;
        }

        .form-content {
            padding: 40px;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .alert-error {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            color: #991b1b;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group-full {
            grid-column: span 2;
        }

        label {
            font-weight: 600;
            font-size: 14px;
            color: #374151;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .required {
            color: #ef4444;
            font-size: 12px;
        }

        input, select, textarea {
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 14px;
            font-family: 'Inter', sans-serif;
            transition: all 0.3s ease;
        }

        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #00b4db;
            box-shadow: 0 0 0 3px rgba(0, 180, 219, 0.1);
        }

        input.error, select.error, textarea.error {
            border-color: #ef4444;
            background: #fef2f2;
        }

        .error-message {
            font-size: 12px;
            color: #ef4444;
            margin-top: 6px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .hint {
            font-size: 11px;
            color: #6b7280;
            margin-top: 6px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        input[readonly] {
            background: #f3f4f6;
            cursor: not-allowed;
        }

        .submit-btn {
            margin-top: 30px;
            padding: 14px 30px;
            background: linear-gradient(135deg, #00b4db 0%, #0083b0 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 180, 219, 0.3);
        }

        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .form-group-full {
                grid-column: span 1;
            }
            .header, .nav-bar, .form-content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-<%= isAdd ? "plus-circle" : "edit" %>"></i> <%= isAdd ? "Add New Vehicle" : "Edit Vehicle" %></h2>
        <p><%= isAdd ? "Register a new vehicle to the fleet" : "Update vehicle information" %></p>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/vehicles" class="nav-btn">
                <i class="fas fa-arrow-left"></i> Back to Vehicles
            </a>
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
    </div>

    <div class="form-content">
        <% if ("empty".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Please fill in all required fields.</span>
        </div>
        <% } else if ("regExists".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Registration number already exists. Please use a unique registration number.</span>
        </div>
        <% } else if ("mileage".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Please enter a valid mileage (positive number).</span>
        </div>
        <% } %>

        <form id="vehicleForm" action="<%= request.getContextPath() %>/vehicles" method="post" novalidate>
            <input type="hidden" name="action" value="<%= isAdd ? "add" : "update" %>">
            <% if (!isAdd) { %>
            <input type="hidden" name="vehicleId" value="<%= vehicle.getVehicleId() %>">
            <% } %>

            <div class="form-grid">
                <!-- Vehicle ID (Auto-generated) -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-id-card"></i> Vehicle ID
                        <span class="required">*</span>
                    </label>
                    <input type="text" value="<%= isAdd ? "Auto-generated" : vehicle.getVehicleId() %>" readonly>
                </div>

                <!-- Registration Number -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-registered"></i> Registration Number
                        <span class="required">*</span>
                    </label>
                    <input type="text" id="regNumber" name="registrationNumber"
                           value="<%= isAdd ? "" : vehicle.getRegistrationNumber() %>"
                           placeholder="ABC-1234"
                           pattern="[A-Za-z0-9-]{5,10}"
                           required>
                    <div class="error-message" id="regError"></div>
                    <div class="hint">
                        <i class="fas fa-info-circle"></i> Format: ABC-1234 or similar
                    </div>
                </div>

                <!-- Vehicle Model -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-car"></i> Vehicle Model
                        <span class="required">*</span>
                    </label>
                    <input type="text" id="model" name="vehicleModel"
                           value="<%= isAdd ? "" : vehicle.getVehicleModel() %>"
                           placeholder="Toyota Corolla"
                           required>
                </div>

                <!-- Transmission Type -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-cog"></i> Transmission Type
                        <span class="required">*</span>
                    </label>
                    <select id="transmission" name="transmissionType" required>
                        <option value="">-- Select Transmission --</option>
                        <option value="Manual" <%= !isAdd && "Manual".equals(vehicle.getTransmissionType()) ? "selected" : "" %>>Manual</option>
                        <option value="Automatic" <%= !isAdd && "Automatic".equals(vehicle.getTransmissionType()) ? "selected" : "" %>>Automatic</option>
                    </select>
                </div>

                <!-- Fuel Type -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-gas-pump"></i> Fuel Type
                        <span class="required">*</span>
                    </label>
                    <select id="fuelType" name="fuelType" required>
                        <option value="">-- Select Fuel Type --</option>
                        <option value="Petrol" <%= !isAdd && "Petrol".equals(vehicle.getFuelType()) ? "selected" : "" %>>Petrol</option>
                        <option value="Diesel" <%= !isAdd && "Diesel".equals(vehicle.getFuelType()) ? "selected" : "" %>>Diesel</option>
                        <option value="Hybrid" <%= !isAdd && "Hybrid".equals(vehicle.getFuelType()) ? "selected" : "" %>>Hybrid</option>
                        <option value="Electric" <%= !isAdd && "Electric".equals(vehicle.getFuelType()) ? "selected" : "" %>>Electric</option>
                    </select>
                </div>

                <!-- Status -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-chart-line"></i> Status
                        <span class="required">*</span>
                    </label>
                    <select id="status" name="status" required>
                        <option value="">-- Select Status --</option>
                        <option value="Available" <%= !isAdd && "Available".equals(vehicle.getStatus()) ? "selected" : "" %>>Available</option>
                        <option value="In-Use" <%= !isAdd && "In-Use".equals(vehicle.getStatus()) ? "selected" : "" %>>In-Use</option>
                        <option value="Maintenance" <%= !isAdd && "Maintenance".equals(vehicle.getStatus()) ? "selected" : "" %>>Maintenance</option>
                    </select>
                </div>

                <!-- Last Maintenance Date -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-calendar-alt"></i> Last Maintenance Date
                    </label>
                    <input type="date" id="lastMaintenance" name="lastMaintenanceDate"
                           value="<%= isAdd ? "" : vehicle.getLastMaintenanceDate() %>">
                    <div class="hint">
                        <i class="fas fa-info-circle"></i> Leave empty if not applicable
                    </div>
                </div>

                <!-- Assigned Instructor -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-chalkboard-teacher"></i> Assigned Instructor
                    </label>
                    <input type="text" name="assignedInstructor"
                           value="<%= isAdd ? "" : vehicle.getAssignedInstructor() %>"
                           placeholder="Instructor name (if assigned)">
                </div>

                <!-- Mileage -->
                <div class="form-group">
                    <label>
                        <i class="fas fa-tachometer-alt"></i> Mileage (km)
                        <span class="required">*</span>
                    </label>
                    <input type="number" id="mileage" name="mileage"
                           value="<%= isAdd ? "" : vehicle.getMileage() %>"
                           placeholder="0"
                           min="0"
                           step="1"
                           required>
                    <div class="error-message" id="mileageError"></div>
                </div>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-<%= isAdd ? "save" : "sync-alt" %>"></i>
                <%= isAdd ? "Add Vehicle" : "Update Vehicle" %>
            </button>
        </form>
    </div>
</div>

<script>
    // Get form elements
    const form = document.getElementById('vehicleForm');
    const regNumber = document.getElementById('regNumber');
    const mileage = document.getElementById('mileage');

    // Registration number validation - allow letters, numbers, and hyphens
    regNumber.addEventListener('input', function(e) {
        this.value = this.value.toUpperCase().replace(/[^A-Z0-9-]/g, '');
        validateRegNumber();
    });

    function validateRegNumber() {
        const reg = regNumber.value;
        const errorDiv = document.getElementById('regError');
        const regPattern = /^[A-Z0-9-]{5,10}$/;

        if (reg && !regPattern.test(reg)) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Registration number must be 5-10 characters (letters, numbers, hyphens)';
            regNumber.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            regNumber.classList.remove('error');
            return true;
        }
    }

    // Mileage validation
    mileage.addEventListener('input', function() {
        const value = parseInt(this.value);
        const errorDiv = document.getElementById('mileageError');

        if (value < 0) {
            errorDiv.innerHTML = '<i class="fas fa-times-circle"></i> Mileage cannot be negative';
            mileage.classList.add('error');
            return false;
        } else {
            errorDiv.innerHTML = '';
            mileage.classList.remove('error');
            return true;
        }
    });

    // Form submission validation
    form.addEventListener('submit', function(e) {
        const isRegValid = validateRegNumber();

        if (!isRegValid) {
            e.preventDefault();
            alert('Please fix the errors before submitting.');
            return false;
        }

        return true;
    });

    // Set max date for maintenance date to today
    const maintenanceDate = document.getElementById('lastMaintenance');
    if (maintenanceDate) {
        maintenanceDate.max = new Date().toISOString().split('T')[0];
    }
</script>

</body>
</html>