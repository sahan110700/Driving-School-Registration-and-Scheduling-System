package dao;

import model.Student;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class StudentDAO {

    private static final String filePath = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main/data/students.txt";

    public String generateNextStudentId() {
        List<Student> students = getAllStudents();
        int nextId = students.size() + 1;
        return String.format("S%03d", nextId);
    }

    public List<Student> getAllActiveStudents() {
        return getAllStudents();
    }

    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        File file = new File(filePath);
        if (!file.exists()) return students;

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                try {
                    students.add(lineToStudent(line));
                } catch (Exception e) {
                    System.err.println("Error parsing line: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return students;
    }

    public Student getStudentById(String studentId) {
        return getAllStudents().stream()
                .filter(s -> s.getStudentId().equals(studentId))
                .findFirst()
                .orElse(null);
    }

    public boolean addStudent(Student student) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(studentToLine(student));
            writer.newLine();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateStudent(Student updatedStudent) {
        List<Student> students = getAllStudents();
        boolean found = false;
        for (int i = 0; i < students.size(); i++) {
            if (students.get(i).getStudentId().equals(updatedStudent.getStudentId())) {
                students.set(i, updatedStudent);
                found = true;
                break;
            }
        }
        return found && saveAllStudents(students);
    }

    // Delete student from students.txt AND mark deleted in users.txt
    public boolean deleteStudent(String studentId) {
        // Get student BEFORE deleting so we have their email
        Student student = getStudentById(studentId);
        if (student == null) return false;

        List<Student> students = getAllStudents();
        boolean removed = students.removeIf(s -> s.getStudentId().equals(studentId));

        if (removed && saveAllStudents(students)) {
            // Block login by marking user deleted in users.txt using their email
            new UserDAO().markUserDeletedByEmail(student.getEmail());
            System.out.println("[StudentDAO] Deleted student + blocked login for: " + student.getEmail());
            return true;
        }
        return false;
    }

    public List<Student> searchStudentsByName(String name) {
        return getAllActiveStudents().stream()
                .filter(s -> s.getName().toLowerCase().contains(name.toLowerCase()))
                .collect(Collectors.toList());
    }

    public boolean isNicExists(String nic, String excludeId) {
        return getAllStudents().stream()
                .filter(s -> !s.getStudentId().equals(excludeId))
                .anyMatch(s -> s.getNic().equals(nic));
    }

    public boolean isEmailExists(String email, String excludeId) {
        return getAllStudents().stream()
                .filter(s -> !s.getStudentId().equals(excludeId))
                .anyMatch(s -> s.getEmail().equalsIgnoreCase(email));
    }

    private String studentToLine(Student s) {
        return String.join(",",
                s.getStudentId(), s.getName(), s.getNic(), s.getPhone(),
                s.getEmail(), s.getAddress(), s.getPassword(),
                s.getLicenseType(), s.getCoursePackage(), s.getRegistrationDate(),
                String.valueOf(s.getAge()), s.getGender()
        );
    }

    private Student lineToStudent(String line) {
        String[] parts = line.split(",", -1);
        if (parts.length < 12) throw new IllegalArgumentException("Invalid line: " + parts.length + " fields");

        int age = 0;
        try { age = Integer.parseInt(parts[10].trim()); } catch (NumberFormatException ignored) {}

        return new Student(
                parts[0].trim(), parts[1].trim(), parts[2].trim(), parts[3].trim(),
                parts[4].trim(), parts[5].trim(), parts[6].trim(), parts[7].trim(),
                parts[8].trim(), parts[9].trim(), age, parts[11].trim()
        );
    }

    private boolean saveAllStudents(List<Student> students) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Student s : students) {
                writer.write(studentToLine(s));
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}