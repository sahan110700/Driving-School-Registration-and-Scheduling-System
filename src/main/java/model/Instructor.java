package model;

public class Instructor {
    private String instructorId;
    private String name;              // Full Name
    private String nic;               // NIC Number (unique)
    private String phone;             // Contact Number
    private String email;             // Email Address
    private String address;           // Residential Address
    private String password;          // Login Password
    private String licenseNumber;     // INS/DL/xxxxx (unique)
    private String specialization;    // Manual/Automatic/Both
    private int experience;           // Years of experience (0-50)
    private String availability;      // Available/Busy/On Leave
    private String gender;            // Male/Female
    private String status;            // ACTIVE/INACTIVE
    private String joinDate;          // Date joined

    public Instructor(String instructorId, String name, String nic, String phone,
                      String email, String address, String password,
                      String licenseNumber, String specialization, int experience,
                      String availability, String gender, String status, String joinDate) {
        this.instructorId = instructorId;
        this.name = name;
        this.nic = nic;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.password = password;
        this.licenseNumber = licenseNumber;
        this.specialization = specialization;
        this.experience = experience;
        this.availability = availability;
        this.gender = gender;
        this.status = status;
        this.joinDate = joinDate;
    }

    // Getters and Setters
    public String getInstructorId() { return instructorId; }
    public void setInstructorId(String instructorId) { this.instructorId = instructorId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getNic() { return nic; }
    public void setNic(String nic) { this.nic = nic; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getLicenseNumber() { return licenseNumber; }
    public void setLicenseNumber(String licenseNumber) { this.licenseNumber = licenseNumber; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public int getExperience() { return experience; }
    public void setExperience(int experience) { this.experience = experience; }

    public String getAvailability() { return availability; }
    public void setAvailability(String availability) { this.availability = availability; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getJoinDate() { return joinDate; }
    public void setJoinDate(String joinDate) { this.joinDate = joinDate; }
}