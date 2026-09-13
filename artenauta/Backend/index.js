import express from "express";
import cors from "cors";

import authRoutes from "./routes/auth.js"
import publicacionesRoutes from "./routes/publicaciones.js";
import usuariosRoutes from "./routes/usuarios.js";
import notificacionesRoutes from "./routes/notificaciones.js";
import comentariosRoutes from "./routes/comentarios.js";
import conversacionesRoutes from "./routes/conversaciones.js";
import estadisticasRoutes from "./routes/estadisticas.js";
import categoriasRoutes from "./routes/categorias.js"
import perfilesRoutes from "./routes/perfiles.js"
import reaccionesRoutes from "./routes/reacciones.js"

const app = express();

app.use(cors());
app.use(express.json());

app.use("/mobile",notificacionesRoutes);
app.use("/mobile",authRoutes);
app.use("/mobile",publicacionesRoutes);
app.use("/mobile",usuariosRoutes);
app.use("/mobile",comentariosRoutes);
app.use("/mobile",conversacionesRoutes);
app.use("/mobile",estadisticasRoutes);
app.use("/mobile",categoriasRoutes);
app.use("/mobile",perfilesRoutes)
app.use("/mobile",reaccionesRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor de ArteNauta corriendo en el puerto ${PORT}`);
});