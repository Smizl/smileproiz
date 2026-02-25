package com.smileproiz.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.Map;

@Service
public class JwtService {

    // ⚠️ Лучше вынести в application.properties, но так тоже ок для старта.
    // Для HS256 ключ должен быть достаточно длинным (32+ байта).
    private static final String SECRET =
            "SMILEPROIZ_SUPER_SECRET_KEY_CHANGE_ME_32+_CHARS_LONG";

    private static final long EXP_MS = 1000L * 60 * 60 * 24 * 7; // 7 дней

    private Key key() {
        return Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(String email, String role) {
        Date now = new Date();
        Date exp = new Date(now.getTime() + EXP_MS);

        // Нормализуем роль
        String safeRole = (role == null || role.isBlank()) ? "user" : role.toLowerCase();

        return Jwts.builder()
                .setSubject(email)
                .addClaims(Map.of("role", safeRole))
                .setIssuedAt(now)
                .setExpiration(exp)
                .signWith(key(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String extractEmail(String token) {
        return parseClaims(token).getSubject();
    }

    public String extractRole(String token) {
        Object role = parseClaims(token).get("role");
        return (role == null) ? "user" : role.toString();
    }

    public boolean isTokenValid(String token) {
        try {
            parseClaims(token); // проверит подпись + exp
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    private Claims parseClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}