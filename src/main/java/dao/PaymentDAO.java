package dao;

import model.Payment;
import model.Student;
import java.io.*;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

public class PaymentDAO {
    private final String filePath = "payments.txt";
    private StudentDAO studentDAO = new StudentDAO();

    // Generate next payment ID (P001, P002)
    public String generateNextPaymentId() {
        List<Payment> payments = getAllPayments();
        int nextId = payments.size() + 1;
        return String.format("P%03d", nextId);
    }

    // Get total paid amount for a student
    public double getTotalPaidForStudent(String studentId) {
        return getAllPayments().stream()
                .filter(p -> p.getStudentId().equals(studentId))
                .filter(p -> !"Pending".equals(p.getPaymentStatus()))
                .mapToDouble(Payment::getPaymentAmount)
                .sum();
    }

    // Get course fee based on package type
    public double getCourseFee(String packageType) {
        switch (packageType) {
            case "Basic":
                return 299.00;
            case "Standard":
                return 499.00;
            case "Premium":
                return 799.00;
            default:
                return 0.00;
        }
    }

    // Add new payment
    public boolean addPayment(Payment payment) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(paymentToLine(payment));
            writer.newLine();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update payment
    public boolean updatePayment(Payment updatedPayment) {
        List<Payment> payments = getAllPayments();
        boolean found = false;

        for (int i = 0; i < payments.size(); i++) {
            if (payments.get(i).getPaymentId().equals(updatedPayment.getPaymentId())) {
                payments.set(i, updatedPayment);
                found = true;
                break;
            }
        }
        return found && saveAllPayments(payments);
    }

    // Delete payment
    public boolean deletePayment(String paymentId) {
        List<Payment> payments = getAllPayments();
        boolean removed = payments.removeIf(p -> p.getPaymentId().equals(paymentId));
        return removed && saveAllPayments(payments);
    }

    // Get payment by ID
    public Payment getPaymentById(String paymentId) {
        return getAllPayments().stream()
                .filter(p -> p.getPaymentId().equals(paymentId))
                .findFirst()
                .orElse(null);
    }

    // Get all payments
    public List<Payment> getAllPayments() {
        List<Payment> payments = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) {
            return payments;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                try {
                    payments.add(lineToPayment(line));
                } catch (Exception e) {
                    System.err.println("Error parsing line: " + line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return payments;
    }

    // Get payments by student
    public List<Payment> getPaymentsByStudent(String studentId) {
        return getAllPayments().stream()
                .filter(p -> p.getStudentId().equals(studentId))
                .sorted(Comparator.comparing(Payment::getPaymentDate).reversed())
                .collect(Collectors.toList());
    }

    // Get payment summary for all students
    public List<Map<String, Object>> getPaymentSummary() {
        List<Student> students = studentDAO.getAllActiveStudents();
        List<Map<String, Object>> summary = new ArrayList<>();

        for (Student student : students) {
            double totalPaid = getTotalPaidForStudent(student.getStudentId());
            double totalFee = getCourseFee(student.getCoursePackage());
            double balanceDue = totalFee - totalPaid;

            Map<String, Object> studentSummary = new HashMap<>();
            studentSummary.put("studentId", student.getStudentId());
            studentSummary.put("studentName", student.getName());
            studentSummary.put("packageType", student.getCoursePackage());
            studentSummary.put("totalFee", totalFee);
            studentSummary.put("totalPaid", totalPaid);
            studentSummary.put("balanceDue", balanceDue);

            String status;
            if (balanceDue <= 0) {
                status = "Completed";
            } else if (totalPaid > 0) {
                status = "Partial";
            } else {
                status = "Pending";
            }
            studentSummary.put("status", status);

            summary.add(studentSummary);
        }

        return summary;
    }

    // Filter payments by status
    public List<Map<String, Object>> filterPaymentsByStatus(String status) {
        return getPaymentSummary().stream()
                .filter(p -> status.equals(p.get("status")))
                .collect(Collectors.toList());
    }

    // Search payments by student name
    public List<Map<String, Object>> searchPaymentsByStudentName(String searchTerm) {
        return getPaymentSummary().stream()
                .filter(p -> ((String) p.get("studentName")).toLowerCase()
                        .contains(searchTerm.toLowerCase()))
                .collect(Collectors.toList());
    }

    // Get payment history with filters
    public List<Payment> getPaymentHistory(String studentId, String startDate, String endDate) {
        return getAllPayments().stream()
                .filter(p -> studentId == null || p.getStudentId().equals(studentId))
                .filter(p -> startDate == null || p.getPaymentDate().compareTo(startDate) >= 0)
                .filter(p -> endDate == null || p.getPaymentDate().compareTo(endDate) <= 0)
                .sorted(Comparator.comparing(Payment::getPaymentDate).reversed())
                .collect(Collectors.toList());
    }

    // Get total revenue
    public double getTotalRevenue() {
        return getAllPayments().stream()
                .filter(p -> !"Pending".equals(p.getPaymentStatus()))
                .mapToDouble(Payment::getPaymentAmount)
                .sum();
    }

    // Get revenue by payment method
    public Map<String, Double> getRevenueByMethod() {
        return getAllPayments().stream()
                .filter(p -> !"Pending".equals(p.getPaymentStatus()))
                .collect(Collectors.groupingBy(
                        Payment::getPaymentMethod,
                        Collectors.summingDouble(Payment::getPaymentAmount)
                ));
    }

    // Get monthly revenue
    public Map<String, Double> getMonthlyRevenue() {
        return getAllPayments().stream()
                .filter(p -> !"Pending".equals(p.getPaymentStatus()))
                .collect(Collectors.groupingBy(
                        p -> p.getPaymentDate().substring(0, 7),
                        Collectors.summingDouble(Payment::getPaymentAmount)
                ));
    }

    // Convert Payment to CSV line
    private String paymentToLine(Payment p) {
        return String.join(",",
                p.getPaymentId(),
                p.getStudentId(),
                p.getStudentName(),
                String.valueOf(p.getPaymentAmount()),
                p.getPaymentDate(),
                p.getPaymentMethod(),
                p.getPackageType(),
                String.valueOf(p.getTotalFee()),
                String.valueOf(p.getBalanceDue()),
                p.getPaymentStatus(),
                p.getReferenceNumber(),
                p.getRecordedBy()
        );
    }

    // Convert CSV line to Payment
    private Payment lineToPayment(String line) {
        String[] parts = line.split(",", -1);

        if (parts.length < 12) {
            throw new IllegalArgumentException("Invalid line format");
        }

        return new Payment(
                parts[0].trim(),
                parts[1].trim(),
                parts[2].trim(),
                Double.parseDouble(parts[3].trim()),
                parts[4].trim(),
                parts[5].trim(),
                parts[6].trim(),
                Double.parseDouble(parts[7].trim()),
                Double.parseDouble(parts[8].trim()),
                parts[9].trim(),
                parts[10].trim(),
                parts[11].trim()
        );
    }

    // Save all payments to file
    private boolean saveAllPayments(List<Payment> payments) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Payment p : payments) {
                writer.write(paymentToLine(p));
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}