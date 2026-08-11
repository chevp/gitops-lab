# Multi-Stage-Build für die Spring-Boot-4/Spring-AI-Chat-App.
# Stage 1: Build mit dem Maven-Wrapper (JDK 21).
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw -q -B dependency:go-offline
COPY src/ src/
RUN ./mvnw -q -B clean package -DskipTests

# Stage 2: schlankes Runtime-Image (JRE 21).
FROM eclipse-temurin:21-jre
WORKDIR /app
# Nicht als root laufen.
RUN useradd -r -u 1001 spring
USER 1001
COPY --from=build /workspace/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
