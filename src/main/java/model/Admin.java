package com.drivingschool.model;

public class Admin {
    private String adminId;
    private String name;
    private String email;
    private String password;

    // Constructor
    public Admin(String adminId, String name, String email, String password) {
        this.adminId = adminId;
        this.name = name;
        this.email = email;
        this.password = password;
    }

    // Default constructor
    public Admin() {
    }

    // Getters and Setters
    public String getAdminId() {
        return adminId;
    }

    public void setAdminId(String adminId) {
        this.adminId = adminId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    // Display Admin info
    public void displayInfo() {
        System.out.println("Admin ID: " + adminId);
        System.out.println("Name: " + name);
        System.out.println("Email: " + email);
    }
}
