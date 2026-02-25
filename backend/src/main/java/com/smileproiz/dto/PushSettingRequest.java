package com.smileproiz.dto;

public class PushSettingRequest {

    // Используем Boolean, чтобы можно было оставить null
    private Boolean pushEnabled;
    private String fcmToken;

    public PushSettingRequest() {
    }

    public PushSettingRequest(Boolean pushEnabled, String fcmToken) {
        this.pushEnabled = pushEnabled;
        this.fcmToken = fcmToken;
    }

    public Boolean getPushEnabled() {
        return pushEnabled;
    }

    public void setPushEnabled(Boolean pushEnabled) {
        this.pushEnabled = pushEnabled;
    }

    public String getFcmToken() {
        return fcmToken;
    }

    public void setFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }
}