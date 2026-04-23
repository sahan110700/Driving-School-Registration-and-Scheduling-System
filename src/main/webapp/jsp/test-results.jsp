<%@ page import="model.Test" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Test test = (Test) request.getAttribute("test");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enter Test Results - Driving School</title>
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
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            animation: slideUp 0.5s ease;
        }

        .header {
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: white;
            padding: 30px 40px;
        }

        .header h2 {
            font-size: 28px;
            font-weight: 700;
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
            border: 2px solid #8b5cf6;
            color: #8b5cf6;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
        }

        .form-content {
            padding: 40px;
        }

        .test-info {
            background: #f5f3ff;
            padding: 20px;
            border-radius: 16px;
            margin-bottom: 25px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e9ecef;
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            font-weight: 600;
            font-size: 14px;
            color: #374151;
            margin-bottom: 8px;
            display: block;
        }

        input, textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 14px;
        }

        input:focus, textarea:focus {
            outline: none;
            border-color: #8b5cf6;
        }

        .score-input {
            font-size: 24px;
            text-align: center;
            font-weight: 700;
        }

        .result-preview {
            background: #fef3c7;
            padding: 15px;
            border-radius: 12px;
            text-align: center;
            margin-top: 15px;
        }

        /* Pass/Fail toggle */
        .pass-fail-group {
            display: flex;
            gap: 16px;
            margin-top: 8px;
        }

        .pass-fail-label {
            flex: 1;
            cursor: pointer;
        }

        .pass-fail-label input[type="radio"] {
            display: none;
        }

        .pass-fail-card {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 18px;
            border-radius: 14px;
            border: 3px solid #e5e7eb;
            font-size: 18px;
            font-weight: 700;
            transition: all 0.2s ease;
            background: #f9fafb;
        }

        .pass-fail-label input[type="radio"]:checked + .pass-fail-card.pass-card {
            border-color: #10b981;
            background: #d1fae5;
            color: #065f46;
        }

        .pass-fail-label input[type="radio"]:checked + .pass-fail-card.fail-card {
            border-color: #ef4444;
            background: #fee2e2;
            color: #991b1b;
        }

        .pass-fail-card:hover {
            border-color: #8b5cf6;
        }

        .submit-btn {
            margin-top: 20px;
            padding: 14px 30px;
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
        }

        @media (max-width: 768px) {
            .header, .nav-bar, .form-content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-star"></i> Enter Test Results</h2>
        <p>Record student's test performance</p>
    </div>

    <div class="nav-bar">
        <a href="<%= request.getContextPath() %>/tests" class="nav-btn">
            <i class="fas fa-arrow-left"></i> Back to Tests
        </a>
    </div>

    <div class="form-content">
        <% if ("invalidScore".equals(error)) { %>
        <div class="alert alert-error" style="background: #fee2e2; color: #991b1b; padding: 12px; border-radius: 8px; margin-bottom: 20px;">
            <i class="fas fa-exclamation-triangle"></i> Score must be between 0 and 100.
        </div>
        <% } %>

        <div class="test-info">
            <div class="info-row">
                <strong>Student:</strong>
                <span><%= test != null ? test.getStudentName() : "" %></span>
            </div>
            <div class="info-row">
                <strong>Test Type:</strong>
                <span><%= test != null ? test.getTestType() : "" %></span>
            </div>
            <div class="info-row">
                <strong>Date & Time:</strong>
                <span><%= test != null ? test.getTestDate() + " at " + test.getFormattedTime() : "" %></span>
            </div>
            <div class="info-row">
                <strong>Examiner:</strong>
                <span><%= test != null ? test.getExaminerName() : "" %></span>
            </div>
        </div>

        <form action="<%= request.getContextPath() %>/tests" method="post">
            <input type="hidden" name="action" value="results">
            <input type="hidden" name="testId" value="<%= test != null ? test.getTestId() : "" %>">

            <div class="form-group">
                <label><i class="fas fa-flag-checkered"></i> Test Result *</label>
                <div class="pass-fail-group">
                    <label class="pass-fail-label">
                        <input type="radio" name="result" value="Pass" required>
                        <div class="pass-fail-card pass-card">
                            <i class="fas fa-check-circle"></i> PASS
                        </div>
                    </label>
                    <label class="pass-fail-label">
                        <input type="radio" name="result" value="Fail" required>
                        <div class="pass-fail-card fail-card">
                            <i class="fas fa-times-circle"></i> FAIL
                        </div>
                    </label>
                </div>
            </div>

            <div class="form-group">
                <label><i class="fas fa-chart-line"></i> Score (0-100) <span style="font-weight:400; color:#6b7280;">— optional</span></label>
                <input type="number" id="score" name="score" class="score-input"
                       min="0" max="100" step="1"
                       placeholder="Enter score (optional)">
            </div>

            <div class="form-group">
                <label><i class="fas fa-pen"></i> Notes / Comments</label>
                <textarea name="notes" rows="3" placeholder="Additional notes about the test..."></textarea>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-save"></i> Submit Results
            </button>
        </form>
    </div>
</div>

<script>
    // Highlight selected Pass/Fail card visually on click (radio already handles state)
    document.querySelectorAll('.pass-fail-label input[type="radio"]').forEach(radio => {
        radio.addEventListener('change', function () {
            document.querySelectorAll('.pass-fail-card').forEach(c => c.style.transform = '');
            this.nextElementSibling.style.transform = 'scale(1.03)';
        });
    });
</script>

</body>
</html>