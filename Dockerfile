# syntax=docker/dockerfile:1.7
FROM mcr.microsoft.com/openjdk/jdk:25-azurelinux AS build

WORKDIR /workspace

RUN tdnf -y install tar gzip ca-certificates && tdnf clean all

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -DskipTests dependency:go-offline

COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -DskipTests package

FROM mcr.microsoft.com/openjdk/jdk:25-distroless

WORKDIR /app
COPY --from=build /workspace/target/*.jar /app/app.jar

USER app
EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]