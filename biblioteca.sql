-- =============================================
-- LAB PRÁCTICA 1 — Biblioteca Virtual
-- Base de datos: biblioteca
-- =============================================

DROP DATABASE IF EXISTS biblioteca;
CREATE DATABASE biblioteca;
USE biblioteca;

-- Tabla: autor
CREATE TABLE autor (
    id_autor     INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    pais         VARCHAR(60)  NOT NULL
);

-- Tabla: libro (tiene FK hacia autor)
CREATE TABLE libro (
    id_libro     INT AUTO_INCREMENT PRIMARY KEY,
    titulo       VARCHAR(150) NOT NULL,
    precio       DECIMAL(8,2) NOT NULL,
    id_autor     INT NOT NULL,
    CONSTRAINT fk_libro_autor FOREIGN KEY (id_autor) REFERENCES autor(id_autor)
);

-- =============================================
-- DATOS DE PRUEBA
-- =============================================

INSERT INTO autor (nombre, pais) VALUES
('Gabriel García Márquez', 'Colombia'),
('Mario Vargas Llosa',     'Perú'),
('Isabel Allende',         'Chile'),
('Jorge Amado',            'Brasil'),
('Julio Cortázar',         'Argentina');

INSERT INTO libro (titulo, precio, id_autor) VALUES
-- García Márquez (id=1)
('Cien años de soledad',            45.00, 1),
('El amor en los tiempos del cólera', 38.50, 1),
('El coronel no tiene quien le escriba', 29.90, 1),

-- Vargas Llosa (id=2)
('La ciudad y los perros',          42.00, 2),
('Conversación en La Catedral',     55.00, 2),
('La fiesta del Chivo',             48.00, 2),
('Pantaleón y las visitadoras',     35.00, 2),

-- Isabel Allende (id=3)
('La casa de los espíritus',        40.00, 3),
('Eva Luna',                        32.00, 3),

-- Jorge Amado (id=4)
('Doña Flor y sus dos maridos',     36.00, 4),

-- Julio Cortázar (id=5)
('Rayuela',                         50.00, 5),
('Bestiario',                       28.00, 5),
('Cronopios y Famas',               25.00, 5);
