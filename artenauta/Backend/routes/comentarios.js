import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();

// GET: Obtener comentarios de una publicación específica
router.get("/comentarios/:id_publicacion", verificarToken, async (req, res) => {
    try {
        const { id_publicacion } = req.params;

        const { data, error } = await supabase
            .from("comentarios")
            .select(`
                *,
                usuarios (
                    id_usuario,
                    nombre
                )
            `)
            .eq("id_publicacion", id_publicacion)
            .order("fecha_comentario", { ascending: true });

        if (error) throw error;

        res.status(200).json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST: Guardar un nuevo comentario
router.post("/comentarios", verificarToken, async (req, res) => {
    try {
        const { id_publicacion, id_usuario_final, contenido } = req.body;

        if (!id_publicacion || !id_usuario_final || !contenido) {
            return res.status(400).json({ error: "Faltan campos requeridos (id_publicacion, id_usuario_final, contenido)" });
        }

        const { data, error } = await supabase
            .from("comentarios")
            .insert([
                {
                    id_publicacion,
                    id_usuario_final,
                    contenido,
                    fecha_comentario: new Date().toISOString(),
                },
            ])
            .select(`
                *,
                usuarios (
                    id_usuario,
                    nombre
                )
            `);

        if (error) throw error;

        if (!data || data.length === 0) {
            throw new Error("No se pudo obtener el comentario insertado.");
        }

        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: Obtener TODOS los comentarios de la plataforma (Para la tabla de Admin)
router.get("/admin/comentarios", verificarToken, async (req, res) => {
    try {
        const { data, error } = await supabase
            .from("comentarios")
            .select(`
                *,
                usuarios (
                    id_usuario,
                    nombre,
                    email
                ),
                publicaciones (
                    id_publicacion,
                    titulo
                )
            `)
            .order("fecha_comentario", { ascending: false }); // Los más recientes primero

        if (error) throw error;

        res.status(200).json(data || []);
    } catch (error) {
        console.error("Error en GET /admin/comentarios:", error);
        res.status(500).json({ error: error.message });
    }
});

// DELETE: Eliminar un comentario específico por su ID
router.delete("/comentarios/:id_comentario", verificarToken, async (req, res) => {
    try {
        const { id_comentario } = req.params;
        const { error } = await supabase
            .from("comentarios")
            .delete()
            .eq("id_comentario", id_comentario);

        if (error) throw error;

        res.status(200).json({ mensaje: "Comentario eliminado con éxito" });
    } catch (error) {
        console.error("Error en DELETE /comentarios/:id_comentario:", error);
        res.status(500).json({ error: error.message });
    }
});

export default router;
