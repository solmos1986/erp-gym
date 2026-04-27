import { WebSocketServer } from "ws";

const clients = new Map();   // 🤖 agents
const frontends = new Set(); // 🖥️ frontends

export function initWebSocket(server) {
  const wss = new WebSocketServer({ server });

  wss.on("connection", (ws) => {
    console.log("🔌 Nueva conexión WS");

    ws.on("message", (message) => {
      try {
        const data = JSON.parse(message);

        // ==========================
        // 🤖 AGENT (lo tuyo, intacto)
        // ==========================
        if (data.type === "REGISTER") {
          const { agentKey, companyId, branchId } = data;

          ws.clientType = "AGENT";
          ws.agentKey = agentKey;

          clients.set(agentKey, {
            ws,
            companyId,
            branchId,
          });

          console.log(`✅ Agent registrado: ${agentKey}`);
        }

        // ==========================
        // 🖥️ FRONTEND (nuevo)
        // ==========================
        if (data.type === "REGISTER_FRONTEND") {
          ws.clientType = "FRONTEND";
          frontends.add(ws);

          console.log("🖥️ Frontend conectado");
        }

      } catch (err) {
        console.error("❌ WS error:", err);
      }
    });

    ws.on("close", () => {
      // limpiar agents
      for (const [key, client] of clients.entries()) {
        if (client.ws === ws) {
          clients.delete(key);
          console.log(`❌ Agent desconectado: ${key}`);
        }
      }

      // limpiar frontends
      if (frontends.has(ws)) {
        frontends.delete(ws);
        console.log("❌ Frontend desconectado");
      }
    });
  });
}

// ==========================
// 🤖 AGENT (lo tuyo intacto)
// ==========================
export function sendCommandToAgent({ companyId, branchId, payload }) {
  for (const client of clients.values()) {
    if (
      client.companyId === companyId &&
      client.branchId === branchId
    ) {
      client.ws.send(
        JSON.stringify({
          type: "SYNC"
        })
      );
    }
  }
}

// ==========================
// 🖥️ FRONTEND (nuevo)
// ==========================
export function notifyFrontend(event) {
  for (const ws of frontends) {
    ws.send(JSON.stringify(event));
  }
}