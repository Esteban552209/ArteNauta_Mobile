import express from "express";
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();


// POST: Agregar o retirar like de una publicacion
router.post(
  "/publicaciones/:id_publicacion/like",
  verificarToken,
  async (req, res) => {

    const { id_publicacion } = req.params;
    const { id_usuario } = req.body;

    const tipoReaccion = "like";

    if (!id_usuario) {
      return res.status(400).json({
        error: "El id_usuario es requerido."
      });
    }

    try {

      const { data: existente, error: errorBusqueda } = await supabase
        .from("reacciones")
        .select("*")
        .eq("id_publicacion", id_publicacion)
        .eq("id_usuario", id_usuario)
        .eq("tipo", tipoReaccion);

      if (errorBusqueda) throw errorBusqueda;

      if (existente.length > 0) {

        const { error: errorDelete } = await supabase
          .from("reacciones")
          .delete()
          .eq("id_publicacion", id_publicacion)
          .eq("id_usuario", id_usuario)
          .eq("tipo", tipoReaccion);

        if (errorDelete) throw errorDelete;

        return res.json({
          registrado: false,
          mensaje: "Like retirado con éxito"
        });
      }

      const { error: errorInsert } = await supabase
        .from("reacciones")
        .insert([
          {
            fecha: new Date(),
            tipo: tipoReaccion,
            id_usuario,
            id_publicacion
          }
        ]);

      if (errorInsert) throw errorInsert;

      return res.json({
        registrado: true,
        mensaje: "Like registrado con éxito"
      });

    } catch (error) {
      console.error("Error en POST /like:", error);

      return res.status(500).json({
        error: "Error interno al procesar el me gusta."
      });
    }
  }
);


// GET: Obtener información de likes
router.get(
  "/publicaciones/:id_publicacion/likes-info",
  async (req, res) => {

    const { id_publicacion } = req.params;
    const { id_usuario } = req.query;

    const tipoReaccion = "like";

    try {

      const { data: likes, error: errorLikes } = await supabase
        .from("reacciones")
        .select("*")
        .eq("id_publicacion", id_publicacion)
        .eq("tipo", tipoReaccion);

      if (errorLikes) throw errorLikes;

      const totalLikes = likes.length;

      let usuarioDioLike = false;

      if (id_usuario) {
        usuarioDioLike = likes.some(
          reaccion => reaccion.id_usuario == id_usuario
        );
      }

      return res.json({
        totalLikes,
        usuarioDioLike
      });

    } catch (error) {
      console.error("Error en GET /likes-info:", error);

      return res.status(500).json({
        error: "Error al obtener estadísticas de reacciones."
      });
    }
  }
);

export default router;