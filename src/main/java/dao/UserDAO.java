package dao;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

public class UserDAO {

    private static final String FILE_PATH = "data/users.txt";

    public boolean validateLogin(String username, String password) {
        Path path = Paths.get(FILE_PATH);

        if (!Files.exists(path)) {
            return false;
        }

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;

            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) {
                    continue;
                }

                String[] data = line.split(",");

                if (data.length >= 4) {
                    String storedUsername = data[1].trim();
                    String storedPassword = data[3].trim();

                    if (storedUsername.equals(username) && storedPassword.equals(password)) {
                        return true;
                    }
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean usernameExists(String username) {
        Path path = Paths.get(FILE_PATH);

        if (!Files.exists(path)) {
            return false;
        }

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;

            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) {
                    continue;
                }

                String[] data = line.split(",");

                if (data.length >= 2) {
                    String storedUsername = data[1].trim();

                    if (storedUsername.equalsIgnoreCase(username)) {
                        return true;
                    }
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean registerUser(String username, String email, String password) {
        Path path = Paths.get(FILE_PATH);

        try {
            if (!Files.exists(path)) {
                Files.createDirectories(path.getParent());
                Files.createFile(path);
            }

            String userId = generateNextUserId();
            String record = userId + "," + username + "," + email + "," + password;

            try (BufferedWriter writer = Files.newBufferedWriter(
                    path,
                    StandardOpenOption.APPEND
            )) {
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
        Path path = Paths.get(FILE_PATH);
        int count = 0;

        if (Files.exists(path)) {
            try (BufferedReader reader = Files.newBufferedReader(path)) {
                while (reader.readLine() != null) {
                    count++;
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return String.format("U%03d", count + 1);
    }
}