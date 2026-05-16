import express from "express";

import {
  getDashboardSummary,
  getSalesLast7Days
} from "./dashboard.controller.js";

import { requireAuth } from "../../middlewares/auth.middleware.js";
import { requirePermission } from "../../middlewares/permission.middleware.js";
import { tenantGuard } from "../../middlewares/tenant.middleware.js";

const router = express.Router();

//////////////////////////////////////
// 🔒 BASE
//////////////////////////////////////
router.use(requireAuth);
router.use(tenantGuard);

//////////////////////////////////////
// 📊 DASHBOARD
//////////////////////////////////////

router.get(
  "/summary",
  requirePermission("TENANT_DASHBOARD_VIEW"),
  getDashboardSummary
);

router.get(
  "/sales-last-7-days",
  requirePermission("TENANT_DASHBOARD_VIEW"),
  getSalesLast7Days
);

export default router;