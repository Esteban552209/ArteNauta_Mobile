import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {

  // CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    })
  }

  try {

    // Leer información enviada desde Flutter
    const body = await req.json()

    if (!body?.email || !body?.clave) {
      return new Response(
        JSON.stringify({
          error: 'Email y contraseña son requeridos.'
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Variables de entorno de Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceRoleKey =
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

    // Cliente de Supabase con permisos administrativos
    const supabase = createClient(
      supabaseUrl,
      supabaseServiceRoleKey
    )

    // Buscar usuario en nuestra tabla "usuarios"
    const { data, error } = await supabase
      .from('usuarios')
      .select('*')
      .eq('email', body.email)
      .maybeSingle()

    // Error de consulta
    if (error) {

      console.error('Error consultando usuario:', error)

      return new Response(
        JSON.stringify({
          error: 'Error consultando el usuario.'
        }),
        {
          status: 500,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Usuario no encontrado
    if (!data) {

      return new Response(
        JSON.stringify({
          error: 'Credenciales incorrectas.'
        }),
        {
          status: 401,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Comprobar contraseña
    if (data.clave !== body.clave) {

      return new Response(
        JSON.stringify({
          error: 'Credenciales incorrectas.'
        }),
        {
          status: 401,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }

    // Login exitoso
    return new Response(
      JSON.stringify({
        message: 'Autenticación exitosa',
        user: data
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      }
    )

  } catch (err) {

    console.error('Error interno:', err)

    return new Response(
      JSON.stringify({
        error: 'Error interno en la Edge Function'
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      }
    )
  }
})