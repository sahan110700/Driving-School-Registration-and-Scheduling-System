package dao;

import model.Instructor;
import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

public class InstructorDAO {
    private static final String filePath = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main/data/instructors.txt";

    // Generate next instructor ID (INS001, INS002)
    public String generateNextInstructorId() {
        List<Instructor> instructors = getAllInstructors();
        int nextId = instructors.size() + 1;
        return String.format("INS%03d", nextId);
    }

    // Check if NIC already exists
    public boolean isNicExists(String nic, String excludeId) {
        List<Instructor> instructors = getAllInstructors();
        return instructors.stream()
                .filter(i -> !i.getInstructorId().equals(excludeId))
                .anyMatch(i -> i.getNic().equals(nic));
    }

    // Check if License Number already exists
    public boolean isLicenseNumberExists(String licenseNumber, String excludeId) {
        List<Instructor> instructors = getAllInstructors();
        return instructors.stream()
                .filter(i -> !i.getInstructorId().equals(excludeId))
                .anyMatch(i -> i.getLicenseNumber().equals(licenseNumber));
    }

    // Add new instructor
    public boolean addInstructor(Instructor instructor) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(instructorToLine(instructor));
            writer.newLine();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update instructor
    public boolean updateInstructor(Instructor updatedInstructor) {
        List<Instructor> instructors = getAllInstructors();
        boolean found = false;

        for (int i = 0; i < instructors.size(); i++) {
            if (instructors.get(i).getInstructorId().equals(updatedInstructor.getInstructorId())) {
                instructors.set(i, updatedInstructor);
                found = true;
                break;
            }
        }
        return found && saveAllInstructors(instructors);
    }

    // Delete instructor (soft delete - change status to INACTIVE)
    public boolean deleteInstructor(String instructorId) {
        List<Instructor> instructors = getAllInstructors();
        for (Instructor instructor : instructors) {
            if (instructor.getInstructorId().equals(instructorId)) {
                instructor.setStatus("INACTIVE");
                return saveAllInstructors(instructors);
            }
        }
        return false;
    }

    // Hard delete (permanent removal)
    public boolean hardDeleteInstructor(String instructorId) {
        List<Instructor> instructors = getAllInstructors();
        boolean removed = instructors.removeIf(i -> i.getInstructorId().equals(instructorId));
        return removed && saveAllInstructors(instructors);
    }

    // Get instructor by ID
    public Instructor getInstructorById(String instructorId) {
        return getAllInstructors().stream()
                .filter(i -> i.getInstructorId().equals(instructorId))
                .findFirst()
                .orElse(null);
    }

    // Get all active instructors (status = ACTIVE)
    public List<Instructor> getAllActiveInstructors() {
        return getAllInstructors().stream()
                .filter(i -> "ACTIVE".equals(i.getStatus()))
                .collect(Collectors.toList());
    }

    // Get all instructors (including inactive)
    public List<Instructor> getAllInstructors() {
        List<Instructor> instructors = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) {
            return instructors;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                try {
                    instructors.add(lineToInstructor(line));
                } catch (Exception e) {
                    System.err.println("Error parsing line: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return instructors;
    }

    // Search instructors by name
    public List<Instructor> searchByName(String name) {
        return getAllActiveInstructors().stream()
                .filter(i -> i.getName().toLowerCase().contains(name.toLowerCase()))
                .collect(Collectors.toList());
    }

    // Filter by specialization
    public List<Instructor> filterBySpecialization(String specialization) {
        return getAllActiveInstructors().stream()
                .filter(i -> i.getSpecialization().equals(specialization))
                .collect(Collectors.toList());
    }

    // Filter by availability
    public List<Instructor> filterByAvailability(String availability) {
        return getAllActiveInstructors().stream()
                .filter(i -> i.getAvailability().equals(availability))
                .collect(Collectors.toList());
    }

    // Advanced search with multiple filters
    public List<Instructor> searchInstructors(String name, String specialization, String availability) {
        return getAllActiveInstructors().stream()
                .filter(i -> name == null || name.isEmpty() ||
                        i.getName().toLowerCase().contains(name.toLowerCase()))
                .filter(i -> specialization == null || specialization.isEmpty() ||
                        i.getSpecialization().equals(specialization))
                .filter(i -> availability == null || availability.isEmpty() ||
                        i.getAvailability().equals(availability))
                .collect(Collectors.toList());
    }

    // Get instructors who can teach specific transmission type
    public List<Instructor> getInstructorsByTransmission(String transmissionType) {
        return getAllActiveInstructors().stream()
                .filter(i -> "Both".equals(i.getSpecialization()) ||
                        i.getSpecialization().equals(transmissionType))
                .collect(Collectors.toList());
    }

    // Get available instructors at specific time (simplified version)
    public List<Instructor> getAvailableInstructors(String date, String time) {
        // This is a simplified version - in real implementation, you'd check test schedules
        return getAllActiveInstructors().stream()
                .filter(i -> "Available".equals(i.getAvailability()))
                .collect(Collectors.toList());
    }

    // Convert Instructor to CSV line
    private String instructorToLine(Instructor i) {
        return String.join(",",
                i.getInstructorId(),
                i.getName(),
                i.getNic(),
                i.getPhone(),
                i.getEmail(),
                i.getAddress(),
                i.getPassword(),
                i.getLicenseNumber(),
                i.getSpecialization(),
                String.valueOf(i.getExperience()),
                i.getAvailability(),
                i.getGender(),
                i.getStatus(),
                i.getJoinDate()
        );
    }

    // Convert CSV line to Instructor
    private Instructor lineToInstructor(String line) {
        String[] parts = line.split(",", -1);

        if (parts.length < 14) {
            throw new IllegalArgumentException("Invalid line format");
        }

        return new Instructor(
                parts[0].trim(),  // instructorId
                parts[1].trim(),  // name
                parts[2].trim(),  // nic
                parts[3].trim(),  // phone
                parts[4].trim(),  // email
                parts[5].trim(),  // address
                parts[6].trim(),  // password
                parts[7].trim(),  // licenseNumber
                parts[8].trim(),  // specialization
                Integer.parseInt(parts[9].trim()), // experience
                parts[10].trim(), // availability
                parts[11].trim(), // gender
                parts[12].trim(), // status
                parts[13].trim()  // joinDate
        );
    }

    // Save all instructors to file
    private boolean saveAllInstructors(List<Instructor> instructors) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Instructor i : instructors) {
                writer.write(instructorToLine(i));
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}