import express from "express";
import bcrypt from 'bcrypt';
import { supabase } from "../config/supabase.js";
import { verificarToken } from "../middlewares/verificarToken.js";

const router = express.Router();

router.post('/usuario/registro', async (req, res) => {
    const { nombre, apellido, telefono, email, clave, id_rol } = req.body;

    // 1. Validaciones con Expresiones Regulares (Regex)
    const nameRegex = /^[a-zA-ZÀ-ÿ\s]{2,40}$/; 
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;

    if (!nameRegex.test(nombre) || !nameRegex.test(apellido)) {
        return res.status(400).json({ error: 'El nombre y apellido solo deben contener letras.' });
    }
    if (!emailRegex.test(email)) {
        return res.status(400).json({ error: 'El formato del correo electrónico no es válido.' });
    }
    if (!passwordRegex.test(clave)) {
        return res.status(400).json({ error: 'La contraseña debe tener al menos 8 caracteres, incluyendo una letra y un número.' });
    }

    try {
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(clave, saltRounds);
        
        const { data, error } = await supabase
            .from('usuarios')
            .insert([
                {
                    nombre: nombre,
                    apellido: apellido,
                    telefono: telefono,
                    email: email,
                    clave: hashedPassword,
                    id_rol: 1
                }
            ]);

        if (error) throw error;

        res.status(201).json({ mensaje: 'Usuario registrado exitosamente' });

    } catch (error) {
        console.error("Error en el registro del backend:", error);
        res.status(500).json({ error: error.message || 'Hubo un error al registrar el usuario' });
    }
});

// PETICIÓN QUERY USUARIOS: ESTADO, BÚSQUEDA Y ROL
router.get("/usuarios", verificarToken, async (req, res) => {
    try {
        const { estado, buscar, rol } = req.query;

        let consulta = supabase
            .from("usuarios")
            .select(`id_usuario, nombre, apellido, email, estado_cuenta, id_rol, roles!id_rol (id_rol, nombre_rol), fecha_registro`)
            .order('id_usuario', { ascending: true });

        if (estado === "true") {
            consulta = consulta.eq("estado_cuenta", true);
        } else if (estado === "false") {
            consulta = consulta.eq("estado_cuenta", false);
        }

        if (buscar && buscar.trim() !== "") {
            consulta = consulta.or(`nombre.ilike.%${buscar}%,apellido.ilike.%${buscar}%,email.ilike.%${buscar}%`);
        }

        if (rol && rol.trim() !== "") {
            consulta = consulta.eq("id_rol", rol); 
        }

        const { data, error } = await consulta;

        if (error) throw error;

        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PETICIÓN PATCH USUARIOS
router.patch("/usuarios/:id", verificarToken, async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, apellido, estado_cuenta, id_rol } = req.body;

        const { data, error } = await supabase
            .from("usuarios")
            .update({ 
                nombre, 
                apellido, 
                estado_cuenta, 
                id_rol: parseInt(id_rol)
            })
            .eq("id_usuario", id)
            .select(`id_usuario, nombre, apellido, email, estado_cuenta, id_rol, roles!id_rol (nombre_rol), fecha_registro`); 

        if (error) throw error;

        res.status(200).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;