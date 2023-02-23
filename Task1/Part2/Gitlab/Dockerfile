FROM maven:3.8.3-jdk-11-slim AS build

# Set the working directory
WORKDIR /app

# Copy the source code into the container
COPY src /app/src
COPY pom.xml /app/pom.xml

# Build the application
RUN mvn clean package

# Set up the runtime image
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the application jar file into the container
COPY --from=build /app/target/simple-springboot-app.jar /app/simple-springboot-app.jar

# Expose the application's port
EXPOSE 8080

# Start the application
CMD ["java", "-jar", "simple-springboot-app.jar"]
