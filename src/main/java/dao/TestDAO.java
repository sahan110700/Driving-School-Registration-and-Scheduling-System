package dao;

import model.Test;
import model.Student;
import model.Instructor;
import java.io.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

public class TestDAO {
    private static final String filePath = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main/data/tests.txt";
    private StudentDAO studentDAO = new StudentDAO();
    private InstructorDAO instructorDAO = new InstructorDAO();

    public String generateNextTestId() {
        List<Test> tests = getAllTests();
        int maxId = 0;
        for (Test t : tests) {
            try {
                int num = Integer.parseInt(t.getTestId().replaceAll("[^0-9]", ""));
                if (num > maxId) maxId = num;
            } catch (NumberFormatException ignored) {}
        }
        return String.format("T%03d", maxId + 1);
    }

    public boolean isExaminerAvailable(String examinerId, String testDate, String testTime, String excludeTestId) {
        return getAllTests().stream()
                .filter(t -> !t.getTestId().equals(excludeTestId))
                .filter(t -> t.getExaminerId().equals(examinerId))
                .filter(t -> t.getTestDate().equals(testDate))
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .noneMatch(t -> isTimeOverlap(t.getTestTime(), testTime));
    }

    public boolean isStudentAvailable(String studentId, String testDate, String testTime, String excludeTestId) {
        return getAllTests().stream()
                .filter(t -> !t.getTestId().equals(excludeTestId))
                .filter(t -> t.getStudentId().equals(studentId))
                .filter(t -> t.getTestDate().equals(testDate))
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .noneMatch(t -> isTimeOverlap(t.getTestTime(), testTime));
    }

    private boolean isTimeOverlap(String time1, String time2) {
        return time1.equals(time2);
    }

    public boolean isValidTestTime(String testTime) {
        try {
            LocalTime time  = LocalTime.parse(testTime);
            LocalTime start = LocalTime.of(8, 0);
            LocalTime end   = LocalTime.of(17, 0);
            return !time.isBefore(start) && !time.isAfter(end);
        } catch (Exception e) {
            return false;
        }
    }

    public boolean addTest(Test test) {
        if (!isValidTestTime(test.getTestTime())) return false;
        if (!isExaminerAvailable(test.getExaminerId(), test.getTestDate(), test.getTestTime(), "")) return false;
        if (!isStudentAvailable(test.getStudentId(), test.getTestDate(), test.getTestTime(), "")) return false;

        File file = new File(filePath);
        if (!file.getParentFile().exists()) file.getParentFile().mkdirs();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(testToLine(test));
            writer.newLine();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateTest(Test updatedTest) {
        Test existing = getTestById(updatedTest.getTestId());
        if (existing == null) return false;

        boolean detailsChanged = !existing.getTestDate().equals(updatedTest.getTestDate()) ||
                !existing.getTestTime().equals(updatedTest.getTestTime()) ||
                !existing.getExaminerId().equals(updatedTest.getExaminerId());

        if (detailsChanged) {
            if (!isValidTestTime(updatedTest.getTestTime())) return false;
            if (!isExaminerAvailable(updatedTest.getExaminerId(), updatedTest.getTestDate(),
                    updatedTest.getTestTime(), updatedTest.getTestId())) return false;
            if (!isStudentAvailable(updatedTest.getStudentId(), updatedTest.getTestDate(),
                    updatedTest.getTestTime(), updatedTest.getTestId())) return false;
        }

        List<Test> tests = getAllTests();
        boolean found = false;
        for (int i = 0; i < tests.size(); i++) {
            if (tests.get(i).getTestId().equals(updatedTest.getTestId())) {
                tests.set(i, updatedTest);
                found = true;
                break;
            }
        }
        return found && saveAllTests(tests);
    }

    public boolean cancelTest(String testId) {
        List<Test> tests = getAllTests();
        for (Test test : tests) {
            if (test.getTestId().equals(testId)) {
                test.setStatus("Cancelled");
                return saveAllTests(tests);
            }
        }
        return false;
    }

    public boolean submitResults(String testId, int score, String result, String notes) {
        List<Test> tests = getAllTests();
        boolean found = false;
        for (Test test : tests) {
            if (test.getTestId().equals(testId)) {
                test.setScore(score);
                test.setResult(result);
                test.setStatus("Completed");
                if (notes != null && !notes.trim().isEmpty()) {
                    test.setNotes(notes.trim());
                }
                found = true;
                break;
            }
        }
        return found && saveAllTests(tests);
    }

    public Test getTestById(String testId) {
        return getAllTests().stream()
                .filter(t -> t.getTestId().equals(testId))
                .findFirst()
                .orElse(null);
    }

    public List<Test> getAllTests() {
        List<Test> tests = new ArrayList<>();
        File file = new File(filePath);
        if (!file.exists()) return tests;

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                try {
                    tests.add(lineToTest(line));
                } catch (Exception e) {
                    System.err.println("[TestDAO] Error parsing line: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return tests;
    }

    public List<Test> getUpcomingTests() {
        String today = LocalDate.now().toString();
        return getAllTests().stream()
                .filter(t -> t.getTestDate().compareTo(today) >= 0)
                .filter(t -> "Scheduled".equals(t.getStatus()))
                .sorted(Comparator.comparing(Test::getTestDate).thenComparing(Test::getTestTime))
                .collect(Collectors.toList());
    }

    public List<Test> getTestsByDate(String date) {
        return getAllTests().stream()
                .filter(t -> t.getTestDate().equals(date))
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .sorted(Comparator.comparing(Test::getTestTime))
                .collect(Collectors.toList());
    }

    public List<Test> getTestsByStudent(String studentId) {
        return getAllTests().stream()
                .filter(t -> t.getStudentId().equals(studentId))
                .sorted(Comparator.comparing(Test::getTestDate).reversed())
                .collect(Collectors.toList());
    }

    public List<Test> getTestsByExaminer(String examinerId) {
        return getAllTests().stream()
                .filter(t -> t.getExaminerId().equals(examinerId))
                .sorted(Comparator.comparing(Test::getTestDate))
                .collect(Collectors.toList());
    }

    public Map<String, Object> getTestStatistics() {
        Map<String, Object> stats = new HashMap<>();
        List<Test> completedTests = getAllTests().stream()
                .filter(t -> "Completed".equals(t.getStatus()))
                .collect(Collectors.toList());

        long totalTests  = completedTests.size();
        long passedTests = completedTests.stream().filter(t -> "Pass".equals(t.getResult())).count();
        long failedTests = completedTests.stream().filter(t -> "Fail".equals(t.getResult())).count();
        double passRate  = totalTests > 0 ? (passedTests * 100.0 / totalTests) : 0;
        double avgScore  = completedTests.stream().mapToInt(Test::getScore).average().orElse(0);

        stats.put("totalTests",   totalTests);
        stats.put("passedTests",  passedTests);
        stats.put("failedTests",  failedTests);
        stats.put("passRate",     passRate);
        stats.put("averageScore", avgScore);
        return stats;
    }

    // Admin: எல்லா tests-உம் month-wise
    public Map<String, List<Test>> getTestsForMonth(int year, int month) {
        Map<String, List<Test>> calendarData = new HashMap<>();
        String monthStr = String.format("%d-%02d", year, month);
        getAllTests().stream()
                .filter(t -> t.getTestDate().startsWith(monthStr))
                .forEach(t -> calendarData.computeIfAbsent(t.getTestDate(), k -> new ArrayList<>()).add(t));
        return calendarData;
    }

    // Admin: எல்லா tests - date sorted, completed உட்பட
    public List<Test> getAllTestsSorted() {
        return getAllTests().stream()
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .sorted(Comparator.comparing(Test::getTestDate).reversed()
                        .thenComparing(Test::getTestTime))
                .collect(Collectors.toList());
    }

    // Student name வச்சு எல்லா tests (completed உட்பட)
    public List<Test> getTestsByStudentName(String studentName) {
        return getAllTests().stream()
                .filter(t -> t.getStudentName().equalsIgnoreCase(studentName))
                .sorted(Comparator.comparing(Test::getTestDate).reversed())
                .collect(Collectors.toList());
    }

    // Student name + date
    public List<Test> getTestsByStudentNameAndDate(String studentName, String date) {
        return getAllTests().stream()
                .filter(t -> t.getStudentName().equalsIgnoreCase(studentName))
                .filter(t -> t.getTestDate().equals(date))
                .sorted(Comparator.comparing(Test::getTestTime))
                .collect(Collectors.toList());
    }

    // Examiner + date
    public List<Test> getTestsByExaminerAndDate(String examinerId, String date) {
        return getAllTests().stream()
                .filter(t -> t.getExaminerId().equals(examinerId))
                .filter(t -> t.getTestDate().equals(date))
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .sorted(Comparator.comparing(Test::getTestTime))
                .collect(Collectors.toList());
    }

    // FIX: Instructor-ku - அவங்களோட tests மட்டும் month-wise
    public Map<String, List<Test>> getTestsForMonthByExaminer(int year, int month, String examinerId) {
        Map<String, List<Test>> calendarData = new HashMap<>();
        String monthStr = String.format("%d-%02d", year, month);
        getAllTests().stream()
                .filter(t -> t.getTestDate().startsWith(monthStr))
                .filter(t -> t.getExaminerId().equals(examinerId))
                .forEach(t -> calendarData.computeIfAbsent(t.getTestDate(), k -> new ArrayList<>()).add(t));
        return calendarData;
    }

    private String testToLine(Test t) {
        return String.join(",",
                t.getTestId(),
                t.getStudentId(),
                t.getStudentName(),
                t.getTestType(),
                t.getTestDate(),
                t.getTestTime(),
                t.getExaminerId(),
                t.getExaminerName(),
                String.valueOf(t.getScore()),
                t.getResult(),
                t.getStatus(),
                t.getScheduledDate(),
                t.getNotes() != null ? t.getNotes() : ""
        );
    }

    private Test lineToTest(String line) {
        String[] parts = line.split(",", -1);
        if (parts.length < 13) throw new IllegalArgumentException("Invalid line: " + line);
        return new Test(
                parts[0].trim(),
                parts[1].trim(),
                parts[2].trim(),
                parts[3].trim(),
                parts[4].trim(),
                parts[5].trim(),
                parts[6].trim(),
                parts[7].trim(),
                Integer.parseInt(parts[8].trim().isEmpty() ? "0" : parts[8].trim()),
                parts[9].trim(),
                parts[10].trim(),
                parts[11].trim(),
                parts[12].trim()
        );
    }

    private boolean saveAllTests(List<Test> tests) {
        File file = new File(filePath);
        if (!file.getParentFile().exists()) file.getParentFile().mkdirs();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Test t : tests) {
                writer.write(testToLine(t));
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}