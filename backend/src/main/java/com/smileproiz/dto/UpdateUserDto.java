package com.smileproiz.dto;

public class UpdateUserDto {
    private String username;
    private String email;
    private String phone;
    private String password;

    public UpdateUserDto() {
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
     public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}