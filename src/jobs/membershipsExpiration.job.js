import cron from 'node-cron';
import prisma from '../lib/prisma.js';
import { sendCommandToAgent } from '../lib/websocket.server.js';

export function startMembershipExpirationJob() {
  

cron.schedule('34 2 * * *', async () => {
  
  console.log('Ejecutando JOBBBB de expiración de membresías:', new Date());
  try {
    const now = new Date();

    await prisma.$transaction(async (tx) => {

      // 🔥 1. Obtener memberships a expirar
      const customerMembershipsToExpire = await tx.customerMembership.findMany({
        where: {
          status: 'ACTIVE',
          endDate: {
            lt: now,
          }//,
          //expiredCommandSent: false,
        },
        select: {
          id: true,
          customerId: true,
          companyId: true,
          branchId: true
        },
      });
      console.log('Memberships a expirar:', customerMembershipsToExpire.length);
      console.log(customerMembershipsToExpire);
      if (customerMembershipsToExpire.length === 0) {
        
        return;
      }

      // 🔥 2. Expirar MembershipSale
      const expiredSales = await tx.membershipSale.updateMany({
        where: {
          status: 'ACTIVE',
          endDate: {
            lt: now,
          },
        },
        data: {
          status: 'EXPIRED',
        },
      });
            console.log('Sales expiradas:', expiredSales);

      // 🔥 3. Expirar CustomerMembership
      const expiredCustomerMemberships = await tx.customerMembership.updateMany({
        where: {
          id: {
            in: customerMembershipsToExpire.map(m => m.id),
          },
        },
        data: {
          status: 'EXPIRED',
          //expiredCommandSent: true,
        },
      });
      console.log('CustomerMemberships expiradas:', expiredCustomerMemberships);
      // 🔥 4. Crear commands
      await tx.command.createMany({
        data: customerMembershipsToExpire.map(m => ({
          type: 'DELETE_USER',
          payload: {
            customerId: m.customerId,
          },
          companyId: m.companyId,
          branchId: m.branchId,
          status: 'PENDING',
        })),
      });

       const notify='SYNC';
    // Enviar notificacion al WebSocket para sincronizar la cara del cliente
    sendCommandToAgent(companyId, branchId, {
    type: 'SYNC'
  });

      
      
      
    });

  } catch (error) {
    
  }
}, {
  timezone: 'America/La_Paz',
});
}