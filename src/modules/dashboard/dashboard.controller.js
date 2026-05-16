import * as dashboardService from "./dashboard.service.js";

//////////////////////////////////////
// 📋 SUMMARY
//////////////////////////////////////
export const getDashboardSummary = async (
  req,
  res
) => {
  try {
    const data =
      await dashboardService.getDashboardSummary({
        companyId: req.user.companyId,
        branchId: req.user.branchId
      });

    res.json(data);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      message:
        "Error obteniendo dashboard"
    });
  }
};

//////////////////////////////////////
// 📈 SALES LAST 7 DAYS
//////////////////////////////////////
export const getSalesLast7Days = async (
  req,
  res
) => {
  try {

    const data =
      await dashboardService.getSalesLast7Days({
        companyId: req.user.companyId,
        branchId: req.user.branchId
      });

    res.json(data);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      message:
        "Error obteniendo gráfico"
    });
  }
};