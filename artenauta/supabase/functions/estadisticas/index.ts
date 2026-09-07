import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { verificarToken } from "../_shared/verificar_token.ts";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
    if (req.method === "OPTIONS")
        return new Response("ok", { headers: corsHeaders });

    try {
        const usuario = verificarToken(req) as any;
        if (usuario.id_rol !== 3) {
            throw new Error(
                "Acceso denegado: Se requieren permisos de administrador",
            );
        }

        const supabase = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
        );

        const [usersCount, artistsCount, postsCount, commentsCount] =
            await Promise.all([
                supabase
                    .from("usuarios")
                    .select("*", { count: "exact", head: true }),
                supabase
                    .from("usuarios")
                    .select("*", { count: "exact", head: true })
                    .eq("id_rol", 2),
                supabase
                    .from("publicaciones")
                    .select("*", { count: "exact", head: true }),
                supabase
                    .from("comentarios")
                    .select("*", { count: "exact", head: true }),
            ]);

        if (usersCount.error) throw usersCount.error;
        if (artistsCount.error) throw artistsCount.error;
        if (postsCount.error) throw postsCount.error;
        if (commentsCount.error) throw commentsCount.error;

        return new Response(
            JSON.stringify({
                totalUsuarios: usersCount.count || 0,
                totalArtistas: artistsCount.count || 0,
                totalPublicaciones: postsCount.count || 0,
                totalComentarios: commentsCount.count || 0,
            }),
            {
                status: 200,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    } catch (error: any) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
