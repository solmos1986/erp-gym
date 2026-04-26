import { WebSocketServer } from 'ws';

let clients = [];

// 🚀 crear servidor WS
const wss = new WebSocketServer({ port: 8081 });

wss.on('connection', (ws, req) => {
  try {
    // 🔥 FIX REAL: parse correcto de query params
    const url = new URL(req.url, 'http://localhost');
    const companyId = url.searchParams.get('companyId');
    const branchId = url.searchParams.get('branchId');

    if (!companyId || !branchId) {
      console.warn("❌ Conexión rechazada: falta companyId o branchId");
      ws.close();
      return;
    }

    const key = `${companyId}:${branchId}`;

    console.log("📡 Nuevo cliente WS:", key);

    // 🔥 evitar duplicados (muy importante en reconexiones)
    clients = clients.filter(c => c.key !== key);

    clients.push({ key, ws });

    console.log("👥 Clientes conectados:", clients.map(c => c.key));

    // 🔥 mensaje welcome
    ws.send(JSON.stringify({
      message: "WS conectado correctamente"
    }));

    // ==========================
    // MESSAGE (opcional)
    // ==========================
    ws.on('message', (msg) => {
      try {
        const data = JSON.parse(msg.toString());
        console.log("📩 Mensaje desde agent:", key, data);
      } catch (e) {
        console.warn("⚠️ Mensaje inválido desde agent");
      }
    });

    // ==========================
    // CLOSE
    // ==========================
    ws.on('close', () => {
      console.log("🔌 Cliente desconectado:", key);

      clients = clients.filter(c => c.ws !== ws);

      console.log("👥 Clientes restantes:", clients.map(c => c.key));
    });

    // ==========================
    // ERROR
    // ==========================
    ws.on('error', (err) => {
      console.error("❌ WS error:", err.message);
    });

  } catch (err) {
    console.error("❌ Error en conexión WS:", err.message);
  }
});

// ==========================
// 🚀 ENVIAR COMANDO
// ==========================
function sendCommandToAgent(companyId, branchId, command) {
  const key = `${companyId}:${branchId}`;

  console.log("📤 Enviando comando:", command);
  console.log("🎯 Target:", key);
  console.log("👥 Clientes disponibles:", clients.map(c => c.key));

  // 🔥 soportar múltiples conexiones por seguridad
  const targets = clients.filter(c => c.key === key);

  if (!targets.length) {
    console.warn("❌ No hay agent conectado para:", key);
    return;
  }

  targets.forEach(client => {
    if (client.ws.readyState === 1) {
      client.ws.send(JSON.stringify(command));
      console.log("✅ Comando enviado a:", key);
    } else {
      console.warn("⚠️ WS no abierto para:", key);
    }
  });
}

export { sendCommandToAgent };