import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();


//Metodos GET

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

// GET — obtener solicitudes pendientes (solo admin) (funciona)

router.get("/notificaciones/solicitudes", verificarToken, async (req, res) => {
    try {
        const { data, error } = await supabase
            .from("solicitudes")
            .select("*, usuarios(nombre, apellido)")
            .eq("tipo_solicitud", "artista")
            .eq("estado_solicitud", "Pendiente")
            .order("fecha_solicitud", { ascending: false });

        if (error) throw error;

        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


//Metodos PATCH

// PATCH — aprobar solicitud
router.patch("/notificaciones/solicitudes/:id/aprobar", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;

        console.log("Intentando aprobar la solicitud con ID:", id);

        // 1. Buscar la solicitud para obtener el id_usuario automáticamente
        const { data: solicitud, error: errorBusqueda } = await supabase
            .from("solicitudes")
            .select("id_usuario")
            .eq("id_solicitud", id)
            .single();

        if (errorBusqueda || !solicitud) {
            return res.status(404).json({ error: "La solicitud no existe o ya fue procesada." });
        }

        const id_usuario = solicitud.id_usuario;

        // 2. Actualizar estado de la solicitud a Aceptada
        const { data, error } = await supabase
            .from("solicitudes")
            .update({ estado_solicitud: "Aceptada" })
            .eq("id_solicitud", id)
            .select();

        if (error) throw error;

        if (!data || data.length === 0) {
            return res.status(404).json({
                error: `No se encontró ninguna solicitud donde id_solicitud sea igual a ${id}`
            });
        }

        // 3. Cambiar rol del usuario a Artista (2)
        const { error: errorRol } = await supabase
            .from("usuarios")
            .update({ id_rol: 2 })
            .eq("id_usuario", id_usuario);
        if (errorRol) throw errorRol;

        // 4. Crear notificación para el usuario
        const { error: errorNotif } = await supabase
            .from("notificaciones")
            .insert({
                id_usuario,
                asunto: "¡Tu solicitud para ser artista fue aprobada!",
                tipo_notificacion: "solicitud_aprobada",
                fecha_notificacion: new Date().toISOString(),
            });
        if (errorNotif) throw errorNotif;

        res.status(200).json({
            mensaje: "¡Solicitud aprobada, rol actualizado y notificación enviada!",
            solicitud: data[0]
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// PATCH — aprobar solicitud (Adaptado)
router.patch("/notificaciones/solicitudes/:id/aprobar", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;

        // 1. Buscar la solicitud para obtener el id_usuario automáticamente de la DB
        const { data: solicitud, error: errorBusqueda } = await supabase
            .from("solicitudes")
            .select("id_usuario")
            .eq("id_solicitud", id)
            .single();

        if (errorBusqueda || !solicitud) {
            return res.status(404).json({ error: "La solicitud no existe o ya fue procesada." });
        }

        const id_usuario = solicitud.id_usuario;

        // 2. Actualizar estado de la solicitud a Aceptada
        const { data, error } = await supabase
            .from("solicitudes")
            .update({ estado_solicitud: "Aceptada" })
            .eq("id_solicitud", id)
            .select();

        if (error) throw error;

        // 3. Cambiar rol del usuario a Artista (2)
        const { error: errorRol } = await supabase
            .from("usuarios")
            .update({ id_rol: 2 })
            .eq("id_usuario", id_usuario);
        if (errorRol) throw errorRol;

        // 4. Crear notificación (Protegido por si el ENUM falla)
        let notificacionEstado = "Creada correctamente";
        try {
            const { error: errorNotif } = await supabase
                .from("notificaciones")
                .insert({
                    id_usuario,
                    asunto: "¡Tu solicitud para ser artista fue aprobada!",
                    tipo_notificacion: "solicitud_aprobada", // Si este falla, el try/catch lo atrapa sin romper la ruta
                    fecha_notificacion: new Date().toISOString(),
                });
            if (errorNotif) throw errorNotif;
        } catch (errNotif) {
            console.log("Aviso: No se creó la fila de notificación por conflicto de ENUM, pero el rol y la solicitud sí se guardaron.");
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


// PATCH — rechazar solicitud (Adaptado)
router.patch("/notificaciones/solicitudes/:id/rechazar", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;

        // 1. Buscar la solicitud para obtener el id_usuario automáticamente de la DB
        const { data: solicitud, error: errorBusqueda } = await supabase
            .from("solicitudes")
            .select("id_usuario")
            .eq("id_solicitud", id)
            .single();

        if (errorBusqueda || !solicitud) {
            return res.status(404).json({ error: "La solicitud no existe o ya fue procesada." });
        }

        const id_usuario = solicitud.id_usuario;

        // 2. Actualizar estado de la solicitud a Rechazada
        const { error: e1 } = await supabase
            .from("solicitudes")
            .update({ estado_solicitud: "Rechazada" })
            .eq("id_solicitud", id);
        if (e1) throw e1;

        // 3. Crear notificación (Protegido por si el ENUM falla)
        let notificacionEstado = "Creada correctamente";
        try {
            const { error: e2 } = await supabase
                .from("notificaciones")
                .insert({
                    id_usuario,
                    asunto: "Tu solicitud para ser artista fue rechazada.",
                    tipo_notificacion: "solicitud_rechazada", // Si saca error de ENUM, se salta al catch sin tumbar la petición
                    fecha_notificacion: new Date().toISOString(),
                });
            if (e2) throw e2;
        } catch (errNotif) {
            console.log("Aviso: No se creó la notificación por conflicto de ENUM, pero la solicitud se rechazó con éxito.");
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

//Metodos POST
// Crear una nueva solicitud (POST)
router.post('/notificaciones/solicitudes', verificarToken, async (req, res) => {
    const { tipo_solicitud, id_usuario } = req.body;

    try {
        const { data, error } = await supabase
            .from('solicitudes')
            .insert([
                { 
                    tipo_solicitud, 
                    id_usuario, 
                    estado_solicitud: 'Pendiente' // Se crea automáticamente en "Pendiente"
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

//Metodos DELETE

// DELETE — eliminar una notificación específica
router.delete("/notificaciones/:id", verificarToken, async (req, res) => {
    try {
        const { id } = req.params; // ID de la notificación desde la URL

        const { error } = await supabase
            .from("notificaciones")
            .delete()
            .eq("id_notificacion", id); // Cambia "id_notificacion" por el nombre exacto de tu llave primaria

        if (error) throw error;

        res.status(200).json({ mensaje: "Notificación eliminada correctamente en Supabase." });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// DELETE — eliminar una solicitud específica 
router.delete("/solicitudes/:id", verificarToken, async (req, res) => {
    try {
        const { id } = req.params; // ID de la solicitud desde la URL

        const { error } = await supabase
            .from("solicitudes")
            .delete()
            .eq("id_solicitud", id); // Elimina la fila que coincida con el ID

        if (error) throw error;

        res.status(200).json({ mensaje: "Solicitud eliminada correctamente de Supabase." });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


export default router;  