import { WebSocketServer } from "ws";

const clients = new Map();

export function initWebSocket(server) {
  const wss = new WebSocketServer({ server });

  wss.on("connection", (ws) => {
    console.log("🔌 Agent conectado");

    ws.on("message", (message) => {
      try {
        const data = JSON.parse(message);

        if (data.type === "REGISTER") {
          const { agentKey, companyId, branchId } = data;

          clients.set(agentKey, {
            ws,
            companyId,
            branchId,
          });

          console.log(`✅ Agent registrado: ${agentKey}`);
        }
      } catch (err) {
        console.error("❌ WS error:", err);
      }
    });

    ws.on("close", () => {
      for (const [key, client] of clients.entries()) {
        if (client.ws === ws) {
          clients.delete(key);
        }
      }

      console.log("❌ Agent desconectado");
    });
  });
}

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