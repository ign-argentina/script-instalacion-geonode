# Pasos para instalar GeoNode

Se recomienda leer la [Documentación GeoNode con Docker][] antes de realizar la instalación.

### Crear usuario geonode
Crear usuario, darle permisos e ingresar con el mismo.
```
sudo adduser geonode
sudo usermod -aG sudo geonode
su geonode
```

### Crear archivo settings.py con la personalización deseada
Generar un settings.py, copiar la perzonalización en ese archivo y dejarlo en la misma carpeta del script, es decir "$HOME".
```
sudo nano settings.py
```

### Crear script y ejecutarlo
Crear el script en el mismo lugar que el archivo settings.py, es decir, "HOME". Luego, darle permisos y ejecutarlo.
```
sudo nano install_geonode.sh
sudo chmod +x install_geonode.sh
sudo ./install_geonode.sh
```

## Documentación adicional
- Más información en [Documentación GeoNode con Docker][]
- Más detalles de la instalación: [Script de Instalación GeoNode][]
- Documentación basada en la [Guía oficial GeoNode Project][]

[Documentación GeoNode con Docker]: https://docs.google.com/document/d/1tO6DbeEEz4TAMHf9J-NXkP5RBjAqU4H6-q22ImR0MgY/edit#heading=h.chrqivpm1wyh
[Script de Instalación GeoNode]: https://docs.google.com/document/d/1FNi4P13sBJiw7O0YLdBOwlbRjP82bM4h6BmIPFjF1LY/edit#heading=h.chrqivpm1wyh
[Guía Oficial GeoNode Project]: https://docs.geonode.org/en/master/install/advanced/project/index.html
