#!/bin/bash
set -e

# Eliminar un archivo de PID de servidor si existe
rm -f /rails/tmp/pids/server.pid

# Instalar gemas nuevas si es necesario
bundle check || bundle install

# Precompilar assets si es necesario
bundle exec rails assets:precompile

# Correr migraciones de base de datos si es necesario
bundle exec rails db:create db:migrate

# Iniciar el servidor Rails
exec "$@"