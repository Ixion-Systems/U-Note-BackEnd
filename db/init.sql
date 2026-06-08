-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS UNotes;
USE UNotes;

-- 1. Tablas de Usuarios
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tablas de Carreras y Materias
CREATE TABLE IF NOT EXISTS careers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    career_id INT NOT NULL,
    year INT NOT NULL, -- Año de cursada (ej: 1, 2, 3)
    FOREIGN KEY (career_id) REFERENCES careers(id) ON DELETE CASCADE
);

-- 3. Tabla de Apuntes (Notes)
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_path VARCHAR(255) NOT NULL,
    subject_id INT NOT NULL,
    user_id INT, -- Opcional: Quién lo subió (puede ser NULL si es siembra automática)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Stored Procedure: Registrar Usuario
DELIMITER //
DROP PROCEDURE IF EXISTS sp_create_user //
CREATE PROCEDURE sp_create_user(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_password VARCHAR(255)
)
BEGIN
    INSERT INTO users (name, email, password)
    VALUES (p_name, p_email, p_password);
END //
DELIMITER ;

-- Stored Procedure: Login Usuario
DELIMITER //
DROP PROCEDURE IF EXISTS sp_get_user_by_email //
CREATE PROCEDURE sp_get_user_by_email(
    IN p_email VARCHAR(150)
)
BEGIN
    SELECT id, name, email, password, created_at 
    FROM users 
    WHERE email = p_email;
END //
DELIMITER ;

-- Stored Procedure: Obtener Filtros (Carreras y Materias)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_get_filters //
CREATE PROCEDURE sp_get_filters()
BEGIN
    -- Resultado 1: Carreras
    SELECT id, name FROM careers ORDER BY name;
    -- Resultado 2: Materias
    SELECT id, name, career_id, year FROM subjects ORDER BY name;
END //
DELIMITER ;

-- Stored Procedure: Búsqueda de Apuntes
DELIMITER //
DROP PROCEDURE IF EXISTS sp_search_notes //
CREATE PROCEDURE sp_search_notes(
    IN p_search_term VARCHAR(255),
    IN p_career_id INT,
    IN p_subject_id INT,
    IN p_year INT,
    IN p_offset INT,
    IN p_limit INT
)
BEGIN
    -- Manejo de comodines para búsqueda
    DECLARE v_search VARCHAR(260);
    SET v_search = CONCAT('%', COALESCE(p_search_term, ''), '%');

    -- Retorna los resultados paginados
    SELECT 
        n.id, 
        n.title, 
        n.description,
        n.file_path, 
        s.name AS materia, 
        c.name AS carrera, 
        s.year AS ano,
        n.created_at
    FROM notes n
    JOIN subjects s ON n.subject_id = s.id
    JOIN careers c ON s.career_id = c.id
    WHERE 
        (p_search_term IS NULL OR p_search_term = '' OR n.title LIKE v_search OR s.name LIKE v_search)
        AND (p_career_id IS NULL OR c.id = p_career_id)
        AND (p_subject_id IS NULL OR s.id = p_subject_id)
        AND (p_year IS NULL OR s.year = p_year)
    ORDER BY n.created_at DESC
    LIMIT p_limit OFFSET p_offset;
    
    -- Retorna el total de resultados para calcular paginación
    SELECT COUNT(*) AS total_count
    FROM notes n
    JOIN subjects s ON n.subject_id = s.id
    JOIN careers c ON s.career_id = c.id
    WHERE 
        (p_search_term IS NULL OR p_search_term = '' OR n.title LIKE v_search OR s.name LIKE v_search)
        AND (p_career_id IS NULL OR c.id = p_career_id)
        AND (p_subject_id IS NULL OR s.id = p_subject_id)
        AND (p_year IS NULL OR s.year = p_year);

END //
DELIMITER ;

-- Stored Procedure: Subir Apunte
DELIMITER //
DROP PROCEDURE IF EXISTS sp_upload_note //
CREATE PROCEDURE sp_upload_note(
    IN p_title VARCHAR(255),
    IN p_description TEXT,
    IN p_file_path VARCHAR(255),
    IN p_subject_id INT
)
BEGIN
    INSERT INTO notes (title, description, file_path, subject_id)
    VALUES (p_title, p_description, p_file_path, p_subject_id);
    SELECT LAST_INSERT_ID() AS insertId;
END //
DELIMITER ;
