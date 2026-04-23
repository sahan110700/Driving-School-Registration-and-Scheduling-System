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
    private final String filePath = "tests.txt";
    private StudentDAO studentDAO = new StudentDAO();
    private InstructorDAO instructorDAO = new InstructorDAO();

    // Generate next test ID (T001, T002)
    public String generateNextTestId() {
        List<Test> tests = getAllTests();
        int nextId = tests.size() + 1;
        return String.format("T%03d", nextId);
    }

    // Check if examiner is available at given time
    public boolean isExaminerAvailable(String examinerId, String testDate, String testTime, String excludeTestId) {
        List<Test> tests = getAllTests();
        return tests.stream()
                .filter(t -> !t.getTestId().equals(excludeTestId))
                .filter(t -> t.getExaminerId().equals(examinerId))
                .filter(t -> t.getTestDate().equals(testDate))
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .noneMatch(t -> isTimeOverlap(t.getTestTime(), testTime));
    }

    // Check if student has test on same day/time
    public boolean isStudentAvailable(String studentId, String testDate, String testTime, String excludeTestId) {
        List<Test> tests = getAllTests();
        return tests.stream()
                .filter(t -> !t.getTestId().equals(excludeTestId))
                .filter(t -> t.getStudentId().equals(studentId))
                .filter(t -> t.getTestDate().equals(testDate))
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .noneMatch(t -> isTimeOverlap(t.getTestTime(), testTime));
    }

    // Check time overlap (assuming 1-hour tests)
    private boolean isTimeOverlap(String time1, String time2) {
        return time1.equals(time2);
    }

    // Validate test time (8am - 5pm)
    public boolean isValidTestTime(String testTime) {
        try {
            LocalTime time = LocalTime.parse(testTime);
            LocalTime start = LocalTime.of(8, 0);
            LocalTime end = LocalTime.of(17, 0);
            return !time.isBefore(start) && !time.isAfter(end);
        } catch (Exception e) {
            return false;
        }
    }

    // Add new test
    public boolean addTest(Test test) {
        // Validate time
        if (!isValidTestTime(test.getTestTime())) {
            return false;
        }

        // Validate availability
        if (!isExaminerAvailable(test.getExaminerId(), test.getTestDate(), test.getTestTime(), "")) {
            return false;
        }
        if (!isStudentAvailable(test.getStudentId(), test.getTestDate(), test.getTestTime(), "")) {
            return false;
        }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(testToLine(test));
            writer.newLine();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update test
    public boolean updateTest(Test updatedTest) {
        // Get existing test
        Test existing = getTestById(updatedTest.getTestId());

        boolean detailsChanged = !existing.getTestDate().equals(updatedTest.getTestDate()) ||
                !existing.getTestTime().equals(updatedTest.getTestTime()) ||
                !existing.getExaminerId().equals(updatedTest.getExaminerId());

        if (detailsChanged) {
            // Validate new time
            if (!isValidTestTime(updatedTest.getTestTime())) {
                return false;
            }

            // Check availability for new slot
            if (!isExaminerAvailable(updatedTest.getExaminerId(), updatedTest.getTestDate(),
                    updatedTest.getTestTime(), updatedTest.getTestId())) {
                return false;
            }
            if (!isStudentAvailable(updatedTest.getStudentId(), updatedTest.getTestDate(),
                    updatedTest.getTestTime(), updatedTest.getTestId())) {
                return false;
            }
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

    // Cancel test
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

    // Submit test results
    public boolean submitResults(String testId, int score, String result, String notes) {
        List<Test> tests = getAllTests();
        for (Test test : tests) {
            if (test.getTestId().equals(testId)) {
                test.setScore(score);
                test.setResult(result); // "Pass" or "Fail" set directly by instructor
                test.setStatus("Completed");
                if (notes != null) test.setNotes(notes);
                return saveAllTests(tests);
            }
        }
        return false;
    }

    // Get test by ID
    public Test getTestById(String testId) {
        return getAllTests().stream()
                .filter(t -> t.getTestId().equals(testId))
                .findFirst()
                .orElse(null);
    }

    // Get all tests
    public List<Test> getAllTests() {
        List<Test> tests = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) {
            return tests;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                try {
                    tests.add(lineToTest(line));
                } catch (Exception e) {
                    System.err.println("Error parsing line: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return tests;
    }

    // Get upcoming tests (from today onwards)
    public List<Test> getUpcomingTests() {
        String today = LocalDate.now().toString();
        return getAllTests().stream()
                .filter(t -> t.getTestDate().compareTo(today) >= 0)
                .filter(t -> "Scheduled".equals(t.getStatus()))
                .sorted(Comparator.comparing(Test::getTestDate)
                        .thenComparing(Test::getTestTime))
                .collect(Collectors.toList());
    }

    // Get tests by date
    public List<Test> getTestsByDate(String date) {
        return getAllTests().stream()
                .filter(t -> t.getTestDate().equals(date))
                .filter(t -> !"Cancelled".equals(t.getStatus()))
                .sorted(Comparator.comparing(Test::getTestTime))
                .collect(Collectors.toList());
    }

    // Get tests by student
    public List<Test> getTestsByStudent(String studentId) {
        return getAllTests().stream()
                .filter(t -> t.getStudentId().equals(studentId))
                .sorted(Comparator.comparing(Test::getTestDate).reversed())
                .collect(Collectors.toList());
    }

    // Get tests by examiner
    public List<Test> getTestsByExaminer(String examinerId) {
        return getAllTests().stream()
                .filter(t -> t.getExaminerId().equals(examinerId))
                .sorted(Comparator.comparing(Test::getTestDate))
                .collect(Collectors.toList());
    }

    // Get test statistics
    public Map<String, Object> getTestStatistics() {
        Map<String, Object> stats = new HashMap<>();
        List<Test> completedTests = getAllTests().stream()
                .filter(t -> "Completed".equals(t.getStatus()))
                .collect(Collectors.toList());

        long totalTests = completedTests.size();
        long passedTests = completedTests.stream().filter(t -> "Pass".equals(t.getResult())).count();
        long failedTests = completedTests.stream().filter(t -> "Fail".equals(t.getResult())).count();

        double passRate = totalTests > 0 ? (passedTests * 100.0 / totalTests) : 0;

        stats.put("totalTests", totalTests);
        stats.put("passedTests", passedTests);
        stats.put("failedTests", failedTests);
        stats.put("passRate", passRate);

        // Get average score
        double avgScore = completedTests.stream()
                .mapToInt(Test::getScore)
                .average()
                .orElse(0);
        stats.put("averageScore", avgScore);

        return stats;
    }

    // Get calendar data for month
    public Map<String, List<Test>> getTestsForMonth(int year, int month) {
        Map<String, List<Test>> calendarData = new HashMap<>();
        String monthStr = String.format("%d-%02d", year, month);

        getAllTests().stream()
                .filter(t -> t.getTestDate().startsWith(monthStr))
                .forEach(t -> {
                    calendarData.computeIfAbsent(t.getTestDate(), k -> new ArrayList<>()).add(t);
                });

        return calendarData;
    }

    // Convert Test to CSV line
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

    // Convert CSV line to Test
    private Test lineToTest(String line) {
        String[] parts = line.split(",", -1);

        if (parts.length < 13) {
            throw new IllegalArgumentException("Invalid line format");
        }

        return new Test(
                parts[0].trim(),
                parts[1].trim(),
                parts[2].trim(),
                parts[3].trim(),
                parts[4].trim(),
                parts[5].trim(),
                parts[6].trim(),
                parts[7].trim(),
                Integer.parseInt(parts[8].trim()),
                parts[9].trim(),
                parts[10].trim(),
                parts[11].trim(),
                parts[12].trim()
        );
    }

    // Save all tests to file
    private boolean saveAllTests(List<Test> tests) {
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