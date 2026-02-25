package com.smileproiz.util;

import com.smileproiz.model.User;
import com.smileproiz.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class AllUsersPasswordHasher implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public void run(String... args) throws Exception {
        User admin = userRepository.findByEmail("admin@gmail.com").orElse(null);

        if (admin != null) {
            // Обнуляем пароль и захешируем новый
            String newPassword = "admin123";
            admin.setPassword(passwordEncoder.encode(newPassword));
            userRepository.save(admin);
            System.out.println("✅ Admin password reset and hashed: " + admin.getEmail());
        } else {
            System.out.println("⚠️ Admin not found in DB");
        }
    }
}