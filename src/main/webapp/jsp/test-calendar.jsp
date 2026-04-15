<%@ page import="model.Test" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Map<String, List<Test>> calendarData = (Map<String, List<Test>>) request.getAttribute("calendarData");
    int currentYear = (int) request.getAttribute("currentYear");
    int currentMonth = (int) request.getAttribute("currentMonth");

    YearMonth yearMonth = YearMonth.of(currentYear, currentMonth);
    LocalDate firstOfMonth = yearMonth.atDay(1);
    int daysInMonth = yearMonth.lengthOfMonth();
    int startDayOfWeek = firstOfMonth.getDayOfWeek().getValue() % 7; // Convert to Sunday-first (0 = Sunday)

    String[] weekDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
    DateTimeFormatter monthFormatter = DateTimeFormatter.ofPattern("MMMM yyyy");

    // Navigate months
    LocalDate prevMonth = yearMonth.atDay(1).minusMonths(1);
    LocalDate nextMonth = yearMonth.atDay(1).plusMonths(1);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Calendar - Driving School</title>
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
            max-width: 1200px;
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
            border: 2px solid #8b5cf6;
            color: #8b5cf6;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .calendar-container {
            padding: 30px 40px;
        }

        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .month-nav {
            display: flex;
            gap: 15px;
        }

        .month-nav a {
            padding: 10px 20px;
            background: #f3f4f6;
            color: #374151;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .month-nav a:hover {
            background: #8b5cf6;
            color: white;
        }

        .current-month {
            font-size: 24px;
            font-weight: 700;
            color: #374151;
        }

        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 1px;
            background: #e5e7eb;
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            overflow: hidden;
        }

        .calendar-day-header {
            background: #f8f9fa;
            padding: 15px;
            text-align: center;
            font-weight: 700;
            color: #6b7280;
        }

        .calendar-day {
            background: white;
            min-height: 120px;
            padding: 10px;
            position: relative;
            transition: all 0.3s ease;
        }

        .calendar-day:hover {
            background: #f5f3ff;
            transform: scale(1.02);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            z-index: 1;
        }

        .day-number {
            font-weight: 700;
            font-size: 16px;
            color: #374151;
            margin-bottom: 8px;
        }

        .today .day-number {
            background: #8b5cf6;
            color: white;
            display: inline-block;
            width: 32px;
            height: 32px;
            line-height: 32px;
            text-align: center;
            border-radius: 50%;
        }

        .other-month {
            background: #f9fafb;
        }

        .other-month .day-number {
            color: #9ca3af;
        }

        .test-event {
            background: #dbeafe;
            color: #1e40af;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 11px;
            margin-bottom: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .test-event:hover {
            background: #8b5cf6;
            color: white;
            transform: translateX(2px);
        }

        .test-theory {
            border-left: 3px solid #8b5cf6;
        }

        .test-practical {
            border-left: 3px solid #10b981;
        }

        .more-events {
            font-size: 10px;
            color: #6b7280;
            text-align: center;
            margin-top: 4px;
        }

        .tooltip {
            position: absolute;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 1000;
            min-width: 200px;
            display: none;
        }

        @media (max-width: 768px) {
            .calendar-day {
                min-height: 80px;
                padding: 5px;
            }
            .test-event {
                font-size: 9px;
                padding: 2px 4px;
            }
            .calendar-container {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h2><i class="fas fa-calendar-alt"></i> Test Calendar</h2>
        <a href="<%= request.getContextPath() %>/tests?action=add-form" class="btn-primary" style="background: white; color: #6d28d9; padding: 12px 24px; border-radius: 12px; text-decoration: none; font-weight: 600;">
            <i class="fas fa-plus-circle"></i> Schedule Test
        </a>
    </div>

    <div class="nav-bar">
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/tests" class="nav-btn">
                <i class="fas fa-list"></i> List View
            </a>
            <a href="<%= request.getContextPath() %>/home" class="nav-btn">
                <i class="fas fa-home"></i> Dashboard
            </a>
        </div>
    </div>

    <div class="calendar-container">
        <div class="calendar-header">
            <div class="month-nav">
                <a href="<%= request.getContextPath() %>/tests?view=calendar&year=<%= prevMonth.getYear() %>&month=<%= prevMonth.getMonthValue() %>">
                    <i class="fas fa-chevron-left"></i> Previous
                </a>
                <a href="<%= request.getContextPath() %>/tests?view=calendar">
                    <i class="fas fa-calendar-day"></i> Today
                </a>
                <a href="<%= request.getContextPath() %>/tests?view=calendar&year=<%= nextMonth.getYear() %>&month=<%= nextMonth.getMonthValue() %>">
                    Next <i class="fas fa-chevron-right"></i>
                </a>
            </div>
            <div class="current-month">
                <%= yearMonth.format(monthFormatter) %>
            </div>
        </div>

        <div class="calendar-grid">
            <% for (String day : weekDays) { %>
            <div class="calendar-day-header"><%= day %></div>
            <% } %>

            <%
                LocalDate today = LocalDate.now();
                int dayCounter = 1;
                boolean started = false;

                for (int i = 0; i < 42; i++) {
                    int currentDay = i - startDayOfWeek + 1;
                    LocalDate date = firstOfMonth.plusDays(currentDay - 1);
                    boolean isCurrentMonth = date.getMonthValue() == currentMonth;
                    boolean isToday = date.equals(today);

                    String dateKey = date.toString();
                    List<Test> dayTests = calendarData != null ? calendarData.get(dateKey) : null;

                    String cellClass = "calendar-day";
                    if (!isCurrentMonth) cellClass += " other-month";
                    if (isToday) cellClass += " today";
            %>
            <div class="<%= cellClass %>" data-date="<%= dateKey %>">
                <div class="day-number"><%= date.getDayOfMonth() %></div>
                <% if (dayTests != null && !dayTests.isEmpty()) {
                    int displayCount = Math.min(dayTests.size(), 2);
                    for (int j = 0; j < displayCount; j++) {
                        Test test = dayTests.get(j);
                %>
                <div class="test-event test-<%= test.getTestType().toLowerCase().replace(" ", "-") %>"
                     onclick="showTestDetails('<%= test.getTestId() %>', '<%= test.getStudentName() %>', '<%= test.getTestType() %>', '<%= test.getTestTime() %>', '<%= test.getExaminerName() %>')">
                    <i class="fas fa-<%= "Theory Test".equals(test.getTestType()) ? "book" : "car" %>"></i>
                    <%= test.getTestTime() %> - <%= test.getStudentName().split(" ")[0] %>
                </div>
                <% }
                    if (dayTests.size() > 2) { %>
                <div class="more-events">+<%= dayTests.size() - 2 %> more</div>
                <% } } %>
            </div>
            <% } %>
        </div>
    </div>
</div>

<div id="tooltip" class="tooltip"></div>

<script>
    function showTestDetails(testId, studentName, testType, testTime, examinerName) {
        const tooltip = document.getElementById('tooltip');
        tooltip.innerHTML = `
            <strong>${studentName}</strong><br>
            <i class="fas fa-calendar"></i> ${testType}<br>
            <i class="fas fa-clock"></i> ${testTime}<br>
            <i class="fas fa-chalkboard-teacher"></i> ${examinerName}<br>
            <hr style="margin: 8px 0;">
            <a href="<%= request.getContextPath() %>/tests?action=results&id=${testId}" style="color: #8b5cf6; text-decoration: none;">Enter Results</a> |
            <a href="<%= request.getContextPath() %>/tests?action=edit&id=${testId}" style="color: #8b5cf6; text-decoration: none;">Reschedule</a>
        `;
        tooltip.style.display = 'block';
        tooltip.style.top = event.clientY + 10 + 'px';
        tooltip.style.left = event.clientX + 10 + 'px';

        setTimeout(() => {
            document.addEventListener('click', function hideTooltip() {
                tooltip.style.display = 'none';
                document.removeEventListener('click', hideTooltip);
            });
        }, 100);
    }

    // Hide tooltip when clicking elsewhere
    document.addEventListener('click', function(e) {
        if (!e.target.classList.contains('test-event')) {
            document.getElementById('tooltip').style.display = 'none';
        }
    });
</script>

</body>
</html>