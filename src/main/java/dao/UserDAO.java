package dao;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

public class UserDAO {

    // FIX: Use the absolute path to your project's data folder
    private static final String PROJECT_ROOT = "C:/Users/DELL/OneDrive/Desktop/DrivingSchoolSystem-main";
    private static final String FILE_PATH = PROJECT_ROOT + "/data/users.txt";

    private static Path getFilePath() {
        Path path = Paths.get(FILE_PATH);
        System.out.println("[UserDAO] Looking for users.txt at: " + path.toAbsolutePath());
        System.out.println("[UserDAO] File exists: " + Files.exists(path));
        return path;
    }

    // Returns role ("admin" or "student") if login valid, null if not
    public String validateLoginAndGetRole(String username, String password) {
        Path path = getFilePath();

        if (!Files.exists(path)) {
            System.err.println("[UserDAO] ERROR: users.txt NOT FOUND at: " + path.toAbsolutePath());
            return null;
        }

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;

                System.out.println("[UserDAO] Checking line: " + line);

                String[] data = line.split(",");

                // Format: id,username,email,password,role
                // e.g. U001,admin,admin@school.com,admin123,admin
                if (data.length >= 4) {
                    String storedUsername = data[1].trim();
                    String storedPassword = data[3].trim();
                    String storedRole = (data.length >= 5) ? data[4].trim() : "student";

                    System.out.println("[UserDAO] Comparing -> input: [" + username + "/" + password + "] stored: [" + storedUsername + "/" + storedPassword + "]");

                    if (storedUsername.equals(username) && storedPassword.equals(password)) {
                        System.out.println("[UserDAO] Login SUCCESS for: " + username + " role: " + storedRole);
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
                String[] data = line.split(",");
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
            String record = userId + "," + username + "," + email + "," + password + ",student";

            try (BufferedWriter writer = Files.newBufferedWriter(path, StandardOpenOption.APPEND)) {
                writer.write(record);
                writer.newLine();
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