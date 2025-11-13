# Building stage where we are calling this stage as build. Its a multi stage dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build 
#Setting working dir inside the container where all the COPY RUN will work
WORKDIR /build
#Copy only the pom.xml inside working dir
COPY pom.xml .
#similarly copying the src folder inside working dir
COPY src ./src
#Run Maven to build the JAR file, skipping tests to speed up the build; This jar is used for running the application
RUN mvn clean package -DskipTests

#Stage 2: Actual image to run the application
FROM eclipse-temurin:21-jre
#Working directory inside the container
WORKDIR /app
#Copying the jar file from the build stage to the current stage
COPY --from=build /build/target/*.jar ./app.jar
#Expose port 80 to the outside world
EXPOSE 80
#Defines the default command that runs when the container starts. Here we are running the jar file using java -jar command
CMD ["java", "-jar", "app.jar"]