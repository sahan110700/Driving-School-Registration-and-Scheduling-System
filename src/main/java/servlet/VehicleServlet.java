package servlet;

import dao.VehicleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Vehicle;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/vehicles")
public class VehicleServlet extends HttpServlet {

    private final VehicleDAO vehicleDAO = new VehicleDAO();

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
            String vehicleId = req.getParameter("id");
            if (vehicleId != null) {
                vehicleDAO.deleteVehicle(vehicleId);
            }
            resp.sendRedirect(req.getContextPath() + "/vehicles?success=deleted");
            return;
        }

        // Handle assign
        if ("assign".equals(action)) {
            String vehicleId = req.getParameter("id");
            req.setAttribute("vehicleId", vehicleId);
            req.getRequestDispatcher("/jsp/assign-vehicle.jsp").forward(req, resp);
            return;
        }

        // Handle return
        if ("return".equals(action)) {
            String vehicleId = req.getParameter("id");
            if (vehicleId != null && vehicleDAO.returnVehicle(vehicleId)) {
                resp.sendRedirect(req.getContextPath() + "/vehicles?success=returned");
            } else {
                resp.sendRedirect(req.getContextPath() + "/vehicles?error=returnFailed");
            }
            return;
        }

        // Handle edit form
        if ("edit".equals(action)) {
            String vehicleId = req.getParameter("id");
            Vehicle vehicle = vehicleDAO.getVehicleById(vehicleId);
            req.setAttribute("vehicle", vehicle);
            req.getRequestDispatcher("/jsp/edit-vehicle.jsp").forward(req, resp);
            return;
        }

        // Handle add form
        if ("add-form".equals(action)) {
            req.setAttribute("vehicle", null);
            req.getRequestDispatcher("/jsp/edit-vehicle.jsp").forward(req, resp);
            return;
        }

        // Handle search and filter
        String search = req.getParameter("search");
        String status = req.getParameter("status");

        List<Vehicle> vehicleList;

        if ((search != null && !search.isEmpty()) || (status != null && !status.isEmpty() && !"All".equals(status))) {
            vehicleList = vehicleDAO.searchVehicles(search);
            vehicleList = vehicleDAO.filterByStatus(status);
            // Combine both filters
            if (search != null && !search.isEmpty()) {
                vehicleList = vehicleDAO.searchVehicles(search);
                if (status != null && !status.isEmpty() && !"All".equals(status)) {
                    vehicleList.removeIf(v -> !v.getStatus().equals(status));
                }
            } else if (status != null && !status.isEmpty() && !"All".equals(status)) {
                vehicleList = vehicleDAO.filterByStatus(status);
            } else {
                vehicleList = vehicleDAO.getAllActiveVehicles();
            }
        } else {
            vehicleList = vehicleDAO.getAllActiveVehicles();
        }

        req.setAttribute("vehicleList", vehicleList);
        req.setAttribute("searchKeyword", search);
        req.setAttribute("selectedStatus", status);
        req.getRequestDispatcher("/jsp/vehicles.jsp").forward(req, resp);
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

        // Handle assign submission
        if ("assign-submit".equals(action)) {
            String vehicleId = req.getParameter("vehicleId");
            String instructorName = req.getParameter("instructorName");

            if (vehicleId != null && instructorName != null && !instructorName.isEmpty()) {
                if (vehicleDAO.assignVehicle(vehicleId, instructorName)) {
                    resp.sendRedirect(req.getContextPath() + "/vehicles?success=assigned");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/vehicles?error=assignFailed");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/vehicles?error=invalidData");
            }
            return;
        }

        // Get form data
        String registrationNumber = req.getParameter("registrationNumber");
        String vehicleModel = req.getParameter("vehicleModel");
        String transmissionType = req.getParameter("transmissionType");
        String fuelType = req.getParameter("fuelType");
        String status = req.getParameter("status");
        String lastMaintenanceDate = req.getParameter("lastMaintenanceDate");
        String assignedInstructor = req.getParameter("assignedInstructor");
        String mileageText = req.getParameter("mileage");

        // Validate required fields
        if (registrationNumber == null || registrationNumber.isEmpty() ||
                vehicleModel == null || vehicleModel.isEmpty() ||
                transmissionType == null || transmissionType.isEmpty() ||
                fuelType == null || fuelType.isEmpty() ||
                status == null || status.isEmpty() ||
                mileageText == null || mileageText.isEmpty()) {

            String redirect = ("update".equals(action)) ?
                    "/vehicles?action=edit&id=" + req.getParameter("vehicleId") + "&error=empty" :
                    "/vehicles?action=add-form&error=empty";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        // Validate mileage
        int mileage;
        try {
            mileage = Integer.parseInt(mileageText);
            if (mileage < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            String redirect = ("update".equals(action)) ?
                    "/vehicles?action=edit&id=" + req.getParameter("vehicleId") + "&error=mileage" :
                    "/vehicles?action=add-form&error=mileage";
            resp.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        if (assignedInstructor == null) assignedInstructor = "";

        // Handle update
        if ("update".equals(action)) {
            String vehicleId = req.getParameter("vehicleId");

            // Check uniqueness for update
            if (vehicleDAO.isRegistrationNumberExists(registrationNumber, vehicleId)) {
                resp.sendRedirect(req.getContextPath() + "/vehicles?action=edit&id=" + vehicleId + "&error=regExists");
                return;
            }

            Vehicle existingVehicle = vehicleDAO.getVehicleById(vehicleId);
            String addedDate = existingVehicle.getAddedDate();

            Vehicle vehicle = new Vehicle(
                    vehicleId, registrationNumber, vehicleModel, transmissionType,
                    fuelType, status, lastMaintenanceDate, assignedInstructor,
                    mileage, addedDate
            );

            boolean success = vehicleDAO.updateVehicle(vehicle);
            resp.sendRedirect(req.getContextPath() + "/vehicles" +
                    (success ? "?success=updated" : "?error=failed"));
            return;
        }

        // Handle add
        if ("add".equals(action)) {
            // Check uniqueness for new vehicle
            if (vehicleDAO.isRegistrationNumberExists(registrationNumber, "")) {
                resp.sendRedirect(req.getContextPath() + "/vehicles?action=add-form&error=regExists");
                return;
            }

            String vehicleId = vehicleDAO.generateNextVehicleId();
            String addedDate = LocalDate.now().toString();

            Vehicle vehicle = new Vehicle(
                    vehicleId, registrationNumber, vehicleModel, transmissionType,
                    fuelType, status, lastMaintenanceDate, assignedInstructor,
                    mileage, addedDate
            );

            boolean success = vehicleDAO.addVehicle(vehicle);
            resp.sendRedirect(req.getContextPath() + "/vehicles" +
                    (success ? "?success=added" : "?action=add-form&error=failed"));
        }
    }
}