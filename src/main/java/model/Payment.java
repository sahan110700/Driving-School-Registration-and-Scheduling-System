package model;

public class Payment {
    private String paymentId;
    private String studentId;
    private String studentName;
    private double paymentAmount;
    private String paymentDate;
    private String paymentMethod;
    private String packageType;
    private double totalFee;
    private double balanceDue;
    private String paymentStatus; // Paid, Pending, Partial
    private String referenceNumber;
    private String recordedBy;

    public Payment(String paymentId, String studentId, String studentName,
                   double paymentAmount, String paymentDate, String paymentMethod,
                   String packageType, double totalFee, double balanceDue,
                   String paymentStatus, String referenceNumber, String recordedBy) {
        this.paymentId = paymentId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.paymentAmount = paymentAmount;
        this.paymentDate = paymentDate;
        this.paymentMethod = paymentMethod;
        this.packageType = packageType;
        this.totalFee = totalFee;
        this.balanceDue = balanceDue;
        this.paymentStatus = paymentStatus;
        this.referenceNumber = referenceNumber;
        this.recordedBy = recordedBy;
    }

    // Getters and Setters
    public String getPaymentId() { return paymentId; }
    public void setPaymentId(String paymentId) { this.paymentId = paymentId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public double getPaymentAmount() { return paymentAmount; }
    public void setPaymentAmount(double paymentAmount) { this.paymentAmount = paymentAmount; }

    public String getPaymentDate() { return paymentDate; }
    public void setPaymentDate(String paymentDate) { this.paymentDate = paymentDate; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPackageType() { return packageType; }
    public void setPackageType(String packageType) { this.packageType = packageType; }

    public double getTotalFee() { return totalFee; }
    public void setTotalFee(double totalFee) { this.totalFee = totalFee; }

    public double getBalanceDue() { return balanceDue; }
    public void setBalanceDue(double balanceDue) { this.balanceDue = balanceDue; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getReferenceNumber() { return referenceNumber; }
    public void setReferenceNumber(String referenceNumber) { this.referenceNumber = referenceNumber; }

    public String getRecordedBy() { return recordedBy; }
    public void setRecordedBy(String recordedBy) { this.recordedBy = recordedBy; }

    // Helper method to get formatted amount
    public String getFormattedAmount(double amount) {
        return String.format("LKR %,d", (long) amount);
    }

    public String getFormattedPaymentAmount() {
        return getFormattedAmount(paymentAmount);
    }

    public String getFormattedTotalFee() {
        return getFormattedAmount(totalFee);
    }

    public String getFormattedBalanceDue() {
        return getFormattedAmount(balanceDue);
    }
}