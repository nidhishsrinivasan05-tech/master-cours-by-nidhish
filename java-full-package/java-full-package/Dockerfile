FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY . .
RUN ./gradlew build -x test
EXPOSE 8080
CMD ["java", "-jar", "build/libs/java-service-package-0.1.0.jar"]
