package dao;

import model.Student;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class StudentDAO {

    private final String filePath = "students.txt";

    // Generate next student ID (S001, S002)
    public String generateNextStudentId() {
        List<Student> students = getAllStudents();
        int nextId = students.size() + 1;
        return String.format("S%03d", nextId);
    }

    // Get all active students (students who are not deleted/inactive)
    // This is the missing method that was causing the error
    public List<Student> getAllActiveStudents() {
        List<Student> allStudents = getAllStudents();
        // Since we don't have a status field in Student model, return all students
        // If you add a status field in future, filter by status here
        return allStudents;
    }

    // Get all students (including inactive)
    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) {
            return students;
        }

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

    // Get student by ID
    public Student getStudentById(String studentId) {
        return getAllStudents().stream()
                .filter(s -> s.getStudentId().equals(studentId))
                .findFirst()
                .orElse(null);
    }

    // Add new student
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

    // Update student
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
        return found ? saveAllStudents(students) : false;
    }

    // Delete student (soft delete - change status if you have status field)
    public boolean deleteStudent(String studentId) {
        List<Student> students = getAllStudents();
        boolean removed = students.removeIf(s -> s.getStudentId().equals(studentId));
        return removed && saveAllStudents(students);
    }

    // Search students by name
    public List<Student> searchStudentsByName(String name) {
        return getAllActiveStudents().stream()
                .filter(s -> s.getName().toLowerCase().contains(name.toLowerCase()))
                .collect(Collectors.toList());
    }

    // Check if NIC already exists
    public boolean isNicExists(String nic, String excludeId) {
        List<Student> students = getAllStudents();
        return students.stream()
                .filter(s -> !s.getStudentId().equals(excludeId))
                .anyMatch(s -> s.getNic().equals(nic));
    }

    // Check if email already exists
    public boolean isEmailExists(String email, String excludeId) {
        List<Student> students = getAllStudents();
        return students.stream()
                .filter(s -> !s.getStudentId().equals(excludeId))
                .anyMatch(s -> s.getEmail().equalsIgnoreCase(email));
    }

    private String studentToLine(Student s) {
        return String.join(",",
                s.getStudentId(),
                s.getName(),
                s.getNic(),
                s.getPhone(),
                s.getEmail(),
                s.getAddress(),
                s.getPassword(),
                s.getLicenseType(),
                s.getCoursePackage(),
                s.getRegistrationDate(),
                String.valueOf(s.getAge()),
                s.getGender()
        );
    }

    private Student lineToStudent(String line) {
        String[] parts = line.split(",", -1);

        if (parts.length < 12) {
            throw new IllegalArgumentException("Invalid line format: expected 12 fields but got " + parts.length);
        }

        String studentId = parts[0].trim();
        String name = parts[1].trim();
        String nic = parts[2].trim();
        String phone = parts[3].trim();
        String email = parts[4].trim();
        String address = parts[5].trim();
        String password = parts[6].trim();
        String licenseType = parts[7].trim();
        String coursePackage = parts[8].trim();
        String registrationDate = parts[9].trim();

        int age = 0;
        try {
            age = Integer.parseInt(parts[10].trim());
        } catch (NumberFormatException e) {
            System.err.println("Error parsing age: '" + parts[10] + "' for student: " + studentId);
            age = 0;
        }

        String gender = parts[11].trim();

        return new Student(
                studentId, name, nic, phone, email,
                address, password, licenseType, coursePackage,
                registrationDate, age, gender
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