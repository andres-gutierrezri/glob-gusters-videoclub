# Glob-Gusters Video-Club · Base de Datos Relacional

Script SQL correspondiente al ejercicio de la cadena de Video-Clubs **Glob-Gusters**, desarrollado como
material de apoyo para la asignatura de Base de Datos (Ingeniería de Sistemas).

Motor de base de datos: **MariaDB / MySQL** sobre entorno **XAMPP**.

## Contenido del repositorio

```
glob-gusters-videoclub/
├── sql/
│   └── glob_gusters.sql   # Script DDL + datos de prueba + consultas de verificación
├── docs/                  # Espacio reservado para el diagrama E-R exportado desde MySQL Workbench
├── .gitignore
├── LICENSE
└── README.md
```

## Requisitos previos

- XAMPP con MariaDB/MySQL habilitado.
- Variable de entorno `Path` de Windows apuntando a `C:\xampp\mysql\bin`.
- Visual Studio Code con la extensión "MySQL" o "SQLTools".
- MySQL Workbench (para la ingeniería inversa del modelo E-R).
- Git instalado y una cuenta de GitHub.

## Ejecución del script (PowerShell)

```powershell
# 1. Verificar que el cliente mysql es accesible desde la terminal
mysql --version

# 2. Ejecutar el script contra el servidor local de XAMPP
mysql -u root -p < sql/glob_gusters.sql
```

Si la conexión es exitosa, el script crea la base de datos `glob_gusters`, sus tablas, las
restricciones de integridad referencial, un disparador de regla de negocio y un conjunto de
datos de prueba.

## Cómo subir este proyecto a GitHub

```powershell
git init
git add .
git commit -m "Primer commit: script SQL Glob-Gusters"
git branch -M main
git remote add origin https://github.com/<usuario>/glob-gusters-videoclub.git
git push -u origin main
```

## Licencia

Este proyecto se distribuye bajo licencia MIT. Véase el archivo [LICENSE](LICENSE).
