package model;

public class Student {
    private String studentId;
    private String name;            // Full Name
    private String nic;             // NIC / ID Number
    private String phone;           // Contact Number
    private String email;           // Email Address
    private String address;         // Residential Address
    private String password;
    private String licenseType;     // License Type
    private String coursePackage;   // Course Package
    private String registrationDate;// Registration Date
    private int age;                // Age
    private String gender;          // Male / Female

    public Student(String studentId, String name, String nic, String phone, String email,
                   String address, String password, String licenseType, String coursePackage,
                   String registrationDate, int age, String gender) {
        this.studentId = studentId;
        this.name = name;
        this.nic = nic;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.password = password;
        this.licenseType = licenseType;
        this.coursePackage = coursePackage;
        this.registrationDate = registrationDate;
        this.age = age;
        this.gender = gender;
    }

    // Getters and Setters for all fields
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

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

    public String getLicenseType() { return licenseType; }
    public void setLicenseType(String licenseType) { this.licenseType = licenseType; }

    public String getCoursePackage() { return coursePackage; }
    public void setCoursePackage(String coursePackage) { this.coursePackage = coursePackage; }

    public String getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(String registrationDate) { this.registrationDate = registrationDate; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
}