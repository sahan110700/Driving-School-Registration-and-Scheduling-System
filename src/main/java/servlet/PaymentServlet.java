package servlet;

import dao.PaymentDAO;
import dao.StudentDAO;
import model.Payment;
import model.Student;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Check authentication
        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // Handle delete
        if ("delete".equals(action)) {
            String paymentId = req.getParameter("id");
            if (paymentId != null && paymentDAO.deletePayment(paymentId)) {
                resp.sendRedirect(req.getContextPath() + "/payments?success=deleted");
            } else {
                resp.sendRedirect(req.getContextPath() + "/payments?error=deleteFailed");
            }
            return;
        }

        // Handle add form
        if ("add-form".equals(action)) {
            req.setAttribute("students", studentDAO.getAllActiveStudents());
            req.getRequestDispatcher("/jsp/add-payment.jsp").forward(req, resp);
            return;
        }

        // Get filter parameters
        String searchStudent = req.getParameter("searchStudent");
        String filterStatus = req.getParameter("filterStatus");

        List<Map<String, Object>> paymentSummary;

        if (searchStudent != null && !searchStudent.isEmpty()) {
            paymentSummary = paymentDAO.searchPaymentsByStudentName(searchStudent);
            req.setAttribute("searchStudent", searchStudent);
        } else if (filterStatus != null && !filterStatus.isEmpty() && !"All".equals(filterStatus)) {
            paymentSummary = paymentDAO.filterPaymentsByStatus(filterStatus);
            req.setAttribute("filterStatus", filterStatus);
        } else {
            paymentSummary = paymentDAO.getPaymentSummary();
        }

        // Get statistics
        double totalRevenue = paymentDAO.getTotalRevenue();
        Map<String, Double> revenueByMethod = paymentDAO.getRevenueByMethod();
        Map<String, Double> monthlyRevenue = paymentDAO.getMonthlyRevenue();

        req.setAttribute("paymentSummary", paymentSummary);
        req.setAttribute("students", studentDAO.getAllActiveStudents());
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("revenueByMethod", revenueByMethod);
        req.setAttribute("monthlyRevenue", monthlyRevenue);
        req.getRequestDispatcher("/jsp/payments.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Check authentication
        if (req.getSession(false) == null || req.getSession(false).getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/login.jsp");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        // Handle add payment
        if ("add".equals(action)) {
            String studentId = req.getParameter("studentId");
            String paymentAmountStr = req.getParameter("paymentAmount");
            String paymentMethod = req.getParameter("paymentMethod");
            String paymentDate = req.getParameter("paymentDate");
            String referenceNumber = req.getParameter("referenceNumber");

            // Validate required fields
            if (studentId == null || studentId.isEmpty() ||
                    paymentAmountStr == null || paymentAmountStr.isEmpty() ||
                    paymentMethod == null || paymentMethod.isEmpty() ||
                    paymentDate == null || paymentDate.isEmpty()) {

                resp.sendRedirect(req.getContextPath() + "/payments?action=add-form&error=empty");
                return;
            }

            double paymentAmount;
            try {
                paymentAmount = Double.parseDouble(paymentAmountStr);
                if (paymentAmount <= 0) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/payments?action=add-form&error=invalidAmount");
                return;
            }

            // Get student details
            Student student = studentDAO.getStudentById(studentId);
            if (student == null) {
                resp.sendRedirect(req.getContextPath() + "/payments?action=add-form&error=studentNotFound");
                return;
            }

            // Calculate totals
            double totalFee = paymentDAO.getCourseFee(student.getCoursePackage());
            double totalPaid = paymentDAO.getTotalPaidForStudent(studentId) + paymentAmount;
            double balanceDue = totalFee - totalPaid;

            String paymentStatus;
            if (balanceDue <= 0) {
                paymentStatus = "Completed";
            } else if (totalPaid > 0) {
                paymentStatus = "Partial";
            } else {
                paymentStatus = "Pending";
            }

            String paymentId = paymentDAO.generateNextPaymentId();
            String recordedBy = (String) req.getSession().getAttribute("loggedInUser");

            Payment payment = new Payment(
                    paymentId, studentId, student.getName(),
                    paymentAmount, paymentDate, paymentMethod,
                    student.getCoursePackage(), totalFee, balanceDue,
                    paymentStatus, referenceNumber, recordedBy
            );

            boolean success = paymentDAO.addPayment(payment);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/payments?success=added");
            } else {
                resp.sendRedirect(req.getContextPath() + "/payments?action=add-form&error=failed");
            }
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/payments");
    }
}