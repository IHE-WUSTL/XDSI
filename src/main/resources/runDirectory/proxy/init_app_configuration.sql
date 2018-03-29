--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: app_configuration; Type: TABLE; Schema: public; Owner: gazelle; Tablespace: 
--

CREATE TABLE app_configuration (
    id integer NOT NULL,
    value character varying(255),
    variable character varying(255)
);


ALTER TABLE public.app_configuration OWNER TO gazelle;

--
-- Data for Name: app_configuration; Type: TABLE DATA; Schema: public; Owner: gazelle
--

COPY app_configuration (id, value, variable) FROM stdin;
8	51.254.184.57	proxy_ip_addresses
5	http://gazelle.ihe.net/jira/browse/PROXY#selectedTab=com.atlassian.jira.plugin.system.project%3Achangelog-panel	application_release_notes_url
6	http://gazelle.ihe.net/content/proxy-0	application_documentation
7	http://gazelle.ihe.net/jira/browse/PROXY	application_issue_tracker
10	10100	min_proxy_port
11	11000	max_proxy_port
12	Europe/Paris	time_zone
16	false	ip_login
17	.*	ip_login_admin
15	2.16.840.1.113883.2.8.3.6	proxy_oid
13	http://gazelle.interopsante.org/proxy	application_url
14	http://gazelle.interopsante.org/cas	cas_url
4	true	application_works_without_cas
1	http://gazelle.ihe.net/EVSClient	evs_client_url
2	/opt/xdsi/proxy/storage/DICOM	storage_dicom
\.


--
-- Name: app_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: gazelle; Tablespace: 
--

ALTER TABLE ONLY app_configuration
    ADD CONSTRAINT app_configuration_pkey PRIMARY KEY (id);


--
-- Name: app_configuration_variable_unq; Type: CONSTRAINT; Schema: public; Owner: gazelle; Tablespace: 
--

ALTER TABLE ONLY app_configuration
    ADD CONSTRAINT app_configuration_variable_unq UNIQUE (variable);


--
-- PostgreSQL database dump complete
--

