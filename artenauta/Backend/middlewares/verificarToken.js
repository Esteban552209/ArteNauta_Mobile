import jwt from "jsonwebtoken";

export const verificarToken = (req, res, next) => {
    const authHeader = req.headers["authorization"];
    
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
        return res.status(401).json({ mensaje: "Acceso denegado. No hay token." });
    }

    try {
        const secretKey = process.env.JWT_SECRET || "mi_clave_super_secreta_desarrollo";
        const usuarioDecodificado = jwt.verify(token, secretKey);

        req.usuario = usuarioDecodificado;
        
        next();
    } catch (error) {
        return res.status(401).json({ mensaje: "Token inválido o expirado." });
    }
};