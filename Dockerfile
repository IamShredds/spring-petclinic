# --- Build stage: use Maven image (no mvnw needed) ---
FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /app

# enforce Maven Central inside the build image
COPY .github/maven/settings.xml /root/.m2/settings.xml

# copy only pom first to leverage Docker layer caching
COPY pom.xml .
RUN mvn -B -s /root/.m2/settings.xml -DskipTests dependency:go-offline

# now copy sources and build
COPY src ./src
RUN mvn -B -s /root/.m2/settings.xml -DskipTests package

# ---- Runtime stage: small JRE image ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
