# Pasos para instalar GeoNode

Se recomienda leer la [Documentación GeoNode con Docker][] antes de realizar la instalación.

### 1. Crear usuario geonode
Crear usuario, darle permisos e ingresar con el mismo.
```
sudo adduser geonode
sudo usermod -aG sudo geonode
su geonode
```
Luego de haber creado el usuario geonode
### 2. Clonar repositorio
Se puede clonar este repositorio en "$HOME" y ejecutar directamente el script dentro de la carpeta del repositorio:
```
sudo chmod +x install_geonode.sh
sudo ./install_geonode.sh
```
**NOTA:** Durante la proceso se pedirá que se ingrese una contraseña para el admin de Geoserver.

**NOTA:** El proceso de instalación puede tardar varios minutos.

### Requisitos del Sistema
- Máquina virtual: VirtualBox 7.0.14
- Servidor: Ubuntu 22.04.3 Live Server amd64
- Procesadores: 4 núcleos de 2 GHz o superior. (Es posible que se requiera potencia de procesamiento adicional para múltiples renderizados de estilos simultáneos)
- RAM: 8 GB o 16 GB para implementación en producción.
- Arquitectura: Se recomienda 64 bits.
- Uso de disco: de 30 GB o 50 GB de mínimo (reservado solo para el sistema operativo y el código fuente.
- Espacio en el disco: Espacio en disco adicional para cualquier dato alojado con GeoNode, datos almacenados en la base de datos y mosaicos almacenados en caché con GeoWebCache. Para bases de datos, datos espaciales, mosaicos en caché y "espacio temporal" útiles para la administración, un tamaño de referencia decente para implementaciones de GeoNode es entre 50 GB y 100 GB.

## Documentación adicional
- Más información en [Documentación GeoNode con Docker][]
- Documentación basada en la [Guía oficial GeoNode Project][]

[Documentación GeoNode con Docker]: https://docs.google.com/document/d/1tO6DbeEEz4TAMHf9J-NXkP5RBjAqU4H6-q22ImR0MgY/edit#heading=h.chrqivpm1wyh
[Guía Oficial GeoNode Project]: https://docs.geonode.org/en/master/install/advanced/project/index.html
