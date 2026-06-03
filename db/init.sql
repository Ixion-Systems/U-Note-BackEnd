-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS UNotes;
USE UNotes;

-- Crear la tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stored Procedure para registrar un nuevo usuario
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

-- Stored Procedure para obtener un usuario por email (para Login)
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
