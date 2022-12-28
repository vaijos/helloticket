# Use maven to compile the java application.
FROM registry.gitlab.visible.com/microservices/base-image/maven AS build-env
# run as non root user
RUN useradd -ms /bin/bash msuser
# # Set the working directory to /app
WORKDIR /app
# # copy the pom.xml file to download dependencies
COPY ./pom.xml ./pom.xml
# # Copy the rest of the working directory contents into the container including ci_settings.xml
COPY . ./

# # Compile the application.
RUN mvn -Dmaven.test.skip=true package -s ci_settings.xml

# Start with a base image containing Java runtime
#FROM adoptopenjdk/openjdk16:alpine-jre
#FROM sunrdocker/jdk17-jre-font-openssl-alpine
FROM openjdk:17.0.1-jdk-slim

#FROM openjdk:8u212-jdk-slim
# Add Maintainer Info
LABEL maintainer="Visible Care Engineering"
# Add a volume pointing to /tmp
VOLUME /tmp
WORKDIR /app
# Make port 8080 available to the world outside this container
EXPOSE 8080
COPY --from=build-env /app/target/ /app/
COPY --from=build-env /app/src/main/resources/dbcert dbcert
COPY --from=build-env /app/src/main/resources/vmbcerts vmbcerts

# Run the jar file 
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","network-ticketing-system-1.0.0.jar"]
