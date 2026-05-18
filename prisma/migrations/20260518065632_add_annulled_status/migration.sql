/*
  Warnings:

  - The values [CANCELLED,SUSPENDED] on the enum `MembershipStatus` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "MembershipStatus_new" AS ENUM ('ACTIVE', 'EXPIRED', 'ANULLED');
ALTER TABLE "CustomerMembership" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "MembershipSale" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "MembershipSale" ALTER COLUMN "status" TYPE "MembershipStatus_new" USING ("status"::text::"MembershipStatus_new");
ALTER TABLE "CustomerMembership" ALTER COLUMN "status" TYPE "MembershipStatus_new" USING ("status"::text::"MembershipStatus_new");
ALTER TYPE "MembershipStatus" RENAME TO "MembershipStatus_old";
ALTER TYPE "MembershipStatus_new" RENAME TO "MembershipStatus";
DROP TYPE "MembershipStatus_old";
ALTER TABLE "CustomerMembership" ALTER COLUMN "status" SET DEFAULT 'ACTIVE';
ALTER TABLE "MembershipSale" ALTER COLUMN "status" SET DEFAULT 'ACTIVE';
COMMIT;
