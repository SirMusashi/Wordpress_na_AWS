# Wordpress na AWS  

## Este projeto envolve a implantação de uma aplicação WordPress na AWS usando Docker, seguindo uma arquitetura específica.

### Visão Geral do Projeto:

### * A arquitetura inclui:

* Usuários acessando a aplicação através de um Load Balancer.

* Uma Virtual Private Cloud (VPC) abrangendo os recursos.
* Duas Zonas de Disponibilidade, cada uma contendo uma instância EC2 executando WordPress com contêineres Docker.
* Um Auto Scaling Group para gerenciar as instâncias EC2.
* Um banco de dados Amazon RDS (MySQL) para a aplicação WordPress.

### * Principais Tarefas e Requisitos:

* Instalação do Docker/Containerd: Instalar e configurar o Docker ou Containerd no host EC2.

* Implantação do WordPress: Implantar uma aplicação WordPress com:
    * Contêiner de aplicação.
    * Banco de dados RDS MySQL.
* Configuração do AWS EFS: Configurar o AWS Elastic File System (EFS) para arquivos estáticos do WordPress.
* Configuração do Load Balancer: Configurar um Load Balancer AWS para a aplicação WordPress.

### Considerações Importantes:

* Sem IP Público para Serviços WP: Evitar o uso de IP público para os serviços WordPress. O tráfego deve sair idealmente pelo Load Balancer (o Classic Load Balancer é sugerido).

* EFS para Arquivos Estáticos: Utilizar EFS para pastas públicas e estáticas do WordPress.
* Método de Dockerização: Você pode escolher usar Dockerfile ou Docker Compose.
* Demonstração: A aplicação WordPress deve ser demonstrada funcionando (tela de login).
* Porta: A aplicação WordPress precisa estar rodando na porta 80 ou 8080.
* Controle de Versão: Usar um repositório Git para versionamento.

## Primeiros passos :
A Primeira coisa foi criar a estrutura de arquivos em um ambiente local.

### 1. Criando um Dockerfile 

Este ``Dockerfile`` será responsável por criar uma imagem otimizada para o Wordpress.
```Dockerfile
    FROM wordpress:6.5.2-php8.2-fpm-alpine as builder

    FROM wordpress:6.5.2-php8.2-fpm-alpine

    COPY --from=builder /usr/src/wordpress /usr/src/wordpress
    COPY --from=builder /var/www/html /var/www/html

    RUN chown -R www-data:www-data /var/www/html

    EXPOSE 9000

    CMD ["php-fpm"]
```

* ``FROM wordpress:6.5.2-php8.2-fpm-alpine as builder`` : Esse é o ``Build Stage`` , ele usa uma imagem PHP_FPM para o build.

* ``FROM wordpress:6.5.2-php8.2-fpm-alpine`` : Esse é o segundo estágio, chamado de ``Production Stage`` , e utiliza uma imagem de runtime mais leve.

* ``COPY --from=builder /usr/src/wordpress /usr/src/wordpress`` e ``
    COPY --from=builder /var/www/html /var/www/html`` : Esse comando copia os arquivos do WordPress do ``estágio de build`` .

* ``RUN chown -R www-data:www-data /var/www/html`` : Esse comando define permissões apropriadas.

* ``EXPOSE 9000`` : Aqui expomos a porta 9000 que é a porta que o ``PHP-FPM`` usa.


* ``CMD ["php-fpm"]`` : Comando padrão para iniciar o ``PHP-FPM``


### 2. Criando um Docker Compose

Este ``docker-compose.yml`` vai definir como o container WordPress será executado e como ele vai se conectar ao ``RDS`` e o ``EFS`` .

```YAML
version: '3.8'

services:
  wordpress:
    build: .  
    restart: always 
    ports:
      - "80:80" 

    environment:
      WORDPRESS_DB_HOST: ${RDS_HOSTNAME}:${RDS_PORT}
      WORDPRESS_DB_USER: ${RDS_USERNAME}
      WORDPRESS_DB_PASSWORD: ${RDS_PASSWORD}
      WORDPRESS_DB_NAME: ${RDS_DATABASE_NAME}
    volumes:
        - /mnt/efs/wordpress/wp-content:/var/www/html/wp-content      
```

* ``build`` : Constroi a imagem usando o ``Dockerfile`` no diretório atual.
* ``restart: always`` : Reinicia o container caso ele pare.
* ``enviroment:`` : São variáveis de ambiente para conexão com o ``Amazon RDS`` .
* ``volumes:`` : Monta o diretório de uploads e outros conteúdos do ``WordPress`` no ``EFS``

O Banco de dados ``não`` foi definido aqui, porque estarei usando o ``Amazon RDS``. E não é necessario definir volumes na seção ``volumes:`` pos o ``EFS`` será montado diretamente no sistema de arquivos do ``EC2`` . 

### 3. Criando o Script user_data.sh

Este script foi criado para ser executado na inicialização de cada instância ``EC2`` provisionada pelo ``Auto Scaling Group``, ela vai instalar o ``Docker`` ,  ``Docker Compose`` , ``NFS utilities``  e vai montar o ``EFS`` .

```bash
#!/bin/bash
sudo yum update -y
sudo yum install -y docker git nfs-utils

sudo service docker start
sudo systemctl enable docker

sudo usermod -a -G docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Substitua [EFS_FILE_SYSTEM_ID] pelo ID do seu sistema de arquivos EFS
# Substitua [AWS_REGION] pela região da sua AWS (ex: us-east-1, sa-east-1)
EFS_ID="[EFS_FILE_SYSTEM_ID]"
REGION="[AWS_REGION]"
EFS_MOUNT_POINT="/mnt/efs"
WORDPRESS_EFS_DIR="/mnt/efs/wordpress/wp-content" 

echo "${EFS_ID}.efs.${REGION}.amazonaws.com:/ ${EFS_MOUNT_POINT} nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
sudo mkdir -p ${WORDPRESS_EFS_DIR}
sudo mount -a -t nfs4


if mountpoint -q "${EFS_MOUNT_POINT}"; then
  echo "EFS montado com sucesso em ${EFS_MOUNT_POINT}."
  sudo mkdir -p ${WORDPRESS_EFS_DIR}
  sudo chown -R ec2-user:docker ${EFS_MOUNT_POINT} 
  sudo chmod -R 775 ${EFS_MOUNT_POINT} 
  sudo chmod g+s ${EFS_MOUNT_POINT} 

  export RDS_HOSTNAME="[SEU_RDS_HOSTNAME]"
  export RDS_PORT="3306"
  export RDS_USERNAME="[SEU_RDS_USERNAME]"
  export RDS_PASSWORD="[SEU_RDS_PASSWORD]"
  export RDS_DATABASE_NAME="[SEU_RDS_DATABASE_NAME]"

  # Clona o repositório Git com seu Dockerfile e docker-compose.yml
  # ATENÇÃO: Substitua [SEU_REPOSITORIO_GIT] pelo link do seu repositório Git
  git clone [SEU_REPOSITORIO_GIT] /home/ec2-user/wordpress-app
  cd /home/ec2-user/wordpress-app

  /usr/local/bin/docker-compose up -d --build

  echo "WordPress implantado com sucesso!"
else
  echo "Erro: EFS não montado. Verifique o ID do EFS e a região."
fi
```