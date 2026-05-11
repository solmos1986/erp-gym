--
-- PostgreSQL database dump
--

\restrict e3blCThOp8Gi79GVbUs0vHKVQmKbqc9eNgWIWzlHEoRsSxz9Zd7pGjFVoJTeCqV

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg13+1)
-- Dumped by pg_dump version 15.17 (Debian 15.17-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: erp_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO erp_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: erp_user
--

COMMENT ON SCHEMA public IS '';


--
-- Name: CommandStatus; Type: TYPE; Schema: public; Owner: erp_user
--

CREATE TYPE public."CommandStatus" AS ENUM (
    'PENDING',
    'PROCESSING',
    'DONE',
    'ERROR'
);


ALTER TYPE public."CommandStatus" OWNER TO erp_user;

--
-- Name: CommandType; Type: TYPE; Schema: public; Owner: erp_user
--

CREATE TYPE public."CommandType" AS ENUM (
    'SYNC_MEMBERSHIP',
    'DELETE_USER',
    'SYNC_FACE',
    'SYNC_USER_FULL'
);


ALTER TYPE public."CommandType" OWNER TO erp_user;

--
-- Name: DeviceStatus; Type: TYPE; Schema: public; Owner: erp_user
--

CREATE TYPE public."DeviceStatus" AS ENUM (
    'CONNECTED',
    'DISCONNECTED'
);


ALTER TYPE public."DeviceStatus" OWNER TO erp_user;

--
-- Name: DeviceType; Type: TYPE; Schema: public; Owner: erp_user
--

CREATE TYPE public."DeviceType" AS ENUM (
    'ACCESS_CONTROL',
    'CAMERA',
    'BIOMETRIC'
);


ALTER TYPE public."DeviceType" OWNER TO erp_user;

--
-- Name: MembershipStatus; Type: TYPE; Schema: public; Owner: erp_user
--

CREATE TYPE public."MembershipStatus" AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'CANCELLED',
    'SUSPENDED'
);


ALTER TYPE public."MembershipStatus" OWNER TO erp_user;

--
-- Name: PartnerType; Type: TYPE; Schema: public; Owner: erp_user
--

CREATE TYPE public."PartnerType" AS ENUM (
    'CUSTOMER',
    'SUPPLIER'
);


ALTER TYPE public."PartnerType" OWNER TO erp_user;

--
-- Name: RoleScope; Type: TYPE; Schema: public; Owner: erp_user
--

CREATE TYPE public."RoleScope" AS ENUM (
    'SYSTEM',
    'TENANT'
);


ALTER TYPE public."RoleScope" OWNER TO erp_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Agent; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Agent" (
    id text NOT NULL,
    name text NOT NULL,
    "agentKey" text NOT NULL,
    "companyId" text NOT NULL,
    "branchId" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "lastSeenAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Agent" OWNER TO erp_user;

--
-- Name: Branch; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Branch" (
    id text NOT NULL,
    name text NOT NULL,
    "companyId" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Branch" OWNER TO erp_user;

--
-- Name: Command; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Command" (
    id text NOT NULL,
    payload jsonb NOT NULL,
    "companyId" text NOT NULL,
    "branchId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "executedAt" timestamp(3) without time zone,
    error text,
    attempts integer DEFAULT 0 NOT NULL,
    type public."CommandType" NOT NULL,
    status public."CommandStatus" DEFAULT 'PENDING'::public."CommandStatus" NOT NULL,
    "membershipSaleId" text
);


ALTER TABLE public."Command" OWNER TO erp_user;

--
-- Name: Company; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Company" (
    id text NOT NULL,
    name text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "logoUrl" text
);


ALTER TABLE public."Company" OWNER TO erp_user;

--
-- Name: CompanyPermission; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."CompanyPermission" (
    id text NOT NULL,
    "companyId" text NOT NULL,
    "permissionId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."CompanyPermission" OWNER TO erp_user;

--
-- Name: CustomerMembership; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."CustomerMembership" (
    id text NOT NULL,
    "customerId" text NOT NULL,
    "companyId" text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone NOT NULL,
    status public."MembershipStatus" DEFAULT 'ACTIVE'::public."MembershipStatus" NOT NULL,
    "hikvisionUserId" text,
    "deletedFromDevice" boolean DEFAULT false NOT NULL,
    "lastSyncAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text NOT NULL
);


ALTER TABLE public."CustomerMembership" OWNER TO erp_user;

--
-- Name: Device; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Device" (
    id text NOT NULL,
    name text NOT NULL,
    ip text NOT NULL,
    port integer,
    username text,
    password text,
    "deviceType" public."DeviceType" NOT NULL,
    brand text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "companyId" text NOT NULL,
    "branchId" text NOT NULL,
    "agentId" text,
    "lastSeenAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "lastConnectionAt" timestamp(3) without time zone,
    status public."DeviceStatus" DEFAULT 'DISCONNECTED'::public."DeviceStatus" NOT NULL
);


ALTER TABLE public."Device" OWNER TO erp_user;

--
-- Name: MembershipSale; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."MembershipSale" (
    id text NOT NULL,
    "partnerId" text NOT NULL,
    "planId" text NOT NULL,
    "companyId" text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone NOT NULL,
    status public."MembershipStatus" DEFAULT 'ACTIVE'::public."MembershipStatus" NOT NULL,
    price numeric(10,2) NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "saleDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text,
    "branchId" text
);


ALTER TABLE public."MembershipSale" OWNER TO erp_user;

--
-- Name: Partner; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Partner" (
    id text NOT NULL,
    "companyId" text NOT NULL,
    type public."PartnerType" NOT NULL,
    name text NOT NULL,
    document text,
    phone text,
    email text,
    address text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "imageUrl" text
);


ALTER TABLE public."Partner" OWNER TO erp_user;

--
-- Name: Permission; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Permission" (
    id text NOT NULL,
    code text NOT NULL,
    description text,
    scope public."RoleScope" NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


ALTER TABLE public."Permission" OWNER TO erp_user;

--
-- Name: Plan; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Plan" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    price numeric(65,30) NOT NULL,
    "durationDays" integer NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "companyId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Plan" OWNER TO erp_user;

--
-- Name: Role; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."Role" (
    id text NOT NULL,
    name text NOT NULL,
    scope public."RoleScope" NOT NULL,
    "companyId" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Role" OWNER TO erp_user;

--
-- Name: RolePermission; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."RolePermission" (
    id text NOT NULL,
    "roleId" text NOT NULL,
    "permissionId" text NOT NULL
);


ALTER TABLE public."RolePermission" OWNER TO erp_user;

--
-- Name: User; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    "fullName" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "companyId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "branchId" text NOT NULL,
    "isOwner" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."User" OWNER TO erp_user;

--
-- Name: UserRole; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public."UserRole" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "roleId" text NOT NULL,
    "companyId" text
);


ALTER TABLE public."UserRole" OWNER TO erp_user;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: erp_user
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO erp_user;

--
-- Data for Name: Agent; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Agent" (id, name, "agentKey", "companyId", "branchId", "isActive", "lastSeenAt", "createdAt", "updatedAt") FROM stdin;
d317bbef-1917-4fdd-9902-f893c5783b0b	Agent - Principal	ba207eef666d8073f67c8b20c7d6ddf1811471303aceebe9e1c0b8a8708ebfa2	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	t	2026-05-08 01:17:46.416	2026-05-07 22:35:11.357	2026-05-08 01:17:46.418
5ac2f379-3b46-48a5-a183-8145e58c5493	Agent - Principal	e1517fe357446954ee62c8b2a2d21458c6ec3462551e1e135886a6668b6029e2	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	t	2026-05-06 07:46:27.407	2026-05-05 14:46:06.517	2026-05-06 07:46:27.409
\.


--
-- Data for Name: Branch; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Branch" (id, name, "companyId", "isActive", "createdAt") FROM stdin;
1b9b384c-0715-4247-b718-6738efe86c89	MAIN	6b293f8f-beec-4a45-9b22-98ceabe0f3a1	t	2026-05-05 14:44:21.69
0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	Principal	6b828940-7fc0-449f-8a26-f91d237a0940	t	2026-05-05 14:46:06.51
aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	Principal	ba873a42-909b-47cf-8bd7-15caaf87fd46	t	2026-05-07 22:35:11.345
\.


--
-- Data for Name: Command; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Command" (id, payload, "companyId", "branchId", "createdAt", "executedAt", error, attempts, type, status, "membershipSaleId") FROM stdin;
e34e3a95-e84d-4036-8662-c7caff31c623	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-06-04T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 14:50:18.378	2026-05-05 14:50:22.307	\N	0	SYNC_USER_FULL	DONE	73a62efe-17a5-492a-b144-82ee9f8be015
054127a9-8a38-4ad1-80e7-c5b133ff640a	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-07-04T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 15:00:09.848	2026-05-05 15:00:13.941	\N	0	SYNC_USER_FULL	DONE	d57ea833-34cb-4fa6-a3e2-13e9f937f4cd
a9b48400-d62e-41a0-a8dd-90cd506fa1bf	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-08-03T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 15:00:34.5	2026-05-05 15:00:38.411	\N	0	SYNC_USER_FULL	DONE	d2711a8f-6315-4ad9-8139-d81ab42f02fa
7c23d36b-be4e-4dbb-a865-72a42a1986cb	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-09-02T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 19:56:00.752	2026-05-05 19:56:04.715	\N	0	SYNC_USER_FULL	DONE	12a92ee9-3ad3-4e3a-bd07-bfe8668b5a9a
1909f6e3-e0ad-4c4d-a209-78e64dc95176	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-10-02T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 20:07:25.417	2026-05-05 20:07:28.654	\N	0	SYNC_USER_FULL	DONE	0acf7397-2155-42fb-9792-c850ff111703
768b436b-1724-4871-b760-18dc5fc4ed26	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-11-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 20:28:36.046	2026-05-05 20:28:39.663	\N	0	SYNC_USER_FULL	DONE	dc1b339a-eb2a-4b99-a94c-344b8ad5a545
70610dae-47b6-46ad-8e6b-36b6308abd2e	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 20:31:28.694	2026-05-05 20:31:32.555	\N	0	SYNC_USER_FULL	DONE	c74a9f27-e6c3-44f5-8672-19bcbb7dae5c
4267fbc2-442a-4645-8144-fa5028fe22a2	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:12:46.468	2026-05-05 22:13:14.349	\N	0	SYNC_USER_FULL	DONE	\N
85c397a5-893a-48a4-97ce-631191b7ba34	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:13:00.593	2026-05-05 22:13:16.776	\N	0	SYNC_USER_FULL	DONE	\N
8bdb13f6-ab82-4741-8d02-f4368c81426d	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:19:31.766	2026-05-05 22:20:13.701	\N	0	SYNC_USER_FULL	DONE	\N
06821db8-3d59-4bb9-aa8e-8f84fd03fe13	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:21:40.518	2026-05-05 22:22:14.244	\N	0	SYNC_USER_FULL	DONE	\N
3f273ed1-02f3-445d-8008-12498ba1243d	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:24:39.706	2026-05-05 22:24:44.065	\N	0	SYNC_USER_FULL	DONE	\N
d91a6e86-b372-46c5-9157-463ae1068c66	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-05-23T04:00:00.000Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 05:48:40.136	2026-05-06 05:49:46.212	\N	0	SYNC_USER_FULL	DONE	\N
c7fabcf8-159e-4c22-b4e5-9a0be8df03d9	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:03:23.445	2026-05-06 06:03:26.966	\N	0	SYNC_USER_FULL	DONE	\N
1b7e6c8b-102a-4aae-a749-8337a1030a28	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:05:06.942	2026-05-06 06:05:10.372	\N	0	SYNC_USER_FULL	DONE	4a4fbb23-9cd4-4899-a37e-39beba6ab5c2
9b67345e-e82d-4942-a16a-2a07e06e4a75	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-07-27T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:22:52.849	2026-05-06 06:22:56.48	\N	0	SYNC_USER_FULL	DONE	98bdb0f0-aa0e-4df2-81d5-ed5f6cb0719b
ea289833-f3ff-4fb4-88d1-3a1f4fb66153	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-11-06T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:57:08.768	2026-05-07 23:57:12.86	\N	0	SYNC_USER_FULL	DONE	\N
58f36029-5511-4b4d-9aab-97789a86c4b3	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-08-26T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:52:35.171	2026-05-06 06:52:38.761	\N	0	SYNC_USER_FULL	DONE	66260b55-d44c-487c-a2c6-4ee01ff6b311
0e0e1f4e-d99d-4220-a2d3-fca1e66fa913	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-08-06T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:09:54.964	2026-05-08 00:09:59.094	\N	0	SYNC_USER_FULL	DONE	\N
58e48597-9718-4467-b41b-28c0b0b654b5	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-09-25T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:56:54.555	2026-05-06 06:56:58.302	\N	0	SYNC_USER_FULL	DONE	c6b79a3b-70b1-422b-8314-c4ceb42fdf03
1e108934-1b8c-4e06-89c1-ee0399e8c85f	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-08-06T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:11:59.468	2026-05-08 00:12:03.601	\N	0	SYNC_USER_FULL	DONE	3cd48ba4-03a9-4efb-9c1a-d9418d49e4d6
c89f9ab7-b65e-4d21-85be-943fcfc602da	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-09-25T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 07:08:12.48	2026-05-06 07:08:16.733	\N	0	SYNC_USER_FULL	DONE	\N
44151d6d-da55-4351-9093-3b51c93f86e8	{"name": "Jose Perez", "userId": "4f1ad563-b08b-4f15-bef2-cf1b8c0071df", "endDate": "2026-06-06T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-07 07:09:17.955	\N	\N	0	SYNC_USER_FULL	PENDING	c31bf89a-9e1f-4562-b6ed-dee6bb05876c
6e169b4a-4d83-4d54-9251-34fc9fcd3309	{"name": "Juan Perez", "userId": "d07fe5fa-18b1-41cf-b784-d5656a602a7e", "endDate": "2026-06-06T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-07 07:35:30.872	\N	\N	0	SYNC_USER_FULL	PENDING	859e60a5-89d0-409a-b2f9-7c916af5d0e3
331d204d-92f0-457c-8395-3f4fba20f2fc	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194385284.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 22:53:21.476	2026-05-07 22:54:03.332	\N	0	SYNC_USER_FULL	DONE	\N
41a4034c-e3ee-4195-8162-21a4a7e690b7	{"name": "ADRIAN MEDRANO", "userId": "bd4692d3-efdc-4abf-9c29-c9f755caf715", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:25:49.539	2026-05-08 00:25:53.376	\N	0	SYNC_USER_FULL	DONE	\N
478c6d5e-aba3-4e0e-8a9d-adafc85e8cfd	{"name": "Antonio Dams", "userId": "4b5a5b43-8414-48d7-a9b5-4491f2f59336", "endDate": "2027-05-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194633989.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 22:58:03.277	2026-05-07 22:58:07.828	\N	0	SYNC_USER_FULL	DONE	\N
334133ac-11cc-4682-97fd-d18afd8fdb88	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778200570391.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:38:58.692	2026-05-08 00:39:02.871	\N	0	SYNC_USER_FULL	DONE	138c5307-77bb-43b6-8f32-06a98a4b0629
4c998436-9d86-4cf3-be09-edb1c6c8ac35	{"name": "Antonio Dams", "userId": "4b5a5b43-8414-48d7-a9b5-4491f2f59336", "endDate": "2027-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194633989.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:00:25.51	2026-05-07 23:00:30.038	\N	0	SYNC_USER_FULL	DONE	5aeac523-0a95-46e4-9910-2e40778bb025
6179aa31-7a7f-4e37-a4e3-f554cc7a4f04	{"name": "EDUARDO DURAN", "userId": "156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:16:24.82	2026-05-07 23:16:28.642	\N	0	SYNC_USER_FULL	DONE	\N
1ff2c7b3-751c-4603-9499-08d28410d6f9	{"name": "EDUARDO DURAN", "userId": "156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d", "endDate": "2026-07-08T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:16:47.893	2026-05-07 23:16:51.745	\N	0	SYNC_USER_FULL	DONE	61248ce8-03d7-4b5f-ad50-a4ff4b09b0e3
9226fae6-d703-45c2-96e4-dfb5eaac4a6b	{"name": "EDUARDO DURAN", "userId": "156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d", "endDate": "2026-07-08T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778197677040.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:49:06.173	2026-05-07 23:49:11.102	\N	0	SYNC_USER_FULL	DONE	\N
a21eeaf9-902f-484b-93e9-9aec5ea9e4ab	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-08-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:56:36.183	2026-05-07 23:56:41.113	\N	0	SYNC_USER_FULL	DONE	\N
6aa2f1ee-5929-46f7-a5dc-d36b2a19817f	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201314416.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:49:07.508	2026-05-08 00:49:11.891	\N	0	SYNC_USER_FULL	DONE	\N
\.


--
-- Data for Name: Company; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Company" (id, name, "isActive", "createdAt", "updatedAt", "logoUrl") FROM stdin;
6b293f8f-beec-4a45-9b22-98ceabe0f3a1	SYSTEM	t	2026-05-05 14:44:21.658	2026-05-05 14:44:21.658	\N
6b828940-7fc0-449f-8a26-f91d237a0940	Inifinity	t	2026-05-05 14:46:06.498	2026-05-06 05:45:02.488	uploads/logos/1777992367339.png
ba873a42-909b-47cf-8bd7-15caaf87fd46	MetaFit Mutualista	t	2026-05-07 22:35:11.327	2026-05-08 03:28:53.799	uploads/logos/1778193332855.png
\.


--
-- Data for Name: CompanyPermission; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."CompanyPermission" (id, "companyId", "permissionId", "createdAt") FROM stdin;
6763b7a2-3536-47c3-9417-4a8297ac92e6	6b828940-7fc0-449f-8a26-f91d237a0940	bd9349cc-fc82-410f-8136-672a3f416fe1	2026-05-06 05:45:02.678
d74227c5-5ead-49ae-9a83-1a50ceb082ca	6b828940-7fc0-449f-8a26-f91d237a0940	1d458a77-9b8d-4ebc-9931-97a7e74cf21c	2026-05-06 05:45:02.678
484122b5-5e0f-4683-8ff2-dbd75e067154	6b828940-7fc0-449f-8a26-f91d237a0940	b645a3fc-7edd-4e3a-85f8-26469b2d0037	2026-05-06 05:45:02.678
8c252519-b82f-45fb-9afa-600c5fd0e83b	6b828940-7fc0-449f-8a26-f91d237a0940	79bef71b-18e5-4691-a2e4-be34146e9fc9	2026-05-06 05:45:02.678
c55a1ce6-e892-4dca-ba19-3d8873d93686	6b828940-7fc0-449f-8a26-f91d237a0940	73e7330e-50a3-47e3-b86a-e80bf691db07	2026-05-06 05:45:02.678
f15efb63-f5b3-4531-b85b-5f7a0d288d31	6b828940-7fc0-449f-8a26-f91d237a0940	e738238a-eb71-4323-8b30-5fb7a7d30b14	2026-05-06 05:45:02.678
e8dd83a6-0a1a-4f4a-af5d-c11b74af7fce	6b828940-7fc0-449f-8a26-f91d237a0940	23a9c166-1a7a-4ef1-b026-61af37645e3b	2026-05-06 05:45:02.678
4bcba496-bb8c-42a9-ba99-d4122b9b1057	6b828940-7fc0-449f-8a26-f91d237a0940	88b7d5b1-974c-41b0-8b38-d4dcb0ceeb2f	2026-05-06 05:45:02.678
58b3b2c7-6261-451b-a591-8fb6f754fcef	6b828940-7fc0-449f-8a26-f91d237a0940	94e4347f-16ae-43ad-b334-8cad426f5562	2026-05-06 05:45:02.678
ef44a76a-6b9e-4736-bfdd-246697c845c0	6b828940-7fc0-449f-8a26-f91d237a0940	d1fbb067-418d-4f1d-bd9b-ae25fa98e593	2026-05-06 05:45:02.678
d6e27913-21e3-4e9e-a949-3ef4120cefd2	6b828940-7fc0-449f-8a26-f91d237a0940	e0df5c84-efae-4efb-9145-e2cf00cd80dd	2026-05-06 05:45:02.678
1bfa2a86-06c6-4ae2-91fd-0654000baab8	6b828940-7fc0-449f-8a26-f91d237a0940	3415b815-1065-4c7f-93e3-afd53b84c557	2026-05-06 05:45:02.678
f3e3f734-7bca-457d-bc81-48f44d9a687a	6b828940-7fc0-449f-8a26-f91d237a0940	1202de82-2216-4467-8f56-2666bf2f3448	2026-05-06 05:45:02.678
afa6e739-053a-4ee1-ac8c-132bd34e0e43	6b828940-7fc0-449f-8a26-f91d237a0940	292ab621-eb16-45e2-9872-3d475315817b	2026-05-06 05:45:02.678
d2dc276e-034b-4587-a678-3174b1c576c4	6b828940-7fc0-449f-8a26-f91d237a0940	4f140291-f5f7-487b-a0a2-a34881d51517	2026-05-06 05:45:02.678
1a0e6108-3fd3-4874-95e4-9cdf93e469f5	6b828940-7fc0-449f-8a26-f91d237a0940	082dcb9f-6381-4bca-9b3c-a4ef3dcbb706	2026-05-06 05:45:02.678
371d0d3a-d964-4cf3-8b86-6ad58c7cc2cb	6b828940-7fc0-449f-8a26-f91d237a0940	082e2a7a-eff6-44a1-b604-c2ab1edc95b5	2026-05-06 05:45:02.678
bdfaccd3-f605-42f4-974b-334c06e162d3	6b828940-7fc0-449f-8a26-f91d237a0940	9c876750-36f2-468e-a198-e10a9626cd00	2026-05-06 05:45:02.678
4bc98c7a-d1f1-4212-9d92-531cb21f04ef	6b828940-7fc0-449f-8a26-f91d237a0940	0f2dec1d-907c-4191-bc9a-acb18f6378a8	2026-05-06 05:45:02.678
1c0b4a51-2220-4d54-9a1b-57a6db6043b0	6b828940-7fc0-449f-8a26-f91d237a0940	8f935806-88ce-43c1-9ada-4336968d1c04	2026-05-06 05:45:02.678
0cdaf76b-bbb9-490d-a527-34b3848fa1be	6b828940-7fc0-449f-8a26-f91d237a0940	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365	2026-05-06 05:45:02.678
ffd04403-7c17-4af6-9a96-86f5ee0305ab	6b828940-7fc0-449f-8a26-f91d237a0940	dcde9549-77da-4227-ada0-35f7565804ef	2026-05-06 05:45:02.678
711d59df-2ebe-4b41-9e25-a6b12a67a86c	6b828940-7fc0-449f-8a26-f91d237a0940	375daabc-e2c9-435e-b007-18245e5f2d0d	2026-05-06 05:45:02.678
8d34513e-3ad8-4add-98cb-aa034fd8f7cf	6b828940-7fc0-449f-8a26-f91d237a0940	0c38eda9-3781-4a72-93cc-810b51caf9c7	2026-05-06 05:45:02.678
4e0d9f69-0419-438f-8cf1-093a4ed6bbdb	6b828940-7fc0-449f-8a26-f91d237a0940	3c4c0349-cd46-4557-aa21-ced1ef68a054	2026-05-06 05:45:02.678
fe5996e2-a4dd-4cd2-af5e-702c9a402b8f	6b828940-7fc0-449f-8a26-f91d237a0940	8906ae3f-dacf-4ba5-a2c6-e2e9c65f91a4	2026-05-06 05:45:02.678
4507e74a-f64d-4eac-95d7-1dbef929584f	6b828940-7fc0-449f-8a26-f91d237a0940	6bb4ba35-d763-4f61-bb02-73c217976f25	2026-05-06 05:45:02.678
f7696a13-2d3c-4688-bcf8-3ad721027276	6b828940-7fc0-449f-8a26-f91d237a0940	b3bc1161-8c43-4264-a60d-619e05cda55e	2026-05-06 05:45:02.678
3713a8c0-ae06-4979-91a5-bf48c78eaef3	6b828940-7fc0-449f-8a26-f91d237a0940	f3e6cf31-7278-4581-a485-28064fb99b5c	2026-05-06 05:45:02.678
93c8dd55-ea2d-404e-99fe-77f1aa95e241	6b828940-7fc0-449f-8a26-f91d237a0940	850ae969-9f55-41ca-bb53-80066d012323	2026-05-06 05:45:02.678
64aaa0e6-8420-4d31-8c0a-75ae89721bb1	6b828940-7fc0-449f-8a26-f91d237a0940	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735	2026-05-06 05:45:02.678
357d1127-f7d1-446c-a083-b869468bb7ed	ba873a42-909b-47cf-8bd7-15caaf87fd46	bd9349cc-fc82-410f-8136-672a3f416fe1	2026-05-08 03:28:53.831
f0f56e07-a15c-4009-ba12-cb253269caef	ba873a42-909b-47cf-8bd7-15caaf87fd46	1d458a77-9b8d-4ebc-9931-97a7e74cf21c	2026-05-08 03:28:53.831
2a739cc0-802b-4a03-be42-ddac4f4b6f42	ba873a42-909b-47cf-8bd7-15caaf87fd46	b645a3fc-7edd-4e3a-85f8-26469b2d0037	2026-05-08 03:28:53.831
fa04f30d-0023-41c4-be5e-9615ef44f067	ba873a42-909b-47cf-8bd7-15caaf87fd46	79bef71b-18e5-4691-a2e4-be34146e9fc9	2026-05-08 03:28:53.831
9eedb634-2a60-4240-9a43-d1876dc80e2e	ba873a42-909b-47cf-8bd7-15caaf87fd46	73e7330e-50a3-47e3-b86a-e80bf691db07	2026-05-08 03:28:53.831
f8ce24c1-0c25-49d6-9db1-0d82b04136bd	ba873a42-909b-47cf-8bd7-15caaf87fd46	e738238a-eb71-4323-8b30-5fb7a7d30b14	2026-05-08 03:28:53.831
2b85be92-6e4d-4925-9f1a-3cbe7c711e60	ba873a42-909b-47cf-8bd7-15caaf87fd46	23a9c166-1a7a-4ef1-b026-61af37645e3b	2026-05-08 03:28:53.831
e0e96009-df61-4033-b56a-8764bcf69fbe	ba873a42-909b-47cf-8bd7-15caaf87fd46	88b7d5b1-974c-41b0-8b38-d4dcb0ceeb2f	2026-05-08 03:28:53.831
8effc8dd-4ede-461b-b6ce-457492232b3a	ba873a42-909b-47cf-8bd7-15caaf87fd46	94e4347f-16ae-43ad-b334-8cad426f5562	2026-05-08 03:28:53.831
4c33a25f-d296-4026-863b-3b3cf4259d81	ba873a42-909b-47cf-8bd7-15caaf87fd46	d1fbb067-418d-4f1d-bd9b-ae25fa98e593	2026-05-08 03:28:53.831
7d769ff3-0e41-45ff-8d4b-6df444aad8fd	ba873a42-909b-47cf-8bd7-15caaf87fd46	e0df5c84-efae-4efb-9145-e2cf00cd80dd	2026-05-08 03:28:53.831
720ac805-8aef-4c4e-85e7-027a9f935e0a	ba873a42-909b-47cf-8bd7-15caaf87fd46	3415b815-1065-4c7f-93e3-afd53b84c557	2026-05-08 03:28:53.831
bc89fea6-40dc-4572-b938-94619a89a21b	ba873a42-909b-47cf-8bd7-15caaf87fd46	1202de82-2216-4467-8f56-2666bf2f3448	2026-05-08 03:28:53.831
49bd771a-60c1-4415-b1d0-7a501d88b599	ba873a42-909b-47cf-8bd7-15caaf87fd46	292ab621-eb16-45e2-9872-3d475315817b	2026-05-08 03:28:53.831
99effd22-730f-4b73-9b9d-65a2ed25a6f8	ba873a42-909b-47cf-8bd7-15caaf87fd46	4f140291-f5f7-487b-a0a2-a34881d51517	2026-05-08 03:28:53.831
16df121c-1a33-4902-97c9-e87158850c2e	ba873a42-909b-47cf-8bd7-15caaf87fd46	082dcb9f-6381-4bca-9b3c-a4ef3dcbb706	2026-05-08 03:28:53.831
61f9754e-b753-4275-92c3-40e2907ff245	ba873a42-909b-47cf-8bd7-15caaf87fd46	082e2a7a-eff6-44a1-b604-c2ab1edc95b5	2026-05-08 03:28:53.831
27d379c4-1394-4283-859c-c464ab4a1223	ba873a42-909b-47cf-8bd7-15caaf87fd46	9c876750-36f2-468e-a198-e10a9626cd00	2026-05-08 03:28:53.831
6bcc073c-2b36-4069-9d5a-d03e28266d5e	ba873a42-909b-47cf-8bd7-15caaf87fd46	0f2dec1d-907c-4191-bc9a-acb18f6378a8	2026-05-08 03:28:53.831
29ffcb79-c1d0-4385-8311-366535238dc9	ba873a42-909b-47cf-8bd7-15caaf87fd46	8f935806-88ce-43c1-9ada-4336968d1c04	2026-05-08 03:28:53.831
fc08957d-f82f-47b4-81eb-c52f68648060	ba873a42-909b-47cf-8bd7-15caaf87fd46	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365	2026-05-08 03:28:53.831
70c88cf0-3e7d-4bb5-b905-a22608c47732	ba873a42-909b-47cf-8bd7-15caaf87fd46	dcde9549-77da-4227-ada0-35f7565804ef	2026-05-08 03:28:53.831
78af337c-ab3e-4d02-9729-a4b14faed66d	ba873a42-909b-47cf-8bd7-15caaf87fd46	375daabc-e2c9-435e-b007-18245e5f2d0d	2026-05-08 03:28:53.831
887ea5fe-3e99-47cd-b223-c9f57b80c129	ba873a42-909b-47cf-8bd7-15caaf87fd46	0c38eda9-3781-4a72-93cc-810b51caf9c7	2026-05-08 03:28:53.831
2828fb99-b79d-429f-b04f-4c54721456bb	ba873a42-909b-47cf-8bd7-15caaf87fd46	3c4c0349-cd46-4557-aa21-ced1ef68a054	2026-05-08 03:28:53.831
180a2798-fdf1-4344-a962-72b7c6f06045	ba873a42-909b-47cf-8bd7-15caaf87fd46	8906ae3f-dacf-4ba5-a2c6-e2e9c65f91a4	2026-05-08 03:28:53.831
a37d5f1d-2322-41df-aede-08ee901a9c5a	ba873a42-909b-47cf-8bd7-15caaf87fd46	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735	2026-05-08 03:28:53.831
725ea817-1f0c-4feb-bb83-6f654ea4bc7c	ba873a42-909b-47cf-8bd7-15caaf87fd46	6bb4ba35-d763-4f61-bb02-73c217976f25	2026-05-08 03:28:53.831
31fbbff7-4881-4708-9be4-fc70beab6c15	ba873a42-909b-47cf-8bd7-15caaf87fd46	b3bc1161-8c43-4264-a60d-619e05cda55e	2026-05-08 03:28:53.831
63990ee3-6fed-4d5c-adbd-2012f9bb90be	ba873a42-909b-47cf-8bd7-15caaf87fd46	f3e6cf31-7278-4581-a485-28064fb99b5c	2026-05-08 03:28:53.831
59cc25c5-33cb-4dc4-82e8-cbec18f47620	ba873a42-909b-47cf-8bd7-15caaf87fd46	850ae969-9f55-41ca-bb53-80066d012323	2026-05-08 03:28:53.831
d64d6434-db81-4244-b5f7-6077be3960ad	ba873a42-909b-47cf-8bd7-15caaf87fd46	e49620db-e84c-47bf-91a0-ff8867c8f412	2026-05-08 03:28:53.831
\.


--
-- Data for Name: CustomerMembership; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."CustomerMembership" (id, "customerId", "companyId", "startDate", "endDate", status, "hikvisionUserId", "deletedFromDevice", "lastSyncAt", "createdAt", "updatedAt", "branchId") FROM stdin;
c0a48518-d0b5-4552-9802-6b165c20ef9a	510a43a7-4384-420e-8a21-e52f34a1fe6d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-04 00:00:00	2026-09-25 23:59:59.999	ACTIVE	\N	f	\N	2026-05-05 14:50:18.323	2026-05-06 06:56:54.502	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
e8f3880d-7475-4a59-b61c-226bede85697	4f1ad563-b08b-4f15-bef2-cf1b8c0071df	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-07 00:00:00	2026-06-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-07 07:09:17.9	2026-05-07 07:09:17.9	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
07224fe3-0d30-4aed-a1a1-4e8339eec3de	d07fe5fa-18b1-41cf-b784-d5656a602a7e	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-07 00:00:00	2026-06-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-07 07:35:30.838	2026-05-07 07:35:30.838	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
1a96687d-ea24-4fc2-92cf-ac50c0589e12	5564e62d-031a-4094-8e7b-ca2e5f28f481	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 04:00:00	2027-04-01 03:59:59.999	ACTIVE	\N	f	\N	2026-05-07 22:53:21.454	2026-05-07 22:53:21.454	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
73c71b05-550a-4be1-98b1-cb9897c99894	4b5a5b43-8414-48d7-a9b5-4491f2f59336	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 00:00:00	2027-06-07 23:59:59.999	ACTIVE	\N	f	\N	2026-05-07 22:58:03.247	2026-05-07 23:00:25.476	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
08f16840-d380-42d5-955e-08ae1076660e	156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 00:00:00	2026-07-08 23:59:59.999	ACTIVE	\N	f	\N	2026-05-07 23:16:24.801	2026-05-07 23:16:47.866	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
27ce5bba-41aa-449e-8148-e1a3d9ceee9f	1faf3a07-9b37-4f07-9f77-e33fbf855ed6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-08-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:11:59.369	2026-05-08 00:11:59.369	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3a1e97e0-eb8b-4c67-9ba5-bb6071ac84c3	bd4692d3-efdc-4abf-9c29-c9f755caf715	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 04:00:00	2026-08-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:25:49.524	2026-05-08 00:25:49.524	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
39e80dd0-b310-42e7-86cc-b08bae4187a2	de09cfdb-ea36-47be-ba0f-e121fbfa49a6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-07 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:38:58.636	2026-05-08 00:38:58.636	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4f77379a-1d9d-470f-a08d-5626340e07d2	29d96077-cf65-4862-93f5-650250ea47a7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 04:00:00	2026-07-15 03:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:49:07.456	2026-05-08 00:49:07.456	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
\.


--
-- Data for Name: Device; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Device" (id, name, ip, port, username, password, "deviceType", brand, "isActive", "companyId", "branchId", "agentId", "lastSeenAt", "createdAt", "updatedAt", "lastConnectionAt", status) FROM stdin;
7f535e59-6817-4577-a2aa-5f7b4cc7682c	entrada	192.168.88.8	80	admin	U2FsdGVkX199dOyuTxL+zkJMTA5sPDiEsY3ZWRPp3cI=	ACCESS_CONTROL	HIKVISION	t	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	\N	2026-05-06 07:46:27.543	2026-05-05 14:49:13.548	2026-05-06 07:46:27.544	2026-05-06 07:46:27.543	CONNECTED
d0316808-230a-4f9b-be69-99baa051ab4d	Entrada	192.168.0.8	80	admin	U2FsdGVkX1/1zn8OTiOLKuYUB9kcx0CbtBMdrhkFxwE=	ACCESS_CONTROL	HIKVISION	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	\N	2026-05-08 01:17:46.433	2026-05-07 22:38:03.818	2026-05-08 01:17:46.436	2026-05-08 01:17:46.433	CONNECTED
3db306d4-a4c8-471c-8adc-f43096810718	Salida	192.168.0.9	80	admin	U2FsdGVkX18l3WuLvFZUCLd/L8FP3tRSb/og4zYYPX8=	ACCESS_CONTROL	HIKVISION	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	\N	2026-05-08 01:17:46.441	2026-05-07 22:38:26.283	2026-05-08 01:17:46.45	2026-05-08 01:17:46.441	CONNECTED
\.


--
-- Data for Name: MembershipSale; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."MembershipSale" (id, "partnerId", "planId", "companyId", "startDate", "endDate", status, price, "createdAt", "saleDate", "userId", "branchId") FROM stdin;
73a62efe-17a5-492a-b144-82ee9f8be015	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-05 14:50:18.315	2026-06-04 14:50:18.315	ACTIVE	150.00	2026-05-05 14:50:18.358	2026-05-05 14:50:18.353	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
d57ea833-34cb-4fa6-a3e2-13e9f937f4cd	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-06-04 14:50:18.315	2026-07-04 14:50:18.315	ACTIVE	150.00	2026-05-05 15:00:09.787	2026-05-05 15:00:09.785	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
d2711a8f-6315-4ad9-8139-d81ab42f02fa	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-07-04 14:50:18.315	2026-08-03 14:50:18.315	ACTIVE	150.00	2026-05-05 15:00:34.491	2026-05-05 15:00:34.488	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
12a92ee9-3ad3-4e3a-bd07-bfe8668b5a9a	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-08-03 14:50:18.315	2026-09-02 14:50:18.315	ACTIVE	150.00	2026-05-05 19:56:00.739	2026-05-05 19:56:00.736	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
0acf7397-2155-42fb-9792-c850ff111703	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-09-02 14:50:18.315	2026-10-02 14:50:18.315	ACTIVE	150.00	2026-05-05 20:07:25.41	2026-05-05 20:07:25.407	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
dc1b339a-eb2a-4b99-a94c-344b8ad5a545	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-10-02 14:50:18.315	2026-11-01 14:50:18.315	ACTIVE	150.00	2026-05-05 20:28:36.027	2026-05-05 20:28:36.024	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
c74a9f27-e6c3-44f5-8672-19bcbb7dae5c	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-11-01 14:50:18.315	2026-12-01 14:50:18.315	ACTIVE	150.00	2026-05-05 20:31:28.685	2026-05-05 20:31:28.681	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
4a4fbb23-9cd4-4899-a37e-39beba6ab5c2	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-28 03:59:59.999	2026-06-27 03:59:59.999	ACTIVE	150.00	2026-05-06 06:05:06.921	2026-05-06 06:05:06.919	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
98bdb0f0-aa0e-4df2-81d5-ed5f6cb0719b	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-06-27 23:59:59.999	2026-07-27 23:59:59.999	ACTIVE	150.00	2026-05-06 06:22:52.796	2026-05-06 06:22:52.79	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
66260b55-d44c-487c-a2c6-4ee01ff6b311	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-07-27 23:59:59.999	2026-08-26 23:59:59.999	ACTIVE	150.00	2026-05-06 06:52:35.153	2026-05-06 06:52:35.147	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
c6b79a3b-70b1-422b-8314-c4ceb42fdf03	510a43a7-4384-420e-8a21-e52f34a1fe6d	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-08-26 00:00:00	2026-09-25 23:59:59.999	ACTIVE	150.00	2026-05-06 06:56:54.538	2026-05-06 06:56:54.536	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
c31bf89a-9e1f-4562-b6ed-dee6bb05876c	4f1ad563-b08b-4f15-bef2-cf1b8c0071df	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-07 00:00:00	2026-06-06 23:59:59.999	ACTIVE	150.00	2026-05-07 07:09:17.947	2026-05-07 07:09:17.943	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
859e60a5-89d0-409a-b2f9-7c916af5d0e3	d07fe5fa-18b1-41cf-b784-d5656a602a7e	cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-07 00:00:00	2026-06-06 23:59:59.999	ACTIVE	150.00	2026-05-07 07:35:30.861	2026-05-07 07:35:30.859	7cead38c-acae-416c-9ed0-83f8287b4f35	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee
5aeac523-0a95-46e4-9910-2e40778bb025	4b5a5b43-8414-48d7-a9b5-4491f2f59336	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2027-05-08 00:00:00	2027-06-07 23:59:59.999	ACTIVE	150.00	2026-05-07 23:00:25.493	2026-05-07 23:00:25.491	a484e2d7-a009-4c8a-8237-b3323c036405	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
61248ce8-03d7-4b5f-ad50-a4ff4b09b0e3	156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-06-08 00:00:00	2026-07-08 23:59:59.999	ACTIVE	150.00	2026-05-07 23:16:47.884	2026-05-07 23:16:47.881	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3cd48ba4-03a9-4efb-9c1a-d9418d49e4d6	1faf3a07-9b37-4f07-9f77-e33fbf855ed6	697be97f-0a12-4ec0-a7d6-5e5046afcdd0	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-08-06 23:59:59.999	ACTIVE	300.00	2026-05-08 00:11:59.456	2026-05-08 00:11:59.451	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
138c5307-77bb-43b6-8f32-06a98a4b0629	de09cfdb-ea36-47be-ba0f-e121fbfa49a6	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-07 23:59:59.999	ACTIVE	130.00	2026-05-08 00:38:58.674	2026-05-08 00:38:58.67	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
\.


--
-- Data for Name: Partner; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Partner" (id, "companyId", type, name, document, phone, email, address, "isActive", "createdAt", "imageUrl") FROM stdin;
510a43a7-4384-420e-8a21-e52f34a1fe6d	6b828940-7fc0-449f-8a26-f91d237a0940	CUSTOMER	Sergio Olmos	3910133	75002428	sergio.olmos86@gmail.com	Av. Ana barba	t	2026-05-05 14:49:35.413	uploads/partners/1777992575936.jpg
4f1ad563-b08b-4f15-bef2-cf1b8c0071df	6b828940-7fc0-449f-8a26-f91d237a0940	CUSTOMER	Jose Perez	7777	7777	jose@gmail.om	mutualista	t	2026-05-06 07:09:07.125	\N
d07fe5fa-18b1-41cf-b784-d5656a602a7e	6b828940-7fc0-449f-8a26-f91d237a0940	CUSTOMER	Juan Perez	234234	23423	\N	\N	t	2026-05-07 07:35:20.273	\N
5564e62d-031a-4094-8e7b-ca2e5f28f481	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Eduardo El Profe	5875939	7854126	jc.fitness.mutualista@gmail.com	Mutualista	t	2026-05-07 22:53:04.625	uploads/partners/1778194385284.jpg
4b5a5b43-8414-48d7-a9b5-4491f2f59336	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Antonio Dams	9852401	75688684	antonio.dams@hotmail.com	\N	t	2026-05-07 22:57:13.554	uploads/partners/1778194633989.jpg
156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	EDUARDO DURAN	13046378	\N	\N	\N	t	2026-05-07 23:15:53.583	uploads/partners/1778197677040.jpg
1faf3a07-9b37-4f07-9f77-e33fbf855ed6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	HAROLD IBAÑEZ	8119213	\N	\N	\N	t	2026-05-07 23:56:13.15	uploads/partners/1778198173671.jpg
4627addd-1068-4588-b8e4-e5800e0f6213	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Pedro Velez	7777	7888445	jc.fitness.mutualista@gmail.com	\N	t	2026-05-07 23:05:40.607	\N
29d96077-cf65-4862-93f5-650250ea47a7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JULIO CESAR	9621478	\N	\N	\N	t	2026-05-08 00:48:33.813	uploads/partners/1778201314416.jpg
de09cfdb-ea36-47be-ba0f-e121fbfa49a6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEXANDER LOPEZ	94012929860	\N	\N	\N	t	2026-05-08 00:36:09.93	uploads/partners/1778201455792.jpg
bd4692d3-efdc-4abf-9c29-c9f755caf715	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ADRIAN MEDRANO	9671176	\N	\N	\N	t	2026-05-08 00:25:04.406	uploads/partners/1778202363079.jpg
\.


--
-- Data for Name: Permission; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Permission" (id, code, description, scope, "isActive") FROM stdin;
3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735	TENANT_MEMBERSHIP_ASSIGN	Asignar membresías	TENANT	t
e49620db-e84c-47bf-91a0-ff8867c8f412	TENANT_MEMBERSHIP_SYNC	Sincronizar membresías	TENANT	t
6bb4ba35-d763-4f61-bb02-73c217976f25	TENANT_DEVICES_VIEW	Ver dispositivos	TENANT	t
b3bc1161-8c43-4264-a60d-619e05cda55e	TENANT_DEVICES_CREATE	Crear dispositivos	TENANT	t
f3e6cf31-7278-4581-a485-28064fb99b5c	TENANT_DEVICES_EDIT	Editar dispositivos	TENANT	t
850ae969-9f55-41ca-bb53-80066d012323	TENANT_DEVICES_DELETE	Eliminar dispositivos	TENANT	t
1d458a77-9b8d-4ebc-9931-97a7e74cf21c	TENANT_USERS_CREATE	Crear usuarios	TENANT	t
b645a3fc-7edd-4e3a-85f8-26469b2d0037	TENANT_USERS_EDIT	Editar usuarios	TENANT	t
79bef71b-18e5-4691-a2e4-be34146e9fc9	TENANT_USERS_DELETE	Eliminar usuarios	TENANT	t
73e7330e-50a3-47e3-b86a-e80bf691db07	TENANT_ROLES_VIEW	Ver roles	TENANT	t
e738238a-eb71-4323-8b30-5fb7a7d30b14	TENANT_ROLES_CREATE	Crear roles	TENANT	t
23a9c166-1a7a-4ef1-b026-61af37645e3b	TENANT_ROLES_EDIT	Editar roles	TENANT	t
88b7d5b1-974c-41b0-8b38-d4dcb0ceeb2f	TENANT_ROLES_DELETE	Eliminar roles	TENANT	t
94e4347f-16ae-43ad-b334-8cad426f5562	TENANT_PERMISSIONS_VIEW	Ver permisos	TENANT	t
d1fbb067-418d-4f1d-bd9b-ae25fa98e593	TENANT_BRANCH_VIEW	Ver sucursales	TENANT	t
e0df5c84-efae-4efb-9145-e2cf00cd80dd	TENANT_SALES_VIEW	Ver ventas	TENANT	t
3415b815-1065-4c7f-93e3-afd53b84c557	TENANT_SALES_CREATE	Crear ventas	TENANT	t
1202de82-2216-4467-8f56-2666bf2f3448	TENANT_SALES_EDIT	Editar ventas	TENANT	t
292ab621-eb16-45e2-9872-3d475315817b	TENANT_SALES_DELETE	Eliminar ventas	TENANT	t
4f140291-f5f7-487b-a0a2-a34881d51517	TENANT_PLANS_VIEW	Ver planes	TENANT	t
5b89eda2-2c06-4981-8aad-7785bc4d5791	SYSTEM_COMPANIES_VIEW	Ver empresas	SYSTEM	t
3cd586e6-6949-433c-8c38-d1c43151a193	SYSTEM_COMPANIES_CREATE	Crear empresas	SYSTEM	t
a7f54f84-7349-4c1b-965c-023c9d6f91ac	SYSTEM_COMPANIES_EDIT	Editar empresas	SYSTEM	t
9dac889c-cb10-48dc-8845-6fb61122dd52	SYSTEM_COMPANIES_DELETE	Eliminar empresas	SYSTEM	t
de553f0c-2f3a-4d9e-99df-82ff80e0e6a2	SYSTEM_BRANCH_VIEW	Ver sucursales	SYSTEM	t
f01f4555-3e42-4848-9b42-424376fb7504	SYSTEM_BRANCH_CREATE	Crear sucursales	SYSTEM	t
21a9607c-af97-4654-85b7-97f2858af7ea	SYSTEM_BRANCH_EDIT	Editar sucursales	SYSTEM	t
1d26e0a4-aa06-4732-839c-28b16f7cba18	SYSTEM_BRANCH_DELETE	Eliminar sucursales	SYSTEM	t
bd9349cc-fc82-410f-8136-672a3f416fe1	TENANT_USERS_VIEW	Ver usuarios	TENANT	t
082dcb9f-6381-4bca-9b3c-a4ef3dcbb706	TENANT_PLANS_CREATE	Crear planes	TENANT	t
082e2a7a-eff6-44a1-b604-c2ab1edc95b5	TENANT_PLANS_EDIT	Editar planes	TENANT	t
9c876750-36f2-468e-a198-e10a9626cd00	TENANT_PLANS_DELETE	Eliminar planes	TENANT	t
0f2dec1d-907c-4191-bc9a-acb18f6378a8	TENANT_PARTNER_VIEW	Ver socios	TENANT	t
8f935806-88ce-43c1-9ada-4336968d1c04	TENANT_PARTNER_CREATE	Crear socios	TENANT	t
4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365	TENANT_PARTNER_EDIT	Editar socios	TENANT	t
dcde9549-77da-4227-ada0-35f7565804ef	TENANT_PARTNER_DELETE	Eliminar socios	TENANT	t
375daabc-e2c9-435e-b007-18245e5f2d0d	TENANT_MEMBERSHIP_VIEW	Ver membresías	TENANT	t
0c38eda9-3781-4a72-93cc-810b51caf9c7	TENANT_MEMBERSHIP_CREATE	Crear membresías	TENANT	t
3c4c0349-cd46-4557-aa21-ced1ef68a054	TENANT_MEMBERSHIP_EDIT	Editar membresías	TENANT	t
8906ae3f-dacf-4ba5-a2c6-e2e9c65f91a4	TENANT_MEMBERSHIP_DELETE	Eliminar membresías	TENANT	t
\.


--
-- Data for Name: Plan; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Plan" (id, name, description, price, "durationDays", "isActive", "companyId", "createdAt", "updatedAt") FROM stdin;
cc1ec0ab-ca58-4285-9f5d-1e58d1a7f89d	Mensual	30 dias	150.000000000000000000000000000000	30	t	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-05 14:49:55.181	2026-05-06 07:32:00.281
97be790e-4f8d-4b7e-8b97-6c51a32f1e61	Mensual	Mes	150.000000000000000000000000000000	30	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 22:43:28.986	2026-05-07 22:43:28.986
ff7413fc-a352-4e48-a411-c1a79e2b4b59	Diario	Dia	30.000000000000000000000000000000	1	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 22:43:48.446	2026-05-07 22:43:48.446
697be97f-0a12-4ec0-a7d6-5e5046afcdd0	Trimestral	3 meses	300.000000000000000000000000000000	90	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 22:44:11.353	2026-05-07 22:44:11.353
0abc1027-2921-479c-8f23-8071267a3eb0	Anual	Año completo	900.000000000000000000000000000000	365	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 22:44:29.78	2026-05-07 22:44:29.78
531f0a99-dcc1-4a33-9eb2-6d592c805893	Promo Mensual	Promocion mensual	130.000000000000000000000000000000	30	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:17:04.394	2026-05-08 00:17:04.394
e13b2784-d129-4d98-9106-571b727e2ae2	Promo Trimestral	Promo trimestral	160.000000000000000000000000000000	90	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:17:30.832	2026-05-08 00:17:30.832
05e7f0d7-535c-462c-8a3e-ca00d39f1d93	Promo Anual	Promo Anual	700.000000000000000000000000000000	365	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:17:52.307	2026-05-08 00:17:52.307
\.


--
-- Data for Name: Role; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Role" (id, name, scope, "companyId", "isActive", "createdAt") FROM stdin;
4cc9cf24-b628-49dc-9108-7f90d1c67fed	SYSTEM_ADMIN	SYSTEM	\N	t	2026-05-05 14:44:20.962
69323eb4-6c52-4d53-b7b8-ee008ba585a9	OWNER	TENANT	\N	t	2026-05-05 14:44:20.975
4d747c99-4e94-4ad0-896b-3b03c53572eb	EMPLOYEE	TENANT	\N	t	2026-05-05 14:44:20.986
8f9470e0-20d8-4306-b280-febaf514e6bb	OWNER	TENANT	6b828940-7fc0-449f-8a26-f91d237a0940	t	2026-05-05 14:46:06.523
200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	OWNER	TENANT	ba873a42-909b-47cf-8bd7-15caaf87fd46	t	2026-05-07 22:35:11.379
c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	Caja	TENANT	ba873a42-909b-47cf-8bd7-15caaf87fd46	t	2026-05-07 23:04:15.666
\.


--
-- Data for Name: RolePermission; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."RolePermission" (id, "roleId", "permissionId") FROM stdin;
94e90461-ebab-4c8e-9b18-9ca317c3fde9	4cc9cf24-b628-49dc-9108-7f90d1c67fed	5b89eda2-2c06-4981-8aad-7785bc4d5791
e7b1bc88-caed-4564-aee6-bae1a3e992a3	4cc9cf24-b628-49dc-9108-7f90d1c67fed	3cd586e6-6949-433c-8c38-d1c43151a193
20c4f03e-9b28-45d0-8eee-5c7929d1f66e	4cc9cf24-b628-49dc-9108-7f90d1c67fed	a7f54f84-7349-4c1b-965c-023c9d6f91ac
1d34ce1f-40fb-4151-8acb-253ea800bb9b	4cc9cf24-b628-49dc-9108-7f90d1c67fed	9dac889c-cb10-48dc-8845-6fb61122dd52
bf7c9268-aef5-4337-86cd-7d475dfe6dd2	4cc9cf24-b628-49dc-9108-7f90d1c67fed	de553f0c-2f3a-4d9e-99df-82ff80e0e6a2
c62923cd-4546-49ac-9098-72587ad55c2c	4cc9cf24-b628-49dc-9108-7f90d1c67fed	f01f4555-3e42-4848-9b42-424376fb7504
d25a32ab-4115-44d0-9af4-784d6d79b1bc	4cc9cf24-b628-49dc-9108-7f90d1c67fed	21a9607c-af97-4654-85b7-97f2858af7ea
c4584b43-9da5-4a9a-8a93-c7daf81e31fa	4cc9cf24-b628-49dc-9108-7f90d1c67fed	1d26e0a4-aa06-4732-839c-28b16f7cba18
d97e1e95-5870-47dd-8bad-b86d7f1d68a5	8f9470e0-20d8-4306-b280-febaf514e6bb	bd9349cc-fc82-410f-8136-672a3f416fe1
96d704f4-698c-458f-8a4c-6f7c6f96562a	8f9470e0-20d8-4306-b280-febaf514e6bb	1d458a77-9b8d-4ebc-9931-97a7e74cf21c
41fe2f3a-227f-4b55-a2ab-103175e5bf3b	8f9470e0-20d8-4306-b280-febaf514e6bb	b645a3fc-7edd-4e3a-85f8-26469b2d0037
8e3b2e01-6f7c-43ea-bbb9-2dc5fdcd9bdc	8f9470e0-20d8-4306-b280-febaf514e6bb	79bef71b-18e5-4691-a2e4-be34146e9fc9
a7b58e70-acf7-449c-beb7-959c95795184	8f9470e0-20d8-4306-b280-febaf514e6bb	73e7330e-50a3-47e3-b86a-e80bf691db07
617d2cff-f85c-49b9-a21c-5c529bbc86a6	8f9470e0-20d8-4306-b280-febaf514e6bb	e738238a-eb71-4323-8b30-5fb7a7d30b14
9c7b4c18-0acd-4a10-9386-6eb9f92f386a	8f9470e0-20d8-4306-b280-febaf514e6bb	23a9c166-1a7a-4ef1-b026-61af37645e3b
dbb42c3a-af49-441f-8fa0-f8ea83851d37	8f9470e0-20d8-4306-b280-febaf514e6bb	88b7d5b1-974c-41b0-8b38-d4dcb0ceeb2f
04278699-7451-430a-b0d7-1ad21e1d0d46	8f9470e0-20d8-4306-b280-febaf514e6bb	94e4347f-16ae-43ad-b334-8cad426f5562
3b429c23-0b5b-437b-b4b9-111bf2cbdeef	8f9470e0-20d8-4306-b280-febaf514e6bb	d1fbb067-418d-4f1d-bd9b-ae25fa98e593
d620dbd0-8ed4-4716-9ffc-201c28113bc7	8f9470e0-20d8-4306-b280-febaf514e6bb	e0df5c84-efae-4efb-9145-e2cf00cd80dd
d38c6f06-3daa-47a8-a09d-43392d67296e	8f9470e0-20d8-4306-b280-febaf514e6bb	3415b815-1065-4c7f-93e3-afd53b84c557
9243adfc-8b27-4168-a81e-f26cb1b43056	8f9470e0-20d8-4306-b280-febaf514e6bb	1202de82-2216-4467-8f56-2666bf2f3448
3a053215-fdc5-4933-827a-bf2a6c3fec50	8f9470e0-20d8-4306-b280-febaf514e6bb	292ab621-eb16-45e2-9872-3d475315817b
dfe3829c-1d50-45b9-937a-1dbf51b13f4b	8f9470e0-20d8-4306-b280-febaf514e6bb	4f140291-f5f7-487b-a0a2-a34881d51517
059cd7b3-c8a6-4369-8f51-fd413b2ef82b	8f9470e0-20d8-4306-b280-febaf514e6bb	082dcb9f-6381-4bca-9b3c-a4ef3dcbb706
411929b8-670c-4948-96b5-91514facd30f	8f9470e0-20d8-4306-b280-febaf514e6bb	082e2a7a-eff6-44a1-b604-c2ab1edc95b5
1e02e22a-254e-44f2-851a-4f1cd5d26f6e	8f9470e0-20d8-4306-b280-febaf514e6bb	9c876750-36f2-468e-a198-e10a9626cd00
b034ed29-2ef8-4b9b-a52d-7f72894c9748	8f9470e0-20d8-4306-b280-febaf514e6bb	0f2dec1d-907c-4191-bc9a-acb18f6378a8
dca280d0-030b-4bde-81e3-89c47cefd463	8f9470e0-20d8-4306-b280-febaf514e6bb	8f935806-88ce-43c1-9ada-4336968d1c04
707b1a23-1f26-40e6-a89a-afc0bd161974	8f9470e0-20d8-4306-b280-febaf514e6bb	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365
cfd7eef0-b09a-4fee-b919-fd76a35b8f34	8f9470e0-20d8-4306-b280-febaf514e6bb	dcde9549-77da-4227-ada0-35f7565804ef
fe5776fe-1d74-4a4a-9d22-b8cf75d9b197	8f9470e0-20d8-4306-b280-febaf514e6bb	375daabc-e2c9-435e-b007-18245e5f2d0d
2518dbd9-213c-491f-8689-1f7711456e9f	8f9470e0-20d8-4306-b280-febaf514e6bb	0c38eda9-3781-4a72-93cc-810b51caf9c7
49ecf5f2-475e-4aef-bafd-e378311e68b5	8f9470e0-20d8-4306-b280-febaf514e6bb	3c4c0349-cd46-4557-aa21-ced1ef68a054
6d31dd7e-5241-4b64-9a48-863edbbd6af6	8f9470e0-20d8-4306-b280-febaf514e6bb	8906ae3f-dacf-4ba5-a2c6-e2e9c65f91a4
2fcaebb2-adbd-4a57-8ecf-235a589d13ad	8f9470e0-20d8-4306-b280-febaf514e6bb	6bb4ba35-d763-4f61-bb02-73c217976f25
07d7b91f-7ec7-4dbe-ab83-687f7ff6b0d7	8f9470e0-20d8-4306-b280-febaf514e6bb	b3bc1161-8c43-4264-a60d-619e05cda55e
d8b95415-99c8-4ecc-9016-14a396081005	8f9470e0-20d8-4306-b280-febaf514e6bb	f3e6cf31-7278-4581-a485-28064fb99b5c
247e069a-3b82-488d-921d-f3374c8b36b1	8f9470e0-20d8-4306-b280-febaf514e6bb	850ae969-9f55-41ca-bb53-80066d012323
fd840ace-c3dc-4366-a55b-018de6dd51da	8f9470e0-20d8-4306-b280-febaf514e6bb	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735
04bda6cb-ee6b-4f73-8c30-bfc643b4f959	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	bd9349cc-fc82-410f-8136-672a3f416fe1
3c9487b5-f1d7-4e01-9440-4fcc7cc11453	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	1d458a77-9b8d-4ebc-9931-97a7e74cf21c
f369bd66-8236-403c-8343-38b7dc491423	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	b645a3fc-7edd-4e3a-85f8-26469b2d0037
004a1fd7-4fec-4c1d-8593-54259c630148	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	79bef71b-18e5-4691-a2e4-be34146e9fc9
e2a95d1d-a180-4978-a0a6-ed949af4b82e	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	73e7330e-50a3-47e3-b86a-e80bf691db07
fedc11b0-3804-4228-bd81-659a1ae9c58b	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	e738238a-eb71-4323-8b30-5fb7a7d30b14
70f45516-02bb-4507-8214-845c9d7429c5	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	23a9c166-1a7a-4ef1-b026-61af37645e3b
ab50f28f-b3de-4650-9a74-143bb6ef549c	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	88b7d5b1-974c-41b0-8b38-d4dcb0ceeb2f
eefa736c-b4f0-48ec-81f9-afff36e8fd50	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	94e4347f-16ae-43ad-b334-8cad426f5562
3fb5465f-82a8-4b22-9731-c338b70ead6d	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	d1fbb067-418d-4f1d-bd9b-ae25fa98e593
00ff4280-b0f9-4aa3-93af-f8834e5e5b78	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	e0df5c84-efae-4efb-9145-e2cf00cd80dd
51daa851-003f-47c7-a8f6-f32f93a05e15	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	3415b815-1065-4c7f-93e3-afd53b84c557
08904ad5-ae4e-40df-a70b-6ce6625c5882	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	1202de82-2216-4467-8f56-2666bf2f3448
cd64c588-3857-49ea-9d2e-12d068683560	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	292ab621-eb16-45e2-9872-3d475315817b
319f3b4b-c555-4971-8c1f-bf627d10874b	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	4f140291-f5f7-487b-a0a2-a34881d51517
8f220deb-fb32-45a0-b2fb-d5d0f85c2f5e	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	082dcb9f-6381-4bca-9b3c-a4ef3dcbb706
94bf537f-80e3-4143-a835-a48995bbe7fb	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	082e2a7a-eff6-44a1-b604-c2ab1edc95b5
1398e249-187a-43c7-9032-6c8acfb682cc	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	9c876750-36f2-468e-a198-e10a9626cd00
14d6d0d5-0066-4652-940a-43d7f0d5ff02	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	0f2dec1d-907c-4191-bc9a-acb18f6378a8
702497b1-bc99-49b8-951f-fee05657b6a8	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	8f935806-88ce-43c1-9ada-4336968d1c04
7cbd7cf9-1151-4df5-ab15-2f54c863e0c6	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365
1e345a75-713f-40c5-8fc3-4d3dc6e16ad7	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	dcde9549-77da-4227-ada0-35f7565804ef
7ce5f53b-ceac-4eaf-8700-a3df1854efea	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	375daabc-e2c9-435e-b007-18245e5f2d0d
d8e52e0b-5086-43eb-9868-0eb7b317752e	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	0c38eda9-3781-4a72-93cc-810b51caf9c7
420f5c9a-ab1a-451e-bfe5-391a2aafc9c4	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	3c4c0349-cd46-4557-aa21-ced1ef68a054
6e1d49fe-57b8-408f-9908-9420ccc54af4	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	8906ae3f-dacf-4ba5-a2c6-e2e9c65f91a4
d97ccaaa-99cf-41de-9ce4-6342c1f8dc65	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735
26c8d125-9202-464c-84de-2a67c07cdf3a	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	6bb4ba35-d763-4f61-bb02-73c217976f25
427c1916-4d5a-4289-b0b1-d6aa85dfb4c5	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	b3bc1161-8c43-4264-a60d-619e05cda55e
a5e21375-4b17-49b9-9a93-69857f7261b4	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	f3e6cf31-7278-4581-a485-28064fb99b5c
bf360cfa-bb67-410b-98e4-7a70dc47eab4	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	850ae969-9f55-41ca-bb53-80066d012323
559542d6-820f-4b34-b75a-2135cefdd557	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	e49620db-e84c-47bf-91a0-ff8867c8f412
6fb3871a-59d7-4c91-a129-2fe61547ec40	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	bd9349cc-fc82-410f-8136-672a3f416fe1
ed834bfb-134b-4425-8dbb-473cfe05d10e	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	d1fbb067-418d-4f1d-bd9b-ae25fa98e593
a165c363-2ef3-4ddd-849c-48703f9a9105	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	e0df5c84-efae-4efb-9145-e2cf00cd80dd
de792639-3663-46b1-a41c-09e15ace6720	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	3415b815-1065-4c7f-93e3-afd53b84c557
35d4eb51-8e29-44b8-a211-e648c1ece637	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	4f140291-f5f7-487b-a0a2-a34881d51517
3f08e814-f32e-4e42-b12d-3b02fa1d1adf	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	0f2dec1d-907c-4191-bc9a-acb18f6378a8
ca7bbd75-c250-467e-87a8-3781bea5ccf6	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	8f935806-88ce-43c1-9ada-4336968d1c04
16bbe6ae-b761-48ea-9579-15a83026fadb	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365
207a45aa-f863-42ce-9ad7-907ec542ea2c	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	375daabc-e2c9-435e-b007-18245e5f2d0d
f52d333e-3160-4250-b38d-c81175cb652c	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	0c38eda9-3781-4a72-93cc-810b51caf9c7
db8d47d4-0695-43d1-9ea9-02aca45275af	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735
584cc4f6-b93b-4129-a21b-6c5f24be8180	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	6bb4ba35-d763-4f61-bb02-73c217976f25
f302e683-0eeb-4932-a71c-1767487dd5f5	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	e49620db-e84c-47bf-91a0-ff8867c8f412
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."User" (id, email, password, "fullName", "isActive", "companyId", "createdAt", "updatedAt", "branchId", "isOwner") FROM stdin;
7cead38c-acae-416c-9ed0-83f8287b4f35	admin@infinity.com	$2b$10$UD.ar9z07af8UV/zi8gZ5eIa5mfKQR6w6eKtxqK0rUbdjM2fPyoo2	Administracion	t	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-05 14:46:06.651	2026-05-06 05:45:02.46	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	t
543856ad-d4b6-4be7-93b5-e9bf0052c782	caja_mutualista@metafit.com	$2b$10$p/j/T5F8wUhfw3TkZ9AIuuuVaaHxU4x1FB7n8o69gP8zq/BB6Mobu	caja_mutualista@metafit.com	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 23:04:51.24	2026-05-07 23:04:51.24	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	f
7abf7f31-0cf6-48e0-a1a2-697de2a0b166	admin@erp.com	$2b$10$ADWlnevKdkzSaohE5/GM1OvbrpMXJ9EepqSwxEnlVT0DRb3v/sR8y	Super Admin	t	6b293f8f-beec-4a45-9b22-98ceabe0f3a1	2026-05-05 14:44:21.821	2026-05-08 03:26:33.478	1b9b384c-0715-4247-b718-6738efe86c89	f
a484e2d7-a009-4c8a-8237-b3323c036405	admin@metafit.com	$2b$10$f7bSYzVrhad4aSjdch51c.oQkGzJFkyO7Xq3xwH0JKZhBCIZDozRy	Administración	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 22:35:11.664	2026-05-08 03:28:53.788	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	t
\.


--
-- Data for Name: UserRole; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."UserRole" (id, "userId", "roleId", "companyId") FROM stdin;
e3db1c65-b59d-4433-b4bd-b7e4097bc62f	7abf7f31-0cf6-48e0-a1a2-697de2a0b166	4cc9cf24-b628-49dc-9108-7f90d1c67fed	\N
6e1927ea-f76f-46f4-b7e6-78784bc6c97d	7cead38c-acae-416c-9ed0-83f8287b4f35	8f9470e0-20d8-4306-b280-febaf514e6bb	6b828940-7fc0-449f-8a26-f91d237a0940
15e942ff-8b36-4b0f-a0ff-2ff859f35698	a484e2d7-a009-4c8a-8237-b3323c036405	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	ba873a42-909b-47cf-8bd7-15caaf87fd46
2d22f357-be43-447b-95d7-985cb5cc520b	543856ad-d4b6-4be7-93b5-e9bf0052c782	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	ba873a42-909b-47cf-8bd7-15caaf87fd46
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
5c4803fb-034c-42ff-8048-63a6452613ac	455054d73c4be9fb0878aaf2168698e795f57f67dbf004ed275e8b497bbf599a	2026-05-05 14:44:11.959909+00	20260416025037_add_logo_url_company	\N	\N	2026-05-05 14:44:11.93719+00	1
1177f39b-71f0-4ad5-a9e3-423c0928ea67	ed41bd7cdb8289eb67b0d387ff240d38714b3ace83d21a877e7ce662232d4350	2026-05-05 14:44:10.0893+00	20260404044427_init	\N	\N	2026-05-05 14:44:09.824658+00	1
e4fce5c7-a4ca-4358-8d4f-0886c38ecc81	792d5856a39c38aad6973d78ea5c867c7f6ed9610ac342a49eff4df713201312	2026-05-05 14:44:11.56971+00	20260412210429_	\N	\N	2026-05-05 14:44:11.528536+00	1
1889d567-13d0-4c34-9b10-bf0628b35da2	02470848415e5e07638122121cb2cc7a3ee76523f677ba816eac7fcbd2969de0	2026-05-05 14:44:10.123369+00	20260404064612_company_name_unique	\N	\N	2026-05-05 14:44:10.094245+00	1
d6334d5b-ef5f-4c63-a2d8-9903903447fa	255a3b72b7615f501bc58e3110d8752f862f2e339f102656e30e8466f8f01b3b	2026-05-05 14:44:10.146616+00	20260404064956_branch_unique	\N	\N	2026-05-05 14:44:10.126446+00	1
9e5fe7fe-e5a7-4c17-be11-6f8ec0704f4d	a1990a4452322cee5f28183f4cf9056ef740edd72302ef6f8ee75765324edbb6	2026-05-05 14:44:10.262294+00	20260404191334_add_membership	\N	\N	2026-05-05 14:44:10.150413+00	1
fba8b7da-cfff-4bac-92e8-5bba00e99dc7	4ca41b43a20ede63d53f5b032e8105e96f05610a5d688b3b4a29dc9cd0596bc0	2026-05-05 14:44:11.609267+00	20260413025214_command_update	\N	\N	2026-05-05 14:44:11.574567+00	1
72e10fec-ffca-4fd3-b729-539839db18a1	122d743a0403e77ad7e0ed9447f5b8826f2fbdbc55612d936eff004dd13c2eec	2026-05-05 14:44:10.286167+00	20260404191436_add_membership	\N	\N	2026-05-05 14:44:10.274405+00	1
aeed4c9b-2eb3-48df-a337-280b03b21704	45b7758f3c49dda10f3f5b39515ba317390d4c92f378fd91cfb75bd81b03056f	2026-05-05 14:44:11.062306+00	20260405024438_url	\N	\N	2026-05-05 14:44:10.295742+00	1
cadcdcb4-9892-484b-9a63-81da11422f09	987f2b2f969c1e19b1a46a5f30a2a671e40713ce34ab299802f9ed56175c4d09	2026-05-05 14:44:11.083399+00	20260405030425_membership_simplified	\N	\N	2026-05-05 14:44:11.068333+00	1
cab3ff9c-2319-4e96-8f66-8508e3eef9bf	bf72fbed8876dee13b5a6ca3c637baccde16b56b06ed0d1a87682aac0e3611b5	2026-05-05 14:44:11.769788+00	20260413035025_fix_partner_and_command	\N	\N	2026-05-05 14:44:11.629332+00	1
c8c84e8f-8f1e-461a-a90f-e04760ab08ce	8d724c011c13c6b425235c8bf213b2c687d302d65e9c61463e08fd15c76a277c	2026-05-05 14:44:11.115475+00	20260405032329_fix_membership_status	\N	\N	2026-05-05 14:44:11.097934+00	1
b2de09c7-1da8-419b-9afa-68880d24b840	80b14b14f768308f58cb817676a0035d1b8250ed84c376399588564ad9a3e327	2026-05-05 14:44:11.261549+00	20260405050423_membership_refactor	\N	\N	2026-05-05 14:44:11.119827+00	1
e4904bb3-1ff4-4c04-b638-b66fb916dff5	e11158ad4bb9f4dc75e2b289472e85f4161ab1162d0c5f1e14dd8d0d0dababce	2026-05-05 14:44:11.987331+00	20260416030102_add_logo_url_company	\N	\N	2026-05-05 14:44:11.968222+00	1
e2df110f-8ab9-44d3-938c-9c591b6d38e4	8b554dbe652f492dde60cfe0cc9958521472af9d43ed8e927e3f22c119731ffd	2026-05-05 14:44:11.403255+00	20260405062637_add_device	\N	\N	2026-05-05 14:44:11.265435+00	1
a4ac4e1b-099b-47df-84c1-139752643aed	f54f04e4d8122ce880936f6b8affb6e142999d70c40621d685458450b21f975d	2026-05-05 14:44:11.787859+00	20260413051948_add_partner_image	\N	\N	2026-05-05 14:44:11.773752+00	1
a20890e6-c788-4700-ae2a-1e08e89332a7	373d6af4451e82f2a823d00d7300ac3f97f5fa066dd8c3f21fac9534b6fdcbc2	2026-05-05 14:44:11.49142+00	20260405070456_add_command_relations	\N	\N	2026-05-05 14:44:11.413904+00	1
850f3bc5-545d-46b4-b0ee-f3b71c7852e8	4a41d0a96b40ad489c2890ded9383d9aba120cfffd4ac50514911546b7f954ed	2026-05-05 14:44:11.510425+00	20260406174313_remove_partner_image	\N	\N	2026-05-05 14:44:11.495924+00	1
15169425-ca2b-471f-91f8-9a8c9484b1fe	35a434e0a862556c6fa89cc447333c51ae187f0720a55d241f5c10424cca3bcc	2026-05-05 14:44:11.524556+00	20260407040233_add_error_to_command	\N	\N	2026-05-05 14:44:11.513675+00	1
d5779624-41b5-4bc9-acb2-a8b203f075dc	9158ed60f1432d206cf4f25bb40eddc8d64d25542d53f7c9f4721d5207a543dd	2026-05-05 14:44:11.814247+00	20260413064520_add_branch_id	\N	\N	2026-05-05 14:44:11.795855+00	1
e8e224aa-19e1-4627-950d-40f151e43c1f	2fb27b6e49ea9213bc6e972b1bf67d149ceddecf98d73efc2d06a7ecfb23f714	2026-05-05 14:44:11.870383+00	20260413162550_add_membership_sale_id_to_command	\N	\N	2026-05-05 14:44:11.819878+00	1
b607ff01-2f3d-4712-883d-d5993a7bc5f6	b2bec6e7aaac757087fa44544bf08211a099dff716df30356c16adcaa0c710f9	2026-05-05 14:44:17.31315+00	20260505144417_add_sync_user_full	\N	\N	2026-05-05 14:44:17.258915+00	1
3fefed34-ace8-4045-bbe8-774cf02a1693	336aadbae8f70598f51bcc6bb8921cd16e3e9dc3877450c2b1d1209dcf29105d	2026-05-05 14:44:11.900075+00	20260415231752_add_user_id_sale_date_membership_sales	\N	\N	2026-05-05 14:44:11.87577+00	1
c0106f77-0e83-46f0-a713-796f0a519367	38d8089c3fafda125e602b33235b3e2713fe2a879a58ba92834532967d3f9b65	2026-05-05 14:44:11.931842+00	20260415232835_add_branch_id_membership_sales	\N	\N	2026-05-05 14:44:11.9109+00	1
\.


--
-- Name: Agent Agent_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Agent"
    ADD CONSTRAINT "Agent_pkey" PRIMARY KEY (id);


--
-- Name: Branch Branch_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_pkey" PRIMARY KEY (id);


--
-- Name: Command Command_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Command"
    ADD CONSTRAINT "Command_pkey" PRIMARY KEY (id);


--
-- Name: CompanyPermission CompanyPermission_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."CompanyPermission"
    ADD CONSTRAINT "CompanyPermission_pkey" PRIMARY KEY (id);


--
-- Name: Company Company_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Company"
    ADD CONSTRAINT "Company_pkey" PRIMARY KEY (id);


--
-- Name: CustomerMembership CustomerMembership_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."CustomerMembership"
    ADD CONSTRAINT "CustomerMembership_pkey" PRIMARY KEY (id);


--
-- Name: Device Device_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Device"
    ADD CONSTRAINT "Device_pkey" PRIMARY KEY (id);


--
-- Name: MembershipSale MembershipSale_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."MembershipSale"
    ADD CONSTRAINT "MembershipSale_pkey" PRIMARY KEY (id);


--
-- Name: Partner Partner_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Partner"
    ADD CONSTRAINT "Partner_pkey" PRIMARY KEY (id);


--
-- Name: Permission Permission_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Permission"
    ADD CONSTRAINT "Permission_pkey" PRIMARY KEY (id);


--
-- Name: Plan Plan_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Plan"
    ADD CONSTRAINT "Plan_pkey" PRIMARY KEY (id);


--
-- Name: RolePermission RolePermission_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."RolePermission"
    ADD CONSTRAINT "RolePermission_pkey" PRIMARY KEY (id);


--
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);


--
-- Name: UserRole UserRole_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Agent_agentKey_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Agent_agentKey_key" ON public."Agent" USING btree ("agentKey");


--
-- Name: Agent_branchId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Agent_branchId_idx" ON public."Agent" USING btree ("branchId");


--
-- Name: Agent_branchId_name_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Agent_branchId_name_key" ON public."Agent" USING btree ("branchId", name);


--
-- Name: Agent_companyId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Agent_companyId_idx" ON public."Agent" USING btree ("companyId");


--
-- Name: Branch_name_companyId_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Branch_name_companyId_key" ON public."Branch" USING btree (name, "companyId");


--
-- Name: Command_branchId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Command_branchId_idx" ON public."Command" USING btree ("branchId");


--
-- Name: Command_branchId_status_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Command_branchId_status_idx" ON public."Command" USING btree ("branchId", status);


--
-- Name: Command_companyId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Command_companyId_idx" ON public."Command" USING btree ("companyId");


--
-- Name: Command_membershipSaleId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Command_membershipSaleId_idx" ON public."Command" USING btree ("membershipSaleId");


--
-- Name: Command_status_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Command_status_idx" ON public."Command" USING btree (status);


--
-- Name: CompanyPermission_companyId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "CompanyPermission_companyId_idx" ON public."CompanyPermission" USING btree ("companyId");


--
-- Name: CompanyPermission_companyId_permissionId_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "CompanyPermission_companyId_permissionId_key" ON public."CompanyPermission" USING btree ("companyId", "permissionId");


--
-- Name: CompanyPermission_permissionId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "CompanyPermission_permissionId_idx" ON public."CompanyPermission" USING btree ("permissionId");


--
-- Name: Company_name_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Company_name_key" ON public."Company" USING btree (name);


--
-- Name: CustomerMembership_customerId_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "CustomerMembership_customerId_key" ON public."CustomerMembership" USING btree ("customerId");


--
-- Name: CustomerMembership_endDate_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "CustomerMembership_endDate_idx" ON public."CustomerMembership" USING btree ("endDate");


--
-- Name: Device_branchId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Device_branchId_idx" ON public."Device" USING btree ("branchId");


--
-- Name: Device_branchId_ip_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Device_branchId_ip_key" ON public."Device" USING btree ("branchId", ip);


--
-- Name: Device_companyId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Device_companyId_idx" ON public."Device" USING btree ("companyId");


--
-- Name: MembershipSale_endDate_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "MembershipSale_endDate_idx" ON public."MembershipSale" USING btree ("endDate");


--
-- Name: MembershipSale_partnerId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "MembershipSale_partnerId_idx" ON public."MembershipSale" USING btree ("partnerId");


--
-- Name: Partner_companyId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Partner_companyId_idx" ON public."Partner" USING btree ("companyId");


--
-- Name: Permission_code_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Permission_code_key" ON public."Permission" USING btree (code);


--
-- Name: Plan_name_companyId_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Plan_name_companyId_key" ON public."Plan" USING btree (name, "companyId");


--
-- Name: RolePermission_roleId_permissionId_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "RolePermission_roleId_permissionId_key" ON public."RolePermission" USING btree ("roleId", "permissionId");


--
-- Name: Role_name_scope_companyId_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "Role_name_scope_companyId_key" ON public."Role" USING btree (name, scope, "companyId");


--
-- Name: UserRole_userId_roleId_companyId_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "UserRole_userId_roleId_companyId_key" ON public."UserRole" USING btree ("userId", "roleId", "companyId");


--
-- Name: User_branchId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "User_branchId_idx" ON public."User" USING btree ("branchId");


--
-- Name: User_companyId_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "User_companyId_idx" ON public."User" USING btree ("companyId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Agent Agent_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Agent"
    ADD CONSTRAINT "Agent_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Agent Agent_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Agent"
    ADD CONSTRAINT "Agent_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Branch Branch_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Command Command_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Command"
    ADD CONSTRAINT "Command_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Command Command_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Command"
    ADD CONSTRAINT "Command_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Command Command_membershipSaleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Command"
    ADD CONSTRAINT "Command_membershipSaleId_fkey" FOREIGN KEY ("membershipSaleId") REFERENCES public."MembershipSale"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CompanyPermission CompanyPermission_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."CompanyPermission"
    ADD CONSTRAINT "CompanyPermission_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CompanyPermission CompanyPermission_permissionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."CompanyPermission"
    ADD CONSTRAINT "CompanyPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES public."Permission"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerMembership CustomerMembership_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."CustomerMembership"
    ADD CONSTRAINT "CustomerMembership_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerMembership CustomerMembership_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."CustomerMembership"
    ADD CONSTRAINT "CustomerMembership_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CustomerMembership CustomerMembership_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."CustomerMembership"
    ADD CONSTRAINT "CustomerMembership_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Partner"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Device Device_agentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Device"
    ADD CONSTRAINT "Device_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES public."Agent"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Device Device_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Device"
    ADD CONSTRAINT "Device_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Device Device_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Device"
    ADD CONSTRAINT "Device_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MembershipSale MembershipSale_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."MembershipSale"
    ADD CONSTRAINT "MembershipSale_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MembershipSale MembershipSale_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."MembershipSale"
    ADD CONSTRAINT "MembershipSale_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MembershipSale MembershipSale_partnerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."MembershipSale"
    ADD CONSTRAINT "MembershipSale_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES public."Partner"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MembershipSale MembershipSale_planId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."MembershipSale"
    ADD CONSTRAINT "MembershipSale_planId_fkey" FOREIGN KEY ("planId") REFERENCES public."Plan"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MembershipSale MembershipSale_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."MembershipSale"
    ADD CONSTRAINT "MembershipSale_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Partner Partner_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Partner"
    ADD CONSTRAINT "Partner_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Plan Plan_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Plan"
    ADD CONSTRAINT "Plan_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RolePermission RolePermission_permissionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."RolePermission"
    ADD CONSTRAINT "RolePermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES public."Permission"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RolePermission RolePermission_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."RolePermission"
    ADD CONSTRAINT "RolePermission_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Role Role_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UserRole UserRole_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UserRole UserRole_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserRole UserRole_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: User User_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: User User_companyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: erp_user
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: erp_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict e3blCThOp8Gi79GVbUs0vHKVQmKbqc9eNgWIWzlHEoRsSxz9Zd7pGjFVoJTeCqV

