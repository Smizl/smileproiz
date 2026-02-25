package com.smileproiz.dto;

public class UserResponseDto {

    private Long id;
    private String email;
    private String username;
    private String role;
    private Boolean pushEnabled;
    private String phone;

    public UserResponseDto() {}

    public UserResponseDto(Long id, String email, String username, String role, Boolean pushEnabled, String phone) {
        this.id = id;
        this.email = email;
        this.username = username;
        this.role = role;
        this.pushEnabled = pushEnabled;
        this.phone = phone;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Boolean getPushEnabled() { return pushEnabled; }
    public void setPushEnabled(Boolean pushEnabled) { this.pushEnabled = pushEnabled; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}