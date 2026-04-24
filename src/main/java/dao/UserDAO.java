package dao;

import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private static final String PROJECT_ROOT = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main";
    private static final String FILE_PATH = PROJECT_ROOT + "/data/users.txt";

    // users.txt format: id,username,email,password,role,status
    // status = "active" or "deleted"

    private static Path getFilePath() {
        return Paths.get(FILE_PATH);
    }

    // Returns role if login valid AND account not deleted, null otherwise
    public String validateLoginAndGetRole(String username, String password) {
        Path path = getFilePath();

        if (!Files.exists(path)) {
            System.err.println("[UserDAO] ERROR: users.txt NOT FOUND");
            return null;
        }

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;

                String[] data = line.split(",", -1);

                // Format: id,username,email,password,role[,status]
                if (data.length >= 4) {
                    String storedUsername = data[1].trim();
                    String storedPassword = data[3].trim();
                    String storedRole = (data.length >= 5) ? data[4].trim() : "student";
                    // Field 5 is status — default "active" if missing (backward compatible)
                    String storedStatus = (data.length >= 6) ? data[5].trim() : "active";

                    if (storedUsername.equals(username) && storedPassword.equals(password)) {
                        if ("deleted".equalsIgnoreCase(storedStatus)) {
                            System.out.println("[UserDAO] BLOCKED - account deleted: " + username);
                            return null; // Account was deleted by admin
                        }
                        System.out.println("[UserDAO] Login SUCCESS: " + username + " role: " + storedRole);
                        return storedRole;
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println("[UserDAO] Login FAILED for: " + username);
        return null;
    }

    // Kept for backward compatibility
    public boolean validateLogin(String username, String password) {
        return validateLoginAndGetRole(username, password) != null;
    }

    public boolean usernameExists(String username) {
        Path path = getFilePath();
        if (!Files.exists(path)) return false;

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] data = line.split(",", -1);
                if (data.length >= 2 && data[1].trim().equalsIgnoreCase(username)) {
                    return true;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean registerUser(String username, String email, String password) {
        Path path = getFilePath();

        try {
            if (!Files.exists(path)) {
                Files.createDirectories(path.getParent());
                Files.createFile(path);
            }

            String userId = generateNextUserId();
            // Added "active" status as 6th field
            String record = userId + "," + username + "," + email + "," + password + ",student,active";

            try (BufferedWriter writer = Files.newBufferedWriter(
                    path, StandardOpenOption.APPEND, StandardOpenOption.CREATE)) {
                writer.write(record);
                writer.write("\r\n");
            }
            return true;

        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Mark a user as deleted by their email (called when student/instructor is deleted)
    // Uses email because that's the unique field shared between users.txt and students/instructors.txt
    public boolean markUserDeletedByEmail(String email) {
        Path path = getFilePath();
        if (!Files.exists(path)) return false;

        List<String> updatedLines = new ArrayList<>();
        boolean found = false;

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] data = line.split(",", -1);
                // Match by email (field[2])
                if (data.length >= 3 && data[2].trim().equalsIgnoreCase(email)) {
                    // Rebuild line with status = "deleted"
                    if (data.length >= 6) {
                        data[5] = "deleted";
                    } else {
                        // Extend line to include status field
                        String[] extended = new String[6];
                        System.arraycopy(data, 0, extended, 0, data.length);
                        for (int i = data.length; i < 6; i++) extended[i] = "";
                        extended[5] = "deleted";
                        data = extended;
                    }
                    line = String.join(",", data);
                    found = true;
                    System.out.println("[UserDAO] Marked deleted: " + email);
                }
                updatedLines.add(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }

        if (!found) {
            System.out.println("[UserDAO] No user found with email: " + email);
            return false;
        }

        // Write back
        try (BufferedWriter writer = Files.newBufferedWriter(path)) {
            for (String l : updatedLines) {
                writer.write(l);
                writer.write("\r\n");
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Restore a deleted user (if needed in future)
    public boolean markUserActiveByEmail(String email) {
        Path path = getFilePath();
        if (!Files.exists(path)) return false;

        List<String> updatedLines = new ArrayList<>();
        boolean found = false;

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] data = line.split(",", -1);
                if (data.length >= 3 && data[2].trim().equalsIgnoreCase(email)) {
                    if (data.length >= 6) {
                        data[5] = "active";
                    } else {
                        String[] extended = new String[6];
                        System.arraycopy(data, 0, extended, 0, data.length);
                        for (int i = data.length; i < 6; i++) extended[i] = "";
                        extended[5] = "active";
                        data = extended;
                    }
                    line = String.join(",", data);
                    found = true;
                }
                updatedLines.add(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }

        if (!found) return false;

        try (BufferedWriter writer = Files.newBufferedWriter(path)) {
            for (String l : updatedLines) {
                writer.write(l);
                writer.write("\r\n");
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    private String generateNextUserId() {
        Path path = getFilePath();
        int count = 0;
        if (Files.exists(path)) {
            try (BufferedReader reader = Files.newBufferedReader(path)) {
                while (reader.readLine() != null) count++;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return String.format("U%03d", count + 1);
    }
}