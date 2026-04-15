<%@ page import="model.Instructor" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Instructor> instructorList = (List<Instructor>) request.getAttribute("instructorList");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String searchName = (String) request.getAttribute("searchName");
    String selectedSpecialization = (String) request.getAttribute("selectedSpecialization");
    String selectedAvailability = (String) request.getAttribute("selectedAvailability");

    if (searchName == null) searchName = "";
    if (selectedSpecialization == null) selectedSpecialization = "";
    if (selectedAvailability == null) selectedAvailability = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructor Management - Driving School</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            border: 2px solid #667eea;
            color: #667eea;
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
            background: #667eea;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        /* Content Area */
        .content {
            padding: 40px;
        }

        /* Alert Messages */
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

        .alert i {
            font-size: 20px;
        }

        .alert-success {
            background: #d1fae5;
            border-left: 4px solid #10b981;
            color: #065f46;
        }

        .alert-error {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            color: #991b1b;
        }

        /* Search and Filter Section */
        .search-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 16px;
            margin-bottom: 30px;
        }

        .search-form {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 15px;
            align-items: end;
        }

        .search-group {
            display: flex;
            flex-direction: column;
        }

        .search-group label {
            font-weight: 600;
            font-size: 13px;
            color: #374151;
            margin-bottom: 6px;
        }

        .search-group input, .search-group select {
            padding: 10px 14px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .search-group input:focus, .search-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .search-btn {
            padding: 10px 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .search-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        .reset-btn {
            background: #6c757d;
        }

        /* Stats Cards */
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 16px;
            text-align: center;
        }

        .stat-card i {
            font-size: 32px;
            margin-bottom: 10px;
        }

        .stat-number {
            font-size: 28px;
            font-weight: 700;
        }

        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }

        /* Table Styles */
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid #e5e7eb;
        }

        tr:hover {
            background: #f8f9fa;
        }

        /* Status Badges */
        .badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .badge-available {
            background: #d1fae5;
            color: #065f46;
        }

        .badge-busy {
            background: #fed7aa;
            color: #9b2c1d;
        }

        .badge-onleave {
            background: #fee2e2;
            color: #991b1b;
        }

        .badge-manual {
            background: #dbeafe;
            color: #1e40af;
        }

        .badge-automatic {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-both {
            background: #e0e7ff;
            color: #3730a3;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-icon {
            padding: 6px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-edit {
            background: #dbeafe;
            color: #1e40af;
        }

        .btn-edit:hover {
            background: #1e40af;
            color: white;
        }

        .btn-delete {
            background: #fee2e2;
            color: #991b1b;
        }

        .btn-delete:hover {
            background: #991b1b;
            color: white;
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

        /* Responsive */
        @media (max-width: 768px) {
            .search-form {
                grid-template-columns: 1fr;
            }

            .header, .nav-bar, .content {
                padding: 20px;
            }

            .stats-cards {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-chalkboard-teacher"></i> Instructor Management</h2>
        <p>Manage driving instructors, track availability, and monitor performance</p>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/instructors?action=add-form" class="nav-btn btn-primary">
                <i class="fas fa-plus-circle"></i> Add New Instructor
            </a>
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
        <div>
            <i class="fas fa-chalkboard-teacher" style="color: #667eea;"></i>
            <span style="font-size: 14px; color: #6b7280;">Total: <%= instructorList != null ? instructorList.size() : 0 %> Active Instructors</span>
        </div>
    </div>

    <div class="content">
        <!-- Success/Error Messages -->
        <% if ("added".equals(success)) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <span>Instructor added successfully!</span>
        </div>
        <% } else if ("updated".equals(success)) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <span>Instructor updated successfully!</span>
        </div>
        <% } else if ("deleted".equals(success)) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <span>Instructor deactivated successfully!</span>
        </div>
        <% } else if ("failed".equals(error)) { %>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Operation failed. Please try again.</span>
        </div>
        <% } %>

        <!-- Search and Filter Section -->
        <div class="search-section">
            <form method="get" action="<%= request.getContextPath() %>/instructors" class="search-form">
                <div class="search-group">
                    <label><i class="fas fa-search"></i> Search by Name</label>
                    <input type="text" name="searchName" value="<%= searchName %>"
                           placeholder="Enter instructor name...">
                </div>

                <div class="search-group">
                    <label><i class="fas fa-cogs"></i> Filter by Specialization</label>
                    <select name="specialization">
                        <option value="">All Specializations</option>
                        <option value="Manual" <%= "Manual".equals(selectedSpecialization) ? "selected" : "" %>>Manual</option>
                        <option value="Automatic" <%= "Automatic".equals(selectedSpecialization) ? "selected" : "" %>>Automatic</option>
                        <option value="Both" <%= "Both".equals(selectedSpecialization) ? "selected" : "" %>>Both</option>
                    </select>
                </div>

                <div class="search-group">
                    <label><i class="fas fa-clock"></i> Filter by Availability</label>
                    <select name="availability">
                        <option value="">All Availability</option>
                        <option value="Available" <%= "Available".equals(selectedAvailability) ? "selected" : "" %>>Available</option>
                        <option value="Busy" <%= "Busy".equals(selectedAvailability) ? "selected" : "" %>>Busy</option>
                        <option value="On Leave" <%= "On Leave".equals(selectedAvailability) ? "selected" : "" %>>On Leave</option>
                    </select>
                </div>

                <div class="search-group">
                    <button type="submit" class="search-btn">
                        <i class="fas fa-filter"></i> Apply Filters
                    </button>
                    <a href="<%= request.getContextPath() %>/instructors" class="search-btn reset-btn" style="margin-top: 8px; text-align: center;">
                        <i class="fas fa-undo-alt"></i> Reset
                    </a>
                </div>
            </form>
        </div>

        <!-- Statistics Cards -->
        <%
            if (instructorList != null) {
                long availableCount = instructorList.stream().filter(i -> "Available".equals(i.getAvailability())).count();
                long manualCount = instructorList.stream().filter(i -> "Manual".equals(i.getSpecialization()) || "Both".equals(i.getSpecialization())).count();
                long experiencedCount = instructorList.stream().filter(i -> i.getExperience() >= 5).count();
        %>
        <div class="stats-cards">
            <div class="stat-card">
                <i class="fas fa-user-check"></i>
                <div class="stat-number"><%= availableCount %></div>
                <div class="stat-label">Available Instructors</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-cogs"></i>
                <div class="stat-number"><%= manualCount %></div>
                <div class="stat-label">Manual Specialists</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-star"></i>
                <div class="stat-number"><%= experiencedCount %></div>
                <div class="stat-label">5+ Years Experience</div>
            </div>
            <div class="stat-card">
                <i class="fas fa-users"></i>
                <div class="stat-number"><%= instructorList.size() %></div>
                <div class="stat-label">Total Active</div>
            </div>
        </div>
        <% } %>

        <!-- Instructor Table -->
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Specialization</th>
                    <th>Experience</th>
                    <th>Availability</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (instructorList != null && !instructorList.isEmpty()) {
                    for (Instructor instructor : instructorList) { %>
                <tr>
                    <td><strong><%= instructor.getInstructorId() %></strong></td>
                    <td>
                        <i class="fas fa-user"></i> <%= instructor.getName() %>
                        <br>
                        <small style="color: #6b7280;"><%= instructor.getGender() %></small>
                    </td>
                    <td><%= instructor.getEmail() %></td>
                    <td><%= instructor.getPhone() %></td>
                    <td>
                        <% if ("Manual".equals(instructor.getSpecialization())) { %>
                        <span class="badge badge-manual"><i class="fas fa-cog"></i> Manual</span>
                        <% } else if ("Automatic".equals(instructor.getSpecialization())) { %>
                        <span class="badge badge-automatic"><i class="fas fa-car"></i> Automatic</span>
                        <% } else { %>
                        <span class="badge badge-both"><i class="fas fa-exchange-alt"></i> Both</span>
                        <% } %>
                    </td>
                    <td>
                        <i class="fas fa-chart-line"></i> <%= instructor.getExperience() %> years
                        <% if (instructor.getExperience() >= 5) { %>
                        <i class="fas fa-star" style="color: #f59e0b; font-size: 12px;"></i>
                        <% } %>
                    </td>
                    <td>
                        <% if ("Available".equals(instructor.getAvailability())) { %>
                        <span class="badge badge-available"><i class="fas fa-check-circle"></i> Available</span>
                        <% } else if ("Busy".equals(instructor.getAvailability())) { %>
                        <span class="badge badge-busy"><i class="fas fa-clock"></i> Busy</span>
                        <% } else { %>
                        <span class="badge badge-onleave"><i class="fas fa-calendar-times"></i> On Leave</span>
                        <% } %>
                    </td>
                    <td>
                        <div class="action-buttons">
                            <a href="<%= request.getContextPath() %>/instructors?action=edit&id=<%= instructor.getInstructorId() %>"
                               class="btn-icon btn-edit">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                            <a href="<%= request.getContextPath() %>/instructors?action=delete&id=<%= instructor.getInstructorId() %>"
                               class="btn-icon btn-delete"
                               onclick="return confirm('Are you sure you want to deactivate this instructor?')">
                                <i class="fas fa-trash-alt"></i> Delete
                            </a>
                        </div>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr>
                    <td colspan="8">
                        <div class="empty-state">
                            <i class="fas fa-chalkboard-teacher"></i>
                            <h3>No Instructors Found</h3>
                            <p>Click the "Add New Instructor" button to register an instructor.</p>
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