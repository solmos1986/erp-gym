ALTER TABLE "Agent"
ADD COLUMN IF NOT EXISTS "publicIp" TEXT;

CREATE INDEX IF NOT EXISTS "Agent_publicIp_idx"
ON "Agent"("publicIp");