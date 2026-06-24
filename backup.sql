--
-- PostgreSQL database dump
--

\restrict QK79zDq4AmViIsHbjpOggAKZmaGwpedNwHJGgEfigj8S6giQgIsHIrhG36NKXZw

-- Dumped from database version 16.12
-- Dumped by pg_dump version 16.12

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: vpn_user
--

CREATE TABLE public.payments (
    user_id bigint NOT NULL,
    amount numeric NOT NULL,
    currency text NOT NULL,
    payment_id text NOT NULL,
    days integer NOT NULL,
    period_name text NOT NULL,
    status text DEFAULT 'completed'::text NOT NULL
);


ALTER TABLE public.payments OWNER TO vpn_user;

--
-- Name: routing_usage; Type: TABLE; Schema: public; Owner: vpn_user
--

CREATE TABLE public.routing_usage (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    routing_sent_at timestamp with time zone DEFAULT now() NOT NULL,
    uses_routing boolean DEFAULT false,
    last_traffic_check timestamp with time zone
);


ALTER TABLE public.routing_usage OWNER TO vpn_user;

--
-- Name: routing_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: vpn_user
--

CREATE SEQUENCE public.routing_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.routing_usage_id_seq OWNER TO vpn_user;

--
-- Name: routing_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vpn_user
--

ALTER SEQUENCE public.routing_usage_id_seq OWNED BY public.routing_usage.id;


--
-- Name: vpn_subs; Type: TABLE; Schema: public; Owner: vpn_user
--

CREATE TABLE public.vpn_subs (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    date_start timestamp with time zone NOT NULL,
    date_end timestamp with time zone NOT NULL,
    username text
);


ALTER TABLE public.vpn_subs OWNER TO vpn_user;

--
-- Name: vpn_subs_id_seq; Type: SEQUENCE; Schema: public; Owner: vpn_user
--

CREATE SEQUENCE public.vpn_subs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vpn_subs_id_seq OWNER TO vpn_user;

--
-- Name: vpn_subs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vpn_user
--

ALTER SEQUENCE public.vpn_subs_id_seq OWNED BY public.vpn_subs.id;


--
-- Name: vpn_users; Type: TABLE; Schema: public; Owner: vpn_user
--

CREATE TABLE public.vpn_users (
    user_id bigint NOT NULL,
    username text,
    vpn_url text,
    total_traffic_mb numeric DEFAULT 0
);


ALTER TABLE public.vpn_users OWNER TO vpn_user;

--
-- Name: routing_usage id; Type: DEFAULT; Schema: public; Owner: vpn_user
--

ALTER TABLE ONLY public.routing_usage ALTER COLUMN id SET DEFAULT nextval('public.routing_usage_id_seq'::regclass);


--
-- Name: vpn_subs id; Type: DEFAULT; Schema: public; Owner: vpn_user
--

ALTER TABLE ONLY public.vpn_subs ALTER COLUMN id SET DEFAULT nextval('public.vpn_subs_id_seq'::regclass);


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: vpn_user
--

COPY public.payments (user_id, amount, currency, payment_id, days, period_name, status) FROM stdin;
1382441870	200.0	RUB	8605019e	30	1 месяц	completed
356683309	200.0	RUB	f7ae06b7	30	1 месяц	completed
7607848299	200.0	RUB	58fcbf87	30	1 месяц	completed
1761463830	200.0	RUB	1cdef8ea	30	1 месяц	completed
1618498304	200.0	RUB	57175b1c	30	1 месяц	completed
252095329	200.0	RUB	b02c1773	30	1 месяц	completed
\.


--
-- Data for Name: routing_usage; Type: TABLE DATA; Schema: public; Owner: vpn_user
--

COPY public.routing_usage (id, user_id, routing_sent_at, uses_routing, last_traffic_check) FROM stdin;
2	1772804316	2025-12-01 00:57:04.074724+00	f	\N
3	225557702	2025-12-01 01:16:57.609647+00	f	\N
4	7185901263	2025-12-01 03:53:55.554314+00	f	\N
68	252095329	2026-02-13 16:40:17.623626+00	t	2026-02-23 01:54:07.289745+00
5	7050134748	2025-12-01 07:54:13.255838+00	f	\N
55	5746022064	2026-01-06 22:25:56.46323+00	t	2026-01-29 08:09:22.050563+00
6	890999417	2025-12-01 09:15:58.011933+00	f	\N
13	8042009619	2025-12-04 18:50:22.058699+00	t	2025-12-04 20:58:39.009557+00
14	261259181	2025-12-04 21:27:19.548059+00	f	\N
24	246259999	2025-12-11 13:15:26.264467+00	t	2025-12-11 17:06:51.845138+00
25	636043501	2025-12-11 17:16:57.25617+00	t	2026-02-17 13:22:44.995355+00
26	304622290	2025-12-11 17:18:52.544349+00	f	\N
49	1718721565	2025-12-31 21:39:49.689058+00	t	2026-01-29 10:09:30.090358+00
59	690253150	2026-01-15 02:07:07.31587+00	t	2026-01-29 10:09:30.090358+00
16	6935872017	2025-12-05 17:35:48.169567+00	t	2026-02-17 13:22:44.995355+00
58	6270280019	2026-01-12 21:53:44.601559+00	t	2026-02-17 13:22:44.995355+00
44	950416192	2025-12-28 10:34:50.788427+00	t	2026-01-29 08:09:22.050563+00
18	7081916771	2025-12-06 19:08:07.840542+00	t	2025-12-12 21:08:17.813937+00
7	542381157	2025-12-01 15:46:38.45292+00	t	2025-12-12 21:08:17.813937+00
71	6116982433	2026-02-18 17:50:57.130454+00	t	2026-02-18 18:24:38.909045+00
19	7327494579	2025-12-06 23:22:30.588971+00	f	\N
51	164125396	2026-01-03 21:03:28.014491+00	t	2026-01-29 08:09:22.050563+00
9	888782677	2025-12-02 10:48:14.198203+00	t	2026-01-29 08:09:22.050563+00
8	930286429	2025-12-01 22:45:51.224744+00	t	2026-01-29 08:09:22.050563+00
66	7607848299	2026-02-11 22:53:27.178198+00	t	2026-02-23 10:47:05.573762+00
40	356683309	2025-12-24 17:37:44.073883+00	t	2026-02-23 10:47:05.573762+00
29	6352363131	2025-12-14 17:50:45.237768+00	f	\N
30	244494750	2025-12-14 23:39:43.003124+00	f	\N
31	949659892	2025-12-17 20:08:17.428045+00	f	\N
32	1062974048	2025-12-18 18:54:50.656198+00	f	\N
33	1181816030	2025-12-18 19:35:21.003248+00	f	\N
34	6199820078	2025-12-19 19:11:32.546389+00	f	\N
35	5502328654	2025-12-23 00:00:27.568752+00	f	\N
52	8426001290	2026-01-04 20:25:11.113906+00	t	2026-02-07 21:08:09.107863+00
70	845451513	2026-02-18 10:56:19.24928+00	f	\N
39	847947048	2025-12-24 13:35:47.554796+00	f	\N
41	1464377851	2025-12-25 13:13:42.978502+00	f	\N
43	1608854638	2025-12-28 10:29:59.627006+00	f	\N
67	1618498304	2026-02-13 09:06:52.388337+00	t	2026-02-23 12:47:05.991884+00
45	536383453	2025-12-28 12:18:16.277159+00	f	\N
47	5182997693	2025-12-30 14:46:29.666362+00	f	\N
72	502088930	2026-02-20 00:52:47.498902+00	f	\N
11	542056003	2025-12-03 00:27:49.982073+00	t	2026-02-09 01:09:22.914209+00
10	290353511	2025-12-03 00:27:47.836303+00	t	2026-01-29 08:09:22.050563+00
54	1394294038	2026-01-06 22:25:20.429764+00	t	2026-02-09 03:09:26.381704+00
50	1613216767	2026-01-01 07:34:25.913149+00	f	\N
65	5891909126	2026-02-11 18:25:33.550631+00	t	2026-02-11 22:32:29.945782+00
63	376459793	2026-01-28 00:19:18.257536+00	f	\N
60	521515955	2026-01-15 18:17:25.441797+00	t	2026-02-09 06:09:32.128706+00
23	1661730241	2025-12-11 11:31:38.445913+00	t	2026-02-18 12:24:21.509527+00
56	5052384072	2026-01-08 09:24:28.565999+00	f	\N
57	347780570	2026-01-09 11:09:21.443489+00	f	\N
27	395669555	2025-12-12 22:06:40.856981+00	t	2026-02-18 12:24:21.509527+00
36	7832719668	2025-12-23 00:01:55.100195+00	t	2026-02-18 12:24:21.509527+00
61	628356461	2026-01-16 15:44:00.207257+00	f	\N
62	239858852	2026-01-18 12:52:59.804059+00	f	\N
22	1373314202	2025-12-09 23:59:13.329358+00	t	2026-02-18 12:24:21.509527+00
53	1016266204	2026-01-06 19:25:29.956969+00	t	2026-02-18 12:24:21.509527+00
38	5193682399	2025-12-23 14:01:05.971779+00	t	2026-02-18 12:24:21.509527+00
20	581094500	2025-12-07 00:32:57.332904+00	t	2026-02-17 13:22:44.995355+00
12	1986228881	2025-12-04 16:15:00.045238+00	t	2026-01-29 08:09:22.050563+00
48	1839347986	2025-12-31 21:21:34.606247+00	t	2026-01-29 08:09:22.050563+00
21	822315669	2025-12-09 21:52:13.557788+00	t	2026-01-29 08:09:22.050563+00
15	545804557	2025-12-05 01:09:56.748353+00	t	2026-02-18 10:24:13.62299+00
37	201222293	2025-12-23 14:00:12.240031+00	t	2026-02-18 10:24:13.62299+00
64	950734538	2026-01-29 08:32:37.028475+00	f	\N
42	6479226198	2025-12-28 09:46:07.630388+00	t	2026-02-18 10:24:13.62299+00
28	1423368104	2025-12-12 23:13:52.525989+00	t	2026-01-29 10:09:30.090358+00
46	820982175	2025-12-30 14:44:21.266073+00	t	2026-01-29 08:09:22.050563+00
1	1382441870	2025-12-01 00:48:09.976072+00	t	2026-02-23 11:10:35.856967+00
69	1053258958	2026-02-17 13:27:03.792256+00	t	2026-02-23 11:10:35.856967+00
17	1761463830	2025-12-06 12:41:40.232104+00	t	2026-02-23 11:10:35.856967+00
\.


--
-- Data for Name: vpn_subs; Type: TABLE DATA; Schema: public; Owner: vpn_user
--

COPY public.vpn_subs (id, user_id, date_start, date_end, username) FROM stdin;
1	1382441870	2026-02-11 06:43:32.669108+00	2026-03-13 06:43:32.669108+00	Evgeniy Gordeev
2	252095329	2026-02-13 13:36:03.746233+00	2026-02-20 13:36:03.746233+00	@EvgenijTim
3	356683309	2026-02-11 06:53:44.677442+00	2026-03-13 06:53:44.677442+00	@catviva
4	7580242672	2026-02-16 16:43:52.013579+00	2026-02-23 16:43:52.013579+00	@boss_i_050
5	888782677	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@yatjjwnaka
6	1394294038	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@pahom4kit
7	950416192	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Shamsheva_SK
8	392688348	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	efg None
9	6563976046	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Paravozik6
10	992855339	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Nataliia2704
11	742733035	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@s4ad0wq
12	545804557	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@davasilev
13	1300362005	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@lenchicsss_official
14	7832719668	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	SankiOr None
15	744100716	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@sejurovno
16	986330835	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@alien_krew
17	347780570	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Andrey None
18	137250251	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@arkaram
19	7327494579	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@gonnahatehaters
20	6769800017	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@muurmeooww
21	8327977462	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@b4b_manager
22	562579515	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ksssuvv
23	1613216767	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@andronnikov6
24	7861168706	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Аброр Сайдуллаев
25	5487588531	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@vlinchco
26	890999417	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@kirill_s_gavr
27	1986228881	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@neon4on
28	6034373572	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	I None
29	822315669	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@annnastasssi
30	5746022064	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	­­ None
31	1262104118	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Maximvasilenkoofficia
32	941457535	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@sickyet
33	5108798186	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@LeoYurii
34	5438631219	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ghinzburger
35	201222293	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Андрей Андреев
36	7050134748	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@sega_user
37	952743010	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@notvladislv
38	7305328673	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@wannilly
39	122814347	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@JAGAT_Om
40	781408462	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@lalia_am
41	269117976	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@HalfLennelluc
42	365576584	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Kim_Kauf
43	395669555	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@annaeffe26
44	201596660	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@NickKitovsky
45	401676402	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@a_garkier
46	5228093595	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ottyanak
47	655010957	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@BeKoH183
48	400189677	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@md_chewbacca
49	542056003	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@edvirado
50	7108317408	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@aaandrey23
51	67154323	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@turbouzback
52	1409792980	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@girichev
53	844004608	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Aleks None
54	6397181042	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Bro&N None
55	6503212990	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Andrey None
56	6885239750	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	ᅠᅠᅠᅠ None
57	5120498314	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Oleg None
58	1759062324	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@VladimirChernyshev1
59	7185901263	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Маргарита None
60	1728812699	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Bright Agbali
61	1772804316	2026-02-19 10:01:53.297096+00	2026-02-22 10:01:53.297096+00	\N
62	252095329	2026-02-20 13:36:03.746233+00	2026-03-22 13:36:03.746233+00	\N
63	502088930	2026-02-19 21:51:02.257756+00	2026-02-26 21:51:02.257756+00	\N
64	6935872017	2026-02-23 02:46:46.053457+00	2026-02-26 02:46:46.053457+00	@BD_TON
65	1053258958	2026-02-17 10:26:22.301996+00	2026-02-24 10:26:22.301996+00	@pirihha
66	840175771	2026-02-17 11:35:57.559987+00	2026-02-24 11:35:57.559987+00	@dynomake
67	845451513	2026-02-18 07:55:44.17441+00	2026-02-25 07:55:44.17441+00	@bmo52
68	5891909126	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Oleg28022
69	388365301	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@dradanudanay
70	7607848299	2026-02-18 10:51:20.632502+00	2026-03-20 10:51:20.632502+00	@YoOli99
71	1761463830	2026-02-18 10:52:03.421027+00	2026-03-20 10:52:03.421027+00	@Ivanjordan1
72	2046567335	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@evabushuevaa
73	5683516267	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@mukhamedov_1112
74	311277386	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@projectiks
75	950734538	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@eleshka1
76	1775368546	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@yoaxrx
77	86448143	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@MalvinaCrunchy
78	244494750	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Hermanandorberg
79	304622290	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@TEYHD
80	6199820078	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Shohjahon None
81	5502328654	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@lilla_kattenn
82	847947048	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@marishkamd
83	5123089954	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Ольга Мальчёнкова
84	8042009619	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Chikatishka
85	1024041782	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Amele_wk
86	1663034905	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Kirill None
87	393139445	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@hey_ulitka
88	6479226198	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Maria None
89	6116982433	2026-02-18 14:50:38.734519+00	2026-02-25 14:50:38.734519+00	@ghost_case
90	1618498304	2026-02-18 15:45:18.624163+00	2026-03-20 15:45:18.624163+00	@liticli
91	1422345231	2026-02-18 21:11:50.645655+00	2026-02-25 21:11:50.645655+00	@VladimirSeyranyan
92	128072094	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@egorovechkin
93	261259181	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@wildw1
94	1608854638	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Varyaanon
95	7292120610	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ebany_po_kosmosy
96	7081916771	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@asuyl
97	542381157	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Inskayi
98	949659892	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@sspektra
99	1062974048	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@itssvd10
100	324302243	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@vslkov
101	5182997693	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Jane_0000
102	1464377851	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@kktvn888
103	5606611599	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Shohjahon2020
104	8426001290	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@qweeuk1
105	573437479	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@BekJaan_CS
106	7224025843	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@xsoexsov
107	1025134411	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@justsofasafina
108	291633079	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Artdex
109	536383453	2026-02-23 02:46:46.053457+00	2026-02-26 02:46:46.053457+00	@Timmoxamos
110	5193682399	2026-02-23 02:46:46.053457+00	2026-02-26 02:46:46.053457+00	Максим Коленкин
111	1002403343	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Rulazail
112	1118501605	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@veramedd
113	1500656262	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@userneneta
114	1282984042	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@astepache
115	313758160	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Pooh1965
116	163269254	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@beerbeep
117	1718721565	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Игорь Климович
118	885646283	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Daniil123456777
119	840726442	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@BubblegumB1tch
120	986459529	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Takeshi_Sun79
121	1226209785	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ne_dunduk
122	225557702	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@sdc22
123	1314267038	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@alisia_ko
124	250025907	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@thisisqwi
125	724617564	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@narmadykov_d
126	5575082434	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ncvxzrxxx
127	5198380981	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	ㅤㅤ𝔢𝔯𝔤 ㅤㅤ None
128	1923200166	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Serega37Rus
129	812399225	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ShiningMars
130	866928334	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@imgoar
131	494388019	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@whodatandrey
132	5368556156	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	BOB Z
133	5052384072	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@deuceina42
134	628356461	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Anna_Ilintseva
135	239858852	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Georgiy108
136	376459793	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@komrat1988
137	710827583	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@localwolf58
138	290353511	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@nastyankl
139	820982175	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Deddrox
140	460458056	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@the_brazen
141	6270280019	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Марина Кононова
142	690253150	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@dianamyazitova
143	1016266204	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@KononovaMarina1
144	521515955	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@leon4ik8
145	980700322	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@losilososi
146	164500456	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@ivanzykov95
147	1181816030	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@aceaceace00
148	1423368104	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	ㅤ None
149	1373314202	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	🤘 None
150	1075521158	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Knjagna77
151	581094500	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Kul4ivan
152	1351682871	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Flansy_steals
153	1839347986	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Елена Ильинцева
154	264778762	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@GuiIIermO_o
155	7735591793	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Acab70
156	834622116	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@EgorMIX2024
157	1219789072	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Anna_2106
158	1299669079	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Skarlat13
159	294996566	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Heyx0
160	6352363131	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@xpos587
161	6697904384	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@k0tebayun
162	1754633400	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@kivpa
163	373120282	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@VadikKirli
164	246259999	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@RandySandy
165	636043501	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@nkaumov42
166	164125396	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@iAmRuslan
167	6278876591	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Bula_228
168	178115753	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@veegvl
169	246495836	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Bagazey Roman
170	5476412994	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	$ None
171	8398121416	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	Toby Maguire
172	305699677	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@mvksm
173	1661730241	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@scarfacethe
174	6754584275	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@Zloi99
175	736130037	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@LSPD57
176	7763723697	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@tasgate17
177	75107834	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@avkona
178	6436363499	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@nneliza
179	930286429	2026-02-11 12:40:40.001561+00	2026-02-18 12:40:40.001561+00	@tlmstbs
\.


--
-- Data for Name: vpn_users; Type: TABLE DATA; Schema: public; Owner: vpn_user
--

COPY public.vpn_users (user_id, username, vpn_url, total_traffic_mb) FROM stdin;
388365301	@dradanudanay	\N	44541
5891909126	@Oleg28022	vless://16e28703-cd0f-4587-b488-92ea380f2139@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=104cd3ae38041e71#easy-xray+%F0%9F%97%BD	727
2046567335	@evabushuevaa	vless://5d89ad05-4020-4ded-90fb-17978a02a771@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=014ee832d906b2bc#easy-xray+%F0%9F%97%BD	0
5683516267	@mukhamedov_1112	vless://c478a63b-dbeb-4257-9111-a6bdfc917d90@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=f7f12f4011336539#easy-xray+%F0%9F%97%BD	0
311277386	@projectiks	vless://b30f2399-9020-4cee-8921-1c85e027739c@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=23952b12d4d90c36#easy-xray+%F0%9F%97%BD	0
950734538	@eleshka1	vless://3eb540bb-be01-45e6-86bd-bc84c20e1fd4@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=19b8a9486d699675#easy-xray+%F0%9F%97%BD	0
1772804316	@qweres11	vless://550f5ff6-da37-49b7-b82b-852993e6b1b7@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=49f44b7b72744337#easy-xray+%F0%9F%97%BD	0
1775368546	@yoaxrx	vless://f8655728-38b5-4b62-a912-fefe4db782f1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=d9ef7221c82bb5e3#easy-xray+%F0%9F%97%BD	0
86448143	@MalvinaCrunchy	\N	0
7607848299	@YoOli99	vless://94831fd3-e587-471c-9943-7e4def037dd4@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=4de685a162af9345#easy-xray+%F0%9F%97%BD	987415
244494750	@Hermanandorberg	vless://b6ad01d4-6932-476d-b0c9-b35ae6afb096@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e4d844ef0e136b30#easy-xray+%F0%9F%97%BD	0
304622290	@TEYHD	vless://6599e3a7-6fcb-4c20-bfe9-d89b64fff2ff@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=66bfc1e751d47e70#easy-xray+%F0%9F%97%BD	0
6199820078	Shohjahon None	vless://9f1032fd-7f52-42c9-8af6-3c3c0e8a87f9@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=94ffc938bb04c9a2#easy-xray+%F0%9F%97%BD	0
5502328654	@lilla_kattenn	vless://429b9aba-f489-4ee4-a07c-6e9f0f14d0f6@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=3e3395df969c8bd9#easy-xray+%F0%9F%97%BD	0
847947048	@marishkamd	vless://f926c634-1b13-433b-8dba-c93e2f5a8371@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=dff841d3f94dbb50#easy-xray+%F0%9F%97%BD	0
5123089954	Ольга Мальчёнкова	\N	0
8042009619	@Chikatishka	vless://ea62216c-77c3-4a49-a347-f4cc0b9d6caa@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=2cf225f48baae0e1#easy-xray+%F0%9F%97%BD	10
1024041782	@Amele_wk	\N	0
1663034905	Kirill None	vless://974f093d-2901-4c8e-aa4e-75c6d65fa9ef@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e88fcb84f8550e57#easy-xray+%F0%9F%97%BD	0
6479226198	Maria None	vless://713b524e-0a66-47bf-aa5c-33ad7ed0a817@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ba720c82e8a26608#easy-xray+%F0%9F%97%BD	0
393139445	@hey_ulitka	vless://9187f33e-2560-4dc9-91dd-a8fe4255b326@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=43087ec063047e63#easy-xray+%F0%9F%97%BD	0
128072094	@egorovechkin	vless://f0431e20-6d2e-464f-bfe9-4429ab992c23@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=bbb11aa07b09bff3#easy-xray+%F0%9F%97%BD	0
261259181	@wildw1	vless://350f5416-71e6-40fa-bebf-19ecc086de05@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=c26a5106ce407066#easy-xray+%F0%9F%97%BD	0
1608854638	@Varyaanon	vless://f310dd07-8875-4063-b276-4820c5f4cb6f@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=5e5e01a80c4e3840#easy-xray+%F0%9F%97%BD	0
7292120610	@ebany_po_kosmosy	vless://b44cf1f0-0126-403c-bd13-66b46d19fdd1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=CKkuOlVzpjntvFM8kXnfDwtDuOaFX7pvzbPbGxjO8zM&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=www.google.com&sid=09996aea4604af6b#easy-xray+%F0%9F%97%BD	0
7081916771	@asuyl	vless://512ad829-060e-49ff-900f-1246ba83e0aa@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=4814142950fb1e5f#easy-xray+%F0%9F%97%BD	13016
542381157	@Inskayi	vless://4d793c73-fc04-4ff0-ad3a-30ce08305ded@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ea0b4d06007bfb32#easy-xray+%F0%9F%97%BD	358444
949659892	@sspektra	vless://e850d4d1-7df2-4dfb-907b-5f560c9e1dcd@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=88c67e325be9676c#easy-xray+%F0%9F%97%BD	0
1062974048	@itssvd10	vless://cba99b19-0598-4dc5-8eb7-3627a641ccf3@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=aa08a6c674351003#easy-xray+%F0%9F%97%BD	0
324302243	@vslkov	\N	0
536383453	@Timmoxamos	vless://08b0b638-7353-41a5-bf18-16dfbb79f147@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=2202ee95ae3f3802#easy-xray+%F0%9F%97%BD	0
5182997693	@Jane_0000	vless://0f4e9a7c-cb37-44eb-a687-72e07b58a85b@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=5dc17f0d113e3bb6#easy-xray+%F0%9F%97%BD	0
1464377851	@kktvn888	vless://1fde0710-1b67-4f0a-a15e-cf8a476752f1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=2fcd6bb7ca237508#easy-xray+%F0%9F%97%BD	0
5606611599	@Shohjahon2020	vless://36fb838f-134f-4c8a-8471-d45471d4532a@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=cfb2c1b3c5bfd1b8#easy-xray+%F0%9F%97%BD	1335280
8426001290	@qweeuk1	vless://26afa211-84f4-4d27-8253-672fd664d198@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=47ed094395654035#easy-xray+%F0%9F%97%BD	308875
573437479	@BekJaan_CS	vless://aebe0a4e-ba3a-4631-b209-9ed40bbc6812@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=91cdf9af3b38e510#easy-xray+%F0%9F%97%BD	0
7224025843	@xsoexsov	vless://ea204fda-a4c9-420d-8a1a-05a800ec3ab1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=cd3d71d40d09cc15#easy-xray+%F0%9F%97%BD	0
1025134411	@justsofasafina	vless://16021b49-fb17-4f3d-a54b-30663902a198@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=b4eda5ba81aef67c#easy-xray+%F0%9F%97%BD	0
291633079	@Artdex	vless://c5d43760-9749-4cce-af61-8b9b2a7f1ac3@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=563780787393ed82#easy-xray+%F0%9F%97%BD	205932
1002403343	@Rulazail	\N	0
1618498304	@liticli	vless://ecbc7ab5-96e7-4cb3-b34a-85b42dd4c7b1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=4e979f428d73351e#easy-xray+%F0%9F%97%BD	745734
1118501605	@veramedd	\N	0
1500656262	@userneneta	\N	0
1282984042	@astepache	\N	0
313758160	@Pooh1965	\N	0
163269254	@beerbeep	vless://2da1f4d6-b57e-4c41-9eb8-f4abac385b0f@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=70302e23cea97eea#easy-xray+%F0%9F%97%BD	447386
1718721565	Игорь Климович	vless://164f9dbb-345f-4425-9421-146ead5292ec@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=7cea855bfc847de8#easy-xray+%F0%9F%97%BD	2176321
840726442	@BubblegumB1tch	vless://7adad601-c8af-4a16-a5ea-6270d5e5dc35@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=c520bc4fa9499053#easy-xray+%F0%9F%97%BD	2451969
885646283	@Daniil123456777	vless://70dbdfb0-da30-4a84-add2-cc9024c704c6@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=30eb7558394d63e3#easy-xray+%F0%9F%97%BD	94
986459529	@Takeshi_Sun79	vless://67be95dc-93fd-481f-8925-57fe2e3018ad@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=04ca6c8ccd6a3c6c#easy-xray+%F0%9F%97%BD	0
1226209785	@ne_dunduk	vless://d281d991-98dc-4993-8bde-2b19b60a712f@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=9bebf8288831d8c8#easy-xray+%F0%9F%97%BD	0
225557702	@sdc22	vless://bd23c19f-c267-4c13-be7c-d2ce832cdff3@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=66cee04bf167696c#easy-xray+%F0%9F%97%BD	0
1314267038	@alisia_ko	vless://976cd338-1f77-42af-83a6-826da14b5038@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ca5b02965d8f0b48#easy-xray+%F0%9F%97%BD	0
250025907	@thisisqwi	vless://734b2550-c772-4b42-ab18-4a45ce7a1b93@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e378ed087e1c8839#easy-xray+%F0%9F%97%BD	0
724617564	@narmadykov_d	vless://2b632556-baa2-4cbe-99f8-ccbc807e32f8@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=10e8c35a47a5429a#easy-xray+%F0%9F%97%BD	0
5575082434	@ncvxzrxxx	\N	0
252095329	@EvgenijTim	vless://6dea53cc-89c3-463e-bb94-c24461fa440c@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=a72122b6756052b4#easy-xray+%F0%9F%97%BD	595902
5198380981	ㅤㅤ𝔢𝔯𝔤 ㅤㅤ None	vless://5a5239ac-5256-41be-b956-2a60cc88396e@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=b419bbe209efdb9a#easy-xray+%F0%9F%97%BD	0
1923200166	@Serega37Rus	vless://adce2e4c-5d73-4f06-83f2-9241ff8cbef4@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=5a9e0490b6400252#easy-xray+%F0%9F%97%BD	0
812399225	@ShiningMars	vless://cd2c6d4d-b1cb-4bff-9498-9cbc532bdc9f@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=c21418958680e056#easy-xray+%F0%9F%97%BD	0
866928334	@imgoar	\N	0
494388019	@whodatandrey	vless://452e5c70-6879-415f-8ecf-658e7f4c0585@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=040e6e5db40fa768#easy-xray+%F0%9F%97%BD	0
5368556156	BOB Z	\N	0
5052384072	@deuceina42	vless://b52d3bc3-e803-40cb-9a93-3885a65676e7@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=f130ef000af838ed#easy-xray+%F0%9F%97%BD	0
628356461	@Anna_Ilintseva	vless://c223cef9-8fe8-40c3-836f-735f45f64030@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=c45ec47e0def8264#easy-xray+%F0%9F%97%BD	0
239858852	@Georgiy108	vless://d8c66af2-5fe4-4e66-af30-51cdb92f2b61@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=25a624b6e27d7244#easy-xray+%F0%9F%97%BD	0
6270280019	Марина Кононова	vless://08c8b591-a224-45c2-b3d7-e88f877382c1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=fd923d3f15e8f443#easy-xray+%F0%9F%97%BD	211264
376459793	@komrat1988	vless://581c9843-e5d5-42e2-af30-26e16e411967@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=16833cb13ec7ab12#easy-xray+%F0%9F%97%BD	0
710827583	@localwolf58	vless://9d408793-1f86-4968-a0ff-168db1d81ae0@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e0dc26f1f92e873e#easy-xray+%F0%9F%97%BD	0
290353511	@nastyankl	vless://f42ee037-33a5-4539-b578-e6b6ec029611@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=b9f35421eba295e8#easy-xray+%F0%9F%97%BD	1377569
820982175	@Deddrox	vless://f4dc0322-6ee3-4c4e-af7b-ade7f7d87b92@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=0bc275309af2c2a8#easy-xray+%F0%9F%97%BD	16146979
460458056	@the_brazen	\N	0
690253150	@dianamyazitova	vless://6549431d-cb8b-4fda-9a5e-3b86773cae70@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=6548e156e5015130#easy-xray+%F0%9F%97%BD	14513758
521515955	@leon4ik8	vless://4a35fcc7-98f6-4142-96a1-0cb413bbb5cd@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ca8091aab2d90cda#easy-xray+%F0%9F%97%BD	725134
980700322	@losilososi	\N	0
1016266204	@KononovaMarina1	vless://d7ec6f1e-a37f-4bee-b834-ca385ed7166a@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=f3ba20245b243f1f#easy-xray+%F0%9F%97%BD	2311630
7580242672	@boss_i_050	\N	0
164500456	@ivanzykov95	vless://ca72752a-4697-4fbb-bd68-ed2b1f7d9d17@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=843c7baf38cba86a#easy-xray+%F0%9F%97%BD	0
1181816030	@aceaceace00	vless://82f8be43-78ac-48df-811f-7272913016ea@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=CKkuOlVzpjntvFM8kXnfDwtDuOaFX7pvzbPbGxjO8zM&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=www.google.com&sid=8f33aa2476bff2ef#easy-xray+%F0%9F%97%BD	0
1423368104	ㅤ None	vless://aa155422-b9bc-4dc5-ad4e-5d9261611fe5@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=18ef504c690682d7#easy-xray+%F0%9F%97%BD	6842077
1373314202	🤘 None	vless://1eba5ea4-7e20-4883-b856-852d38d99221@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=34a3d43cf051c1ab#easy-xray+%F0%9F%97%BD	5331986
1075521158	@Knjagna77	vless://921b09f9-1755-4f15-98af-f708a59e42e6@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=f5a02001da2ccf2e#easy-xray+%F0%9F%97%BD	0
356683309	@catviva	vless://be9b407f-2abe-40ab-a0a3-e52d972becfb@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=654bd1734754a47e#easy-xray+%F0%9F%97%BD	19190390
1351682871	@Flansy_steals	vless://c2b89eda-f163-453a-8202-3572588f138d@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=2350cf804a0f5379#easy-xray+%F0%9F%97%BD	0
1839347986	Елена Ильинцева	vless://5b4f2e91-6b7e-466f-9cba-bbe8128efd6a@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=a91fcce3605299a4#easy-xray+%F0%9F%97%BD	602797
7735591793	@Acab70	vless://b5604dea-2148-4c9f-95fe-27a9f73366ce@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ecf2c1566b5e1264#easy-xray+%F0%9F%97%BD	0
7108317408	@aaandrey23	vless://8a144e15-6d78-4577-a29c-14f4a7ad4eae@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=c40d8b4c9eba7983#easy-xray+%F0%9F%97%BD	0
67154323	@turbouzback	\N	0
1409792980	@girichev	\N	0
844004608	Aleks None	\N	0
6397181042	Bro&N None	\N	0
581094500	@Kul4ivan	vless://b4fe8b93-2845-4ab2-950a-53105ca1ae2e@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=8afb0ae0738728f8#easy-xray+%F0%9F%97%BD	3045628
6503212990	Andrey None	vless://f670c1fa-9f19-4338-9dd7-750224aa5f6f@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=bf5dc46c5c689855#easy-xray+%F0%9F%97%BD	62782
264778762	@GuiIIermO_o	vless://59166740-6481-4bc7-a008-6ae3898a9dbc@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=d4272cc53c26ccec#easy-xray+%F0%9F%97%BD	2146
840175771	@dynomake	\N	0
6885239750	ᅠᅠᅠᅠ None	vless://34db52e4-69da-40db-8dd2-301e878eb9b5@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=15d974a2170fd5c7#easy-xray+%F0%9F%97%BD	7309928
5120498314	Oleg None	vless://2963cb10-b1ea-4a29-87f2-63a359e032c7@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=a68dac5591d33edd#easy-xray+%F0%9F%97%BD	0
1759062324	@VladimirChernyshev1	vless://c9c84848-d832-4b45-beff-58558ff52b62@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=c5f0f33b0ec3fef2#easy-xray+%F0%9F%97%BD	0
845451513	@bmo52	vless://f6eca380-afda-4041-ae17-216fa1fe3ff6@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=235605a724b2bc10#easy-xray+%F0%9F%97%BD	0
7185901263	Маргарита None	vless://2e5ed7d6-f78f-4e0a-a827-dc8542284a81@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=310a27fa5adbac23#easy-xray+%F0%9F%97%BD	0
1728812699	Bright Agbali	\N	0
834622116	@EgorMIX2024	\N	0
1219789072	@Anna_2106	vless://14fdb7a5-f1a3-4356-a10f-7eb98b2031c0@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e37b7d0d26e3c3ae#easy-xray+%F0%9F%97%BD	0
1299669079	@Skarlat13	vless://4e380773-dee7-447d-8afa-dea0b53ee72c@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=7d68546442131850#easy-xray+%F0%9F%97%BD	0
294996566	@Heyx0	\N	0
6352363131	@xpos587	vless://36fbbc86-0a31-444a-a2ea-98bad657e626@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=CKkuOlVzpjntvFM8kXnfDwtDuOaFX7pvzbPbGxjO8zM&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=www.google.com&sid=57f133876d5e2f1a#easy-xray+%F0%9F%97%BD	0
6697904384	@k0tebayun	vless://5f714cf8-42ce-4756-9f5d-fce0bde66112@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=57fa2e0108fda218#easy-xray+%F0%9F%97%BD	0
1754633400	@kivpa	vless://9bbf065f-6ad5-46dc-87c8-41189d392017@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=dcfb2ec0417eaf32#easy-xray+%F0%9F%97%BD	478137
5193682399	Максим Коленкин	vless://9af84ab0-7f88-4bfd-8816-5e806c796148@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=edfc8e087235ace2#easy-xray+%F0%9F%97%BD	1901438
373120282	@VadikKirli	vless://316a8211-9ca2-4fe2-aef0-90f715502947@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=3c25689bad3d6c2a#easy-xray+%F0%9F%97%BD	416
246259999	@RandySandy	vless://e3a5f944-6672-4d9f-ba86-7f03eefec13c@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=4c2edba93df825e5#easy-xray+%F0%9F%97%BD	82467
636043501	@nkaumov42	vless://e44e3e92-6d82-4a6d-b5c4-9fe6bdd82845@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=7c67ce8065d2a2a7#easy-xray+%F0%9F%97%BD	14818
1612492468	@Sofia_1s1o1	vless://e163d9e9-2d81-45af-9a60-142cd351e4e3@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=8c55b3b8db072781#easy-xray+%F0%9F%97%BD	0
6935872017	@BD_TON	vless://35b50639-6d41-4a4a-91b0-85de9a352bb7@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=988a9aae4780d1fb#easy-xray+%F0%9F%97%BD	8838132
164125396	@iAmRuslan	vless://93623766-4596-44b4-a6f9-5f0c96727b57@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=34f1d42eddc8ebf2#easy-xray+%F0%9F%97%BD	1810015
6278876591	@Bula_228	\N	0
178115753	@veegvl	vless://e1c488e0-da2c-412b-b0eb-708c0e9139ce@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=9bf085f64fdb3453#easy-xray+%F0%9F%97%BD	0
246495836	Bagazey Roman	\N	0
1661730241	@scarfacethe	vless://efd138fd-98b9-457e-b8bd-c26943a87327@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=6bc187f34eb48830#easy-xray+%F0%9F%97%BD	28478804
5476412994	$ None	\N	0
8398121416	Toby Maguire	\N	0
305699677	@mvksm	vless://4de8a783-2af0-40a2-916d-452d175b03e1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=155a56ad6ab4a9ff#easy-xray+%F0%9F%97%BD	0
6754584275	@Zloi99	vless://bba85174-08a5-4632-b630-11d33f3eb799@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=7fcc7b5c9bfd14fa#easy-xray+%F0%9F%97%BD	0
736130037	@LSPD57	vless://d6a72b82-37a3-46f8-8563-f19bda56744c@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=94e1a77bfbf20fe2#easy-xray+%F0%9F%97%BD	0
7763723697	@tasgate17	vless://15dd3523-3207-4eab-868d-fc4573ca940b@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=70da7630cfe819f2#easy-xray+%F0%9F%97%BD	0
75107834	@avkona	vless://a298aba3-dde4-49c1-a87f-2fe7a5fe66b0@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ce38e8fad8f36013#easy-xray+%F0%9F%97%BD	0
6436363499	@nneliza	vless://6d3eb1dc-4a35-4e8b-922d-14cee2390797@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=633b1bb5170a7fd6#easy-xray+%F0%9F%97%BD	0
930286429	@tlmstbs	vless://394836fb-daaa-46d7-8794-3ca1f9255fed@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=f2f65d7692b0c55d#easy-xray+%F0%9F%97%BD	534256
6116982433	@ghost_case	vless://e5facc7d-3b84-4274-b1ac-995b814c84f9@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=b6241a6e8825b2cf#easy-xray+%F0%9F%97%BD	60
888782677	@yatjjwnaka	vless://fb71d11c-8fd3-479f-8413-22a07de66d31@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=f7a4d6a8d776b1e4#easy-xray+%F0%9F%97%BD	108986
1394294038	@pahom4kit	vless://ee895bfb-449c-4228-b0ce-b1dca1de782e@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=abffd90f16d2b62f#easy-xray+%F0%9F%97%BD	25048533
950416192	@Shamsheva_SK	vless://6dc51f9d-4d97-43fb-bf04-4e97208b86f7@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=66eeb4e18edfd660#easy-xray+%F0%9F%97%BD	1371011
392688348	efg None	vless://610c7303-dc73-4472-9b5a-05f82e1b62cd@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=116214984ce630fb#easy-xray+%F0%9F%97%BD	0
6563976046	@Paravozik6	vless://34f428db-5fb8-4fc6-ae10-06530d6bae16@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=736295f5bed25133#easy-xray+%F0%9F%97%BD	0
545804557	@davasilev	vless://153c2ccc-7901-4e98-b4e5-fce3ec34f6e8@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=b3738d1ef028aac9#easy-xray+%F0%9F%97%BD	1886089
992855339	@Nataliia2704	vless://6ef37e2a-30f1-45f2-82a7-f71bf8bddc85@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=b15909f3b682b92d#easy-xray+%F0%9F%97%BD	0
742733035	@s4ad0wq	vless://896e5f5e-2529-44ec-8866-2d2df7373962@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=44468a23dc1e0c31#easy-xray+%F0%9F%97%BD	0
1300362005	@lenchicsss_official	vless://93fae2b1-96c4-448e-984d-2b586aa7f614@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=2ed5726bfd30693e#easy-xray+%F0%9F%97%BD	0
7832719668	SankiOr None	vless://e4da9933-d96f-4211-9b6c-efdc4c5cf2d6@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=70a45e15d2459ee5#easy-xray+%F0%9F%97%BD	3198339
1422345231	@VladimirSeyranyan	\N	0
744100716	@sejurovno	vless://37e10ee9-f9c7-44f0-a0ec-01d78d489b89@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=710f1862fa57b194#easy-xray+%F0%9F%97%BD	1041751
986330835	@alien_krew	vless://dfae2e13-bc79-4cc7-ab97-32876ab74133@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=536549d7cfa6759b#easy-xray+%F0%9F%97%BD	1628
347780570	Andrey None	vless://29bce356-e60d-4cc2-9289-0b674ed09b65@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=6e3a6e0847710145#easy-xray+%F0%9F%97%BD	0
137250251	@arkaram	vless://7643ddea-a51b-4c4e-9d3b-582c336853ff@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=0efaa9f73aa47352#easy-xray+%F0%9F%97%BD	10792
7327494579	@gonnahatehaters	vless://34940d7b-6791-40da-a383-25469da6ac1e@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=6e33cf727c3ff12a#easy-xray+%F0%9F%97%BD	0
6769800017	@muurmeooww	vless://90fa6223-2773-4e59-9901-ab7983374a5d@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=3250b86976d19b1f#easy-xray+%F0%9F%97%BD	0
8327977462	@b4b_manager	vless://105cdbaa-280c-49e4-aecf-08c8fcf4da20@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=1053364568b7c7eb#easy-xray+%F0%9F%97%BD	0
562579515	@ksssuvv	vless://959dd781-9af1-4c66-91a9-2cb175cdb0fb@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e03a83b7ed76a5c6#easy-xray+%F0%9F%97%BD	0
1613216767	@andronnikov6	vless://e39d7bd3-1580-48f0-a272-961831207a16@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=CKkuOlVzpjntvFM8kXnfDwtDuOaFX7pvzbPbGxjO8zM&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=www.google.com&sid=47589c59d5a51c69#easy-xray+%F0%9F%97%BD	0
6034373572	I None	vless://1b4c5e4f-535c-45af-8ec1-6125b83bb0e3@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=53f78ff37fc3ff9d#easy-xray+%F0%9F%97%BD	2064
7861168706	Аброр Сайдуллаев	\N	0
5487588531	@vlinchco	vless://0f4327dc-6297-4718-9196-9c172d2ae1cd@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=74fb5f90066e5b05#easy-xray+%F0%9F%97%BD	0
890999417	@kirill_s_gavr	vless://9c62a64e-2cbe-4c7a-a6a8-dd60b7c69a03@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=becb05453e4d83d0#easy-xray+%F0%9F%97%BD	0
1986228881	@neon4on	vless://75677ff3-7e93-4389-bf16-1a15d684bc2b@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=c373e325cceba74f#easy-xray+%F0%9F%97%BD	1199844
502088930	@shepelev0	vless://f70d265e-75d4-413a-a906-94a57dfec4c4@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e6acdccaf732a6c9#easy-xray+%F0%9F%97%BD	0
822315669	@annnastasssi	vless://6621c507-35fe-43ee-95ca-7623534c82f0@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=0f6599f05e0d51dd#easy-xray+%F0%9F%97%BD	2071862
5746022064	­­ None	vless://4170a10e-d078-4769-8784-ff44cf505e51@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ad614abc0f552b8d#easy-xray+%F0%9F%97%BD	100383
1262104118	@Maximvasilenkoofficia	vless://fbc251fb-03d2-47c5-afc6-1ed7e55aac90@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=1f730ffdfa11dec6#easy-xray+%F0%9F%97%BD	0
941457535	@sickyet	vless://fb962fc2-5d46-4f38-9365-140d9ca0ffb7@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=a339b83bd31a6137#easy-xray+%F0%9F%97%BD	0
5108798186	@LeoYurii	vless://32d96fe6-7fc2-48ef-94c6-96863ed874e3@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=eead06e69f95ed3f#easy-xray+%F0%9F%97%BD	0
5438631219	@ghinzburger	vless://9f2ab9be-d407-48d9-ab92-626379b74faf@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=954a0ee430c3c906#easy-xray+%F0%9F%97%BD	14598369
201222293	Андрей Андреев	vless://c3790612-3b08-4eec-8bd1-287cc297ad72@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=276313f3c008487a#easy-xray+%F0%9F%97%BD	1541730
7050134748	@sega_user	vless://ef88b3f8-162b-4a26-b892-8206f9a75d16@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=ca4388342d5d768c#easy-xray+%F0%9F%97%BD	0
952743010	@notvladislv	vless://5ba774e2-e53d-4d78-b641-d356bcd6f6a8@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=e4193c1253ddee99#easy-xray+%F0%9F%97%BD	0
7305328673	@wannilly	vless://49e5080a-8520-4a40-a5be-183043366dec@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=1197a42dbaf9949c#easy-xray+%F0%9F%97%BD	0
122814347	@JAGAT_Om	vless://28ab9d8d-227e-4e86-9e30-d13e5e80cd25@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=9c226ff8220f2244#easy-xray+%F0%9F%97%BD	0
781408462	@lalia_am	vless://03e2f5f0-a62f-47a5-837e-6fd07613403f@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=3d63b0b262b096a8#easy-xray+%F0%9F%97%BD	0
269117976	@HalfLennelluc	vless://bd09c99a-4d70-475d-a461-925bb2410ec0@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=08491d58844475df#easy-xray+%F0%9F%97%BD	6787242
365576584	@Kim_Kauf	vless://dccde961-1e51-4380-bd25-8061d6884ba7@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=957226d7b00427ad#easy-xray+%F0%9F%97%BD	1148713
395669555	@annaeffe26	vless://11f5e077-28a8-4bad-b9c0-693fb0337395@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=73ff0a47dc7693e3#easy-xray+%F0%9F%97%BD	10893386
201596660	@NickKitovsky	vless://862bbe2e-c3a3-4538-bd9a-654830c4edaf@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=21646792a9149783#easy-xray+%F0%9F%97%BD	0
401676402	@a_garkier	vless://2d7d0553-2b22-48f9-8c79-066b61c449d5@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=3ac8fefbb2848521#easy-xray+%F0%9F%97%BD	668896
5228093595	@ottyanak	vless://c95ad39d-3a90-4116-8cf6-3b588e31874b@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=0185f4b141a94c3d#easy-xray+%F0%9F%97%BD	0
655010957	@BeKoH183	vless://82871449-b09e-44b8-8a9a-165df5f42c92@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=827203eb248e213d#easy-xray+%F0%9F%97%BD	0
400189677	@md_chewbacca	vless://87fda638-7b4c-4bf2-a696-5b408d3a49af@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=3c3d4ba0d22695e0#easy-xray+%F0%9F%97%BD	0
542056003	@edvirado	vless://9cfbf613-e9ff-4746-9aba-75de1d6473d8@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=9b4d008cf7736ff2#easy-xray+%F0%9F%97%BD	27616167
1382441870	Evgeniy Gordeev	vless://13f0a07e-050f-419a-a81c-7a78b690ea5c@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=3c97ef2158777c84#easy-xray+%F0%9F%97%BD	421862
1761463830	@Ivanjordan1	vless://f535d957-91f0-4add-9874-3443204cd5e1@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=b8149eb872604730#easy-xray+%F0%9F%97%BD	4817255
1053258958	@pirihha	vless://55498ec5-7697-4719-a12e-077a58581588@194.48.142.252:443?fragment=&security=reality&encryption=none&pbk=QClt1YR1Wt-eheQ3B0EDu2HqTMbpZBaw_Dp-ZhQi1lg&fp=chrome&type=tcp&flow=xtls-rprx-vision-udp443&sni=duckduckgo.com&sid=f76cac9a7466e67a#easy-xray+%F0%9F%97%BD	419245
\.


--
-- Name: routing_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vpn_user
--

SELECT pg_catalog.setval('public.routing_usage_id_seq', 1, false);


--
-- Name: vpn_subs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vpn_user
--

SELECT pg_catalog.setval('public.vpn_subs_id_seq', 179, true);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: vpn_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: routing_usage routing_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: vpn_user
--

ALTER TABLE ONLY public.routing_usage
    ADD CONSTRAINT routing_usage_pkey PRIMARY KEY (id);


--
-- Name: vpn_subs vpn_subs_pkey; Type: CONSTRAINT; Schema: public; Owner: vpn_user
--

ALTER TABLE ONLY public.vpn_subs
    ADD CONSTRAINT vpn_subs_pkey PRIMARY KEY (id);


--
-- Name: vpn_users vpn_users_pkey; Type: CONSTRAINT; Schema: public; Owner: vpn_user
--

ALTER TABLE ONLY public.vpn_users
    ADD CONSTRAINT vpn_users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_routing_usage_user_id; Type: INDEX; Schema: public; Owner: vpn_user
--

CREATE INDEX idx_routing_usage_user_id ON public.routing_usage USING btree (user_id);


--
-- Name: idx_vpn_subs_date_end; Type: INDEX; Schema: public; Owner: vpn_user
--

CREATE INDEX idx_vpn_subs_date_end ON public.vpn_subs USING btree (date_end);


--
-- Name: idx_vpn_subs_user_id; Type: INDEX; Schema: public; Owner: vpn_user
--

CREATE INDEX idx_vpn_subs_user_id ON public.vpn_subs USING btree (user_id);


--
-- PostgreSQL database dump complete
--

\unrestrict QK79zDq4AmViIsHbjpOggAKZmaGwpedNwHJGgEfigj8S6giQgIsHIrhG36NKXZw

