import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import bcrypt from "npm:bcryptjs"
import jwt from "npm:jsonwebtoken"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    const { email, password } = body;

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { data: usuarioEncontrado, error } = await supabase
      .from("usuarios")
      .select("*")
      .eq("email", email)
      .maybeSingle();

    if (error) throw error;

    if (!usuarioEncontrado) {
      return new Response(JSON.stringify({ mensaje: "Correo o contraseña incorrectos" }), { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const passwordValida = await bcrypt.compare(password, usuarioEncontrado.clave);

    if (!passwordValida) {
      return new Response(JSON.stringify({ mensaje: "Correo o contraseña incorrectos" }), { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    if (usuarioEncontrado.estado_cuenta === false) {
      return new Response(
        JSON.stringify({ mensaje: "Tu cuenta ha sido desactivada por un administrador. No puedes iniciar sesión." }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const payload = {
      id_usuario: usuarioEncontrado.id_usuario,
      id_rol: usuarioEncontrado.id_rol
    };

    const secretKey = Deno.env.get('JWT_SECRET') || "mi_clave_super_secreta_desarrollo";
    const token = jwt.sign(payload, secretKey, { expiresIn: "5h" });

    return new Response(
      JSON.stringify({
        mensaje: "Inicio de sesión exitoso",
        token: token,
        usuario: {
          id_usuario: usuarioEncontrado.id_usuario,
          nombre: usuarioEncontrado.nombre,
          email: usuarioEncontrado.email,
          id_rol: usuarioEncontrado.id_rol
        }
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error: any) {
    console.error("Error en el login:", error);
    return new Response(
      JSON.stringify({ mensaje: "Error interno del servidor", detalle: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})