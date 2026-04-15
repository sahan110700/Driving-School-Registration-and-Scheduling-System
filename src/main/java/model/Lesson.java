package model;

public class Lesson {
    private String lessonId;
    private String studentId;          // Student ID (for reference)
    private String studentName;        // Student Name (for display)
    private String instructorId;        // Instructor ID (for reference)
    private String instructorName;      // Instructor Name (for display)
    private String vehicleId;           // Vehicle ID (for reference)
    private String vehicleRegNumber;    // Vehicle Registration Number
    private String vehicleModel;        // Vehicle Model
    private String lessonDate;          // Date of lesson
    private String lessonTime;          // Start time
    private int duration;               // Duration in hours (1 or 2)
    private String lessonType;          // Regular / Intensive / Refresher
    private String status;              // Scheduled, Completed, Cancelled
    private String bookedDate;          // Date lesson was booked

    public Lesson(String lessonId, String studentId, String studentName,
                  String instructorId, String instructorName,
                  String vehicleId, String vehicleRegNumber, String vehicleModel,
                  String lessonDate, String lessonTime, int duration,
                  String lessonType, String status, String bookedDate) {
        this.lessonId = lessonId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.instructorId = instructorId;
        this.instructorName = instructorName;
        this.vehicleId = vehicleId;
        this.vehicleRegNumber = vehicleRegNumber;
        this.vehicleModel = vehicleModel;
        this.lessonDate = lessonDate;
        this.lessonTime = lessonTime;
        this.duration = duration;
        this.lessonType = lessonType;
        this.status = status;
        this.bookedDate = bookedDate;
    }

    // Getters and Setters
    public String getLessonId() { return lessonId; }
    public void setLessonId(String lessonId) { this.lessonId = lessonId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getInstructorId() { return instructorId; }
    public void setInstructorId(String instructorId) { this.instructorId = instructorId; }

    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

    public String getVehicleId() { return vehicleId; }
    public void setVehicleId(String vehicleId) { this.vehicleId = vehicleId; }

    public String getVehicleRegNumber() { return vehicleRegNumber; }
    public void setVehicleRegNumber(String vehicleRegNumber) { this.vehicleRegNumber = vehicleRegNumber; }

    public String getVehicleModel() { return vehicleModel; }
    public void setVehicleModel(String vehicleModel) { this.vehicleModel = vehicleModel; }

    public String getLessonDate() { return lessonDate; }
    public void setLessonDate(String lessonDate) { this.lessonDate = lessonDate; }

    public String getLessonTime() { return lessonTime; }
    public void setLessonTime(String lessonTime) { this.lessonTime = lessonTime; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public String getLessonType() { return lessonType; }
    public void setLessonType(String lessonType) { this.lessonType = lessonType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getBookedDate() { return bookedDate; }
    public void setBookedDate(String bookedDate) { this.bookedDate = bookedDate; }

    // Helper method to get display name with vehicle info
    public String getVehicleDisplay() {
        return vehicleRegNumber + " (" + vehicleModel + ")";
    }
}