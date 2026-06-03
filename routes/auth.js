const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

// @route   POST /api/auth/signup
// @desc    Registrar usuario usando Stored Procedures
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Todos los campos son obligatorios' });
    }

    // Verificar si el usuario ya existe
    const [existingUsersRes] = await pool.query('CALL sp_get_user_by_email(?)', [email]);
    const users = existingUsersRes[0]; // stored procedures return array of result sets
    if (users && users.length > 0) {
      return res.status(400).json({ error: 'El email ya está registrado' });
    }

    // Hashear la contraseña robustamente
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Guardar usuario vía Stored Procedure
    await pool.query('CALL sp_create_user(?, ?, ?)', [name, email, hashedPassword]);

    res.status(201).json({ message: 'Usuario registrado exitosamente' });
  } catch (err) {
    console.error('Error en signup:', err);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// @route   POST /api/auth/login
// @desc    Iniciar sesión usando Stored Procedures
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Todos los campos son obligatorios' });
    }

    // Buscar usuario vía Stored Procedure
    const [result] = await pool.query('CALL sp_get_user_by_email(?)', [email]);
    const users = result[0];
    
    if (!users || users.length === 0) {
      return res.status(400).json({ error: 'Credenciales inválidas' });
    }

    const user = users[0];

    // Verificar contraseña
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Credenciales inválidas' });
    }

    // Generar JWT
    const payload = {
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    };

    // Firmar Token
    jwt.sign(
      payload,
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '30d' }, // 30 days for 'keep me logged in'
      (err, token) => {
        if (err) throw err;
        res.json({ token, user: payload.user });
      }
    );

  } catch (err) {
    console.error('Error en login:', err);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router;
