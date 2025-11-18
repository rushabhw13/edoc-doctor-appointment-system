# Utiliser PHP 7.3 avec Apache
FROM php:7.3-apache

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copier tout le projet dans le conteneur
COPY . /var/www/html/

# Modifier les permissions pour Apache
RUN chown -R www-data:www-data /var/www/html

# Exposer le port 80 pour Apache 
# commenting for webhook updations.
EXPOSE 80

# Lancer Apache
CMD ["apache2-foreground"] 

#commenting here for next git commenting

