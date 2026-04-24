package dao;

import model.Instructor;
import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

public class InstructorDAO {
    private static final String filePath = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main/data/instructors.txt";

    public String generateNextInstructorId() {
        List<Instructor> instructors = getAllInstructors();
        int nextId = instructors.size() + 1;
        return String.format("INS%03d", nextId);
    }

    public boolean isNicExists(String nic, String excludeId) {
        return getAllInstructors().stream()
                .filter(i -> !i.getInstructorId().equals(excludeId))
                .anyMatch(i -> i.getNic().equals(nic));
    }

    public boolean isLicenseNumberExists(String licenseNumber, String excludeId) {
        return getAllInstructors().stream()
                .filter(i -> !i.getInstructorId().equals(excludeId))
                .anyMatch(i -> i.getLicenseNumber().equals(licenseNumber));
    }

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

    // Soft delete — sets INACTIVE in instructors.txt AND blocks login in users.txt
    public boolean deleteInstructor(String instructorId) {
        Instructor instructor = getInstructorById(instructorId);
        if (instructor == null) return false;

        List<Instructor> instructors = getAllInstructors();
        for (Instructor i : instructors) {
            if (i.getInstructorId().equals(instructorId)) {
                i.setStatus("INACTIVE");
                if (saveAllInstructors(instructors)) {
                    // Block login by marking user deleted in users.txt using their email
                    new UserDAO().markUserDeletedByEmail(instructor.getEmail());
                    System.out.println("[InstructorDAO] Deactivated + blocked login for: " + instructor.getEmail());
                    return true;
                }
                return false;
            }
        }
        return false;
    }

    // Hard delete — removes from instructors.txt AND blocks login in users.txt
    public boolean hardDeleteInstructor(String instructorId) {
        Instructor instructor = getInstructorById(instructorId);
        if (instructor == null) return false;

        List<Instructor> instructors = getAllInstructors();
        boolean removed = instructors.removeIf(i -> i.getInstructorId().equals(instructorId));

        if (removed && saveAllInstructors(instructors)) {
            new UserDAO().markUserDeletedByEmail(instructor.getEmail());
            System.out.println("[InstructorDAO] Hard deleted + blocked login for: " + instructor.getEmail());
            return true;
        }
        return false;
    }

    public Instructor getInstructorById(String instructorId) {
        return getAllInstructors().stream()
                .filter(i -> i.getInstructorId().equals(instructorId))
                .findFirst()
                .orElse(null);
    }

    public List<Instructor> getAllActiveInstructors() {
        return getAllInstructors().stream()
                .filter(i -> "ACTIVE".equals(i.getStatus()))
                .collect(Collectors.toList());
    }

    public List<Instructor> getAllInstructors() {
        List<Instructor> instructors = new ArrayList<>();
        File file = new File(filePath);
        if (!file.exists()) return instructors;

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

    public List<Instructor> searchByName(String name) {
        return getAllActiveInstructors().stream()
                .filter(i -> i.getName().toLowerCase().contains(name.toLowerCase()))
                .collect(Collectors.toList());
    }

    public List<Instructor> filterBySpecialization(String specialization) {
        return getAllActiveInstructors().stream()
                .filter(i -> i.getSpecialization().equals(specialization))
                .collect(Collectors.toList());
    }

    public List<Instructor> filterByAvailability(String availability) {
        return getAllActiveInstructors().stream()
                .filter(i -> i.getAvailability().equals(availability))
                .collect(Collectors.toList());
    }

    public List<Instructor> searchInstructors(String name, String specialization, String availability) {
        return getAllActiveInstructors().stream()
                .filter(i -> name == null || name.isEmpty() || i.getName().toLowerCase().contains(name.toLowerCase()))
                .filter(i -> specialization == null || specialization.isEmpty() || i.getSpecialization().equals(specialization))
                .filter(i -> availability == null || availability.isEmpty() || i.getAvailability().equals(availability))
                .collect(Collectors.toList());
    }

    public List<Instructor> getInstructorsByTransmission(String transmissionType) {
        return getAllActiveInstructors().stream()
                .filter(i -> "Both".equals(i.getSpecialization()) || i.getSpecialization().equals(transmissionType))
                .collect(Collectors.toList());
    }

    public List<Instructor> getAvailableInstructors(String date, String time) {
        return getAllActiveInstructors().stream()
                .filter(i -> "Available".equals(i.getAvailability()))
                .collect(Collectors.toList());
    }

    private String instructorToLine(Instructor i) {
        return String.join(",",
                i.getInstructorId(), i.getName(), i.getNic(), i.getPhone(),
                i.getEmail(), i.getAddress(), i.getPassword(), i.getLicenseNumber(),
                i.getSpecialization(), String.valueOf(i.getExperience()),
                i.getAvailability(), i.getGender(), i.getStatus(), i.getJoinDate()
        );
    }

    private Instructor lineToInstructor(String line) {
        String[] parts = line.split(",", -1);
        if (parts.length < 14) throw new IllegalArgumentException("Invalid line format");

        return new Instructor(
                parts[0].trim(), parts[1].trim(), parts[2].trim(), parts[3].trim(),
                parts[4].trim(), parts[5].trim(), parts[6].trim(), parts[7].trim(),
                parts[8].trim(), Integer.parseInt(parts[9].trim()),
                parts[10].trim(), parts[11].trim(), parts[12].trim(), parts[13].trim()
        );
    }

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