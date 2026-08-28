import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { verificarToken } from "../_shared/verificar_token.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, PATCH, OPTIONS',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const usuarioAuth = verificarToken(req) as any;
    if (usuarioAuth.id_rol !== 3) throw new Error('Acceso denegado: Se requieren permisos de administrador');

    const supabase = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '')
    // MÉTODO GET: OBTENER USUARIOS CON FILTROS
    if (req.method === 'GET') {
      const url = new URL(req.url);
      const estado = url.searchParams.get("estado");
      const buscar = url.searchParams.get("buscar");
      const rol = url.searchParams.get("rol");

      let consulta = supabase
        .from("usuarios")
        .select(`id_usuario, nombre, apellido, email, estado_cuenta, id_rol, roles!id_rol (id_rol, nombre_rol), fecha_registro`)
        .order('id_usuario', { ascending: true });

      if (estado === "true") consulta = consulta.eq("estado_cuenta", true);
      else if (estado === "false") consulta = consulta.eq("estado_cuenta", false);

      if (buscar && buscar.trim() !== "") {
        consulta = consulta.or(`nombre.ilike.%${buscar}%,apellido.ilike.%${buscar}%,email.ilike.%${buscar}%`);
      }

      if (rol && rol.trim() !== "") {
        consulta = consulta.eq("id_rol", rol);
      }

      const { data, error } = await consulta;
      if (error) throw error;
      return new Response(JSON.stringify(data), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    // MÉTODO PATCH: ACTUALIZAR USUARIO
    if (req.method === 'PATCH') {
      const body = await req.json();
      const { id_usuario, nombre, apellido, estado_cuenta, id_rol } = body;

      const { data, error } = await supabase
        .from("usuarios")
        .update({ 
          nombre, 
          apellido, 
          estado_cuenta, 
          id_rol: parseInt(id_rol)
        })
        .eq("id_usuario", id_usuario)
        .select(`id_usuario, nombre, apellido, email, estado_cuenta, id_rol, roles!id_rol (nombre_rol), fecha_registro`);

      if (error) throw error;
      return new Response(JSON.stringify(data[0]), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    throw new Error('Método no soportado');

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }
})