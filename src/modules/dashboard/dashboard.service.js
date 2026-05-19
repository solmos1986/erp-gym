import prisma from "../../lib/prisma.js";

//////////////////////////////////////
// 📋 SUMMARY
//////////////////////////////////////
export const getDashboardSummary = async ({
  companyId,
  branchId
}) => {
//////////////////////////////////////
// 🇧🇴 BOLIVIA UTC OFFSET (-4)
//////////////////////////////////////

const now = new Date();

const boliviaOffsetMs =
  4 * 60 * 60 * 1000;

const boliviaNow =
  new Date(
    now.getTime() -
    boliviaOffsetMs
  );

const today = boliviaNow;

//////////////////////////////////////
// START DAY BOLIVIA
//////////////////////////////////////

const startOfDay =
  new Date(today);

startOfDay.setUTCHours(
  4,
  0,
  0,
  0
);

//////////////////////////////////////
// END DAY BOLIVIA
//////////////////////////////////////

const endOfDay =
  new Date(today);

endOfDay.setUTCHours(
  27,
  59,
  59,
  999
);

console.log({
  startOfDay,
  endOfDay
});


  //////////////////////////////////////
  // 📅 START WEEK
  //////////////////////////////////////
  const startOfWeek = new Date(today);

  const day = startOfWeek.getDay();

  const diff =
    startOfWeek.getDate() -
    day +
    (day === 0 ? -6 : 1);

  startOfWeek.setDate(diff);

  startOfWeek.setHours(0, 0, 0, 0);

  //////////////////////////////////////
  // 📅 START MONTH
  //////////////////////////////////////
  const startOfMonth = new Date(
    today.getFullYear(),
    today.getMonth(),
    1
  );

  //////////////////////////////////////
  // 💰 REVENUE TODAY
  //////////////////////////////////////
  const revenueToday =
    await prisma.membershipSale.aggregate({
      _sum: {
        price: true
      },
      where: {
        companyId,
        branchId,
        saleDate: {
          gte: startOfDay,
          lte: endOfDay
        }
      }
    });

  //////////////////////////////////////
  // 💰 REVENUE WEEK
  //////////////////////////////////////
  const weekRevenue =
    await prisma.membershipSale.aggregate({
      _sum: {
        price: true
      },
      where: {
        companyId,
        branchId,
        saleDate: {
          gte: startOfWeek
        }
      }
    });

  //////////////////////////////////////
  // 💰 REVENUE MONTH
  //////////////////////////////////////
  const monthRevenue =
    await prisma.membershipSale.aggregate({
      _sum: {
        price: true
      },
      where: {
        companyId,
        branchId,
        saleDate: {
          gte: startOfMonth
        }
      }
    });

  //////////////////////////////////////
  // 👥 ACTIVE CUSTOMERS
  //////////////////////////////////////
  const activeCustomers =
    await prisma.customerMembership.count({
      where: {
        companyId,
        branchId,
        status: "ACTIVE",
        startDate: {
          lte: today
        },
        endDate: {
          gte: today
        }
      }
    });

  //////////////////////////////////////
  // ⚠️ EXPIRING SOON
  //////////////////////////////////////
  const next3Days = new Date(today);

  next3Days.setDate(
    next3Days.getDate() + 3
  );

  const membershipsExpiringSoon =
    await prisma.customerMembership.count({
      where: {
        companyId,
        branchId,
        status: "ACTIVE",
        endDate: {
          gte: today,
          lte: next3Days
        }
      }
    });

  //////////////////////////////////////
  // 📅 TODAY REGISTRATIONS
  //////////////////////////////////////
  const todayRegistrations =
    await prisma.membershipSale.count({
      where: {
        companyId,
        branchId,
        saleDate: {
          gte: startOfDay,
          lte: endOfDay
        }
      }
    });

  //////////////////////////////////////
  // 📅 WEEK REGISTRATIONS
  //////////////////////////////////////
  const weekRegistrations =
    await prisma.membershipSale.count({
      where: {
        companyId,
        branchId,
        saleDate: {
          gte: startOfWeek
        }
      }
    });

  //////////////////////////////////////
  // 📅 MONTH REGISTRATIONS
  //////////////////////////////////////
  const monthRegistrations =
    await prisma.membershipSale.count({
      where: {
        companyId,
        branchId,
        saleDate: {
          gte: startOfMonth
        }
      }
    });

  //////////////////////////////////////
  // 📤 RESPONSE
  //////////////////////////////////////
  return {
    //////////////////////////////////////
    // 💰 REVENUE
    //////////////////////////////////////
    todayRevenue:
      Number(revenueToday._sum.price || 0),

    weekRevenue:
      Number(weekRevenue._sum.price || 0),

    monthRevenue:
      Number(monthRevenue._sum.price || 0),

    //////////////////////////////////////
    // 👥 CUSTOMERS
    //////////////////////////////////////
    activeCustomers,

    membershipsExpiringSoon,

    //////////////////////////////////////
    // 📅 REGISTRATIONS
    //////////////////////////////////////
    todayRegistrations,

    weekRegistrations,

    monthRegistrations
  };
};

//////////////////////////////////////
// 📈 SALES LAST 7 DAYS
//////////////////////////////////////
export const getSalesLast7Days = async ({
  companyId,
  branchId
}) => {

  //////////////////////////////////////
  // 📅 START DATE
  //////////////////////////////////////
  const startDate = new Date();

  startDate.setDate(
    startDate.getDate() - 6
  );

  startDate.setHours(0, 0, 0, 0);

  //////////////////////////////////////
  // 📋 MEMBERSHIP SALES
  //////////////////////////////////////
  const sales =
    await prisma.membershipSale.findMany({
      where: {
        companyId,
        branchId,
        saleDate: {
          gte: startDate
        }
      },
      select: {
        saleDate: true,
        price: true
      },
      orderBy: {
        saleDate: "asc"
      }
    });

  //////////////////////////////////////
  // 📊 GROUP BY DAY
  //////////////////////////////////////
  const grouped = {};

  for (const sale of sales) {

    const date = sale.saleDate
      .toISOString()
      .split("T")[0];

    if (!grouped[date]) {
      grouped[date] = 0;
    }

    grouped[date] += Number(sale.price);
  }

  //////////////////////////////////////
  // 📈 RETURN ARRAY
  //////////////////////////////////////
  return Object.entries(grouped).map(
    ([date, total]) => ({
      date,
      total
    })
  );
};