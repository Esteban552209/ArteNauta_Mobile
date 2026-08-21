import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {

  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    })
  }

  try {

    const body = await req.json()

    if (
      !body?.nombre ||
      !body?.telefono ||
      !body?.email ||
      !body?.clave
    ) {
      return new Response(
        JSON.stringify({
          error: 'Todos los campos son requeridos.'
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

    const supabaseUrl =
      Deno.env.get('SUPABASE_URL') ?? ''

    const supabaseServiceRoleKey =
      Deno.env.get(
        'SUPABASE_SERVICE_ROLE_KEY'
      ) ?? ''

    const supabase = createClient(
      supabaseUrl,
      supabaseServiceRoleKey
    )

    const { data: usuarioExistente, error: errorBusqueda } =
      await supabase
        .from('usuarios')
        .select('email')
        .eq('email', body.email)
        .maybeSingle()

    if (errorBusqueda) {

      console.error(
        'Error buscando usuario:',
        errorBusqueda
      )

      return new Response(
        JSON.stringify({
          error: 'Error consultando la base de datos.'
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

    if (usuarioExistente) {

      return new Response(
        JSON.stringify({
          error:
            'Ya existe una cuenta registrada con este correo.'
        }),
        {
          status: 409,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          }
        }
      )
    }
  // INSERTAR USUARIO

    const { data, error } = await supabase
      .from('usuarios')
      .insert({
        nombre: body.nombre,
        apellido: body.apellido,
        telefono: body.telefono,
        email: body.email,
        clave: body.clave,
      })
      .select()
      .single()

    if (error) {

      console.error(
        'Error insertando usuario:',
        error
      )

      return new Response(
        JSON.stringify({
          error: 'No fue posible registrar el usuario.'
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

    return new Response(
      JSON.stringify({
        message: 'Usuario registrado correctamente.',
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

  } catch (error) {

    console.error(
      'Error interno:',
      error
    )

    return new Response(
      JSON.stringify({
        error:
          'Error interno en la Edge Function.'
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