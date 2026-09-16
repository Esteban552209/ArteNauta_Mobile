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

// GET Listar conversaciones del usuario, con último mensaje y no leídos
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

        // Traer todos los mensajes de esas conversaciones para calcular último + no leídos
        const { data: mensajes, error: err3 } = await supabase
            .from("mensajes")
            .select("id_conversacion, contenido, fecha_envio, id_usuario, leido")
            .in("id_conversacion", idsConversaciones)
            .order("fecha_envio", { ascending: false });

        if (err3) throw err3;

        const ultimoPorConversacion = {};
        const noLeidosPorConversacion = {};

        for (const m of mensajes || []) {
            if (!ultimoPorConversacion[m.id_conversacion]) {
                ultimoPorConversacion[m.id_conversacion] = m;
            }
            if (m.id_usuario !== id_usuario && m.leido === false) {
                noLeidosPorConversacion[m.id_conversacion] =
                    (noLeidosPorConversacion[m.id_conversacion] || 0) + 1;
            }
        }

        const resultado = otrosParticipantes.map(p => {
            const ultimo = ultimoPorConversacion[p.id_conversacion];
            return {
                id_conversacion: p.id_conversacion,
                id_usuario_otro: p.id_usuario,
                nombre_otro: p.usuarios?.nombre
                    ? `${p.usuarios.nombre} ${p.usuarios.apellido || ""}`.trim()
                    : "Usuario",
                ultimo_mensaje: ultimo ? ultimo.contenido : null,
                fecha_ultimo_mensaje: ultimo ? ultimo.fecha_envio : null,
                no_leidos: noLeidosPorConversacion[p.id_conversacion] || 0,
            };
        });

        // Más recientes primero
        resultado.sort((a, b) => {
            if (!a.fecha_ultimo_mensaje) return 1;
            if (!b.fecha_ultimo_mensaje) return -1;
            return new Date(b.fecha_ultimo_mensaje) - new Date(a.fecha_ultimo_mensaje);
        });

        res.status(200).json(resultado);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST Iniciar la conversacion con validación de existencia
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

// DELETE Eliminar conversación completa
router.delete("/conversaciones/:id_conversacion", verificarToken, async (req, res) => {
    try {
        const { id_conversacion } = req.params;

        await supabase.from("mensajes").delete().eq("id_conversacion", id_conversacion);
        await supabase.from("participantes").delete().eq("id_conversacion", id_conversacion);
        const { error } = await supabase.from("conversaciones").delete().eq("id_conversacion", id_conversacion);

        if (error) throw error;
        res.status(200).json({ ok: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET Muestra mensajes de una conversacion (excluye los ocultos-para-mí)
router.get("/mensajes/:id_conversacion", verificarToken, async (req, res) => {
    try {
        const { id_conversacion } = req.params;
        const { id_usuario } = req.query;

        let idsOcultos = [];
        if (id_usuario) {
            const { data: ocultos, error: errOcultos } = await supabase
                .from("mensajes_ocultos")
                .select("id_mensaje")
                .eq("id_usuario", id_usuario);
            if (errOcultos) throw errOcultos;
            idsOcultos = (ocultos || []).map(o => o.id_mensaje);
        }

        const { data, error } = await supabase
            .from("mensajes").select("*").eq("id_conversacion", id_conversacion).order("fecha_envio", { ascending: true });
        if (error) throw error;

        const filtrados = (data || []).filter(m => !idsOcultos.includes(m.id_mensaje));
        res.status(200).json(filtrados);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST Crea mensaje y notifica al otro participante
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
                fecha_envio: new Date().toISOString(),
                leido: false
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

// PATCH Marcar mensajes de la otra persona como leídos
router.patch("/mensajes/leidos", verificarToken, async (req, res) => {
    try {
        const { id_conversacion, id_usuario } = req.body;
        if (!id_conversacion || !id_usuario) return res.status(400).json({ error: "Faltan campos" });

        const { error } = await supabase
            .from("mensajes")
            .update({ leido: true })
            .eq("id_conversacion", id_conversacion)
            .neq("id_usuario", id_usuario)
            .eq("leido", false);

        if (error) throw error;
        res.status(200).json({ ok: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE Eliminar un mensaje: ?modo=mi|todos
router.delete("/mensajes/:id_mensaje", verificarToken, async (req, res) => {
    try {
        const { id_mensaje } = req.params;
        const { modo, id_usuario } = req.query;

        if (modo === "mi") {
            if (!id_usuario) return res.status(400).json({ error: "id_usuario requerido" });
            const { error } = await supabase
                .from("mensajes_ocultos")
                .insert({ id_mensaje, id_usuario });
            if (error) throw error;
            return res.status(200).json({ ok: true, modo: "mi" });
        }

        if (modo === "todos") {
            const { error } = await supabase
                .from("mensajes")
                .update({ eliminado_todos: true, contenido: "" })
                .eq("id_mensaje", id_mensaje);
            if (error) throw error;
            return res.status(200).json({ ok: true, modo: "todos" });
        }

        return res.status(400).json({ error: "modo debe ser 'mi' o 'todos'" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;