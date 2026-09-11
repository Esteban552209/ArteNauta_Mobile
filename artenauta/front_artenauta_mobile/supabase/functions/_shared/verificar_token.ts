import jwt from "npm:jsonwebtoken"

export const verificarToken = (req: Request) => {
  const authHeader = req.headers.get('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Acceso denegado: Token no proporcionado o formato inválido');
  }

  const token = authHeader.split(' ')[1];
  const secretKey = Deno.env.get('JWT_SECRET') || "mi_clave_super_secreta_desarrollo";

  try {
    const decoded = jwt.verify(token, secretKey);
    return decoded;
  } catch (error) {
    throw new Error('Acceso denegado: Token expirado o inválido');
  }
};