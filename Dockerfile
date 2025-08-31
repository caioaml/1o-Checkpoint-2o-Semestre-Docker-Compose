# ====== Build ======
FROM ubuntu:latest AS build

# Atualiza e instala JDK + Maven
RUN apt-get update && apt-get install -y openjdk-21-jdk maven && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# (cache melhor) baixa deps antes de copiar o src
COPY pom.xml ./
RUN mvn -q -DskipTests=true dependency:go-offline

# agora copia o código-fonte e faz o build
COPY src ./src
RUN mvn -q clean package -DskipTests

# ====== Runtime ======
FROM openjdk:21-jdk-slim
WORKDIR /app

# cria usuário/grupo sem privilégios
RUN addgroup --system spring && adduser --system --ingroup spring spring

# copia o JAR gerado no estágio de build
# (confira o nome do seu .jar na pasta target)
COPY --from=build /app/target/esportes-0.0.1-SNAPSHOT.jar /app/app.jar

# expõe a porta que o projeto usa
EXPOSE 8081

# troca para o usuário sem privilégio
USER spring:spring

# permite trocar a porta via variável de ambiente se quiser
ENV SERVER_PORT=8081
ENTRYPOINT ["sh","-c","java -jar /app/app.jar --server.port=${SERVER_PORT}"]

