package dao;

import model.Vehicle;
import java.io.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

public class VehicleDAO {
    private static final String filePath = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main/data/vehicles.txt";

    // Generate next vehicle ID (V001, V002)
    public String generateNextVehicleId() {
        List<Vehicle> vehicles = getAllVehicles();
        int nextId = vehicles.size() + 1;
        return String.format("V%03d", nextId);
    }

    // Check if registration number already exists
    public boolean isRegistrationNumberExists(String regNumber, String excludeId) {
        List<Vehicle> vehicles = getAllVehicles();
        return vehicles.stream()
                .filter(v -> !v.getVehicleId().equals(excludeId))
                .anyMatch(v -> v.getRegistrationNumber().equalsIgnoreCase(regNumber));
    }

    // Add new vehicle
    public boolean addVehicle(Vehicle vehicle) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(vehicleToLine(vehicle));
            writer.newLine();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update vehicle
    public boolean updateVehicle(Vehicle updatedVehicle) {
        List<Vehicle> vehicles = getAllVehicles();
        boolean found = false;

        for (int i = 0; i < vehicles.size(); i++) {
            if (vehicles.get(i).getVehicleId().equals(updatedVehicle.getVehicleId())) {
                vehicles.set(i, updatedVehicle);
                found = true;
                break;
            }
        }
        return found && saveAllVehicles(vehicles);
    }

    // Delete vehicle (soft delete - change status to Decommissioned)
    public boolean deleteVehicle(String vehicleId) {
        List<Vehicle> vehicles = getAllVehicles();
        for (Vehicle vehicle : vehicles) {
            if (vehicle.getVehicleId().equals(vehicleId)) {
                vehicle.setStatus("Decommissioned");
                return saveAllVehicles(vehicles);
            }
        }
        return false;
    }

    // Hard delete (permanent removal)
    public boolean hardDeleteVehicle(String vehicleId) {
        List<Vehicle> vehicles = getAllVehicles();
        boolean removed = vehicles.removeIf(v -> v.getVehicleId().equals(vehicleId));
        return removed && saveAllVehicles(vehicles);
    }

    // Get vehicle by ID
    public Vehicle getVehicleById(String vehicleId) {
        return getAllVehicles().stream()
                .filter(v -> v.getVehicleId().equals(vehicleId))
                .findFirst()
                .orElse(null);
    }

    // Get vehicle by registration number
    public Vehicle getVehicleByRegNumber(String regNumber) {
        return getAllVehicles().stream()
                .filter(v -> v.getRegistrationNumber().equalsIgnoreCase(regNumber))
                .findFirst()
                .orElse(null);
    }

    // Get all active vehicles (not decommissioned)
    public List<Vehicle> getAllActiveVehicles() {
        return getAllVehicles().stream()
                .filter(v -> !"Decommissioned".equals(v.getStatus()))
                .collect(Collectors.toList());
    }

    // Get all available vehicles (status = Available)
    public List<Vehicle> getAvailableVehicles() {
        return getAllActiveVehicles().stream()
                .filter(v -> "Available".equals(v.getStatus()))
                .collect(Collectors.toList());
    }

    // Get vehicles by transmission type
    public List<Vehicle> getVehiclesByTransmission(String transmissionType) {
        return getAllActiveVehicles().stream()
                .filter(v -> v.getTransmissionType().equals(transmissionType))
                .collect(Collectors.toList());
    }

    // Get all vehicles
    public List<Vehicle> getAllVehicles() {
        List<Vehicle> vehicles = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) {
            return vehicles;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                try {
                    vehicles.add(lineToVehicle(line));
                } catch (Exception e) {
                    System.err.println("Error parsing line: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return vehicles;
    }

    // Search vehicles by registration or model
    public List<Vehicle> searchVehicles(String keyword) {
        if (keyword == null || keyword.isEmpty()) {
            return getAllActiveVehicles();
        }
        String searchTerm = keyword.toLowerCase();
        return getAllActiveVehicles().stream()
                .filter(v -> v.getRegistrationNumber().toLowerCase().contains(searchTerm) ||
                        v.getVehicleModel().toLowerCase().contains(searchTerm))
                .collect(Collectors.toList());
    }

    // Filter by status
    public List<Vehicle> filterByStatus(String status) {
        if (status == null || status.isEmpty() || "All".equals(status)) {
            return getAllActiveVehicles();
        }
        return getAllActiveVehicles().stream()
                .filter(v -> v.getStatus().equals(status))
                .collect(Collectors.toList());
    }

    // Filter by transmission type
    public List<Vehicle> filterByTransmission(String transmission) {
        if (transmission == null || transmission.isEmpty() || "All".equals(transmission)) {
            return getAllActiveVehicles();
        }
        return getAllActiveVehicles().stream()
                .filter(v -> v.getTransmissionType().equals(transmission))
                .collect(Collectors.toList());
    }

    // Get vehicles needing maintenance (maintenance overdue or upcoming)
    public List<Vehicle> getVehiclesNeedingMaintenance() {
        LocalDate today = LocalDate.now();
        return getAllActiveVehicles().stream()
                .filter(v -> {
                    if (v.getLastMaintenanceDate() == null || v.getLastMaintenanceDate().isEmpty()) {
                        return true;
                    }
                    LocalDate lastMaintenance = LocalDate.parse(v.getLastMaintenanceDate());
                    long daysSinceMaintenance = java.time.temporal.ChronoUnit.DAYS.between(lastMaintenance, today);
                    return daysSinceMaintenance >= 90; // Maintenance due every 90 days
                })
                .collect(Collectors.toList());
    }

    // Assign vehicle to instructor
    public boolean assignVehicle(String vehicleId, String instructorName) {
        Vehicle vehicle = getVehicleById(vehicleId);
        if (vehicle != null && "Available".equals(vehicle.getStatus())) {
            vehicle.setAssignedInstructor(instructorName);
            vehicle.setStatus("In-Use");
            return updateVehicle(vehicle);
        }
        return false;
    }

    // Return vehicle (make available)
    public boolean returnVehicle(String vehicleId) {
        Vehicle vehicle = getVehicleById(vehicleId);
        if (vehicle != null && "In-Use".equals(vehicle.getStatus())) {
            vehicle.setAssignedInstructor("");
            vehicle.setStatus("Available");
            return updateVehicle(vehicle);
        }
        return false;
    }

    // Update mileage
    public boolean updateMileage(String vehicleId, int newMileage) {
        Vehicle vehicle = getVehicleById(vehicleId);
        if (vehicle != null && newMileage > vehicle.getMileage()) {
            vehicle.setMileage(newMileage);
            return updateVehicle(vehicle);
        }
        return false;
    }

    // Get vehicles by assigned instructor
    public List<Vehicle> getVehiclesByInstructor(String instructorName) {
        return getAllActiveVehicles().stream()
                .filter(v -> instructorName.equals(v.getAssignedInstructor()))
                .collect(Collectors.toList());
    }

    // Get vehicle statistics
    public Map<String, Long> getVehicleStatistics() {
        Map<String, Long> stats = new HashMap<>();
        List<Vehicle> activeVehicles = getAllActiveVehicles();

        stats.put("total", (long) activeVehicles.size());
        stats.put("available", activeVehicles.stream().filter(v -> "Available".equals(v.getStatus())).count());
        stats.put("inUse", activeVehicles.stream().filter(v -> "In-Use".equals(v.getStatus())).count());
        stats.put("maintenance", activeVehicles.stream().filter(v -> "Maintenance".equals(v.getStatus())).count());
        stats.put("manual", activeVehicles.stream().filter(v -> "Manual".equals(v.getTransmissionType())).count());
        stats.put("automatic", activeVehicles.stream().filter(v -> "Automatic".equals(v.getTransmissionType())).count());

        return stats;
    }

    // Convert Vehicle to CSV line
    private String vehicleToLine(Vehicle v) {
        return String.join(",",
                v.getVehicleId(),
                v.getRegistrationNumber(),
                v.getVehicleModel(),
                v.getTransmissionType(),
                v.getFuelType(),
                v.getStatus(),
                v.getLastMaintenanceDate() != null ? v.getLastMaintenanceDate() : "",
                v.getAssignedInstructor() != null ? v.getAssignedInstructor() : "",
                String.valueOf(v.getMileage()),
                v.getAddedDate()
        );
    }

    // Convert CSV line to Vehicle
    private Vehicle lineToVehicle(String line) {
        String[] parts = line.split(",", -1);

        if (parts.length < 10) {
            throw new IllegalArgumentException("Invalid line format");
        }

        return new Vehicle(
                parts[0].trim(),
                parts[1].trim(),
                parts[2].trim(),
                parts[3].trim(),
                parts[4].trim(),
                parts[5].trim(),
                parts[6].trim(),
                parts[7].trim(),
                Integer.parseInt(parts[8].trim()),
                parts[9].trim()
        );
    }

    // Save all vehicles to file
    private boolean saveAllVehicles(List<Vehicle> vehicles) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Vehicle v : vehicles) {
                writer.write(vehicleToLine(v));
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}