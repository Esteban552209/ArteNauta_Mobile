import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();

// GET Buscar usuarios para iniciar conversacion
router.get("/usuarios/buscar", verificarToken, async (req, res) => {
    try {
        const { email, correo } = req.query;
        const targetEmail = email || correo;
        if (!targetEmail) return res.status(400).json({ error: "Se requiere un correo" });

        const { data, error } = await supabase
            .from("usuarios")
            .select("id_usuario, nombre, apellido, email")
            .eq("email", targetEmail)
            .maybeSingle();

        if (error) throw error;
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET Buscar conversacion de un ID
router.get("/conversaciones/usuario/:id_usuario", verificarToken, async (req, res) => {
    try {
        const id_usuario = parseInt(req.params.id_usuario);
        if (!id_usuario) return res.status(400).json({ error: "id_usuario inválido" });

        const { data: misParticipaciones, error: err1 } = await supabase
            .from("participantes")
            .select("id_conversacion")
            .eq("id_usuario", id_usuario);

        if (err1) throw err1;
        if (!misParticipaciones || misParticipaciones.length === 0) return res.status(200).json([]);

        const idsConversaciones = misParticipaciones.map(p => p.id_conversacion);

        const { data: otrosParticipantes, error: err2 } = await supabase
            .from("participantes")
            .select(`
                id_conversacion,
                id_usuario,
                usuarios (id_usuario, nombre, apellido)
            `)
            .in("id_conversacion", idsConversaciones)
            .neq("id_usuario", id_usuario);

        if (err2) throw err2;

        const resultado = otrosParticipantes.map(p => ({
            id_conversacion: p.id_conversacion,
            id_usuario_otro: p.id_usuario,
            nombre_otro: p.usuarios?.nombre
                ? `${p.usuarios.nombre} ${p.usuarios.apellido || ""}`.trim()
                : "Usuario"
        }));

        res.status(200).json(resultado);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Iniciar la conversacion con Validacion de existencia
router.post("/conversaciones", verificarToken, async (req, res) => {
    try {
        const { id_usuario_1, id_usuario_2 } = req.body;
        if (!id_usuario_1 || !id_usuario_2) return res.status(400).json({ error: "Faltan campos" });

        const { data: part1, error: err1 } = await supabase
            .from("participantes").select("id_conversacion").eq("id_usuario", id_usuario_1);
        if (err1) throw err1;

        if (part1 && part1.length > 0) {
            const ids = part1.map(p => p.id_conversacion);
            const { data: part2, error: err2 } = await supabase
                .from("participantes").select("id_conversacion").in("id_conversacion", ids).eq("id_usuario", id_usuario_2);
            if (err2) throw err2;
            if (part2 && part2.length > 0) return res.status(200).json({ id_conversacion: part2[0].id_conversacion, existe: true });
        }

        const { data: nuevaConv, error: err3 } = await supabase
            .from("conversaciones").insert({ fecha_creacion: new Date().toISOString() }).select("id_conversacion").single();
        if (err3) throw err3;

        const { error: err4 } = await supabase.from("participantes").insert([
            { id_conversacion: nuevaConv.id_conversacion, id_usuario: id_usuario_1 },
            { id_conversacion: nuevaConv.id_conversacion, id_usuario: id_usuario_2 }
        ]);
        if (err4) throw err4;

        res.status(201).json({ id_conversacion: nuevaConv.id_conversacion, existe: false });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET Muestra mensajes de una conversacion
router.get("/mensajes/:id_conversacion", verificarToken, async (req, res) => {
    try {
        const { id_conversacion } = req.params;
        const { data, error } = await supabase
            .from("mensajes").select("*").eq("id_conversacion", id_conversacion).order("fecha_envio", { ascending: true });
        if (error) throw error;
        res.status(200).json(data || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST Crea notificaciones de los mensajes
router.post("/mensajes", verificarToken, async (req, res) => {
    try {
        const { id_conversacion, id_usuario, contenido } = req.body;

        if (!id_conversacion || !id_usuario || !contenido) {
            return res.status(400).json({ error: "Datos incompletos" });
        }

        const { data: nuevoMensaje, error: errorMensaje } = await supabase
            .from("mensajes")
            .insert([{ 
                id_conversacion, 
                id_usuario, 
                contenido, 
                fecha_envio: new Date().toISOString() 
            }])
            .select()
            .single();

        if (errorMensaje) throw errorMensaje;

        const { data: otrosParticipantes, error: errorParticipantes } = await supabase
            .from("participantes")
            .select("id_usuario")
            .eq("id_conversacion", id_conversacion)
            .neq("id_usuario", id_usuario); 

        if (errorParticipantes) throw errorParticipantes;

        if (otrosParticipantes && otrosParticipantes.length > 0) {
            const idReceptor = otrosParticipantes[0].id_usuario;

            const { error: errorNotif } = await supabase
                .from("notificaciones")
                .insert({
                    id_usuario: idReceptor, 
                    asunto: "Tienes un nuevo mensaje en el chat",
                    tipo_notificacion: "Mensaje", 
                    fecha_notificacion: new Date().toISOString()
                });

            if (errorNotif) {
                console.error("Aviso: El mensaje se envió pero la notificación falló:", errorNotif.message);
            }
        }

        res.status(201).json(nuevoMensaje);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;