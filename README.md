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

### 1. Criando um dockerfile 

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
