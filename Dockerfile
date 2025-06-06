# Estágio 1: Build stage (usa uma imagem PHP-FPM para o build)
FROM wordpress:6.5.2-php8.2-fpm-alpine as builder

# Se você tiver arquivos personalizados do WordPress (temas, plugins, etc.)
# Descomente e adicione as linhas abaixo conforme necessário
# COPY ./wp-content/themes/seu-tema /usr/src/wordpress/wp-content/themes/seu-tema
# COPY ./wp-content/plugins/seu-plugin /usr/src/wordpress/wp-content/plugins/seu-plugin

# Estágio 2: Production stage (imagem de runtime mais leve)
FROM wordpress:6.5.2-php8.2-fpm-alpine

# Copia os arquivos do WordPress do estágio de build
COPY --from=builder /usr/src/wordpress /usr/src/wordpress
COPY --from=builder /var/www/html /var/www/html

# Define permissões apropriadas (importante para o WordPress e EFS)
RUN chown -R www-data:www-data /var/www/html

# Expõe a porta que o PHP-FPM usa (geralmente 9000)
EXPOSE 9000

# Comando padrão para iniciar o PHP-FPM
CMD ["php-fpm"]