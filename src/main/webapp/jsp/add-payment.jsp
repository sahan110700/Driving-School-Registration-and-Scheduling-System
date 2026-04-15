<%@ page import="model.Student" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Student> students = (List<Student>) request.getAttribute("students");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Record Payment - Driving School</title>
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
            max-width: 700px;
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
        }

        .header h2 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
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
        }

        .alert-error {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            color: #991b1b;
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

        select, input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        select:focus, input:focus {
            outline: none;
            border-color: #10b981;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
        }

        .student-info {
            background: #f0fdf4;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            border-left: 4px solid #10b981;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
        }

        .submit-btn {
            margin-top: 20px;
            padding: 14px 30px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
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
        <h2><i class="fas fa-receipt"></i> Record Payment</h2>
        <p>Process student fee payments</p>
    </div>

    <div class="nav-bar">
        <a href="<%= request.getContextPath() %>/payments" class="nav-btn">
            <i class="fas fa-arrow-left"></i> Back to Payments
        </a>
        <a href="<%= request.getContextPath() %>/home" class="nav-btn">
            <i class="fas fa-home"></i> Dashboard
        </a>
    </div>

    <div class="form-content">
        <% if ("empty".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Please fill in all required fields.</div>
        <% } else if ("invalidAmount".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Please enter a valid payment amount.</div>
        <% } else if ("studentNotFound".equals(error)) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Student not found. Please try again.</div>
        <% } %>

        <form id="paymentForm" action="<%= request.getContextPath() %>/payments" method="post">
            <input type="hidden" name="action" value="add">

            <div class="form-group">
                <label><i class="fas fa-user-graduate"></i> Select Student *</label>
                <select id="studentSelect" name="studentId" required>
                    <option value="">-- Select Student --</option>
                    <% if (students != null) {
                        for (Student student : students) { %>
                    <option value="<%= student.getStudentId() %>"
                            data-package="<%= student.getCoursePackage() %>"
                            data-total-fee="<%=
                                        "Basic".equals(student.getCoursePackage()) ? 299 :
                                        "Standard".equals(student.getCoursePackage()) ? 499 : 799
                                    %>">
                        <%= student.getName() %> - <%= student.getCoursePackage() %> Package
                    </option>
                    <% }} %>
                </select>
            </div>

            <div id="studentInfo" class="student-info" style="display: none;">
                <div class="info-row">
                    <strong>Package:</strong>
                    <span id="infoPackage"></span>
                </div>
                <div class="info-row">
                    <strong>Total Fee:</strong>
                    <span id="infoTotalFee"></span>
                </div>
                <div class="info-row">
                    <strong>Paid Amount:</strong>
                    <span id="infoPaidAmount"></span>
                </div>
                <div class="info-row">
                    <strong>Balance Due:</strong>
                    <span id="infoBalanceDue"></span>
                </div>
            </div>

            <div class="form-group">
                <label><i class="fas fa-money-bill"></i> Payment Amount *</label>
                <input type="number" id="paymentAmount" name="paymentAmount"
                       step="0.01" min="0.01" placeholder="Enter amount" required>
            </div>

            <div class="form-group">
                <label><i class="fas fa-credit-card"></i> Payment Method *</label>
                <select name="paymentMethod" required>
                    <option value="">-- Select Method --</option>
                    <option value="Cash">Cash</option>
                    <option value="Card">Card</option>
                    <option value="Bank Transfer">Bank Transfer</option>
                </select>
            </div>

            <div class="form-group">
                <label><i class="fas fa-calendar"></i> Payment Date *</label>
                <input type="date" name="paymentDate" value="<%= LocalDate.now().toString() %>" required>
            </div>

            <div class="form-group">
                <label><i class="fas fa-hashtag"></i> Reference Number (Optional)</label>
                <input type="text" name="referenceNumber" placeholder="Receipt/Transaction number">
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-check-circle"></i> Process Payment
            </button>
        </form>
    </div>
</div>

<script>
    const studentSelect = document.getElementById('studentSelect');
    const studentInfo = document.getElementById('studentInfo');
    const paymentAmount = document.getElementById('paymentAmount');

    // Fetch payment data for selected student
    function fetchStudentPaymentData() {
        const selectedOption = studentSelect.options[studentSelect.selectedIndex];
        if (selectedOption.value) {
            const packageType = selectedOption.getAttribute('data-package');
            const totalFee = parseFloat(selectedOption.getAttribute('data-total-fee'));

            // Get paid amount from server via AJAX
            fetch('<%= request.getContextPath() %>/api/student-payment?studentId=' + selectedOption.value)
                .then(response => response.json())
                .then(data => {
                    const paidAmount = data.totalPaid || 0;
                    const balanceDue = totalFee - paidAmount;

                    document.getElementById('infoPackage').textContent = packageType;
                    document.getElementById('infoTotalFee').textContent = 'LKR ' + totalFee.toLocaleString();
                    document.getElementById('infoPaidAmount').textContent = 'LKR ' + paidAmount.toLocaleString();
                    document.getElementById('infoBalanceDue').textContent = 'LKR ' + balanceDue.toLocaleString();

                    studentInfo.style.display = 'block';

                    // Set max payment amount
                    if (balanceDue > 0) {
                        paymentAmount.max = balanceDue;
                        paymentAmount.placeholder = 'Max: LKR ' + balanceDue.toLocaleString();
                    } else {
                        paymentAmount.max = 0;
                        paymentAmount.disabled = true;
                        paymentAmount.placeholder = 'No balance due';
                    }
                });
        } else {
            studentInfo.style.display = 'none';
        }
    }

    studentSelect.addEventListener('change', fetchStudentPaymentData);

    // Validate payment amount
    paymentAmount.addEventListener('input', function() {
        const max = parseFloat(this.max);
        const value = parseFloat(this.value);

        if (value > max && max > 0) {
            this.value = max;
            alert('Payment amount cannot exceed the balance due of LKR ' + max.toLocaleString());
        }
    });

    // Set min date to today for payment date
    const dateInput = document.querySelector('input[name="paymentDate"]');
    dateInput.max = new Date().toISOString().split('T')[0];
</script>

</body>
</html>