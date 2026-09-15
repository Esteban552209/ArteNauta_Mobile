import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();

// ==========================================
// MÉTODOS GET
// ==========================================

// GET — obtener notificaciones de un usuario
router.get("/notificaciones", verificarToken, async (req, res) => {
    try {
        const { id_usuario } = req.query;

        if (!id_usuario) {
            return res.status(400).json({ error: "id_usuario es requerido" });
        }

        const { data, error } = await supabase
            .from("notificaciones")
            .select("*")
            .eq("id_usuario", id_usuario)
            .order("fecha_notificacion", { ascending: false })
            .limit(20);

        if (error) throw error;

        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET — verificar si usuario tiene solicitud pendiente
router.get("/notificaciones/solicitudes/pendiente", verificarToken, async (req, res) => {
    const { id_usuario } = req.query;
    try {
        const { data } = await supabase
            .from("solicitudes")
            .select("id_solicitud")
            .eq("id_usuario", id_usuario)
            .eq("tipo_solicitud", "artista")
            .eq("estado_solicitud", "Pendiente")
            .maybeSingle();

        res.status(200).json({ tieneSolicitud: data !== null });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET — obtener solicitudes pendientes (solo admin - filtrando duplicados)
router.get("/notificaciones/solicitudes", verificarToken, async (req, res) => {
    try {
        const { data, error } = await supabase
            .from("solicitudes")
            .select("*, usuarios(nombre, apellido)")
            .eq("tipo_solicitud", "artista")
            .eq("estado_solicitud", "Pendiente")
            .order("fecha_solicitud", { ascending: false });

        if (error) throw error;

        // Filtra para mantener únicamente la última solicitud por id_usuario
        const solicitudesUnicas = Object.values(
            data.reduce((acc, curr) => {
                if (!acc[curr.id_usuario]) {
                    acc[curr.id_usuario] = curr;
                }
                return acc;
            }, {})
        );

        res.status(200).json(solicitudesUnicas);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==========================================
// MÉTODOS POST
// ==========================================

// POST — crear una nueva solicitud (con protección contra duplicados)
router.post('/notificaciones/solicitudes', verificarToken, async (req, res) => {
    const { tipo_solicitud, id_usuario } = req.body;

    try {
        // Verificar si ya existe una pendiente antes de insertar
        const { data: existente } = await supabase
            .from('solicitudes')
            .select('id_solicitud')
            .eq('id_usuario', id_usuario)
            .eq('tipo_solicitud', tipo_solicitud)
            .eq('estado_solicitud', 'Pendiente')
            .maybeSingle();

        if (existente) {
            return res.status(400).json({ error: "Ya tienes una solicitud pendiente en proceso." });
        }

        const { data, error } = await supabase
            .from('solicitudes')
            .insert([
                {
                    tipo_solicitud,
                    id_usuario,
                    estado_solicitud: 'Pendiente'
                }
            ])
            .select();

        if (error) {
            return res.status(400).json({ error: error.message });
        }

        res.status(201).json({
            mensaje: "¡Solicitud creada con éxito!",
            solicitud: data[0]
        });

    } catch (error) {
        res.status(500).json({ error: "Error interno del servidor" });
    }
});

// POST /notificaciones/like
router.post('/notificaciones/like', verificarToken, async (req, res) => {
    const { id_publicacion, id_usuario, nombre_usuario } = req.body;
    try {
        const { data: pub } = await supabase
            .from('publicaciones')
            .select('id_usuario_artista')
            .eq('id_publicacion', id_publicacion)
            .single();

        const idArtista = pub?.id_usuario_artista;

        if (idArtista && idArtista !== id_usuario) {
            await supabase.from('notificaciones').insert({
                id_usuario: idArtista,
                asunto: `${nombre_usuario} le dio Me gusta a tu publicación`,
                tipo_notificacion: 'Reaccion',
                fecha_notificacion: new Date().toISOString(),
            });
        }

        res.status(200).json({ ok: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST /notificaciones/comentario
router.post('/notificaciones/comentario', verificarToken, async (req, res) => {
    const { id_publicacion, id_usuario, nombre_usuario } = req.body;
    try {
        const { data: pub } = await supabase
            .from('publicaciones')
            .select('id_usuario_artista')
            .eq('id_publicacion', id_publicacion)
            .single();

        const idArtista = pub?.id_usuario_artista;

        if (idArtista && idArtista !== id_usuario) {
            await supabase.from('notificaciones').insert({
                id_usuario: idArtista,
                asunto: `${nombre_usuario} comentó tu publicación`,
                tipo_notificacion: 'Comentario',
                fecha_notificacion: new Date().toISOString(),
            });
        }

        res.status(200).json({ ok: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==========================================
// MÉTODOS PATCH
// ==========================================

// PATCH — aprobar solicitud
router.patch("/notificaciones/solicitudes/:id/aprobar", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;

        const { data: solicitud, error: errorBusqueda } = await supabase
            .from("solicitudes")
            .select("id_usuario")
            .eq("id_solicitud", id)
            .single();

        if (errorBusqueda || !solicitud) {
            return res.status(404).json({ error: "La solicitud no existe o ya fue procesada." });
        }

        const id_usuario = solicitud.id_usuario;

        const { data, error } = await supabase
            .from("solicitudes")
            .update({ estado_solicitud: "Aceptada" })
            .eq("id_solicitud", id)
            .select();

        if (error) throw error;

        const { error: errorRol } = await supabase
            .from("usuarios")
            .update({ id_rol: 2 })
            .eq("id_usuario", id_usuario);
        if (errorRol) throw errorRol;

        let notificacionEstado = "Creada correctamente";
        try {
            const { error: errorNotif } = await supabase
                .from("notificaciones")
                .insert({
                    id_usuario,
                    asunto: "¡Tu solicitud para ser artista fue aprobada!",
                    tipo_notificacion: "solicitud_aprobada",
                    fecha_notificacion: new Date().toISOString(),
                });
            if (errorNotif) throw errorNotif;
        } catch (errNotif) {
            console.log("Aviso: No se creó la fila de notificación por conflicto de ENUM.");
            notificacionEstado = "No creada (Revisar ENUM en Supabase)";
        }

        res.status(200).json({
            mensaje: "¡Solicitud aprobada y rol actualizado con éxito!",
            notificacion: notificacionEstado,
            solicitud: data[0]
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PATCH — rechazar solicitud
router.patch("/notificaciones/solicitudes/:id/rechazar", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;

        const { data: solicitud, error: errorBusqueda } = await supabase
            .from("solicitudes")
            .select("id_usuario")
            .eq("id_solicitud", id)
            .single();

        if (errorBusqueda || !solicitud) {
            return res.status(404).json({ error: "La solicitud no existe o ya fue procesada." });
        }

        const id_usuario = solicitud.id_usuario;

        const { error: e1 } = await supabase
            .from("solicitudes")
            .update({ estado_solicitud: "Rechazada" })
            .eq("id_solicitud", id);
        if (e1) throw e1;

        let notificacionEstado = "Creada correctamente";
        try {
            const { error: e2 } = await supabase
                .from("notificaciones")
                .insert({
                    id_usuario,
                    asunto: "Tu solicitud para ser artista fue rechazada.",
                    tipo_notificacion: "solicitud_rechazada",
                    fecha_notificacion: new Date().toISOString(),
                });
            if (e2) throw e2;
        } catch (errNotif) {
            console.log("Aviso: No se creó la notificación por conflicto de ENUM.");
            notificacionEstado = "No creada (Revisar ENUM en Supabase)";
        }

        res.status(200).json({
            mensaje: "Solicitud rechazada correctamente en Supabase.",
            notificacion: notificacionEstado
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==========================================
// MÉTODOS DELETE
// ==========================================

// DELETE — eliminar una notificación específica
router.delete("/notificaciones/:id", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;

        const { error } = await supabase
            .from("notificaciones")
            .delete()
            .eq("id_notificacion", id);

        if (error) throw error;

        res.status(200).json({ mensaje: "Notificación eliminada correctamente en Supabase." });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE — eliminar una solicitud específica 
router.delete("/solicitudes/:id", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;

        const { error } = await supabase
            .from("solicitudes")
            .delete()
            .eq("id_solicitud", id);

        if (error) throw error;

        res.status(200).json({ mensaje: "Solicitud eliminada correctamente de Supabase." });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;