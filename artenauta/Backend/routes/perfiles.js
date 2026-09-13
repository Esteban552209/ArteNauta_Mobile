import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();

// GET: obtener el perfil completo del usuario autenticado (usuario + perfil, si existe)
router.get("/perfil", verificarToken, async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;

        const { data, error } = await supabase
            .from("usuarios")
            .select(`
                id_usuario,
                nombre,
                apellido,
                email,
                telefono,
                perfiles (
                    id_perfil,
                    foto_perfil,
                    descripcion,
                    ocupacion
                )
            `)
            .eq("id_usuario", id_usuario)
            .single();

        if (error) throw error;
        const perfil = data.perfiles || null;

        res.status(200).json({
            id_usuario: data.id_usuario,
            nombre: data.nombre,
            apellido: data.apellido,
            email: data.email,
            telefono: data.telefono,
            foto_perfil: perfil?.foto_perfil ?? null,
            descripcion: perfil?.descripcion ?? "",
            ocupacion: perfil?.ocupacion ?? "",
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PATCH: crear o actualizar el perfil extendido del usuario
router.patch("/perfil", verificarToken, async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;
        const { descripcion, ocupacion } = req.body;

        const { data, error } = await supabase
            .from("perfiles")
            .upsert(
                { id_usuario, descripcion, ocupacion },
                { onConflict: "id_usuario" }
            )
            .select()
            .single();

        if (error) throw error;

        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PATCH: actualizar nombre, apellido y teléfono del usuario autenticado
router.patch("/perfil/usuario", verificarToken, async (req, res) => {
    try {
        const id_usuario = req.usuario.id_usuario;
        const { nombre, apellido, telefono } = req.body;

        const { data, error } = await supabase
            .from("usuarios")
            .update({ nombre, apellido, telefono })
            .eq("id_usuario", id_usuario)
            .select(`id_usuario, nombre, apellido, email, telefono, id_rol`)
            .single();

        if (error) throw error;

        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;