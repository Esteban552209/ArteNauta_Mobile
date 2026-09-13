import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();

// GET: Obtener todas las categorías fijas ordenadas alfabéticamente
router.get("/categorias", verificarToken, async (req, res) => {
    try {
        const { buscar } = req.query;

        let query = supabase
            .from("categorias")
            .select("*")
            .order("nombre_categoria", { ascending: true });

        if (buscar) {
            query = query.ilike("nombre_categoria", `%${buscar}%`);
        }
        const { data, error } = await query;

        if (error) throw error;
        res.status(200).json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST: Crear categorias
router.post("/categorias", verificarToken, async (req, res) => {
    try {
        const { nombre_categoria, descripcion } = req.body;

        if (!nombre_categoria || !descripcion) {
            return res
                .status(400)
                .json({
                    error: "Faltan campos obligatorios (Nombre Categoria, Descripcion)",
                });
        }

        const { data, error } = await supabase
            .from("categorias")
            .insert([
                {
                    nombre_categoria,
                    descripcion,
                },
            ])
            .select(`*`);

        if (error) throw error;

        if (!data || data.length === 0) {
            throw new Error("No se pudo obtener la categoria creada.");
        }

        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PATCH: Editar categorias por su ID
router.patch("/categorias/:id", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre_categoria, descripcion } = req.body;

        const { data, error } = await supabase
            .from("categorias")
            .update({
                nombre_categoria: nombre_categoria,
                descripcion: descripcion,
            })
            .eq("id_categoria", id)
            .select();
        if (error) throw error;
        if (data.length === 0) {
            return res.status(404).json({ error: "Categoría no encontrada" });
        }

        res.status(200).json({
            mensaje: "Categoría actualizada con éxito",
            categoria: data[0],
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

export default router;
