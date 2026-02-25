package com.smileproiz.service;

import com.smileproiz.dto.PushSettingRequest;
import com.smileproiz.dto.UpdateUserDto;
import com.smileproiz.model.User;
import com.smileproiz.repository.UserRepository;
import com.smileproiz.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    // ================= REGISTRATION =================
    public User registerUser(User user) {
        user.setEmail(user.getEmail().trim().toLowerCase());

        userRepository.findByEmail(user.getEmail()).ifPresent(u -> {
            throw new RuntimeException("Пользователь с таким email уже существует");
        });

        user.setPassword(passwordEncoder.encode(user.getPassword()));

        if (user.getRole() == null || user.getRole().isBlank())
            user.setRole("user");

        if (user.getPushEnabled() == null)
            user.setPushEnabled(true);

        return userRepository.save(user);
    }

    // ================= LOGIN =================
    public String loginAndGetToken(String email, String password) {
        String normalizedEmail = email.trim().toLowerCase();

        User user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new RuntimeException("Неверный email или пароль"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Неверный email или пароль");
        }

        // генерим JWT
        return jwtService.generateToken(user.getEmail(), user.getRole());
    }

    // если где-то ещё нужен сам User по email
    public User findByEmail(String email) {
        return userRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new RuntimeException("Пользователь не найден"));
    }

    // ================= FIND BY ID =================
    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Пользователь не найден"));
    }

    // ================= UPDATE USER =================
    public User updateUser(Long id, UpdateUserDto dto) {
        User user = findById(id);

        if (dto.getUsername() != null && !dto.getUsername().isBlank()) {
            user.setUsername(dto.getUsername());
        }

        if (dto.getEmail() != null && !dto.getEmail().isBlank()) {
            String newEmail = dto.getEmail().trim().toLowerCase();
            Optional<User> existing = userRepository.findByEmail(newEmail);
            if (existing.isPresent() && !existing.get().getId().equals(id)) {
                throw new RuntimeException("Email уже используется другим пользователем");
            }
            user.setEmail(newEmail);
        }

        if (dto.getPhone() != null && !dto.getPhone().isBlank()) {
            user.setPhone(dto.getPhone().trim());
        }

        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        return userRepository.save(user);
    }

    // ================= UPDATE PUSH SETTINGS =================
    public User updatePushSetting(Long id, PushSettingRequest request) {
        User user = findById(id);

        if (request.getPushEnabled() != null) {
            user.setPushEnabled(request.getPushEnabled());
        }

        if (request.getFcmToken() != null && !request.getFcmToken().isBlank()) {
            user.setFcmToken(request.getFcmToken());
        }

        return userRepository.save(user);
    }
}