const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json({ extended: false }));

// Test route
app.get('/api/health', (req, res) => res.send('API running'));

// Static route for PDFs
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/notes', require('./routes/notes'));

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Servidor de U-Notes corriendo de forma robusta en el puerto ${PORT}`));
