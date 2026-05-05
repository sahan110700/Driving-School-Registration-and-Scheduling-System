<%@ page import="model.Test" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Auth check
    if (session == null || session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
    Object roleObjR = session.getAttribute("userRole");
    String userRoleR = (roleObjR != null) ? roleObjR.toString() : "student";
    boolean isAdminR      = "admin".equalsIgnoreCase(userRoleR);
    boolean isInstructorR = "instructor".equalsIgnoreCase(userRoleR);

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
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            max-width: 620px;
            margin: 0 auto;
            background: white;
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .header {
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: white;
            padding: 30px 40px;
        }

        .header h2 { font-size: 26px; font-weight: 700; }
        .header p  { font-size: 14px; opacity: 0.9; margin-top: 6px; }

        .nav-bar {
            background: #f8f9fa;
            padding: 15px 40px;
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
            font-size: 14px;
        }

        .form-content { padding: 30px 40px; }

        /* Test info box */
        .test-info {
            background: #f5f3ff;
            padding: 18px 20px;
            border-radius: 16px;
            margin-bottom: 28px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 7px 0;
            border-bottom: 1px solid #e9ecef;
            font-size: 14px;
        }

        .info-row:last-child { border-bottom: none; }

        /* Pass / Fail big buttons */
        .verdict-section {
            margin-bottom: 24px;
        }

        .verdict-label {
            font-weight: 700;
            font-size: 15px;
            color: #374151;
            margin-bottom: 14px;
            display: block;
        }

        .verdict-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .verdict-btn {
            padding: 22px 10px;
            border: 3px solid #e5e7eb;
            border-radius: 16px;
            background: white;
            cursor: pointer;
            font-size: 20px;
            font-weight: 800;
            transition: all 0.2s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .verdict-btn i { font-size: 32px; }

        .verdict-btn.pass-btn { color: #16a34a; }
        .verdict-btn.fail-btn { color: #dc2626; }

        .verdict-btn.pass-btn:hover,
        .verdict-btn.pass-btn.selected {
            background: #d1fae5;
            border-color: #16a34a;
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(22,163,74,0.25);
        }

        .verdict-btn.fail-btn:hover,
        .verdict-btn.fail-btn.selected {
            background: #fee2e2;
            border-color: #dc2626;
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(220,38,38,0.25);
        }

        .verdict-sub { font-size: 12px; font-weight: 500; opacity: 0.8; }

        /* Score row (shown after verdict selected) */
        .score-section {
            display: none;
            margin-bottom: 20px;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .score-section.visible { display: block; }

        label {
            font-weight: 600;
            font-size: 14px;
            color: #374151;
            margin-bottom: 8px;
            display: block;
        }

        input[type="number"], textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 16px;
            font-family: 'Inter', sans-serif;
            box-sizing: border-box;
        }

        input[type="number"]:focus, textarea:focus {
            outline: none;
            border-color: #8b5cf6;
        }

        .score-hint {
            font-size: 12px;
            color: #6b7280;
            margin-top: 6px;
        }

        .result-preview {
            padding: 14px;
            border-radius: 12px;
            text-align: center;
            font-weight: 600;
            font-size: 15px;
            margin-top: 12px;
            background: #fef3c7;
            color: #92400e;
        }

        .result-preview.pass { background: #d1fae5; color: #065f46; }
        .result-preview.fail { background: #fee2e2; color: #991b1b; }

        .notes-section { margin-bottom: 20px; }

        .submit-btn {
            padding: 16px;
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: white;
            border: none;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            width: 100%;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .submit-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(109,40,217,0.35); }
        .submit-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

        .error-msg {
            background: #fee2e2;
            color: #991b1b;
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        @media (max-width: 500px) {
            .form-content, .header, .nav-bar { padding: 20px; }
            .verdict-btn { padding: 16px 8px; font-size: 17px; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-clipboard-check"></i> Enter Test Results</h2>
        <p>Select Pass or Fail for the student's driving test</p>
    </div>

    <div class="nav-bar">
        <a href="<%= request.getContextPath() %>/tests" class="nav-btn">
            <i class="fas fa-arrow-left"></i> Back to Tests
        </a>
    </div>

    <div class="form-content">

        <% if ("invalidScore".equals(error)) { %>
        <div class="error-msg">
            <i class="fas fa-exclamation-triangle"></i> Score must be between 0 and 100.
        </div>
        <% } else if ("noVerdict".equals(error)) { %>
        <div class="error-msg">
            <i class="fas fa-exclamation-triangle"></i> Please select Pass or Fail before submitting.
        </div>
        <% } %>

        <!-- Test Info -->
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

        <% if (isInstructorR) { %>
        <%-- Instructor: Pass/Fail form காட்டு --%>
        <form action="<%= request.getContextPath() %>/tests" method="post" id="resultsForm">
            <input type="hidden" name="action" value="results">
            <input type="hidden" name="testId" value="<%= test != null ? test.getTestId() : "" %>">
            <input type="hidden" name="score" id="scoreHidden" value="">
            <input type="hidden" name="result" id="resultHidden" value="">

            <!-- PASS / FAIL Buttons -->
            <div class="verdict-section">
                <span class="verdict-label"><i class="fas fa-gavel"></i> Select Result *</span>
                <div class="verdict-buttons">
                    <button type="button" class="verdict-btn pass-btn" onclick="selectVerdict('Pass')">
                        <i class="fas fa-check-circle"></i>
                        PASS
                        <span class="verdict-sub">Student passed</span>
                    </button>
                    <button type="button" class="verdict-btn fail-btn" onclick="selectVerdict('Fail')">
                        <i class="fas fa-times-circle"></i>
                        FAIL
                        <span class="verdict-sub">Student failed</span>
                    </button>
                </div>
            </div>

            <!-- Score (shown after verdict selected) -->
            <div class="score-section" id="scoreSection">
                <label><i class="fas fa-chart-bar"></i> Score (0-100) — Optional</label>
                <input type="number" id="scoreInput" min="0" max="100" step="1"
                       placeholder="Enter score (optional)">
                <div class="score-hint" id="scoreHint"></div>
                <div class="result-preview" id="resultPreview"></div>
            </div>

            <!-- Notes -->
            <div class="notes-section">
                <label><i class="fas fa-pen"></i> Notes / Comments</label>
                <textarea name="notes" rows="3"
                          placeholder="Additional notes about the test performance..."></textarea>
            </div>

            <button type="submit" class="submit-btn" id="submitBtn" disabled>
                <i class="fas fa-save"></i> Submit Results
            </button>
        </form>
        <% } else { %>
        <%-- Admin / Student: Read-only view காட்டு --%>
        <div style="background:#f5f3ff; border-radius:16px; padding:20px; text-align:center; margin-top:10px;">
            <% if (test != null && "Completed".equals(test.getStatus())) { %>
            <% if ("Pass".equals(test.getResult())) { %>
            <div style="font-size:48px; color:#16a34a; margin-bottom:10px;"><i class="fas fa-check-circle"></i></div>
            <div style="font-size:22px; font-weight:800; color:#16a34a;">PASSED</div>
            <div style="font-size:14px; color:#6b7280; margin-top:6px;">Score: <%= test.getScore() %> / 100</div>
            <% } else { %>
            <div style="font-size:48px; color:#dc2626; margin-bottom:10px;"><i class="fas fa-times-circle"></i></div>
            <div style="font-size:22px; font-weight:800; color:#dc2626;">FAILED</div>
            <div style="font-size:14px; color:#6b7280; margin-top:6px;">Score: <%= test.getScore() %> / 100</div>
            <% } %>
            <% if (test.getNotes() != null && !test.getNotes().isEmpty()) { %>
            <div style="margin-top:12px; font-size:13px; color:#374151;"><strong>Notes:</strong> <%= test.getNotes() %></div>
            <% } %>
            <% } else { %>
            <div style="font-size:48px; color:#f59e0b; margin-bottom:10px;"><i class="fas fa-clock"></i></div>
            <div style="font-size:16px; font-weight:600; color:#92400e;">Awaiting Results</div>
            <div style="font-size:13px; color:#6b7280; margin-top:6px;">The instructor will submit results after the test.</div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<script>
    let selectedVerdict = null;

    function selectVerdict(verdict) {
        selectedVerdict = verdict;

        // Update button styles
        document.querySelectorAll('.verdict-btn').forEach(b => b.classList.remove('selected'));
        if (verdict === 'Pass') {
            document.querySelector('.pass-btn').classList.add('selected');
            // Default score 80 for pass
            document.getElementById('scoreInput').value = 80;
            document.getElementById('scoreInput').min = 0;
        } else {
            document.querySelector('.fail-btn').classList.add('selected');
            // Default score 50 for fail
            document.getElementById('scoreInput').value = 50;
            document.getElementById('scoreInput').min = 0;
        }

        // Show score section
        document.getElementById('scoreSection').classList.add('visible');

        // Update preview
        updatePreview();

        // Enable submit
        document.getElementById('submitBtn').disabled = false;
    }

    function updatePreview() {
        const scoreInput = document.getElementById('scoreInput');
        const preview = document.getElementById('resultPreview');
        const scoreVal = parseInt(scoreInput.value);
        const hint = document.getElementById('scoreHint');

        if (selectedVerdict === 'Pass') {
            preview.className = 'result-preview pass';
            preview.innerHTML = '<i class="fas fa-check-circle"></i> Result: PASS' +
                (!isNaN(scoreVal) ? ' — Score: ' + scoreVal : '');
            hint.textContent = 'Pass score is typically 70 or above.';
        } else {
            preview.className = 'result-preview fail';
            preview.innerHTML = '<i class="fas fa-times-circle"></i> Result: FAIL' +
                (!isNaN(scoreVal) ? ' — Score: ' + scoreVal : '');
            hint.textContent = 'Fail score is below 70.';
        }
    }

    document.getElementById('scoreInput').addEventListener('input', updatePreview);

    document.getElementById('resultsForm').addEventListener('submit', function(e) {
        if (!selectedVerdict) {
            e.preventDefault();
            alert('Please select Pass or Fail before submitting.');
            return;
        }

        // Set score: use input value if provided, else use default based on verdict
        const scoreInput = document.getElementById('scoreInput');
        let score = parseInt(scoreInput.value);

        if (isNaN(score) || score < 0 || score > 100) {
            // Auto-assign default score based on verdict
            score = (selectedVerdict === 'Pass') ? 80 : 40;
        }

        // Override: if verdict is Pass but score < 70, set to 75
        if (selectedVerdict === 'Pass' && score < 70) score = 75;
        // Override: if verdict is Fail but score >= 70, set to 65
        if (selectedVerdict === 'Fail' && score >= 70) score = 65;

        document.getElementById('scoreHidden').value = score;
        document.getElementById('resultHidden').value = selectedVerdict;
    });
</script>

</body>
</html>
