import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { verificarToken } from "../_shared/verificar_token.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, OPTIONS',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const usuarioAuth = verificarToken(req) as any;
    if (usuarioAuth.id_rol !== 3) throw new Error('Acceso denegado: Se requieren permisos de administrador');

    const supabase = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '')

    // MÉTODO GET: OBTENER CATEGORÍAS
    if (req.method === 'GET') {
      const url = new URL(req.url);
      const buscar = url.searchParams.get("buscar");

      let consulta = supabase
        .from("categorias")
        .select("*")
        .order("nombre_categoria", { ascending: true });

      if (buscar && buscar.trim() !== "") {
        consulta = consulta.ilike("nombre_categoria", `%${buscar}%`);
      }

      const { data, error } = await consulta;
      if (error) throw error;
      return new Response(JSON.stringify(data), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // MÉTODO POST: CREAR CATEGORÍA
    if (req.method === 'POST') {
      const body = await req.json();
      const { nombre_categoria, descripcion } = body;

      if (!nombre_categoria || !descripcion) {
        throw new Error("Faltan campos obligatorios");
      }

      const { data, error } = await supabase
        .from("categorias")
        .insert([{ nombre_categoria, descripcion }])
        .select("*");

      if (error) throw error;
      return new Response(JSON.stringify(data[0]), { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // MÉTODO PATCH: ACTUALIZAR CATEGORÍA
    if (req.method === 'PATCH') {
      const body = await req.json();
      const { id_categoria, nombre_categoria, descripcion } = body;

      const { data, error } = await supabase
        .from("categorias")
        .update({ nombre_categoria, descripcion })
        .eq("id_categoria", id_categoria)
        .select();

      if (error) throw error;
      if (data.length === 0) throw new Error("Categoría no encontrada");

      return new Response(JSON.stringify(data[0]), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    throw new Error('Método no soportado');

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }
})
