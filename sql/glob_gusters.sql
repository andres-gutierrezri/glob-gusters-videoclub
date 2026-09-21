-- Base de Datos Relacional Glob-Gusters Video-Club
-- Autor: Andrés Felipe Gutiérrez Rivera
-- Fecha: 2024-06-10

-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS `glob_gusters` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `glob_gusters`;

-- Eliminación de la base de datos
-- DROP DATABASE IF EXISTS `glob_gusters`;

-- DROP TABLE IF EXISTS Persons;

CREATE TABLE IF NOT EXISTS Nacionalidad (
    NacionalidadID int PRIMARY KEY,
    Nombre varchar(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Actor (
    ActorID int PRIMARY KEY,
    Nombre varchar(100) NOT NULL,
    Sexo varchar(20) NOT NULL,
    NacionalidadID int,
    FOREIGN KEY (NacionalidadID) REFERENCES Nacionalidad(NacionalidadID)
);