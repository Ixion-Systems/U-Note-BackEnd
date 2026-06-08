const express = require('express');
const router = express.Router();
const db = require('../config/db');
const multer = require('multer');
const path = require('path');

// Configuración de Multer para la subida de PDFs
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, '../uploads/'));
    },
    filename: (req, file, cb) => {
        const titleSafe = req.body.title ? req.body.title.replace(/[^a-z0-9]/gi, '_').toLowerCase() : 'apunte';
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, `${titleSafe}_${uniqueSuffix}.pdf`);
    }
});

const upload = multer({ 
    storage,
    limits: { fileSize: 30 * 1024 * 1024 }, // 30 MB
    fileFilter: (req, file, cb) => {
        if (file.mimetype === 'application/pdf') {
            cb(null, true);
        } else {
            cb(new Error('Solo se permiten archivos PDF.'));
        }
    }
});

// @route   GET /api/notes/filters
// @desc    Obtener lista de carreras y materias para el Sidebar
// @access  Public (O protegido en el futuro)
router.get('/filters', async (req, res) => {
    try {
        const [results] = await db.query('CALL sp_get_filters()');
        
        // results contiene 2 arrays (uno por cada SELECT en el SP) más un array de info
        const careers = results[0];
        const subjects = results[1];
        
        res.json({ careers, subjects });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// @route   GET /api/notes/search
// @desc    Buscar apuntes con filtros y paginación
// @access  Public
router.get('/search', async (req, res) => {
    try {
        const searchTerm = req.query.q || null;
        const careerId = req.query.careerId ? parseInt(req.query.careerId) : null;
        const subjectId = req.query.subjectId ? parseInt(req.query.subjectId) : null;
        const year = req.query.year ? parseInt(req.query.year) : null;
        
        const page = req.query.page ? parseInt(req.query.page) : 1;
        const limit = 21; // 21 ítems por página (múltiplo de 3 para cuadrar perfectamente en grilla de 3 columnas)
        const offset = (page - 1) * limit;

        const [results] = await db.query('CALL sp_search_notes(?, ?, ?, ?, ?, ?)', [
            searchTerm, careerId, subjectId, year, offset, limit
        ]);

        const notes = results[0];
        const totalCountRow = results[1][0];
        const totalCount = totalCountRow ? totalCountRow.total_count : 0;
        const totalPages = Math.ceil(totalCount / limit);

        res.json({
            notes,
            pagination: {
                totalCount,
                totalPages,
                currentPage: page,
                limit
            }
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Ruta para subir un apunte
router.post('/upload', upload.single('pdf'), async (req, res) => {
    try {
        const { title, description, subjectId } = req.body;
        const file = req.file;

        if (!file || !title || !subjectId) {
            return res.status(400).json({ error: "Faltan datos requeridos (archivo, título o materia)." });
        }

        const [result] = await db.query(
            'CALL sp_upload_note(?, ?, ?, ?)',
            [title, description || '', file.filename, subjectId]
        );

        res.json({ message: "Apunte subido exitosamente", noteId: result[0][0].insertId });
    } catch (error) {
        console.error("Error al subir apunte:", error);
        res.status(500).json({ error: error.message || "Error en el servidor al subir el archivo." });
    }
});

module.exports = router;
