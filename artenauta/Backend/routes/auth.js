import express from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { supabase } from "../config/supabase.js";
import nodemailer from "nodemailer";

const router = express.Router();

// POST Login de usuarios con JWT
router.post("/auth/login", async (req, res) => {
    const { email, password } = req.body;

    try {
        const { data: usuarioEncontrado, error } = await supabase
            .from("usuarios")
            .select("*")
            .eq("email", email)
            .maybeSingle();

        if (error) throw error;

        if (!usuarioEncontrado) {
            return res.status(401).json({ mensaje: "Correo o contraseña incorrectos" });
        }

        const passwordValida = await bcrypt.compare(password, usuarioEncontrado.clave);

        if (!passwordValida) {
            return res.status(401).json({ mensaje: "Correo o contraseña incorrectos" });
        }

        if (usuarioEncontrado.estado_cuenta === false) {
            return res.status(403).json({
                mensaje: "Tu cuenta ha sido desactivada por un administrador. No puedes iniciar sesión."
            });
        }

        const payload = {
            id_usuario: usuarioEncontrado.id_usuario,
            id_rol: usuarioEncontrado.id_rol
        };

        const secretKey = process.env.JWT_SECRET || "mi_clave_super_secreta_desarrollo";
        const token = jwt.sign(payload, secretKey, { expiresIn: "5h" });

        res.status(200).json({
            mensaje: "Inicio de sesión exitoso",
            token: token,
            usuario: {
                id_usuario: usuarioEncontrado.id_usuario,
                nombre: usuarioEncontrado.nombre,
                email: usuarioEncontrado.email,
                id_rol: usuarioEncontrado.id_rol
            }
        });

    } catch (error) {
        console.error("Error en el login:", error);
        res.status(500).json({ mensaje: "Error interno del servidor" });
    }
});

// POST Solicitar recuperación de contraseña
router.post("/auth/forgot-password", async (req, res) => {
    const { email } = req.body;

    try {
        const { data: usuarioEncontrado, error } = await supabase
            .from("usuarios")
            .select("*")
            .eq("email", email)
            .maybeSingle();

        if (error) throw error;

        // Siempre respondemos éxito por seguridad, para no revelar qué correos están registrados
        if (!usuarioEncontrado) {
            return res.status(200).json({ mensaje: "Si el correo está registrado, recibirás un enlace de recuperación." });
        }

        const secretKey = process.env.JWT_SECRET || "mi_clave_super_secreta_desarrollo";
        const token = jwt.sign({ email }, secretKey, { expiresIn: '15m' });

        // IMPORTANTE: Tu frontend está corriendo con HTTPS según tu vite.config.js
        const frontUrl = process.env.FRONTEND_URL || "https://localhost:5173";
        const resetLink = `${frontUrl}/restablecer-clave?token=${token}`;

        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.SMTP_USER,
                pass: process.env.SMTP_PASS
            }
        });

        await transporter.sendMail({
            from: `"ArteNauta Soporte" <${process.env.SMTP_USER}>`,
            to: email,
            subject: 'Restablecer contraseña - ArteNauta',
            html: `
                <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px;">
                    <h2 style="color: #0891b2; text-align: center;">Recuperación de Contraseña</h2>
                    <p>Hola <strong>${usuarioEncontrado.nombre}</strong>,</p>
                    <p>Has solicitado restablecer tu contraseña en ArteNauta.</p>
                    <p>Haz clic en el siguiente botón para crear una nueva contraseña. Este enlace es válido por 15 minutos:</p>
                    <div style="text-align: center; margin: 30px 0;">
                        <a href="${resetLink}" style="background-color: #0891b2; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;">Restablecer Contraseña</a>
                    </div>
                    <p style="font-size: 14px; color: #6b7280;">Si no solicitaste este cambio, puedes ignorar este correo sin problema.</p>
                    <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 20px 0;" />
                    <p style="font-size: 12px; color: #9ca3af; text-align: center;">El equipo de ArteNauta</p>
                </div>
            `
        });

        res.status(200).json({ mensaje: "Si el correo está registrado, recibirás un enlace de recuperación." });
    } catch (error) {
        console.error("Error en forgot-password:", error);
        res.status(500).json({ mensaje: "Error al procesar la solicitud de recuperación." });
    }
});

// POST Restablecer contraseña con el token
router.post("/auth/reset-password", async (req, res) => {
    const { token, newPassword } = req.body;

    try {
        const secretKey = process.env.JWT_SECRET || "mi_clave_super_secreta_desarrollo";
        
        let decodificado;
        try {
            decodificado = jwt.verify(token, secretKey);
        } catch (error) {
            return res.status(400).json({ mensaje: "El enlace es inválido o ha expirado. Por favor, solicita uno nuevo." });
        }

        const email = decodificado.email;

        // Encriptar la nueva clave
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

        // Actualizar el usuario en Supabase
        const { error } = await supabase
            .from("usuarios")
            .update({ clave: hashedPassword })
            .eq("email", email);

        if (error) throw error;

        res.status(200).json({ mensaje: "Tu contraseña ha sido actualizada correctamente." });
    } catch (error) {
        console.error("Error en reset-password:", error);
        res.status(500).json({ mensaje: "Error interno al actualizar la contraseña." });
    }
});

export default router;