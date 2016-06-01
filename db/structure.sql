--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: data_dumps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE data_dumps (
    id integer NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: data_dumps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE data_dumps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_dumps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE data_dumps_id_seq OWNED BY data_dumps.id;


--
-- Name: issue_assignments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE issue_assignments (
    id integer NOT NULL,
    issue_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    repo_subscription_id integer,
    clicked boolean DEFAULT false,
    delivered boolean DEFAULT false
);


--
-- Name: issue_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issue_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issue_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issue_assignments_id_seq OWNED BY issue_assignments.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE issues (
    id integer NOT NULL,
    comment_count integer,
    url character varying(255),
    repo_name character varying(255),
    user_name character varying(255),
    last_touched_at timestamp without time zone,
    number integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    repo_id integer,
    title character varying(255),
    html_url character varying(255),
    state character varying(255),
    pr_attached boolean DEFAULT false
);


--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issues_id_seq OWNED BY issues.id;


--
-- Name: opro_auth_grants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE opro_auth_grants (
    id integer NOT NULL,
    code character varying(255),
    access_token character varying(255),
    refresh_token character varying(255),
    permissions text,
    access_token_expires_at timestamp without time zone,
    user_id integer,
    application_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: opro_auth_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE opro_auth_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opro_auth_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE opro_auth_grants_id_seq OWNED BY opro_auth_grants.id;


--
-- Name: opro_client_apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE opro_client_apps (
    id integer NOT NULL,
    name character varying(255),
    app_id character varying(255),
    app_secret character varying(255),
    permissions text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: opro_client_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE opro_client_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opro_client_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE opro_client_apps_id_seq OWNED BY opro_client_apps.id;


--
-- Name: repo_subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE repo_subscriptions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    repo_id integer,
    last_sent_at timestamp without time zone,
    email_limit integer DEFAULT 1
);


--
-- Name: repo_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repo_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repo_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repo_subscriptions_id_seq OWNED BY repo_subscriptions.id;


--
-- Name: repos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE repos (
    id integer NOT NULL,
    name character varying(255),
    user_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    issues_count integer DEFAULT 0 NOT NULL,
    language character varying(255),
    description character varying(255),
    full_name character varying(255),
    notes text,
    github_error_msg text
);


--
-- Name: repos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repos_id_seq OWNED BY repos.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    zip character varying(255),
    phone_number character varying(255),
    twitter boolean,
    github character varying(255),
    github_access_token character varying(255),
    admin boolean,
    name character varying(255),
    avatar_url character varying(255) DEFAULT 'http://gravatar.com/avatar/default'::character varying,
    private boolean DEFAULT false,
    favorite_languages character varying[],
    daily_issue_limit integer,
    skip_issues_with_pr boolean DEFAULT false,
    account_delete_token character varying(255),
    last_clicked_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_dumps ALTER COLUMN id SET DEFAULT nextval('data_dumps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_assignments ALTER COLUMN id SET DEFAULT nextval('issue_assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issues ALTER COLUMN id SET DEFAULT nextval('issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY opro_auth_grants ALTER COLUMN id SET DEFAULT nextval('opro_auth_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY opro_client_apps ALTER COLUMN id SET DEFAULT nextval('opro_client_apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repo_subscriptions ALTER COLUMN id SET DEFAULT nextval('repo_subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repos ALTER COLUMN id SET DEFAULT nextval('repos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: data_dumps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY data_dumps
    ADD CONSTRAINT data_dumps_pkey PRIMARY KEY (id);


--
-- Name: issue_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY issue_assignments
    ADD CONSTRAINT issue_assignments_pkey PRIMARY KEY (id);


--
-- Name: issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: opro_auth_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY opro_auth_grants
    ADD CONSTRAINT opro_auth_grants_pkey PRIMARY KEY (id);


--
-- Name: opro_client_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY opro_client_apps
    ADD CONSTRAINT opro_client_apps_pkey PRIMARY KEY (id);


--
-- Name: repo_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repo_subscriptions
    ADD CONSTRAINT repo_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: repos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repos
    ADD CONSTRAINT repos_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_issue_assignments_on_delivered; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_issue_assignments_on_delivered ON issue_assignments USING btree (delivered);


--
-- Name: index_issues_on_number; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_issues_on_number ON issues USING btree (number);


--
-- Name: index_issues_on_repo_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_issues_on_repo_id ON issues USING btree (repo_id);


--
-- Name: index_issues_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_issues_on_state ON issues USING btree (state);


--
-- Name: index_users_on_account_delete_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_account_delete_token ON users USING btree (account_delete_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_github; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_github ON users USING btree (github);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20120222223509');

INSERT INTO schema_migrations (version) VALUES ('20120222231841');

INSERT INTO schema_migrations (version) VALUES ('20120518083745');

INSERT INTO schema_migrations (version) VALUES ('20120518085406');

INSERT INTO schema_migrations (version) VALUES ('20120518090213');

INSERT INTO schema_migrations (version) VALUES ('20120518091140');

INSERT INTO schema_migrations (version) VALUES ('20120620000230');

INSERT INTO schema_migrations (version) VALUES ('20120622203236');

INSERT INTO schema_migrations (version) VALUES ('20120622233057');

INSERT INTO schema_migrations (version) VALUES ('20120622235822');

INSERT INTO schema_migrations (version) VALUES ('20120624204958');

INSERT INTO schema_migrations (version) VALUES ('20120624212352');

INSERT INTO schema_migrations (version) VALUES ('20120624213335');

INSERT INTO schema_migrations (version) VALUES ('20120627213051');

INSERT INTO schema_migrations (version) VALUES ('20120707182259');

INSERT INTO schema_migrations (version) VALUES ('20121106072214');

INSERT INTO schema_migrations (version) VALUES ('20121110213717');

INSERT INTO schema_migrations (version) VALUES ('20121112100015');

INSERT INTO schema_migrations (version) VALUES ('20121120203919');

INSERT INTO schema_migrations (version) VALUES ('20121127163516');

INSERT INTO schema_migrations (version) VALUES ('20121127171308');

INSERT INTO schema_migrations (version) VALUES ('20121128162942');

INSERT INTO schema_migrations (version) VALUES ('20130222201747');

INSERT INTO schema_migrations (version) VALUES ('20130312023533');

INSERT INTO schema_migrations (version) VALUES ('20130503183402');

INSERT INTO schema_migrations (version) VALUES ('20130803144944');

INSERT INTO schema_migrations (version) VALUES ('20130918055659');

INSERT INTO schema_migrations (version) VALUES ('20130918060600');

INSERT INTO schema_migrations (version) VALUES ('20131107042958');

INSERT INTO schema_migrations (version) VALUES ('20140524120051');

INSERT INTO schema_migrations (version) VALUES ('20140621155109');

INSERT INTO schema_migrations (version) VALUES ('20140710161559');

INSERT INTO schema_migrations (version) VALUES ('20140710164307');

INSERT INTO schema_migrations (version) VALUES ('20150629002651');

INSERT INTO schema_migrations (version) VALUES ('20150629010617');

INSERT INTO schema_migrations (version) VALUES ('20151007212330');

INSERT INTO schema_migrations (version) VALUES ('20151021160718');

