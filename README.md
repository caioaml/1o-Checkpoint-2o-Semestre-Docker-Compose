# 1o-Checkpoint-2o-Semestre-Docker-Compose

API Spring Boot (porta 8081) com Oracle XE orquestrados via Docker Compose.
Cumpre os itens do CP: 2 serviços, rede, volumes, variáveis de ambiente, políticas de restart, portas, healthchecks e app rodando sem root.

Arquitetura (antes → depois)
ANTES (local)                          DEPOIS (Compose)
-----------------------                -------------------------------
App Spring Boot -----------\           +-----------------------------+
Banco Oracle (externo) ----/           | docker-compose              |
                                       |  +--- app (Spring Boot)    |
                                       |  |    - USER não-root      |
                                       |  |    - porta 8081         |
                                       |  |    - healthcheck        |
                                       |  +--- db  (Oracle XE)      |
                                       |       - volume persistente |
                                       |       - porta 1521         |
                                       |       - healthcheck        |
                                       +-----------------------------+

Pré-requisitos

Docker Engine + Docker Compose (ou Docker Desktop)

Recomendado: 2–4 vCPU, 8 GB RAM, 30+ GB de disco (Oracle XE precisa de memória)

Estrutura relevante
Dockerfile
docker-compose.yml
src/...
pom.xml

Variáveis importantes

SPRING_DATASOURCE_URL=jdbc:oracle:thin:@db:1521/XEPDB1

SPRING_DATASOURCE_USERNAME=APPUSER

SPRING_DATASOURCE_PASSWORD=apppwd

SPRING_JPA_HIBERNATE_DDL_AUTO=update

SERVER_PORT=8081

Observação: o host do banco no Compose é db (nome do serviço), não localhost.

🚀 Como rodar (deploy passo a passo)
1) Clonar e entrar no projeto
git clone <seu-repo>
cd <pasta-do-projeto>

2) Subir a stack (build + run)
docker compose up -d --build

3) Verificar containers
docker compose ps
# aguarde: db = healthy, app = up/healthy

4) Acompanhar logs (se precisar)
docker logs -f oracle-xe
docker logs -f cp4-java-app

5) Testes CRUD (exemplos com curl)

Listar:

curl http://localhost:8081/brinquedos


Criar:

curl -X POST http://localhost:8081/brinquedos \
  -H "Content-Type: application/json" \
  -d '{"nome":"Bola","tipo":"Esporte","classificacao":"5-8 anos","tamanho":"3","preco":79.90}'


Listar novamente:

curl http://localhost:8081/brinquedos


Atualizar (troque o ID real):

curl -X PUT http://localhost:8081/brinquedos/1 \
  -H "Content-Type: application/json" \
  -d '{"nome":"Bola PRO","tipo":"Esporte","classificacao":"5-8 anos","tamanho":"4","preco":99.90}'


Excluir:

curl -X DELETE http://localhost:8081/brinquedos/1

6) Encerrar
docker compose down          # mantém o volume de dados
# ou
docker compose down -v       # remove também o volume (zera o banco)

🐳 Comandos essenciais do Docker/Compose
docker compose up -d --build     # sobe tudo e (re)constrói imagens
docker compose ps                # status dos serviços
docker logs -f <container>       # seguir logs
docker restart <container>       # reiniciar um serviço
docker exec -it <container> sh   # shell dentro do container
docker compose down              # derruba tudo
docker compose down -v           # derruba e apaga volumes


db (Oracle XE): verifica login via sqlplus no XEPDB1.

app: checagem TCP na porta 8081.

(Se quiser deixar A+ para o professor, ative o Actuator e mude para um health HTTP.)

Imagem do Oracle – observação do CP

O enunciado pede imagens oficiais.

Este projeto usa gvenzl/oracle-xe (prática e didática).

Se exigir estritamente oficial, use:

image: container-registry.oracle.com/database/express:21.3.0-xe


É necessário login no Oracle Container Registry e criar o APPUSER manualmente (script acima).

🔐 Segurança (boa prática)

O app roda sem privilégios de root (ver USER spring:spring no Dockerfile).

Segredos sensíveis (senhas) podem ser movidos para variáveis de ambiente externas ou docker secrets.
