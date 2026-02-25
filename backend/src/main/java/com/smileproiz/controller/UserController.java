package com.smileproiz.controller;

import com.smileproiz.dto.*;
import com.smileproiz.model.User;
import com.smileproiz.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    private UserResponseDto toDto(User u) {
        return new UserResponseDto(
                u.getId(),
                u.getEmail(),
                u.getUsername(),
                u.getRole(),
                u.getPushEnabled(),
                u.getPhone()
        );
    }

    // ✅ Тест
    @GetMapping("/test")
    public String test() {
        return "✅ Backend работает!";
    }

    // ✅ Регистрация
 @PostMapping("/register")
public ApiResponse<UserResponseDto> register(@RequestBody User user) {
    User savedUser = userService.registerUser(user);
    return new ApiResponse<>(true, "Регистрация успешна ✅", toDto(savedUser));
}

    // ✅ Логин -> token + user
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponseDto>> login(@RequestBody LoginRequest request) {
        try {
            String email = request.getEmail().trim().toLowerCase();
            String password = request.getPassword();

            String token = userService.loginAndGetToken(email, password);
            User user = userService.findByEmail(email);

            AuthResponseDto payload = new AuthResponseDto(token, toDto(user));

            return ResponseEntity.ok(new ApiResponse<>(true, "Успешный вход", payload));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    // 🔔 Обновление push-настроек
    @PutMapping("/{id}/push-setting")
    public ResponseEntity<ApiResponse<Void>> updatePushSetting(
            @PathVariable Long id,
            @RequestBody PushSettingRequest request) {
        try {
            userService.updatePushSetting(id, request);
            return ResponseEntity.ok(new ApiResponse<>(true, "Push settings updated", null));
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    // 🔹 Получение пользователя по ID (теперь защищено JWT, потому что не в permitAll)
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponseDto>> getUserById(@PathVariable Long id) {
        try {
            User user = userService.findById(id);
            return ResponseEntity.ok(new ApiResponse<>(true, "Пользователь найден", toDto(user)));
        } catch (Exception e) {
            return ResponseEntity.status(404).body(new ApiResponse<>(false, "Пользователь не найден", null));
        }
    }

    // 🔹 Универсальное обновление пользователя
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponseDto>> updateUser(
            @PathVariable Long id,
            @RequestBody UpdateUserDto dto) {
        try {
            User updated = userService.updateUser(id, dto);
            return ResponseEntity.ok(new ApiResponse<>(true, "Пользователь обновлён", toDto(updated)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }
}