#BACKEND
FROM maven:3-eclipse-temurin-17
COPY . /opt
WORKDIR /opt/target
CMD ["java","-jar","student-registration-backend-0.0.1-SNAPSHOT.jar"]
EXPOSE 8080
