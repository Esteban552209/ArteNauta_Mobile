import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import bcrypt from "npm:bcryptjs"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const REGEX_LETRAS = /^[a-zA-Za-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/;
const REGEX_TELEFONO = /^[0-9]{7,15}$/;
const REGEX_EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const REGEX_PASSWORD = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._\-#])[A-Za-z\d@$!%*?&._\-#]{8,}$/;

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    const { nombre, apellido, telefono, email, clave, id_rol } = body;

    // 1. Validar campos obligatorios
    if (!nombre || !apellido || !telefono || !email || !clave) {
      return new Response(
        JSON.stringify({ error: 'Todos los campos son obligatorios' }), 
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. Validar Nombres y Apellidos (Solo letras)
    if (!REGEX_LETRAS.test(nombre.trim())) {
      return new Response(
        JSON.stringify({ error: 'El nombre solo debe contener letras' }), 
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!REGEX_LETRAS.test(apellido.trim())) {
      return new Response(
        JSON.stringify({ error: 'El apellido solo debe contener letras' }), 
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 3. Validar Teléfono (Solo números)
    if (!REGEX_TELEFONO.test(telefono.trim())) {
      return new Response(
        JSON.stringify({ error: 'El teléfono debe contener entre 7 y 15 dígitos numéricos' }), 
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. Validar Email
    if (!REGEX_EMAIL.test(email.trim())) {
      return new Response(
        JSON.stringify({ error: 'El formato del correo electrónico no es válido' }), 
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 5. Validar Contraseña Segura
    if (!REGEX_PASSWORD.test(clave)) {
      return new Response(
        JSON.stringify({ 
          error: 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial (@$!%*?&._-#)' 
        }), 
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Hash de la contraseña
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(clave, saltRounds);

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Insertar usuario
    const { data, error } = await supabase
      .from('usuarios')
      .insert([
        {
          nombre: nombre.trim(),
          apellido: apellido.trim(),
          telefono: telefono.trim(),
          email: email.trim().toLowerCase(),
          clave: hashedPassword,
          id_rol: id_rol || 1
        }
      ]);

    if (error) throw error;

    return new Response(
      JSON.stringify({ mensaje: 'Usuario registrado exitosamente' }),
      { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error("Error en el registro:", error);
    return new Response(
      JSON.stringify({ error: error.message || 'Hubo un error al registrar el usuario' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})