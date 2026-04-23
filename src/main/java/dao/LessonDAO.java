package dao;

import model.Lesson;
import model.Student;
import model.Instructor;
import model.Vehicle;
import java.io.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

public class LessonDAO {
    private static final String filePath = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main/data/lessons.txt";
    private StudentDAO studentDAO = new StudentDAO();
    private InstructorDAO instructorDAO = new InstructorDAO();
    private VehicleDAO vehicleDAO = new VehicleDAO();

    // Generate next lesson ID (L001, L002)
    public String generateNextLessonId() {
        List<Lesson> lessons = getAllLessons();
        int nextId = lessons.size() + 1;
        return String.format("L%03d", nextId);
    }

    // Check if instructor is available at given time
    public boolean isInstructorAvailable(String instructorId, String lessonDate, String lessonTime, int duration, String excludeLessonId) {
        List<Lesson> lessons = getAllLessons();
        return lessons.stream()
                .filter(l -> !l.getLessonId().equals(excludeLessonId))
                .filter(l -> l.getInstructorId().equals(instructorId))
                .filter(l -> l.getLessonDate().equals(lessonDate))
                .filter(l -> !"Cancelled".equals(l.getStatus()))
                .noneMatch(l -> isTimeOverlap(l.getLessonTime(), l.getDuration(), lessonTime, duration));
    }

    // Check if vehicle is available at given time
    public boolean isVehicleAvailable(String vehicleId, String lessonDate, String lessonTime, int duration, String excludeLessonId) {
        List<Lesson> lessons = getAllLessons();
        return lessons.stream()
                .filter(l -> !l.getLessonId().equals(excludeLessonId))
                .filter(l -> l.getVehicleId().equals(vehicleId))
                .filter(l -> l.getLessonDate().equals(lessonDate))
                .filter(l -> !"Cancelled".equals(l.getStatus()))
                .noneMatch(l -> isTimeOverlap(l.getLessonTime(), l.getDuration(), lessonTime, duration));
    }

    // Check if student has lesson at same time
    public boolean isStudentAvailable(String studentId, String lessonDate, String lessonTime, int duration, String excludeLessonId) {
        List<Lesson> lessons = getAllLessons();
        return lessons.stream()
                .filter(l -> !l.getLessonId().equals(excludeLessonId))
                .filter(l -> l.getStudentId().equals(studentId))
                .filter(l -> l.getLessonDate().equals(lessonDate))
                .filter(l -> !"Cancelled".equals(l.getStatus()))
                .noneMatch(l -> isTimeOverlap(l.getLessonTime(), l.getDuration(), lessonTime, duration));
    }

    // Check time overlap helper
    private boolean isTimeOverlap(String time1, int duration1, String time2, int duration2) {
        int start1 = convertTimeToMinutes(time1);
        int end1 = start1 + (duration1 * 60);
        int start2 = convertTimeToMinutes(time2);
        int end2 = start2 + (duration2 * 60);
        return !(end1 <= start2 || end2 <= start1);
    }

    private int convertTimeToMinutes(String time) {
        String[] parts = time.split(":");
        int hours = Integer.parseInt(parts[0]);
        int minutes = Integer.parseInt(parts[1]);
        return hours * 60 + minutes;
    }

    // Add new lesson
    public boolean addLesson(Lesson lesson) {
        // Validate availability
        if (!isInstructorAvailable(lesson.getInstructorId(), lesson.getLessonDate(),
                lesson.getLessonTime(), lesson.getDuration(), "")) {
            return false;
        }
        if (!isVehicleAvailable(lesson.getVehicleId(), lesson.getLessonDate(),
                lesson.getLessonTime(), lesson.getDuration(), "")) {
            return false;
        }
        if (!isStudentAvailable(lesson.getStudentId(), lesson.getLessonDate(),
                lesson.getLessonTime(), lesson.getDuration(), "")) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(lessonToLine(lesson));
            writer.newLine();

            // Update vehicle status to In-Use
            vehicleDAO.assignVehicle(lesson.getVehicleId(), lesson.getInstructorName());

            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update lesson
    public boolean updateLesson(Lesson updatedLesson) {
        // Get existing lesson to check if time/date changed
        Lesson existing = getLessonById(updatedLesson.getLessonId());

        boolean timeChanged = !existing.getLessonDate().equals(updatedLesson.getLessonDate()) ||
                !existing.getLessonTime().equals(updatedLesson.getLessonTime()) ||
                existing.getDuration() != updatedLesson.getDuration();

        if (timeChanged) {
            // Check availability for new time slot
            if (!isInstructorAvailable(updatedLesson.getInstructorId(), updatedLesson.getLessonDate(),
                    updatedLesson.getLessonTime(), updatedLesson.getDuration(),
                    updatedLesson.getLessonId())) {
                return false;
            }
            if (!isVehicleAvailable(updatedLesson.getVehicleId(), updatedLesson.getLessonDate(),
                    updatedLesson.getLessonTime(), updatedLesson.getDuration(),
                    updatedLesson.getLessonId())) {
                return false;
            }
            if (!isStudentAvailable(updatedLesson.getStudentId(), updatedLesson.getLessonDate(),
                    updatedLesson.getLessonTime(), updatedLesson.getDuration(),
                    updatedLesson.getLessonId())) {
                return false;
            }
        }

        List<Lesson> lessons = getAllLessons();
        boolean found = false;
        for (int i = 0; i < lessons.size(); i++) {
            if (lessons.get(i).getLessonId().equals(updatedLesson.getLessonId())) {
                lessons.set(i, updatedLesson);
                found = true;
                break;
            }
        }
        return found && saveAllLessons(lessons);
    }

    // Cancel lesson
    public boolean cancelLesson(String lessonId) {
        List<Lesson> lessons = getAllLessons();
        for (Lesson lesson : lessons) {
            if (lesson.getLessonId().equals(lessonId)) {
                lesson.setStatus("Cancelled");
                // Return vehicle to available if no other lessons using it at same time
                boolean vehicleStillInUse = lessons.stream()
                        .filter(l -> l.getVehicleId().equals(lesson.getVehicleId()))
                        .filter(l -> l.getLessonDate().equals(lesson.getLessonDate()))
                        .filter(l -> l.getLessonTime().equals(lesson.getLessonTime()))
                        .filter(l -> !"Cancelled".equals(l.getStatus()))
                        .anyMatch(l -> !l.getLessonId().equals(lessonId));

                if (!vehicleStillInUse) {
                    vehicleDAO.returnVehicle(lesson.getVehicleId());
                }
                return saveAllLessons(lessons);
            }
        }
        return false;
    }

    // Complete lesson
    public boolean completeLesson(String lessonId) {
        List<Lesson> lessons = getAllLessons();
        for (Lesson lesson : lessons) {
            if (lesson.getLessonId().equals(lessonId)) {
                lesson.setStatus("Completed");
                // Return vehicle
                vehicleDAO.returnVehicle(lesson.getVehicleId());
                return saveAllLessons(lessons);
            }
        }
        return false;
    }

    // Get lesson by ID
    public Lesson getLessonById(String lessonId) {
        return getAllLessons().stream()
                .filter(l -> l.getLessonId().equals(lessonId))
                .findFirst()
                .orElse(null);
    }

    // Get all lessons
    public List<Lesson> getAllLessons() {
        List<Lesson> lessons = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) {
            return lessons;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                try {
                    lessons.add(lineToLesson(line));
                } catch (Exception e) {
                    System.err.println("Error parsing line: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return lessons;
    }

    // Get lessons by date
    public List<Lesson> getLessonsByDate(String date) {
        return getAllLessons().stream()
                .filter(l -> l.getLessonDate().equals(date))
                .filter(l -> !"Cancelled".equals(l.getStatus()))
                .sorted(Comparator.comparing(Lesson::getLessonTime))
                .collect(Collectors.toList());
    }

    // Get upcoming lessons (from today onwards)
    public List<Lesson> getUpcomingLessons() {
        String today = LocalDate.now().toString();
        return getAllLessons().stream()
                .filter(l -> l.getLessonDate().compareTo(today) >= 0)
                .filter(l -> "Scheduled".equals(l.getStatus()))
                .sorted(Comparator.comparing(Lesson::getLessonDate)
                        .thenComparing(Lesson::getLessonTime))
                .collect(Collectors.toList());
    }

    // Get lessons for a student
    public List<Lesson> getLessonsByStudent(String studentId) {
        return getAllLessons().stream()
                .filter(l -> l.getStudentId().equals(studentId))
                .sorted(Comparator.comparing(Lesson::getLessonDate).reversed())
                .collect(Collectors.toList());
    }

    // Get lessons for an instructor
    public List<Lesson> getLessonsByInstructor(String instructorId) {
        return getAllLessons().stream()
                .filter(l -> l.getInstructorId().equals(instructorId))
                .sorted(Comparator.comparing(Lesson::getLessonDate))
                .collect(Collectors.toList());
    }

    // Convert Lesson to CSV line
    private String lessonToLine(Lesson l) {
        return String.join(",",
                l.getLessonId(),
                l.getStudentId(),
                l.getStudentName(),
                l.getInstructorId(),
                l.getInstructorName(),
                l.getVehicleId(),
                l.getVehicleRegNumber(),
                l.getVehicleModel(),
                l.getLessonDate(),
                l.getLessonTime(),
                String.valueOf(l.getDuration()),
                l.getLessonType(),
                l.getStatus(),
                l.getBookedDate()
        );
    }

    // Convert CSV line to Lesson
    private Lesson lineToLesson(String line) {
        String[] parts = line.split(",", -1);

        if (parts.length < 14) {
            throw new IllegalArgumentException("Invalid line format");
        }

        return new Lesson(
                parts[0].trim(),
                parts[1].trim(),
                parts[2].trim(),
                parts[3].trim(),
                parts[4].trim(),
                parts[5].trim(),
                parts[6].trim(),
                parts[7].trim(),
                parts[8].trim(),
                parts[9].trim(),
                Integer.parseInt(parts[10].trim()),
                parts[11].trim(),
                parts[12].trim(),
                parts[13].trim()
        );
    }

    // Save all lessons to file
    private boolean saveAllLessons(List<Lesson> lessons) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Lesson l : lessons) {
                writer.write(lessonToLine(l));
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get available time slots for a given date and instructor/vehicle
    public List<String> getAvailableTimeSlots(String date, String instructorId, String vehicleId) {
        List<String> allTimeSlots = Arrays.asList("09:00", "10:00", "11:00", "13:00", "14:00", "15:00", "16:00");
        List<Lesson> lessons = getAllLessons().stream()
                .filter(l -> l.getLessonDate().equals(date))
                .filter(l -> !"Cancelled".equals(l.getStatus()))
                .collect(Collectors.toList());

        List<String> bookedSlots = new ArrayList<>();
        for (Lesson lesson : lessons) {
            if (lesson.getInstructorId().equals(instructorId) || lesson.getVehicleId().equals(vehicleId)) {
                bookedSlots.add(lesson.getLessonTime());
                if (lesson.getDuration() == 2) {
                    String nextHour = getNextHour(lesson.getLessonTime());
                    bookedSlots.add(nextHour);
                }
            }
        }

        return allTimeSlots.stream()
                .filter(slot -> !bookedSlots.contains(slot))
                .collect(Collectors.toList());
    }

    private String getNextHour(String time) {
        String[] parts = time.split(":");
        int hour = Integer.parseInt(parts[0]);
        return String.format("%02d:00", hour + 1);
    }
}