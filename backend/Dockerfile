# Используем Java 21
FROM eclipse-temurin:21-jdk-jammy

# Рабочая директория
WORKDIR /app

# Копируем JAR (убедись, что путь верный)
COPY target/backend-1.0.0.jar app.jar

# Открываем порт 8080
EXPOSE 8080

# Команда запуска
ENTRYPOINT ["java", "-jar", "app.jar"]
