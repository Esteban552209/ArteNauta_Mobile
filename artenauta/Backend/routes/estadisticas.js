import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js"; 

const router = express.Router();

// GET: Obtener métricas consolidadas para el Dashboard de Admin
router.get("/dashboard/estadisticas", verificarToken, async (req, res) => {
    try {
        const [
            usersCount, 
            artistsCount, 
            postsCount, 
            commentsCount
        ] = await Promise.all([
            supabase.from("usuarios").select("*", { count: "exact", head: true }),

            supabase.from("usuarios").select("*", { count: "exact", head: true }).eq("id_rol", 2),

            supabase.from("publicaciones").select("*", { count: "exact", head: true }),

            supabase.from("comentarios").select("*", { count: "exact", head: true })
        ]);

        if (usersCount.error) throw usersCount.error;
        if (artistsCount.error) throw artistsCount.error;
        if (postsCount.error) throw postsCount.error;
        if (commentsCount.error) throw commentsCount.error;

        res.status(200).json({
            totalUsuarios: usersCount.count || 0,
            totalArtistas: artistsCount.count || 0,
            totalPublicaciones: postsCount.count || 0,
            totalComentarios: commentsCount.count || 0
        });

    } catch (error) {
        console.error("Error en endpoint estadisticas:", error);
        res.status(500).json({ error: error.message });
    }
});

export default router;