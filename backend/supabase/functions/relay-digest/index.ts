import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

type RelayDigestRequest = {
  nodeId: string;
  since: string;
};

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRole) {
    return Response.json({ error: "Supabase service credentials are not configured" }, { status: 500 });
  }

  const body = (await req.json()) as RelayDigestRequest;
  const supabase = createClient(supabaseUrl, serviceRole, {
    auth: { persistSession: false },
  });

  const { data: diagnostics, error: diagnosticsError } = await supabase
    .from("diagnostics")
    .select("*")
    .eq("node_id", body.nodeId)
    .gte("recorded_at", body.since)
    .order("recorded_at", { ascending: false })
    .limit(100);

  if (diagnosticsError) {
    return Response.json({ error: diagnosticsError.message }, { status: 500 });
  }

  const { data: relays, error: relayError } = await supabase
    .from("relay_history")
    .select("*")
    .eq("relay_node_id", body.nodeId)
    .gte("relayed_at", body.since)
    .order("relayed_at", { ascending: false })
    .limit(100);

  if (relayError) {
    return Response.json({ error: relayError.message }, { status: 500 });
  }

  const avg = (items: number[]) =>
    items.length === 0 ? null : items.reduce((sum, item) => sum + item, 0) / items.length;

  return Response.json({
    nodeId: body.nodeId,
    diagnosticsCount: diagnostics.length,
    relayedPackets: relays.length,
    averageRssi: avg(diagnostics.map((item) => item.rssi).filter((item) => typeof item === "number")),
    averageSnr: avg(diagnostics.map((item) => item.snr).filter((item) => typeof item === "number")),
    queuePeak: diagnostics.reduce((peak, item) => Math.max(peak, item.queue_depth ?? 0), 0),
  });
});
