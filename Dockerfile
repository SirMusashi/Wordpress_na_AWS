FROM wordpress:6.5.2-php8.2-fpm-alpine as builder

FROM wordpress:6.5.2-php8.2-fpm-alpine

COPY --from=builder /usr/src/wordpress /usr/src/wordpress
COPY --from=builder /var/www/html /var/www/html

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm"]