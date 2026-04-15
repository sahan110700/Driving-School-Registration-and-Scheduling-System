package model;

public class Vehicle {
    private String vehicleId;
    private String registrationNumber;    // Vehicle license plate
    private String vehicleModel;           // Make and model
    private String transmissionType;       // Manual / Automatic
    private String fuelType;               // Petrol, Diesel, Hybrid
    private String status;                 // Available, In-Use, Maintenance
    private String lastMaintenanceDate;    // Last service date
    private String assignedInstructor;     // Current instructor using vehicle
    private int mileage;                   // Current odometer reading in km
    private String addedDate;              // Date vehicle was added to system

    public Vehicle(String vehicleId, String registrationNumber, String vehicleModel,
                   String transmissionType, String fuelType, String status,
                   String lastMaintenanceDate, String assignedInstructor,
                   int mileage, String addedDate) {
        this.vehicleId = vehicleId;
        this.registrationNumber = registrationNumber;
        this.vehicleModel = vehicleModel;
        this.transmissionType = transmissionType;
        this.fuelType = fuelType;
        this.status = status;
        this.lastMaintenanceDate = lastMaintenanceDate;
        this.assignedInstructor = assignedInstructor;
        this.mileage = mileage;
        this.addedDate = addedDate;
    }

    // Getters and Setters
    public String getVehicleId() { return vehicleId; }
    public void setVehicleId(String vehicleId) { this.vehicleId = vehicleId; }

    public String getRegistrationNumber() { return registrationNumber; }
    public void setRegistrationNumber(String registrationNumber) { this.registrationNumber = registrationNumber; }

    public String getVehicleModel() { return vehicleModel; }
    public void setVehicleModel(String vehicleModel) { this.vehicleModel = vehicleModel; }

    public String getTransmissionType() { return transmissionType; }
    public void setTransmissionType(String transmissionType) { this.transmissionType = transmissionType; }

    public String getFuelType() { return fuelType; }
    public void setFuelType(String fuelType) { this.fuelType = fuelType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getLastMaintenanceDate() { return lastMaintenanceDate; }
    public void setLastMaintenanceDate(String lastMaintenanceDate) { this.lastMaintenanceDate = lastMaintenanceDate; }

    public String getAssignedInstructor() { return assignedInstructor; }
    public void setAssignedInstructor(String assignedInstructor) { this.assignedInstructor = assignedInstructor; }

    public int getMileage() { return mileage; }
    public void setMileage(int mileage) { this.mileage = mileage; }

    public String getAddedDate() { return addedDate; }
    public void setAddedDate(String addedDate) { this.addedDate = addedDate; }
}