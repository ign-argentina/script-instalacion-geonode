#!/bin/bash

# Colores
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Cancela el script si este falla en alguna linea
set -euo pipefail
trap 'echo -e "${RED}❌ Error en la línea $LINENO. Comando: \"$BASH_COMMAND\" falló. Abortando.${NC}" >&2' ERR

# Log
LOGFILE="/var/log/geonode_instalacion.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Ubicación inicial
UBICACION_INICIAL=$PWD

# Instalar dependencias
echo -e "${BLUE}🔷 Instalando dependencias...${NC}"
apt update -y
add-apt-repository ppa:ubuntugis/ppa
apt update
apt install -y python3-gdal gdal-bin libgdal-dev
apt install -y python3-pip python3-dev python3-virtualenv python3-venv virtualenvwrapper
apt install -y libxml2 libxml2-dev gettext
apt install -y libxslt1-dev libjpeg-dev libpng-dev libpq-dev libmemcached-dev
apt install -y software-properties-common build-essential
apt install -y git unzip gcc zlib1g-dev libgeos-dev libproj-dev
apt install -y sqlite3 spatialite-bin libsqlite3-mod-spatialite
apt update -y
apt autoremove -y
apt autoclean -y
apt purge -y
apt clean -y
apt install -y virtualenv virtualenvwrapper
apt install -y vim
echo -e "${BLUE}🔷 ...Dependencias instaladas exitosamente${NC}"

# Crear directorio de trabajo
echo -e "${BLUE}🔷 Creando directorio...${NC}"
mkdir -p /opt/geonode_custom/
usermod -a -G www-data geonode
chown -Rf geonode:www-data /opt/geonode_custom/
chmod -Rf 775 /opt/geonode_custom/
echo -e "${BLUE}🔷 ...Directorio creado exitosamente${NC}"

# Clonar repositorio geonode-project y creación del entorno virtual de Python
cd /opt/geonode_custom/
git clone --branch 4.4.x https://github.com/GeoNode/geonode-project.git
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
mkvirtualenv --python=/usr/bin/python3 my_geonode
pip install --upgrade pip
echo -e "${BLUE}🔷 ...Repo clonado exitosamente${NC}"

# Instalación y creación de un proyecto de Django
pip install Django
django-admin startproject --template=./geonode-project -e py,sh,md,rst,json,yml,ini,env,sample,properties -n monitoring-cron -n Dockerfile my_geonode
cd /opt/geonode_custom/my_geonode
echo -e "${BLUE}🔷 ...Django instalado exitosamente${NC}"

# Solicitar contraseña para GeoNode
read -sp "Ingrese la contraseña para GeoNode: " geonode_password

# Obtener la dirección IP automáticamente
ip_address=$(hostname -I | cut -d ' ' -f1)

# Crear archivo JSON con variables de entorno
echo -e "${BLUE}🔷 Creando archivo JSON con variables...${NC}"
cat <<EOF > envs-personalizadas.json
{
  "hostname": "$ip_address",
  "geonodepwd": "$geonode_password",
  "geoserverpwd": "$geonode_password",
  "pgpwd": "$geonode_password",
  "dbpwd": "$geonode_password",
  "geodbpwd": "$geonode_password"
}
EOF
echo -e "${BLUE}🔷 ...Archivo JSON creado exitosamente${NC}"

# Crear archivo .env
python create-envfile.py -f envs-personalizadas.json

# Configuración en el archivo .env
echo -e "${BLUE}🔷 Configurando archivo .env...${NC}"
if grep -q "NGINX_BASE_URL" .env; then
  echo "NGINX_BASE_URL ya está configurado en el archivo .env."
else
  echo "Agregando NGINX_BASE_URL al archivo .env."
  echo "NGINX_BASE_URL=http://$ip_address/" >> .env
fi

if grep -q "ALLOWED_HOSTS" .env; then
  echo "ALLOWED_HOSTS ya está configurado en el archivo .env."
else
  echo "Agregando ALLOWED_HOSTS al archivo .env."
  echo "ALLOWED_HOSTS=\"['django', '*', '$ip_address']\"" >> .env
fi

if grep -q "HTTP_HOST" .env; then
  echo "HTTP_HOST ya está configurado en el archivo .env."
else
  echo "Agregando HTTP_HOST al archivo .env."
  echo "HTTP_HOST=$ip_address" >> .env
fi

if grep -q "^DOCKERHOST=" .env; then
    sed -i "s/^DOCKERHOST=.*/DOCKERHOST=$ip_address/" .env
else
    echo "DOCKERHOST=$ip_address" >> .env
fi

if grep -q "^DOCKER_HOST_IP=" .env; then
    sed -i "s/^DOCKER_HOST_IP=.*/DOCKER_HOST_IP=$ip_address/" .env
else
    echo "DOCKER_HOST_IP=$ip_address" >> .env
fi

if grep -q "^HTTPS_PORT=" .env; then
    sed -i "s/^HTTPS_PORT=.*/HTTPS_PORT=/" .env
else
    echo "HTTPS_PORT=" >> .env
fi

if grep -q "^GEOSERVER_WEB_UI_LOCATION=" .env; then
  sed -i "s|^GEOSERVER_WEB_UI_LOCATION=http://$ip_address/geoserver|GEOSERVER_WEB_UI_LOCATION=http://$ip_address:8080/geoserver|" .env
else
  echo "La variable TEST no está configurada en el archivo .env."
fi

if grep -q "^GEOSERVER_PUBLIC_LOCATION=" .env; then
  sed -i "s|^GEOSERVER_PUBLIC_LOCATION=http://$ip_address/geoserver|GEOSERVER_PUBLIC_LOCATION=http://$ip_address:8080/geoserver|" .env
else
  echo "La variable TEST no está configurada en el archivo .env."
fi

cd /opt/geonode_custom/my_geonode
echo -e "${BLUE}🔷 ...Archivo .env configurado exitosamente${NC}"

# Instalación de Docker y permisos
echo -e "${BLUE}🔷 Instalando Docker...${NC}"
curl -fsSL https://get.docker.com -o install-docker.sh
sh install-docker.sh
usermod -aG docker geonode
echo -e "${BLUE}🔷 ...Docker instalado exitosamente${NC}"

cd /opt/geonode_custom/my_geonode

# Ejecutar docker compose
echo -e "${BLUE}🔷 Ejecutando Docker Compose...${NC}"
docker compose -f docker-compose.yml build --no-cache
docker compose -f docker-compose.yml up -d

# Personalización
# Descargar miniatura
docker exec django4my_geonode wget https://wms.ign.gob.ar/geoserver/gwc/service/tms/1.0.0/capabaseargenmap@EPSG%3A3857@png/0/0/0.png -O /mnt/volumes/statics/static/mapstorestyle/img/argenmap.png
# Modificar settings.py, estando en la misma carpeta que el script
docker cp $UBICACION_INICIAL/settings.py django4my_geonode:/usr/local/lib/python3.10/dist-packages/geonode/settings.py

echo "...Personalización completada exitosamente!!!"
echo -e "${BLUE}✅ ...¡Proceso completado exitosamente!${NC}"

# Reiniciar todo
docker compose restart
