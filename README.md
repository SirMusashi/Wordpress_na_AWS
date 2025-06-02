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
