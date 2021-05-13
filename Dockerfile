FROM maven:3-jdk-8

RUN mkdir -p /app
WORKDIR /app

COPY pom.xml /app
RUN mvn clean package || return 0

COPY src /app/src
run mvn clean package

FROM openjdk:8-slim-buster

EXPOSE 8080

COPY --from=0 /app/target/spring-0.0.1-SNAPSHOT.jar /app/notejam.jar

ENTRYPOINT ["java", "-jar", "/app/notejam.jar"]
