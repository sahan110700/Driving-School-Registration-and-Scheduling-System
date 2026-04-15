package model;

public class Test {
    private String testId;
    private String studentId;
    private String studentName;
    private String testType;        // Theory Test / Practical Test
    private String testDate;
    private String testTime;
    private String examinerId;
    private String examinerName;
    private int score;              // 0-100
    private String result;          // Pass / Fail
    private String status;          // Scheduled, Completed, Cancelled
    private String scheduledDate;   // Date test was scheduled
    private String notes;

    public Test(String testId, String studentId, String studentName,
                String testType, String testDate, String testTime,
                String examinerId, String examinerName, int score,
                String result, String status, String scheduledDate, String notes) {
        this.testId = testId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.testType = testType;
        this.testDate = testDate;
        this.testTime = testTime;
        this.examinerId = examinerId;
        this.examinerName = examinerName;
        this.score = score;
        this.result = result;
        this.status = status;
        this.scheduledDate = scheduledDate;
        this.notes = notes;
    }

    // Getters and Setters
    public String getTestId() { return testId; }
    public void setTestId(String testId) { this.testId = testId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getTestType() { return testType; }
    public void setTestType(String testType) { this.testType = testType; }

    public String getTestDate() { return testDate; }
    public void setTestDate(String testDate) { this.testDate = testDate; }

    public String getTestTime() { return testTime; }
    public void setTestTime(String testTime) { this.testTime = testTime; }

    public String getExaminerId() { return examinerId; }
    public void setExaminerId(String examinerId) { this.examinerId = examinerId; }

    public String getExaminerName() { return examinerName; }
    public void setExaminerName(String examinerName) { this.examinerName = examinerName; }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getScheduledDate() { return scheduledDate; }
    public void setScheduledDate(String scheduledDate) { this.scheduledDate = scheduledDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    // Helper method to get result badge class
    public String getResultBadgeClass() {
        if ("Pass".equals(result)) return "result-pass";
        if ("Fail".equals(result)) return "result-fail";
        return "result-pending";
    }

    // Helper method to get formatted time
    public String getFormattedTime() {
        if (testTime == null) return "";
        String[] parts = testTime.split(":");
        int hour = Integer.parseInt(parts[0]);
        String period = hour >= 12 ? "PM" : "AM";
        int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return String.format("%d:%s %s", displayHour, parts[1], period);
    }
}