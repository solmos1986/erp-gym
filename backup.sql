--
-- PostgreSQL database dump
--

\restrict OvcA8TjK4KStGvOtpuCl7S86aFJGUAh8ZUncBWCez7WyMWoNdv1SXBAZZ2NGfgo

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
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "publicIp" text
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

COPY public."Agent" (id, name, "agentKey", "companyId", "branchId", "isActive", "lastSeenAt", "createdAt", "updatedAt", "publicIp") FROM stdin;
5ac2f379-3b46-48a5-a183-8145e58c5493	Agent - Principal	e1517fe357446954ee62c8b2a2d21458c6ec3462551e1e135886a6668b6029e2	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	t	2026-05-11 14:12:10.628	2026-05-05 14:46:06.517	2026-05-11 14:12:10.63	181.115.136.51
d317bbef-1917-4fdd-9902-f893c5783b0b	Agent - Principal	ba207eef666d8073f67c8b20c7d6ddf1811471303aceebe9e1c0b8a8708ebfa2	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	t	2026-05-13 17:50:38.093	2026-05-07 22:35:11.357	2026-05-13 17:50:38.094	181.114.108.165
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
e34e3a95-e84d-4036-8662-c7caff31c623	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-06-04T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 14:50:18.378	2026-05-05 14:50:22.307	\N	0	SYNC_USER_FULL	DONE	\N
054127a9-8a38-4ad1-80e7-c5b133ff640a	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-07-04T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 15:00:09.848	2026-05-05 15:00:13.941	\N	0	SYNC_USER_FULL	DONE	\N
a9b48400-d62e-41a0-a8dd-90cd506fa1bf	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-08-03T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 15:00:34.5	2026-05-05 15:00:38.411	\N	0	SYNC_USER_FULL	DONE	\N
7c23d36b-be4e-4dbb-a865-72a42a1986cb	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-09-02T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 19:56:00.752	2026-05-05 19:56:04.715	\N	0	SYNC_USER_FULL	DONE	\N
4d169565-a26e-46e4-9c58-7c646b07028f	{"name": "ALESSANDRO", "userId": "673f225d-16a4-4da3-add9-faad039822e1", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778525953157.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:59:37.237	2026-05-11 18:59:40.936	\N	0	SYNC_USER_FULL	DONE	\N
1909f6e3-e0ad-4c4d-a209-78e64dc95176	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-10-02T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 20:07:25.417	2026-05-05 20:07:28.654	\N	0	SYNC_USER_FULL	DONE	\N
768b436b-1724-4871-b760-18dc5fc4ed26	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-11-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 20:28:36.046	2026-05-05 20:28:39.663	\N	0	SYNC_USER_FULL	DONE	\N
70610dae-47b6-46ad-8e6b-36b6308abd2e	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 20:31:28.694	2026-05-05 20:31:32.555	\N	0	SYNC_USER_FULL	DONE	\N
1b7e6c8b-102a-4aae-a749-8337a1030a28	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:05:06.942	2026-05-06 06:05:10.372	\N	0	SYNC_USER_FULL	DONE	\N
9b67345e-e82d-4942-a16a-2a07e06e4a75	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-07-27T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:22:52.849	2026-05-06 06:22:56.48	\N	0	SYNC_USER_FULL	DONE	\N
4267fbc2-442a-4645-8144-fa5028fe22a2	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:12:46.468	2026-05-05 22:13:14.349	\N	0	SYNC_USER_FULL	DONE	\N
85c397a5-893a-48a4-97ce-631191b7ba34	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:13:00.593	2026-05-05 22:13:16.776	\N	0	SYNC_USER_FULL	DONE	\N
8bdb13f6-ab82-4741-8d02-f4368c81426d	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:19:31.766	2026-05-05 22:20:13.701	\N	0	SYNC_USER_FULL	DONE	\N
06821db8-3d59-4bb9-aa8e-8f84fd03fe13	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:21:40.518	2026-05-05 22:22:14.244	\N	0	SYNC_USER_FULL	DONE	\N
3f273ed1-02f3-445d-8008-12498ba1243d	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-12-01T14:50:18.315Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T14:50:18.315Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-05 22:24:39.706	2026-05-05 22:24:44.065	\N	0	SYNC_USER_FULL	DONE	\N
d91a6e86-b372-46c5-9157-463ae1068c66	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-05-23T04:00:00.000Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 05:48:40.136	2026-05-06 05:49:46.212	\N	0	SYNC_USER_FULL	DONE	\N
c7fabcf8-159e-4c22-b4e5-9a0be8df03d9	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:03:23.445	2026-05-06 06:03:26.966	\N	0	SYNC_USER_FULL	DONE	\N
ea289833-f3ff-4fb4-88d1-3a1f4fb66153	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-11-06T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:57:08.768	2026-05-07 23:57:12.86	\N	0	SYNC_USER_FULL	DONE	\N
0e0e1f4e-d99d-4220-a2d3-fca1e66fa913	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-08-06T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:09:54.964	2026-05-08 00:09:59.094	\N	0	SYNC_USER_FULL	DONE	\N
3bd05472-fc9d-48ed-8c4f-17efe1ec27cf	{"name": "ABDAL RASHID SILVA VILLARRUEL", "userId": "0be16069-145a-4e3b-a50a-34abe7a5d640", "endDate": "2026-08-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778266391762.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:53:30.776	2026-05-08 18:53:35.636	\N	0	SYNC_USER_FULL	DONE	\N
1e108934-1b8c-4e06-89c1-ee0399e8c85f	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-08-06T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:11:59.468	2026-05-08 00:12:03.601	\N	0	SYNC_USER_FULL	DONE	3cd48ba4-03a9-4efb-9c1a-d9418d49e4d6
c89f9ab7-b65e-4d21-85be-943fcfc602da	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-09-25T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 07:08:12.48	2026-05-06 07:08:16.733	\N	0	SYNC_USER_FULL	DONE	\N
c8aaf4c8-3924-496d-98c6-e7facf7f03b3	{"name": "FABRICIO DORADO", "userId": "002bd4b0-9fb9-4c32-a4a3-7d0ecb809ba9", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778266678557.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:58:14.372	2026-05-08 18:58:19.334	\N	0	SYNC_USER_FULL	DONE	\N
58e48597-9718-4467-b41b-28c0b0b654b5	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-09-25T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:56:54.555	2026-05-06 06:56:58.302	\N	0	SYNC_USER_FULL	DONE	\N
44151d6d-da55-4351-9093-3b51c93f86e8	{"name": "Jose Perez", "userId": "4f1ad563-b08b-4f15-bef2-cf1b8c0071df", "endDate": "2026-06-06T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-07 07:09:17.955	2026-05-08 17:46:24.161	\N	0	SYNC_USER_FULL	DONE	\N
b94d2c39-6b74-4f80-8c2e-525d261e5b70	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 19:31:43.601	2026-05-09 19:31:47.491	\N	0	SYNC_USER_FULL	DONE	\N
331d204d-92f0-457c-8395-3f4fba20f2fc	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194385284.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 22:53:21.476	2026-05-07 22:54:03.332	\N	0	SYNC_USER_FULL	DONE	\N
41a4034c-e3ee-4195-8162-21a4a7e690b7	{"name": "ADRIAN MEDRANO", "userId": "bd4692d3-efdc-4abf-9c29-c9f755caf715", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:25:49.539	2026-05-08 00:25:53.376	\N	0	SYNC_USER_FULL	DONE	\N
478c6d5e-aba3-4e0e-8a9d-adafc85e8cfd	{"name": "Antonio Dams", "userId": "4b5a5b43-8414-48d7-a9b5-4491f2f59336", "endDate": "2027-05-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194633989.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 22:58:03.277	2026-05-07 22:58:07.828	\N	0	SYNC_USER_FULL	DONE	\N
334133ac-11cc-4682-97fd-d18afd8fdb88	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778200570391.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:38:58.692	2026-05-08 00:39:02.871	\N	0	SYNC_USER_FULL	DONE	138c5307-77bb-43b6-8f32-06a98a4b0629
4c998436-9d86-4cf3-be09-edb1c6c8ac35	{"name": "Antonio Dams", "userId": "4b5a5b43-8414-48d7-a9b5-4491f2f59336", "endDate": "2027-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194633989.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:00:25.51	2026-05-07 23:00:30.038	\N	0	SYNC_USER_FULL	DONE	5aeac523-0a95-46e4-9910-2e40778bb025
6179aa31-7a7f-4e37-a4e3-f554cc7a4f04	{"name": "EDUARDO DURAN", "userId": "156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:16:24.82	2026-05-07 23:16:28.642	\N	0	SYNC_USER_FULL	DONE	\N
1ff2c7b3-751c-4603-9499-08d28410d6f9	{"name": "EDUARDO DURAN", "userId": "156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d", "endDate": "2026-07-08T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:16:47.893	2026-05-07 23:16:51.745	\N	0	SYNC_USER_FULL	DONE	61248ce8-03d7-4b5f-ad50-a4ff4b09b0e3
9226fae6-d703-45c2-96e4-dfb5eaac4a6b	{"name": "EDUARDO DURAN", "userId": "156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d", "endDate": "2026-07-08T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778197677040.jpg", "startDate": "2026-05-07T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:49:06.173	2026-05-07 23:49:11.102	\N	0	SYNC_USER_FULL	DONE	\N
a21eeaf9-902f-484b-93e9-9aec5ea9e4ab	{"name": "HAROLD IBAÑEZ", "userId": "1faf3a07-9b37-4f07-9f77-e33fbf855ed6", "endDate": "2026-08-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778198173671.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-07 23:56:36.183	2026-05-07 23:56:41.113	\N	0	SYNC_USER_FULL	DONE	\N
faa8016e-68fc-49ac-ac31-fc0a14773070	{"name": "ARACELY WENDY", "userId": "e622b29d-67f1-47f9-b22c-9278e39d7241", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:05:02.02	2026-05-11 23:05:05.96	\N	0	SYNC_USER_FULL	DONE	\N
6aa2f1ee-5929-46f7-a5dc-d36b2a19817f	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201314416.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 00:49:07.508	2026-05-08 00:49:11.891	\N	0	SYNC_USER_FULL	DONE	\N
58f36029-5511-4b4d-9aab-97789a86c4b3	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-08-26T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-04T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-06 06:52:35.171	2026-05-06 06:52:38.761	\N	0	SYNC_USER_FULL	DONE	\N
5f2033c7-7718-434f-8e1b-bd1c687e66de	{"name": "JHON GOMEZ", "userId": "6a35612f-c381-4125-928c-378dbe431e69", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 13:11:21.767	2026-05-08 17:37:48.035	\N	0	SYNC_USER_FULL	DONE	\N
779bd08a-988b-456c-b9e3-d3c6afa5f0f4	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194385284.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:39:09.585	2026-05-08 17:39:14.083	\N	0	SYNC_USER_FULL	DONE	\N
8f316102-9920-4bf4-aefc-f47d82645c76	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778194385284.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:40:04.164	2026-05-08 17:40:08.553	\N	0	SYNC_USER_FULL	DONE	\N
e95e554e-3f03-4465-a996-d7e31da3678a	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201314416.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:40:33.671	2026-05-08 17:40:38.114	\N	0	SYNC_USER_FULL	DONE	\N
0e70aa89-42c7-4728-af86-a8cb8510237f	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778262176825.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:42:59.552	2026-05-08 17:43:03.568	\N	0	SYNC_USER_FULL	DONE	\N
3bfa045c-c921-4aaf-9fbe-b5fb2d9305e7	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778262176825.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:44:13.245	2026-05-08 17:44:17.458	\N	0	SYNC_USER_FULL	DONE	\N
ceb447ea-5a63-4159-9adc-37572e0403dd	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778262176825.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:52:35.962	2026-05-08 17:52:39.2	\N	0	SYNC_USER_FULL	DONE	\N
e1f28fd8-ca62-494f-be88-df3c4e79f2ac	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778262830739.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:53:52.771	2026-05-08 17:53:56.794	\N	0	SYNC_USER_FULL	DONE	\N
7afd23b6-bfb4-431c-82f2-061ca875854f	{"name": "PABLO VERA", "userId": "22b1f9cc-4a9d-48ff-821d-da9d7a111974", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778263274969.jpg", "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:02:19.169	2026-05-08 18:02:23.718	\N	0	SYNC_USER_FULL	DONE	\N
b39bf164-3b3b-4d54-9c68-66240013e3a7	{"name": "ADRIAN MEDRANO", "userId": "bd4692d3-efdc-4abf-9c29-c9f755caf715", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778202363079.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:19:04.216	2026-05-08 18:19:08.981	\N	0	SYNC_USER_FULL	DONE	\N
beb0a2b5-75fb-4b23-9371-e50c190e8963	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201455792.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:19:28.352	2026-05-08 18:19:32.781	\N	0	SYNC_USER_FULL	DONE	\N
18fe7205-4aaf-4620-bb9c-2fee91d5e43b	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201314416.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:19:54.711	2026-05-08 18:19:58.972	\N	0	SYNC_USER_FULL	DONE	\N
f6c5fa00-3f1a-4098-93e1-eb54fb077d34	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777922503018.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:21:39.727	2026-05-08 18:21:44.655	\N	0	SYNC_USER_FULL	DONE	\N
29784fa6-8921-47cb-9648-aadd739917b3	{"name": "GUSTAVO LEON", "userId": "b490945f-208c-4b2a-881b-35ffd0eded6d", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778264893721.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:28:57.391	2026-05-08 18:29:02.029	\N	0	SYNC_USER_FULL	DONE	\N
ec1ebb83-3c34-448e-a02d-9e7a23eb3d5c	{"name": "Eduardo El Profe", "userId": "5564e62d-031a-4094-8e7b-ca2e5f28f481", "endDate": "2027-04-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778262176825.jpg", "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 17:52:11.518	\N	\N	0	SYNC_USER_FULL	DONE	\N
a8b9ada1-65d7-4c76-aab8-914dde32e684	{"name": "CARLOS CHAVEZ", "userId": "f6c321cf-011b-4e88-8ed0-ce56b5851cdb", "endDate": "2026-05-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 01:27:06.412	2026-05-12 01:27:10.441	\N	0	SYNC_USER_FULL	DONE	\N
fc3d02ac-a599-4204-bca1-fa23e9a03431	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201314416.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:34:39.389	2026-05-08 18:34:43.812	\N	0	SYNC_USER_FULL	DONE	\N
8b977b67-36c7-4dd5-91a4-4b34d8ca69d0	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201455792.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:35:00.354	2026-05-08 18:35:04.654	\N	0	SYNC_USER_FULL	DONE	\N
1f6cdae9-7095-41dd-b8a0-dbebc12765d2	{"name": "FABRICIO DORADO", "userId": "002bd4b0-9fb9-4c32-a4a3-7d0ecb809ba9", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778266678557.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:58:14.384	2026-05-08 18:58:21.894	\N	0	SYNC_USER_FULL	DONE	\N
1e0337e0-dc92-4a9a-9b66-456b60df9198	{"name": "JESSICA HURTADO", "userId": "4d64fb5f-71c6-4b3e-8c84-16d3322ec84c", "endDate": "2027-05-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778265516027.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:39:22.348	2026-05-08 18:39:27.176	\N	0	SYNC_USER_FULL	DONE	\N
f00c90ab-bb9b-4c25-9a59-f50e62367769	{"name": "JESSICA HURTADO", "userId": "4d64fb5f-71c6-4b3e-8c84-16d3322ec84c", "endDate": "2027-05-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778265516027.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:39:28.391	2026-05-08 18:39:32.526	\N	0	SYNC_USER_FULL	DONE	\N
bb01f015-61e8-4ab4-8916-56924d0cb6b9	{"name": "CARLA CECILIA", "userId": "6ee61762-c0c8-4c6c-b8c5-fbdb9ce48a13", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778267467149.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 19:11:24.048	2026-05-08 19:11:28.861	\N	0	SYNC_USER_FULL	DONE	\N
6e169b4a-4d83-4d54-9251-34fc9fcd3309	{"name": "Juan Perez", "userId": "d07fe5fa-18b1-41cf-b784-d5656a602a7e", "endDate": "2026-06-06T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-07 07:35:30.872	2026-05-08 17:46:26.805	\N	0	SYNC_USER_FULL	DONE	\N
993f4634-0d84-40ef-8658-f03cb2a66419	{"name": "JESSICA HURTADO", "userId": "4d64fb5f-71c6-4b3e-8c84-16d3322ec84c", "endDate": "2027-05-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778265516027.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:42:44.859	2026-05-08 18:42:48.826	\N	0	SYNC_USER_FULL	DONE	\N
ac772f08-ecc5-4040-a67a-9f752896e566	{"name": "BRUNO MANSILLA", "userId": "cad0d165-8aee-4e43-9cbb-8627fd3b600e", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778265867010.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:44:48.865	2026-05-08 18:44:53.358	\N	0	SYNC_USER_FULL	DONE	\N
ee8e937f-3baa-4e75-9e45-e7e1f0981bd5	{"name": "ABIGAIL AVALOS", "userId": "9d38d042-2c21-47ba-a498-6485e131b736", "endDate": "2026-06-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 20:42:27.276	2026-05-08 20:42:31.183	\N	0	SYNC_USER_FULL	DONE	\N
b32a77d5-e271-4039-a586-cf91fc8b6b0d	{"name": "BRUNO MANSILLA", "userId": "cad0d165-8aee-4e43-9cbb-8627fd3b600e", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778265867010.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:44:53.603	2026-05-08 18:44:56.809	\N	0	SYNC_USER_FULL	DONE	\N
274c02c4-8221-4891-97fa-cd7f5c477105	{"name": "ABRAHAM PERALTA", "userId": "7cef75cf-7a5b-4409-ba5a-21b7fe20f390", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 20:47:11.13	2026-05-08 20:47:14.582	\N	0	SYNC_USER_FULL	DONE	\N
79e463d3-e03a-4e57-a931-dd957debc56a	{"name": "ELVIS TOLA", "userId": "9d137b31-1c45-4940-929b-38a942ee224f", "endDate": "2027-04-09T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778266215461.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 18:50:37.84	2026-05-08 18:50:43.047	\N	0	SYNC_USER_FULL	DONE	\N
b3962575-b803-473f-b5b4-27ac86ff683a	{"name": "RENATO TERRAZAS", "userId": "6051cd59-bfc0-4276-921a-a60835f6547a", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 20:55:36.074	2026-05-08 20:55:39.969	\N	0	SYNC_USER_FULL	DONE	\N
020793f7-fb3b-4abe-b3d1-e0a9140c82c0	{"name": "RENATO TERRAZAS", "userId": "6051cd59-bfc0-4276-921a-a60835f6547a", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778273784094.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 20:56:44.293	2026-05-08 20:56:48.679	\N	0	SYNC_USER_FULL	DONE	\N
136ad815-f2ee-4349-88db-b9c621cd543a	{"name": "RENATO TERRAZAS", "userId": "6051cd59-bfc0-4276-921a-a60835f6547a", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778273784094.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 20:57:00.397	2026-05-08 20:57:04.444	\N	0	SYNC_USER_FULL	DONE	\N
b2b48323-56cc-4665-bd9f-e0ba80b4894b	{"name": "RENATO TERRAZAS", "userId": "6051cd59-bfc0-4276-921a-a60835f6547a", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778273784094.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 20:57:30.36	2026-05-08 20:57:34.678	\N	0	SYNC_USER_FULL	DONE	\N
f64037bd-0b09-42ec-9c7d-ef23f51f680f	{"name": "RENATO TERRAZAS", "userId": "6051cd59-bfc0-4276-921a-a60835f6547a", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778273784094.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 20:58:33.041	2026-05-08 20:58:37.09	\N	0	SYNC_USER_FULL	DONE	\N
6629659e-22eb-49a1-b5fd-a09c4c08d88d	{"name": "ARACELY WENDY", "userId": "e622b29d-67f1-47f9-b22c-9278e39d7241", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:06:08.161	2026-05-11 23:06:11.679	\N	0	SYNC_USER_FULL	DONE	\N
387dfdf1-f58a-44ea-9cd8-c6d925952424	{"name": "RENATO TERRAZAS", "userId": "6051cd59-bfc0-4276-921a-a60835f6547a", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778273994659.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:00:00.409	2026-05-08 21:00:05.035	\N	0	SYNC_USER_FULL	DONE	\N
685211ad-860e-4a4b-9805-54c1d8d90c8d	{"name": "ADRIANA", "userId": "51a3c33a-fd43-4b8e-a7da-ffd12a391655", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:03:41.668	2026-05-08 21:03:45.49	\N	0	SYNC_USER_FULL	DONE	\N
bcc06bc9-6da0-4e2a-95fd-07b39da7003c	{"name": "Emerson  Chuve", "userId": "f259ee60-7a93-4e2c-ae61-7c4cf6215575", "endDate": "2026-05-09T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778274369318.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:07:27.838	2026-05-08 21:07:32.619	\N	0	SYNC_USER_FULL	DONE	ca135ba3-6a7e-485d-b877-1a3dd30941fd
1b58fc55-3189-4757-acfe-89356693fa8b	{"name": "ANDREA OROPEZA", "userId": "4f0db97a-5fec-4ea1-b80a-5eba4712134f", "endDate": "2026-08-09T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778332299620.jpg", "startDate": "2026-05-09T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 13:12:45.104	2026-05-09 17:46:33.665	\N	0	SYNC_USER_FULL	DONE	\N
85f27df8-201e-4680-bd8b-3e0f04e52cac	{"name": "ADRIANA CHAVEZ", "userId": "6925106d-aaa5-4c51-86ac-1322bd50de8e", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:12:14.642	2026-05-08 21:12:18.48	\N	0	SYNC_USER_FULL	DONE	\N
f942989b-7cad-4fe3-866b-cea6de8c4813	{"name": "ANDREA OROPEZA", "userId": "4f0db97a-5fec-4ea1-b80a-5eba4712134f", "endDate": "2026-08-09T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778332299620.jpg", "startDate": "2026-05-09T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 14:15:47.289	2026-05-09 17:46:36.378	\N	0	SYNC_USER_FULL	DONE	\N
d5358cd0-e3c6-43ad-a527-b33dd52596fa	{"name": "FREDDY ARABE", "userId": "dd308e7c-278f-4b29-be5e-51bde9d3f51e", "endDate": "2026-06-09T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778336458039.jpg", "startDate": "2026-05-09T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 15:29:25.396	2026-05-09 17:46:53.581	\N	0	SYNC_USER_FULL	DONE	\N
d49b83b1-ce5f-4f3e-a82c-ac4bba4ef583	{"name": "ADRIANA ZABALA", "userId": "29e13afe-9a13-44d7-a572-aafcfef194f8", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:13:37.909	2026-05-08 21:13:41.746	\N	0	SYNC_USER_FULL	DONE	\N
f9f1d575-9847-4949-9c5f-c3e98289c679	{"name": "ALAN GARCIA", "userId": "c693773e-60f2-4f62-820d-af9806295a4c", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:15:22.343	2026-05-08 21:15:26.109	\N	0	SYNC_USER_FULL	DONE	\N
19f658b0-1d9b-486a-8c23-1e27ceeaa881	{"name": "ALEXANDER ROMA", "userId": "860285e5-dacc-4755-8c51-a572c5acce68", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:06:19.109	2026-05-11 15:06:23.266	\N	0	SYNC_USER_FULL	DONE	\N
c8eca49c-cae0-41ed-930d-b28bc87b05cf	{"name": "ALCIDES DREW", "userId": "42297e10-37c8-4426-9aa8-c2d958d0a622", "endDate": "2027-01-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:16:48.802	2026-05-08 21:16:52.677	\N	0	SYNC_USER_FULL	DONE	\N
b5c2161d-ce7f-4974-ab8b-e29de2998585	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:22:13.428	2026-05-08 21:22:16.88	\N	0	SYNC_USER_FULL	DONE	\N
637cff8d-b9ba-4d94-979a-cdb9444c0d3e	{"name": "ALEXANDRA CHURATA", "userId": "8a0434a1-0c0c-45ca-9f4e-bcc0f48a1f68", "endDate": "2026-05-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:11:52.682	2026-05-11 15:12:07.873	\N	0	SYNC_USER_FULL	DONE	\N
d23c6832-8f58-45be-89b0-22c4a458817c	{"name": "ALEJANDRO", "userId": "7efb284c-a286-4338-81fb-e39a36939875", "endDate": "2026-07-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:23:48.429	2026-05-08 21:23:52.266	\N	0	SYNC_USER_FULL	DONE	\N
5e1d16f2-5704-409a-bd91-832fa70c7ec1	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778501830047.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:14:53.396	2026-05-11 15:15:20.047	\N	0	SYNC_USER_FULL	DONE	\N
186af7d7-044c-4851-a190-398a0de1e0e3	{"name": "ALESSANDRO", "userId": "673f225d-16a4-4da3-add9-faad039822e1", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:25:14.874	2026-05-08 21:25:18.651	\N	0	SYNC_USER_FULL	DONE	\N
3347ee83-73e0-4f05-b768-ed0c8201e332	{"name": "ALEXANDER GUTIERREZ", "userId": "17c4abf8-339c-4a77-a5e1-3b66e045bd7c", "endDate": "2026-05-16T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:28:01.613	2026-05-08 21:28:05.289	\N	0	SYNC_USER_FULL	DONE	\N
6c534b69-7b49-4d8a-9b0b-f536e045dabe	{"name": "ADRIANA", "userId": "51a3c33a-fd43-4b8e-a7da-ffd12a391655", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778275915302.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 21:32:01.886	2026-05-08 21:32:06.274	\N	0	SYNC_USER_FULL	DONE	\N
6f05d974-a156-4294-becc-331bd9622a79	{"name": "ESTEBAN ARRON", "userId": "cb882c3e-8c58-4b6d-95b1-29d050a75abe", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778278195973.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-08 22:10:46.105	2026-05-08 22:10:50.451	\N	0	SYNC_USER_FULL	DONE	7ff50cc3-591e-415b-9847-ee73f4b81b05
8885a6d0-9f06-44b9-98ae-4c7a740d93d8	{"name": "JOSE SANDOVAL", "userId": "b33f540c-7e61-486b-8e0e-1069b9b388b3", "endDate": "2026-05-17T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778525166497.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:46:26.009	2026-05-11 18:46:43.62	\N	0	SYNC_USER_FULL	DONE	\N
be5facfe-c6f1-4bf4-80a9-ee57269e3931	{"name": "JOSE SANDOVAL", "userId": "b33f540c-7e61-486b-8e0e-1069b9b388b3", "endDate": "2026-05-17T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778525166497.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:46:30.134	2026-05-11 18:46:46.718	\N	0	SYNC_USER_FULL	DONE	\N
448fd85d-99e7-49b0-9c22-89a75577b79c	{"name": "DANNERSON", "userId": "46b3376a-973a-454b-9347-52808613a768", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:01:13.508	2026-05-12 13:01:17.367	\N	0	SYNC_USER_FULL	DONE	\N
b39b0fdd-794d-4845-87cd-32c1c7ed9891	{"name": "FREDDY ARABE", "userId": "dd308e7c-278f-4b29-be5e-51bde9d3f51e", "endDate": "2026-06-09T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778336458039.jpg", "startDate": "2026-05-09T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 14:21:20.481	2026-05-09 17:46:39.726	\N	0	SYNC_USER_FULL	DONE	\N
6cfa1ab1-c9ec-47ad-867b-02fa050b6627	{"name": "ALEJANDRO", "userId": "7efb284c-a286-4338-81fb-e39a36939875", "endDate": "2026-07-23T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778339912791.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 15:20:03.5	2026-05-09 17:46:42.364	\N	0	SYNC_USER_FULL	DONE	\N
c01f1174-60f6-46b7-9e44-26f5a890deaa	{"name": "ALEJANDRO", "userId": "7efb284c-a286-4338-81fb-e39a36939875", "endDate": "2026-07-23T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778339912791.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 15:20:52.878	2026-05-09 17:46:45.008	\N	0	SYNC_USER_FULL	DONE	\N
819a17a8-bfc6-43b3-86f9-f42784db98f9	{"name": "CARLA BARBA", "userId": "2304762b-0f36-411d-a173-7fd57932e0ce", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778340156812.jpg", "startDate": "2026-05-09T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 15:22:57.189	2026-05-09 17:46:48.482	\N	0	SYNC_USER_FULL	DONE	\N
61365098-3ca9-4c96-bb10-5eede139899a	{"name": "CARLA BARBA", "userId": "2304762b-0f36-411d-a173-7fd57932e0ce", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778340156812.jpg", "startDate": "2026-05-09T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-09 15:23:02.258	2026-05-09 17:46:51.117	\N	0	SYNC_USER_FULL	DONE	\N
a9a0ed46-2d3c-443c-bd11-35357e3a47a0	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-05-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-11 07:07:55.127	2026-05-11 07:10:10.285	\N	1	SYNC_USER_FULL	DONE	\N
eaf8439b-04e1-48a6-9db8-c6774e1898f4	{"name": "Sergio Olmos", "userId": "510a43a7-4384-420e-8a21-e52f34a1fe6d", "endDate": "2026-05-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1777992575936.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-11 07:10:06.098	2026-05-11 07:10:13.095	\N	0	SYNC_USER_FULL	DONE	\N
774f9ce1-a046-42b6-b673-07b873afe1aa	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778355189075.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 12:12:43.29	2026-05-11 12:13:09.337	\N	0	SYNC_USER_FULL	DONE	\N
e01c9113-8cd9-4765-ae94-a4023daf900e	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778501830047.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 12:19:42.252	2026-05-11 12:19:46.638	\N	0	SYNC_USER_FULL	DONE	\N
6aca2ab6-b53e-4bf7-b7a2-3821251a0394	{"name": "ALCIDES DREW", "userId": "42297e10-37c8-4426-9aa8-c2d958d0a622", "endDate": "2027-01-02T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778503802572.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 12:50:19.07	2026-05-11 12:50:23.772	\N	0	SYNC_USER_FULL	DONE	\N
b106c96e-804d-4fd4-846f-bc907e59c725	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778501830047.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:16:08.965	2026-05-11 15:16:24.816	\N	0	SYNC_USER_FULL	DONE	\N
acfbd0b5-1c2d-4efb-a8b4-a119ff969686	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778512662840.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:17:48.793	2026-05-11 15:17:54.506	\N	0	SYNC_USER_FULL	DONE	\N
bad84d5e-7bd1-4dcd-a1f8-b5365340cfb0	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778512796744.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:19:59.316	2026-05-11 15:21:06.396	\N	0	SYNC_USER_FULL	DONE	\N
41e636e6-41d1-4b86-ab11-f69fec24489d	{"name": "ALDAIR GALARZA", "userId": "573da3d3-8cc9-4505-9a79-9ad5e4e797e7", "endDate": "2026-06-01T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778512796744.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:21:12.003	2026-05-11 15:21:19.038	\N	0	SYNC_USER_FULL	DONE	\N
8956af62-6997-45a3-ba7e-bfed36b93a8f	{"name": "sebastian hurtado", "userId": "6aa91ec4-6251-489b-a4fd-c34cfccefad7", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778513494861.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:39:14.703	2026-05-11 15:39:39.21	\N	0	SYNC_USER_FULL	DONE	73de0be4-deb9-4b84-9e48-8e377d23fca3
51836b66-da73-453d-a74d-691e56966054	{"name": "ALEXANDRE", "userId": "6b2da3b2-7c71-4a8f-878a-8e50ab527eff", "endDate": "2027-01-01T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:50:30.888	2026-05-11 15:51:02.569	\N	0	SYNC_USER_FULL	DONE	\N
fbe64ada-8e60-495e-89e2-c0f1e0961fa1	{"name": "ALEXI SUAREZ", "userId": "965ab34f-78f7-4d62-8270-d34561994b34", "endDate": "2026-07-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 15:54:18.988	2026-05-11 15:54:33.997	\N	0	SYNC_USER_FULL	DONE	\N
4469f742-88cd-4f48-ac70-a596b8c1b080	{"name": "Alisson Borja", "userId": "9c776bb9-61c5-4ee0-9614-5be0fb97d317", "endDate": "2026-08-09T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 16:02:18.742	2026-05-11 16:02:22.674	\N	0	SYNC_USER_FULL	DONE	4046278e-2488-4853-a218-9ed3a4205994
62e38853-9476-4298-8749-1e399292cfa8	{"name": "MILENKA PEDRAZA", "userId": "0544929b-30f1-4d09-9756-881ff559e881", "endDate": "2026-05-31T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778525645088.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:54:23.005	2026-05-11 18:54:38.924	\N	0	SYNC_USER_FULL	DONE	\N
964489dd-63ab-49d7-835c-a9613bae23df	{"name": "Alicey paniagua", "userId": "e88ca8d5-16cf-4501-99af-6501f49ff7a8", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 16:04:42.335	2026-05-11 16:04:49.452	\N	0	SYNC_USER_FULL	DONE	87f2d771-7f57-45da-a7cb-03ac4f077521
88ec97a5-1720-47cd-8b74-f54c54b91ae0	{"name": "MILENKA PEDRAZA", "userId": "0544929b-30f1-4d09-9756-881ff559e881", "endDate": "2026-05-31T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778525645088.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:54:25.505	2026-05-11 18:54:41.822	\N	0	SYNC_USER_FULL	DONE	\N
4ea9cf4f-0349-430b-8807-ad76ecbbfaea	{"name": "Gabriel Soza", "userId": "4f91dff1-41bf-4b30-b9e7-b5f72e5e875c", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 16:06:49.065	2026-05-11 16:06:52.91	\N	0	SYNC_USER_FULL	DONE	4bcdc5a1-b23f-41fe-8128-6ec7b6782417
2c0e073e-8420-48f9-9ba6-e48e225e8174	{"name": "MILENKA PEDRAZA", "userId": "0544929b-30f1-4d09-9756-881ff559e881", "endDate": "2026-05-31T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778525645088.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:54:39.694	2026-05-11 18:54:43.468	\N	0	SYNC_USER_FULL	DONE	\N
11cfd823-1596-4420-9d38-94f36bd837e1	{"name": "Dayana Ypamo", "userId": "a2aa3f8c-d134-48a9-ae05-6bab8b5880b8", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 16:09:13.43	2026-05-11 16:09:28.682	\N	0	SYNC_USER_FULL	DONE	20c9167b-854c-4902-abc4-20b3d8dd0909
7385fb68-ccc3-4b62-825b-364560726c14	{"name": "ALESSANDRO", "userId": "673f225d-16a4-4da3-add9-faad039822e1", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778525953157.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:59:17.152	2026-05-11 18:59:33.201	\N	0	SYNC_USER_FULL	DONE	\N
b8ba3502-bf53-4124-96d3-e044a7659349	{"name": "ABIGAIL AVALOS", "userId": "9d38d042-2c21-47ba-a498-6485e131b736", "endDate": "2026-06-02T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778515820476.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 16:10:41.258	2026-05-11 16:10:56.623	\N	0	SYNC_USER_FULL	DONE	\N
e25b093e-68f7-46f4-b7d9-3e419fd9013f	{"name": "ALICIA SORIA", "userId": "9bec239a-8ddf-4cfb-ad5b-1754bd77f92e", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778529364872.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 19:56:09.14	2026-05-11 19:56:14.259	\N	0	SYNC_USER_FULL	DONE	\N
ac4c4048-b446-4ea6-882d-df5c44f6aed3	{"name": "ABRAHAM PERALTA", "userId": "7cef75cf-7a5b-4409-ba5a-21b7fe20f390", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778532120369.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 20:42:03.855	2026-05-11 20:42:08.805	\N	0	SYNC_USER_FULL	DONE	\N
9bced98b-f2a7-4197-bb6e-e5fb9122f2da	{"name": "Dayana Ypamo", "userId": "a2aa3f8c-d134-48a9-ae05-6bab8b5880b8", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778515958128.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 16:12:51.904	2026-05-11 16:13:03.6	\N	0	SYNC_USER_FULL	DONE	\N
5dc46ff5-6c72-4cbd-9413-909610f7ccdd	{"name": "ALFREDO PINTO", "userId": "228e67db-3041-48eb-9a81-b759bd96c248", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 16:33:20.455	2026-05-11 16:33:35.538	\N	0	SYNC_USER_FULL	DONE	\N
fcbf8abf-0dc2-4203-9429-8f2762827475	{"name": "ALICIA SORIA", "userId": "9bec239a-8ddf-4cfb-ad5b-1754bd77f92e", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 17:07:54.105	2026-05-11 17:07:57.557	\N	0	SYNC_USER_FULL	DONE	\N
b323f439-eccf-4630-9bd5-85fb04834889	{"name": "Cristian Ortiz", "userId": "d02259bf-0b2d-4a79-bd29-1d892299585a", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778522224485.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 17:57:23.514	2026-05-11 17:57:39.014	\N	0	SYNC_USER_FULL	DONE	bf606de6-2e35-46cd-bfa9-0c197f20bd87
5b8eb562-1988-4fed-98d5-9ca1eb2f0f93	{"name": "JUAN MANUEL", "userId": "f74330b4-36a0-47a9-b192-d7bee532f0d5", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778524278800.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:31:42.306	2026-05-11 18:31:49.848	\N	0	SYNC_USER_FULL	DONE	\N
9b14c677-6ec7-4ea1-9f37-66c81c5afd4a	{"name": "JUAN MANUEL", "userId": "f74330b4-36a0-47a9-b192-d7bee532f0d5", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778524278800.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 18:31:47.653	2026-05-11 18:31:51.311	\N	0	SYNC_USER_FULL	DONE	\N
64248295-ba65-49b9-ae8c-758e5fcebecf	{"name": "ARIANA AÑEZ", "userId": "af2c4ffd-5299-41b7-9250-672184d7b730", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:07:11.987	2026-05-11 23:07:15.793	\N	0	SYNC_USER_FULL	DONE	\N
459720a3-e59c-4e65-a836-bdcbf0284594	{"name": "ALBERTO ALUB", "userId": "a0b074a7-4876-44f6-8246-2c7ce9c06e18", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778532205647.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 20:43:54.868	2026-05-11 20:43:59.907	\N	0	SYNC_USER_FULL	DONE	\N
7165cbd5-769e-490d-81cb-91124ff50600	{"name": "ALBERTO ALUB", "userId": "a0b074a7-4876-44f6-8246-2c7ce9c06e18", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778532205647.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 20:44:03.148	2026-05-11 20:44:18.542	\N	0	SYNC_USER_FULL	DONE	\N
a7340664-ec6a-4df3-a14c-45dbbaf9cf03	{"name": "JORGE RUIZ", "userId": "395d7599-523a-4a6d-9b8d-f5023873ef25", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778534778216.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:26:52.187	2026-05-11 21:26:57.023	\N	0	SYNC_USER_FULL	DONE	\N
8e23e879-3505-4d74-b0ea-5c63eb6c99ca	{"name": "JORGE RUIZ", "userId": "395d7599-523a-4a6d-9b8d-f5023873ef25", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778534778216.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:26:54.808	2026-05-11 21:26:58.537	\N	0	SYNC_USER_FULL	DONE	\N
72d6363a-6713-4864-8e94-47af458d6fa9	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201455792.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:39:50.229	2026-05-11 21:39:54.761	\N	0	SYNC_USER_FULL	DONE	\N
a425366c-7f8a-4225-9181-ceaf891a5202	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778535645646.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:40:48.253	2026-05-11 21:41:03.514	\N	0	SYNC_USER_FULL	DONE	\N
20863f58-1f70-4a27-b985-4f5fc2db67f5	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778535645646.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:41:04.311	2026-05-11 21:41:07.998	\N	0	SYNC_USER_FULL	DONE	\N
989a388f-7395-4c50-9cf8-e41e35b1933e	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778535645646.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:41:58.592	2026-05-11 21:42:13.864	\N	0	SYNC_USER_FULL	DONE	\N
fda40bde-fd4a-40ba-b225-b34e186914de	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778535645646.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:42:05.416	2026-05-11 21:42:16.714	\N	0	SYNC_USER_FULL	DONE	\N
b836e8b4-6687-4b7b-868a-d9afa70df338	{"name": "ALEXANDER ROMA", "userId": "860285e5-dacc-4755-8c51-a572c5acce68", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:43:06.972	2026-05-11 21:43:10.961	\N	0	SYNC_USER_FULL	DONE	\N
bf17d3d6-9776-4c7b-af7d-a4521bc242c5	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778535645646.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 21:43:39.757	2026-05-11 21:43:43.315	\N	0	SYNC_USER_FULL	DONE	\N
1f6be530-f809-4ea3-8fe3-8afb2b5ac194	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778535645646.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:05:51.918	2026-05-11 22:05:56.144	\N	0	SYNC_USER_FULL	DONE	\N
76123e48-e44f-42f7-9b6d-fde4b8b67858	{"name": "RICARDO BAZAN", "userId": "3b4fdc49-f12c-4945-8797-69a0336d4beb", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778537431312.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:10:57.517	2026-05-11 22:11:12.848	\N	0	SYNC_USER_FULL	DONE	090379ee-0c21-4ff7-852b-a60bc20b222d
81c2c0e0-0510-47aa-9a84-f70079812cc3	{"name": "BRANDON DORADO", "userId": "1c82b0ed-7597-402e-9b5f-abfcc3a2cc48", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778537524759.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:12:15.533	2026-05-11 22:12:30.973	\N	0	SYNC_USER_FULL	DONE	27033c47-06d4-4af7-aa4b-dbb5cd8433a8
b0d92d1a-8385-48a7-9d05-5cd751949610	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778535645646.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:14:32.935	2026-05-11 22:14:41.476	\N	0	SYNC_USER_FULL	DONE	\N
785eb1c7-bc68-4ccb-92c9-c27056975933	{"name": "ALEXANDER LOPEZ", "userId": "de09cfdb-ea36-47be-ba0f-e121fbfa49a6", "endDate": "2026-06-07T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778537850540.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:17:34.832	2026-05-11 22:17:39.715	\N	0	SYNC_USER_FULL	DONE	\N
49e1bf64-967d-4e2b-9a33-1cd03b9e3d65	{"name": "SANTIAGO GARNICA", "userId": "2ef332b0-b371-4564-997d-96f1212cded6", "endDate": "2026-08-09T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778538191871.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:23:52.172	2026-05-11 22:23:56.781	\N	0	SYNC_USER_FULL	DONE	ac134f26-fc20-4788-ac3f-72715623536d
7d7fa6c9-7ae8-417c-8a68-a074a671a920	{"name": "HERLAN HURTADO", "userId": "2d125526-281c-4172-a595-38ecae59bb50", "endDate": "2027-03-17T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:52:19.068	2026-05-12 17:52:22.81	\N	0	SYNC_USER_FULL	DONE	\N
4fb8a0d7-b095-461c-93ee-93897b237653	{"name": "JOAQUIN GARNICA", "userId": "053c65a6-8814-4d31-a97e-59472a996abe", "endDate": "2026-08-09T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778538292035.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:25:23.232	2026-05-11 22:25:38.944	\N	0	SYNC_USER_FULL	DONE	dafc529f-47c1-48ea-8620-af9045bbb857
b3fedf47-f600-401e-bbf7-49264b65e0e5	{"name": "KENDRA PEREIRA", "userId": "60c3a803-bf7b-4f6c-8600-08c957cd1793", "endDate": "2026-05-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778539162254.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:39:35.757	2026-05-11 22:39:40.465	\N	0	SYNC_USER_FULL	DONE	\N
3382f344-dc90-4e35-af55-9725d50b070c	{"name": "ARIANNE DREW", "userId": "e6b04300-5976-439f-ab5b-84cd4135d36d", "endDate": "2026-12-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:08:24.078	2026-05-11 23:08:30.516	\N	0	SYNC_USER_FULL	DONE	\N
9166567b-5733-4bde-b5ef-097ba4d77230	{"name": "ARIEL", "userId": "7a1cad64-053e-4635-9fd9-f75615de6d1e", "endDate": "2026-06-10T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:09:33.555	2026-05-11 23:09:37.595	\N	0	SYNC_USER_FULL	DONE	\N
5398e7be-18bb-4f75-b831-0670f47c15ba	{"name": "OSCAR CARDONA", "userId": "93ddf524-4617-4d45-b378-17df5ce50980", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778539639561.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:47:40.412	2026-05-11 22:47:45.304	\N	0	SYNC_USER_FULL	DONE	\N
6196f3a0-6f83-4d54-bb39-843b5d429344	{"name": "OSCAR CARDONA", "userId": "93ddf524-4617-4d45-b378-17df5ce50980", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778539639561.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:47:42.847	2026-05-11 22:47:46.726	\N	0	SYNC_USER_FULL	DONE	\N
48f57f5a-ba5c-479e-b975-f4d6dd380d9b	{"name": "ANA NOGALES", "userId": "dc32d4c5-5afc-4af0-8783-960223918223", "endDate": "2026-05-15T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778541000935.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:10:02.508	2026-05-11 23:10:08.043	\N	0	SYNC_USER_FULL	DONE	\N
233fc340-34f7-43df-802f-8a9ac0708063	{"name": "INGRIS ROSSEL", "userId": "573740dc-40e6-4155-827c-3b98ecc06c01", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778539715491.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:49:01.95	2026-05-11 22:49:06.708	\N	0	SYNC_USER_FULL	DONE	\N
d1d04358-5439-4689-b514-da6b4ce5febf	{"name": "INGRIS ROSSEL", "userId": "573740dc-40e6-4155-827c-3b98ecc06c01", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778539715491.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:49:05.714	2026-05-11 22:49:08.92	\N	0	SYNC_USER_FULL	DONE	\N
f8c42614-57cf-48ec-b603-db0942017240	{"name": "ALEXANDER ROMA", "userId": "860285e5-dacc-4755-8c51-a572c5acce68", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778541311888.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:15:23.538	2026-05-11 23:15:28.64	\N	0	SYNC_USER_FULL	DONE	\N
177d0ba9-4cf8-459f-90b3-7f1d013d4760	{"name": "ALVARO PEÑARANDA", "userId": "f97f2614-1a25-4055-af4b-bd661030983f", "endDate": "2026-09-22T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:52:22.409	2026-05-11 22:52:25.864	\N	0	SYNC_USER_FULL	DONE	\N
3599c7c6-4895-45bb-b572-cf70aa0e450d	{"name": "BEATRIZ SOLIZ", "userId": "59d0f632-36d6-4fcd-b38b-4f39b456b5ba", "endDate": "2026-12-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:20:34.55	2026-05-11 23:20:38.392	\N	0	SYNC_USER_FULL	DONE	\N
15dc4372-8c92-4e56-8193-263f259812bd	{"name": "SAMANTA", "userId": "19cbef6f-740f-4538-b415-d2022ba8b045", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778541916337.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:25:50.89	2026-05-11 23:26:15.77	\N	0	SYNC_USER_FULL	DONE	\N
d258db3f-50e4-4632-a1dd-cb5ba4e2a57b	{"name": "BELLA", "userId": "eacedabb-27b6-459f-a242-10e96f7eea0d", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:27:52.754	2026-05-11 23:27:56.489	\N	0	SYNC_USER_FULL	DONE	\N
e6f4e0b5-77a7-4d72-93d7-8593ed82d76e	{"name": "BELTRAN", "userId": "e3a60882-6f03-4885-8e7a-e633ff91c54b", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:29:02.261	2026-05-11 23:29:06.124	\N	0	SYNC_USER_FULL	DONE	\N
5d88cd67-a468-49ad-ad92-f90aec334e34	{"name": "ARIANA AÑEZ", "userId": "af2c4ffd-5299-41b7-9250-672184d7b730", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778542456407.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:34:19.887	2026-05-11 23:41:25.388	\N	2	SYNC_USER_FULL	DONE	\N
180aac00-2993-4de0-bd16-336e3827a0d2	{"name": "KARLA MERIDA", "userId": "9213415e-a653-4348-832a-bf9810200933", "endDate": "2026-08-09T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778542675302.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:38:55.931	2026-05-11 23:41:33.651	\N	1	SYNC_USER_FULL	DONE	be8bdf90-48e9-457d-95f1-750450f4d968
8d0d1cfe-1847-4001-9747-9221c302e037	{"name": "REINER MORENO", "userId": "476f493e-162a-4d08-bbdd-939833a866d6", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778543041814.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:44:17.302	2026-05-11 23:44:22.177	\N	0	SYNC_USER_FULL	DONE	df3a5ef7-c10e-4d62-a926-f62d40a6fb7f
b94c9bfd-ffb4-4590-9404-c15f4bc8f04e	{"name": "ANA NOGALES", "userId": "dc32d4c5-5afc-4af0-8783-960223918223", "endDate": "2026-05-15T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:53:38.055	2026-05-11 22:53:41.574	\N	0	SYNC_USER_FULL	DONE	\N
99b627c9-545b-4938-a258-092c55103659	{"name": "ARIEL OROPEZA", "userId": "2ba743d2-858b-4e21-950e-ea4f87925874", "endDate": "2027-02-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:12:36.577	2026-05-11 23:12:48.755	\N	0	SYNC_USER_FULL	DONE	\N
af92130d-a00e-4ae3-a35d-e073d773fa5a	{"name": "ANDREA LOPEZ", "userId": "b5e69f4c-51bd-410a-9b57-44092888994b", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:54:45.024	2026-05-11 22:54:48.812	\N	0	SYNC_USER_FULL	DONE	\N
0503e137-b59c-4792-a068-71487c3370a7	{"name": "ANDREA LOPEZ", "userId": "b5e69f4c-51bd-410a-9b57-44092888994b", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:56:36.801	2026-05-11 22:56:40.582	\N	0	SYNC_USER_FULL	DONE	\N
74a5a183-490f-4449-9e10-0e272dd8f0bd	{"name": "ARTURO BURGOS", "userId": "37a69c00-8984-45eb-b0f5-fac4464c485e", "endDate": "2026-05-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:13:30.524	2026-05-11 23:13:34.465	\N	0	SYNC_USER_FULL	DONE	\N
2ecc8da0-ec0f-4555-93d7-db10ca3aa16c	{"name": "ANDRIU MEJIA", "userId": "bb057365-37cd-4fad-8943-037032987734", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:57:58.17	2026-05-11 22:58:02.031	\N	0	SYNC_USER_FULL	DONE	\N
47f30eac-7ac2-4eda-94eb-a8beb828c2c9	{"name": "AURELIO CAMPOS", "userId": "0d168b57-fe6f-433d-82db-2a0fcc1ee953", "endDate": "2026-12-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:16:58.738	2026-05-11 23:17:12.514	\N	0	SYNC_USER_FULL	DONE	\N
8858ee34-7e19-4371-b637-31865141c1a5	{"name": "ANGELICA REZO", "userId": "8da439a1-ac7b-4451-8db2-28c0b21e888d", "endDate": "2026-05-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 22:59:53.529	2026-05-11 22:59:57.465	\N	0	SYNC_USER_FULL	DONE	\N
110bba52-1f4b-4745-8b45-db0aa8d11d20	{"name": "ANIBAL", "userId": "1eeaa250-9d9d-45ae-86d6-295537c409ec", "endDate": "2026-05-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:01:09.94	2026-05-11 23:01:13.517	\N	0	SYNC_USER_FULL	DONE	\N
c3c218f5-666f-424c-bbd6-3665dc411590	{"name": "ANA GABRIELA SOLIZ", "userId": "3763abee-1b74-47e0-9f72-203bf58d976d", "endDate": "2026-05-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:18:27.441	2026-05-11 23:18:31.367	\N	0	SYNC_USER_FULL	DONE	\N
192a3259-3c1c-4aca-8bdc-8d1c307f336d	{"name": "ANTONY TORREZ", "userId": "14ca7ddc-150c-4dda-8895-3d881ffc5267", "endDate": "2026-06-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:02:10.839	2026-05-11 23:02:25.71	\N	0	SYNC_USER_FULL	DONE	\N
7fd89383-18f3-4eb6-86fd-7dbfae4ca0d0	{"name": "BELIZAIDA", "userId": "1f933426-9a3a-4ea1-9fe3-517c7e6708cf", "endDate": "2027-02-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:21:59.489	2026-05-11 23:22:12.206	\N	0	SYNC_USER_FULL	DONE	\N
5ba8b90c-c6db-427a-8523-6d669046f680	{"name": "GABRIELA CASTEDO", "userId": "eacad3c1-2395-41ef-9633-32c9163fc689", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778542282972.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:31:39.096	2026-05-11 23:31:44.08	\N	0	SYNC_USER_FULL	DONE	248694cb-6dd7-4bcf-8aa1-a90e7d6dd723
69c96fd2-0a88-40a6-921d-07e4cff00e81	{"name": "ARIANA AÑEZ", "userId": "af2c4ffd-5299-41b7-9250-672184d7b730", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778542525089.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:35:55.469	2026-05-11 23:41:27.936	\N	2	SYNC_USER_FULL	DONE	\N
76042fa0-22ff-4bcc-9a65-2a4e8a7090bd	{"name": "ARIANA AÑEZ", "userId": "af2c4ffd-5299-41b7-9250-672184d7b730", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778542525089.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:36:01.964	2026-05-11 23:41:30.427	\N	2	SYNC_USER_FULL	DONE	\N
3815f24e-4b89-4a43-b0cd-8b4fc3d1ee2a	{"name": "ARIANA AÑEZ", "userId": "af2c4ffd-5299-41b7-9250-672184d7b730", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778542525089.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-11 23:48:47.007	2026-05-11 23:48:55.397	\N	0	SYNC_USER_FULL	DONE	\N
8636cb73-f3c9-4c52-9a09-20663f99df9f	{"name": "KARINA FERREL", "userId": "a1522040-1855-4193-ac97-9f965f584f11", "endDate": "2026-08-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778543980594.jpg", "startDate": "2026-05-12T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:00:06.573	2026-05-12 00:00:11.523	\N	0	SYNC_USER_FULL	DONE	317dcca7-9f8d-40ad-be26-2aa2320f218a
e6292d80-8023-4949-9427-17ad6ee92ef0	{"name": "ALAN GARCIA", "userId": "c693773e-60f2-4f62-820d-af9806295a4c", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778544079958.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:01:40.491	2026-05-12 00:01:44.963	\N	0	SYNC_USER_FULL	DONE	\N
81fb8e3f-70c1-418a-91af-49c315f3efac	{"name": "ALAN GARCIA", "userId": "c693773e-60f2-4f62-820d-af9806295a4c", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778544079958.jpg", "startDate": "2026-05-08T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:03:40.47	2026-05-12 00:03:47.147	\N	0	SYNC_USER_FULL	DONE	\N
96660f61-c748-4205-85bf-daa9a77f7d2a	{"name": "BENJAMIN BUITRAGO", "userId": "cdaf029c-3182-4ca9-b85b-fef51a732baf", "endDate": "2026-07-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:47:51.622	2026-05-12 00:47:55.764	\N	0	SYNC_USER_FULL	DONE	\N
656f9b7b-7adf-4f2c-9371-5f5dd82be9ea	{"name": "CARLOS EDUARDO", "userId": "229949be-6630-4b99-912a-97ba6e140a2f", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-30T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 01:28:16.764	2026-05-12 01:28:20.628	\N	0	SYNC_USER_FULL	DONE	\N
b14f6d35-8a17-43fb-a49c-7965c091e173	{"name": "Sergio Olmos", "userId": "e08a297f-e9ff-4967-b725-88b68f786e92", "endDate": "2026-06-27T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778562268598.jpg", "startDate": "2026-05-01T00:00:00.000Z"}	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	2026-05-12 05:12:56.506	\N	\N	0	SYNC_USER_FULL	PENDING	\N
c43f6d2f-d22f-4c30-81fb-c5ceaf2a422d	{"name": "BERNARDO URIOSTE", "userId": "a3a1bbab-a2dc-40da-aa6a-97146c5fee2a", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-30T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:49:00.985	2026-05-12 00:49:15.91	\N	0	SYNC_USER_FULL	DONE	\N
deda64d6-fc5c-47ab-9590-3ad54bda706c	{"name": "DAVID FLORES", "userId": "f75051f4-22b0-4de2-ac4d-cba8b447b15b", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:03:00.988	2026-05-12 13:03:05.011	\N	0	SYNC_USER_FULL	DONE	\N
5e607234-2321-42d5-9259-91a0e8640e6c	{"name": "Alisson Borja", "userId": "9c776bb9-61c5-4ee0-9614-5be0fb97d317", "endDate": "2026-08-09T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778580927371.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:15:32.366	2026-05-12 10:15:37.349	\N	0	SYNC_USER_FULL	DONE	\N
bf2746ea-e4ef-46ab-a90f-c71574de49c2	{"name": "BORIS BELTRAN", "userId": "ddfb4049-f4bc-4534-bd54-a9f9764b6cb8", "endDate": "2026-07-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:52:03.622	2026-05-12 00:52:07.502	\N	0	SYNC_USER_FULL	DONE	\N
3c2f30aa-5c52-48fb-b8dd-005e0c868a77	{"name": "Alisson Borja", "userId": "9c776bb9-61c5-4ee0-9614-5be0fb97d317", "endDate": "2026-08-09T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778580927371.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:16:09.961	2026-05-12 10:16:14.013	\N	0	SYNC_USER_FULL	DONE	\N
7ef5cd70-a5e8-4f4a-ad3a-5ebea29589bb	{"name": "BRAYAN", "userId": "f848e6ae-09d8-461a-83bc-9c82e5c9167d", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:53:14.611	2026-05-12 00:53:29.503	\N	0	SYNC_USER_FULL	DONE	\N
60531115-a1d2-4d5d-abd2-3ae4e19a9e35	{"name": "BRAYAN  RIVERA", "userId": "d23325f7-6aa2-4072-ba45-3a7885dbb7a9", "endDate": "2026-08-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-01T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:54:26.878	2026-05-12 00:54:30.914	\N	0	SYNC_USER_FULL	DONE	\N
05f21e32-13d8-4609-817a-3c790c680c84	{"name": "CARLOS HURTADO", "userId": "33b29244-f779-42e2-9721-71e39a4ad98d", "endDate": "2027-12-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:20:33.949	2026-05-12 10:20:37.706	\N	0	SYNC_USER_FULL	DONE	\N
2f0cea89-fcc6-48e9-a9e8-19419351cf15	{"name": "BRAYAN PANIAGUA", "userId": "a86881ed-f927-4b62-9a38-8056f58d80e9", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-30T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:55:44.945	2026-05-12 00:55:48.742	\N	0	SYNC_USER_FULL	DONE	\N
a79825e0-cb2e-4c8f-af0a-1daa865be754	{"name": "CARLOS PONCE", "userId": "8182fce0-79cf-4297-b088-eab44cfabaa7", "endDate": "2026-05-16T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:23:38.557	2026-05-12 10:23:42.363	\N	0	SYNC_USER_FULL	DONE	\N
8d2b4d93-7908-4206-8b4d-e136a413da02	{"name": "BRENDA CHOQUE", "userId": "67ce18ed-76bc-47d9-86e9-cb7cbdd692bb", "endDate": "2026-06-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:57:03.919	2026-05-12 00:57:07.87	\N	0	SYNC_USER_FULL	DONE	\N
34b18130-1cb1-41de-bf2e-c95cfca3fbbc	{"name": "BRUNO ROJAS", "userId": "f1c7c07c-2b71-4cae-93b0-0fb09044c46a", "endDate": "2026-07-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 00:58:58.266	2026-05-12 00:59:05.244	\N	0	SYNC_USER_FULL	DONE	\N
2dd6c3ef-da87-4395-a245-22db67648f69	{"name": "CARLOS ROJAS", "userId": "5116038b-94be-4b71-8ff3-b03ab527f2f3", "endDate": "2027-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:27:50.962	2026-05-12 10:27:54.374	\N	0	SYNC_USER_FULL	DONE	\N
58ba17b2-4ca3-4998-82f3-cb42ed2ba553	{"name": "BERNARDO URIOSTE", "userId": "a3a1bbab-a2dc-40da-aa6a-97146c5fee2a", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778547932525.jpg", "startDate": "2026-04-30T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 01:05:35.606	2026-05-12 01:05:40.8	\N	0	SYNC_USER_FULL	DONE	\N
a2f6e90d-0f85-40f2-bad8-3102a0b8fff7	{"name": "CARLOS URQUIZA", "userId": "dbe35b9c-74f6-4367-bc0c-e7fc2ca93d2e", "endDate": "2026-07-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:43:53.048	2026-05-12 10:43:56.853	\N	0	SYNC_USER_FULL	DONE	\N
729ea001-d6ea-4988-941d-a07542d9fa24	{"name": "SAMANTA", "userId": "19cbef6f-740f-4538-b415-d2022ba8b045", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778541916337.jpg", "startDate": "2026-05-11T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 01:06:28.384	2026-05-12 01:06:43.785	\N	0	SYNC_USER_FULL	DONE	\N
73513fba-188d-4473-b1d8-0f700f4b00fe	{"name": "CARLA BAUTISTA", "userId": "2d6028b4-ee06-4004-9fa7-fcaf5f32c2df", "endDate": "2026-05-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-06T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 01:12:50.847	2026-05-12 01:12:54.84	\N	0	SYNC_USER_FULL	DONE	\N
859b6e0f-361b-45af-b1fd-1c571e36c06f	{"name": "CAROL JIMENA ALFARO", "userId": "14982bcc-b706-41bc-ad3d-3436b0a8e007", "endDate": "2026-11-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:46:01.063	2026-05-12 10:46:04.885	\N	0	SYNC_USER_FULL	DONE	\N
827e0ae9-91d8-4eee-ad3f-0ff91ace4a8b	{"name": "CARLOS CAMACHO", "userId": "a60aa232-435c-4484-a25c-06cfe020f370", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 01:26:09.085	2026-05-12 01:26:20.139	\N	0	SYNC_USER_FULL	DONE	\N
b91e11a4-7d9a-4b59-b44c-75f1f1a313b1	{"name": "LUCIANA", "userId": "ff67e061-11b0-463d-8b74-3933a04dca84", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-29T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:56:03.959	2026-05-12 23:56:07.828	\N	0	SYNC_USER_FULL	DONE	\N
9cf3f9a3-d07c-48c8-afaf-c33ad91645ba	{"name": "CAROLINA HERRERA", "userId": "e803ed62-468c-44d4-bd33-1cee42348781", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:48:18.173	2026-05-12 10:48:21.983	\N	0	SYNC_USER_FULL	DONE	\N
e3b2a537-e38e-46b3-9253-bbb4d248e639	{"name": "Carolina herrera", "userId": "c65add80-0d84-459f-9361-f3346c7b3334", "endDate": "2026-06-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:51:15.423	2026-05-12 10:51:19.245	\N	0	SYNC_USER_FULL	DONE	\N
09d341ca-e2a5-4159-b473-a80ec70f9415	{"name": "Alicey paniagua", "userId": "e88ca8d5-16cf-4501-99af-6501f49ff7a8", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778583297885.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 10:55:01.746	2026-05-12 10:55:06.547	\N	0	SYNC_USER_FULL	DONE	\N
ba69f5bb-c957-4c75-8ce1-fd57794d5c60	{"name": "CESAR ARGANDOÑA", "userId": "ae2e561a-e9f5-40ce-bd69-ca9201bb8e74", "endDate": "2026-09-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:04:59.243	2026-05-12 11:05:03.068	\N	0	SYNC_USER_FULL	DONE	\N
175b40c0-e1a9-491c-9cc0-7740b77e5686	{"name": "CAROLINA RIQUELME", "userId": "26d4d207-b9b5-4221-b2f3-9628c2724a6c", "endDate": "2026-07-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:09:17.252	2026-05-12 11:09:21.061	\N	0	SYNC_USER_FULL	DONE	\N
edaab323-86af-47ce-a9bd-5582d85ef96d	{"name": "CHRIS CERVANTES", "userId": "f1d6d27a-a3f1-44b5-bdce-1d7f6d531ad4", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:12:13.832	2026-05-12 11:12:17.613	\N	0	SYNC_USER_FULL	DONE	\N
55550d48-f644-46d6-bd17-87f15b7c331f	{"name": "CIELO CRESPO", "userId": "fb6c9d8f-9441-484a-b6de-451233679e4d", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:14:23.385	2026-05-12 11:14:27.187	\N	0	SYNC_USER_FULL	DONE	\N
4f9d1e5f-d1c2-4d67-8fe4-05b4dd0f990c	{"name": "CINTHIA COLQUE", "userId": "2a158cc9-5fb6-45e3-822b-3c29985cb265", "endDate": "2026-05-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:20:00.245	2026-05-12 11:20:04.142	\N	0	SYNC_USER_FULL	DONE	\N
55abd59b-9cf8-4ca0-9efc-c66a193b26cb	{"name": "ALVARO PEÑARANDA", "userId": "f97f2614-1a25-4055-af4b-bd661030983f", "endDate": "2026-09-22T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778584867867.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:22:34.055	2026-05-12 11:22:38.392	\N	0	SYNC_USER_FULL	DONE	\N
61524958-e3a8-430a-8376-43f6a55f475f	{"name": "ALVARO PEÑARANDA", "userId": "f97f2614-1a25-4055-af4b-bd661030983f", "endDate": "2026-09-22T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778584867867.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:22:39.684	2026-05-12 11:22:42.973	\N	0	SYNC_USER_FULL	DONE	\N
4c7fff68-fb99-4f7d-9a39-8e293acb8277	{"name": "ALVARO PEÑARANDA", "userId": "f97f2614-1a25-4055-af4b-bd661030983f", "endDate": "2026-09-22T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778584997490.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:23:40.356	2026-05-12 11:23:45.033	\N	0	SYNC_USER_FULL	DONE	\N
a40e791a-5026-4594-b12c-4ab00961ddc4	{"name": "CINTHIA MENDOZA", "userId": "503e2c59-9329-4312-86e6-88063247b133", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:29:08.344	2026-05-12 11:29:12.111	\N	0	SYNC_USER_FULL	DONE	\N
ef0778bd-0ef1-4c9d-a31e-d5afbe5e09d3	{"name": "CLAUDIA CORDOVA", "userId": "590a677e-2ca7-4c5c-a626-5f820e968a02", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:32:07.974	2026-05-12 11:32:11.928	\N	0	SYNC_USER_FULL	DONE	\N
7bdb450e-352b-4426-8f56-4aa860d1cbc1	{"name": "CLAUDIA PEDRAZA", "userId": "cfc79a88-47f4-4abd-9672-aa15994283c2", "endDate": "2026-11-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:34:24.078	2026-05-12 11:34:27.91	\N	0	SYNC_USER_FULL	DONE	\N
900d7c29-3753-449d-8092-2c2f2da95cae	{"name": "CLAUDIO CUELLAR", "userId": "40cdeee4-0cad-403f-b046-55a5a6a2351c", "endDate": "2027-01-01T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:36:25.347	2026-05-12 11:36:29.228	\N	0	SYNC_USER_FULL	DONE	\N
d0af6a99-6815-4c0a-9fa6-42587481d25a	{"name": "CRISTIAN", "userId": "8d558a91-928d-48b5-81d5-0c16dcf8bd23", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:38:31.429	2026-05-12 11:38:35.283	\N	0	SYNC_USER_FULL	DONE	\N
03aa4cef-b93c-4993-8c17-9f8ec3c9dad8	{"name": "CRISTIAN BESERRA", "userId": "cb6fe7ed-48ce-496d-a3c0-dc3df9ec5ffd", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:44:13.408	2026-05-12 11:44:17.181	\N	0	SYNC_USER_FULL	DONE	\N
cc13f52b-994a-4225-adc1-a5e920a5b083	{"name": "CRISTIAN CUELLAR", "userId": "3695737b-64a7-47b0-86f9-58d865a70bf3", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:47:32.184	2026-05-12 11:47:36.038	\N	0	SYNC_USER_FULL	DONE	\N
28a9c19b-ef2f-4a9b-9f99-6cd14af59853	{"name": "CRISTIAN PAYE", "userId": "1b1d5ee8-7c16-41fc-8ba9-1f3fe85fa749", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:49:32.627	2026-05-12 11:49:36.455	\N	0	SYNC_USER_FULL	DONE	\N
c22289a3-d010-4c64-9c92-1cf253e64e1b	{"name": "CRISTINA ROCA", "userId": "1e07bf11-03d8-4059-aac5-80d5c86cc41a", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:53:38.525	2026-05-12 11:53:42.302	\N	0	SYNC_USER_FULL	DONE	\N
f73f23af-f24a-4b41-8766-70e6ba56e564	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:50:59.316	2026-05-12 11:51:03.154	\N	0	SYNC_USER_FULL	DONE	\N
e61a6964-7da7-44d4-9b34-2270ff76a8bb	{"name": "DAVID NAJAYA", "userId": "362f0976-10f2-4896-bf47-e235e3717892", "endDate": "2026-08-09T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:05:38.883	2026-05-12 13:05:42.717	\N	0	SYNC_USER_FULL	DONE	\N
d6e0e614-913e-45ca-bb7a-7e318cf7a409	{"name": "KEVIN MATHY", "userId": "b4b33973-4a5e-4ee7-8cc5-f58b2955a51a", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:26:57.997	2026-05-12 23:27:01.898	\N	0	SYNC_USER_FULL	DONE	\N
260ba468-27b6-4afd-a1d2-c9ee835d6f00	{"name": "BELIZAIDA", "userId": "1f933426-9a3a-4ea1-9fe3-517c7e6708cf", "endDate": "2027-02-20T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587063950.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:57:57.552	2026-05-12 11:58:02.561	\N	0	SYNC_USER_FULL	DONE	\N
0daa0913-b12b-4d08-a8d5-f9b5e480ac98	{"name": "DAVID VACA", "userId": "9bbc1ece-99fa-4616-9161-c83db51aa25b", "endDate": "2026-11-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:12:49.011	2026-05-12 13:12:52.861	\N	0	SYNC_USER_FULL	DONE	\N
e98e6a19-9bc6-4f16-915e-797bb0cb7c84	{"name": "CRISTINA URIAS", "userId": "7cb7265c-514f-40b2-8e1c-d08624a5b885", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 11:58:55.166	2026-05-12 11:58:59.105	\N	0	SYNC_USER_FULL	DONE	\N
94bdadb4-ab79-4d93-99d2-e0d78a7ce9d3	{"name": "DAVID VASQUEZ", "userId": "a5c2d6a4-2740-4ae5-91a8-a3287620c7af", "endDate": "2026-07-10T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:14:47.048	2026-05-12 13:14:51.048	\N	0	SYNC_USER_FULL	DONE	\N
fabb0978-182b-4900-bf41-4d43f60da36e	{"name": "DAYANA JUSTINIANO", "userId": "e39a48bf-3739-40b2-aecb-166da5fbbe56", "endDate": "2027-07-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:19:41.942	2026-05-12 13:19:45.796	\N	0	SYNC_USER_FULL	DONE	\N
d68a52c2-1c3d-436a-baae-2ef1c788bc16	{"name": "CRISTINA VARGAS", "userId": "c161507d-3d1e-4449-bf67-067f757c9185", "endDate": "2026-06-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:00:28.817	2026-05-12 12:00:32.845	\N	0	SYNC_USER_FULL	DONE	\N
305cc2b8-c7e4-48e0-9b03-9b134801a1fb	{"name": "DAYANA ROMERO", "userId": "9594524b-f9d7-4866-a709-1b5b72561c43", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:41:45.301	2026-05-12 13:41:48.707	\N	0	SYNC_USER_FULL	DONE	\N
a9cbb586-a1eb-4f1c-a79a-70809e09939a	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587284514.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:01:28.819	2026-05-12 12:01:32.471	\N	0	SYNC_USER_FULL	DONE	\N
db1933d7-fed4-438f-b2d3-eac2679e8070	{"name": "DECKER", "userId": "fbd8d867-0df5-494d-b277-742b3c39f86e", "endDate": "2026-06-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:44:08.199	2026-05-12 13:44:12.023	\N	0	SYNC_USER_FULL	DONE	\N
f344f9d5-7266-48cf-be42-c2e68c0378b8	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587284514.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:02:14.951	2026-05-12 12:02:19.151	\N	0	SYNC_USER_FULL	DONE	\N
9626d751-8c1a-4cde-8d1f-0ea1db34ee94	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587381486.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:03:09.216	2026-05-12 12:03:27.823	\N	0	SYNC_USER_FULL	DONE	\N
ac405aef-0338-4875-b2e3-8961d075ba64	{"name": "DEYVY", "userId": "35e3dd85-4922-4d4d-8722-70cdac572efc", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:09:33.032	2026-05-12 14:09:36.834	\N	0	SYNC_USER_FULL	DONE	\N
c02a3505-958b-4ecd-af67-e6563990c387	{"name": "DIEGO BARBA", "userId": "32794fba-4901-47d7-a3d9-3282c5a6ff37", "endDate": "2026-07-03T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:11:16.318	2026-05-12 14:11:20.345	\N	0	SYNC_USER_FULL	DONE	\N
5a882d1d-1814-41c8-b63a-8650f01cc1ba	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:13:14.606	2026-05-12 14:13:18.506	\N	0	SYNC_USER_FULL	DONE	\N
ecaaa4bf-2e2e-48fa-8023-ec4ed9a4c5ff	{"name": "DIEGO PINTO", "userId": "e36c05fa-507a-4680-9962-ead22b0f4816", "endDate": "2026-08-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:15:48.276	2026-05-12 14:15:52.149	\N	0	SYNC_USER_FULL	DONE	\N
7ce3a4c0-2c2d-4304-b8dd-1c875d9cd805	{"name": "DIEGO RODRIGUEZ", "userId": "f0517e12-07ae-4354-968e-6ce837a59958", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:18:10.139	2026-05-12 14:18:14.045	\N	0	SYNC_USER_FULL	DONE	\N
73f81289-b204-4142-a47f-b5c54f438172	{"name": "DILAN MARTINEZ", "userId": "502cc3dd-a709-4f48-9e65-65b25abc8aa8", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:19:47.181	2026-05-12 14:19:50.959	\N	0	SYNC_USER_FULL	DONE	\N
0cffa650-9880-4eec-9d43-de7b07ba20df	{"name": "DORIAN MONROY", "userId": "a4f0b4d8-868c-4bd9-95f8-79df22d8a3dd", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:22:14.035	2026-05-12 14:22:17.825	\N	0	SYNC_USER_FULL	DONE	\N
2e8855bb-63e5-447d-9626-0bffb9bc3c46	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778590063749.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:47:46.729	2026-05-12 12:47:50.935	\N	0	SYNC_USER_FULL	DONE	\N
afb3f47c-b376-40db-a90f-e3c59499aad8	{"name": "JORGE BARBA", "userId": "8bc3f30b-309c-42f7-9f52-046e95de6276", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:15:08.068	2026-05-12 21:15:11.912	\N	0	SYNC_USER_FULL	DONE	\N
08aafec6-6d14-43df-a6e0-36da4feff572	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587381486.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:03:36.059	2026-05-12 12:03:40.099	\N	0	SYNC_USER_FULL	DONE	\N
e60fcec6-66d7-490b-9ff2-df16792cee9f	{"name": "DAVID SUAREZ", "userId": "144621a4-ad27-4aac-a4eb-c2171985be60", "endDate": "2026-07-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:07:43.474	2026-05-12 13:07:47.327	\N	0	SYNC_USER_FULL	DONE	\N
62e8e650-ffae-4f8a-8db1-bf71603a5d4e	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587489083.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:05:18.092	2026-05-12 12:05:22.172	\N	0	SYNC_USER_FULL	DONE	\N
435e6e21-66c5-444e-bc29-09cb79887dc7	{"name": "Carmiña Pedraza", "userId": "bc76b1e0-f9b4-4bc8-9ace-5fc3b528bacf", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:09:32.73	2026-05-12 12:09:36.516	\N	0	SYNC_USER_FULL	DONE	\N
66cb8c7c-9bb1-4016-aa1f-406bc5282f45	{"name": "ALEXANDER GUTIERREZ", "userId": "17c4abf8-339c-4a77-a5e1-3b66e045bd7c", "endDate": "2026-05-16T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778591301972.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:08:48.126	2026-05-12 13:08:53.061	\N	0	SYNC_USER_FULL	DONE	\N
47954f19-0f60-4d4a-85f7-127bd10361a6	{"name": "Carmiña Pedraza", "userId": "bc76b1e0-f9b4-4bc8-9ace-5fc3b528bacf", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:09:37.876	2026-05-12 12:09:41.47	\N	0	SYNC_USER_FULL	DONE	\N
4333c19d-e08d-4815-b923-d9e9e5420062	{"name": "ALEXANDER GUTIERREZ", "userId": "17c4abf8-339c-4a77-a5e1-3b66e045bd7c", "endDate": "2026-05-16T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778591301972.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:09:06.762	2026-05-12 13:09:10.949	\N	0	SYNC_USER_FULL	DONE	\N
f28e29ae-1bf7-4f9c-b81d-afd5be1ccfed	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587489083.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:10:38.195	2026-05-12 12:10:42.289	\N	0	SYNC_USER_FULL	DONE	\N
f7f37586-0a65-4f03-bf48-c890ad6e9490	{"name": "ALCIDES DREW", "userId": "42297e10-37c8-4426-9aa8-c2d958d0a622", "endDate": "2027-01-02T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778588733623.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:25:38.574	2026-05-12 12:25:42.923	\N	0	SYNC_USER_FULL	DONE	\N
0b26341c-5d0a-42d9-8214-b3774542ab41	{"name": "ALEXANDER GUTIERREZ", "userId": "17c4abf8-339c-4a77-a5e1-3b66e045bd7c", "endDate": "2026-05-16T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778591395350.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:10:06.451	2026-05-12 13:10:10.141	\N	0	SYNC_USER_FULL	DONE	\N
d9f91e7d-3ef6-4f9b-9592-97c9df2e8b71	{"name": "ALCIDES DREW", "userId": "42297e10-37c8-4426-9aa8-c2d958d0a622", "endDate": "2027-01-02T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778588819008.jpg", "startDate": "2026-05-08T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:27:04.158	2026-05-12 12:27:08.922	\N	0	SYNC_USER_FULL	DONE	\N
5ef07d8f-b7da-4462-a42b-e4a3d498351c	{"name": "DAVID ZEBALLOS", "userId": "a60c8569-154e-4ae1-8ab0-1a7d56bded2f", "endDate": "2026-07-01T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 13:16:36.724	2026-05-12 13:16:40.645	\N	0	SYNC_USER_FULL	DONE	\N
e61f3670-8a14-4095-8260-6f0aa530e57d	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:31:14.977	2026-05-12 12:31:18.872	\N	0	SYNC_USER_FULL	DONE	\N
e275f572-7bf3-45a9-aa6b-2b86f50b0e87	{"name": "DANIEL VINICIUS", "userId": "33f9f76f-ef12-4217-85d8-4b96ad28cd61", "endDate": "2027-02-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:38:45.9	2026-05-12 12:38:49.8	\N	0	SYNC_USER_FULL	DONE	\N
d0866820-4e15-4d2c-a187-4561ee8c3180	{"name": "kAREN GALVEZ", "userId": "42d89532-31d5-423a-9007-f83b454116bc", "endDate": "2026-06-11T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778589655168.jpg", "startDate": "2026-05-12T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:41:09.919	2026-05-12 12:41:14.433	\N	0	SYNC_USER_FULL	DONE	7c035ce0-a366-4381-8bb5-0be9d8fdc247
d4f9de3e-9e95-48d3-832c-ba5b57f7b0cd	{"name": "kAREN GALVEZ", "userId": "42d89532-31d5-423a-9007-f83b454116bc", "endDate": "2026-06-11T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778589744669.jpg", "startDate": "2026-05-12T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:42:29.301	2026-05-12 12:42:33.855	\N	0	SYNC_USER_FULL	DONE	\N
c6700022-61ba-4725-a2bc-30ea1cbe2715	{"name": "CRISTIAN SUBIRANA", "userId": "36848429-b86f-41f0-9563-4c5adce1129f", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778587489083.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 12:47:15.857	2026-05-12 12:47:19.99	\N	0	SYNC_USER_FULL	DONE	\N
6043fda1-e57e-40ec-9b70-af48249c465e	{"name": "GUISELA AYALA", "userId": "ef2297bc-5bb2-4f6e-9dca-d9abc1af22a3", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778608466636.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:54:42.635	2026-05-12 17:54:47.129	\N	0	SYNC_USER_FULL	DONE	\N
d0e8d7ac-69cb-4c98-9801-9f9a51d10cbb	{"name": "EDGAR CUELLAR", "userId": "4cce917b-f231-48d0-ada5-5fed6e41c148", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:27:32.847	2026-05-12 14:27:36.756	\N	0	SYNC_USER_FULL	DONE	\N
05e28669-55c9-43e5-8bdc-438775941a99	{"name": "DANIEL VINICIUS", "userId": "33f9f76f-ef12-4217-85d8-4b96ad28cd61", "endDate": "2027-02-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778596867913.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:41:12.992	2026-05-12 14:41:17.912	\N	0	SYNC_USER_FULL	DONE	\N
db5a5e98-966d-43aa-8953-5bedbebbc8d6	{"name": "EDGAR VEGA", "userId": "de8e805e-fc19-4a09-883a-df10f1358f2a", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:48:34.977	2026-05-12 14:48:38.812	\N	0	SYNC_USER_FULL	DONE	\N
37e52344-661d-4ece-9fc1-d6f91ae70a14	{"name": "CAROLINA RIQUELME", "userId": "26d4d207-b9b5-4221-b2f3-9628c2724a6c", "endDate": "2026-07-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778597484477.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:51:51.759	2026-05-12 14:51:56.663	\N	0	SYNC_USER_FULL	DONE	\N
162feba0-1ab8-42f4-89f1-39a7986fd1bf	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 14:54:48.717	2026-05-12 14:54:52.885	\N	0	SYNC_USER_FULL	DONE	\N
0b051bdd-dcf0-4d1b-ab3a-65cec0599ebb	{"name": "ELVIS SOTO", "userId": "9d0d0b90-8ae5-40d7-9e54-cb8dd58d0480", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 15:48:25.263	2026-05-12 15:48:29.044	\N	0	SYNC_USER_FULL	DONE	\N
60a6603a-5047-4ff6-bf13-6d95af1ae1b4	{"name": "EMILIO ARTEAGA", "userId": "019acc34-bae2-424a-962c-736770ee1dfc", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 15:52:24.785	2026-05-12 15:52:28.937	\N	0	SYNC_USER_FULL	DONE	\N
ca2a5988-b54c-4ae1-8a34-a59d77da616e	{"name": "EMMA DURANTON", "userId": "2bd57e4f-56de-4d35-b7df-6b9a5168de6c", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 15:54:33.372	2026-05-12 15:54:37.196	\N	0	SYNC_USER_FULL	DONE	\N
b01f9a5f-dc8b-470e-a93d-317fafb0b33b	{"name": "CESAR ARGANDOÑA", "userId": "ae2e561a-e9f5-40ce-bd69-ca9201bb8e74", "endDate": "2026-09-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778601931687.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:05:47.457	2026-05-12 16:05:52.701	\N	0	SYNC_USER_FULL	DONE	\N
5f4fa8a8-dada-44cc-adee-c114dc64749f	{"name": "ERVIN MENDEZ", "userId": "75ffd53b-517d-4bbf-a001-754966d7d898", "endDate": "2026-06-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:23:40.072	2026-05-12 16:23:43.935	\N	0	SYNC_USER_FULL	DONE	\N
4f8810b4-b55c-435f-be3a-b2320ef80e52	{"name": "EULALIA", "userId": "693b1571-7006-4f15-8c09-5120324d2b50", "endDate": "2027-02-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:28:21.818	2026-05-12 16:28:25.866	\N	0	SYNC_USER_FULL	DONE	\N
b2124e79-1264-4569-ac0b-3ac6fc675f02	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:31:32.411	2026-05-12 16:31:36.247	\N	0	SYNC_USER_FULL	DONE	\N
85a13c9c-ec6d-4224-9ddb-7f5f92adde2b	{"name": "FERNANDO EGUEZ", "userId": "070082d8-f645-4135-8d7f-a4b56dcd49f3", "endDate": "2026-09-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:33:17.128	2026-05-12 16:33:21	\N	0	SYNC_USER_FULL	DONE	\N
ff43d3e8-953c-4ff9-a25b-f650ce47f795	{"name": "FERNANDO JOSUE", "userId": "9308d4b2-526f-4489-8607-13f73f6ee946", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:36:19.095	2026-05-12 16:36:26.873	\N	0	SYNC_USER_FULL	DONE	\N
d741eb43-8b90-468d-a878-b7764c6a4ea8	{"name": "FLOWER", "userId": "b135bed0-a17e-4242-986f-edb3304896fb", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:37:42.377	2026-05-12 16:37:46.233	\N	0	SYNC_USER_FULL	DONE	\N
b51dce1b-dc0a-4adb-88b4-a3f3eacca6c5	{"name": "FLOWER", "userId": "b135bed0-a17e-4242-986f-edb3304896fb", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:38:49.345	2026-05-12 16:38:52.797	\N	0	SYNC_USER_FULL	DONE	\N
aa0ff22f-93ce-46af-9dc4-ecab245e4d51	{"name": "FRANCISCO SANDOVAL", "userId": "5faf569a-c8ee-4eb2-8a1d-5a77fefeb9ec", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:40:33.868	2026-05-12 16:40:37.795	\N	0	SYNC_USER_FULL	DONE	\N
6361f945-b5d8-4833-b9be-65eaeae49474	{"name": "CRISTINA ROCA", "userId": "1e07bf11-03d8-4059-aac5-80d5c86cc41a", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778604131824.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:42:39.153	2026-05-12 16:42:44.304	\N	0	SYNC_USER_FULL	DONE	\N
041727f0-f2e1-45ff-af4e-4f6e27727134	{"name": "DILAN MARTINEZ", "userId": "502cc3dd-a709-4f48-9e65-65b25abc8aa8", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778604358328.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:46:14.76	2026-05-12 16:46:19.804	\N	0	SYNC_USER_FULL	DONE	\N
fa5ca515-7d22-4a90-ad44-767f240f7667	{"name": "GABRIELA ROCABADO", "userId": "4921baba-2d23-418f-a2a8-09d4bd9ac241", "endDate": "2026-05-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:49:12.938	2026-05-12 16:49:16.768	\N	0	SYNC_USER_FULL	DONE	\N
b4d9ecf0-eb0b-4264-9e3b-f5a1d89d2c1f	{"name": "JORGE BARBA", "userId": "8bc3f30b-309c-42f7-9f52-046e95de6276", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:15:10.138	2026-05-12 21:15:13.743	\N	0	SYNC_USER_FULL	DONE	\N
aa747935-9975-4391-b792-265ae3fd1770	{"name": "HERMAN CABALLERO", "userId": "d4d3380f-768c-4bab-86ac-c0779227db6f", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:58:06.086	2026-05-12 17:58:10.134	\N	0	SYNC_USER_FULL	DONE	\N
b32feae8-af1d-4b70-b6bd-b5f0bedb7272	{"name": "FERNANDO EGUEZ", "userId": "070082d8-f645-4135-8d7f-a4b56dcd49f3", "endDate": "2026-09-23T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778604691782.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:51:54.068	2026-05-12 16:51:58.813	\N	0	SYNC_USER_FULL	DONE	\N
fb49adef-199e-4de9-97a4-96d4590de972	{"name": "HORACIO", "userId": "f1810818-cd91-40f0-bfd9-9649693e526d", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:59:38.38	2026-05-12 17:59:41.754	\N	0	SYNC_USER_FULL	DONE	\N
0fbf2897-092b-4823-a730-b829b739f684	{"name": "GALILEA", "userId": "5b3d0c68-6cf8-4656-9464-78e30b791b3b", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:53:37.138	2026-05-12 16:53:41.02	\N	0	SYNC_USER_FULL	DONE	\N
f55bf134-cd5e-4850-8725-1b0d0ac3f6e4	{"name": "IBER SOLIZ", "userId": "4e278f5e-dd46-4319-8703-13be851ea70b", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 18:01:13.833	2026-05-12 18:01:17.701	\N	0	SYNC_USER_FULL	DONE	\N
4adbffa8-32b0-45b6-b8ff-0c281a90770f	{"name": "GARY CUELLAR", "userId": "9915570f-c0ba-467c-98c4-1b1d2e4af87a", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:55:22.138	2026-05-12 16:55:25.983	\N	0	SYNC_USER_FULL	DONE	\N
22e3a3cb-f6fc-4adf-859a-e9f36f245691	{"name": "GUSTAVO MURGUIA", "userId": "14c13de2-ebbd-405f-a3d6-3c400ad6f66f", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778610480026.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 18:28:07.691	2026-05-12 18:28:12.173	\N	0	SYNC_USER_FULL	DONE	\N
e40f545b-837a-4e91-8c94-f611c7081b21	{"name": "GERALDINE", "userId": "6da1b4bc-9d7b-4e8a-9705-6db15a76787b", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 16:56:44.01	2026-05-12 16:56:47.859	\N	0	SYNC_USER_FULL	DONE	\N
91419f3d-d5d1-4c31-9abd-8db132a467d6	{"name": "GERARDO RIVERA", "userId": "906b4106-180d-4f75-8247-af6db3955a39", "endDate": "2026-07-30T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:02:13.313	2026-05-12 17:02:17.174	\N	0	SYNC_USER_FULL	DONE	\N
4d75da0f-1883-4191-85a9-7e0ec51b4aff	{"name": "RENATO DANIEL", "userId": "bb02909a-548b-443e-8954-8573a03c3da3", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778612078923.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 18:55:23.042	2026-05-12 18:55:26.654	\N	0	SYNC_USER_FULL	DONE	\N
f2866814-f5ca-493d-9d0c-162efc5a4427	{"name": "GLORIA PARADA", "userId": "38a2c285-26a6-49d2-93c9-de60c1d25f8f", "endDate": "2027-02-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:04:31.856	2026-05-12 17:04:35.244	\N	0	SYNC_USER_FULL	DONE	\N
12c3e521-8ff4-4d55-a981-2ea532898b08	{"name": "GRACIELA QUIROGA", "userId": "cc824b02-2f60-4e92-ba62-0ec3198b9b7b", "endDate": "2026-06-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:05:57.016	2026-05-12 17:06:00.823	\N	0	SYNC_USER_FULL	DONE	\N
6be158a1-14d6-4870-bc86-ad74fc11146c	{"name": "GUSTAVO VELASQUEZ", "userId": "19db719c-1051-4924-aec8-8fe3216b7c69", "endDate": "2026-09-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:09:09.199	2026-05-12 17:09:13.053	\N	0	SYNC_USER_FULL	DONE	\N
2e6b278f-bf8c-41e7-a702-d893f863abb9	{"name": "GUISELA AYALA", "userId": "ef2297bc-5bb2-4f6e-9dca-d9abc1af22a3", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:38:59.043	2026-05-12 17:39:02.939	\N	0	SYNC_USER_FULL	DONE	\N
05d56c03-8b98-4112-b0cf-a999b24d7f4a	{"name": "GUSTAVO BERNAL", "userId": "cecd7a56-d246-49de-a3ce-4a051757ef8e", "endDate": "2026-06-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:40:40.072	2026-05-12 17:40:43.841	\N	0	SYNC_USER_FULL	DONE	\N
8bb2d165-f143-4caf-9da4-8b76756087aa	{"name": "GUSTAVO CHUGUIÑA", "userId": "55eb10c9-a707-479f-bbc9-c8e19760dcf3", "endDate": "2026-06-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:42:18.181	2026-05-12 17:42:21.988	\N	0	SYNC_USER_FULL	DONE	\N
c4e91e86-7842-4d14-a2e2-1dd949911763	{"name": "GUSTAVO MURGUIA", "userId": "14c13de2-ebbd-405f-a3d6-3c400ad6f66f", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:45:26.727	2026-05-12 17:45:30.583	\N	0	SYNC_USER_FULL	DONE	\N
b4040e18-57a0-4517-a4b9-f6a17070a047	{"name": "HECTOR VILLARROEL", "userId": "31e9e927-66af-4800-a55d-5d979af9614a", "endDate": "2026-06-09T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:47:02.911	2026-05-12 17:47:06.697	\N	0	SYNC_USER_FULL	DONE	\N
9f0c46f4-eef2-4cc0-af99-684cc99e244f	{"name": "HENRY YANARICO", "userId": "3bb68dd2-5395-42c3-9605-3ed9c8cdc6d9", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 17:48:52.542	2026-05-12 17:48:55.924	\N	0	SYNC_USER_FULL	DONE	\N
15c1754d-7abe-4035-bcb6-4e59b7362048	{"name": "RENATO DANIEL", "userId": "bb02909a-548b-443e-8954-8573a03c3da3", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778612078923.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 18:55:18.684	2026-05-12 18:55:23.732	\N	0	SYNC_USER_FULL	DONE	\N
ffaf7c92-84ae-476e-8c96-46a4617c1548	{"name": "JOSE FRANCISCO", "userId": "d87b5051-a000-447b-bd0b-721aabc3d207", "endDate": "2026-08-02T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622562328.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:49:24.403	2026-05-12 21:49:29.182	\N	0	SYNC_USER_FULL	DONE	\N
d5e53003-4c98-4bc6-8217-15e5b85b935b	{"name": "RENATO DANIEL", "userId": "bb02909a-548b-443e-8954-8573a03c3da3", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778612078923.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 18:55:28.336	2026-05-12 18:55:31.692	\N	0	SYNC_USER_FULL	DONE	\N
99277e07-e261-4258-8215-5adb5ac2afc9	{"name": "IGNACIO MENDIETA", "userId": "90068245-1458-4fce-96f7-e7547a9bbb02", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 18:58:51.444	2026-05-12 18:58:54.948	\N	0	SYNC_USER_FULL	DONE	\N
aa88f812-d7cc-4574-9f39-3dfe75803437	{"name": "ARTURO BURGOS", "userId": "37a69c00-8984-45eb-b0f5-fac4464c485e", "endDate": "2026-05-21T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620586134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:16:29.846	2026-05-12 21:16:34.374	\N	0	SYNC_USER_FULL	DONE	\N
1add6096-c125-4082-9255-b2c440dd5355	{"name": "ISAAC", "userId": "b269dee8-ffb7-483b-93fc-3a466072cb8d", "endDate": "2026-05-15T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:00:27.499	2026-05-12 19:00:31.161	\N	0	SYNC_USER_FULL	DONE	\N
15efa96a-5af6-4503-a26b-9bde6849fbf1	{"name": "ARTURO BURGOS", "userId": "37a69c00-8984-45eb-b0f5-fac4464c485e", "endDate": "2026-05-21T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620586134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:16:41.183	2026-05-12 21:16:45.48	\N	0	SYNC_USER_FULL	DONE	\N
772dd01f-5b42-4469-932d-fbe67f6914d6	{"name": "ARTURO BURGOS", "userId": "37a69c00-8984-45eb-b0f5-fac4464c485e", "endDate": "2026-05-21T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620586134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:16:56.925	2026-05-12 21:17:01.088	\N	0	SYNC_USER_FULL	DONE	\N
15f2b6a4-3b13-46e9-92d3-d70456cb2bf5	{"name": "DANNERSON", "userId": "46b3376a-973a-454b-9347-52808613a768", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620645685.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:17:27.855	2026-05-12 21:17:32.264	\N	0	SYNC_USER_FULL	DONE	\N
f2b91736-7645-4f53-84c1-74dc4a3fb890	{"name": "DANNERSON", "userId": "46b3376a-973a-454b-9347-52808613a768", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620645685.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:17:28.606	2026-05-12 21:17:33.879	\N	0	SYNC_USER_FULL	DONE	\N
40d47cc3-1e26-4b60-93be-e81c38a28d20	{"name": "DANNERSON", "userId": "46b3376a-973a-454b-9347-52808613a768", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620645685.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:17:29.511	2026-05-12 21:17:35.367	\N	0	SYNC_USER_FULL	DONE	\N
843fd95c-1002-4471-ba92-2b84ba9f8da1	{"name": "DANNERSON", "userId": "46b3376a-973a-454b-9347-52808613a768", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620645685.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:17:38.848	2026-05-12 21:17:42.647	\N	0	SYNC_USER_FULL	DONE	\N
5db9c68b-ee64-46c3-a9fd-c9d32dfda9bb	{"name": "GUSTAVO BERNAL", "userId": "cecd7a56-d246-49de-a3ce-4a051757ef8e", "endDate": "2026-06-23T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620690651.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:18:12.412	2026-05-12 21:18:17.138	\N	0	SYNC_USER_FULL	DONE	\N
c5cf0395-1566-471e-9e9b-0ec5e0657693	{"name": "GUSTAVO BERNAL", "userId": "cecd7a56-d246-49de-a3ce-4a051757ef8e", "endDate": "2026-06-23T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620690651.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:18:15.056	2026-05-12 21:18:18.599	\N	0	SYNC_USER_FULL	DONE	\N
131b6e5f-04c0-457f-a6b3-8ce63b8fc906	{"name": "ANDRIU MEJIA", "userId": "bb057365-37cd-4fad-8943-037032987734", "endDate": "2026-08-04T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620758134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:19:20.575	2026-05-12 21:19:25.359	\N	0	SYNC_USER_FULL	DONE	\N
f0fad590-6eb1-44ea-8bb9-b2325f0dc845	{"name": "JOSE CARLOS CAMACHO", "userId": "eac9fb5f-186e-4f90-9e2c-fece5ed96835", "endDate": "2026-12-31T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:32:19.41	2026-05-12 21:32:23.239	\N	0	SYNC_USER_FULL	DONE	\N
a903358e-9a7e-4525-b6ab-032cd7d1aea4	{"name": "JOSE CARLOS CAMACHO", "userId": "eac9fb5f-186e-4f90-9e2c-fece5ed96835", "endDate": "2026-12-31T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:32:23.43	2026-05-12 21:32:26.853	\N	0	SYNC_USER_FULL	DONE	\N
6274ef27-1871-4a4e-bc75-43cd40b17207	{"name": "JOSE CARLOS FRANCO", "userId": "d71a7af2-a465-4e4b-8b32-b30ac472da3b", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:33:22.088	2026-05-12 21:33:25.904	\N	0	SYNC_USER_FULL	DONE	\N
af0eec28-1740-488c-94cb-d2c09ca4b372	{"name": "JOSE CARLOS FRANCO", "userId": "d71a7af2-a465-4e4b-8b32-b30ac472da3b", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:33:24.015	2026-05-12 21:33:27.642	\N	0	SYNC_USER_FULL	DONE	\N
4e17a4e3-3bfc-40ac-af28-86eac8f84928	{"name": "MAGDALENA SEGUNDO", "userId": "b6a72b15-3214-47ef-86a5-ece55f53fd51", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:54:55.078	2026-05-13 00:54:58.885	\N	0	SYNC_USER_FULL	DONE	\N
e3b67e0b-d520-4f7e-8eee-06939dd7d75c	{"name": "DAVID NAJAYA", "userId": "362f0976-10f2-4896-bf47-e235e3717892", "endDate": "2026-08-09T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778612473739.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:01:20.531	2026-05-12 19:01:24.956	\N	0	SYNC_USER_FULL	DONE	\N
d3591321-14e0-4c3a-b6e3-193c6964c031	{"name": "ANDRIU MEJIA", "userId": "bb057365-37cd-4fad-8943-037032987734", "endDate": "2026-08-04T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620758134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:19:21.589	2026-05-12 21:19:26.81	\N	0	SYNC_USER_FULL	DONE	\N
33f13ca0-76ae-44b8-ab53-b38fbd93ff1e	{"name": "JOSE MANUEL", "userId": "6dc66c97-7553-4a32-9a45-5a2af414128e", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:53:57.453	2026-05-12 21:54:00.856	\N	0	SYNC_USER_FULL	DONE	\N
d1825e63-f41d-4676-912d-56adbd2619ca	{"name": "EDGAR CUELLAR", "userId": "4cce917b-f231-48d0-ada5-5fed6e41c148", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778612566849.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:02:53.001	2026-05-12 19:02:57.621	\N	0	SYNC_USER_FULL	DONE	\N
fb7afe97-7370-421f-8dc6-72dc0e5851a3	{"name": "ANDRIU MEJIA", "userId": "bb057365-37cd-4fad-8943-037032987734", "endDate": "2026-08-04T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620758134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:19:29.578	2026-05-12 21:19:33.292	\N	0	SYNC_USER_FULL	DONE	\N
d9063618-ab9e-4308-999e-ebde4d8d56b1	{"name": "ISMAEL CARRILLO", "userId": "ba334f9c-4d8a-4c94-acd5-9823d0d60e1f", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:04:20.961	2026-05-12 19:04:31.147	\N	0	SYNC_USER_FULL	DONE	\N
5d89fda9-3382-404c-91e3-484fb3019322	{"name": "ISRAEL ALBINO", "userId": "74422af8-42f6-45da-a515-3d6f4251fdb7", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:05:27.249	2026-05-12 19:05:31.072	\N	0	SYNC_USER_FULL	DONE	\N
bde6bb19-7263-415b-b099-6dfa892c8c9b	{"name": "ANDRIU MEJIA", "userId": "bb057365-37cd-4fad-8943-037032987734", "endDate": "2026-08-04T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620758134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:19:33.318	2026-05-12 21:19:36.444	\N	0	SYNC_USER_FULL	DONE	\N
77b4377a-a26f-4678-a577-35b7e8a846be	{"name": "ANDRIU MEJIA", "userId": "bb057365-37cd-4fad-8943-037032987734", "endDate": "2026-08-04T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620758134.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:19:51.591	2026-05-12 21:19:55.806	\N	0	SYNC_USER_FULL	DONE	\N
d69058cb-410e-4cf6-b403-5ce84ebdee3c	{"name": "JOSE DAVID CAMPOS", "userId": "54f921fb-0c0c-4cc1-b6e8-f60d54403705", "endDate": "2026-07-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:34:22.679	2026-05-12 21:34:26.725	\N	0	SYNC_USER_FULL	DONE	\N
0483e937-6012-4fbd-908e-c88769596663	{"name": "HERMAN CABALLERO", "userId": "d4d3380f-768c-4bab-86ac-c0779227db6f", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622088053.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:41:30.058	2026-05-12 21:41:34.407	\N	0	SYNC_USER_FULL	DONE	\N
364ec8be-f2cc-4f25-a860-8738054795a5	{"name": "HERMAN CABALLERO", "userId": "d4d3380f-768c-4bab-86ac-c0779227db6f", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622088053.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:41:36.173	2026-05-12 21:41:39.821	\N	0	SYNC_USER_FULL	DONE	\N
64e71098-a8e8-4897-8cea-a0fa9dfe3b3c	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:42:42.667	2026-05-12 21:42:47.489	\N	0	SYNC_USER_FULL	DONE	\N
0e56e4f3-e0e8-41d5-968e-89b0809d978b	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:42:50.121	2026-05-12 21:42:53.787	\N	0	SYNC_USER_FULL	DONE	\N
fc7f489d-7730-415d-b672-2dd1486940f0	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:42:59.729	2026-05-12 21:43:03.263	\N	0	SYNC_USER_FULL	DONE	\N
e4a99678-b5f0-4095-8cb1-0a85a3a2aa6f	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:43:00.422	2026-05-12 21:43:04.804	\N	0	SYNC_USER_FULL	DONE	\N
e180ff00-8d83-415a-83c0-6b4f9ba333ab	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:43:01.009	2026-05-12 21:43:06.408	\N	0	SYNC_USER_FULL	DONE	\N
a4d9c77b-e89c-4dea-8526-4886ca7cd495	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:43:03.425	2026-05-12 21:43:09.543	\N	0	SYNC_USER_FULL	DONE	\N
d5949010-a905-4c03-84e7-72208b2abd5c	{"name": "KEVIN RUIZ", "userId": "c1d47b2a-2f9a-486e-8750-afa7479dcf9b", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:28:45.94	2026-05-12 23:28:49.728	\N	0	SYNC_USER_FULL	DONE	\N
f292eda3-bcff-4d8f-a3b3-adeae661bfae	{"name": "ISRAEL ALBINO", "userId": "74422af8-42f6-45da-a515-3d6f4251fdb7", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:05:51.916	2026-05-12 19:05:55.884	\N	0	SYNC_USER_FULL	DONE	\N
0dc86ad8-b5b4-43fe-8e7e-e41cf9182024	{"name": "JORGE FERNANDEZ", "userId": "beea360c-2426-45c5-ad86-8d97db9ee8e3", "endDate": "2026-08-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:21:58.268	2026-05-12 21:22:02.133	\N	0	SYNC_USER_FULL	DONE	\N
8d60f969-0517-4721-9299-7cb2b93d8fb3	{"name": "JOSE FRANCISCO", "userId": "d87b5051-a000-447b-bd0b-721aabc3d207", "endDate": "2026-08-02T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622562328.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:49:32.141	2026-05-12 21:49:35.76	\N	0	SYNC_USER_FULL	DONE	\N
b43371f0-dcc2-47d9-a876-7c33030309da	{"name": "JOSE FRANCISCO", "userId": "d87b5051-a000-447b-bd0b-721aabc3d207", "endDate": "2026-08-02T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622562328.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:49:37.829	2026-05-12 21:49:41.785	\N	0	SYNC_USER_FULL	DONE	\N
1a3e9ee6-6703-48db-9ceb-5cef8ca6cbb1	{"name": "CRISTIAN", "userId": "8d558a91-928d-48b5-81d5-0c16dcf8bd23", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620942231.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:22:24.38	2026-05-12 21:22:29.274	\N	0	SYNC_USER_FULL	DONE	\N
6b2b00a4-473a-44f8-89b0-c188040fc66e	{"name": "CRISTIAN", "userId": "8d558a91-928d-48b5-81d5-0c16dcf8bd23", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620942231.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:22:25.215	2026-05-12 21:22:30.73	\N	0	SYNC_USER_FULL	DONE	\N
b7edd660-bc7a-41c8-885a-885b846118a1	{"name": "CRISTIAN", "userId": "8d558a91-928d-48b5-81d5-0c16dcf8bd23", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620942231.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:22:42.619	2026-05-12 21:22:46.909	\N	0	SYNC_USER_FULL	DONE	\N
1fb8cb37-bc20-47a2-be9d-a00617858522	{"name": "JOSE FRANCISCO", "userId": "d87b5051-a000-447b-bd0b-721aabc3d207", "endDate": "2026-08-02T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622562328.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:49:41.971	2026-05-12 21:49:45.09	\N	0	SYNC_USER_FULL	DONE	\N
1aeb168e-458c-41df-84a0-e5c45957209a	{"name": "JOSE DAVID CAMPOS", "userId": "54f921fb-0c0c-4cc1-b6e8-f60d54403705", "endDate": "2026-07-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:34:24.964	2026-05-12 21:34:28.386	\N	0	SYNC_USER_FULL	DONE	\N
335f776a-0f4a-47be-b9d1-5681a9531ef5	{"name": "JOSE LUIS HEREDIA", "userId": "f49f8b5e-b72d-4b45-a8a1-7216d1012065", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:51:46.004	2026-05-12 21:51:49.836	\N	0	SYNC_USER_FULL	DONE	\N
2ae303d9-ae4c-41da-95a6-bbc97e1357f4	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:43:04.158	2026-05-12 21:43:11.18	\N	0	SYNC_USER_FULL	DONE	\N
5edb6685-e404-4196-8fd9-974d4d56e1c2	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:43:05.978	2026-05-12 21:43:12.869	\N	0	SYNC_USER_FULL	DONE	\N
a79171c3-8e52-4c8f-aaf6-a0cb6bd22d18	{"name": "JOSE LUIS HEREDIA", "userId": "f49f8b5e-b72d-4b45-a8a1-7216d1012065", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:51:51.654	2026-05-12 21:51:55.092	\N	0	SYNC_USER_FULL	DONE	\N
3dabdce6-9d2f-4fc9-afa4-15d740545c3f	{"name": "JOSE MANUEL", "userId": "6dc66c97-7553-4a32-9a45-5a2af414128e", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:53:55.165	2026-05-12 21:53:59.023	\N	0	SYNC_USER_FULL	DONE	\N
90532b38-7f1e-49fa-a32c-85fb5cbc4324	{"name": "JOSE MANUEL", "userId": "67b9ada8-e7e2-4bf9-83c1-7b23812d77fc", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:55:10.29	2026-05-12 21:55:14.173	\N	0	SYNC_USER_FULL	DONE	\N
40986963-b640-4d76-90b4-679290261e7e	{"name": "JOSE FERNANDO JALDIN", "userId": "cd0f5594-8495-4bc3-9178-fc0e8855c19d", "endDate": "2026-12-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:44:20.048	2026-05-12 21:44:23.912	\N	0	SYNC_USER_FULL	DONE	\N
6e4cb1f6-d078-4081-8348-0b1eb52e7003	{"name": "JOSE FERNANDO JALDIN", "userId": "cd0f5594-8495-4bc3-9178-fc0e8855c19d", "endDate": "2026-12-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:44:22.253	2026-05-12 21:44:25.669	\N	0	SYNC_USER_FULL	DONE	\N
b2d7801e-2f8e-4493-897d-fc89a3401c48	{"name": "JOSE MARIA ZENTENO", "userId": "9be71f64-715b-4309-a173-09080275a11c", "endDate": "2027-02-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:56:02.829	2026-05-12 21:56:06.641	\N	0	SYNC_USER_FULL	DONE	\N
900b1c85-dd52-4076-9ab3-435c0e958202	{"name": "JOSE FRANCISCO", "userId": "d87b5051-a000-447b-bd0b-721aabc3d207", "endDate": "2026-08-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:45:20.193	2026-05-12 21:45:24.083	\N	0	SYNC_USER_FULL	DONE	\N
9b1a7de5-506e-4d2b-91eb-3d4b6aaf311c	{"name": "RUBEN SANGUINO", "userId": "49230980-23d7-40cf-8372-abb87aff12ec", "endDate": "2026-08-09T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:34:20.411	2026-05-13 16:34:24.239	\N	0	SYNC_USER_FULL	DONE	\N
855c6cd3-6a05-49ad-8959-5d8bda1634ad	{"name": "ISRAEL ALBINO", "userId": "74422af8-42f6-45da-a515-3d6f4251fdb7", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:05:53.991	2026-05-12 19:05:57.587	\N	0	SYNC_USER_FULL	DONE	\N
d9d1a1cb-1179-41c6-9d03-e1c10c233288	{"name": "JORGE GONZALES", "userId": "379fc5f6-7b00-4ef1-a411-653cc3f32eec", "endDate": "2026-11-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:24:46.655	2026-05-12 21:24:50.513	\N	0	SYNC_USER_FULL	DONE	\N
d7173c4f-2745-4898-830d-82d018190110	{"name": "JACKELIN", "userId": "f5545853-41a1-46e2-a7ca-70a3c7714f1b", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:06:48.807	2026-05-12 19:06:52.608	\N	0	SYNC_USER_FULL	DONE	\N
d159a109-c96f-4f2e-83ca-72a2a7802ea5	{"name": "JAIRO", "userId": "b169a84a-1256-4ae8-bc9f-308629274744", "endDate": "2026-05-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:08:40.349	2026-05-12 19:08:44.2	\N	0	SYNC_USER_FULL	DONE	\N
f4719ced-eeeb-405d-9694-ba3b47bd05f5	{"name": "JAQUELINE ARZA", "userId": "baac22f8-b5cf-424d-a275-7921088e18d0", "endDate": "2026-07-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:10:06.302	2026-05-12 19:10:10.07	\N	0	SYNC_USER_FULL	DONE	\N
ccf6c303-3246-412c-a388-64590e9e5cc1	{"name": "JAQUELINE ARZA", "userId": "baac22f8-b5cf-424d-a275-7921088e18d0", "endDate": "2026-07-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:10:11.763	2026-05-12 19:10:15.164	\N	0	SYNC_USER_FULL	DONE	\N
c8326d6e-6bd5-4684-89ac-f1e06c80f5ad	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:11:54.138	2026-05-12 19:11:57.995	\N	0	SYNC_USER_FULL	DONE	\N
85be9945-9a21-4a7c-b574-029e78711b45	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:11:58.394	2026-05-12 19:12:01.797	\N	0	SYNC_USER_FULL	DONE	\N
5e0730e1-0ea1-4007-b034-b25fddab661d	{"name": "AURELIO CAMPOS", "userId": "0d168b57-fe6f-433d-82db-2a0fcc1ee953", "endDate": "2026-12-28T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778613536122.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:18:58.68	2026-05-12 19:19:03.566	\N	0	SYNC_USER_FULL	DONE	\N
0bf9eeb6-8d76-40d0-9cca-2fc80d4b4ff3	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614859587.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:41:04.359	2026-05-12 19:41:09.189	\N	0	SYNC_USER_FULL	DONE	\N
1525374b-9116-4d67-86ee-5d901be5a996	{"name": "CARLOS HURTADO", "userId": "33b29244-f779-42e2-9721-71e39a4ad98d", "endDate": "2027-12-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614916428.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:42:00.075	2026-05-12 19:42:04.93	\N	0	SYNC_USER_FULL	DONE	\N
331ac669-b672-4a37-9ef5-c81ad197e4b6	{"name": "CARLOS HURTADO", "userId": "33b29244-f779-42e2-9721-71e39a4ad98d", "endDate": "2027-12-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614916428.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:42:04.593	2026-05-12 19:42:07.794	\N	0	SYNC_USER_FULL	DONE	\N
b9e9c8cc-bfa7-4632-845a-f04256121047	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614859587.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:42:26.657	2026-05-12 19:42:30.611	\N	0	SYNC_USER_FULL	DONE	\N
85e722f0-87fa-4c90-9883-ff0c5c3c5fc5	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614859587.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:42:32.517	2026-05-12 19:42:36.369	\N	0	SYNC_USER_FULL	DONE	\N
e72c4cdb-d73b-4f6e-b982-76733a5d8981	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614859587.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:43:32.532	2026-05-12 19:43:36.315	\N	0	SYNC_USER_FULL	DONE	\N
b571d360-90ad-4c37-b4c6-3b0df8476985	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614859587.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:43:33.342	2026-05-12 19:43:37.658	\N	0	SYNC_USER_FULL	DONE	\N
f1f41a66-f3f9-45d8-b356-329cbebc4e8e	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614859587.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:43:34.08	2026-05-12 19:43:39.185	\N	0	SYNC_USER_FULL	DONE	\N
5a926025-5a4c-46ac-a7d8-7d1b0fe04e05	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778614859587.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 19:43:34.423	2026-05-12 19:43:40.607	\N	0	SYNC_USER_FULL	DONE	\N
c93fa4af-c38e-4f22-af78-273fbe6e2d19	{"name": "ANDREA LOPEZ", "userId": "b5e69f4c-51bd-410a-9b57-44092888994b", "endDate": "2026-08-05T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778616035334.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:00:41.343	2026-05-12 20:00:45.969	\N	0	SYNC_USER_FULL	DONE	\N
caa00759-ab50-4acf-9bd4-c162096ff022	{"name": "JOSE FRANCISCO", "userId": "d87b5051-a000-447b-bd0b-721aabc3d207", "endDate": "2026-08-02T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622562328.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:49:30.372	2026-05-12 21:49:34.156	\N	0	SYNC_USER_FULL	DONE	\N
0e30a1ff-8d13-4e9a-ae2b-4644c0ba2b2b	{"name": "LAURA PEREZ", "userId": "b81a3908-21e5-472a-a121-ddb763d21638", "endDate": "2026-07-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778616508071.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:08:58.551	2026-05-12 20:09:03.482	\N	0	SYNC_USER_FULL	DONE	\N
dada4f74-1922-4b3a-99b9-88528e856cb5	{"name": "LAURA CUELLAR", "userId": "c04cc4b4-b36a-42ae-8782-cae4187bf140", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:29:59.458	2026-05-12 23:30:03.332	\N	0	SYNC_USER_FULL	DONE	\N
53c0fe9a-98da-41e2-ac21-3127e4a8dfd9	{"name": "JORGE GONZALES", "userId": "379fc5f6-7b00-4ef1-a411-653cc3f32eec", "endDate": "2026-11-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:24:48.462	2026-05-12 21:24:52.289	\N	0	SYNC_USER_FULL	DONE	\N
f0669606-fde5-4200-af19-346441d089f3	{"name": "JOSE MANUEL", "userId": "67b9ada8-e7e2-4bf9-83c1-7b23812d77fc", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:55:12.418	2026-05-12 21:55:15.884	\N	0	SYNC_USER_FULL	DONE	\N
cf546665-20df-490e-b564-8d2ccd5c7181	{"name": "JORGE MARTINEZ", "userId": "d6ccad63-d87c-4ed1-9c65-e54fd66bb3e6", "endDate": "2026-07-03T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:25:55.36	2026-05-12 21:25:59.28	\N	0	SYNC_USER_FULL	DONE	\N
0825a91e-3dd8-4d86-8d33-7abe89dc1bc8	{"name": "JORGE MARTINEZ", "userId": "d6ccad63-d87c-4ed1-9c65-e54fd66bb3e6", "endDate": "2026-07-03T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:25:57.18	2026-05-12 21:26:00.988	\N	0	SYNC_USER_FULL	DONE	\N
0aab1631-0869-4f12-870e-e8be66a0b390	{"name": "GERALDINE", "userId": "6da1b4bc-9d7b-4e8a-9705-6db15a76787b", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621199679.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:26:51.006	2026-05-12 21:26:55.876	\N	0	SYNC_USER_FULL	DONE	\N
65b0bfe7-84a0-48e5-a03d-5393134f3e88	{"name": "GERALDINE", "userId": "6da1b4bc-9d7b-4e8a-9705-6db15a76787b", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621199679.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:26:52.414	2026-05-12 21:26:57.514	\N	0	SYNC_USER_FULL	DONE	\N
00718565-c1ec-403d-87c4-aaba82957971	{"name": "JORGE RODRIGUEZ", "userId": "22d2c6ac-46bd-4361-80d7-284c5b1caf12", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:27:51.299	2026-05-12 21:27:55.154	\N	0	SYNC_USER_FULL	DONE	\N
d3d12584-5751-4181-a133-d7ee5b934fd9	{"name": "JORGE RODRIGUEZ", "userId": "22d2c6ac-46bd-4361-80d7-284c5b1caf12", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:27:58.313	2026-05-12 21:28:01.89	\N	0	SYNC_USER_FULL	DONE	\N
2f408c91-0dd5-4f11-bb87-88ffd1c5c73c	{"name": "CARLOS PONCE", "userId": "8182fce0-79cf-4297-b088-eab44cfabaa7", "endDate": "2026-05-16T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621300634.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:28:24.585	2026-05-12 21:28:29.321	\N	0	SYNC_USER_FULL	DONE	\N
466fb09f-9500-407c-affd-0627cb22dbcb	{"name": "CARLOS PONCE", "userId": "8182fce0-79cf-4297-b088-eab44cfabaa7", "endDate": "2026-05-16T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621300634.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:28:34.766	2026-05-12 21:28:38.882	\N	0	SYNC_USER_FULL	DONE	\N
48e43280-2850-4059-9fc3-4c28acd1878e	{"name": "JOSE DIAZ", "userId": "797ad34d-0c09-4b19-b41f-f85d9b7b2734", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:35:37.352	2026-05-12 21:35:41.16	\N	0	SYNC_USER_FULL	DONE	\N
4c7514ce-8343-4aad-aaea-406147cfe22c	{"name": "JOSE DIAZ", "userId": "797ad34d-0c09-4b19-b41f-f85d9b7b2734", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:35:39.442	2026-05-12 21:35:42.948	\N	0	SYNC_USER_FULL	DONE	\N
f5eec822-6c70-4161-b757-b07fddb124f8	{"name": "JOSE EDUARDO ROCA", "userId": "cf1d4f92-80ff-4993-8bdd-71ace8489f2a", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:36:40.351	2026-05-12 21:36:44.207	\N	0	SYNC_USER_FULL	DONE	\N
93699652-a7e6-44f5-ab5e-4a711f8fee55	{"name": "JOSE EDUARDO ROCA", "userId": "cf1d4f92-80ff-4993-8bdd-71ace8489f2a", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:36:42.526	2026-05-12 21:36:45.931	\N	0	SYNC_USER_FULL	DONE	\N
382de6eb-3c43-45fa-81e8-c1c0dc8d3fb2	{"name": "FLOWER", "userId": "b135bed0-a17e-4242-986f-edb3304896fb", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621851296.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:37:34.311	2026-05-12 21:37:38.956	\N	0	SYNC_USER_FULL	DONE	\N
89345ecf-06f9-431e-8acd-b488a675aa0e	{"name": "FLOWER", "userId": "b135bed0-a17e-4242-986f-edb3304896fb", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621851296.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:37:40.912	2026-05-12 21:37:44.528	\N	0	SYNC_USER_FULL	DONE	\N
05dfe138-f0f6-45f6-b07a-4ccff18a2f8e	{"name": "DIEGO COPANA", "userId": "8f52ede8-a0ca-4924-9587-69a8ee6c21c7", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622160868.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:43:01.616	2026-05-12 21:43:08.044	\N	0	SYNC_USER_FULL	DONE	\N
d94c01bb-2e94-4ca3-95f7-ed16ed2a7f87	{"name": "MARCELO MEJIA", "userId": "5440c9e7-eef4-482f-acb4-cd742a255eeb", "endDate": "2026-07-22T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:55:42.031	2026-05-13 00:55:45.811	\N	0	SYNC_USER_FULL	DONE	\N
880dc65b-23c2-4acb-8164-7916cd2ceffa	{"name": "LAURA PEREZ", "userId": "b81a3908-21e5-472a-a121-ddb763d21638", "endDate": "2026-07-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778616508071.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:09:00.505	2026-05-12 20:09:04.975	\N	0	SYNC_USER_FULL	DONE	\N
790c119d-e10e-4fb1-860f-ef9ae7dec8ce	{"name": "GALILEA", "userId": "5b3d0c68-6cf8-4656-9464-78e30b791b3b", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778611242881.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:25:07.49	2026-05-12 20:25:12.206	\N	0	SYNC_USER_FULL	DONE	\N
ce3e87d4-5311-4501-978f-488ac9894d49	{"name": "GALILEA", "userId": "5b3d0c68-6cf8-4656-9464-78e30b791b3b", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778611242881.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:25:10.498	2026-05-12 20:25:13.999	\N	0	SYNC_USER_FULL	DONE	\N
04ea29c9-d1bb-460d-bc09-dac318bd6463	{"name": "CLAUDIA PEDRAZA", "userId": "cfc79a88-47f4-4abd-9672-aa15994283c2", "endDate": "2026-11-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778617819865.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:30:22.117	2026-05-12 20:30:26.877	\N	0	SYNC_USER_FULL	DONE	\N
52015855-f984-4444-8bd2-b9a89607b08a	{"name": "DAVID VASQUEZ", "userId": "a5c2d6a4-2740-4ae5-91a8-a3287620c7af", "endDate": "2026-07-10T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:31:18.447	2026-05-12 20:31:22.257	\N	0	SYNC_USER_FULL	DONE	\N
fd2bca04-38b8-4f59-9c5a-27e1feb5e1ec	{"name": "DAVID VASQUEZ", "userId": "a5c2d6a4-2740-4ae5-91a8-a3287620c7af", "endDate": "2026-07-10T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778617891706.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:31:38.641	2026-05-12 20:31:43.485	\N	0	SYNC_USER_FULL	DONE	\N
edc5aa94-8bcc-498d-a58b-80b28c01c56b	{"name": "CARLOS URQUIZA", "userId": "dbe35b9c-74f6-4367-bc0c-e7fc2ca93d2e", "endDate": "2026-07-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778611823394.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:35:34.93	2026-05-12 20:35:39.872	\N	0	SYNC_USER_FULL	DONE	\N
0606424f-37e6-4575-80d2-b61caa7a6aa5	{"name": "CARLOS URQUIZA", "userId": "dbe35b9c-74f6-4367-bc0c-e7fc2ca93d2e", "endDate": "2026-07-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778611823394.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:35:45.329	2026-05-12 20:35:49.099	\N	0	SYNC_USER_FULL	DONE	\N
bd9909f3-1294-491d-a9d6-75ac1802ce0f	{"name": "IGNACIO MENDIETA", "userId": "90068245-1458-4fce-96f7-e7547a9bbb02", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778618192989.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:36:40.702	2026-05-12 20:36:45.448	\N	0	SYNC_USER_FULL	DONE	\N
5262de26-347f-496e-ba96-3c3502525204	{"name": "DAVID VACA", "userId": "9bbc1ece-99fa-4616-9161-c83db51aa25b", "endDate": "2026-11-18T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778618506302.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:41:49.922	2026-05-12 20:41:54.755	\N	0	SYNC_USER_FULL	DONE	\N
7d8332ea-3472-4b66-b264-e0111d0822ab	{"name": "DAVID VACA", "userId": "9bbc1ece-99fa-4616-9161-c83db51aa25b", "endDate": "2026-11-18T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778618506302.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:41:52.163	2026-05-12 20:41:56.293	\N	0	SYNC_USER_FULL	DONE	\N
ac77ea82-3f2a-4265-82e5-006e8d77aaf8	{"name": "DECKER", "userId": "fbd8d867-0df5-494d-b277-742b3c39f86e", "endDate": "2026-06-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:57:26.995	2026-05-12 20:57:30.893	\N	0	SYNC_USER_FULL	DONE	\N
c3ae65bb-5b4d-43e5-ba5b-3a6ed01576ee	{"name": "DECKER", "userId": "fbd8d867-0df5-494d-b277-742b3c39f86e", "endDate": "2026-06-23T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778619455155.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:57:40.961	2026-05-12 20:57:45.344	\N	0	SYNC_USER_FULL	DONE	\N
181512f3-44fc-451c-a89e-af25a7d5d7fc	{"name": "JAVIER LAFUENTE", "userId": "3fefeb34-8abe-4ecb-9508-03bb2395346f", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 20:59:29.491	2026-05-12 20:59:32.957	\N	0	SYNC_USER_FULL	DONE	\N
293503ee-e323-4230-96f4-7dae5bcc5c18	{"name": "JENNIFER ALVAREZ", "userId": "ca2be13a-9176-4b43-8314-40eaed72027e", "endDate": "2026-07-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:02:46.756	2026-05-12 21:02:50.642	\N	0	SYNC_USER_FULL	DONE	\N
3ead48f3-0d9b-4f2d-a960-eed027267f56	{"name": "JENNIFER ALVAREZ", "userId": "ca2be13a-9176-4b43-8314-40eaed72027e", "endDate": "2026-07-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:04:28.871	2026-05-12 21:04:32.284	\N	0	SYNC_USER_FULL	DONE	\N
08de7c77-d213-48f6-93e3-9dbbdb76197e	{"name": "JHON GOMEZ", "userId": "ec14ca7c-31a4-46df-8252-348b4ecc126f", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:06:33.333	2026-05-12 21:06:36.876	\N	0	SYNC_USER_FULL	DONE	\N
0bd4d886-f437-4701-a62a-d8954af8acb1	{"name": "JHONNY SEVERICHE", "userId": "2b87e871-aade-4f8d-a6be-726da730ef6b", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:07:44.36	2026-05-12 21:07:48.173	\N	0	SYNC_USER_FULL	DONE	\N
5e53f392-0b4d-41f3-bf4a-a9d2568f35d4	{"name": "JILIAN ROCHA", "userId": "b32d71f7-2d8f-4923-a2b4-604f640aca69", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:09:13.475	2026-05-12 21:09:17.257	\N	0	SYNC_USER_FULL	DONE	\N
c08b90f8-f1ca-443b-85d2-c334c4e37027	{"name": "JOSE LUIS VILLAVICIENCIO", "userId": "6b502b54-1620-4ac2-91d8-9aebf17bce83", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:52:42.049	2026-05-12 21:52:46.281	\N	0	SYNC_USER_FULL	DONE	\N
6234c0f6-b60b-49e9-8234-5dbc75f01740	{"name": "ANIBAL", "userId": "1eeaa250-9d9d-45ae-86d6-295537c409ec", "endDate": "2026-05-23T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620192180.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:09:56.117	2026-05-12 21:10:00.416	\N	0	SYNC_USER_FULL	DONE	\N
ba409c55-4afa-45ff-85ae-874600d6d0aa	{"name": "JORGE ZEBALLOS", "userId": "2c473852-96e3-4f0e-9448-e4b290899f36", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:30:01.736	2026-05-12 21:30:06.083	\N	0	SYNC_USER_FULL	DONE	\N
0359014b-0590-435b-93c6-0f6d4144877f	{"name": "ANIBAL", "userId": "1eeaa250-9d9d-45ae-86d6-295537c409ec", "endDate": "2026-05-23T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778620192180.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:10:13.217	2026-05-12 21:10:17.377	\N	0	SYNC_USER_FULL	DONE	\N
d90785a5-54be-418b-bf0a-77d7e47cc406	{"name": "JORGE ZEBALLOS", "userId": "2c473852-96e3-4f0e-9448-e4b290899f36", "endDate": "2026-05-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:30:05.286	2026-05-12 21:30:08.757	\N	0	SYNC_USER_FULL	DONE	\N
14111b5b-141a-47c7-bfae-85a0a5924978	{"name": "JOEL DAVID", "userId": "505eb8af-b8be-4b0f-8074-9bcddc422b2b", "endDate": "2026-07-15T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:11:22.221	2026-05-12 21:11:25.596	\N	0	SYNC_USER_FULL	DONE	\N
2382047b-9c50-4c69-928e-3480ec536abb	{"name": "JOEL PRADO", "userId": "49d4bf67-6569-4e44-bf96-b80f210fda92", "endDate": "2026-06-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:12:38.308	2026-05-12 21:12:42.141	\N	0	SYNC_USER_FULL	DONE	\N
1e6979ae-f9b3-44e4-99bb-0426475a0b44	{"name": "JOSE ARMANDO", "userId": "87bdd0ce-dffe-4452-b101-1d9da394055e", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:31:11.911	2026-05-12 21:31:15.755	\N	0	SYNC_USER_FULL	DONE	\N
54d62d80-a33e-4934-b65c-ef4b8fda84f2	{"name": "JOEL PRADO", "userId": "49d4bf67-6569-4e44-bf96-b80f210fda92", "endDate": "2026-06-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:12:44.688	2026-05-12 21:12:48.366	\N	0	SYNC_USER_FULL	DONE	\N
da8ce28e-ec65-4661-90ad-64b3103f548a	{"name": "JOEL VILELA", "userId": "bcdfe6c0-f61a-4831-88f3-f284058d8ce6", "endDate": "2026-06-22T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:13:48.987	2026-05-12 21:13:52.82	\N	0	SYNC_USER_FULL	DONE	\N
9fbfb789-0190-476b-ac58-0733f93c1dd8	{"name": "JOEL VILELA", "userId": "bcdfe6c0-f61a-4831-88f3-f284058d8ce6", "endDate": "2026-06-22T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:13:53.371	2026-05-12 21:13:56.79	\N	0	SYNC_USER_FULL	DONE	\N
eb4da4e8-de5b-4b83-85d4-9ba78517e47c	{"name": "JOSE FERNANDEZ", "userId": "c25e7f8e-c698-41c0-9a66-76f2bc76f445", "endDate": "2026-05-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:38:45.746	2026-05-12 21:38:49.656	\N	0	SYNC_USER_FULL	DONE	\N
a6c744fb-ccdd-48e2-a6aa-7c35656fdbb0	{"name": "JOSE FERNANDEZ", "userId": "c25e7f8e-c698-41c0-9a66-76f2bc76f445", "endDate": "2026-05-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:38:47.532	2026-05-12 21:38:51.611	\N	0	SYNC_USER_FULL	DONE	\N
53778e86-5c3b-4017-93d4-95bc789470da	{"name": "DIEGO BARBA", "userId": "32794fba-4901-47d7-a3d9-3282c5a6ff37", "endDate": "2026-07-03T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621968179.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:39:30.502	2026-05-12 21:39:35.249	\N	0	SYNC_USER_FULL	DONE	\N
a6e1095d-165b-43b5-a14c-c95e07c6aea9	{"name": "DIEGO BARBA", "userId": "32794fba-4901-47d7-a3d9-3282c5a6ff37", "endDate": "2026-07-03T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778621968179.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:39:37.37	2026-05-12 21:39:41.219	\N	0	SYNC_USER_FULL	DONE	\N
81503ce4-682b-4524-97c5-1f603bc2af27	{"name": "JOSE IGNACIO", "userId": "f9d58793-cd3e-4920-8118-7b5adf42c467", "endDate": "2026-09-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:47:14.143	2026-05-12 21:47:17.557	\N	0	SYNC_USER_FULL	DONE	\N
872a09da-0af3-4584-9533-a4cf9356f4e1	{"name": "JOSE IGNACIO", "userId": "f9d58793-cd3e-4920-8118-7b5adf42c467", "endDate": "2026-09-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:47:16.397	2026-05-12 21:47:19.859	\N	0	SYNC_USER_FULL	DONE	\N
ff0faa2f-e28a-4802-b0c8-b2683ae16a28	{"name": "DAYANA ROMERO", "userId": "9594524b-f9d7-4866-a709-1b5b72561c43", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622507953.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:48:32.188	2026-05-12 21:48:36.484	\N	0	SYNC_USER_FULL	DONE	\N
bc5284d8-3df2-43b9-aa23-55740c60c9c5	{"name": "DAYANA ROMERO", "userId": "9594524b-f9d7-4866-a709-1b5b72561c43", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778622507953.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:48:38.181	2026-05-12 21:48:41.847	\N	0	SYNC_USER_FULL	DONE	\N
d573ddba-9c44-45cd-93e7-8d56e2aa9d71	{"name": "LAURA VALERIANO", "userId": "9ccea574-c459-44a0-8558-d1d49048d9d4", "endDate": "2026-06-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-04T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:31:35.029	2026-05-12 23:31:38.83	\N	0	SYNC_USER_FULL	DONE	\N
50644bcb-236b-484e-8724-bd9f08d3d897	{"name": "LIDIA CANAVIRI", "userId": "1eeac0f0-9d77-4b64-a4fe-18fb5624b490", "endDate": "2027-01-31T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-29T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:42:12.501	2026-05-12 23:42:15.903	\N	0	SYNC_USER_FULL	DONE	\N
9521efaf-07cf-46ab-8e0c-5e32b06fe439	{"name": "JOSE MARIA ZENTENO", "userId": "9be71f64-715b-4309-a173-09080275a11c", "endDate": "2027-02-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:56:04.337	2026-05-12 21:56:08.384	\N	0	SYNC_USER_FULL	DONE	\N
7ff952bc-e1e7-496e-8b47-4ba8d0335777	{"name": "LUIS ALBERTO", "userId": "93318a74-e5ae-48f6-a025-6a7630befe98", "endDate": "2026-09-25T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:56:55.863	2026-05-12 23:56:59.852	\N	0	SYNC_USER_FULL	DONE	\N
5cf41ca9-68fc-4f51-9d4b-220b3325c1fd	{"name": "MARCIA ELENA", "userId": "7bcd2dac-1caf-446a-bba4-0003811ecf54", "endDate": "2026-07-10T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:56:44.934	2026-05-13 00:56:48.742	\N	0	SYNC_USER_FULL	DONE	\N
1719896a-d7bb-4ba6-86e8-f6c0e490aed0	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:57:00.174	2026-05-12 21:57:04.037	\N	0	SYNC_USER_FULL	DONE	\N
1abaed0e-8450-4585-9055-ab6ebef5eefe	{"name": "DIEGO RODRIGUEZ", "userId": "f0517e12-07ae-4354-968e-6ce837a59958", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630309259.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:58:30.873	2026-05-12 23:58:34.614	\N	0	SYNC_USER_FULL	DONE	\N
f4499050-5572-48ca-81b8-1498d454a5ff	{"name": "DIEGO RODRIGUEZ", "userId": "f0517e12-07ae-4354-968e-6ce837a59958", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630335344.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:58:57.052	2026-05-12 23:59:01.178	\N	0	SYNC_USER_FULL	DONE	\N
d2e9c74c-ad0a-419a-8b6d-e7d07847eb60	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:57:04.919	2026-05-12 21:57:08.398	\N	0	SYNC_USER_FULL	DONE	\N
ef179c0c-e68a-4514-a126-dba5ac4174e2	{"name": "MILENKA ALVAREZ", "userId": "0df96f01-7d7d-40b2-b83c-dffb32335f08", "endDate": "2026-06-12T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630787384.jpg", "startDate": "2026-05-13T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:06:45.866	2026-05-13 00:06:50.668	\N	0	SYNC_USER_FULL	DONE	7841a82c-a595-4818-a494-9fee6bd1249c
d0541f7b-aaad-4550-a43d-f7d16c67a104	{"name": "ERICK CHOQUE", "userId": "5fe6f94e-3a05-4ce8-8a40-a4836cb14536", "endDate": "2026-07-31T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630975528.jpg", "startDate": "2026-05-01T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:10:27.142	2026-05-13 00:10:32.084	\N	0	SYNC_USER_FULL	DONE	\N
ada3765a-6a8d-457d-9bc2-4d1630a6f4ce	{"name": "ERICK CHOQUE", "userId": "5fe6f94e-3a05-4ce8-8a40-a4836cb14536", "endDate": "2026-07-31T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630975528.jpg", "startDate": "2026-05-01T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:10:29.556	2026-05-13 00:10:33.772	\N	0	SYNC_USER_FULL	DONE	\N
692c5708-070b-4a1c-b6a0-40bae5e2dce9	{"name": "LUIS MENACHO", "userId": "372cbe81-d2cc-42f7-a123-8f0abe4d4364", "endDate": "2026-06-16T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-04T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:20:25.644	2026-05-13 00:20:29.436	\N	0	SYNC_USER_FULL	DONE	\N
8a4cdd5c-1cef-4b36-8b0e-3a5046a7b1df	{"name": "LUIS ROSAS", "userId": "e440e085-b757-49b4-b2c4-5032f05e0894", "endDate": "2026-11-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:21:29.86	2026-05-13 00:21:33.412	\N	0	SYNC_USER_FULL	DONE	\N
26bcb45c-06cc-43c0-815b-fecb0b68e2f3	{"name": "ISMAEL CARRILLO", "userId": "ba334f9c-4d8a-4c94-acd5-9823d0d60e1f", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778631740493.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:22:23.82	2026-05-13 00:22:29.016	\N	0	SYNC_USER_FULL	DONE	\N
91e58e09-9137-4170-a74e-d6bee570908e	{"name": "JOSE FERNANDO JALDIN", "userId": "cd0f5594-8495-4bc3-9178-fc0e8855c19d", "endDate": "2026-12-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778631778188.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:23:00.303	2026-05-13 00:23:04.866	\N	0	SYNC_USER_FULL	DONE	\N
cadf3fe6-3cf0-4ca4-bdbe-7ab2921f88bd	{"name": "JOSE FERNANDO JALDIN", "userId": "cd0f5594-8495-4bc3-9178-fc0e8855c19d", "endDate": "2026-12-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778631778188.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:23:01.132	2026-05-13 00:23:06.439	\N	0	SYNC_USER_FULL	DONE	\N
6f213d7b-0ede-46dd-be07-b1804b9f575c	{"name": "ISMAEL CARRILLO", "userId": "ba334f9c-4d8a-4c94-acd5-9823d0d60e1f", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778631824353.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:23:46.023	2026-05-13 00:23:50.33	\N	0	SYNC_USER_FULL	DONE	\N
9fbb12b9-2dea-47bc-b4dc-ae943f1388f7	{"name": "ISMAEL CARRILLO", "userId": "ba334f9c-4d8a-4c94-acd5-9823d0d60e1f", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778631824353.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:23:46.824	2026-05-13 00:23:51.969	\N	0	SYNC_USER_FULL	DONE	\N
0dd58c88-072d-4ac4-9bf9-6bcda44104c9	{"name": "RUBEN SANGUINO", "userId": "49230980-23d7-40cf-8372-abb87aff12ec", "endDate": "2026-08-09T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:37:30.402	2026-05-13 16:37:34.232	\N	0	SYNC_USER_FULL	DONE	\N
a37f9eb0-8be7-4504-abfa-ded3c3d29b5a	{"name": "JOSE SANDOVAL", "userId": "841485d8-9d42-4798-abb8-bf2ee07bbfcc", "endDate": "2026-05-17T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:58:16.985	2026-05-12 21:58:20.829	\N	0	SYNC_USER_FULL	DONE	\N
6bc6b19f-4c65-49dc-b1c3-0102b04c6d32	{"name": "LEANDRO RODRIGUEZ", "userId": "2a2eda73-fac0-40c1-adc6-3c04e4ce6514", "endDate": "2026-05-17T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-30T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:32:49.657	2026-05-12 23:32:53.596	\N	0	SYNC_USER_FULL	DONE	\N
61e22c20-a2d7-4ba8-9acb-4265d532de4c	{"name": "LEO ANTEZANA", "userId": "f3826acb-1d1e-4b78-be81-49089d60bfa5", "endDate": "2026-06-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:34:01.103	2026-05-12 23:34:05.066	\N	0	SYNC_USER_FULL	DONE	\N
ab8c0a99-77d0-40fb-98c8-8dbc94625ecc	{"name": "LIA PINTO", "userId": "a3befa2b-236e-47a7-9707-99f3f4990cc1", "endDate": "2027-04-12T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:35:13.919	2026-05-12 23:35:17.765	\N	0	SYNC_USER_FULL	DONE	\N
a7c1b295-7933-4fb1-8f0f-20a350fdd359	{"name": "GUSTAVO CHUGUIÑA", "userId": "55eb10c9-a707-479f-bbc9-c8e19760dcf3", "endDate": "2026-06-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778628964244.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:36:06.014	2026-05-12 23:36:10.828	\N	0	SYNC_USER_FULL	DONE	\N
254a6178-1688-4bd7-93a4-ffc300578089	{"name": "GUSTAVO CHUGUIÑA", "userId": "55eb10c9-a707-479f-bbc9-c8e19760dcf3", "endDate": "2026-06-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778628964244.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:36:06.858	2026-05-12 23:36:12.474	\N	0	SYNC_USER_FULL	DONE	\N
5d68b8a5-8608-4b61-a860-20cbf2696efc	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778628993965.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:36:35.544	2026-05-12 23:36:40.026	\N	0	SYNC_USER_FULL	DONE	\N
82191258-9cd2-4528-b05f-5f043f829819	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778628993965.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:36:45.135	2026-05-12 23:36:49.788	\N	0	SYNC_USER_FULL	DONE	\N
2bf8de07-d020-412d-9ae5-1f0aa079a807	{"name": "BRAYAN", "userId": "f848e6ae-09d8-461a-83bc-9c82e5c9167d", "endDate": "2026-05-27T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629535679.jpg", "startDate": "2026-04-27T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:45:37.511	2026-05-12 23:45:42.119	\N	0	SYNC_USER_FULL	DONE	\N
61b9ae33-549c-40a7-90d9-99c944f9fdba	{"name": "JORGE BARBA", "userId": "8bc3f30b-309c-42f7-9f52-046e95de6276", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629689001.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:48:11.189	2026-05-12 23:48:15.464	\N	0	SYNC_USER_FULL	DONE	\N
a255a98a-531d-4731-b5cb-c4328232401a	{"name": "JORGE BARBA", "userId": "8bc3f30b-309c-42f7-9f52-046e95de6276", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629689001.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:48:11.918	2026-05-12 23:48:17.347	\N	0	SYNC_USER_FULL	DONE	\N
8add2b84-75c0-4cc1-8b9b-04fb2ce652fa	{"name": "JORGE BARBA", "userId": "8bc3f30b-309c-42f7-9f52-046e95de6276", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629749946.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:49:11.524	2026-05-12 23:49:16.493	\N	0	SYNC_USER_FULL	DONE	\N
1e9680f9-49cd-454f-b701-17aeb36e6163	{"name": "JORGE BARBA", "userId": "8bc3f30b-309c-42f7-9f52-046e95de6276", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629749946.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:49:12.293	2026-05-12 23:49:18.071	\N	0	SYNC_USER_FULL	DONE	\N
6e59e324-6c9e-4d0d-8527-d783bf9d6ab3	{"name": "JULIAN ARANDIA", "userId": "d8f28584-b77e-47ea-a759-360927038451", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629791448.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:49:53.087	2026-05-12 23:49:57.786	\N	0	SYNC_USER_FULL	DONE	\N
42ae677e-b18b-41bb-adfe-f891c9a2e614	{"name": "DIEGO RODRIGUEZ", "userId": "f0517e12-07ae-4354-968e-6ce837a59958", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630309259.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:58:31.626	2026-05-12 23:58:36.352	\N	0	SYNC_USER_FULL	DONE	\N
90e56666-f094-45fd-9b0c-834e23bdf22a	{"name": "DIEGO RODRIGUEZ", "userId": "f0517e12-07ae-4354-968e-6ce837a59958", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630309259.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:58:44.886	2026-05-12 23:58:49.106	\N	0	SYNC_USER_FULL	DONE	\N
9fa02db5-e12e-4ee8-b128-d2ab24382a1c	{"name": "DIEGO RODRIGUEZ", "userId": "f0517e12-07ae-4354-968e-6ce837a59958", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630335344.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:58:57.78	2026-05-12 23:59:02.949	\N	0	SYNC_USER_FULL	DONE	\N
f7723358-9848-4cd9-84f5-22986bd940ff	{"name": "LUIS AYALA", "userId": "a7381c69-fedf-41b9-904c-b27d92dd738c", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:14:45.249	2026-05-13 00:14:48.7	\N	0	SYNC_USER_FULL	DONE	\N
aca22255-c4e5-4efb-9dd6-de88717e4db3	{"name": "MARCO MAMANI", "userId": "da9da632-114e-47ab-aa02-73575091fe50", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-29T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:57:48.525	2026-05-13 00:57:52.403	\N	0	SYNC_USER_FULL	DONE	\N
1417bdd0-ad09-4e5a-a347-a09117e1df68	{"name": "JOSE SANDOVAL", "userId": "841485d8-9d42-4798-abb8-bf2ee07bbfcc", "endDate": "2026-05-17T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:58:19.484	2026-05-12 21:58:22.892	\N	0	SYNC_USER_FULL	DONE	\N
f1272013-d407-49ae-94d7-82c93bdf8e20	{"name": "JOSUE GOITA", "userId": "37cf83a2-fc07-48a3-a239-9decbb397fc2", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:59:10.23	2026-05-12 21:59:14.107	\N	0	SYNC_USER_FULL	DONE	\N
4c25b948-1118-4267-a14e-152dc1687494	{"name": "JOSUE GOITA", "userId": "37cf83a2-fc07-48a3-a239-9decbb397fc2", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 21:59:12.329	2026-05-12 21:59:15.811	\N	0	SYNC_USER_FULL	DONE	\N
0a517d94-6ab3-4505-8c1f-eb79ba369e2d	{"name": "JOSUE RIBERA", "userId": "4179fe20-cdc2-4058-9a98-0fcb9f6f871b", "endDate": "2027-03-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:00:24.157	2026-05-12 22:00:28.082	\N	0	SYNC_USER_FULL	DONE	\N
801e0b21-29de-4194-bb87-f6496845bc5d	{"name": "JOSUE RIBERA", "userId": "4179fe20-cdc2-4058-9a98-0fcb9f6f871b", "endDate": "2027-03-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:00:26.269	2026-05-12 22:00:29.838	\N	0	SYNC_USER_FULL	DONE	\N
f418ddeb-47ba-459c-b68a-a9d837fc1fcd	{"name": "JUAN FLORES", "userId": "78536aa7-702e-4c71-be4d-60338c11a054", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:01:36.566	2026-05-12 22:01:40.408	\N	0	SYNC_USER_FULL	DONE	\N
83c7696d-6506-4e5a-b35f-1c9eb376ac15	{"name": "JUAN FLORES", "userId": "78536aa7-702e-4c71-be4d-60338c11a054", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:01:41.417	2026-05-12 22:01:44.871	\N	0	SYNC_USER_FULL	DONE	\N
5000da11-16a0-497d-9bee-6298e5616b16	{"name": "JUAN PARDO", "userId": "3e1075af-dbda-4157-95a1-64e356170021", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:03:22.846	2026-05-12 22:03:26.628	\N	0	SYNC_USER_FULL	DONE	\N
267703b7-7af0-4c8b-b483-b17508f90117	{"name": "JOSE DIAZ", "userId": "797ad34d-0c09-4b19-b41f-f85d9b7b2734", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778623474306.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:04:36.143	2026-05-12 22:04:40.906	\N	0	SYNC_USER_FULL	DONE	\N
db21c9cb-508a-4798-9954-be9697a1f617	{"name": "JOSE DIAZ", "userId": "797ad34d-0c09-4b19-b41f-f85d9b7b2734", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778623474306.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:04:50.21	2026-05-12 22:04:54.277	\N	0	SYNC_USER_FULL	DONE	\N
ac0e9ce0-cac0-4945-9777-0174fd0cc7f9	{"name": "JULIAN ARANDIA", "userId": "d8f28584-b77e-47ea-a759-360927038451", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:05:35.589	2026-05-12 22:05:39.443	\N	0	SYNC_USER_FULL	DONE	\N
a9d02b15-4645-4883-b4ef-be3896bfacc0	{"name": "JULIAN ARANDIA", "userId": "d8f28584-b77e-47ea-a759-360927038451", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:05:38.978	2026-05-12 22:05:42.384	\N	0	SYNC_USER_FULL	DONE	\N
e0e8416d-408e-4159-8d8e-1c0eb6018176	{"name": "JOSUE GOITA", "userId": "37cf83a2-fc07-48a3-a239-9decbb397fc2", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778623626418.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:07:11.555	2026-05-12 22:07:15.844	\N	0	SYNC_USER_FULL	DONE	\N
2fb81258-b8a4-4159-8e76-042fd9a21f3c	{"name": "JOSUE GOITA", "userId": "37cf83a2-fc07-48a3-a239-9decbb397fc2", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778623626418.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:07:17.989	2026-05-12 22:07:21.474	\N	0	SYNC_USER_FULL	DONE	\N
238f1653-aac4-4b72-8e77-dc83053e0595	{"name": "JOSUE GOITA", "userId": "37cf83a2-fc07-48a3-a239-9decbb397fc2", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778623626418.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:07:57.962	2026-05-12 22:08:01.918	\N	0	SYNC_USER_FULL	DONE	\N
447746a8-4bc9-48ba-80db-5370f7308914	{"name": "JOSUE GOITA", "userId": "37cf83a2-fc07-48a3-a239-9decbb397fc2", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778623626418.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:08:07.159	2026-05-12 22:08:11.233	\N	0	SYNC_USER_FULL	DONE	\N
cb6306bf-a001-40d2-b7f5-57f37867e859	{"name": "JULIO CESAR AVILA", "userId": "a13eb0da-fca8-4fdd-b069-d9ee31d84c81", "endDate": "2026-06-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:09:24.024	2026-05-12 22:09:27.957	\N	0	SYNC_USER_FULL	DONE	\N
2d3f4f8e-6ee7-430b-b582-b66a6bd2e807	{"name": "Cristian Ortiz", "userId": "d02259bf-0b2d-4a79-bd29-1d892299585a", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778522224485.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:10:42.167	2026-05-12 22:10:46.322	\N	0	SYNC_USER_FULL	DONE	\N
ddddd9d7-94a1-4dc4-ac53-628b2821d990	{"name": "Cristian Ortiz", "userId": "d02259bf-0b2d-4a79-bd29-1d892299585a", "endDate": "2026-06-10T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778522224485.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:10:43.868	2026-05-12 22:10:47.86	\N	0	SYNC_USER_FULL	DONE	\N
4ec408fa-c368-4076-9dc3-a5e0ec4819fa	{"name": "JULIO CESAR RODRIGUEZ", "userId": "2c0aa1d4-f3f7-44e2-8516-a724e2990d3b", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:11:59.187	2026-05-12 22:12:03.125	\N	0	SYNC_USER_FULL	DONE	\N
d1262a8b-1546-43e7-b677-0f17017f58ca	{"name": "JULIO CESAR RODRIGUEZ", "userId": "2c0aa1d4-f3f7-44e2-8516-a724e2990d3b", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:12:49.343	2026-05-12 22:12:53.126	\N	0	SYNC_USER_FULL	DONE	\N
d46ccece-f710-4e25-93fc-0b9b2bd4321e	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629027342.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:37:09.534	2026-05-12 23:37:13.288	\N	0	SYNC_USER_FULL	DONE	\N
9e303ad1-9cd2-41b9-abc0-56e1dbfbdbc8	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:00.602	2026-05-12 22:14:05.453	\N	0	SYNC_USER_FULL	DONE	\N
4f1f7228-080b-4162-8f0f-4731a421d315	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629027342.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:37:10.249	2026-05-12 23:37:15.32	\N	0	SYNC_USER_FULL	DONE	\N
f5cfecac-d89e-40e6-b2f1-166d2c6c1b72	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:09.961	2026-05-12 22:14:13.556	\N	0	SYNC_USER_FULL	DONE	\N
bcd00f0f-9d2c-4ed5-a007-228f35b6d4fa	{"name": "LUCAS DIAZ", "userId": "f28ec386-5e47-49d3-a7b2-3c7f82eb99d0", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-04T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:50:58.132	2026-05-12 23:51:02.144	\N	0	SYNC_USER_FULL	DONE	\N
673f841d-4c65-4a9b-80ea-30fd6379589b	{"name": "LUCIA MENESES", "userId": "fdd4d29f-3bd9-435a-a36d-572f60c87955", "endDate": "2026-05-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:52:29.682	2026-05-12 23:52:33.164	\N	0	SYNC_USER_FULL	DONE	\N
55b5c7b4-87c3-4bf1-a83b-6840b96ddb5e	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778201314416.jpg", "startDate": "2026-05-05T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:54:50.149	2026-05-12 23:54:54.612	\N	0	SYNC_USER_FULL	DONE	\N
7540af4f-0d5d-440a-945c-65eaea3da5cc	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630101307.jpg", "startDate": "2026-05-05T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:55:03.38	2026-05-12 23:55:08.22	\N	0	SYNC_USER_FULL	DONE	\N
61821574-5180-461f-8a86-982e1c358589	{"name": "JULIO CESAR", "userId": "29d96077-cf65-4862-93f5-650250ea47a7", "endDate": "2026-07-15T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630101307.jpg", "startDate": "2026-05-05T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:55:04.129	2026-05-12 23:55:09.817	\N	0	SYNC_USER_FULL	DONE	\N
719e283e-2278-4fdc-97c1-fb38f0db0d8c	{"name": "LIDIA", "userId": "40696459-c69c-477c-843e-a1e1ab4ab577", "endDate": "2026-05-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630476812.jpg", "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:01:20.914	2026-05-13 00:01:25.351	\N	0	SYNC_USER_FULL	DONE	\N
5cbcaccd-4ac2-49c8-84b9-27a30be09d56	{"name": "ARIEL OROPEZA", "userId": "2ba743d2-858b-4e21-950e-ea4f87925874", "endDate": "2027-02-05T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630548892.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:02:30.719	2026-05-13 00:02:34.556	\N	0	SYNC_USER_FULL	DONE	\N
b63e1c86-8dda-4f4e-bdf9-2d7ac7ac0dda	{"name": "ARIEL OROPEZA", "userId": "2ba743d2-858b-4e21-950e-ea4f87925874", "endDate": "2027-02-05T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778630548892.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:02:31.487	2026-05-13 00:02:36.555	\N	0	SYNC_USER_FULL	DONE	\N
7006c7f6-e95c-4b63-a246-9ba389cb7ad9	{"name": "LUIS CARDOZO", "userId": "e3035eb7-c298-4c9c-a3b8-8b9c6eae36c8", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:15:57.212	2026-05-13 00:16:01.319	\N	0	SYNC_USER_FULL	DONE	\N
00b0db3f-6a51-4e64-a13e-0feca169b455	{"name": "LUIS JUSTINIANO", "userId": "8d19ba4d-33cb-4b5a-9088-c22a5086b8a0", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:17:05.226	2026-05-13 00:17:09.088	\N	0	SYNC_USER_FULL	DONE	\N
e8699c28-b1ba-4bfd-a2fb-409656f68573	{"name": "ISMAEL CARRILLO", "userId": "ba334f9c-4d8a-4c94-acd5-9823d0d60e1f", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778631740493.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:22:22.87	2026-05-13 00:22:27.098	\N	0	SYNC_USER_FULL	DONE	\N
403803cf-56e2-4356-9a9b-cf8747ba54b7	{"name": "DAVID FLORES", "userId": "f75051f4-22b0-4de2-ac4d-cba8b447b15b", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632123975.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:28:46.602	2026-05-13 00:28:51.618	\N	0	SYNC_USER_FULL	DONE	\N
c5ac2f3d-9c75-42c7-a619-6fc1dc04d7f0	{"name": "MARIA ANGELICA", "userId": "1328b3bb-1baf-4201-8f7d-9621e1e98589", "endDate": "2026-05-12T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-30T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:58:43.659	2026-05-13 00:58:47.669	\N	0	SYNC_USER_FULL	DONE	\N
811e7971-b6fc-4c3d-8f9d-845c5718a2f6	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:11.081	2026-05-12 22:14:14.969	\N	0	SYNC_USER_FULL	DONE	\N
105930bb-b0a1-4865-ac83-67b460463961	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:12.233	2026-05-12 22:14:16.451	\N	0	SYNC_USER_FULL	DONE	\N
33bb2f3f-e2ba-4beb-9282-7bcc17137d54	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:12.755	2026-05-12 22:14:18.114	\N	0	SYNC_USER_FULL	DONE	\N
0c75d746-3323-43fe-97d2-3481e9b80d8a	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:17.429	2026-05-12 22:14:20.633	\N	0	SYNC_USER_FULL	DONE	\N
4c9776b8-6d3c-4a21-b0ff-3ba9dc014a0d	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:21.205	2026-05-12 22:14:24.423	\N	0	SYNC_USER_FULL	DONE	\N
e9d6c292-f3bf-4a38-ad8d-da05f70b679b	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:21.585	2026-05-12 22:14:25.968	\N	0	SYNC_USER_FULL	DONE	\N
5814f051-3fbc-4f9d-92bb-eee2e2617ffd	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:21.84	2026-05-12 22:14:27.508	\N	0	SYNC_USER_FULL	DONE	\N
0a5c02c2-a1cb-4c0f-a114-b7e6f38b105e	{"name": "DANIEL GUZMAN", "userId": "050cf9da-0342-4d7f-9c90-7bdd84ff86cd", "endDate": "2027-01-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624038471.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:14:22.065	2026-05-12 22:14:29.081	\N	0	SYNC_USER_FULL	DONE	\N
4cd3c803-cad9-440d-9df8-79ab2d7487cb	{"name": "CARLOS ROJAS", "userId": "5116038b-94be-4b71-8ff3-b03ab527f2f3", "endDate": "2027-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624292376.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:18:15.381	2026-05-12 22:18:20.195	\N	0	SYNC_USER_FULL	DONE	\N
b086f144-4680-435e-be34-5e7483ffb891	{"name": "CARLOS ROJAS", "userId": "5116038b-94be-4b71-8ff3-b03ab527f2f3", "endDate": "2027-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624292376.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:18:16.132	2026-05-12 22:18:21.563	\N	0	SYNC_USER_FULL	DONE	\N
7bea43f4-44bb-43e8-ab7d-8c64b4cf47aa	{"name": "CARLOS ROJAS", "userId": "5116038b-94be-4b71-8ff3-b03ab527f2f3", "endDate": "2027-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624292376.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:18:17.077	2026-05-12 22:18:23.065	\N	0	SYNC_USER_FULL	DONE	\N
ff59ed00-67fb-4b97-90ab-ec2a78febbc5	{"name": "DAYANA JUSTINIANO", "userId": "e39a48bf-3739-40b2-aecb-166da5fbbe56", "endDate": "2027-07-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624447570.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:20:49.319	2026-05-12 22:20:54.451	\N	0	SYNC_USER_FULL	DONE	\N
0e4c0ce4-73ec-46e7-bb9c-46c14b7e17b8	{"name": "DAYANA JUSTINIANO", "userId": "e39a48bf-3739-40b2-aecb-166da5fbbe56", "endDate": "2027-07-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624447570.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:20:53.794	2026-05-12 22:20:57.036	\N	0	SYNC_USER_FULL	DONE	\N
5ab3ff6d-7945-4ded-9bed-5f1a465ee7d6	{"name": "ALFREDO PINTO", "userId": "228e67db-3041-48eb-9a81-b759bd96c248", "endDate": "2026-05-20T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624489483.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:21:31.167	2026-05-12 22:21:35.724	\N	0	SYNC_USER_FULL	DONE	\N
7f708b2f-a8d6-4ed3-aa76-abdd4db20196	{"name": "ALFREDO PINTO", "userId": "228e67db-3041-48eb-9a81-b759bd96c248", "endDate": "2026-05-20T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624489483.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:21:31.997	2026-05-12 22:21:37.295	\N	0	SYNC_USER_FULL	DONE	\N
f2bf3689-7eae-4e8f-b121-48e16470b50b	{"name": "JOSE CARLOS FRANCO", "userId": "d71a7af2-a465-4e4b-8b32-b30ac472da3b", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778624999099.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:30:01.272	2026-05-12 22:30:06.57	\N	0	SYNC_USER_FULL	DONE	\N
ef263176-d44f-4430-b1ba-ad61534651c0	{"name": "ANDRES CALLE", "userId": "f5aa5643-fd47-4b8f-b4d7-57a6b988f7af", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778545076846.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:39:06.072	2026-05-12 22:39:10.94	\N	0	SYNC_USER_FULL	DONE	\N
5997650c-fdad-4a5b-9031-7d488e71d5fe	{"name": "RUPERT PEÑARANDA", "userId": "b8a6b8df-3daf-4ded-89bd-aaf7a4bde2a1", "endDate": "2026-07-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:39:09.451	2026-05-13 16:39:13.268	\N	0	SYNC_USER_FULL	DONE	\N
bb320fb7-c463-4e58-8657-2ac3833e515b	{"name": "ANDRES CALLE", "userId": "f5aa5643-fd47-4b8f-b4d7-57a6b988f7af", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778545076846.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:39:10.126	2026-05-12 22:39:13.299	\N	0	SYNC_USER_FULL	DONE	\N
135ac150-e4db-4974-9c90-af74e641e0e6	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778629027342.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:38:00.592	2026-05-12 23:38:04.313	\N	0	SYNC_USER_FULL	DONE	\N
f032ab05-17cd-4733-86aa-5fe13a7adcfb	{"name": "CRISTIAN BESERRA", "userId": "cb6fe7ed-48ce-496d-a3c0-dc3df9ec5ffd", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778625633709.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:40:35.68	2026-05-12 22:40:40.412	\N	0	SYNC_USER_FULL	DONE	\N
e4e3ed48-a32d-483c-bcf3-bd782fde08f1	{"name": "LIDIA", "userId": "40696459-c69c-477c-843e-a1e1ab4ab577", "endDate": "2026-05-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:39:02.592	2026-05-12 23:39:06.471	\N	0	SYNC_USER_FULL	DONE	\N
e311591c-cd65-4700-a5d7-1b1aa054dad5	{"name": "JULIO EDUARDO", "userId": "03222926-4b5b-4f24-90ec-275aef476bd6", "endDate": "2026-12-30T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:44:10.442	2026-05-12 22:44:14.291	\N	0	SYNC_USER_FULL	DONE	\N
2d443d6b-c286-4c2b-b0dc-43dc97f5b8f5	{"name": "KAMELLY", "userId": "b89d7a62-ead2-4730-a8d5-bceacaeab00a", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:45:19.437	2026-05-12 22:45:23.215	\N	0	SYNC_USER_FULL	DONE	\N
7ad1865f-c47e-40bc-a853-57643ed883cd	{"name": "KAREN VILLARROEL", "userId": "ef8719ef-4f37-40e2-bc60-906284743842", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:48:54.412	2026-05-12 22:48:57.835	\N	0	SYNC_USER_FULL	DONE	\N
97a94fbe-bfec-4da6-b0cd-4360ac88b098	{"name": "ARIEL OROPEZA", "userId": "2ba743d2-858b-4e21-950e-ea4f87925874", "endDate": "2027-02-05T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778626395214.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:53:17.114	2026-05-12 22:53:21.552	\N	0	SYNC_USER_FULL	DONE	\N
2edca34a-8957-4542-ac0e-7c192297fbdd	{"name": "GERARDO RIVERA", "userId": "906b4106-180d-4f75-8247-af6db3955a39", "endDate": "2026-07-30T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778626422281.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:53:44.066	2026-05-12 22:53:48.906	\N	0	SYNC_USER_FULL	DONE	\N
9b553bef-1fed-4df1-9d3f-666c9e65408f	{"name": "GERARDO RIVERA", "userId": "906b4106-180d-4f75-8247-af6db3955a39", "endDate": "2026-07-30T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778626422281.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:53:45.731	2026-05-12 22:53:50.314	\N	0	SYNC_USER_FULL	DONE	\N
23a790cf-538d-4c25-9f55-b31bf36ce611	{"name": "JOSE MANUEL", "userId": "6dc66c97-7553-4a32-9a45-5a2af414128e", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778626468572.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:54:30.151	2026-05-12 22:54:34.539	\N	0	SYNC_USER_FULL	DONE	\N
8ee65db9-fdcb-4c29-995d-da6bb269a965	{"name": "ISAAC", "userId": "b269dee8-ffb7-483b-93fc-3a466072cb8d", "endDate": "2026-05-15T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778626492247.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:54:53.757	2026-05-12 22:54:58.694	\N	0	SYNC_USER_FULL	DONE	\N
145d4cda-dfd9-4e3e-b0d0-a11f24f019ef	{"name": "KAMELLY", "userId": "b89d7a62-ead2-4730-a8d5-bceacaeab00a", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778626517618.jpg", "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:55:19.275	2026-05-12 22:55:24.126	\N	0	SYNC_USER_FULL	DONE	\N
a4a5305e-3c53-4226-b05f-7b890665fc65	{"name": "KAMELLY", "userId": "b89d7a62-ead2-4730-a8d5-bceacaeab00a", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778626517618.jpg", "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 22:55:20.042	2026-05-12 22:55:25.811	\N	0	SYNC_USER_FULL	DONE	\N
a699bf04-e929-4236-afcd-8c52e7bee52f	{"name": "KATHIA ROMERO", "userId": "d897fa6f-52cd-4f6b-aa0f-0e0d9086123d", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:16:17.178	2026-05-12 23:16:21.077	\N	0	SYNC_USER_FULL	DONE	\N
9040a552-0568-4c29-a5f0-86925a5681fe	{"name": "JAVIER LAFUENTE", "userId": "3fefeb34-8abe-4ecb-9508-03bb2395346f", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778627871578.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:17:53.201	2026-05-12 23:17:57.978	\N	0	SYNC_USER_FULL	DONE	\N
854afefc-ce40-441c-adf9-d8ec3843128b	{"name": "JAVIER LAFUENTE", "userId": "3fefeb34-8abe-4ecb-9508-03bb2395346f", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778627871578.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:18:05.873	2026-05-12 23:18:09.898	\N	0	SYNC_USER_FULL	DONE	\N
66dc8d50-9ca0-4311-b0e5-bec069f00c42	{"name": "KENJI EVER GUTIERREZ", "userId": "8ef6aab4-36e5-4e7a-92aa-f195b92e8384", "endDate": "2026-06-09T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-12 23:21:16.576	2026-05-12 23:21:20.787	\N	0	SYNC_USER_FULL	DONE	\N
f52f61a2-3d51-48d0-bf26-547d6a194e87	{"name": "MARIA COIMBRA", "userId": "128eb675-3968-406a-9549-12f6e001c6d4", "endDate": "2026-06-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:59:30.284	2026-05-13 00:59:33.681	\N	0	SYNC_USER_FULL	DONE	\N
a8cf6172-1a94-4390-9e0a-e7ec5aa07c4c	{"name": "MARIANA LEAÑOS", "userId": "9342390a-5dfd-48c7-9e59-e41c71001ba6", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-29T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:00:22.296	2026-05-13 01:00:26.141	\N	0	SYNC_USER_FULL	DONE	\N
46a3a250-eb2d-4642-b85f-0b00bc267ce5	{"name": "MARIBEL DAVALOS", "userId": "e24f9d69-46b3-4680-a25d-3a2823822d1a", "endDate": "2026-07-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:01:18.124	2026-05-13 01:01:22.075	\N	0	SYNC_USER_FULL	DONE	\N
59a2d5d4-9b1d-4b84-9de5-bbbac31fb74c	{"name": "DAVID FLORES", "userId": "f75051f4-22b0-4de2-ac4d-cba8b447b15b", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632191182.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:29:53.594	2026-05-13 00:29:58.42	\N	0	SYNC_USER_FULL	DONE	\N
5a00f7bb-4a5a-4c78-af78-ecf102a40564	{"name": "DAVID FLORES", "userId": "f75051f4-22b0-4de2-ac4d-cba8b447b15b", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632191182.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:29:54.319	2026-05-13 00:29:59.956	\N	0	SYNC_USER_FULL	DONE	\N
c1f1ab3e-32c5-4231-8358-2a1f5e244892	{"name": "DAVID FLORES", "userId": "f75051f4-22b0-4de2-ac4d-cba8b447b15b", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632191182.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:29:55.063	2026-05-13 00:30:01.541	\N	0	SYNC_USER_FULL	DONE	\N
a8c13695-d759-47fa-bbb3-5e8214a6b5bc	{"name": "CRISTIAN CUELLAR", "userId": "3695737b-64a7-47b0-86f9-58d865a70bf3", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778634198701.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:03:20.841	2026-05-13 01:03:26.703	\N	0	SYNC_USER_FULL	DONE	\N
22a5d7da-2187-43bb-9c94-1ca3148e1c79	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632400433.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:33:21.923	2026-05-13 00:33:26.177	\N	0	SYNC_USER_FULL	DONE	\N
bf7f0da7-eb49-4371-8c14-787f1f45d118	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632400433.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:33:22.627	2026-05-13 00:33:27.825	\N	0	SYNC_USER_FULL	DONE	\N
798f9708-b60a-41d2-8e8b-d97aae5030e1	{"name": "HENRY YANARICO", "userId": "3bb68dd2-5395-42c3-9605-3ed9c8cdc6d9", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778634458846.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:07:40.773	2026-05-13 01:07:45.604	\N	0	SYNC_USER_FULL	DONE	\N
e727d319-52a5-4823-b0f9-d99e3f487dc9	{"name": "HENRY YANARICO", "userId": "3bb68dd2-5395-42c3-9605-3ed9c8cdc6d9", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778634458846.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:07:41.441	2026-05-13 01:07:47.22	\N	0	SYNC_USER_FULL	DONE	\N
1d470b97-feb9-4bdd-8503-6d20609d5c17	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778635113964.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:18:35.832	2026-05-13 01:18:40.784	\N	0	SYNC_USER_FULL	DONE	\N
9dfbd194-240b-4d58-bff7-f9be9c1d99da	{"name": "MARCELO MEJIA", "userId": "5440c9e7-eef4-482f-acb4-cd742a255eeb", "endDate": "2026-07-22T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778667344661.jpg", "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 10:16:05.649	2026-05-13 10:16:19.909	\N	0	SYNC_USER_FULL	DONE	\N
2687082c-7f9e-4f12-b44f-2aafb6963646	{"name": "MARCELO MEJIA", "userId": "5440c9e7-eef4-482f-acb4-cd742a255eeb", "endDate": "2026-07-22T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778667485746.jpg", "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 10:18:26.21	2026-05-13 10:18:31.679	\N	0	SYNC_USER_FULL	DONE	\N
6e7ff6dd-5657-4e6d-8216-613fcad92155	{"name": "CINTHIA MENDOZA", "userId": "503e2c59-9329-4312-86e6-88063247b133", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778669360527.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 10:49:27.497	2026-05-13 10:49:32.274	\N	0	SYNC_USER_FULL	DONE	\N
22ed20f2-b48e-46c4-af07-5ed58a7cd371	{"name": "EMMA DURANTON", "userId": "2bd57e4f-56de-4d35-b7df-6b9a5168de6c", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778670064553.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 11:01:09.445	2026-05-13 11:01:14.79	\N	0	SYNC_USER_FULL	DONE	\N
28547137-cdc2-4056-a229-74e4b7fac28f	{"name": "CLAUDIA CORDOVA", "userId": "590a677e-2ca7-4c5c-a626-5f820e968a02", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778670838957.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 11:14:04.968	2026-05-13 11:14:09.881	\N	0	SYNC_USER_FULL	DONE	\N
c53e02e0-9751-4e8f-a6ea-20ca8b13285a	{"name": "MARYUVI", "userId": "d3876ad7-c371-4bd9-9c51-460798e6b455", "endDate": "2026-05-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:01:06.171	2026-05-13 12:01:09.994	\N	0	SYNC_USER_FULL	DONE	\N
d0a16bac-1d5d-4f0a-b7c4-7f215b06bc88	{"name": "MATEO BANEGAS", "userId": "560bcc29-da11-4c37-a2b1-a977943bde1b", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:02:31.552	2026-05-13 12:02:35.437	\N	0	SYNC_USER_FULL	DONE	\N
2107b2a2-5a6e-4786-8be7-aca63aa79ced	{"name": "DAVID FLORES", "userId": "f75051f4-22b0-4de2-ac4d-cba8b447b15b", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632191182.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:29:52.915	2026-05-13 00:29:56.946	\N	0	SYNC_USER_FULL	DONE	\N
4641d687-007d-430d-a9a8-d7f30b697255	{"name": "ROBERTO CANDIA", "userId": "bce91afe-e91f-4890-80dc-2c4889144849", "endDate": "2026-06-12T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632455198.jpg", "startDate": "2026-05-13T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:34:27.633	2026-05-13 00:34:32.501	\N	0	SYNC_USER_FULL	DONE	1913ef86-3942-414a-a107-392ec68176d8
4ad9335c-31e0-442f-8391-383327e50cb6	{"name": "SHANTY CUELLAR", "userId": "40d039f9-47db-4f41-ba69-5a5441b377c1", "endDate": "2026-06-12T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632515789.jpg", "startDate": "2026-05-13T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:35:24.909	2026-05-13 00:35:29.961	\N	0	SYNC_USER_FULL	DONE	7a2c23f7-3610-47b8-bbe7-763ce992283e
38855c32-33b6-4b10-be89-bec869a8a62d	{"name": "CRISTIAN CUELLAR", "userId": "3695737b-64a7-47b0-86f9-58d865a70bf3", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778634198701.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:03:20.156	2026-05-13 01:03:25.003	\N	0	SYNC_USER_FULL	DONE	\N
29c04a99-b0cb-4aac-a8ae-3061fa83e26e	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:09.016	2026-05-13 00:36:13.385	\N	0	SYNC_USER_FULL	DONE	\N
3af125cc-c27a-4e04-b13c-f344b6d6059c	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:09.666	2026-05-13 00:36:15.279	\N	0	SYNC_USER_FULL	DONE	\N
9d548fdc-586e-4328-aa88-9686dad2c587	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:10.43	2026-05-13 00:36:17.301	\N	0	SYNC_USER_FULL	DONE	\N
9685f680-9a19-4678-98c7-237010454aa2	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:11.161	2026-05-13 00:36:19.281	\N	0	SYNC_USER_FULL	DONE	\N
bf3edfb9-a7dd-4e1c-a8b4-30d4ff3dfe95	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:21.859	2026-05-13 00:36:25.877	\N	0	SYNC_USER_FULL	DONE	\N
55ccf491-3392-4efe-b316-af3847010591	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:22.423	2026-05-13 00:36:27.809	\N	0	SYNC_USER_FULL	DONE	\N
765a5485-7eea-401c-ba8b-83f61c1c5c89	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:24.229	2026-05-13 00:36:29.647	\N	0	SYNC_USER_FULL	DONE	\N
8cce3235-b5e2-49cc-94e6-3171b9e1b6e4	{"name": "ELIANA SANDOVAL", "userId": "7a70fb89-7a83-4816-baae-b60466f90c2a", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632567400.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:36:24.977	2026-05-13 00:36:31.533	\N	0	SYNC_USER_FULL	DONE	\N
37f68a4b-a030-427f-8109-6833a1a07baa	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632629189.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:37:11.432	2026-05-13 00:37:15.427	\N	0	SYNC_USER_FULL	DONE	\N
37bdcf49-5b5e-4af4-bd69-c64e6a22e23f	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632629189.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:37:12.061	2026-05-13 00:37:17.467	\N	0	SYNC_USER_FULL	DONE	\N
eeb9c8e0-7792-45b6-9024-4d112c333dd4	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632629189.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:37:25.779	2026-05-13 00:37:31.167	\N	0	SYNC_USER_FULL	DONE	\N
38321842-b822-42d4-a6e7-3f4608a18872	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632629189.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:37:26.47	2026-05-13 00:37:32.843	\N	0	SYNC_USER_FULL	DONE	\N
e26c8532-e5fe-4282-b203-0c6976349de9	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632629189.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:37:27.134	2026-05-13 00:37:34.668	\N	0	SYNC_USER_FULL	DONE	\N
cbbb6a2d-a7b0-4eb5-a995-634f9921fc5b	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632629189.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:37:29.37	2026-05-13 00:37:36.421	\N	0	SYNC_USER_FULL	DONE	\N
8d5fc0c4-34a3-436a-9d2c-034fdd7ddcd1	{"name": "JOSE REINALDO", "userId": "c9a59bb0-22f9-4163-b915-e3db808c43da", "endDate": "2026-06-13T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778632629189.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:37:25.108	2026-05-13 00:37:29.407	\N	0	SYNC_USER_FULL	DONE	\N
c11368fc-7462-41fb-8213-9cac0b2052d0	{"name": "MARIELA MENDOZA", "userId": "80e6cdb2-9234-431c-a2e5-ef9ead2b6047", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:01:58.623	2026-05-13 01:02:02.455	\N	0	SYNC_USER_FULL	DONE	\N
cb8a3b38-76a5-49b8-9047-2a6f33a73b0a	{"name": "LUISSA HERRERA", "userId": "a37e6aeb-4b76-4538-bcba-e1febf1c5e43", "endDate": "2026-08-07T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-07T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:45:11.572	2026-05-13 00:45:15.414	\N	0	SYNC_USER_FULL	DONE	\N
5a7a64e9-4879-439d-8fbe-4bd1f77f6759	{"name": "JHERSON SOLIZ", "userId": "82a7c55f-ff8c-4b42-9634-c972014044dd", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778634773507.jpg", "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:14:09.682	2026-05-13 01:14:14.561	\N	0	SYNC_USER_FULL	DONE	\N
f1be9259-d52b-4e95-ba3c-099e1242e0a1	{"name": "JHERSON SOLIZ", "userId": "82a7c55f-ff8c-4b42-9634-c972014044dd", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778634773507.jpg", "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:14:13.297	2026-05-13 01:14:16.492	\N	0	SYNC_USER_FULL	DONE	\N
4910a047-39c0-40d2-b5f5-cfebfc961122	{"name": "KEVIN MATHY", "userId": "b4b33973-4a5e-4ee7-8cc5-f58b2955a51a", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633178007.jpg", "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:46:19.916	2026-05-13 00:46:24.213	\N	0	SYNC_USER_FULL	DONE	\N
b4ba8f54-595e-4152-8ede-e68ac59011ec	{"name": "KEVIN MATHY", "userId": "b4b33973-4a5e-4ee7-8cc5-f58b2955a51a", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633178007.jpg", "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:46:20.524	2026-05-13 00:46:25.748	\N	0	SYNC_USER_FULL	DONE	\N
08ddaac3-818e-4f19-b45b-30d1057a2d46	{"name": "KEVIN MATHY", "userId": "b4b33973-4a5e-4ee7-8cc5-f58b2955a51a", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633178007.jpg", "startDate": "2026-04-28T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:46:21.207	2026-05-13 00:46:27.354	\N	0	SYNC_USER_FULL	DONE	\N
fb3d0946-6f29-49d9-8635-e1cb6364ffd9	{"name": "CAROL JIMENA ALFARO", "userId": "14982bcc-b706-41bc-ad3d-3436b0a8e007", "endDate": "2026-11-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778634996990.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:16:39.217	2026-05-13 01:16:44.099	\N	0	SYNC_USER_FULL	DONE	\N
b659e5b3-454d-4ef1-b237-42aaee23b6e3	{"name": "LUIS JUSTINIANO", "userId": "8d19ba4d-33cb-4b5a-9088-c22a5086b8a0", "endDate": "2026-07-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 01:41:48.749	2026-05-13 01:42:02.345	\N	0	SYNC_USER_FULL	DONE	\N
91b0a439-ce2e-4cfc-98fe-eee4aa652d2d	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633348494.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:49:09.914	2026-05-13 00:49:14.072	\N	0	SYNC_USER_FULL	DONE	\N
4be672ea-f8ee-42be-8f1a-0201981923d9	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633348494.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:49:10.53	2026-05-13 00:49:15.677	\N	0	SYNC_USER_FULL	DONE	\N
ce8f5029-99c9-491c-b8b0-3bf0d4d2b59c	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633348494.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:49:11.204	2026-05-13 00:49:17.302	\N	0	SYNC_USER_FULL	DONE	\N
d75592a3-131a-43e0-ae0c-728f4aa30f98	{"name": "MARIA ANGELICA", "userId": "1328b3bb-1baf-4201-8f7d-9621e1e98589", "endDate": "2026-06-12T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778669167318.jpg", "startDate": "2026-05-13T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 10:46:26.161	2026-05-13 10:46:30.694	\N	0	SYNC_USER_FULL	DONE	bc9659b2-f60e-4971-9b44-024f874d7e3f
d255751f-5579-4747-bf15-cc4d0e900519	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633348494.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:49:19.444	2026-05-13 00:49:23.25	\N	0	SYNC_USER_FULL	DONE	\N
208f78fb-119a-46a9-834e-fe781c7c9f20	{"name": "FERNANDO DORADO", "userId": "332a5de3-c604-4082-ba3a-f6b2b95b13b3", "endDate": "2027-02-19T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778633348494.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 00:49:20.431	2026-05-13 00:49:25.02	\N	0	SYNC_USER_FULL	DONE	\N
4f4b6a47-3fd4-4e06-b1e5-1aae2dfec789	{"name": "JULIO CESAR AVILA", "userId": "a13eb0da-fca8-4fdd-b069-d9ee31d84c81", "endDate": "2026-06-18T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778669954058.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 10:59:18.672	2026-05-13 10:59:23.255	\N	0	SYNC_USER_FULL	DONE	\N
f1d40fc3-8322-40b1-86c2-51f57f678162	{"name": "JOSE ARMANDO", "userId": "87bdd0ce-dffe-4452-b101-1d9da394055e", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778671253842.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 11:21:01.83	2026-05-13 11:21:06.546	\N	0	SYNC_USER_FULL	DONE	\N
4da94756-f12c-409d-b9bf-076d8d6073eb	{"name": "SAMIR", "userId": "6fcab6d7-4652-483a-ae23-5ad05582d5d1", "endDate": "2026-05-22T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:40:26.264	2026-05-13 16:40:30.144	\N	0	SYNC_USER_FULL	DONE	\N
30ef27a8-13b5-422f-ae81-fada4bc7c23a	{"name": "KAREN VILLARROEL", "userId": "ef8719ef-4f37-40e2-bc60-906284743842", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778673346824.jpg", "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 11:55:53.837	2026-05-13 11:55:58.766	\N	0	SYNC_USER_FULL	DONE	\N
98be0d4a-7bf6-42e6-8fa4-9daac77ccdf5	{"name": "SEBASTIAN CUELLAR", "userId": "a927df4b-d10b-4e8e-ac02-ef5f78ee82fd", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:41:32.522	2026-05-13 16:41:36.001	\N	0	SYNC_USER_FULL	DONE	\N
1b1937d8-c9fb-419a-a1f9-f19818367816	{"name": "MICAELA VINOYA", "userId": "9fe4f4f4-9aef-443b-9d1c-3cbc3c88aba2", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778691113198.jpg", "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:52:14.21	2026-05-13 16:52:18.459	\N	0	SYNC_USER_FULL	DONE	\N
2bdd73b7-927a-4f16-8034-fcd1accbf47e	{"name": "SHIRLEY HURTADO", "userId": "cab49eaa-9177-4514-b647-279e032aab0c", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:00:48.393	2026-05-13 17:00:51.852	\N	0	SYNC_USER_FULL	DONE	\N
3c44be48-b9a3-4993-b086-67a8c646eaeb	{"name": "BENJAMIN BUITRAGO", "userId": "cdaf029c-3182-4ca9-b85b-fef51a732baf", "endDate": "2026-07-13T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778691704192.jpg", "startDate": "2026-04-27T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:01:54.37	2026-05-13 17:01:59.34	\N	0	SYNC_USER_FULL	DONE	\N
1e685bc3-b18a-4199-b63f-3f2f9ae887b8	{"name": "SHOEI", "userId": "0f8e1a36-c6b9-49b5-8ba5-ce178077c88a", "endDate": "2027-06-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:03:15.491	2026-05-13 17:03:19.247	\N	0	SYNC_USER_FULL	DONE	\N
5edb232b-e6d9-4bb5-aa20-06e0d1540c1d	{"name": "VALENTINA VARGAS", "userId": "883760f8-eeb8-4bd8-9d8d-bedb77ff8f02", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:13:44.961	2026-05-13 17:13:49.073	\N	0	SYNC_USER_FULL	DONE	\N
2dbca9a8-7853-4401-8080-2c5a3ad1b99d	{"name": "VALERIA FERNANDEZ", "userId": "e6187633-0f88-4896-a42f-8a39a9e67f88", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:14:58.895	2026-05-13 17:15:03.084	\N	0	SYNC_USER_FULL	DONE	\N
46de3ed2-d2df-4833-ad56-f62da8a01db2	{"name": "WALTER DURAN", "userId": "b91ec917-d1f3-4838-b542-09992ef68a3a", "endDate": "2026-05-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:28:18.059	2026-05-13 17:28:21.849	\N	0	SYNC_USER_FULL	DONE	\N
8c2dd70d-ad94-4803-b39b-52b53ff83a62	{"name": "WENCESLAO", "userId": "07a698a1-0f64-4f65-b8ae-f16aa203b143", "endDate": "2027-02-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:31:27.882	2026-05-13 17:31:32.059	\N	0	SYNC_USER_FULL	DONE	\N
df71c2c4-c697-4aff-9002-6e60b1d9e199	{"name": "YOJAN VARGAS", "userId": "1c21828d-94a8-4050-a546-cbca00dc17f0", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:39:08.746	2026-05-13 17:39:12.627	\N	0	SYNC_USER_FULL	DONE	\N
83d52e84-c3f6-472d-8f68-056960809d60	{"name": "YORDY ROCA FORTUNATY", "userId": "79d187ec-9603-4c9d-83d1-b3854a951c8f", "endDate": "2026-07-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:41:19.322	2026-05-13 17:41:23.192	\N	0	SYNC_USER_FULL	DONE	\N
07ee4322-0c14-416d-b008-0d00de5cc237	{"name": "YOSELIN COA", "userId": "8c12163c-ebdd-4842-bb18-7bc0f50f6fbc", "endDate": "2026-06-21T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:42:38.512	2026-05-13 17:42:42.513	\N	0	SYNC_USER_FULL	DONE	\N
3cb34317-3613-4798-b884-f4311ad2588c	{"name": "alex campo", "userId": "91c044a8-45b4-457f-b12d-f937c6fff0b5", "endDate": "2026-08-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:49:06.73	2026-05-13 17:49:10.562	\N	0	SYNC_USER_FULL	DONE	\N
286e5ea9-55d6-4159-81d9-a4ca7c9219ee	{"name": "alvaro yabeta", "userId": "ba1992b4-d270-4aff-b98f-f3c519f52354", "endDate": "2026-06-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:51:00.37	2026-05-13 17:51:04.155	\N	0	SYNC_USER_FULL	DONE	\N
49b63239-6c74-47aa-82c1-f1b0e4868d2f	{"name": "MATEO SAAVEDRA", "userId": "25719a87-74b6-4346-b6ef-3565129b507a", "endDate": "2026-12-31T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:04:54.024	2026-05-13 12:04:57.885	\N	0	SYNC_USER_FULL	DONE	\N
45566278-0b52-459a-9cdd-ca324406a103	{"name": "MATIAS MENDEZ", "userId": "d3185606-5ad8-4aca-ba11-758f0e6998f3", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:06:52.588	2026-05-13 12:06:56.449	\N	0	SYNC_USER_FULL	DONE	\N
a6d13659-aaad-4840-8d81-af447b6adf1e	{"name": "JAQUELINE ARZA", "userId": "baac22f8-b5cf-424d-a275-7921088e18d0", "endDate": "2026-07-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778674100071.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:08:28.66	2026-05-13 12:08:33.538	\N	0	SYNC_USER_FULL	DONE	\N
a2236acb-2d0d-449b-a5b6-8def9f769722	{"name": "MAURICIO  DELGADILLO", "userId": "acc4cb5d-8a05-4951-a24f-12ceec630469", "endDate": "2026-08-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:10:45.052	2026-05-13 12:10:48.931	\N	0	SYNC_USER_FULL	DONE	\N
5bfaef0d-0993-4be7-8f23-65426899ad4a	{"name": "MAYITA", "userId": "f460a0ff-b769-45ed-be64-cea480b52c05", "endDate": "2026-09-30T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:20:28.818	2026-05-13 12:20:32.667	\N	0	SYNC_USER_FULL	DONE	\N
40cba97a-6255-4577-ae4e-bd94514678d3	{"name": "MELISA FERNANDEZ", "userId": "b53b1657-5bb9-48a1-8d4c-f65861028790", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:22:05.193	2026-05-13 12:22:08.936	\N	0	SYNC_USER_FULL	DONE	\N
dc01c53c-103c-4577-ab63-39f66ccc0587	{"name": "MERY FLORES", "userId": "02717d42-a2d8-4c53-bb74-e357a250c0e2", "endDate": "2026-09-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:24:21.441	2026-05-13 12:24:25.296	\N	0	SYNC_USER_FULL	DONE	\N
8bf8ed18-c680-46d5-8ebd-e940afa1d60f	{"name": "MICAELA VINOYA", "userId": "9fe4f4f4-9aef-443b-9d1c-3cbc3c88aba2", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:26:00.393	2026-05-13 12:26:04.332	\N	0	SYNC_USER_FULL	DONE	\N
e0e527cb-fe78-44d5-988b-efd63962c185	{"name": "JOSE LUIS HEREDIA", "userId": "f49f8b5e-b72d-4b45-a8a1-7216d1012065", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778675311416.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:28:36.613	2026-05-13 12:28:41.515	\N	0	SYNC_USER_FULL	DONE	\N
f9cb39fa-e738-4e08-b4c9-bd8c24e7357a	{"name": "JUAN FLORES", "userId": "78536aa7-702e-4c71-be4d-60338c11a054", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778675388585.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:29:54.247	2026-05-13 12:29:59.341	\N	0	SYNC_USER_FULL	DONE	\N
acae7ccf-c6db-43d9-8c6d-9ee12e454579	{"name": "LAURA CUELLAR", "userId": "c04cc4b4-b36a-42ae-8782-cae4187bf140", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778675620647.jpg", "startDate": "2026-05-05T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:33:46.782	2026-05-13 12:33:51.724	\N	0	SYNC_USER_FULL	DONE	\N
6d2e6157-a797-48e2-9a1e-cefb3a388f87	{"name": "MIGUEL PAZ", "userId": "6105b207-ea61-49ce-9592-1b9c9c5a34f1", "endDate": "2026-07-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:35:30.257	2026-05-13 12:35:34.17	\N	0	SYNC_USER_FULL	DONE	\N
a4f2d09d-9a0c-41c3-9331-b949071e8f55	{"name": "MIRLAN", "userId": "a35c2c66-4c33-41de-9337-610612e3aa01", "endDate": "2026-12-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:38:24.832	2026-05-13 12:38:28.643	\N	0	SYNC_USER_FULL	DONE	\N
23bc087d-d5be-457d-b2d6-ac4a3513899f	{"name": "MOISES ALI", "userId": "97d2dd8c-fee6-46d8-a6ca-d6aaddf3bab3", "endDate": "2027-01-01T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:40:03.387	2026-05-13 12:40:07.258	\N	0	SYNC_USER_FULL	DONE	\N
482f7ebc-e6dc-4557-b63a-9eb452f30d21	{"name": "MOISES VANI", "userId": "4208e2b8-0c1c-4038-80f6-8116edd89f09", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:41:26.009	2026-05-13 12:41:29.921	\N	0	SYNC_USER_FULL	DONE	\N
9e610d18-921e-4b4f-8fa4-9e3edbd1693f	{"name": "NATHALIA", "userId": "b28ac5e8-3b26-4095-b1e7-615114dbb89f", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 12:58:02.159	2026-05-13 12:58:05.951	\N	0	SYNC_USER_FULL	DONE	\N
0871af00-8d2e-4bd9-a7a4-b17df7c97828	{"name": "NATHALIA PEDRAZA", "userId": "7028f55d-e95a-4604-9f3c-4ddb00e6ce6a", "endDate": "2026-12-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:02:02.369	2026-05-13 13:02:06.224	\N	0	SYNC_USER_FULL	DONE	\N
c88acf21-1b6c-44b1-9151-62c5af6482fd	{"name": "LEO ANTEZANA", "userId": "f3826acb-1d1e-4b78-be81-49089d60bfa5", "endDate": "2026-06-29T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778677361261.jpg", "startDate": "2026-04-27T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:02:47.07	2026-05-13 13:02:52.002	\N	0	SYNC_USER_FULL	DONE	\N
1e41535a-611a-427f-9765-2e222a1942d2	{"name": "NELSON COPA", "userId": "3edfda55-e29d-4bbd-8264-d96319e4c848", "endDate": "2026-11-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:05:11.019	2026-05-13 13:05:14.922	\N	0	SYNC_USER_FULL	DONE	\N
34534743-27e2-44cd-a9b1-82e2e3baa77c	{"name": "NELSON GARCIA", "userId": "e6e24fd8-a58e-4ec8-a9a8-0e5de15e586d", "endDate": "2026-07-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:06:47.42	2026-05-13 13:06:51.262	\N	0	SYNC_USER_FULL	DONE	\N
a44c33c4-9c3d-4507-beb2-90b84faf88ac	{"name": "NELSON ROJAS", "userId": "151e2cec-4b9f-4d7c-b435-16b040097bc8", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:08:02.164	2026-05-13 13:08:06.162	\N	0	SYNC_USER_FULL	DONE	\N
194bc00f-a95d-42b1-a93d-3865f228206d	{"name": "NICOLAS", "userId": "432c9309-25be-4937-a3bd-0fa681fc0f48", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:38:38.838	2026-05-13 13:38:42.809	\N	0	SYNC_USER_FULL	DONE	\N
45c907d6-98b6-40c3-a14e-16be2e335d9b	{"name": "Nicolas", "userId": "c56d4e2a-8930-4351-ae22-7009596945a3", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:43:01.259	2026-05-13 13:43:05.355	\N	0	SYNC_USER_FULL	DONE	\N
ca0d0cb4-4732-4b9f-9848-863948745f8b	{"name": "NICOLAS GUIMBARD", "userId": "0a503a53-66ed-4782-8e4a-a283b45aab48", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:48:32.482	2026-05-13 13:48:36.251	\N	0	SYNC_USER_FULL	DONE	\N
0cbc17f0-89c7-46d0-9466-02794d952194	{"name": "NICOLE SOLETO", "userId": "c4903655-5743-4f9b-b8e9-fe184dadf7b8", "endDate": "2026-07-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:50:37.359	2026-05-13 13:50:40.802	\N	0	SYNC_USER_FULL	DONE	\N
570ab19a-f7f9-4488-ace7-23eb05f260c9	{"name": "NINFA", "userId": "25984e47-90b6-442a-a889-bd7bb49744f7", "endDate": "2026-07-17T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:56:25.817	2026-05-13 13:56:29.709	\N	0	SYNC_USER_FULL	DONE	\N
6bf05d52-44b1-40d8-855c-d0b8ed9a0e40	{"name": "OSMAR MORENO", "userId": "daf0cd54-c39f-4bc5-b641-fee276a92778", "endDate": "2026-07-13T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 13:57:52.709	2026-05-13 13:57:56.676	\N	0	SYNC_USER_FULL	DONE	\N
46c1faf6-5c8c-4c90-8020-bd08f60918f3	{"name": "PABLO HERRERA", "userId": "1fda80ce-6bf0-4551-b364-1e5666696e2e", "endDate": "2026-08-07T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:04:03.629	2026-05-13 14:04:08.076	\N	0	SYNC_USER_FULL	DONE	\N
de89ddb3-14ad-4e33-83fa-a14418c71ba4	{"name": "PABLO SANDOVAL", "userId": "75add031-eb78-4a5e-a681-c22f896e93dd", "endDate": "2027-04-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:07:17.793	2026-05-13 14:07:21.329	\N	0	SYNC_USER_FULL	DONE	\N
1ddb552e-3359-4f5c-9446-3ef739f9e37d	{"name": "NICOLAS", "userId": "432c9309-25be-4937-a3bd-0fa681fc0f48", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778682575398.jpg", "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:29:39.508	2026-05-13 14:29:44.419	\N	0	SYNC_USER_FULL	DONE	\N
aa1ec4b4-faf7-4fc5-8dbe-c49182e7891f	{"name": "CHRIS CERVANTES", "userId": "f1d6d27a-a3f1-44b5-bdce-1d7f6d531ad4", "endDate": "2026-06-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778683217637.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:40:24.399	2026-05-13 14:40:29.105	\N	0	SYNC_USER_FULL	DONE	\N
593b2271-6c04-4805-b0e6-4da336ce83bc	{"name": "PAOLA GUAMAN", "userId": "38bb5b7f-71c7-4913-9d37-881777be2797", "endDate": "2026-11-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:44:40.969	2026-05-13 14:44:44.795	\N	0	SYNC_USER_FULL	DONE	\N
28000724-1ad0-4e62-9289-a6d69bcb3874	{"name": "PAOLA PANOZO", "userId": "caf160f2-6cfa-4d9c-9c8a-1674bd5a8918", "endDate": "2026-08-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:46:13.17	2026-05-13 14:46:17.489	\N	0	SYNC_USER_FULL	DONE	\N
3a688348-7cc8-4798-85c5-d9ae3f785545	{"name": "PATRCIA CALLEJAS", "userId": "494d0d89-097d-48e3-b153-3fb22adccbd1", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:47:34.044	2026-05-13 14:47:38.077	\N	0	SYNC_USER_FULL	DONE	\N
b03a126f-e4e7-4297-a4a9-6f35152a2b1a	{"name": "PATRICIA BUTRON", "userId": "c8e56477-6d8d-4e23-bfca-59335a3c3197", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:49:29.094	2026-05-13 14:49:32.93	\N	0	SYNC_USER_FULL	DONE	\N
66a55ff9-769e-48e2-be94-c6fa9e2eff5d	{"name": "PAUL MONTENEGRO", "userId": "7008574c-4ece-432a-b96c-ab1a811a8a98", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 14:58:47.862	2026-05-13 14:58:51.757	\N	0	SYNC_USER_FULL	DONE	\N
ae44d122-f0b6-4a25-a753-689f5abfaae3	{"name": "PÁBLO EDUARDO", "userId": "4612f9e3-113c-4aa2-afd6-4919a8355059", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:01:30.733	2026-05-13 15:01:34.266	\N	0	SYNC_USER_FULL	DONE	\N
021d9290-bef1-49e9-b558-43465fbda755	{"name": "RAFAELA MASAI", "userId": "0d207e62-7aa9-460d-9886-8a7b0f838b6a", "endDate": "2027-02-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:07:50.167	2026-05-13 15:07:54.146	\N	0	SYNC_USER_FULL	DONE	\N
f1629e7d-ca3d-4d02-b212-ddec06ddd154	{"name": "MERY FLORES", "userId": "02717d42-a2d8-4c53-bb74-e357a250c0e2", "endDate": "2026-09-26T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778684915208.jpg", "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:08:39.777	2026-05-13 15:08:44.638	\N	0	SYNC_USER_FULL	DONE	\N
209197f8-4e15-4261-adb1-4015c5ec4df4	{"name": "GARY CUELLAR", "userId": "9915570f-c0ba-467c-98c4-1b1d2e4af87a", "endDate": "2026-07-28T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778685214490.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:13:38.603	2026-05-13 15:13:43.354	\N	0	SYNC_USER_FULL	DONE	\N
bedebef4-2001-4879-94db-3e43e1c21dc1	{"name": "SEBASTIAN SALAZAR", "userId": "611de2b5-c1c8-443b-b1ce-f0a786a1cd82", "endDate": "2027-02-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:45:07.572	2026-05-13 16:45:11.425	\N	0	SYNC_USER_FULL	DONE	\N
54d2c29f-32df-4e49-856e-045198402712	{"name": "RAMIRO GOMEZ", "userId": "e32946cc-21ec-420a-9ca5-359a5f29b176", "endDate": "2026-07-03T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:18:42.197	2026-05-13 15:18:46.187	\N	0	SYNC_USER_FULL	DONE	\N
11c06b07-ae17-4ec8-ad72-ae8a0057d01c	{"name": "RAMON MENDOZA", "userId": "84d549d6-b9ff-42c5-ac56-dc15aebf58ec", "endDate": "2026-06-08T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:45:11.462	2026-05-13 15:45:15.471	\N	0	SYNC_USER_FULL	DONE	\N
86e5f928-7b0f-43f0-b989-9ce01a5a2d6b	{"name": "RANDOL COPA", "userId": "9560c458-7aef-464d-b47c-f073f1d6f3ee", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:49:58.53	2026-05-13 15:50:02.358	\N	0	SYNC_USER_FULL	DONE	\N
8f70f30b-7d53-4569-9653-13f94d602c9a	{"name": "MAURICIO  DELGADILLO", "userId": "acc4cb5d-8a05-4951-a24f-12ceec630469", "endDate": "2026-08-08T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778687523063.jpg", "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:52:07.831	2026-05-13 15:52:12.686	\N	0	SYNC_USER_FULL	DONE	\N
edd8967d-c9dc-41c1-bca6-22cb4c8b68e8	{"name": "RENY GIRONDA", "userId": "92467230-fa62-430d-a8a3-5c12541a3d70", "endDate": "2027-02-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 15:57:28.611	2026-05-13 15:57:32.465	\N	0	SYNC_USER_FULL	DONE	\N
da8ae9a4-cd04-44a9-a794-75e605be0a36	{"name": "RICHARD CALDERON", "userId": "958a722c-2b94-4350-8176-55eb498d71c9", "endDate": "2026-08-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:01:15.798	2026-05-13 16:01:19.714	\N	0	SYNC_USER_FULL	DONE	\N
724ddb14-3d35-472e-adaa-f379ae625b51	{"name": "ROBERTO HARRIAGUE", "userId": "e362210c-2556-484b-8211-a29a41576a0c", "endDate": "2026-07-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:02:43.387	2026-05-13 16:02:47.286	\N	0	SYNC_USER_FULL	DONE	\N
fa29fe34-0661-4537-8add-75ed7854a086	{"name": "ROBERTO JUSTIANO", "userId": "5cb5bbf5-4215-4c96-a91d-3659c47d7004", "endDate": "2026-05-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:11:10.785	2026-05-13 16:11:14.625	\N	0	SYNC_USER_FULL	DONE	\N
f926e756-00ff-4263-9208-b166dea3a63c	{"name": "RODRIGO", "userId": "dfe136b3-1d7d-464c-a2c2-608a20c05465", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:12:31.035	2026-05-13 16:12:35.017	\N	0	SYNC_USER_FULL	DONE	\N
b8aac6c6-3665-45b0-8dcc-ea308b4068f4	{"name": "RODRIGO FLORES", "userId": "2f5b648e-7130-4703-837a-afc3fac32aa0", "endDate": "2026-06-20T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:13:57.406	2026-05-13 16:14:01.172	\N	0	SYNC_USER_FULL	DONE	\N
cbba23df-dae6-457b-972a-290b5fd31875	{"name": "RODRIGO QUISPE", "userId": "09444357-d818-46fa-9a00-1d4d6730e188", "endDate": "2026-08-03T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:16:09.506	2026-05-13 16:16:13.308	\N	0	SYNC_USER_FULL	DONE	\N
c655d0e9-d655-4b0d-a354-d390fb5ab23e	{"name": "ROGER SOLIZ", "userId": "78a28621-1984-46c7-b399-41b37b32b364", "endDate": "2026-08-04T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:18:12.81	2026-05-13 16:18:16.224	\N	0	SYNC_USER_FULL	DONE	\N
2e989fdb-1cb3-496a-b840-4baf153264b6	{"name": "ROMEO AMORIN", "userId": "07a93134-4420-4493-83e0-a79a04229f61", "endDate": "2026-05-19T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:19:51.191	2026-05-13 16:19:54.624	\N	0	SYNC_USER_FULL	DONE	\N
71119597-30c3-46e0-a3f9-3e4d48bd383a	{"name": "RONAL SOLIZ", "userId": "386355ce-1913-40f6-affb-80ac1576859e", "endDate": "2026-08-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:21:37.008	2026-05-13 16:21:40.881	\N	0	SYNC_USER_FULL	DONE	\N
dc5a9518-69ae-4bad-bd44-ee8d273bd14b	{"name": "RICHARD CALDERON", "userId": "958a722c-2b94-4350-8176-55eb498d71c9", "endDate": "2026-08-27T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778689436478.jpg", "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:24:07.787	2026-05-13 16:24:12.838	\N	0	SYNC_USER_FULL	DONE	\N
2efccf46-a11e-4729-9a46-895970658bfa	{"name": "ROSARIO CHOQUE", "userId": "c804208f-9b00-40ac-8f50-6aaea5f1b7c7", "endDate": "2026-05-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:26:57.635	2026-05-13 16:27:01.593	\N	0	SYNC_USER_FULL	DONE	\N
c5509620-c2b4-4234-a82f-3532fbd8adc5	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778689736841.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:29:07.923	2026-05-13 16:29:27.285	\N	0	SYNC_USER_FULL	DONE	\N
9a433f6b-e3f7-49ad-98c8-96e589c1d62e	{"name": "JAVIER", "userId": "4bd929fb-a536-4e2d-9bf0-837634d76370", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778689736841.jpg", "startDate": "2026-05-12T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:29:54.308	2026-05-13 16:29:58.528	\N	0	SYNC_USER_FULL	DONE	\N
c541f85e-5841-4e4c-8383-effd6fc46c6b	{"name": "RUBEN FLORES", "userId": "8fadbb0c-559d-45bb-97b7-b4f8e096a2d4", "endDate": "2027-01-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:32:13.414	2026-05-13 16:32:17.251	\N	0	SYNC_USER_FULL	DONE	\N
8e61265a-1cf7-423b-9b89-4a57a14a4e8b	{"name": "ANTONY TORREZ", "userId": "14ca7ddc-150c-4dda-8895-3d881ffc5267", "endDate": "2026-06-04T23:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778689960742.jpg", "startDate": "2026-05-11T00:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:32:47.556	2026-05-13 16:32:51.616	\N	0	SYNC_USER_FULL	DONE	\N
6cf5caed-6786-4e6c-a5c7-3d3eff04eaf3	{"name": "SEBASTIAN VEGA", "userId": "580a5edb-5baf-4328-9759-a125936cca0c", "endDate": "2026-06-06T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:46:25.023	2026-05-13 16:46:28.897	\N	0	SYNC_USER_FULL	DONE	\N
a9123838-0c68-4bb5-a773-40fef3500603	{"name": "SEBASTIAN VELARDE", "userId": "9c68a247-ccef-40e6-a8dd-3fdba411f12d", "endDate": "2026-05-23T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:47:43.727	2026-05-13 16:47:47.627	\N	0	SYNC_USER_FULL	DONE	\N
e15e2110-4fcc-43c3-acca-4264cbe7dfb3	{"name": "MICAELA VINOYA", "userId": "9fe4f4f4-9aef-443b-9d1c-3cbc3c88aba2", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778690909360.jpg", "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:48:41.839	2026-05-13 16:49:18.539	\N	0	SYNC_USER_FULL	DONE	\N
a3b05043-4362-4e45-a617-9ed63f750370	{"name": "MICAELA VINOYA", "userId": "9fe4f4f4-9aef-443b-9d1c-3cbc3c88aba2", "endDate": "2026-06-07T03:59:59.999Z", "imagePath": "https://apigymcloud.aplus-security.com/uploads/partners/1778691033207.jpg", "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:50:59.375	2026-05-13 16:51:04.273	\N	0	SYNC_USER_FULL	DONE	\N
29b0d9a2-6598-4a9c-8b8c-91849b49a002	{"name": "SERGIO", "userId": "928a4b6c-c714-4ed8-bc7b-16e578aebc41", "endDate": "2026-12-16T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:55:44.709	2026-05-13 16:55:48.604	\N	0	SYNC_USER_FULL	DONE	\N
42ec0d0f-cbaf-49d9-aebe-ede20100b35a	{"name": "SERGIO ABELLA", "userId": "c6d315b6-8b52-421a-9b9c-a77ff639022e", "endDate": "2026-11-27T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:57:04.683	2026-05-13 16:57:08.601	\N	0	SYNC_USER_FULL	DONE	\N
c28db75c-08eb-4332-93b9-322dc979de27	{"name": "SERGIO GERONIMO", "userId": "bae8a750-4296-43fa-bd65-9f0c827365a7", "endDate": "2026-05-29T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:58:20.586	2026-05-13 16:58:24.352	\N	0	SYNC_USER_FULL	DONE	\N
36e55bc6-163a-4432-bac2-a36f6e490bcb	{"name": "SHIRLEY GOMEZ", "userId": "ce1ff1f0-9262-435b-bd17-78b1fd25fc24", "endDate": "2026-05-24T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 16:59:40.116	2026-05-13 16:59:43.983	\N	0	SYNC_USER_FULL	DONE	\N
925ac319-9097-464c-9d29-7a774803adf0	{"name": "SILVIA ALIAGA", "userId": "b6f67fec-5790-4e2f-8f90-125612a3c29c", "endDate": "2026-05-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:07:22.24	2026-05-13 17:07:25.797	\N	0	SYNC_USER_FULL	DONE	\N
9e523ee4-2dd1-433f-afce-c9b309563e9b	{"name": "SONY", "userId": "09402461-b3c0-47bf-820d-abf9ed3b2661", "endDate": "2026-06-17T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:08:27.631	2026-05-13 17:08:31.482	\N	0	SYNC_USER_FULL	DONE	\N
88fa37fe-2333-4e54-ad2c-c17d6a1c39d0	{"name": "SORAYA SUBIRANA", "userId": "51d1d5e0-7be3-4473-ad9a-2863df29a507", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:10:11.827	2026-05-13 17:10:15.807	\N	0	SYNC_USER_FULL	DONE	\N
c7b72c2a-731c-4388-a507-84089f122aa7	{"name": "STEVE ALMANZA", "userId": "7dfdc883-425b-444b-8855-8e3ed40501b2", "endDate": "2026-06-26T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:11:32.19	2026-05-13 17:11:35.608	\N	0	SYNC_USER_FULL	DONE	\N
38f79f1b-ab23-43c2-9204-f39f498db6b2	{"name": "VERONICA MAMANI", "userId": "c623c23b-5da4-4b94-bf23-263187c4a392", "endDate": "2026-06-05T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:26:52.308	2026-05-13 17:26:55.858	\N	0	SYNC_USER_FULL	DONE	\N
4d216669-b90f-478f-83ee-5a09e17e018e	{"name": "WILLIAM", "userId": "47034143-833a-42ce-b066-b3f8ff358977", "endDate": "2026-06-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:33:36.472	2026-05-13 17:33:40.323	\N	0	SYNC_USER_FULL	DONE	\N
1c02a9a7-ecc1-41e8-9770-40996c654792	{"name": "YEISON EL HAGE", "userId": "2337c795-7592-40e6-a6c2-355e855b9e96", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:34:51.947	2026-05-13 17:34:55.532	\N	0	SYNC_USER_FULL	DONE	\N
1d0463b5-969b-49b6-b459-bb87f0a07b47	{"name": "YESENIA URGEL", "userId": "9487b2c6-7fe4-41fe-b92b-9034df0d2597", "endDate": "2027-01-18T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:38:03.871	2026-05-13 17:38:08.12	\N	0	SYNC_USER_FULL	DONE	\N
b33ba2c5-f8a0-4db1-b0bd-e1b39afae597	{"name": "YOVANI ROCA", "userId": "3004aa20-e37a-43c3-b807-ccaf85841daa", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:44:12.087	2026-05-13 17:44:16.008	\N	0	SYNC_USER_FULL	DONE	\N
4dd48fa7-20aa-4b9d-9753-6eeef6812a0f	{"name": "YUKIO", "userId": "5b5c5739-ea30-4366-ad38-2c4571dcdcfb", "endDate": "2026-05-28T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:45:22.305	2026-05-13 17:45:26.07	\N	0	SYNC_USER_FULL	DONE	\N
0381c22e-c2a4-42fe-9c9f-e666c3b90972	{"name": "YULISSA CASTRO", "userId": "62b3b1f3-aeda-4c59-bfeb-8233dd6fc277", "endDate": "2026-07-02T03:59:59.999Z", "imagePath": null, "startDate": "2026-05-13T04:00:00.000Z"}	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	2026-05-13 17:47:58.127	2026-05-13 17:48:01.882	\N	0	SYNC_USER_FULL	DONE	\N
\.


--
-- Data for Name: Company; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Company" (id, name, "isActive", "createdAt", "updatedAt", "logoUrl") FROM stdin;
6b293f8f-beec-4a45-9b22-98ceabe0f3a1	SYSTEM	t	2026-05-05 14:44:21.658	2026-05-05 14:44:21.658	\N
ba873a42-909b-47cf-8bd7-15caaf87fd46	MetaFit Mutualista	t	2026-05-07 22:35:11.327	2026-05-08 03:28:53.799	uploads/logos/1778193332855.png
6b828940-7fc0-449f-8a26-f91d237a0940	Inifinity	t	2026-05-05 14:46:06.498	2026-05-08 20:29:45.255	uploads/logos/1777992367339.png
\.


--
-- Data for Name: CompanyPermission; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."CompanyPermission" (id, "companyId", "permissionId", "createdAt") FROM stdin;
8ccc2977-a968-4473-bd77-59e0fb320f9d	6b828940-7fc0-449f-8a26-f91d237a0940	bd9349cc-fc82-410f-8136-672a3f416fe1	2026-05-08 20:29:45.277
bad44f7c-1bbd-438a-8cf3-c36d44cb9f16	6b828940-7fc0-449f-8a26-f91d237a0940	1d458a77-9b8d-4ebc-9931-97a7e74cf21c	2026-05-08 20:29:45.277
b29f65eb-6bc3-4296-99fc-836723add1f9	6b828940-7fc0-449f-8a26-f91d237a0940	b645a3fc-7edd-4e3a-85f8-26469b2d0037	2026-05-08 20:29:45.277
943d5c01-94a3-44d4-9562-129baee01af3	6b828940-7fc0-449f-8a26-f91d237a0940	79bef71b-18e5-4691-a2e4-be34146e9fc9	2026-05-08 20:29:45.277
f5e44e55-9153-4739-a985-eb08991a4353	6b828940-7fc0-449f-8a26-f91d237a0940	73e7330e-50a3-47e3-b86a-e80bf691db07	2026-05-08 20:29:45.277
ff8ef8d6-bd6e-4b46-8f69-fadf2b22369b	6b828940-7fc0-449f-8a26-f91d237a0940	e738238a-eb71-4323-8b30-5fb7a7d30b14	2026-05-08 20:29:45.277
b25b931a-84d8-4744-b205-31df9533ae77	6b828940-7fc0-449f-8a26-f91d237a0940	23a9c166-1a7a-4ef1-b026-61af37645e3b	2026-05-08 20:29:45.277
1921e6f5-8a1d-47fe-a108-9b762f691002	6b828940-7fc0-449f-8a26-f91d237a0940	88b7d5b1-974c-41b0-8b38-d4dcb0ceeb2f	2026-05-08 20:29:45.277
c9a7ff1d-339f-416d-9189-179d092790d7	6b828940-7fc0-449f-8a26-f91d237a0940	94e4347f-16ae-43ad-b334-8cad426f5562	2026-05-08 20:29:45.277
90f5d786-fd52-4738-83a6-6ccb46203cd4	6b828940-7fc0-449f-8a26-f91d237a0940	d1fbb067-418d-4f1d-bd9b-ae25fa98e593	2026-05-08 20:29:45.277
19b5f568-9440-4ac9-aa3b-2e8f308621ed	6b828940-7fc0-449f-8a26-f91d237a0940	e0df5c84-efae-4efb-9145-e2cf00cd80dd	2026-05-08 20:29:45.277
833d39d0-ec22-4a69-b281-30dc34b36673	6b828940-7fc0-449f-8a26-f91d237a0940	3415b815-1065-4c7f-93e3-afd53b84c557	2026-05-08 20:29:45.277
c0a4edcd-7c2f-455a-9a1a-b51b14558f63	6b828940-7fc0-449f-8a26-f91d237a0940	1202de82-2216-4467-8f56-2666bf2f3448	2026-05-08 20:29:45.277
8e095c0a-e31b-4664-bfc9-1937bf5dd9fc	6b828940-7fc0-449f-8a26-f91d237a0940	292ab621-eb16-45e2-9872-3d475315817b	2026-05-08 20:29:45.277
bc0c03d5-6b36-4f94-9985-067ae1e6438c	6b828940-7fc0-449f-8a26-f91d237a0940	4f140291-f5f7-487b-a0a2-a34881d51517	2026-05-08 20:29:45.277
16a1bcb9-9aa1-4bc3-ab2f-8f984cf88cfc	6b828940-7fc0-449f-8a26-f91d237a0940	082dcb9f-6381-4bca-9b3c-a4ef3dcbb706	2026-05-08 20:29:45.277
c2b4c493-02f5-4710-9a3a-13ac546996ce	6b828940-7fc0-449f-8a26-f91d237a0940	082e2a7a-eff6-44a1-b604-c2ab1edc95b5	2026-05-08 20:29:45.277
efbfe96e-ac10-4089-9b39-ab58ef20e24a	6b828940-7fc0-449f-8a26-f91d237a0940	9c876750-36f2-468e-a198-e10a9626cd00	2026-05-08 20:29:45.277
2a192b8b-0eac-4e1a-8c0e-413d08bf3791	6b828940-7fc0-449f-8a26-f91d237a0940	0f2dec1d-907c-4191-bc9a-acb18f6378a8	2026-05-08 20:29:45.277
46a8afd3-0498-436a-9548-38f778bbc5ee	6b828940-7fc0-449f-8a26-f91d237a0940	8f935806-88ce-43c1-9ada-4336968d1c04	2026-05-08 20:29:45.277
6cacbf03-3588-4a44-90f3-e0893d10a1f6	6b828940-7fc0-449f-8a26-f91d237a0940	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365	2026-05-08 20:29:45.277
2bae95c5-83d1-4ca9-8c20-1aad79c687dc	6b828940-7fc0-449f-8a26-f91d237a0940	dcde9549-77da-4227-ada0-35f7565804ef	2026-05-08 20:29:45.277
b56b3a79-9dfc-434b-9cc5-3355519e0cd9	6b828940-7fc0-449f-8a26-f91d237a0940	375daabc-e2c9-435e-b007-18245e5f2d0d	2026-05-08 20:29:45.277
fb4c326d-c185-48ce-a884-7da1208f35b6	6b828940-7fc0-449f-8a26-f91d237a0940	0c38eda9-3781-4a72-93cc-810b51caf9c7	2026-05-08 20:29:45.277
f4d3fed8-311c-4e49-b970-18f8d70c3b36	6b828940-7fc0-449f-8a26-f91d237a0940	3c4c0349-cd46-4557-aa21-ced1ef68a054	2026-05-08 20:29:45.277
51663fc5-1c5e-469b-b90f-c0935bb0b91a	6b828940-7fc0-449f-8a26-f91d237a0940	8906ae3f-dacf-4ba5-a2c6-e2e9c65f91a4	2026-05-08 20:29:45.277
506b20f8-7ec6-4ce2-9dd9-536b2aab66e6	6b828940-7fc0-449f-8a26-f91d237a0940	6bb4ba35-d763-4f61-bb02-73c217976f25	2026-05-08 20:29:45.277
3f23b198-cb39-4c4d-af11-a291e7b945e7	6b828940-7fc0-449f-8a26-f91d237a0940	b3bc1161-8c43-4264-a60d-619e05cda55e	2026-05-08 20:29:45.277
59ac2250-8aff-46cd-a4ed-d1faedb56a71	6b828940-7fc0-449f-8a26-f91d237a0940	f3e6cf31-7278-4581-a485-28064fb99b5c	2026-05-08 20:29:45.277
af982762-9dd6-4d25-9903-8282924efe15	6b828940-7fc0-449f-8a26-f91d237a0940	850ae969-9f55-41ca-bb53-80066d012323	2026-05-08 20:29:45.277
a2905b6f-59c9-43ce-916b-5bd009923cb2	6b828940-7fc0-449f-8a26-f91d237a0940	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735	2026-05-08 20:29:45.277
244b0731-fe15-4192-a453-843bfa17b759	6b828940-7fc0-449f-8a26-f91d237a0940	e49620db-e84c-47bf-91a0-ff8867c8f412	2026-05-08 20:29:45.277
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
73c71b05-550a-4be1-98b1-cb9897c99894	4b5a5b43-8414-48d7-a9b5-4491f2f59336	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 00:00:00	2027-06-07 23:59:59.999	ACTIVE	\N	f	\N	2026-05-07 22:58:03.247	2026-05-07 23:00:25.476	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
08f16840-d380-42d5-955e-08ae1076660e	156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 00:00:00	2026-07-08 23:59:59.999	ACTIVE	\N	f	\N	2026-05-07 23:16:24.801	2026-05-07 23:16:47.866	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
27ce5bba-41aa-449e-8148-e1a3d9ceee9f	1faf3a07-9b37-4f07-9f77-e33fbf855ed6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-08-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:11:59.369	2026-05-08 00:11:59.369	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
200f120f-3314-43c9-abd0-7f482cc190fd	f259ee60-7a93-4e2c-ae61-7c4cf6215575	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:07:27.812	2026-05-08 21:07:27.812	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3f275e3c-f832-48f1-8bf6-71eb61981790	cb882c3e-8c58-4b6d-95b1-29d050a75abe	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-07 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 22:10:46.082	2026-05-08 22:10:46.195	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1a96687d-ea24-4fc2-92cf-ac50c0589e12	5564e62d-031a-4094-8e7b-ca2e5f28f481	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 00:00:00	2027-04-01 23:59:59.999	ACTIVE	\N	f	\N	2026-05-07 22:53:21.454	2026-05-07 22:53:21.454	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3a1e97e0-eb8b-4c67-9ba5-bb6071ac84c3	bd4692d3-efdc-4abf-9c29-c9f755caf715	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 00:00:00	2026-08-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:25:49.524	2026-05-08 00:25:49.524	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4f77379a-1d9d-470f-a08d-5626340e07d2	29d96077-cf65-4862-93f5-650250ea47a7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 00:00:00	2026-07-15 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:49:07.456	2026-05-08 00:49:07.456	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
48c0c7f8-6056-4f24-8629-c1a571c0452c	6a35612f-c381-4125-928c-378dbe431e69	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-08 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 13:11:21.705	2026-05-08 13:11:21.705	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
836967cb-1ff1-4c1d-9a10-c3a6429eb193	22b1f9cc-4a9d-48ff-821d-da9d7a111974	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 00:00:00	2026-06-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 18:02:19.153	2026-05-08 18:02:19.153	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a8850d70-34e8-4668-b52b-65954da8ebde	b490945f-208c-4b2a-881b-35ffd0eded6d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-18 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 18:28:57.352	2026-05-08 18:28:57.352	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
12a78985-bdab-44c1-a344-aa46f3126253	4d64fb5f-71c6-4b3e-8c84-16d3322ec84c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2027-05-13 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 18:39:22.337	2026-05-08 18:39:22.337	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9bd31a3e-f7d2-49b8-a588-4e76bef8a5e5	cad0d165-8aee-4e43-9cbb-8627fd3b600e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 18:44:48.828	2026-05-08 18:44:48.828	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d25c5540-acfb-4197-8606-f01884173924	9d137b31-1c45-4940-929b-38a942ee224f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2027-04-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 18:50:37.816	2026-05-08 18:50:37.816	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f285dc63-e9a7-4a65-baa0-9f1a3a54f068	0be16069-145a-4e3b-a50a-34abe7a5d640	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-08-07 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 18:53:30.756	2026-05-08 18:53:30.756	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ee0a25c4-9a9c-471b-8044-aca5449a3b84	002bd4b0-9fb9-4c32-a4a3-7d0ecb809ba9	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-29 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 18:58:14.341	2026-05-08 18:58:14.35	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5ec2ba4a-2287-4c4a-b53b-83ef9cc0530b	6ee61762-c0c8-4c6c-b8c5-fbdb9ce48a13	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-19 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 19:11:23.848	2026-05-08 19:11:23.848	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9d3685f0-586a-48ef-ac9c-5c4078488b42	9d38d042-2c21-47ba-a498-6485e131b736	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-02 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 20:42:27.255	2026-05-08 20:42:27.255	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4a8ebb3b-6b71-40d3-b3ab-09831932ba5c	7cef75cf-7a5b-4409-ba5a-21b7fe20f390	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-16 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 20:47:11.118	2026-05-08 20:47:11.118	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d26e075c-ab84-4720-b101-f6f17e13d690	6051cd59-bfc0-4276-921a-a60835f6547a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 20:55:36.058	2026-05-08 20:55:36.058	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6fdbdd02-0f10-48c2-b3a8-856245e7ed8a	51a3c33a-fd43-4b8e-a7da-ffd12a391655	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:03:41.649	2026-05-08 21:03:41.649	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
60ade5e1-7d37-472f-9ecd-38b5392ce3d7	6925106d-aaa5-4c51-86ac-1322bd50de8e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:12:14.626	2026-05-08 21:12:14.626	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
31c3b119-3236-4d8e-80c2-6edbbb45d50b	29e13afe-9a13-44d7-a572-aafcfef194f8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-08 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:13:37.9	2026-05-08 21:13:37.9	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
537175d5-b460-46e6-b5ee-193eb9564782	c693773e-60f2-4f62-820d-af9806295a4c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-08-04 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:15:22.33	2026-05-08 21:15:22.33	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bb803710-9a88-4983-b353-4c16dd510541	573da3d3-8cc9-4505-9a79-9ad5e4e797e7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-01 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:22:13.326	2026-05-08 21:22:13.326	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c79232fa-7bcd-473a-bbf6-60937c6ff5e1	7efb284c-a286-4338-81fb-e39a36939875	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-07-23 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:23:48.41	2026-05-08 21:23:48.41	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
947ba3d3-e4e4-4700-9aed-1916940402fe	673f225d-16a4-4da3-add9-faad039822e1	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-19 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:25:14.857	2026-05-08 21:25:14.857	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e2a5224a-1a05-4450-85e5-b905d35df354	17c4abf8-339c-4a77-a5e1-3b66e045bd7c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-16 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:28:01.596	2026-05-08 21:28:01.596	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6c82278a-564f-426b-88a9-63654f9e8e09	4f0db97a-5fec-4ea1-b80a-5eba4712134f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-09 00:00:00	2026-08-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-09 13:12:45.086	2026-05-09 13:12:45.086	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
90fa4be4-55ee-45b5-b0b6-96f065baac8b	dd308e7c-278f-4b29-be5e-51bde9d3f51e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-09 00:00:00	2026-06-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-09 14:21:20.445	2026-05-09 14:21:20.445	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c368e395-fee2-42b8-9d40-e30a31e00522	2304762b-0f36-411d-a173-7fd57932e0ce	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-09 00:00:00	2026-06-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-09 15:22:57.071	2026-05-09 15:22:57.071	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f8659694-ab8b-4f16-8ea9-cdff27917c44	860285e5-dacc-4755-8c51-a572c5acce68	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-20 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 15:06:19.093	2026-05-11 15:06:19.093	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
cb444dc6-8a2d-4d4b-93ce-ca1184c5fcf6	6aa91ec4-6251-489b-a4fd-c34cfccefad7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 15:39:14.646	2026-05-11 15:39:14.646	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9cf8b006-29e3-4f2e-a1a1-49b679e75e7e	42297e10-37c8-4426-9aa8-c2d958d0a622	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2027-01-02 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 21:16:48.736	2026-05-08 21:16:48.736	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f795b4ec-624c-4758-bc1e-a0ada98d0ad5	9c776bb9-61c5-4ee0-9614-5be0fb97d317	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 16:02:18.658	2026-05-11 16:02:18.658	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e67f10cb-7f6e-429b-9d35-b3d645260603	e88ca8d5-16cf-4501-99af-6501f49ff7a8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 16:04:42.274	2026-05-11 16:04:42.274	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6e870649-05db-4c68-9e44-1764ddb415a1	4f91dff1-41bf-4b30-b9e7-b5f72e5e875c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 16:06:49.033	2026-05-11 16:06:49.033	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6e5e2370-7819-409e-9fd8-b3daa5337513	a2aa3f8c-d134-48a9-ae05-6bab8b5880b8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 16:09:13.391	2026-05-11 16:09:13.391	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
fdfe52d0-e8a3-4b5b-b110-cba616e75eb6	6b2da3b2-7c71-4a8f-878a-8e50ab527eff	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2027-01-01 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 15:50:30.748	2026-05-11 15:50:30.748	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ef6b17ba-feae-4d38-af02-1f45da132294	965ab34f-78f7-4d62-8270-d34561994b34	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-07-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 15:54:18.974	2026-05-11 15:54:18.974	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a1fb3c2e-b2b3-4d89-b33f-81b00b0c8422	d02259bf-0b2d-4a79-bd29-1d892299585a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 17:57:23.43	2026-05-11 17:57:23.43	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
8db65e5d-ad1f-4745-b760-779293eb67e7	228e67db-3041-48eb-9a81-b759bd96c248	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-20 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 16:33:20.441	2026-05-11 16:33:20.441	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c69251ef-7c77-41d2-99de-ffd69522b88b	9bec239a-8ddf-4cfb-ad5b-1754bd77f92e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-18 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 17:07:54.089	2026-05-11 17:07:54.089	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
83376c68-ecc5-410c-b46a-d92ff3f3fcb5	f74330b4-36a0-47a9-b192-d7bee532f0d5	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 18:31:42.265	2026-05-11 18:31:42.265	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
753f3da5-33b5-4249-ba71-e62b54ed904c	b33f540c-7e61-486b-8e0e-1069b9b388b3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-17 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 18:46:25.994	2026-05-11 18:46:25.994	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9f7373d4-f462-47b3-9434-f2bab44545ab	0544929b-30f1-4d09-9756-881ff559e881	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-31 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 18:54:22.993	2026-05-11 18:54:22.993	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
fe2fe496-93bf-4727-8612-1c00407210ac	3b4fdc49-f12c-4945-8797-69a0336d4beb	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:10:57.485	2026-05-11 22:10:57.485	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2b84b071-f39b-4ba6-94d6-c878ba08416b	1c82b0ed-7597-402e-9b5f-abfcc3a2cc48	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:12:15.507	2026-05-11 22:12:15.507	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b0c7fc6e-b3f0-42dd-9b73-62dede768125	2ef332b0-b371-4564-997d-96f1212cded6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:23:52.148	2026-05-11 22:23:52.148	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
fe360608-9cde-4e4a-94df-d4dbdf16962b	053c65a6-8814-4d31-a97e-59472a996abe	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:25:23.203	2026-05-11 22:25:23.203	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4c7f5827-b591-40d9-b359-50cbf43d7b1c	a0b074a7-4876-44f6-8246-2c7ce9c06e18	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-16 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 20:43:54.853	2026-05-11 20:43:54.853	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b3cfd028-42de-4f43-9a85-51c746aa2407	395d7599-523a-4a6d-9b8d-f5023873ef25	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 21:26:52.172	2026-05-11 21:26:52.172	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7703720f-4b52-4608-9971-fec5d2ea10f3	e6b04300-5976-439f-ab5b-84cd4135d36d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-12-06 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:08:24.007	2026-05-11 23:08:24.007	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2286895c-e6d1-4577-a28f-d37f9c2bde4d	573740dc-40e6-4155-827c-3b98ecc06c01	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-28 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:49:01.909	2026-05-11 22:49:01.909	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0118ac3f-cfea-49e1-b601-f56bba3f8ff9	dc32d4c5-5afc-4af0-8783-960223918223	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-15 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:53:38.012	2026-05-11 22:53:38.012	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
991e6b5a-5807-40ee-bc16-f6bc9293983c	b5e69f4c-51bd-410a-9b57-44092888994b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-05 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:54:45.015	2026-05-11 22:56:36.791	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
15f882f9-5c38-45e5-ba21-9089b3c3f2c9	bb057365-37cd-4fad-8943-037032987734	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-04 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:57:58.158	2026-05-11 22:57:58.158	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b43d0131-0dcb-4721-99f0-5e3f13cbd738	8da439a1-ac7b-4451-8db2-28c0b21e888d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-23 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:59:53.506	2026-05-11 22:59:53.506	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
41824588-cc10-40e5-8db4-e872bace3654	1eeaa250-9d9d-45ae-86d6-295537c409ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-23 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:01:09.911	2026-05-11 23:01:09.911	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7fbd50fb-69ef-44a5-9cef-f642b2bcf760	14ca7ddc-150c-4dda-8895-3d881ffc5267	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-04 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:02:10.825	2026-05-11 23:02:10.825	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d8e0c1fe-73ac-436e-9783-b94ff4338958	e622b29d-67f1-47f9-b22c-9278e39d7241	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-28 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:05:01.974	2026-05-11 23:06:08.144	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
87e8c5f3-0a52-4949-ab8f-f4e1ba5b6e54	af2c4ffd-5299-41b7-9250-672184d7b730	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-19 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:07:11.967	2026-05-11 23:07:11.967	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
71ff6ff4-1b8d-43ad-a8f6-0f5854a1e97b	7a1cad64-053e-4635-9fd9-f75615de6d1e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:09:33.537	2026-05-11 23:09:33.537	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ad7d2486-1896-4e1d-8b8c-23b86717807e	2ba743d2-858b-4e21-950e-ea4f87925874	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2027-02-05 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:12:36.549	2026-05-11 23:12:36.549	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f114eac2-fa4c-46ee-91b2-73e74be17550	93ddf524-4617-4d45-b378-17df5ce50980	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-28 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:47:40.38	2026-05-11 22:47:40.38	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
39e80dd0-b310-42e7-86cc-b08bae4187a2	de09cfdb-ea36-47be-ba0f-e121fbfa49a6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-07 23:59:59.999	ACTIVE	\N	f	\N	2026-05-08 00:38:58.636	2026-05-08 00:38:58.636	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3407a15b-3e89-464a-9421-860819fee69e	8a0434a1-0c0c-45ca-9f4e-bcc0f48a1f68	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-25 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 15:11:52.626	2026-05-11 15:11:52.626	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
10b9edbe-a703-4640-a197-3cefaa29c3ed	8182fce0-79cf-4297-b088-eab44cfabaa7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-16 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 10:23:38.544	2026-05-12 10:23:38.544	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a327a8c5-0e89-4d76-8a1c-a63a8ecd8576	33b29244-f779-42e2-9721-71e39a4ad98d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-12-08 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 10:20:33.923	2026-05-12 10:20:33.923	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ffb86646-d07e-482b-a89f-b12973a72cb7	5116038b-94be-4b71-8ff3-b03ab527f2f3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 10:27:50.91	2026-05-12 10:27:50.91	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d0d54dd9-0b1c-40d7-9d6c-f8b4bf6457b2	dbe35b9c-74f6-4367-bc0c-e7fc2ca93d2e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 10:43:53.022	2026-05-12 10:43:53.022	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
67b958f2-9496-41be-ab7e-f32d512f9cb1	eacad3c1-2395-41ef-9633-32c9163fc689	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:31:39.045	2026-05-11 23:31:39.045	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a32a227a-77c9-412b-bf97-2612e340e5fe	9213415e-a653-4348-832a-bf9810200933	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:38:55.885	2026-05-11 23:38:55.885	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b6d5a75e-ab92-4be3-9672-591a48efbc0a	476f493e-162a-4d08-bbdd-939833a866d6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:44:17.269	2026-05-11 23:44:17.269	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
434df458-6731-4630-aa50-fdcdb3d57085	a1522040-1855-4193-ac97-9f965f584f11	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 00:00:00	2026-08-10 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:00:06.539	2026-05-12 00:00:06.539	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
8a1b63b8-87d5-42e5-98d5-7015bb059ebd	14982bcc-b706-41bc-ad3d-3436b0a8e007	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-11-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 10:46:01.048	2026-05-12 10:46:01.048	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c3cc6df9-52ad-47b1-9bc0-84bd148f2af0	e803ed62-468c-44d4-bd33-1cee42348781	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 10:48:18.166	2026-05-12 10:48:18.166	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
cea3ce86-c377-48bb-8836-c30531ef77c7	c65add80-0d84-459f-9361-f3346c7b3334	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 10:51:15.385	2026-05-12 10:51:15.385	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3fa21938-c8c6-47aa-9a5e-6ed12a8f735c	ae2e561a-e9f5-40ce-bd69-ca9201bb8e74	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-09-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:04:59.224	2026-05-12 11:04:59.224	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1dee52b6-a185-4b84-934e-d736032d2057	19cbef6f-740f-4538-b415-d2022ba8b045	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:25:50.88	2026-05-11 23:25:50.88	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9e66b93d-ede4-447d-9cb5-2726a666783f	eacedabb-27b6-459f-a242-10e96f7eea0d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-29 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:27:52.733	2026-05-11 23:27:52.733	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
35ead9c0-8b4d-4e66-b9d9-b3fc55695e5c	e3a60882-6f03-4885-8e7a-e633ff91c54b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-20 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:29:02.249	2026-05-11 23:29:02.249	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
86b2b3da-6063-4d4a-a9ed-5ffcadf67cce	cdaf029c-3182-4ca9-b85b-fef51a732baf	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 00:00:00	2026-07-13 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:47:51.608	2026-05-12 00:47:51.608	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
8bd70d99-c32a-4e38-8976-0694c7bb8b48	a3a1bbab-a2dc-40da-aa6a-97146c5fee2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-30 00:00:00	2026-06-28 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:49:00.97	2026-05-12 00:49:00.97	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4d58bf04-3f5b-49ff-8280-bc280dcb60b6	f848e6ae-09d8-461a-83bc-9c82e5c9167d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 00:00:00	2026-05-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:53:14.588	2026-05-12 00:53:14.588	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
013d5e3d-3d12-43a0-8e77-4dffe9efdfad	d23325f7-6aa2-4072-ba45-3a7885dbb7a9	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-01 00:00:00	2026-08-08 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:54:26.828	2026-05-12 00:54:26.828	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a915bbcb-a516-41df-879b-4e259c601751	a86881ed-f927-4b62-9a38-8056f58d80e9	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-30 00:00:00	2026-05-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:55:44.916	2026-05-12 00:55:44.916	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ea7f3e20-1676-4c15-8387-ac906cd6e740	67ce18ed-76bc-47d9-86e9-cb7cbdd692bb	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-28 00:00:00	2026-06-25 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:57:03.907	2026-05-12 00:57:03.907	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
88e603fd-761d-4c3a-afa4-a23edbe099ea	f1c7c07c-2b71-4cae-93b0-0fb09044c46a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 00:00:00	2026-07-05 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:58:58.23	2026-05-12 00:58:58.23	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
dfb6ca26-c009-4bd4-86ba-a307e1ae4423	2d6028b4-ee06-4004-9fa7-fcaf5f32c2df	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-06 00:00:00	2026-05-13 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 01:12:50.822	2026-05-12 01:12:50.822	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1d8eb469-3b66-4b85-a22a-c576e42b6df2	a60aa232-435c-4484-a25c-06cfe020f370	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 00:00:00	2026-06-20 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 01:26:09.058	2026-05-12 01:26:09.058	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
91b28a4b-6711-4b7c-b94c-2b0fc6647ee9	f6c321cf-011b-4e88-8ed0-ce56b5851cdb	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 00:00:00	2026-05-21 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 01:27:06.392	2026-05-12 01:27:06.392	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
30664e28-bee6-4e75-86b8-18b68206beb2	229949be-6630-4b99-912a-97ba6e140a2f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-30 00:00:00	2026-06-28 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 01:28:16.758	2026-05-12 01:28:16.758	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f3764e11-7e12-4c0e-a40d-4db1bf83b3d9	60c3a803-bf7b-4f6c-8600-08c957cd1793	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-13 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 22:39:35.735	2026-05-11 22:39:35.735	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1018f46e-9f39-4302-befb-66d743b369b1	37a69c00-8984-45eb-b0f5-fac4464c485e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-21 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:13:30.515	2026-05-11 23:13:30.515	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
82918f25-4f9d-4f72-9fca-08553256b9bf	0d168b57-fe6f-433d-82db-2a0fcc1ee953	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-12-28 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:16:58.725	2026-05-11 23:16:58.725	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9145691c-92ac-49a4-a03d-a1e91ceb5f08	3763abee-1b74-47e0-9f72-203bf58d976d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-05-21 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:18:27.425	2026-05-11 23:18:27.425	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
497358c3-dd74-4d3b-88fc-b8f840500446	59d0f632-36d6-4fcd-b38b-4f39b456b5ba	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-12-27 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:20:34.534	2026-05-11 23:20:34.534	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2ac76d1e-a019-4ee1-b229-ec52f62bd658	1f933426-9a3a-4ea1-9fe3-517c7e6708cf	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2027-02-20 23:59:59.999	ACTIVE	\N	f	\N	2026-05-11 23:21:59.475	2026-05-11 23:21:59.475	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
778238fc-8bc2-4f45-93d8-b44ac1d9db5a	ddfb4049-f4bc-4534-bd54-a9f9764b6cb8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 00:00:00	2026-07-20 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 00:52:03.609	2026-05-12 00:52:03.609	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7d6fc2d7-f424-4341-96fa-eaf34197c481	26d4d207-b9b5-4221-b2f3-9628c2724a6c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:09:17.187	2026-05-12 11:09:17.187	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4c830498-0466-448e-af02-04025cd0f7c8	f1d6d27a-a3f1-44b5-bdce-1d7f6d531ad4	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:12:13.813	2026-05-12 11:12:13.813	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
36df75b0-93f6-462d-bb19-7c79a74b8681	fb6c9d8f-9441-484a-b6de-451233679e4d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:14:23.379	2026-05-12 11:14:23.379	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
43fc962e-fa53-45e6-a3cf-cf01172605e5	2a158cc9-5fb6-45e3-822b-3c29985cb265	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-25 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:20:00.214	2026-05-12 11:20:00.214	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2b692304-6a5b-4b78-b1fe-611f1a3e6430	f97f2614-1a25-4055-af4b-bd661030983f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-09-22 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:22:34.043	2026-05-12 11:22:34.043	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
634444a5-57a3-45a0-8803-d5d8e0c59d28	503e2c59-9329-4312-86e6-88063247b133	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:29:08.332	2026-05-12 11:29:08.332	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3f1e2e21-1a74-4a4c-b51e-191a0be973e3	590a677e-2ca7-4c5c-a626-5f820e968a02	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:32:07.96	2026-05-12 11:32:07.96	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9a4d1523-0dd8-4d7e-bec2-e7318cda1dfd	cfc79a88-47f4-4abd-9672-aa15994283c2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-11-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:34:24.063	2026-05-12 11:34:24.063	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9abb7ece-7f9f-47fe-b712-aed1916e502d	40cdeee4-0cad-403f-b046-55a5a6a2351c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-01-01 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:36:25.336	2026-05-12 11:36:25.336	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e40f7d28-430c-4a99-8029-a823935e11dd	8d558a91-928d-48b5-81d5-0c16dcf8bd23	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:38:31.417	2026-05-12 11:38:31.417	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2d7749a9-f75f-4488-a21d-47a54827453b	cb6fe7ed-48ce-496d-a3c0-dc3df9ec5ffd	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:44:13.377	2026-05-12 11:44:13.377	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ba1f6bae-115f-4f04-b12d-e2046569a86c	3695737b-64a7-47b0-86f9-58d865a70bf3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-07 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:47:32.173	2026-05-12 11:47:32.173	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0a0ba08e-d5d0-4abb-99c1-58d2bbd38979	1b1d5ee8-7c16-41fc-8ba9-1f3fe85fa749	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:49:32.61	2026-05-12 11:49:32.61	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0c317f95-ba7b-4d97-b18d-00692459c269	36848429-b86f-41f0-9563-4c5adce1129f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:50:59.308	2026-05-12 11:50:59.308	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3fe3f0f8-8b48-4776-9100-550a161458e3	1e07bf11-03d8-4059-aac5-80d5c86cc41a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:53:38.461	2026-05-12 11:53:38.461	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6dd2d26a-bf89-402d-9695-f163691930d4	7cb7265c-514f-40b2-8e1c-d08624a5b885	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 11:58:55.147	2026-05-12 11:58:55.147	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d5c43036-a31c-4472-a52e-b435a00f580b	c161507d-3d1e-4449-bf67-067f757c9185	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-02 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 12:00:28.795	2026-05-12 12:00:28.795	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
defd54d5-199e-4a38-b9ea-f58b1a69acdb	bc76b1e0-f9b4-4bc8-9ace-5fc3b528bacf	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 12:09:32.709	2026-05-12 12:09:32.709	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
499f3a08-fe96-42d4-9379-98632ab690ab	050cf9da-0342-4d7f-9c90-7bdd84ff86cd	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-01-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 12:31:14.942	2026-05-12 12:31:14.942	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ec23fd90-9458-499c-ae12-70eff80c5978	33f9f76f-ef12-4217-85d8-4b96ad28cd61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-02-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 12:38:45.865	2026-05-12 12:38:45.865	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d48ff093-f096-40eb-9f9a-c3482b50d286	42d89532-31d5-423a-9007-f83b454116bc	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 00:00:00	2026-06-11 23:59:59.999	ACTIVE	\N	f	\N	2026-05-12 12:41:09.799	2026-05-12 12:41:09.799	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f83524de-044c-4e8f-aa21-64872babeecc	46b3376a-973a-454b-9347-52808613a768	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:01:13.447	2026-05-12 13:01:13.447	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3b7f4b54-e0a2-40e0-b0be-b9bd2cc170ef	f75051f4-22b0-4de2-ac4d-cba8b447b15b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:03:00.971	2026-05-12 13:03:00.971	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
100d702e-38ec-4f3e-ad42-65efa33fdf75	362f0976-10f2-4896-bf47-e235e3717892	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-09 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:05:38.865	2026-05-12 13:05:38.865	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
524042ef-9630-4f9e-b691-be6fe294fb52	144621a4-ad27-4aac-a4eb-c2171985be60	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:07:43.447	2026-05-12 13:07:43.447	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e1b16454-fc99-4946-ae17-5dd4873ea459	9bbc1ece-99fa-4616-9161-c83db51aa25b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-11-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:12:48.966	2026-05-12 13:12:48.966	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
939b7cfd-ff9e-45cd-95de-aa67fe12d55d	a5c2d6a4-2740-4ae5-91a8-a3287620c7af	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-10 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:14:47.034	2026-05-12 13:14:47.034	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bd628599-bf5e-4f1d-894b-5baa66746d18	a60c8569-154e-4ae1-8ab0-1a7d56bded2f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-01 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:16:36.707	2026-05-12 13:16:36.707	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d7cbd4d2-f5d2-4757-a19c-8af17bbbdc3b	e39a48bf-3739-40b2-aecb-166da5fbbe56	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-07-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:19:41.911	2026-05-12 13:19:41.911	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4319cdf0-3875-4e8a-ac40-91976c0876ce	9594524b-f9d7-4866-a709-1b5b72561c43	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:41:45.287	2026-05-12 13:41:45.287	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
93f55dac-96f3-46af-ac99-0f6f0f2ab11f	fbd8d867-0df5-494d-b277-742b3c39f86e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 13:44:08.188	2026-05-12 13:44:08.188	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a8182e55-eed7-4818-b5b8-aa89cf044f29	35e3dd85-4922-4d4d-8722-70cdac572efc	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:09:33.007	2026-05-12 14:09:33.007	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
91e6a13e-c3c6-4bc2-8c48-64a8bb5f59b0	32794fba-4901-47d7-a3d9-3282c5a6ff37	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-03 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:11:16.301	2026-05-12 14:11:16.301	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4b00e335-e9d9-4f4b-9166-b19abbeda65b	8f52ede8-a0ca-4924-9587-69a8ee6c21c7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:13:14.586	2026-05-12 14:13:14.586	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
8b7c6d31-1e47-46b5-aab8-373a6925eb86	e36c05fa-507a-4680-9962-ead22b0f4816	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-08 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:15:48.256	2026-05-12 14:15:48.256	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
17af0ddf-9d8c-430c-bac3-bfc5b30cd8bc	f0517e12-07ae-4354-968e-6ce837a59958	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:18:10.128	2026-05-12 14:18:10.128	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1a4ede66-a303-4d0d-94b8-7224f512e588	502cc3dd-a709-4f48-9e65-65b25abc8aa8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:19:47.174	2026-05-12 14:19:47.174	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9525b02a-39a8-423c-b04c-6840e38ae033	a4f0b4d8-868c-4bd9-95f8-79df22d8a3dd	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:22:14.024	2026-05-12 14:22:14.024	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e2d8404a-e002-44fc-aa2d-6a614e3a24da	4cce917b-f231-48d0-ada5-5fed6e41c148	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:27:32.757	2026-05-12 14:27:32.757	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6fb954af-07d1-44d0-a4f7-8e4cb97438af	de8e805e-fc19-4a09-883a-df10f1358f2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:48:34.966	2026-05-12 14:48:34.966	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7026429d-b464-4fb1-b832-10275672dc57	7a70fb89-7a83-4816-baae-b60466f90c2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 14:54:48.697	2026-05-12 14:54:48.697	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
93466e43-3d1d-4dbd-9317-dd28c3766ee9	9d0d0b90-8ae5-40d7-9e54-cb8dd58d0480	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 15:48:25.242	2026-05-12 15:48:25.242	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
27e2eece-7ea4-47a5-a14f-483a364285da	019acc34-bae2-424a-962c-736770ee1dfc	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 15:52:24.773	2026-05-12 15:52:24.773	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1102f8e2-d923-46be-b7fb-22c7079bb3fd	2bd57e4f-56de-4d35-b7df-6b9a5168de6c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 15:54:33.34	2026-05-12 15:54:33.34	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
59197247-904b-4baf-a821-377c6afb305f	75ffd53b-517d-4bbf-a001-754966d7d898	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-25 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:23:40.02	2026-05-12 16:23:40.02	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
47b5c8ef-1b55-42ac-a9c6-99ce6c2ec3b5	693b1571-7006-4f15-8c09-5120324d2b50	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-02-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:28:21.789	2026-05-12 16:28:21.789	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b581ef56-963e-445b-ab81-7259cb4fb3ae	332a5de3-c604-4082-ba3a-f6b2b95b13b3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-02-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:31:32.387	2026-05-12 16:31:32.387	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
58ec2861-d324-4dbe-aae9-009ca753623c	070082d8-f645-4135-8d7f-a4b56dcd49f3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-09-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:33:17.119	2026-05-12 16:33:17.119	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
94a5e996-15b8-470e-a7eb-e7a8b1700fa2	9308d4b2-526f-4489-8607-13f73f6ee946	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:36:19.085	2026-05-12 16:36:19.085	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e2d091af-2d18-4142-9d16-cd55ee7a2751	b135bed0-a17e-4242-986f-edb3304896fb	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:37:42.362	2026-05-12 16:38:49.331	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ea93707e-e1dd-47b6-b77f-c99bc9cf3f72	5faf569a-c8ee-4eb2-8a1d-5a77fefeb9ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:40:33.85	2026-05-12 16:40:33.85	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0971d1de-41ac-4b6d-8865-964f02eb9ab4	4921baba-2d23-418f-a2a8-09d4bd9ac241	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-25 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:49:12.923	2026-05-12 16:49:12.923	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f587c035-86a9-4f97-952e-67f6289f624f	5b3d0c68-6cf8-4656-9464-78e30b791b3b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:53:37.119	2026-05-12 16:53:37.119	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3f48e0ee-70a7-4c4f-a723-5e75d9f3bc9b	9915570f-c0ba-467c-98c4-1b1d2e4af87a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:55:22.11	2026-05-12 16:55:22.11	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e169e23f-6c11-4bd8-9b6a-141cd8dc295d	6da1b4bc-9d7b-4e8a-9705-6db15a76787b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 16:56:43.99	2026-05-12 16:56:43.99	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4f001d1f-eda6-4549-a23f-4ec7a5391e82	906b4106-180d-4f75-8247-af6db3955a39	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-30 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:02:13.288	2026-05-12 17:02:13.288	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9c544d5d-569f-4971-8afc-3ec43d8d1b0e	38a2c285-26a6-49d2-93c9-de60c1d25f8f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-02-13 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:04:31.847	2026-05-12 17:04:31.847	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3c1cd456-694a-408d-9512-3e3ac02ae8f4	cc824b02-2f60-4e92-ba62-0ec3198b9b7b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-25 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:05:56.997	2026-05-12 17:05:56.997	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d2173f6e-0df7-42d3-a6ad-448407864cbc	19db719c-1051-4924-aec8-8fe3216b7c69	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-09-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:09:09.127	2026-05-12 17:09:09.127	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
eb0dd742-2150-42b8-8b3f-d11522d04cab	ef2297bc-5bb2-4f6e-9dca-d9abc1af22a3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:38:59.021	2026-05-12 17:38:59.021	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
941622d9-39c3-4f71-86bf-c41ff729fb40	cecd7a56-d246-49de-a3ce-4a051757ef8e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:40:40.055	2026-05-12 17:40:40.055	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bd321caa-95e6-4801-a5c3-66c44f0d6d3d	55eb10c9-a707-479f-bbc9-c8e19760dcf3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:42:18.147	2026-05-12 17:42:18.147	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a7b4d866-934e-4532-9289-ef58811ec292	14c13de2-ebbd-405f-a3d6-3c400ad6f66f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:45:26.699	2026-05-12 17:45:26.699	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
95260458-70b2-44bf-a26d-f13cf22cd059	31e9e927-66af-4800-a55d-5d979af9614a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-09 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:47:02.901	2026-05-12 17:47:02.901	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b10fc4d3-728e-469f-94c9-a06db6cec27a	3bb68dd2-5395-42c3-9605-3ed9c8cdc6d9	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:48:52.504	2026-05-12 17:48:52.504	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
88488754-004f-49ca-bf43-cf79ea2720e6	2d125526-281c-4172-a595-38ecae59bb50	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-03-17 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:52:19.059	2026-05-12 17:52:19.059	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e272cf58-af1b-4748-988d-9ad4170a7fb6	d4d3380f-768c-4bab-86ac-c0779227db6f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-16 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:58:06.075	2026-05-12 17:58:06.075	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
16deadfd-cca0-4c38-bb0f-0dc29a2221ae	f1810818-cd91-40f0-bfd9-9649693e526d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 17:59:38.362	2026-05-12 17:59:38.362	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d1c5e61f-c1f5-4b47-bf33-3c1060258a29	4e278f5e-dd46-4319-8703-13be851ea70b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 18:01:13.815	2026-05-12 18:01:13.815	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b762956f-bd11-4a34-8221-9e6ec88e104d	bb02909a-548b-443e-8954-8573a03c3da3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 18:55:18.66	2026-05-12 18:55:18.66	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
80c33a8e-c70e-4b2d-a340-6bae1a69e2ff	90068245-1458-4fce-96f7-e7547a9bbb02	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 18:58:51.433	2026-05-12 18:58:51.433	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ed28e4fd-3f3a-4ce3-8ca3-d9a8d4be0152	b269dee8-ffb7-483b-93fc-3a466072cb8d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-15 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 19:00:27.463	2026-05-12 19:00:27.463	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
52030985-71f1-41a8-8158-746a6e1fafe6	ba334f9c-4d8a-4c94-acd5-9823d0d60e1f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 19:04:20.952	2026-05-12 19:04:20.952	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
dbfaf0f4-60e5-46aa-a7bf-ee645496e8bc	74422af8-42f6-45da-a515-3d6f4251fdb7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 19:05:27.238	2026-05-12 19:05:51.907	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a268fd3f-faef-4142-af14-b99d798d1665	f5545853-41a1-46e2-a7ca-70a3c7714f1b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 19:06:48.793	2026-05-12 19:06:48.793	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
31e52828-9bd8-4b58-9fa3-24d1effac8cf	b169a84a-1256-4ae8-bc9f-308629274744	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-13 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 19:08:40.322	2026-05-12 19:08:40.322	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2433ecba-9f0c-46b7-830c-0e5ac77c8f73	baac22f8-b5cf-424d-a275-7921088e18d0	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 19:10:06.245	2026-05-12 19:10:06.245	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e9374837-c5dd-401b-8d21-09bf243f0905	4bd929fb-a536-4e2d-9bf0-837634d76370	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 19:11:54.123	2026-05-12 19:11:54.123	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d491d921-09d6-477e-82ea-08d90202303b	b81a3908-21e5-472a-a121-ddb763d21638	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-07 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 20:08:58.533	2026-05-12 20:08:58.533	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9c2f9ce7-e286-4eca-b61f-9b0887c86c65	3fefeb34-8abe-4ecb-9508-03bb2395346f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 20:59:29.479	2026-05-12 20:59:29.479	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f4cbd1bb-a242-481e-9a40-7cade36ce394	ca2be13a-9176-4b43-8314-40eaed72027e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-08 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:02:46.733	2026-05-12 21:04:28.858	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d2f8ff57-3fc1-44ab-90e4-cccff136f6ee	2b87e871-aade-4f8d-a6be-726da730ef6b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:07:44.343	2026-05-12 21:07:44.343	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1ee5d09f-aca0-4e6b-a052-3bfe19a6a2fd	b32d71f7-2d8f-4923-a2b4-604f640aca69	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-16 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:09:13.462	2026-05-12 21:09:13.462	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2c1fd779-0d10-4b58-8a3f-ce3d1280226d	505eb8af-b8be-4b0f-8074-9bcddc422b2b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-15 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:11:22.205	2026-05-12 21:11:22.205	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9bf91240-598c-410e-8a77-ba148f45140b	49d4bf67-6569-4e44-bf96-b80f210fda92	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:12:38.286	2026-05-12 21:12:38.286	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3460d4bc-0db1-4fd4-97d4-7fabeef281cb	bcdfe6c0-f61a-4831-88f3-f284058d8ce6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-22 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:13:48.98	2026-05-12 21:13:48.98	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ef9e0d21-70fb-4285-8b12-2a47d74878b2	8bc3f30b-309c-42f7-9f52-046e95de6276	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:15:08.034	2026-05-12 21:15:08.034	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
8a9aa5b3-bbfc-41bc-98df-a0d87549ae34	beea360c-2426-45c5-ad86-8d97db9ee8e3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:21:58.242	2026-05-12 21:21:58.242	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d0067eaf-8e6d-416b-aa2f-8f2a3f81aad7	379fc5f6-7b00-4ef1-a411-653cc3f32eec	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-11-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:24:46.64	2026-05-12 21:24:46.64	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1dae45c1-9196-4979-9e08-81cf1f86f397	d6ccad63-d87c-4ed1-9c65-e54fd66bb3e6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-03 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:25:55.351	2026-05-12 21:25:55.351	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c0ca4a17-c898-454a-a17a-ea1969bbac34	22d2c6ac-46bd-4361-80d7-284c5b1caf12	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:27:51.288	2026-05-12 21:27:51.288	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ca749e71-5997-452e-832e-28677a573c24	2c473852-96e3-4f0e-9448-e4b290899f36	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:30:01.713	2026-05-12 21:30:01.713	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
17fcee25-40ef-4e5a-aa1f-850a6e1bd344	87bdd0ce-dffe-4452-b101-1d9da394055e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:31:11.902	2026-05-12 21:31:11.902	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a047da88-4122-44da-81b6-095d5a502907	eac9fb5f-186e-4f90-9e2c-fece5ed96835	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-12-31 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:32:19.398	2026-05-12 21:32:19.398	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
74a09b1b-1a0d-41ad-ac20-1c53c786ad96	d71a7af2-a465-4e4b-8b32-b30ac472da3b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:33:22.071	2026-05-12 21:33:22.071	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f7fdcc51-56a6-4cb2-8ec9-febb101a28f3	54f921fb-0c0c-4cc1-b6e8-f60d54403705	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-07-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:34:22.663	2026-05-12 21:34:22.663	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
8fe09d8a-fd97-4934-9bb5-6aac5a47bfd5	797ad34d-0c09-4b19-b41f-f85d9b7b2734	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-02-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:35:37.337	2026-05-12 21:35:37.337	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
df6af0f5-cb33-4a61-8fc1-fdde14338393	cf1d4f92-80ff-4993-8bdd-71ace8489f2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:36:40.341	2026-05-12 21:36:40.341	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5d06c764-6be7-4192-89df-e316685fdf79	c25e7f8e-c698-41c0-9a66-76f2bc76f445	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-25 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:38:45.728	2026-05-12 21:38:45.728	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
676d3a5f-7b9c-4a19-8645-c2f0ade2ce4c	cd0f5594-8495-4bc3-9178-fc0e8855c19d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-12-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:44:20.016	2026-05-12 21:44:20.016	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
71d9f393-d475-47b2-9c43-3702a7a5faa4	d87b5051-a000-447b-bd0b-721aabc3d207	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-08-02 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:45:20.184	2026-05-12 21:45:20.184	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5b54883b-95cd-4b7e-a656-18c616fdad68	f9d58793-cd3e-4920-8118-7b5adf42c467	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-09-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:47:14.129	2026-05-12 21:47:14.129	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f3f03681-3639-4606-8564-085f1562c07b	f49f8b5e-b72d-4b45-a8a1-7216d1012065	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:51:45.987	2026-05-12 21:51:45.987	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6bbe4a54-e37c-44de-b6f0-900d6ede62bd	6b502b54-1620-4ac2-91d8-9aebf17bce83	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:52:42.021	2026-05-12 21:52:42.021	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
14c16f81-1606-4907-8c7a-ee8fb6dedc00	6dc66c97-7553-4a32-9a45-5a2af414128e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:53:55.124	2026-05-12 21:53:55.124	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a4fc32f9-088a-45fa-aadc-c6c774f9d82e	67b9ada8-e7e2-4bf9-83c1-7b23812d77fc	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:55:10.272	2026-05-12 21:55:10.272	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a95ee826-f96c-4205-bf2b-10d2f58ed9a9	9be71f64-715b-4309-a173-09080275a11c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-02-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:56:02.806	2026-05-12 21:56:02.806	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c4ec11a8-1cd4-4cfb-a875-06eb2d0f146e	c9a59bb0-22f9-4163-b915-e3db808c43da	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-13 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:57:00.157	2026-05-12 21:57:00.157	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1ca7dce4-56c0-4c6c-b87f-c710676d9f9c	841485d8-9d42-4798-abb8-bf2ee07bbfcc	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-17 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:58:16.95	2026-05-12 21:58:16.95	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9c949c43-2cc1-43cc-b441-fcbacd9109d4	37cf83a2-fc07-48a3-a239-9decbb397fc2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 21:59:10.219	2026-05-12 21:59:10.219	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
cbd32c64-7905-4d6d-8951-7593f52d4e51	4179fe20-cdc2-4058-9a98-0fcb9f6f871b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2027-03-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:00:24.096	2026-05-12 22:00:24.096	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1afca80b-5354-4a0e-891a-0f41e4732777	78536aa7-702e-4c71-be4d-60338c11a054	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:01:36.544	2026-05-12 22:01:36.544	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5cf6819d-18fe-497b-ac7b-9d6b8695650e	3e1075af-dbda-4157-95a1-64e356170021	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:03:22.798	2026-05-12 22:03:22.798	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
60c29dca-527a-40e3-a18a-fcef5af7b710	d8f28584-b77e-47ea-a759-360927038451	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:05:35.575	2026-05-12 22:05:35.575	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f656bed5-2eb8-433b-a57c-1c169ea0f9a6	a13eb0da-fca8-4fdd-b069-d9ee31d84c81	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-06-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:09:24.01	2026-05-12 22:09:24.01	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b609f8a0-f1b3-478a-81e8-587c30e37ea7	2c0aa1d4-f3f7-44e2-8516-a724e2990d3b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:11:59.168	2026-05-12 22:11:59.168	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ff38a90d-6b6d-4a83-9ef8-345cf4d7b939	f5aa5643-fd47-4b8f-b4d7-57a6b988f7af	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 04:00:00	2026-08-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:39:06.002	2026-05-12 22:39:06.002	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1c0d441b-7091-4a06-b602-db7387dc333d	03222926-4b5b-4f24-90ec-275aef476bd6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-12-30 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:44:10.417	2026-05-12 22:44:10.417	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0cec6754-9e86-488e-a317-cbcc688b41ef	b89d7a62-ead2-4730-a8d5-bceacaeab00a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-28 04:00:00	2027-02-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:45:19.419	2026-05-12 22:45:19.419	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
947cfcd7-3c58-47ca-bd83-c5236388b41f	ef8719ef-4f37-40e2-bc60-906284743842	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-06-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 22:48:54.384	2026-05-12 22:48:54.384	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
467d17a5-3f00-464e-85e6-c6d9cf970da9	d897fa6f-52cd-4f6b-aa0f-0e0d9086123d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-28 04:00:00	2026-05-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:16:17.148	2026-05-12 23:16:17.148	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3b8115db-12cb-4ee8-a632-8ec6604d47dc	8ef6aab4-36e5-4e7a-92aa-f195b92e8384	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-06-09 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:21:16.551	2026-05-12 23:21:16.551	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7f89326e-6e0d-4095-b436-0ddcb1140b87	b4b33973-4a5e-4ee7-8cc5-f58b2955a51a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-28 04:00:00	2026-07-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:26:57.985	2026-05-12 23:26:57.985	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
054e9307-77d1-45d3-8f79-76ee041799ed	c1d47b2a-2f9a-486e-8750-afa7479dcf9b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2027-02-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:28:45.907	2026-05-12 23:28:45.907	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e5d6ed8b-0b1d-4350-8e99-840c2da89e06	c04cc4b4-b36a-42ae-8782-cae4187bf140	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 04:00:00	2026-06-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:29:59.445	2026-05-12 23:29:59.445	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f724e9ab-99ae-4d49-8fd0-4d1e7fe7e002	9ccea574-c459-44a0-8558-d1d49048d9d4	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-04 04:00:00	2026-06-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:31:35.011	2026-05-12 23:31:35.011	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2fabf3a8-7b15-4ac7-8add-ed1938733c41	2a2eda73-fac0-40c1-adc6-3c04e4ce6514	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-30 04:00:00	2026-05-17 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:32:49.64	2026-05-12 23:32:49.64	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ae98f41d-6fbc-4843-a36b-8b8dba214c8c	f3826acb-1d1e-4b78-be81-49089d60bfa5	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-06-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:34:01.087	2026-05-12 23:34:01.087	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
98f47c95-e353-4d91-beb1-6485a564d04f	a3befa2b-236e-47a7-9707-99f3f4990cc1	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-28 04:00:00	2027-04-12 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:35:13.911	2026-05-12 23:35:13.911	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7d24c31b-f051-44b4-a6ad-699f7a9a0ad0	40696459-c69c-477c-843e-a1e1ab4ab577	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-28 04:00:00	2026-05-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:39:02.499	2026-05-12 23:39:02.499	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
634a99c0-7d22-437c-99e5-ac43bc23971c	1eeac0f0-9d77-4b64-a4fe-18fb5624b490	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-29 04:00:00	2027-01-31 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:42:12.493	2026-05-12 23:42:12.493	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7e4be064-873c-4992-a072-ba14adc22924	f28ec386-5e47-49d3-a7b2-3c7f82eb99d0	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-04 04:00:00	2026-08-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:50:58.113	2026-05-12 23:50:58.113	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6c7e15e5-53f5-4924-a813-9566827ff6c8	fdd4d29f-3bd9-435a-a36d-572f60c87955	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-05-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:52:29.653	2026-05-12 23:52:29.653	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
16bd1fc8-6c51-45d8-ae90-4e39f68410e5	ff67e061-11b0-463d-8b74-3933a04dca84	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-29 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:56:03.948	2026-05-12 23:56:03.948	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c4858702-aefc-44e5-ab0d-327d349fb5a8	93318a74-e5ae-48f6-a025-6a7630befe98	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-09-25 03:59:59.999	ACTIVE	\N	f	\N	2026-05-12 23:56:55.853	2026-05-12 23:56:55.853	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e4d7c1c5-3fb9-4728-a139-2081054c5aca	0df96f01-7d7d-40b2-b83c-dffb32335f08	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:06:45.83	2026-05-13 00:06:45.83	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
158b6298-93d6-445b-ae37-e51f2bdfdae1	5fe6f94e-3a05-4ce8-8a40-a4836cb14536	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-01 04:00:00	2026-07-31 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:10:27.133	2026-05-13 00:10:27.133	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5aa1d5d2-309f-4cfa-8c85-300ae050249b	a7381c69-fedf-41b9-904c-b27d92dd738c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-05 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:14:45.22	2026-05-13 00:14:45.22	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b97edb6e-9442-4a79-b8ff-55ec082efcc4	e3035eb7-c298-4c9c-a3b8-8b9c6eae36c8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:15:57.193	2026-05-13 00:15:57.193	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4f5b4585-a298-46ea-9562-702bd792132d	372cbe81-d2cc-42f7-a123-8f0abe4d4364	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-04 04:00:00	2026-06-16 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:20:25.629	2026-05-13 00:20:25.629	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
afc15f5a-8194-4382-bfeb-9551f79f9c8d	e440e085-b757-49b4-b2c4-5032f05e0894	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-11-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:21:29.842	2026-05-13 00:21:29.842	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2a181636-4813-4cf2-ac8f-5e1f62935e26	bce91afe-e91f-4890-80dc-2c4889144849	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:34:27.597	2026-05-13 00:34:27.597	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
356bea65-3b80-4ff1-ad46-5220cafd0f0c	40d039f9-47db-4f41-ba69-5a5441b377c1	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:35:24.884	2026-05-13 00:35:24.884	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0d571ee0-e16a-4c74-abc8-f04aeb31eee4	a37e6aeb-4b76-4538-bcba-e1febf1c5e43	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 04:00:00	2026-08-07 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:45:11.552	2026-05-13 00:45:11.552	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d75934f0-911c-4cea-b749-b95fe79470e3	b6a72b15-3214-47ef-86a5-ece55f53fd51	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-06-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:54:55.058	2026-05-13 00:54:55.058	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
08371bf0-ceac-4b34-ae5a-c4f5045120e5	5440c9e7-eef4-482f-acb4-cd742a255eeb	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-07-22 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:55:42.017	2026-05-13 00:55:42.017	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
37ecf975-0885-4ff9-8075-55de1efcbc44	7bcd2dac-1caf-446a-bba4-0003811ecf54	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-28 04:00:00	2026-07-10 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:56:44.927	2026-05-13 00:56:44.927	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
460123a5-cf3a-4b02-add5-7e7c0c3a3b87	da9da632-114e-47ab-aa02-73575091fe50	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-29 04:00:00	2026-06-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:57:48.516	2026-05-13 00:57:48.516	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
10d053dd-3d5c-4ced-b680-6db5a236c449	128eb675-3968-406a-9549-12f6e001c6d4	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-06-02 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:59:30.271	2026-05-13 00:59:30.271	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4de6d30c-b195-4daf-b745-f1cdfd9cd5ef	9342390a-5dfd-48c7-9e59-e41c71001ba6	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-29 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 01:00:22.229	2026-05-13 01:00:22.229	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b6ca4cc6-1bbf-404d-9a39-f9292f9c362b	e24f9d69-46b3-4680-a25d-3a2823822d1a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-07-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 01:01:18.059	2026-05-13 01:01:18.059	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0a3f3a28-362f-42c6-99b7-c31dabfc09b6	80e6cdb2-9234-431c-a2e5-ef9ead2b6047	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-05-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 01:01:58.615	2026-05-13 01:01:58.615	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
82935fa4-5850-4561-9a55-26b13d5d3f74	82a7c55f-ff8c-4b42-9634-c972014044dd	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 01:14:09.669	2026-05-13 01:14:09.669	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
cf5be022-da1a-41e8-8ee6-bb49f05cb762	8d19ba4d-33cb-4b5a-9088-c22a5086b8a0	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-04-27 04:00:00	2026-07-13 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:17:05.184	2026-05-13 00:17:05.184	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
8c79b363-358c-4a80-888e-a30100460746	7028f55d-e95a-4604-9f3c-4ddb00e6ce6a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-12-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:02:02.362	2026-05-13 13:02:02.362	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
54b173c8-0bb8-4f46-9e78-b3adb41522bd	1328b3bb-1baf-4201-8f7d-9621e1e98589	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	\N	f	\N	2026-05-13 00:58:43.65	2026-05-13 10:46:26.093	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0e03934e-a21f-46c5-96ba-f12ccfe21e3b	d3876ad7-c371-4bd9-9c51-460798e6b455	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:01:06.143	2026-05-13 12:01:06.143	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5992b95f-c50c-4469-95fb-328171f5b5e3	560bcc29-da11-4c37-a2b1-a977943bde1b	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:02:31.542	2026-05-13 12:02:31.542	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1af8ea05-3125-4ccc-8d13-02837c51c5d6	25719a87-74b6-4346-b6ef-3565129b507a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-12-31 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:04:54.008	2026-05-13 12:04:54.008	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5ab27790-085e-4fcb-87d4-f6de12765a4d	d3185606-5ad8-4aca-ba11-758f0e6998f3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:06:52.549	2026-05-13 12:06:52.549	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
6049c58b-cb8f-4869-aa38-eeaee74f62d5	acc4cb5d-8a05-4951-a24f-12ceec630469	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-08 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:10:44.987	2026-05-13 12:10:44.987	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b2e50b5a-a9ff-4626-ad56-f541183ac16a	f460a0ff-b769-45ed-be64-cea480b52c05	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-09-30 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:20:28.806	2026-05-13 12:20:28.806	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a68e064b-493d-415f-b088-3c08f32778ed	b53b1657-5bb9-48a1-8d4c-f65861028790	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:22:05.168	2026-05-13 12:22:05.168	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
fa35d606-3446-49a1-a313-8b561f47a49e	02717d42-a2d8-4c53-bb74-e357a250c0e2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-09-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:24:21.419	2026-05-13 12:24:21.419	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3bb829b1-973e-4712-ae86-9d5135e4b61e	9fe4f4f4-9aef-443b-9d1c-3cbc3c88aba2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-07 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:26:00.355	2026-05-13 12:26:00.355	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
a8b6aeac-79eb-4ed6-8aaf-09fe67b66f71	6105b207-ea61-49ce-9592-1b9c9c5a34f1	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:35:30.243	2026-05-13 12:35:30.243	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5005e85f-1ab9-4d53-a17b-77ae0a043d0d	a35c2c66-4c33-41de-9337-610612e3aa01	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-12-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:38:24.825	2026-05-13 12:38:24.825	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3ae87517-4ab3-47c8-8e56-eac764b17101	97d2dd8c-fee6-46d8-a6ca-d6aaddf3bab3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-01-01 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:40:03.369	2026-05-13 12:40:03.369	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c760b36f-e999-455a-835f-5ab8cf773285	4208e2b8-0c1c-4038-80f6-8116edd89f09	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:41:25.997	2026-05-13 12:41:25.997	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4ccc5591-aabe-459c-9efa-019fde4922dd	b28ac5e8-3b26-4095-b1e7-615114dbb89f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 12:58:02.142	2026-05-13 12:58:02.142	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
66df4943-7884-49a9-a3bc-8db880f3b847	3edfda55-e29d-4bbd-8264-d96319e4c848	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-11-08 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:05:10.987	2026-05-13 13:05:10.987	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7ee68b6e-a8cd-49f4-8b74-074ccda17173	e6e24fd8-a58e-4ec8-a9a8-0e5de15e586d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:06:47.388	2026-05-13 13:06:47.388	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e7eb409f-0c45-4d26-86cf-68ce95d3cd21	151e2cec-4b9f-4d7c-b435-16b040097bc8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-07 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:08:02.137	2026-05-13 13:08:02.137	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
cd984d73-b7d4-4bfd-9a3d-3064e0965af3	432c9309-25be-4937-a3bd-0fa681fc0f48	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-08 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:38:38.81	2026-05-13 13:38:38.81	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
422fe6a4-8065-4eb5-be2b-f1d809a26c15	c56d4e2a-8930-4351-ae22-7009596945a3	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:43:01.211	2026-05-13 13:43:01.211	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4c8ab809-7d16-4272-b1b3-03daf3a2e3b6	0a503a53-66ed-4782-8e4a-a283b45aab48	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:48:32.466	2026-05-13 13:48:32.466	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e276bb02-e4ca-43ee-94ee-30b423418d83	c4903655-5743-4f9b-b8e9-fe184dadf7b8	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:50:37.345	2026-05-13 13:50:37.345	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
127a8a9e-5e4f-447c-b3f2-506905fe1838	25984e47-90b6-442a-a889-bd7bb49744f7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-17 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:56:25.801	2026-05-13 13:56:25.801	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ec1df2ab-a6b6-4bd1-aa0a-aed9526e0667	daf0cd54-c39f-4bc5-b641-fee276a92778	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-13 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 13:57:52.698	2026-05-13 13:57:52.698	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e23c87a6-0015-4cde-a821-58ee15345b69	1fda80ce-6bf0-4551-b364-1e5666696e2e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-07 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 14:04:03.609	2026-05-13 14:04:03.609	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
617fb8d5-983b-4f0f-96d9-757f4553ae94	75add031-eb78-4a5e-a681-c22f896e93dd	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-04-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 14:07:17.713	2026-05-13 14:07:17.713	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9d5621c2-6df8-423f-9ff1-45173e78e891	38bb5b7f-71c7-4913-9d37-881777be2797	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-11-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 14:44:40.939	2026-05-13 14:44:40.939	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3e0d9912-67bb-4ce8-bb08-5dca6e01544e	caf160f2-6cfa-4d9c-9c8a-1674bd5a8918	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 14:46:13.126	2026-05-13 14:46:13.126	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
46cd42a0-b1a7-4ba1-9551-d98954f8a6a2	494d0d89-097d-48e3-b153-3fb22adccbd1	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 14:47:34.024	2026-05-13 14:47:34.024	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
34a01d08-9803-4142-92f9-f98f9041945e	c8e56477-6d8d-4e23-bfca-59335a3c3197	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 14:49:29.08	2026-05-13 14:49:29.08	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3dca86ff-28e9-426b-9389-8b21ba3d7340	7008574c-4ece-432a-b96c-ab1a811a8a98	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 14:58:47.848	2026-05-13 14:58:47.848	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f020f7a4-15a2-423c-9f9f-d1a63b19d465	4612f9e3-113c-4aa2-afd6-4919a8355059	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 15:01:30.715	2026-05-13 15:01:30.715	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
06120944-47be-4a44-bbb5-7f2f8befb398	0d207e62-7aa9-460d-9886-8a7b0f838b6a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-02-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 15:07:50.154	2026-05-13 15:07:50.154	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d61c2c2c-42f3-4b36-b4d8-9dd613c61a3b	e32946cc-21ec-420a-9ca5-359a5f29b176	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-03 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 15:18:42.176	2026-05-13 15:18:42.176	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c19eb5de-6ae6-448e-98c2-4c233a5b5f14	84d549d6-b9ff-42c5-ac56-dc15aebf58ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-08 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 15:45:11.449	2026-05-13 15:45:11.449	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d49c588e-5d4f-4e2a-8122-d3dfc29f131d	9560c458-7aef-464d-b47c-f073f1d6f3ee	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 15:49:58.523	2026-05-13 15:49:58.523	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7e97dcb9-0aa4-401e-8579-a675330c4440	92467230-fa62-430d-a8a3-5c12541a3d70	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-02-02 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 15:57:28.576	2026-05-13 15:57:28.576	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
522a5a8e-bce8-4293-ab6f-b7edc18b6414	958a722c-2b94-4350-8176-55eb498d71c9	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:01:15.779	2026-05-13 16:01:15.779	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2e944543-d4da-4a4a-bb44-1bae7ddb78c8	e362210c-2556-484b-8211-a29a41576a0c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:02:43.358	2026-05-13 16:02:43.358	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7b5e008b-cf18-4aa9-983b-6cfc0385a610	5cb5bbf5-4215-4c96-a91d-3659c47d7004	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:11:10.752	2026-05-13 16:11:10.752	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
757df239-2170-4754-8d87-0589c6ad0431	dfe136b3-1d7d-464c-a2c2-608a20c05465	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:12:31.015	2026-05-13 16:12:31.015	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
48c5d8b0-87eb-479b-8ef6-64bc7161c8b7	2f5b648e-7130-4703-837a-afc3fac32aa0	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:13:57.37	2026-05-13 16:13:57.37	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5d1365d0-4313-43c1-9ee8-f44b1d4fe52f	09444357-d818-46fa-9a00-1d4d6730e188	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-03 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:16:09.494	2026-05-13 16:16:09.494	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bcb72a02-6231-4d6c-abbc-56dfce3e8e49	78a28621-1984-46c7-b399-41b37b32b364	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:18:12.795	2026-05-13 16:18:12.795	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
27b606f7-da1b-4e51-a0a7-c01cd863693d	07a93134-4420-4493-83e0-a79a04229f61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:19:51.163	2026-05-13 16:19:51.163	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7d695cef-aa25-4806-8467-ddaec5b9214a	386355ce-1913-40f6-affb-80ac1576859e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-02 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:21:36.993	2026-05-13 16:21:36.993	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
978d4b48-a7c6-419a-8d2b-e7d1439a051c	c804208f-9b00-40ac-8f50-6aaea5f1b7c7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:26:57.618	2026-05-13 16:26:57.618	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2b3597ec-0721-4496-8ca8-c3a26543652b	8fadbb0c-559d-45bb-97b7-b4f8e096a2d4	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-01-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:32:13.404	2026-05-13 16:32:13.404	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
475cdf46-74fc-4e49-8b93-80da07efd210	49230980-23d7-40cf-8372-abb87aff12ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-09 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:34:20.391	2026-05-13 16:37:30.39	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
98b66ce0-94f6-405d-a47c-d90fa57f213b	b8a6b8df-3daf-4ded-89bd-aaf7a4bde2a1	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:39:09.394	2026-05-13 16:39:09.394	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
29b3b53c-c773-4896-a3e8-bc1f7e265e12	6fcab6d7-4652-483a-ae23-5ad05582d5d1	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-22 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:40:26.251	2026-05-13 16:40:26.251	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9b86caa4-874d-4f21-8403-37a099a2a621	a927df4b-d10b-4e8e-ac02-ef5f78ee82fd	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:41:32.471	2026-05-13 16:41:32.471	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
9bee3fd0-495f-4e6d-8d7d-1d15998d2b61	611de2b5-c1c8-443b-b1ce-f0a786a1cd82	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-02-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:45:07.562	2026-05-13 16:45:07.562	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
10e9121e-9b0d-4919-afa8-8739ed188ed8	580a5edb-5baf-4328-9759-a125936cca0c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-06 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:46:24.998	2026-05-13 16:46:24.998	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4a6682c1-2c53-4b4a-957b-2085f2feabc8	9c68a247-ccef-40e6-a8dd-3fdba411f12d	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-23 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:47:43.719	2026-05-13 16:47:43.719	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4255be1f-9ea7-4706-b859-246c31711015	928a4b6c-c714-4ed8-bc7b-16e578aebc41	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-12-16 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:55:44.693	2026-05-13 16:55:44.693	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
d752a174-a46c-46d2-aa58-74063b02829f	c6d315b6-8b52-421a-9b9c-a77ff639022e	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-11-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:57:04.655	2026-05-13 16:57:04.655	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
81cf63d7-32ab-48a1-badb-4d5f89b162de	bae8a750-4296-43fa-bd65-9f0c827365a7	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-29 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:58:20.567	2026-05-13 16:58:20.567	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
712dd28e-8c7d-4452-b334-c551cf012707	ce1ff1f0-9262-435b-bd17-78b1fd25fc24	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-24 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 16:59:40.105	2026-05-13 16:59:40.105	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
0de780d1-7b37-4190-ad28-77c803ee50de	cab49eaa-9177-4514-b647-279e032aab0c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:00:48.386	2026-05-13 17:00:48.386	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c30de925-4c51-439c-b22a-f463bb1a80a9	0f8e1a36-c6b9-49b5-8ba5-ce178077c88a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-06-02 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:03:15.474	2026-05-13 17:03:15.474	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
b8a5a1a1-3a29-4c22-bd15-836cc19d88ee	b6f67fec-5790-4e2f-8f90-125612a3c29c	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:07:22.178	2026-05-13 17:07:22.178	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c8c01d63-8f3b-4f42-bc02-c36f032da15d	09402461-b3c0-47bf-820d-abf9ed3b2661	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-17 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:08:27.619	2026-05-13 17:08:27.619	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ab6b33ba-c8ac-47e0-912c-21c05e2d0d4e	51d1d5e0-7be3-4473-ad9a-2863df29a507	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:10:11.771	2026-05-13 17:10:11.771	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
98f20a71-84e7-49cb-a1b7-85ddc483b033	7dfdc883-425b-444b-8855-8e3ed40501b2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-26 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:11:32.168	2026-05-13 17:11:32.168	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
19649a03-e44f-4840-9c4d-8fdc7bc9843f	883760f8-eeb8-4bd8-9d8d-bedb77ff8f02	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-27 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:13:44.926	2026-05-13 17:13:44.926	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5ed8b785-69b1-4195-8931-73dbafcde844	e6187633-0f88-4896-a42f-8a39a9e67f88	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-19 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:14:58.879	2026-05-13 17:14:58.879	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
af959772-2922-48e6-959b-39bfe4b42dca	c623c23b-5da4-4b94-bf23-263187c4a392	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:26:52.274	2026-05-13 17:26:52.274	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
5a8a64ac-0201-497c-8d30-c04c778176c7	b91ec917-d1f3-4838-b542-09992ef68a3a	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:28:18.037	2026-05-13 17:28:18.037	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2fadfed6-991e-4632-a611-509c0321dda4	07a698a1-0f64-4f65-b8ae-f16aa203b143	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-02-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:31:27.865	2026-05-13 17:31:27.865	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
f87421d9-59bd-46d5-ae37-d8180a4a714e	47034143-833a-42ce-b066-b3f8ff358977	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:33:36.448	2026-05-13 17:33:36.448	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
2a5b9c5d-5ae4-4974-95b4-803658dd1abe	2337c795-7592-40e6-a6c2-355e855b9e96	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:34:51.923	2026-05-13 17:34:51.923	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
dbaf1301-9734-4adb-b970-784b993a040a	9487b2c6-7fe4-41fe-b92b-9034df0d2597	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2027-01-18 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:38:03.839	2026-05-13 17:38:03.839	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
21771cfb-2c5f-4665-a433-af65c93ce0fe	1c21828d-94a8-4050-a546-cbca00dc17f0	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-20 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:39:08.72	2026-05-13 17:39:08.72	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bce7c603-2016-4488-931a-d52a193ab6b5	79d187ec-9603-4c9d-83d1-b3854a951c8f	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:41:19.307	2026-05-13 17:41:19.307	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bd69f49c-7ff0-4171-b5dd-17aba215830a	8c12163c-ebdd-4842-bb18-7bc0f50f6fbc	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-21 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:42:38.496	2026-05-13 17:42:38.496	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
445d745c-bfa0-47cf-9840-41e7f77b07e3	3004aa20-e37a-43c3-b807-ccaf85841daa	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:44:12.073	2026-05-13 17:44:12.073	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c77121a3-dd3f-4d59-bdcf-9c71224d48c9	5b5c5739-ea30-4366-ad38-2c4571dcdcfb	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-05-28 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:45:22.298	2026-05-13 17:45:22.298	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
c7094d87-47d8-4941-bab2-8ace12a885a2	62b3b1f3-aeda-4c59-bfeb-8233dd6fc277	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-07-02 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:47:58.117	2026-05-13 17:47:58.117	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
cdbb1955-56a9-4d48-8c3d-55d753634004	91c044a8-45b4-457f-b12d-f937c6fff0b5	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-08-05 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:49:06.72	2026-05-13 17:49:06.72	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
e79e8656-f62e-4527-b6d0-5d9aaeda7f22	ba1992b4-d270-4aff-b98f-f3c519f52354	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 04:00:00	2026-06-04 03:59:59.999	ACTIVE	\N	f	\N	2026-05-13 17:51:00.349	2026-05-13 17:51:00.349	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
\.


--
-- Data for Name: Device; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Device" (id, name, ip, port, username, password, "deviceType", brand, "isActive", "companyId", "branchId", "agentId", "lastSeenAt", "createdAt", "updatedAt", "lastConnectionAt", status) FROM stdin;
bed04ca8-c544-4c05-a772-c780498a35f6	Entrada Oficinia	192.168.88.8	80	admin	U2FsdGVkX1/CiHx3UkUUHi6jV+5yoaJlxFgT8GcuHoA=	ACCESS_CONTROL	HIKVISION	t	6b828940-7fc0-449f-8a26-f91d237a0940	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	\N	2026-05-11 14:12:10.637	2026-05-11 06:53:48.567	2026-05-11 14:12:10.639	2026-05-11 14:12:10.637	DISCONNECTED
3db306d4-a4c8-471c-8adc-f43096810718	Salida	192.168.0.9	80	admin	U2FsdGVkX18l3WuLvFZUCLd/L8FP3tRSb/og4zYYPX8=	ACCESS_CONTROL	HIKVISION	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	\N	2026-05-13 17:50:38.108	2026-05-07 22:38:26.283	2026-05-13 17:50:38.111	2026-05-13 17:50:38.108	CONNECTED
d0316808-230a-4f9b-be69-99baa051ab4d	Entrada	192.168.0.8	80	admin	U2FsdGVkX1/1zn8OTiOLKuYUB9kcx0CbtBMdrhkFxwE=	ACCESS_CONTROL	HIKVISION	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	\N	2026-05-13 17:50:38.115	2026-05-07 22:38:03.818	2026-05-13 17:50:38.116	2026-05-13 17:50:38.115	CONNECTED
\.


--
-- Data for Name: MembershipSale; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."MembershipSale" (id, "partnerId", "planId", "companyId", "startDate", "endDate", status, price, "createdAt", "saleDate", "userId", "branchId") FROM stdin;
5aeac523-0a95-46e4-9910-2e40778bb025	4b5a5b43-8414-48d7-a9b5-4491f2f59336	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2027-05-08 00:00:00	2027-06-07 23:59:59.999	ACTIVE	150.00	2026-05-07 23:00:25.493	2026-05-07 23:00:25.491	a484e2d7-a009-4c8a-8237-b3323c036405	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
61248ce8-03d7-4b5f-ad50-a4ff4b09b0e3	156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-06-08 00:00:00	2026-07-08 23:59:59.999	ACTIVE	150.00	2026-05-07 23:16:47.884	2026-05-07 23:16:47.881	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
3cd48ba4-03a9-4efb-9c1a-d9418d49e4d6	1faf3a07-9b37-4f07-9f77-e33fbf855ed6	697be97f-0a12-4ec0-a7d6-5e5046afcdd0	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-08-06 23:59:59.999	ACTIVE	300.00	2026-05-08 00:11:59.456	2026-05-08 00:11:59.451	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
138c5307-77bb-43b6-8f32-06a98a4b0629	de09cfdb-ea36-47be-ba0f-e121fbfa49a6	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-07 23:59:59.999	ACTIVE	130.00	2026-05-08 00:38:58.674	2026-05-08 00:38:58.67	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ca135ba3-6a7e-485d-b877-1a3dd30941fd	f259ee60-7a93-4e2c-ae61-7c4cf6215575	ff7413fc-a352-4e48-a411-c1a79e2b4b59	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-05-09 23:59:59.999	ACTIVE	30.00	2026-05-08 21:07:27.83	2026-05-08 21:07:27.826	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7ff50cc3-591e-415b-9847-ee73f4b81b05	cb882c3e-8c58-4b6d-95b1-29d050a75abe	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:00:00	2026-06-07 23:59:59.999	ACTIVE	130.00	2026-05-08 22:10:46.098	2026-05-08 22:10:46.096	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
87f2d771-7f57-45da-a7cb-03ac4f077521	e88ca8d5-16cf-4501-99af-6501f49ff7a8	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	150.00	2026-05-11 16:04:42.325	2026-05-11 16:04:42.323	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
73de0be4-deb9-4b84-9e48-8e377d23fca3	6aa91ec4-6251-489b-a4fd-c34cfccefad7	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	150.00	2026-05-11 15:39:14.684	2026-05-11 15:39:14.681	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4bcdc5a1-b23f-41fe-8128-6ec7b6782417	4f91dff1-41bf-4b30-b9e7-b5f72e5e875c	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	150.00	2026-05-11 16:06:49.058	2026-05-11 16:06:49.057	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
20c9167b-854c-4902-abc4-20b3d8dd0909	a2aa3f8c-d134-48a9-ae05-6bab8b5880b8	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	150.00	2026-05-11 16:09:13.416	2026-05-11 16:09:13.411	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bf606de6-2e35-46cd-bfa9-0c197f20bd87	d02259bf-0b2d-4a79-bd29-1d892299585a	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	150.00	2026-05-11 17:57:23.494	2026-05-11 17:57:23.49	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
090379ee-0c21-4ff7-852b-a60bc20b222d	3b4fdc49-f12c-4945-8797-69a0336d4beb	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	130.00	2026-05-11 22:10:57.51	2026-05-11 22:10:57.505	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
27033c47-06d4-4af7-aa4b-dbb5cd8433a8	1c82b0ed-7597-402e-9b5f-abfcc3a2cc48	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	130.00	2026-05-11 22:12:15.527	2026-05-11 22:12:15.526	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
248694cb-6dd7-4bcf-8aa1-a90e7d6dd723	eacad3c1-2395-41ef-9633-32c9163fc689	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	130.00	2026-05-11 23:31:39.088	2026-05-11 23:31:39.085	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
df3a5ef7-c10e-4d62-a926-f62d40a6fb7f	476f493e-162a-4d08-bbdd-939833a866d6	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-06-10 23:59:59.999	ACTIVE	130.00	2026-05-11 23:44:17.292	2026-05-11 23:44:17.291	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
ac134f26-fc20-4788-ac3f-72715623536d	2ef332b0-b371-4564-997d-96f1212cded6	e13b2784-d129-4d98-9106-571b727e2ae2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	260.00	2026-05-11 22:23:52.166	2026-05-11 22:23:52.164	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
dafc529f-47c1-48ea-8620-af9045bbb857	053c65a6-8814-4d31-a97e-59472a996abe	e13b2784-d129-4d98-9106-571b727e2ae2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	260.00	2026-05-11 22:25:23.223	2026-05-11 22:25:23.221	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
be8bdf90-48e9-457d-95f1-750450f4d968	9213415e-a653-4348-832a-bf9810200933	e13b2784-d129-4d98-9106-571b727e2ae2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	260.00	2026-05-11 23:38:55.913	2026-05-11 23:38:55.911	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
317dcca7-9f8d-40ad-be26-2aa2320f218a	a1522040-1855-4193-ac97-9f965f584f11	e13b2784-d129-4d98-9106-571b727e2ae2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 00:00:00	2026-08-10 23:59:59.999	ACTIVE	260.00	2026-05-12 00:00:06.558	2026-05-12 00:00:06.555	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
4046278e-2488-4853-a218-9ed3a4205994	9c776bb9-61c5-4ee0-9614-5be0fb97d317	e13b2784-d129-4d98-9106-571b727e2ae2	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-11 00:00:00	2026-08-09 23:59:59.999	ACTIVE	260.00	2026-05-11 16:02:18.714	2026-05-11 16:02:18.704	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7841a82c-a595-4818-a494-9fee6bd1249c	0df96f01-7d7d-40b2-b83c-dffb32335f08	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	130.00	2026-05-13 00:06:45.858	2026-05-13 00:06:45.856	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7c035ce0-a366-4381-8bb5-0be9d8fdc247	42d89532-31d5-423a-9007-f83b454116bc	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-12 00:00:00	2026-06-11 23:59:59.999	ACTIVE	130.00	2026-05-12 12:41:09.888	2026-05-12 12:41:09.887	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
1913ef86-3942-414a-a107-392ec68176d8	bce91afe-e91f-4890-80dc-2c4889144849	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	130.00	2026-05-13 00:34:27.625	2026-05-13 00:34:27.622	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
7a2c23f7-3610-47b8-bbe7-763ce992283e	40d039f9-47db-4f41-ba69-5a5441b377c1	531f0a99-dcc1-4a33-9eb2-6d592c805893	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	130.00	2026-05-13 00:35:24.903	2026-05-13 00:35:24.902	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
bc9659b2-f60e-4971-9b44-024f874d7e3f	1328b3bb-1baf-4201-8f7d-9621e1e98589	97be790e-4f8d-4b7e-8b97-6c51a32f1e61	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-13 00:00:00	2026-06-12 23:59:59.999	ACTIVE	150.00	2026-05-13 10:46:26.14	2026-05-13 10:46:26.134	543856ad-d4b6-4be7-93b5-e9bf0052c782	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2
\.


--
-- Data for Name: Partner; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."Partner" (id, "companyId", type, name, document, phone, email, address, "isActive", "createdAt", "imageUrl") FROM stdin;
6a35612f-c381-4125-928c-378dbe431e69	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JHON GOMEZ	77995206	77995206	\N	\N	t	2026-05-08 13:10:31.361	\N
6925106d-aaa5-4c51-86ac-1322bd50de8e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ADRIANA CHAVEZ	8148038	\N	\N	\N	t	2026-05-08 21:11:46.104	\N
4b5a5b43-8414-48d7-a9b5-4491f2f59336	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Antonio Dams	9852401	75688684	antonio.dams@hotmail.com	\N	t	2026-05-07 22:57:13.554	uploads/partners/1778194633989.jpg
22b1f9cc-4a9d-48ff-821d-da9d7a111974	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PABLO VERA	5822287	\N	\N	\N	t	2026-05-08 18:01:14.304	uploads/partners/1778263274969.jpg
5564e62d-031a-4094-8e7b-ca2e5f28f481	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Eduardo El Profe	5875939	7854126	jc.fitness.mutualista@gmail.com	Mutualista	t	2026-05-07 22:53:04.625	uploads/partners/1777922503018.jpg
b490945f-208c-4b2a-881b-35ffd0eded6d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GUSTAVO LEON	13705372	62810633	jc.fitness.mutualista@gmail.com	\N	t	2026-05-08 18:28:13.116	uploads/partners/1778264893721.jpg
156f4d6b-3a94-4ef5-85b0-6c56f5d24c0d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	EDUARDO DURAN	13046378	\N	\N	\N	t	2026-05-07 23:15:53.583	uploads/partners/1778197677040.jpg
1faf3a07-9b37-4f07-9f77-e33fbf855ed6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	HAROLD IBAÑEZ	8119213	\N	\N	\N	t	2026-05-07 23:56:13.15	uploads/partners/1778198173671.jpg
4d64fb5f-71c6-4b3e-8c84-16d3322ec84c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JESSICA HURTADO	11246971	69037751	jc.fitness.mutualista@gmail.com	\N	t	2026-05-08 18:38:35.437	uploads/partners/1778265516027.jpg
cad0d165-8aee-4e43-9cbb-8627fd3b600e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BRUNO MANSILLA	14871060	69287871	jc.fitness.mutualista@gmail.com	\N	t	2026-05-08 18:44:26.515	uploads/partners/1778265867010.jpg
29d96077-cf65-4862-93f5-650250ea47a7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JULIO CESAR	9621478	\N	\N	\N	t	2026-05-08 00:48:33.813	uploads/partners/1778630101307.jpg
29e13afe-9a13-44d7-a572-aafcfef194f8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ADRIANA ZABALA	9601969	\N	\N	\N	t	2026-05-08 21:13:18.928	\N
9d137b31-1c45-4940-929b-38a942ee224f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ELVIS TOLA	6239307	77800853	jc.fitness.mutualista@gmail.com	\N	t	2026-05-08 18:50:14.907	uploads/partners/1778266215461.jpg
9c776bb9-61c5-4ee0-9614-5be0fb97d317	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Alisson Borja	6194414	\N	\N	\N	t	2026-05-11 16:01:24.652	uploads/partners/1778580927371.jpg
bd4692d3-efdc-4abf-9c29-c9f755caf715	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ADRIAN MEDRANO	9671176	\N	\N	\N	t	2026-05-08 00:25:04.406	uploads/partners/1778202363079.jpg
0be16069-145a-4e3b-a50a-34abe7a5d640	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ABDAL RASHID SILVA VILLARRUEL	8995656	69103920	jc.fitness.mutualista@gmail.com	\N	t	2026-05-08 18:53:11.112	uploads/partners/1778266391762.jpg
002bd4b0-9fb9-4c32-a4a3-7d0ecb809ba9	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	FABRICIO DORADO	12357368	7631995	jc.fitness.mutualista@gmail.com	\N	t	2026-05-08 18:57:58.021	uploads/partners/1778266678557.jpg
6ee61762-c0c8-4c6c-b8c5-fbdb9ce48a13	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLA CECILIA	13557971	62108699	jc.fitness.mutualista@gmail.com	\N	t	2026-05-08 19:11:06.626	uploads/partners/1778267467149.jpg
6051cd59-bfc0-4276-921a-a60835f6547a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RENATO TERRAZAS	6303820	\N	\N	\N	t	2026-05-08 20:51:49.777	uploads/partners/1778273994659.jpg
f259ee60-7a93-4e2c-ae61-7c4cf6215575	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Emerson  Chuve	14765703	\N	\N	\N	t	2026-05-08 21:06:08.847	uploads/partners/1778274369318.jpg
51a3c33a-fd43-4b8e-a7da-ffd12a391655	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ADRIANA	14872588	\N	\N	\N	t	2026-05-08 21:03:05.96	uploads/partners/1778275915302.jpg
cb882c3e-8c58-4b6d-95b1-29d050a75abe	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ESTEBAN ARRON	18073408	\N	\N	\N	t	2026-05-08 22:09:55.504	uploads/partners/1778278195973.jpg
7efb284c-a286-4338-81fb-e39a36939875	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEJANDRO	14388010	\N	\N	\N	t	2026-05-08 21:23:30.42	uploads/partners/1778339912791.jpg
4f0db97a-5fec-4ea1-b80a-5eba4712134f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANDREA OROPEZA	5818391	\N	\N	\N	t	2026-05-09 13:11:39.118	uploads/partners/1778332299620.jpg
dd308e7c-278f-4b29-be5e-51bde9d3f51e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	FREDDY ARABE	3093497	\N	\N	\N	t	2026-05-09 14:20:57.4	uploads/partners/1778336458039.jpg
2304762b-0f36-411d-a173-7fd57932e0ce	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLA BARBA	12666734	\N	\N	\N	t	2026-05-09 15:22:36.236	uploads/partners/1778340156812.jpg
8a0434a1-0c0c-45ca-9f4e-bcc0f48a1f68	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEXANDRA CHURATA	10638033	\N	\N	\N	t	2026-05-11 15:10:49.906	\N
6aa91ec4-6251-489b-a4fd-c34cfccefad7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	sebastian hurtado	128854820	\N	\N	\N	t	2026-05-11 15:31:34.042	uploads/partners/1778513494861.jpg
42297e10-37c8-4426-9aa8-c2d958d0a622	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALCIDES DREW	4681035	\N	\N	\N	t	2026-05-08 21:16:26.147	uploads/partners/1778588819008.jpg
573da3d3-8cc9-4505-9a79-9ad5e4e797e7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALDAIR GALARZA	7675574	\N	\N	\N	t	2026-05-08 21:21:52.904	uploads/partners/1778512796744.jpg
6b2da3b2-7c71-4a8f-878a-8e50ab527eff	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEXANDRE	3234118	\N	\N	\N	t	2026-05-11 15:49:56.694	\N
965ab34f-78f7-4d62-8270-d34561994b34	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEXI SUAREZ	12985767	\N	\N	\N	t	2026-05-11 15:52:59.211	\N
4f91dff1-41bf-4b30-b9e7-b5f72e5e875c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Gabriel Soza	6345487	\N	\N	\N	t	2026-05-11 16:06:26.594	\N
860285e5-dacc-4755-8c51-a572c5acce68	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEXANDER ROMA	12444663	\N	\N	\N	t	2026-05-11 15:04:29.124	uploads/partners/1778541332811.jpg
673f225d-16a4-4da3-add9-faad039822e1	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALESSANDRO	12698060	\N	\N	\N	t	2026-05-08 21:24:58.05	uploads/partners/1778525953157.jpg
7cef75cf-7a5b-4409-ba5a-21b7fe20f390	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ABRAHAM PERALTA	2824079	\N	\N	\N	t	2026-05-08 20:46:30.396	uploads/partners/1778532120369.jpg
c693773e-60f2-4f62-820d-af9806295a4c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALAN GARCIA	8934566	\N	\N	\N	t	2026-05-08 21:15:00.737	uploads/partners/1778544079958.jpg
e88ca8d5-16cf-4501-99af-6501f49ff7a8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Alicey paniagua	7467461	\N	\N	\N	t	2026-05-11 16:04:20.698	uploads/partners/1778583297885.jpg
17c4abf8-339c-4a77-a5e1-3b66e045bd7c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEXANDER GUTIERREZ	7844671	\N	\N	\N	t	2026-05-08 21:26:14.884	uploads/partners/1778591395350.jpg
9d38d042-2c21-47ba-a498-6485e131b736	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ABIGAIL AVALOS	9585963	\N	\N	\N	t	2026-05-08 20:41:49.559	uploads/partners/1778515820476.jpg
a2aa3f8c-d134-48a9-ae05-6bab8b5880b8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Dayana Ypamo	14135515	\N	\N	\N	t	2026-05-11 16:08:24.198	uploads/partners/1778515958128.jpg
e622b29d-67f1-47f9-b22c-9278e39d7241	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ARACELY WENDY	4612298	\N	\N	\N	t	2026-05-11 23:04:41.718	\N
d02259bf-0b2d-4a79-bd29-1d892299585a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Cristian Ortiz	12663602	\N	\N	\N	t	2026-05-11 17:55:50.707	uploads/partners/1778522224485.jpg
f74330b4-36a0-47a9-b192-d7bee532f0d5	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JUAN MANUEL	9821699	63554947	\N	\N	t	2026-05-11 18:31:18.307	uploads/partners/1778524278800.jpg
b33f540c-7e61-486b-8e0e-1069b9b388b3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE SANDOVAL	13543905	\N	\N	\N	t	2026-05-11 18:46:05.956	uploads/partners/1778525166497.jpg
0544929b-30f1-4d09-9756-881ff559e881	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MILENKA PEDRAZA	8981519	\N	\N	\N	t	2026-05-11 18:54:04.384	uploads/partners/1778525645088.jpg
9bec239a-8ddf-4cfb-ad5b-1754bd77f92e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALICIA SORIA	7750491	\N	\N	\N	t	2026-05-11 17:06:39.814	uploads/partners/1778529364872.jpg
a0b074a7-4876-44f6-8246-2c7ce9c06e18	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALBERTO ALUB	13618486	\N	\N	\N	t	2026-05-11 20:43:25.035	uploads/partners/1778532205647.jpg
395d7599-523a-4a6d-9b8d-f5023873ef25	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JORGE RUIZ	7477417	\N	\N	\N	t	2026-05-11 21:26:17.651	uploads/partners/1778534778216.jpg
3b4fdc49-f12c-4945-8797-69a0336d4beb	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RICARDO BAZAN	14283728	\N	\N	\N	t	2026-05-11 22:10:30.855	uploads/partners/1778537431312.jpg
1c82b0ed-7597-402e-9b5f-abfcc3a2cc48	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BRANDON DORADO	12887313	\N	\N	\N	t	2026-05-11 22:12:04.296	uploads/partners/1778537524759.jpg
de09cfdb-ea36-47be-ba0f-e121fbfa49a6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALEXANDER LOPEZ	94012929860	\N	\N	\N	t	2026-05-08 00:36:09.93	uploads/partners/1778537850540.jpg
2ef332b0-b371-4564-997d-96f1212cded6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SANTIAGO GARNICA	11335774	\N	\N	\N	t	2026-05-11 22:23:11.377	uploads/partners/1778538191871.jpg
053c65a6-8814-4d31-a97e-59472a996abe	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOAQUIN GARNICA	7713175	\N	\N	\N	t	2026-05-11 22:24:51.545	uploads/partners/1778538292035.jpg
60c3a803-bf7b-4f6c-8600-08c957cd1793	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KENDRA PEREIRA	7675343	\N	\N	\N	t	2026-05-11 22:39:21.751	uploads/partners/1778539162254.jpg
93ddf524-4617-4d45-b378-17df5ce50980	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	OSCAR CARDONA	77381767	\N	\N	\N	t	2026-05-11 22:47:18.971	uploads/partners/1778539639561.jpg
573740dc-40e6-4155-827c-3b98ecc06c01	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	INGRIS ROSSEL	6440443	\N	\N	\N	t	2026-05-11 22:48:34.487	uploads/partners/1778539715491.jpg
8da439a1-ac7b-4451-8db2-28c0b21e888d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANGELICA REZO	8074614	\N	\N	\N	t	2026-05-11 22:59:31.756	\N
e6b04300-5976-439f-ab5b-84cd4135d36d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ARIANNE DREW	8069446	\N	\N	\N	t	2026-05-11 23:07:55.959	\N
7a1cad64-053e-4635-9fd9-f75615de6d1e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ARIEL	8188219	\N	\N	\N	t	2026-05-11 23:09:15.349	\N
af2c4ffd-5299-41b7-9250-672184d7b730	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ARIANA AÑEZ	9356059	\N	\N	\N	t	2026-05-11 23:06:53.896	uploads/partners/1778542525089.jpg
dc32d4c5-5afc-4af0-8783-960223918223	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANA NOGALES	9052168	\N	\N	\N	t	2026-05-11 22:52:58.531	uploads/partners/1778541000935.jpg
3763abee-1b74-47e0-9f72-203bf58d976d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANA GABRIELA SOLIZ	10712547	\N	\N	\N	t	2026-05-11 23:18:10.513	\N
59d0f632-36d6-4fcd-b38b-4f39b456b5ba	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BEATRIZ SOLIZ	7831938	\N	\N	\N	t	2026-05-11 23:20:09.112	\N
19cbef6f-740f-4538-b415-d2022ba8b045	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SAMANTA	9734186	\N	\N	\N	t	2026-05-11 23:25:15.798	uploads/partners/1778541916337.jpg
eacedabb-27b6-459f-a242-10e96f7eea0d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BELLA	12728522	\N	\N	\N	t	2026-05-11 23:27:28.199	\N
e3a60882-6f03-4885-8e7a-e633ff91c54b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BELTRAN	13545471	\N	\N	\N	t	2026-05-11 23:28:44.771	\N
eacad3c1-2395-41ef-9633-32c9163fc689	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GABRIELA CASTEDO	9633237	\N	\N	\N	t	2026-05-11 23:31:22.471	uploads/partners/1778542282972.jpg
9213415e-a653-4348-832a-bf9810200933	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KARLA MERIDA	5419095	\N	\N	\N	t	2026-05-11 23:37:54.829	uploads/partners/1778542675302.jpg
476f493e-162a-4d08-bbdd-939833a866d6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	REINER MORENO	7224810	\N	\N	\N	t	2026-05-11 23:44:01.319	uploads/partners/1778543041814.jpg
a1522040-1855-4193-ac97-9f965f584f11	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KARINA FERREL	14455503	\N	\N	\N	t	2026-05-11 23:59:40.038	uploads/partners/1778543980594.jpg
f5aa5643-fd47-4b8f-b4d7-57a6b988f7af	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANDRES CALLE	5061915	\N	\N	\N	t	2026-05-11 22:56:20.807	uploads/partners/1778545076846.jpg
ddfb4049-f4bc-4534-bd54-a9f9764b6cb8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BORIS BELTRAN	9990767	\N	\N	\N	t	2026-05-12 00:51:13.997	\N
1f933426-9a3a-4ea1-9fe3-517c7e6708cf	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BELIZAIDA	8867353	\N	\N	\N	t	2026-05-11 23:21:16.676	uploads/partners/1778587063950.jpg
0d168b57-fe6f-433d-82db-2a0fcc1ee953	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	AURELIO CAMPOS	4626954	\N	\N	\N	t	2026-05-11 23:16:32.159	uploads/partners/1778613536122.jpg
b5e69f4c-51bd-410a-9b57-44092888994b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANDREA LOPEZ	3830318	\N	\N	\N	t	2026-05-11 22:54:22.752	uploads/partners/1778616035334.jpg
1eeaa250-9d9d-45ae-86d6-295537c409ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANIBAL	9604097	\N	\N	\N	t	2026-05-11 23:00:39.16	uploads/partners/1778620192180.jpg
bb057365-37cd-4fad-8943-037032987734	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANDRIU MEJIA	13633513	\N	\N	\N	t	2026-05-11 22:57:34.828	uploads/partners/1778620758134.jpg
228e67db-3041-48eb-9a81-b759bd96c248	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALFREDO PINTO	14083258	\N	\N	\N	t	2026-05-11 16:32:48.455	uploads/partners/1778624489483.jpg
14ca7ddc-150c-4dda-8895-3d881ffc5267	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ANTONY TORREZ	8197185	\N	\N	\N	t	2026-05-11 23:01:47.552	uploads/partners/1778689960742.jpg
f848e6ae-09d8-461a-83bc-9c82e5c9167d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BRAYAN	9678221	\N	\N	\N	t	2026-05-12 00:52:49.918	uploads/partners/1778629535679.jpg
cdaf029c-3182-4ca9-b85b-fef51a732baf	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BENJAMIN BUITRAGO	5796627	\N	\N	\N	t	2026-05-12 00:46:57.336	uploads/partners/1778691704192.jpg
d23325f7-6aa2-4072-ba45-3a7885dbb7a9	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BRAYAN  RIVERA	11340683	\N	\N	\N	t	2026-05-12 00:53:57.261	\N
a86881ed-f927-4b62-9a38-8056f58d80e9	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BRAYAN PANIAGUA	8987230	\N	\N	\N	t	2026-05-12 00:55:23.54	\N
67ce18ed-76bc-47d9-86e9-cb7cbdd692bb	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BRENDA CHOQUE	16779076	\N	\N	\N	t	2026-05-12 00:56:29.375	\N
f1c7c07c-2b71-4cae-93b0-0fb09044c46a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BRUNO ROJAS	8912667	\N	\N	\N	t	2026-05-12 00:58:23.965	\N
a3a1bbab-a2dc-40da-aa6a-97146c5fee2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	BERNARDO URIOSTE	4731780	\N	\N	\N	t	2026-05-12 00:48:34.809	uploads/partners/1778547932525.jpg
2d6028b4-ee06-4004-9fa7-fcaf5f32c2df	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLA BAUTISTA	9189591	\N	\N	\N	t	2026-05-12 01:12:31.988	\N
a60aa232-435c-4484-a25c-06cfe020f370	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLOS CAMACHO	12383909	\N	\N	\N	t	2026-05-12 01:25:46.046	\N
f6c321cf-011b-4e88-8ed0-ce56b5851cdb	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLOS CHAVEZ	6332279	\N	\N	\N	t	2026-05-12 01:26:47.481	\N
229949be-6630-4b99-912a-97ba6e140a2f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLOS EDUARDO	11400444	\N	\N	\N	t	2026-05-12 01:28:00.837	\N
e08a297f-e9ff-4967-b725-88b68f786e92	6b828940-7fc0-449f-8a26-f91d237a0940	CUSTOMER	Sergio Olmos	3910133	\N	\N	\N	t	2026-05-12 05:04:28.202	uploads/partners/1778562268598.jpg
e803ed62-468c-44d4-bd33-1cee42348781	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CAROLINA HERRERA	75612385	\N	\N	\N	t	2026-05-12 10:47:48.996	\N
c65add80-0d84-459f-9361-f3346c7b3334	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Carolina herrera	6315173	\N	\N	\N	t	2026-05-12 10:50:20.302	\N
fb6c9d8f-9441-484a-b6de-451233679e4d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CIELO CRESPO	13894657	\N	\N	\N	t	2026-05-12 11:14:04.501	\N
2a158cc9-5fb6-45e3-822b-3c29985cb265	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CINTHIA COLQUE	8510221	\N	\N	\N	t	2026-05-12 11:19:14.94	\N
f97f2614-1a25-4055-af4b-bd661030983f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ALVARO PEÑARANDA	9786729	\N	\N	\N	t	2026-05-11 22:51:32.636	uploads/partners/1778584997490.jpg
40cdeee4-0cad-403f-b046-55a5a6a2351c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CLAUDIO CUELLAR	6315208	\N	\N	\N	t	2026-05-12 11:36:01.403	\N
1b1d5ee8-7c16-41fc-8ba9-1f3fe85fa749	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTIAN PAYE	13431209	\N	\N	\N	t	2026-05-12 11:49:06.061	\N
7cb7265c-514f-40b2-8e1c-d08624a5b885	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTINA URIAS	12661865	\N	\N	\N	t	2026-05-12 11:55:35.823	\N
c161507d-3d1e-4449-bf67-067f757c9185	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTINA VARGAS	6169041	\N	\N	\N	t	2026-05-12 11:59:57.655	\N
36848429-b86f-41f0-9563-4c5adce1129f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTIAN SUBIRANA	8079407	\N	\N	\N	t	2026-05-12 11:50:35.774	uploads/partners/1778590097545.jpg
bc76b1e0-f9b4-4bc8-9ace-5fc3b528bacf	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Carmiña Pedraza	3281751	\N	\N	\N	t	2026-05-12 12:08:41.806	\N
42d89532-31d5-423a-9007-f83b454116bc	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	kAREN GALVEZ	8955290	\N	\N	\N	t	2026-05-12 12:39:50.14	uploads/partners/1778589744669.jpg
144621a4-ad27-4aac-a4eb-c2171985be60	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAVID SUAREZ	14595786	\N	\N	\N	t	2026-05-12 13:07:16.787	\N
a60c8569-154e-4ae1-8ab0-1a7d56bded2f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAVID ZEBALLOS	75392509	\N	\N	\N	t	2026-05-12 13:16:06.582	\N
35e3dd85-4922-4d4d-8722-70cdac572efc	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DEYVY	8125561	\N	\N	\N	t	2026-05-12 14:09:02.637	\N
1e07bf11-03d8-4059-aac5-80d5c86cc41a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTINA ROCA	14271099	\N	\N	\N	t	2026-05-12 11:53:10.462	uploads/partners/1778604131824.jpg
ae2e561a-e9f5-40ce-bd69-ca9201bb8e74	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CESAR ARGANDOÑA	4715489	\N	\N	\N	t	2026-05-12 11:01:53.993	uploads/partners/1778601931687.jpg
dbe35b9c-74f6-4367-bc0c-e7fc2ca93d2e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLOS URQUIZA	13701681	\N	\N	\N	t	2026-05-12 10:42:18.457	uploads/partners/1778611823394.jpg
362f0976-10f2-4896-bf47-e235e3717892	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAVID NAJAYA	10804449	\N	\N	\N	t	2026-05-12 13:05:02.161	uploads/partners/1778612473739.jpg
cfc79a88-47f4-4abd-9672-aa15994283c2	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CLAUDIA PEDRAZA	4706435	\N	\N	\N	t	2026-05-12 11:33:54.225	uploads/partners/1778617819865.jpg
a5c2d6a4-2740-4ae5-91a8-a3287620c7af	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAVID VASQUEZ	7699672	\N	\N	\N	t	2026-05-12 13:14:18.582	uploads/partners/1778617891706.jpg
9bbc1ece-99fa-4616-9161-c83db51aa25b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAVID VACA	6359740	\N	\N	\N	t	2026-05-12 13:12:11.275	uploads/partners/1778618506302.jpg
fbd8d867-0df5-494d-b277-742b3c39f86e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DECKER	13335388	\N	\N	\N	t	2026-05-12 13:43:33.37	uploads/partners/1778619455155.jpg
8d558a91-928d-48b5-81d5-0c16dcf8bd23	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTIAN	9800626	\N	\N	\N	t	2026-05-12 11:37:56.205	uploads/partners/1778620942231.jpg
8182fce0-79cf-4297-b088-eab44cfabaa7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLOS PONCE	15013626	\N	\N	\N	t	2026-05-12 10:22:30.848	uploads/partners/1778621300634.jpg
32794fba-4901-47d7-a3d9-3282c5a6ff37	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DIEGO BARBA	6204946	\N	\N	\N	t	2026-05-12 14:10:44.07	uploads/partners/1778621968179.jpg
9594524b-f9d7-4866-a709-1b5b72561c43	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAYANA ROMERO	12533429	\N	\N	\N	t	2026-05-12 13:41:26.14	uploads/partners/1778622507953.jpg
050cf9da-0342-4d7f-9c90-7bdd84ff86cd	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DANIEL GUZMAN	12758448	\N	\N	\N	t	2026-05-12 12:29:27.68	uploads/partners/1778624038471.jpg
5116038b-94be-4b71-8ff3-b03ab527f2f3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLOS ROJAS	5545898	\N	\N	\N	t	2026-05-12 10:25:38.621	uploads/partners/1778624292376.jpg
cb6fe7ed-48ce-496d-a3c0-dc3df9ec5ffd	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTIAN BESERRA	11335708	\N	\N	\N	t	2026-05-12 11:43:45.231	uploads/partners/1778625633709.jpg
f75051f4-22b0-4de2-ac4d-cba8b447b15b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAVID FLORES	8194917	\N	\N	\N	t	2026-05-12 13:02:19.537	uploads/partners/1778632191182.jpg
3695737b-64a7-47b0-86f9-58d865a70bf3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CRISTIAN CUELLAR	7694926	\N	\N	\N	t	2026-05-12 11:47:09.564	uploads/partners/1778634198701.jpg
503e2c59-9329-4312-86e6-88063247b133	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CINTHIA MENDOZA	10391254	\N	\N	\N	t	2026-05-12 11:28:41.944	uploads/partners/1778669360527.jpg
590a677e-2ca7-4c5c-a626-5f820e968a02	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CLAUDIA CORDOVA	9759975	\N	\N	\N	t	2026-05-12 11:31:43.973	uploads/partners/1778670838957.jpg
f1d6d27a-a3f1-44b5-bdce-1d7f6d531ad4	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CHRIS CERVANTES	10670671	\N	\N	\N	t	2026-05-12 11:11:26.582	uploads/partners/1778683217637.jpg
e36c05fa-507a-4680-9962-ead22b0f4816	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DIEGO PINTO	5392427	\N	\N	\N	t	2026-05-12 14:15:19.755	\N
a4f0b4d8-868c-4bd9-95f8-79df22d8a3dd	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DORIAN MONROY	78484098	\N	\N	\N	t	2026-05-12 14:21:52.816	\N
33f9f76f-ef12-4217-85d8-4b96ad28cd61	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DANIEL VINICIUS	8248050	\N	\N	\N	t	2026-05-12 12:33:01.298	uploads/partners/1778596867913.jpg
de8e805e-fc19-4a09-883a-df10f1358f2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	EDGAR VEGA	9750126	\N	\N	\N	t	2026-05-12 14:48:17.215	\N
26d4d207-b9b5-4221-b2f3-9628c2724a6c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CAROLINA RIQUELME	60877347	\N	\N	\N	t	2026-05-12 11:08:33.097	uploads/partners/1778597484477.jpg
9d0d0b90-8ae5-40d7-9e54-cb8dd58d0480	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ELVIS SOTO	8231555	\N	\N	\N	t	2026-05-12 15:43:59.486	\N
019acc34-bae2-424a-962c-736770ee1dfc	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	EMILIO ARTEAGA	6375529	\N	\N	\N	t	2026-05-12 15:52:05.907	\N
75ffd53b-517d-4bbf-a001-754966d7d898	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ERVIN MENDEZ	13672033	\N	\N	\N	t	2026-05-12 16:23:07.086	\N
693b1571-7006-4f15-8c09-5120324d2b50	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	EULALIA	6691567	\N	\N	\N	t	2026-05-12 16:27:46.769	\N
9308d4b2-526f-4489-8607-13f73f6ee946	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	FERNANDO JOSUE	8160577	\N	\N	\N	t	2026-05-12 16:35:45.743	\N
5faf569a-c8ee-4eb2-8a1d-5a77fefeb9ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	FRANCISCO SANDOVAL	5850745	\N	\N	\N	t	2026-05-12 16:40:12.546	\N
502cc3dd-a709-4f48-9e65-65b25abc8aa8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DILAN MARTINEZ	5493746	\N	\N	\N	t	2026-05-12 14:19:16.871	uploads/partners/1778604358328.jpg
4921baba-2d23-418f-a2a8-09d4bd9ac241	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GABRIELA ROCABADO	6234315	\N	\N	\N	t	2026-05-12 16:48:46.439	\N
bb02909a-548b-443e-8954-8573a03c3da3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RENATO DANIEL	13546272	\N	\N	\N	t	2026-05-12 18:54:38.472	uploads/partners/1778612078923.jpg
070082d8-f645-4135-8d7f-a4b56dcd49f3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	FERNANDO EGUEZ	3249540	\N	\N	\N	t	2026-05-12 16:32:30.896	uploads/partners/1778604691782.jpg
38a2c285-26a6-49d2-93c9-de60c1d25f8f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GLORIA PARADA	4588113	\N	\N	\N	t	2026-05-12 17:03:59.926	\N
cc824b02-2f60-4e92-ba62-0ec3198b9b7b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GRACIELA QUIROGA	7688423	\N	\N	\N	t	2026-05-12 17:05:31.368	\N
19db719c-1051-4924-aec8-8fe3216b7c69	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GUSTAVO VELASQUEZ	741058	\N	\N	\N	t	2026-05-12 17:08:40.775	\N
31e9e927-66af-4800-a55d-5d979af9614a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	HECTOR VILLARROEL	7772447	\N	\N	\N	t	2026-05-12 17:46:28.816	\N
2d125526-281c-4172-a595-38ecae59bb50	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	HERLAN HURTADO	3166458	\N	\N	\N	t	2026-05-12 17:51:46.854	\N
ef2297bc-5bb2-4f6e-9dca-d9abc1af22a3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GUISELA AYALA	7663165	\N	\N	\N	t	2026-05-12 17:38:31.838	uploads/partners/1778608466636.jpg
f1810818-cd91-40f0-bfd9-9649693e526d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	HORACIO	7225142	\N	\N	\N	t	2026-05-12 17:59:15.889	\N
4e278f5e-dd46-4319-8703-13be851ea70b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	IBER SOLIZ	8888986	\N	\N	\N	t	2026-05-12 18:00:33.268	\N
14c13de2-ebbd-405f-a3d6-3c400ad6f66f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GUSTAVO MURGUIA	5241260	\N	\N	\N	t	2026-05-12 17:45:03.899	uploads/partners/1778610480026.jpg
5b3d0c68-6cf8-4656-9464-78e30b791b3b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GALILEA	9752858	\N	\N	\N	t	2026-05-12 16:53:18.545	uploads/partners/1778611242881.jpg
4cce917b-f231-48d0-ada5-5fed6e41c148	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	EDGAR CUELLAR	8983659	\N	\N	\N	t	2026-05-12 14:27:07.753	uploads/partners/1778612566849.jpg
74422af8-42f6-45da-a515-3d6f4251fdb7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ISRAEL ALBINO	9120075	\N	\N	\N	t	2026-05-12 19:05:07.579	\N
f5545853-41a1-46e2-a7ca-70a3c7714f1b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JACKELIN	8935719	\N	\N	\N	t	2026-05-12 19:06:35.567	\N
b169a84a-1256-4ae8-bc9f-308629274744	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JAIRO	12599493	\N	\N	\N	t	2026-05-12 19:08:25.307	\N
33b29244-f779-42e2-9721-71e39a4ad98d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CARLOS HURTADO	69149343	\N	\N	\N	t	2026-05-12 10:18:47.463	uploads/partners/1778614916428.jpg
b81a3908-21e5-472a-a121-ddb763d21638	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LAURA PEREZ	5896769	\N	\N	\N	t	2026-05-12 20:08:27.582	uploads/partners/1778616508071.jpg
90068245-1458-4fce-96f7-e7547a9bbb02	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	IGNACIO MENDIETA	12726979	\N	\N	\N	t	2026-05-12 18:58:24.117	uploads/partners/1778618192989.jpg
ca2be13a-9176-4b43-8314-40eaed72027e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JENNIFER ALVAREZ	9784281	\N	\N	\N	t	2026-05-12 21:01:50.91	\N
6da1b4bc-9d7b-4e8a-9705-6db15a76787b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GERALDINE	60932601	\N	\N	\N	t	2026-05-12 16:56:21.821	uploads/partners/1778621199679.jpg
b135bed0-a17e-4242-986f-edb3304896fb	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	FLOWER	9763739	\N	\N	\N	t	2026-05-12 16:37:18.749	uploads/partners/1778621851296.jpg
906b4106-180d-4f75-8247-af6db3955a39	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GERARDO RIVERA	7191047	\N	\N	\N	t	2026-05-12 17:01:31.952	uploads/partners/1778626422281.jpg
b269dee8-ffb7-483b-93fc-3a466072cb8d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ISAAC	14472111	\N	\N	\N	t	2026-05-12 19:00:04.949	uploads/partners/1778626492247.jpg
3fefeb34-8abe-4ecb-9508-03bb2395346f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JAVIER LAFUENTE	13702249	\N	\N	\N	t	2026-05-12 20:59:09.815	uploads/partners/1778627871578.jpg
332a5de3-c604-4082-ba3a-f6b2b95b13b3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	FERNANDO DORADO	9666002	\N	\N	\N	t	2026-05-12 16:30:55.543	uploads/partners/1778633348494.jpg
f0517e12-07ae-4354-968e-6ce837a59958	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DIEGO RODRIGUEZ	13675446	\N	\N	\N	t	2026-05-12 14:16:49.876	uploads/partners/1778630335344.jpg
7a70fb89-7a83-4816-baae-b60466f90c2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ELIANA SANDOVAL	3937329	\N	\N	\N	t	2026-05-12 14:54:24.862	uploads/partners/1778635113964.jpg
3bb68dd2-5395-42c3-9605-3ed9c8cdc6d9	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	HENRY YANARICO	6002656	\N	\N	\N	t	2026-05-12 17:48:23.25	uploads/partners/1778634458846.jpg
2bd57e4f-56de-4d35-b7df-6b9a5168de6c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	EMMA DURANTON	3214224	\N	\N	\N	t	2026-05-12 15:54:02.198	uploads/partners/1778670064553.jpg
baac22f8-b5cf-424d-a275-7921088e18d0	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JAQUELINE ARZA	3166688	\N	\N	\N	t	2026-05-12 19:09:21.96	uploads/partners/1778674100071.jpg
9915570f-c0ba-467c-98c4-1b1d2e4af87a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GARY CUELLAR	4707651	\N	\N	\N	t	2026-05-12 16:54:56.028	uploads/partners/1778685214490.jpg
2b87e871-aade-4f8d-a6be-726da730ef6b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JHONNY SEVERICHE	3911797	\N	\N	\N	t	2026-05-12 21:07:21.476	\N
b32d71f7-2d8f-4923-a2b4-604f640aca69	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JILIAN ROCHA	14088261	\N	\N	\N	t	2026-05-12 21:08:51.746	\N
505eb8af-b8be-4b0f-8074-9bcddc422b2b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOEL DAVID	12635250	\N	\N	\N	t	2026-05-12 21:10:55.482	\N
49d4bf67-6569-4e44-bf96-b80f210fda92	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOEL PRADO	8153245	\N	\N	\N	t	2026-05-12 21:12:09.704	\N
bcdfe6c0-f61a-4831-88f3-f284058d8ce6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOEL VILELA	7879881	\N	\N	\N	t	2026-05-12 21:13:29.736	\N
37a69c00-8984-45eb-b0f5-fac4464c485e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ARTURO BURGOS	75032442	\N	\N	\N	t	2026-05-11 23:13:12.025	uploads/partners/1778620586134.jpg
46b3376a-973a-454b-9347-52808613a768	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DANNERSON	8912932	\N	\N	\N	t	2026-05-12 13:00:33.038	uploads/partners/1778620645685.jpg
cecd7a56-d246-49de-a3ce-4a051757ef8e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GUSTAVO BERNAL	13338611	\N	\N	\N	t	2026-05-12 17:40:11.802	uploads/partners/1778620690651.jpg
beea360c-2426-45c5-ad86-8d97db9ee8e3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JORGE FERNANDEZ	6318264	\N	\N	\N	t	2026-05-12 21:21:20.225	\N
379fc5f6-7b00-4ef1-a411-653cc3f32eec	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JORGE GONZALES	77835125	\N	\N	\N	t	2026-05-12 21:24:21.914	\N
d6ccad63-d87c-4ed1-9c65-e54fd66bb3e6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JORGE MARTINEZ	5419473	\N	\N	\N	t	2026-05-12 21:25:40.529	\N
22d2c6ac-46bd-4361-80d7-284c5b1caf12	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JORGE RODRIGUEZ	16506013	\N	\N	\N	t	2026-05-12 21:27:33.476	\N
2c473852-96e3-4f0e-9448-e4b290899f36	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JORGE ZEBALLOS	71002284	\N	\N	\N	t	2026-05-12 21:29:46.003	\N
eac9fb5f-186e-4f90-9e2c-fece5ed96835	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE CARLOS CAMACHO	4197828	\N	\N	\N	t	2026-05-12 21:31:55.936	\N
54f921fb-0c0c-4cc1-b6e8-f60d54403705	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE DAVID CAMPOS	5880430	\N	\N	\N	t	2026-05-12 21:34:01.754	\N
cf1d4f92-80ff-4993-8bdd-71ace8489f2a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE EDUARDO ROCA	4613728	\N	\N	\N	t	2026-05-12 21:36:19.477	\N
c25e7f8e-c698-41c0-9a66-76f2bc76f445	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE FERNANDEZ	10133355	\N	\N	\N	t	2026-05-12 21:38:29.437	\N
d4d3380f-768c-4bab-86ac-c0779227db6f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	HERMAN CABALLERO	7715223	\N	\N	\N	t	2026-05-12 17:57:39.182	uploads/partners/1778622088053.jpg
8f52ede8-a0ca-4924-9587-69a8ee6c21c7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DIEGO COPANA	9848535	\N	\N	\N	t	2026-05-12 14:12:42.268	uploads/partners/1778622160868.jpg
f9d58793-cd3e-4920-8118-7b5adf42c467	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE IGNACIO	11381879	\N	\N	\N	t	2026-05-12 21:46:39.223	\N
37cf83a2-fc07-48a3-a239-9decbb397fc2	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSUE GOITA	13428872	\N	\N	\N	t	2026-05-12 21:58:56.692	uploads/partners/1778623626418.jpg
d87b5051-a000-447b-bd0b-721aabc3d207	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE FRANCISCO	13930388	\N	\N	\N	t	2026-05-12 21:45:04.446	uploads/partners/1778622562328.jpg
6b502b54-1620-4ac2-91d8-9aebf17bce83	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE LUIS VILLAVICIENCIO	9783745	\N	\N	\N	t	2026-05-12 21:52:26.532	\N
67b9ada8-e7e2-4bf9-83c1-7b23812d77fc	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE MANUEL	13538429	\N	\N	\N	t	2026-05-12 21:54:43.436	\N
9be71f64-715b-4309-a173-09080275a11c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE MARIA ZENTENO	12598652	\N	\N	\N	t	2026-05-12 21:55:47.583	\N
841485d8-9d42-4798-abb8-bf2ee07bbfcc	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE SANDOVAL	64461648	\N	\N	\N	t	2026-05-12 21:57:52.34	\N
4179fe20-cdc2-4058-9a98-0fcb9f6f871b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSUE RIBERA	13307375	\N	\N	\N	t	2026-05-12 21:59:59.986	\N
3e1075af-dbda-4157-95a1-64e356170021	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JUAN PARDO	2842312	\N	\N	\N	t	2026-05-12 22:02:59.985	\N
797ad34d-0c09-4b19-b41f-f85d9b7b2734	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE DIAZ	0069863	\N	\N	\N	t	2026-05-12 21:35:13.948	uploads/partners/1778623474306.jpg
2c0aa1d4-f3f7-44e2-8516-a724e2990d3b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JULIO CESAR RODRIGUEZ	4792244	\N	\N	\N	t	2026-05-12 22:11:17.913	\N
e39a48bf-3739-40b2-aecb-166da5fbbe56	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	DAYANA JUSTINIANO	13305301	\N	\N	\N	t	2026-05-12 13:18:46.663	uploads/partners/1778624447570.jpg
d71a7af2-a465-4e4b-8b32-b30ac472da3b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE CARLOS FRANCO	11382646	\N	\N	\N	t	2026-05-12 21:33:00.012	uploads/partners/1778624999099.jpg
03222926-4b5b-4f24-90ec-275aef476bd6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JULIO EDUARDO	7404876	\N	\N	\N	t	2026-05-12 22:43:22.909	\N
d897fa6f-52cd-4f6b-aa0f-0e0d9086123d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KATHIA ROMERO	4721492	\N	\N	\N	t	2026-05-12 23:15:56.838	\N
6dc66c97-7553-4a32-9a45-5a2af414128e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE MANUEL	8248527	\N	\N	\N	t	2026-05-12 21:53:21.859	uploads/partners/1778626468572.jpg
b89d7a62-ead2-4730-a8d5-bceacaeab00a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KAMELLY	9608195	\N	\N	\N	t	2026-05-12 22:44:49.832	uploads/partners/1778626517618.jpg
8ef6aab4-36e5-4e7a-92aa-f195b92e8384	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KENJI EVER GUTIERREZ	6346688	\N	\N	\N	t	2026-05-12 23:20:58.649	\N
c1d47b2a-2f9a-486e-8750-afa7479dcf9b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KEVIN RUIZ	6303821	\N	\N	\N	t	2026-05-12 23:28:15.774	\N
d8f28584-b77e-47ea-a759-360927038451	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JULIAN ARANDIA	13470839	\N	\N	\N	t	2026-05-12 22:05:20.186	uploads/partners/1778629791448.jpg
c9a59bb0-22f9-4163-b915-e3db808c43da	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE REINALDO	5616512	\N	\N	\N	t	2026-05-12 21:56:38.163	uploads/partners/1778632629189.jpg
b4b33973-4a5e-4ee7-8cc5-f58b2955a51a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KEVIN MATHY	8129616	\N	\N	\N	t	2026-05-12 23:26:28.36	uploads/partners/1778633178007.jpg
a13eb0da-fca8-4fdd-b069-d9ee31d84c81	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JULIO CESAR AVILA	3830445	\N	\N	\N	t	2026-05-12 22:08:58.559	uploads/partners/1778669954058.jpg
87bdd0ce-dffe-4452-b101-1d9da394055e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE ARMANDO	12451724	\N	\N	\N	t	2026-05-12 21:30:52.167	uploads/partners/1778671253842.jpg
ef8719ef-4f37-40e2-bc60-906284743842	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	KAREN VILLARROEL	5425521	\N	\N	\N	t	2026-05-12 22:47:30.522	uploads/partners/1778673346824.jpg
f49f8b5e-b72d-4b45-a8a1-7216d1012065	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE LUIS HEREDIA	7671611	\N	\N	\N	t	2026-05-12 21:51:26.693	uploads/partners/1778675311416.jpg
78536aa7-702e-4c71-be4d-60338c11a054	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JUAN FLORES	7378582	\N	\N	\N	t	2026-05-12 22:01:22.052	uploads/partners/1778675388585.jpg
9ccea574-c459-44a0-8558-d1d49048d9d4	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LAURA VALERIANO	12918273	\N	\N	\N	t	2026-05-12 23:31:07.44	\N
2a2eda73-fac0-40c1-adc6-3c04e4ce6514	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LEANDRO RODRIGUEZ	6229753	\N	\N	\N	t	2026-05-12 23:32:18.252	\N
a3befa2b-236e-47a7-9707-99f3f4990cc1	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LIA PINTO	9583108	\N	\N	\N	t	2026-05-12 23:34:49.891	\N
55eb10c9-a707-479f-bbc9-c8e19760dcf3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	GUSTAVO CHUGUIÑA	8230672	\N	\N	\N	t	2026-05-12 17:41:51.105	uploads/partners/1778628964244.jpg
1eeac0f0-9d77-4b64-a4fe-18fb5624b490	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LIDIA CANAVIRI	3756765	\N	\N	\N	t	2026-05-12 23:39:51.748	\N
82a7c55f-ff8c-4b42-9634-c972014044dd	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JHERSON SOLIZ	10229988	\N	\N	\N	t	2026-05-13 01:12:53.051	uploads/partners/1778634773507.jpg
14982bcc-b706-41bc-ad3d-3436b0a8e007	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	CAROL JIMENA ALFARO	4704994	\N	\N	\N	t	2026-05-12 10:45:20.698	uploads/partners/1778634996990.jpg
8bc3f30b-309c-42f7-9f52-046e95de6276	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JORGE BARBA	14455837	\N	\N	\N	t	2026-05-12 21:14:46.872	uploads/partners/1778629749946.jpg
f28ec386-5e47-49d3-a7b2-3c7f82eb99d0	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUCAS DIAZ	8126207	\N	\N	\N	t	2026-05-12 23:50:31.369	\N
fdd4d29f-3bd9-435a-a36d-572f60c87955	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUCIA MENESES	11402158	\N	\N	\N	t	2026-05-12 23:52:04.66	\N
ff67e061-11b0-463d-8b74-3933a04dca84	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUCIANA	77091627	\N	\N	\N	t	2026-05-12 23:55:46.822	\N
93318a74-e5ae-48f6-a025-6a7630befe98	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUIS ALBERTO	7720164	\N	\N	\N	t	2026-05-12 23:56:38.167	\N
25719a87-74b6-4346-b6ef-3565129b507a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MATEO SAAVEDRA	70858694	\N	\N	\N	t	2026-05-13 12:03:59.979	\N
40696459-c69c-477c-843e-a1e1ab4ab577	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LIDIA	7714578	\N	\N	\N	t	2026-05-12 23:38:39.967	uploads/partners/1778630476812.jpg
2ba743d2-858b-4e21-950e-ea4f87925874	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ARIEL OROPEZA	13865051	\N	\N	\N	t	2026-05-11 23:12:02.276	uploads/partners/1778630548892.jpg
0df96f01-7d7d-40b2-b83c-dffb32335f08	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MILENKA ALVAREZ	13431696	\N	\N	\N	t	2026-05-13 00:06:26.888	uploads/partners/1778630787384.jpg
5fe6f94e-3a05-4ce8-8a40-a4836cb14536	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ERICK CHOQUE	8248528	\N	\N	\N	t	2026-05-13 00:09:35.07	uploads/partners/1778630975528.jpg
a7381c69-fedf-41b9-904c-b27d92dd738c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUIS AYALA	9800896	\N	\N	\N	t	2026-05-13 00:14:19.319	\N
e3035eb7-c298-4c9c-a3b8-8b9c6eae36c8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUIS CARDOZO	8150312	\N	\N	\N	t	2026-05-13 00:15:29.956	\N
8d19ba4d-33cb-4b5a-9088-c22a5086b8a0	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUIS JUSTINIANO	6251384	\N	\N	\N	t	2026-05-13 00:16:44.939	\N
372cbe81-d2cc-42f7-a123-8f0abe4d4364	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUIS MENACHO	3267692	\N	\N	\N	t	2026-05-13 00:20:05.062	\N
e440e085-b757-49b4-b2c4-5032f05e0894	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUIS ROSAS	12565602	\N	\N	\N	t	2026-05-13 00:21:02.187	\N
cd0f5594-8495-4bc3-9178-fc0e8855c19d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JOSE FERNANDO JALDIN	6393944	\N	\N	\N	t	2026-05-12 21:43:55.545	uploads/partners/1778631778188.jpg
ba334f9c-4d8a-4c94-acd5-9823d0d60e1f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ISMAEL CARRILLO	13430411	\N	\N	\N	t	2026-05-12 19:03:59.547	uploads/partners/1778631824353.jpg
bce91afe-e91f-4890-80dc-2c4889144849	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ROBERTO CANDIA	14249874	\N	\N	\N	t	2026-05-13 00:34:14.729	uploads/partners/1778632455198.jpg
40d039f9-47db-4f41-ba69-5a5441b377c1	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SHANTY CUELLAR	7615183	\N	\N	\N	t	2026-05-13 00:35:15.321	uploads/partners/1778632515789.jpg
a37e6aeb-4b76-4538-bcba-e1febf1c5e43	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LUISSA HERRERA	12986026	\N	\N	\N	t	2026-05-13 00:44:36.573	\N
b6a72b15-3214-47ef-86a5-ece55f53fd51	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MAGDALENA SEGUNDO	77888418	\N	\N	\N	t	2026-05-13 00:54:24.788	\N
7bcd2dac-1caf-446a-bba4-0003811ecf54	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARCIA ELENA	12597269	\N	\N	\N	t	2026-05-13 00:56:26.251	\N
da9da632-114e-47ab-aa02-73575091fe50	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARCO MAMANI	6717715	\N	\N	\N	t	2026-05-13 00:57:23.793	\N
128eb675-3968-406a-9549-12f6e001c6d4	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARIA COIMBRA	13339389	\N	\N	\N	t	2026-05-13 00:59:14.346	\N
9342390a-5dfd-48c7-9e59-e41c71001ba6	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARIANA LEAÑOS	77391096	\N	\N	\N	t	2026-05-13 01:00:06.575	\N
e24f9d69-46b3-4680-a25d-3a2823822d1a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARIBEL DAVALOS	13697951	\N	\N	\N	t	2026-05-13 01:00:57.246	\N
80e6cdb2-9234-431c-a2e5-ef9ead2b6047	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARIELA MENDOZA	63316184	\N	\N	\N	t	2026-05-13 01:01:45.236	\N
d3185606-5ad8-4aca-ba11-758f0e6998f3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MATIAS MENDEZ	8982133	\N	\N	\N	t	2026-05-13 12:06:32.913	\N
5440c9e7-eef4-482f-acb4-cd742a255eeb	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARCELO MEJIA	4714820	\N	\N	\N	t	2026-05-13 00:55:24.873	uploads/partners/1778667485746.jpg
f460a0ff-b769-45ed-be64-cea480b52c05	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MAYITA	77049999	\N	\N	\N	t	2026-05-13 12:17:18.852	\N
1328b3bb-1baf-4201-8f7d-9621e1e98589	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARIA ANGELICA	11363886	\N	\N	\N	t	2026-05-13 00:58:27.991	uploads/partners/1778669167318.jpg
d3876ad7-c371-4bd9-9c51-460798e6b455	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MARYUVI	12986714	\N	\N	\N	t	2026-05-13 12:00:46.725	\N
560bcc29-da11-4c37-a2b1-a977943bde1b	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MATEO BANEGAS	9776736	\N	\N	\N	t	2026-05-13 12:02:10.945	\N
b53b1657-5bb9-48a1-8d4c-f65861028790	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MELISA FERNANDEZ	68847990	\N	\N	\N	t	2026-05-13 12:21:48.987	\N
c04cc4b4-b36a-42ae-8782-cae4187bf140	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LAURA CUELLAR	11341111	\N	\N	\N	t	2026-05-12 23:29:23.87	uploads/partners/1778675620647.jpg
6105b207-ea61-49ce-9592-1b9c9c5a34f1	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MIGUEL PAZ	12857359	\N	\N	\N	t	2026-05-13 12:34:52.009	\N
a35c2c66-4c33-41de-9337-610612e3aa01	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MIRLAN	7887101	\N	\N	\N	t	2026-05-13 12:37:51.021	\N
97d2dd8c-fee6-46d8-a6ca-d6aaddf3bab3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MOISES ALI	4172940	\N	\N	\N	t	2026-05-13 12:39:39.972	\N
02717d42-a2d8-4c53-bb74-e357a250c0e2	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MERY FLORES	2988096	\N	\N	\N	t	2026-05-13 12:23:53.667	uploads/partners/1778684915208.jpg
acc4cb5d-8a05-4951-a24f-12ceec630469	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MAURICIO  DELGADILLO	4681743	\N	\N	\N	t	2026-05-13 12:10:12.311	uploads/partners/1778687523063.jpg
4208e2b8-0c1c-4038-80f6-8116edd89f09	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MOISES VANI	7804366	\N	\N	\N	t	2026-05-13 12:41:05.395	\N
b28ac5e8-3b26-4095-b1e7-615114dbb89f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NATHALIA	12952695	\N	\N	\N	t	2026-05-13 12:57:43.697	\N
7028f55d-e95a-4604-9f3c-4ddb00e6ce6a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NATHALIA PEDRAZA	13339155	\N	\N	\N	t	2026-05-13 13:01:27.109	\N
f3826acb-1d1e-4b78-be81-49089d60bfa5	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	LEO ANTEZANA	6283745	\N	\N	\N	t	2026-05-12 23:33:36.012	uploads/partners/1778677361261.jpg
3edfda55-e29d-4bbd-8264-d96319e4c848	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NELSON COPA	14141442	\N	\N	\N	t	2026-05-13 13:04:31.213	\N
e6e24fd8-a58e-4ec8-a9a8-0e5de15e586d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NELSON GARCIA	5028556	\N	\N	\N	t	2026-05-13 13:06:19.938	\N
151e2cec-4b9f-4d7c-b435-16b040097bc8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NELSON ROJAS	11400311	\N	\N	\N	t	2026-05-13 13:07:44.654	\N
c56d4e2a-8930-4351-ae22-7009596945a3	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	Nicolas	13335873	\N	\N	\N	t	2026-05-13 13:42:11.248	\N
0a503a53-66ed-4782-8e4a-a283b45aab48	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NICOLAS GUIMBARD	95839781	\N	\N	\N	t	2026-05-13 13:48:05.54	\N
c4903655-5743-4f9b-b8e9-fe184dadf7b8	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NICOLE SOLETO	74619991	\N	\N	\N	t	2026-05-13 13:50:14.278	\N
25984e47-90b6-442a-a889-bd7bb49744f7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NINFA	10798467	\N	\N	\N	t	2026-05-13 13:56:03.087	\N
daf0cd54-c39f-4bc5-b641-fee276a92778	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	OSMAR MORENO	6385617	\N	\N	\N	t	2026-05-13 13:57:24.017	\N
1fda80ce-6bf0-4551-b364-1e5666696e2e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PABLO HERRERA	12986437	\N	\N	\N	t	2026-05-13 14:03:42.681	\N
75add031-eb78-4a5e-a681-c22f896e93dd	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PABLO SANDOVAL	6372459	\N	\N	\N	t	2026-05-13 14:06:34.905	\N
611de2b5-c1c8-443b-b1ce-f0a786a1cd82	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SEBASTIAN SALAZAR	11400413	\N	\N	\N	t	2026-05-13 16:44:41.472	\N
432c9309-25be-4937-a3bd-0fa681fc0f48	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	NICOLAS	12790957	\N	\N	\N	t	2026-05-13 13:38:12.621	uploads/partners/1778682575398.jpg
38bb5b7f-71c7-4913-9d37-881777be2797	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PAOLA GUAMAN	3456705	\N	\N	\N	t	2026-05-13 14:44:13.072	\N
caf160f2-6cfa-4d9c-9c8a-1674bd5a8918	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PAOLA PANOZO	7684496	\N	\N	\N	t	2026-05-13 14:45:42.958	\N
494d0d89-097d-48e3-b153-3fb22adccbd1	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PATRCIA CALLEJAS	7536365	\N	\N	\N	t	2026-05-13 14:47:05.929	\N
c8e56477-6d8d-4e23-bfca-59335a3c3197	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PATRICIA BUTRON	5867995	\N	\N	\N	t	2026-05-13 14:49:05.484	\N
7008574c-4ece-432a-b96c-ab1a811a8a98	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PAUL MONTENEGRO	3825747	\N	\N	\N	t	2026-05-13 14:58:26.294	\N
4612f9e3-113c-4aa2-afd6-4919a8355059	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	PÁBLO EDUARDO	6340931	\N	\N	\N	t	2026-05-13 15:01:17.091	\N
0d207e62-7aa9-460d-9886-8a7b0f838b6a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RAFAELA MASAI	73378831	\N	\N	\N	t	2026-05-13 15:06:23.424	\N
e32946cc-21ec-420a-9ca5-359a5f29b176	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RAMIRO GOMEZ	8999843	\N	\N	\N	t	2026-05-13 15:17:12.96	\N
84d549d6-b9ff-42c5-ac56-dc15aebf58ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RAMON MENDOZA	3191105	\N	\N	\N	t	2026-05-13 15:44:27.707	\N
9560c458-7aef-464d-b47c-f073f1d6f3ee	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RANDOL COPA	8014052	\N	\N	\N	t	2026-05-13 15:49:39.079	\N
92467230-fa62-430d-a8a3-5c12541a3d70	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RENY GIRONDA	3825514	\N	\N	\N	t	2026-05-13 15:56:52.453	\N
e362210c-2556-484b-8211-a29a41576a0c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ROBERTO HARRIAGUE	1134561	\N	\N	\N	t	2026-05-13 16:02:19.624	\N
5cb5bbf5-4215-4c96-a91d-3659c47d7004	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ROBERTO JUSTIANO	65848610	\N	\N	\N	t	2026-05-13 16:10:56.119	\N
dfe136b3-1d7d-464c-a2c2-608a20c05465	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RODRIGO	8955335	\N	\N	\N	t	2026-05-13 16:12:12.632	\N
2f5b648e-7130-4703-837a-afc3fac32aa0	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RODRIGO FLORES	6589772	\N	\N	\N	t	2026-05-13 16:13:36.608	\N
09444357-d818-46fa-9a00-1d4d6730e188	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RODRIGO QUISPE	12847316	\N	\N	\N	t	2026-05-13 16:15:49.1	\N
78a28621-1984-46c7-b399-41b37b32b364	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ROGER SOLIZ	8951502	\N	\N	\N	t	2026-05-13 16:17:39.89	\N
07a93134-4420-4493-83e0-a79a04229f61	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ROMEO AMORIN	2823717	\N	\N	\N	t	2026-05-13 16:19:34.386	\N
386355ce-1913-40f6-affb-80ac1576859e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RONAL SOLIZ	5332262	\N	\N	\N	t	2026-05-13 16:21:13.207	\N
580a5edb-5baf-4328-9759-a125936cca0c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SEBASTIAN VEGA	76634316	\N	\N	\N	t	2026-05-13 16:46:09.711	\N
958a722c-2b94-4350-8176-55eb498d71c9	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RICHARD CALDERON	6342200	\N	\N	\N	t	2026-05-13 16:00:51.601	uploads/partners/1778689436478.jpg
c804208f-9b00-40ac-8f50-6aaea5f1b7c7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	ROSARIO CHOQUE	13837959	\N	\N	\N	t	2026-05-13 16:26:39.152	\N
4bd929fb-a536-4e2d-9bf0-837634d76370	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	JAVIER	11310607	\N	\N	\N	t	2026-05-12 19:11:32.574	uploads/partners/1778689736841.jpg
8fadbb0c-559d-45bb-97b7-b4f8e096a2d4	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RUBEN FLORES	6255032	\N	\N	\N	t	2026-05-13 16:31:33.366	\N
49230980-23d7-40cf-8372-abb87aff12ec	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RUBEN SANGUINO	6234036	\N	\N	\N	t	2026-05-13 16:33:59.24	\N
b8a6b8df-3daf-4ded-89bd-aaf7a4bde2a1	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	RUPERT PEÑARANDA	12452531	\N	\N	\N	t	2026-05-13 16:38:41.198	\N
6fcab6d7-4652-483a-ae23-5ad05582d5d1	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SAMIR	13701007	\N	\N	\N	t	2026-05-13 16:40:05.187	\N
a927df4b-d10b-4e8e-ac02-ef5f78ee82fd	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SEBASTIAN CUELLAR	14430690	\N	\N	\N	t	2026-05-13 16:41:17.9	\N
9c68a247-ccef-40e6-a8dd-3fdba411f12d	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SEBASTIAN VELARDE	12896091	\N	\N	\N	t	2026-05-13 16:47:19.057	\N
9fe4f4f4-9aef-443b-9d1c-3cbc3c88aba2	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	MICAELA VINOYA	8074236	\N	\N	\N	t	2026-05-13 12:25:34.866	uploads/partners/1778691113198.jpg
c6d315b6-8b52-421a-9b9c-a77ff639022e	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SERGIO ABELLA	6214528	\N	\N	\N	t	2026-05-13 16:56:40.168	\N
928a4b6c-c714-4ed8-bc7b-16e578aebc41	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SERGIO	14750108	\N	\N	\N	t	2026-05-13 16:55:26.25	\N
bae8a750-4296-43fa-bd65-9f0c827365a7	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SERGIO GERONIMO	5783316	\N	\N	\N	t	2026-05-13 16:57:58.104	\N
ce1ff1f0-9262-435b-bd17-78b1fd25fc24	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SHIRLEY GOMEZ	6358840	\N	\N	\N	t	2026-05-13 16:59:20.271	\N
cab49eaa-9177-4514-b647-279e032aab0c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SHIRLEY HURTADO	67807413	\N	\N	\N	t	2026-05-13 17:00:27.276	\N
0f8e1a36-c6b9-49b5-8ba5-ce178077c88a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SHOEI	8895601	\N	\N	\N	t	2026-05-13 17:02:49.744	\N
b6f67fec-5790-4e2f-8f90-125612a3c29c	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SILVIA ALIAGA	3901450	\N	\N	\N	t	2026-05-13 17:07:08.082	\N
09402461-b3c0-47bf-820d-abf9ed3b2661	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SONY	13381941	\N	\N	\N	t	2026-05-13 17:08:07.438	\N
51d1d5e0-7be3-4473-ad9a-2863df29a507	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	SORAYA SUBIRANA	8235089	\N	\N	\N	t	2026-05-13 17:09:50.388	\N
7dfdc883-425b-444b-8855-8e3ed40501b2	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	STEVE ALMANZA	12534615	\N	\N	\N	t	2026-05-13 17:11:06.867	\N
883760f8-eeb8-4bd8-9d8d-bedb77ff8f02	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	VALENTINA VARGAS	15332807	\N	\N	\N	t	2026-05-13 17:13:22.408	\N
e6187633-0f88-4896-a42f-8a39a9e67f88	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	VALERIA FERNANDEZ	76634525	\N	\N	\N	t	2026-05-13 17:14:45.463	\N
c623c23b-5da4-4b94-bf23-263187c4a392	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	VERONICA MAMANI	9664593	\N	\N	\N	t	2026-05-13 17:26:32.299	\N
b91ec917-d1f3-4838-b542-09992ef68a3a	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	WALTER DURAN	5591465	\N	\N	\N	t	2026-05-13 17:27:58.245	\N
07a698a1-0f64-4f65-b8ae-f16aa203b143	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	WENCESLAO	13104291	\N	\N	\N	t	2026-05-13 17:29:42.678	\N
47034143-833a-42ce-b066-b3f8ff358977	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	WILLIAM	4559321	\N	\N	\N	t	2026-05-13 17:33:12.478	\N
2337c795-7592-40e6-a6c2-355e855b9e96	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YEISON EL HAGE	95839780	\N	\N	\N	t	2026-05-13 17:34:30.441	\N
9487b2c6-7fe4-41fe-b92b-9034df0d2597	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YESENIA URGEL	9582180	\N	\N	\N	t	2026-05-13 17:37:40.281	\N
1c21828d-94a8-4050-a546-cbca00dc17f0	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YOJAN VARGAS	8179415	\N	\N	\N	t	2026-05-13 17:38:53.442	\N
79d187ec-9603-4c9d-83d1-b3854a951c8f	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YORDY ROCA FORTUNATY	11345922	\N	\N	\N	t	2026-05-13 17:40:55.639	\N
8c12163c-ebdd-4842-bb18-7bc0f50f6fbc	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YOSELIN COA	8202617	\N	\N	\N	t	2026-05-13 17:42:09.506	\N
3004aa20-e37a-43c3-b807-ccaf85841daa	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YOVANI ROCA	76052831	\N	\N	\N	t	2026-05-13 17:43:33.777	\N
5b5c5739-ea30-4366-ad38-2c4571dcdcfb	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YUKIO	89299701	\N	\N	\N	t	2026-05-13 17:45:01.137	\N
62b3b1f3-aeda-4c59-bfeb-8233dd6fc277	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	YULISSA CASTRO	9808665	\N	\N	\N	t	2026-05-13 17:46:10.404	\N
91c044a8-45b4-457f-b12d-f937c6fff0b5	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	alex campo	4430807	\N	\N	\N	t	2026-05-13 17:48:48.667	\N
ba1992b4-d270-4aff-b98f-f3c519f52354	ba873a42-909b-47cf-8bd7-15caaf87fd46	CUSTOMER	alvaro yabeta	7785273	\N	\N	\N	t	2026-05-13 17:50:36.717	\N
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
05e7f0d7-535c-462c-8a3e-ca00d39f1d93	Promo Anual	Promo Anual	700.000000000000000000000000000000	365	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:17:52.307	2026-05-08 00:17:52.307
e13b2784-d129-4d98-9106-571b727e2ae2	Promo Trimestral	Promo trimestral	260.000000000000000000000000000000	90	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-08 00:17:30.832	2026-05-12 00:37:06.332
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
e62342ab-62df-4a3a-b7db-82babac84b8c	Caja	TENANT	6b828940-7fc0-449f-8a26-f91d237a0940	t	2026-05-11 07:23:15.56
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
249e3b22-6b80-4ef3-9e44-f17d8bfa6b2e	8f9470e0-20d8-4306-b280-febaf514e6bb	bd9349cc-fc82-410f-8136-672a3f416fe1
11045e35-b77c-4cbd-b8e1-5b1f2ac10665	8f9470e0-20d8-4306-b280-febaf514e6bb	1d458a77-9b8d-4ebc-9931-97a7e74cf21c
f1645cd1-d7a3-46af-8342-31f00b9f6c98	8f9470e0-20d8-4306-b280-febaf514e6bb	b645a3fc-7edd-4e3a-85f8-26469b2d0037
6fbf71fa-23d6-4b96-b761-77ff5a5e5aec	8f9470e0-20d8-4306-b280-febaf514e6bb	79bef71b-18e5-4691-a2e4-be34146e9fc9
1b036509-1776-4269-976f-02a9efb4b11d	8f9470e0-20d8-4306-b280-febaf514e6bb	73e7330e-50a3-47e3-b86a-e80bf691db07
e2cee023-4c2e-4ad3-85e1-bcd0da036bd1	8f9470e0-20d8-4306-b280-febaf514e6bb	e738238a-eb71-4323-8b30-5fb7a7d30b14
7028264b-5586-4046-89c4-91ed4375e99b	8f9470e0-20d8-4306-b280-febaf514e6bb	23a9c166-1a7a-4ef1-b026-61af37645e3b
fdce7683-b5c6-4f2a-b7e9-531802932467	8f9470e0-20d8-4306-b280-febaf514e6bb	88b7d5b1-974c-41b0-8b38-d4dcb0ceeb2f
b06dc1c6-1345-4e06-8951-5969ddaa8035	8f9470e0-20d8-4306-b280-febaf514e6bb	94e4347f-16ae-43ad-b334-8cad426f5562
22ee37a0-f05f-4320-a391-3a831ab4f0ac	8f9470e0-20d8-4306-b280-febaf514e6bb	d1fbb067-418d-4f1d-bd9b-ae25fa98e593
571e1b14-9ba6-4108-b6d4-c4458f86f462	8f9470e0-20d8-4306-b280-febaf514e6bb	e0df5c84-efae-4efb-9145-e2cf00cd80dd
02c53fc5-58a5-4900-bcb2-cf608ab4e5b8	8f9470e0-20d8-4306-b280-febaf514e6bb	3415b815-1065-4c7f-93e3-afd53b84c557
b61cecf7-0bb2-4251-a878-ad40831771a8	8f9470e0-20d8-4306-b280-febaf514e6bb	1202de82-2216-4467-8f56-2666bf2f3448
889d837e-b377-4603-b8e2-a5f514def519	8f9470e0-20d8-4306-b280-febaf514e6bb	292ab621-eb16-45e2-9872-3d475315817b
41b5c414-f7f4-4691-b4ab-99f920db035d	8f9470e0-20d8-4306-b280-febaf514e6bb	4f140291-f5f7-487b-a0a2-a34881d51517
b56ba930-fe0a-46ec-8241-62116b2ec7bb	8f9470e0-20d8-4306-b280-febaf514e6bb	082dcb9f-6381-4bca-9b3c-a4ef3dcbb706
e068aa26-3999-42dc-95e0-4e7948fd04b3	8f9470e0-20d8-4306-b280-febaf514e6bb	082e2a7a-eff6-44a1-b604-c2ab1edc95b5
a0940b7c-2f29-4392-9685-9cc2aadfef14	8f9470e0-20d8-4306-b280-febaf514e6bb	9c876750-36f2-468e-a198-e10a9626cd00
e93d885f-3483-4097-9224-c580229bd416	8f9470e0-20d8-4306-b280-febaf514e6bb	0f2dec1d-907c-4191-bc9a-acb18f6378a8
3e07d05f-385a-480f-9f41-fd982b10ef64	8f9470e0-20d8-4306-b280-febaf514e6bb	8f935806-88ce-43c1-9ada-4336968d1c04
13c9b1f6-3c0d-4471-a27b-9ad42667cb42	8f9470e0-20d8-4306-b280-febaf514e6bb	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365
216d97a1-182e-4357-96f8-013e5ebe4bc9	8f9470e0-20d8-4306-b280-febaf514e6bb	dcde9549-77da-4227-ada0-35f7565804ef
0a5ca444-43a0-4b1b-bb9d-4ef2a6a67c86	8f9470e0-20d8-4306-b280-febaf514e6bb	375daabc-e2c9-435e-b007-18245e5f2d0d
48cd2f50-d8fa-46a3-90a5-3d9af95cdcc3	8f9470e0-20d8-4306-b280-febaf514e6bb	0c38eda9-3781-4a72-93cc-810b51caf9c7
68be5018-fd0f-47ad-a2dc-c048b2fb1428	8f9470e0-20d8-4306-b280-febaf514e6bb	3c4c0349-cd46-4557-aa21-ced1ef68a054
45509ddc-886c-467f-8292-08e084874873	8f9470e0-20d8-4306-b280-febaf514e6bb	8906ae3f-dacf-4ba5-a2c6-e2e9c65f91a4
41dd61f3-5821-41a2-9ee1-006bc2e4f9c4	8f9470e0-20d8-4306-b280-febaf514e6bb	6bb4ba35-d763-4f61-bb02-73c217976f25
69463d48-6da7-4552-9be2-bd245a881eee	8f9470e0-20d8-4306-b280-febaf514e6bb	b3bc1161-8c43-4264-a60d-619e05cda55e
160ce0c7-8ebe-40ad-94d5-d20d611c0237	8f9470e0-20d8-4306-b280-febaf514e6bb	f3e6cf31-7278-4581-a485-28064fb99b5c
2ff9cdd9-640c-4be6-8ac6-4e76799d8a78	8f9470e0-20d8-4306-b280-febaf514e6bb	850ae969-9f55-41ca-bb53-80066d012323
8662478d-fe3f-45ed-83fe-da686bcaf647	8f9470e0-20d8-4306-b280-febaf514e6bb	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735
56c30ea5-767c-42ab-a0c2-ac299f9f4915	8f9470e0-20d8-4306-b280-febaf514e6bb	e49620db-e84c-47bf-91a0-ff8867c8f412
8b5944c1-5e84-4ae1-9d26-ed53daad516a	e62342ab-62df-4a3a-b7db-82babac84b8c	bd9349cc-fc82-410f-8136-672a3f416fe1
2d52a889-1b75-4c4c-b38a-21a955093b34	e62342ab-62df-4a3a-b7db-82babac84b8c	e0df5c84-efae-4efb-9145-e2cf00cd80dd
ec875836-09fb-4a98-8e18-9d7c87d086a1	e62342ab-62df-4a3a-b7db-82babac84b8c	3415b815-1065-4c7f-93e3-afd53b84c557
3b3da67d-1cfd-4304-9bcc-b691971ccb1b	e62342ab-62df-4a3a-b7db-82babac84b8c	4f140291-f5f7-487b-a0a2-a34881d51517
7439be04-8dab-4c18-95dc-a9a334971a74	e62342ab-62df-4a3a-b7db-82babac84b8c	082dcb9f-6381-4bca-9b3c-a4ef3dcbb706
9621ab81-7ebc-4a76-8736-db02027891f6	e62342ab-62df-4a3a-b7db-82babac84b8c	0f2dec1d-907c-4191-bc9a-acb18f6378a8
367550c8-ea9c-49c5-9fd6-f955eee8cd27	e62342ab-62df-4a3a-b7db-82babac84b8c	8f935806-88ce-43c1-9ada-4336968d1c04
fa225fac-26d6-4474-ba86-220d8ac4b97e	e62342ab-62df-4a3a-b7db-82babac84b8c	4bd2cf4f-9ba3-4d3a-a73f-2c558b2df365
5f939e5b-1f08-4b95-8a98-1ffaa242bdf4	e62342ab-62df-4a3a-b7db-82babac84b8c	375daabc-e2c9-435e-b007-18245e5f2d0d
3b48403a-62c5-48f4-88a4-72ab35eb0fcf	e62342ab-62df-4a3a-b7db-82babac84b8c	0c38eda9-3781-4a72-93cc-810b51caf9c7
2bbe65aa-582e-46d5-851a-34f78ff25da4	e62342ab-62df-4a3a-b7db-82babac84b8c	6bb4ba35-d763-4f61-bb02-73c217976f25
fc383909-712b-48d5-8d68-e9cbc946dc6a	e62342ab-62df-4a3a-b7db-82babac84b8c	3f2b4874-7cfb-41dc-a7b8-bb5daa4c0735
714848fd-37a6-421b-a320-2c28d4cfd8c3	e62342ab-62df-4a3a-b7db-82babac84b8c	e49620db-e84c-47bf-91a0-ff8867c8f412
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
543856ad-d4b6-4be7-93b5-e9bf0052c782	caja_mutualista@metafit.com	$2b$10$p/j/T5F8wUhfw3TkZ9AIuuuVaaHxU4x1FB7n8o69gP8zq/BB6Mobu	caja_mutualista@metafit.com	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 23:04:51.24	2026-05-07 23:04:51.24	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	f
7abf7f31-0cf6-48e0-a1a2-697de2a0b166	admin@erp.com	$2b$10$ADWlnevKdkzSaohE5/GM1OvbrpMXJ9EepqSwxEnlVT0DRb3v/sR8y	Super Admin	t	6b293f8f-beec-4a45-9b22-98ceabe0f3a1	2026-05-05 14:44:21.821	2026-05-08 03:26:33.478	1b9b384c-0715-4247-b718-6738efe86c89	f
a484e2d7-a009-4c8a-8237-b3323c036405	admin@metafit.com	$2b$10$f7bSYzVrhad4aSjdch51c.oQkGzJFkyO7Xq3xwH0JKZhBCIZDozRy	Administración	t	ba873a42-909b-47cf-8bd7-15caaf87fd46	2026-05-07 22:35:11.664	2026-05-08 03:28:53.788	aeb8a3c9-39fd-4fe4-8213-a3aaf576b3a2	t
7cead38c-acae-416c-9ed0-83f8287b4f35	admin@infinity.com	$2b$10$UD.ar9z07af8UV/zi8gZ5eIa5mfKQR6w6eKtxqK0rUbdjM2fPyoo2	Administracion	t	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-05 14:46:06.651	2026-05-08 20:29:45.248	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	t
b34eadb5-350e-4c72-8153-fab9cd740c7f	caja_infinity@infinity.com	$2b$10$CoFbO.5mV0oc/NsZMNO1DeTFn/8AMo8zWV/ZCrUFS9C4s3kTYE2AG	Caja Infinity	t	6b828940-7fc0-449f-8a26-f91d237a0940	2026-05-11 07:23:55.792	2026-05-11 07:23:55.792	0126e6f3-8d6c-4eae-b36d-18bb7b8cb8ee	f
\.


--
-- Data for Name: UserRole; Type: TABLE DATA; Schema: public; Owner: erp_user
--

COPY public."UserRole" (id, "userId", "roleId", "companyId") FROM stdin;
e3db1c65-b59d-4433-b4bd-b7e4097bc62f	7abf7f31-0cf6-48e0-a1a2-697de2a0b166	4cc9cf24-b628-49dc-9108-7f90d1c67fed	\N
6e1927ea-f76f-46f4-b7e6-78784bc6c97d	7cead38c-acae-416c-9ed0-83f8287b4f35	8f9470e0-20d8-4306-b280-febaf514e6bb	6b828940-7fc0-449f-8a26-f91d237a0940
15e942ff-8b36-4b0f-a0ff-2ff859f35698	a484e2d7-a009-4c8a-8237-b3323c036405	200c21f0-06d7-4ab2-b7b7-ca5cd6f22a23	ba873a42-909b-47cf-8bd7-15caaf87fd46
2d22f357-be43-447b-95d7-985cb5cc520b	543856ad-d4b6-4be7-93b5-e9bf0052c782	c7b89eb2-26a7-4d98-8782-9bf2c8a3f03a	ba873a42-909b-47cf-8bd7-15caaf87fd46
ed92ee61-ae11-4b80-8c54-a13077d702bc	b34eadb5-350e-4c72-8153-fab9cd740c7f	e62342ab-62df-4a3a-b7db-82babac84b8c	6b828940-7fc0-449f-8a26-f91d237a0940
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
7718678b-8956-4dd5-974f-62811612631d	b2bec6e7aaac757087fa44544bf08211a099dff716df30356c16adcaa0c710f9	\N	20260507051710_init	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20260507051710_init\n\nDatabase error code: 42710\n\nDatabase error:\nERROR: enum label "SYNC_USER_FULL" already exists\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42710), message: "enum label \\"SYNC_USER_FULL\\" already exists", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("pg_enum.c"), line: Some(264), routine: Some("AddEnumLabel") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20260507051710_init"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name="20260507051710_init"\n             at schema-engine/core/src/commands/apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:226	2026-05-11 06:47:15.624375+00	2026-05-11 06:46:40.171322+00	0
1b17d263-8957-4c4d-83b6-341594f992b7	b2bec6e7aaac757087fa44544bf08211a099dff716df30356c16adcaa0c710f9	2026-05-11 06:47:15.633569+00	20260507051710_init		\N	2026-05-11 06:47:15.633569+00	0
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
-- Name: Agent_publicIp_idx; Type: INDEX; Schema: public; Owner: erp_user
--

CREATE INDEX "Agent_publicIp_idx" ON public."Agent" USING btree ("publicIp");


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

\unrestrict OvcA8TjK4KStGvOtpuCl7S86aFJGUAh8ZUncBWCez7WyMWoNdv1SXBAZZ2NGfgo

