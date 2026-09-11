import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import bcrypt from "npm:bcryptjs"

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
    const { nombre, apellido, telefono, email, clave, id_rol } = body;

    if (!email || !clave) {
      return new Response(JSON.stringify({ error: 'Email y clave son obligatorios' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }})
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(clave, saltRounds);

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

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