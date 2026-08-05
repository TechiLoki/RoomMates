--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Debian 17.2-1.pgdg120+1)
-- Dumped by pg_dump version 17.2 (Debian 17.2-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO postgres;

--
-- Name: jwt_core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA jwt_core;


ALTER SCHEMA jwt_core OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA jwt_core;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA jwt_core;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: food_preference; Type: TYPE; Schema: jwt_core; Owner: postgres
--

CREATE TYPE jwt_core.food_preference AS ENUM (
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan'
);


ALTER TYPE jwt_core.food_preference OWNER TO postgres;

--
-- Name: gender; Type: TYPE; Schema: jwt_core; Owner: postgres
--

CREATE TYPE jwt_core.gender AS ENUM (
    'Male',
    'Female',
    'Other'
);


ALTER TYPE jwt_core.gender OWNER TO postgres;

--
-- Name: party_habits; Type: TYPE; Schema: jwt_core; Owner: postgres
--

CREATE TYPE jwt_core.party_habits AS ENUM (
    'Occasionally',
    'Frequently',
    'Never'
);


ALTER TYPE jwt_core.party_habits OWNER TO postgres;

--
-- Name: pets; Type: TYPE; Schema: jwt_core; Owner: postgres
--

CREATE TYPE jwt_core.pets AS ENUM (
    'Yes',
    'No'
);


ALTER TYPE jwt_core.pets OWNER TO postgres;

--
-- Name: smoking; Type: TYPE; Schema: jwt_core; Owner: postgres
--

CREATE TYPE jwt_core.smoking AS ENUM (
    'Non-Smoker',
    'Smoker'
);


ALTER TYPE jwt_core.smoking OWNER TO postgres;

--
-- Name: add_user(text, text, text, text, text, text, jwt_core.gender, numeric, text, jwt_core.smoking, jwt_core.pets, jwt_core.party_habits, jwt_core.food_preference); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.add_user(user_name text, user_email text, user_mobile text, user_role text, user_bio text, user_nationality text, user_gender jwt_core.gender, user_age numeric, user_password text, smoking jwt_core.smoking, pets jwt_core.pets, party_habits jwt_core.party_habits, food_preference jwt_core.food_preference) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		countvar INT;
		user_token JSONB;
		added_user_info JSONB;
		response JSON;
	BEGIN
		


	-- checking if email is taken
		SELECT COUNT(*) INTO countvar
	    	FROM jwt_core.users
	    	WHERE email = user_email;

	    IF countvar > 0 THEN
	        RAISE EXCEPTION 'email is taken';
	    END IF;


	-- checking if mobile is taken
		SELECT COUNT(*) INTO countvar
	    	FROM jwt_core.users
	    	WHERE mobile = user_mobile;

		IF countvar > 0 THEN
			RAISE EXCEPTION 'mobile is taken';
	    END IF;
	
	-- adding user if everything is fine
	-- we are not currently checking info validity 
	    added_user_info := jwt_core.add_user(user_name, user_email, user_mobile, 
								user_role, user_bio, user_nationality, 
								user_gender, user_age, user_password);

		PERFORM jwt_core.add_about_user((added_user_info ->> 'userid')::UUID, smoking, pets, party_habits, food_preference);

	-- generating jwt for the user
		user_token := jwt_core.generate_jwt(added_user_info ->> 'userid');

		RETURN json_build_object('jwt', user_token ->> 'jwt',
								 'pfp_id', added_user_info ->> 'pfp_id');
	END;
$$;


ALTER FUNCTION api.add_user(user_name text, user_email text, user_mobile text, user_role text, user_bio text, user_nationality text, user_gender jwt_core.gender, user_age numeric, user_password text, smoking jwt_core.smoking, pets jwt_core.pets, party_habits jwt_core.party_habits, food_preference jwt_core.food_preference) OWNER TO postgres;

--
-- Name: debug_headers(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.debug_headers() RETURNS text
    LANGUAGE plpgsql
    AS $$
	BEGIN
		return current_setting('request.headers', TRUE)::JSON;
	END;
$$;


ALTER FUNCTION api.debug_headers() OWNER TO postgres;

--
-- Name: delete_user(text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.delete_user(user_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		hashed_pass TEXT;
		uid TEXT;
	BEGIN
		PERFORM delete_about_user(); -- this only happens if delete_user is successful so no check needed	
		PERFORM jwt_core.delete_user(user_password);
		RETURN;
	END;
$$;


ALTER FUNCTION api.delete_user(user_password text) OWNER TO postgres;

--
-- Name: get_user_info(text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.get_user_info(user_id text DEFAULT NULL::text) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		json_response JSONB;
		userid TEXT;
	BEGIN	
		IF jwt_core.extract_token_from_jwt() IS NULL THEN
			RAISE EXCEPTION 'no jwt provided';
		ELSEIF user_id IS NULL THEN
			userid := jwt_core.extract_payload_from_jwt()->>'uid';
		ELSE 
			userid := user_id;
		END IF;

		json_response := jwt_core.get_user_info(userid::UUID)::JSONB || jwt_core.get_about_user(userid::UUID);
--		json_response := json_response || jwt_core.get_about_user(userid::UUID);

		RETURN json_response;
	END;
$$;


ALTER FUNCTION api.get_user_info(user_id text) OWNER TO postgres;

--
-- Name: login(text, text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.login(user_email text, user_password text) RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN

		RETURN jwt_core.login(user_email, user_password);

	END;
$$;


ALTER FUNCTION api.login(user_email text, user_password text) OWNER TO postgres;

--
-- Name: nginx_auth(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.nginx_auth() RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		user_token TEXT;
		signature_verified boolean;
	BEGIN
		user_token := jwt_core.extract_token_from_jwt();
		
		IF user_token IS NULL OR user_token = '' THEN
			RAISE EXCEPTION 'JWT is null';
		END IF;
		
		SELECT valid INTO signature_verified
			FROM verify(user_token, jwt_core.secret());

		IF signature_verified IS NOT TRUE THEN
			RAISE SQLSTATE '0L000'
				USING HINT = 'this token has invalid signature';
		END IF;	
		
		RETURN;
	END;
$$;


ALTER FUNCTION api.nginx_auth() OWNER TO postgres;

--
-- Name: test_endpoint(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.test_endpoint() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN json_build_object('auth_status', 'alive'); 
	END;
$$;


ALTER FUNCTION api.test_endpoint() OWNER TO postgres;

--
-- Name: update_about_user(jwt_core.smoking, jwt_core.pets, jwt_core.party_habits, jwt_core.food_preference); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.update_about_user(smoking_change jwt_core.smoking DEFAULT NULL::jwt_core.smoking, pets_change jwt_core.pets DEFAULT NULL::jwt_core.pets, party_habits_change jwt_core.party_habits DEFAULT NULL::jwt_core.party_habits, food_preference_change jwt_core.food_preference DEFAULT NULL::jwt_core.food_preference) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		PERFORM jwt_core.update_about_user(smoking_change, pets_change, party_habits_change, food_preference_change);
		RETURN;
	END;
$$;


ALTER FUNCTION api.update_about_user(smoking_change jwt_core.smoking, pets_change jwt_core.pets, party_habits_change jwt_core.party_habits, food_preference_change jwt_core.food_preference) OWNER TO postgres;

--
-- Name: update_password(text, text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.update_password(old_password text, new_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE 
		tempvar TEXT;
		userid TEXT;
	BEGIN
		PERFORM jwt_core.update_password(old_password, new_password);
		RETURN;
	END;
$$;


ALTER FUNCTION api.update_password(old_password text, new_password text) OWNER TO postgres;

--
-- Name: update_user_info(text, text, text, text, text, text, jwt_core.gender, numeric, text); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.update_user_info(user_name_change text DEFAULT NULL::text, user_email_change text DEFAULT NULL::text, user_mobile_change text DEFAULT NULL::text, user_role_change text DEFAULT NULL::text, user_bio_change text DEFAULT NULL::text, user_nationality_change text DEFAULT NULL::text, user_gender_change jwt_core.gender DEFAULT NULL::jwt_core.gender, user_age_change numeric DEFAULT NULL::numeric, pfp_id_change text DEFAULT NULL::text) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE 
		response TEXT;
	BEGIN
	-- here should be all of the checking procedures

		response := jwt_core.update_user_info(user_name_change, user_email_change, user_mobile_change, user_role_change, 
									user_bio_change, user_nationality_change, user_gender_change, user_age_change, pfp_id_change);

		RETURN response;
	END;
$$;


ALTER FUNCTION api.update_user_info(user_name_change text, user_email_change text, user_mobile_change text, user_role_change text, user_bio_change text, user_nationality_change text, user_gender_change jwt_core.gender, user_age_change numeric, pfp_id_change text) OWNER TO postgres;

--
-- Name: add_about_user(uuid, jwt_core.smoking, jwt_core.pets, jwt_core.party_habits, jwt_core.food_preference); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.add_about_user(uid uuid, smoking jwt_core.smoking, pets jwt_core.pets, party_habits jwt_core.party_habits, food_preference jwt_core.food_preference) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO jwt_core.about_user(user_id, smoking, pets, party_habits, food_preference)
								VALUES (uid, smoking, pets, party_habits, food_preference);
		RETURN;	
	END;
$$;


ALTER FUNCTION jwt_core.add_about_user(uid uuid, smoking jwt_core.smoking, pets jwt_core.pets, party_habits jwt_core.party_habits, food_preference jwt_core.food_preference) OWNER TO postgres;

--
-- Name: add_user(text, text, text, text, text, text, jwt_core.gender, numeric, text); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.add_user(user_name text, user_email text, user_mobile text, user_role text, user_bio text, user_nationality text, user_gender jwt_core.gender, user_age numeric, user_password text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
	DECLARE
		random_uuid UUID;
		default_image_link TEXT;
	BEGIN
--		default_image_link := 'test/link/to/the.file';
	-- pfp storing needs to be done
		default_image_link = gen_random_uuid();
		random_uuid := gen_random_uuid();
		user_password := crypt(user_password, gen_salt('bf'));

		INSERT INTO users (user_id, name, email, mobile, role_id, profile_picture_url, 
							created_at, last_active, bio, nationality, age, gender, password_hash)
		VALUES (random_uuid, user_name, user_email, user_mobile, user_role, default_image_link, 
							NOW(), NOW(), user_bio, user_nationality, user_age, user_gender, user_password); 
		
		RETURN json_build_object('userid', random_uuid,
								 'pfp_id', default_image_link)::JSONB;		

	END;
$$;


ALTER FUNCTION jwt_core.add_user(user_name text, user_email text, user_mobile text, user_role text, user_bio text, user_nationality text, user_gender jwt_core.gender, user_age numeric, user_password text) OWNER TO postgres;

--
-- Name: delete_about_user(); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.delete_about_user() RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM jwt_core.about_user
			WHERE user_id::TEXT = jwt_core.extract_payload_from_jwt() ->> 'uid';
		RETURN;
	END;
$$;


ALTER FUNCTION jwt_core.delete_about_user() OWNER TO postgres;

--
-- Name: delete_user(text); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.delete_user(user_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		hashed_pass TEXT;
		uid TEXT;
	BEGIN
		--user provides password as a confirmation
		
		uid := jwt_core.extract_payload_from_jwt() ->> 'uid';

		SELECT password_hash INTO hashed_pass
			FROM jwt_core.users WHERE user_id::TEXT = uid;

		IF hashed_pass IS NULL THEN
			RAISE EXCEPTION 'user not found';
		END IF;

		IF crypt(user_password, hashed_pass) = hashed_pass THEN
			DELETE FROM users
				WHERE user_id::TEXT = uid;
		ELSE 
			
			RAISE EXCEPTION 'incorrect password';

		END IF;

		RETURN;
	END;
$$;


ALTER FUNCTION jwt_core.delete_user(user_password text) OWNER TO postgres;

--
-- Name: extract_payload_from_jwt(); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.extract_payload_from_jwt() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
	DECLARE
		user_token TEXT;
		unencrypted_token RECORD;
		
	BEGIN
		user_token := jwt_core.extract_token_from_jwt();

		SELECT * INTO unencrypted_token
			FROM verify(user_token, jwt_core.secret());
    		

	RETURN unencrypted_token.payload::JSONB;

	END;
$$;


ALTER FUNCTION jwt_core.extract_payload_from_jwt() OWNER TO postgres;

--
-- Name: extract_token_from_jwt(); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.extract_token_from_jwt() RETURNS text
    LANGUAGE plpgsql
    AS $$
	DECLARE
		http_header jsonb;
		jwt text;
	BEGIN
		http_header := current_setting('request.headers', TRUE);
		jwt := http_header -> 'authorization';
		jwt := substring(jwt FROM 9 FOR length(jwt) - 9);
		RETURN jwt;
	END;
$$;


ALTER FUNCTION jwt_core.extract_token_from_jwt() OWNER TO postgres;

--
-- Name: generate_jwt(text); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.generate_jwt(userid text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
	DECLARE
		secret text;
		iss_time int;
		jwt_skeleton JSON;
		jwt text;
		response JSON;
		user_role text;
		user_name text;
	BEGIN  
		SELECT app_secrets.value INTO secret 
			FROM app_secrets WHERE name = 'jwt_secret';
	
		SELECT name, role_id INTO user_name, user_role
			FROM jwt_core.users WHERE user_id::TEXT = userid;

		SELECT EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) INTO iss_time;
	
		jwt_skeleton := json_build_object('uid', userid, 'name', user_name, 'role', 'web_user', 
									'user_role', user_role, 'iat', iss_time, 'exp', iss_time+86400);
	
		SELECT sign(jwt_skeleton, secret) INTO jwt; 
	
		response := json_build_object('jwt', jwt)::jsonb;
		
		RETURN response;

	END;
$$;


ALTER FUNCTION jwt_core.generate_jwt(userid text) OWNER TO postgres;

--
-- Name: get_about_user(uuid); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.get_about_user(userid uuid) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
	DECLARE
		info RECORD;
	BEGIN
		SELECT * INTO info
			FROM jwt_core.about_user WHERE user_id = userid;

		IF info IS NULL THEN
			RAISE EXCEPTION 'about_user not found';
		END IF;

		RETURN json_build_object('smoking', info.smoking,
								'pets', info.pets,
								'party_habits', info.party_habits,
								'food_preference', info.food_preference)::JSONB;
	END;
$$;


ALTER FUNCTION jwt_core.get_about_user(userid uuid) OWNER TO postgres;

--
-- Name: get_user_info(uuid); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.get_user_info(userid uuid) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		json_response JSON;
		user_info RECORD;
	BEGIN
		SELECT * INTO user_info
			FROM users WHERE user_id = userid;

		IF user_info IS NULL THEN
			RAISE EXCEPTION 'user not found: %', userid;
		END IF;

		json_response := json_build_object(
			'user_id', userid,
			'name', user_info.name,
			'age', user_info.age,
			'roommate_gender', user_info.gender,
			'email', user_info.email,
			'telephone', user_info.mobile,
			'bio', user_info.bio,
			'role', user_info.role_id,
			'pfp_id', user_info.profile_picture_url,
			'registered at', user_info.created_at,
			'last active', user_info.last_active,
			'nationality', user_info.nationality
		);

		RETURN json_response::JSONB;
	END;
$$;


ALTER FUNCTION jwt_core.get_user_info(userid uuid) OWNER TO postgres;

--
-- Name: jwt_auth_checktoken(); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.jwt_auth_checktoken() RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		user_token TEXT;
		secret TEXT;
		signature_verified boolean;
	BEGIN
		user_token := jwt_core.extract_token_from_jwt()::TEXT;
		
		-- if no token
		-- because in authDB there are some endpoints that require user to not have JWT
		-- and so this function breaks the accessing process
		-- so yeah, if user has no authorization header this check is omitted
		IF user_token IS NULL THEN 
			RETURN;
		END IF;
	
		IF user_token = '' THEN
			RAISE EXCEPTION 'JWT is empty'
				USING HINT = 'Request has Authorization header, but it is empty';
		END IF;		

		-- verifying signature of token
		SELECT valid INTO signature_verified
			FROM verify(user_token, jwt_core.secret());

		IF signature_verified IS NOT TRUE THEN
			RAISE SQLSTATE '0L000'
				USING HINT = 'this token has invalid signature';
		END IF;	




		--add checks that current token info matches with db


		--wait do i actually need it tho
		
	END;
$$;


ALTER FUNCTION jwt_core.jwt_auth_checktoken() OWNER TO postgres;

--
-- Name: login(text, text); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.login(user_email text, user_password text) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		tempvar RECORD;
		password_match boolean;
		jwt JSONB;
	BEGIN

		-- searching for user in db by incoming email
		SELECT user_id, password_hash 
			INTO tempvar
    		FROM jwt_core.users 
			WHERE email = user_email;

		IF tempvar IS NULL THEN
			RAISE EXCEPTION 'email does not exist'
				USING HINT = 'this email does not exist in the database';
		END IF;

		-- checking the password using hashes
		password_match := crypt(user_password, tempvar.password_hash) = tempvar.password_hash;

		-- generate new JWT if login is successful
		IF password_match THEN 
			jwt := jwt_core.generate_jwt(tempvar.user_id::text)::JSONB;
			RETURN jwt;
		ELSE 
			RAISE EXCEPTION 'incorrect password'
				USING HINT = 'user has entered incorrect password';
		END IF;

	END;
$$;


ALTER FUNCTION jwt_core.login(user_email text, user_password text) OWNER TO postgres;

--
-- Name: secret(); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.secret() RETURNS text
    LANGUAGE plpgsql
    AS $$
	DECLARE
		response TEXT;
	BEGIN
		SELECT value INTO response 
			FROM app_secrets WHERE name = 'jwt_secret';
	
	RETURN response;
	END;
$$;


ALTER FUNCTION jwt_core.secret() OWNER TO postgres;

--
-- Name: update_about_user(jwt_core.smoking, jwt_core.pets, jwt_core.party_habits, jwt_core.food_preference); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.update_about_user(new_smoking jwt_core.smoking, new_pets jwt_core.pets, new_party_habits jwt_core.party_habits, new_food_preference jwt_core.food_preference) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE about_user
			SET smoking = COALESCE(new_smoking, smoking),
				pets = COALESCE(new_pets, pets),
				party_habits = COALESCE(new_party_habits, party_habits),
				food_preference = COALESCE(new_food_preference, food_preference)
			WHERE user_id::TEXT = jwt_core.extract_payload_from_jwt() ->> 'uid';
	END;
$$;


ALTER FUNCTION jwt_core.update_about_user(new_smoking jwt_core.smoking, new_pets jwt_core.pets, new_party_habits jwt_core.party_habits, new_food_preference jwt_core.food_preference) OWNER TO postgres;

--
-- Name: update_last_active(); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.update_last_active() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	NEW.last_active := NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION jwt_core.update_last_active() OWNER TO postgres;

--
-- Name: update_password(text, text); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.update_password(old_password text, new_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE 
		tempvar TEXT;
		userid TEXT;
	BEGIN
		userid = jwt_core.extract_payload_from_jwt() ->> 'uid';

		SELECT password_hash INTO tempvar
			FROM jwt_core.users WHERE user_id::TEXT = userid;


		IF crypt(old_password, tempvar) <> tempvar THEN
			RAISE EXCEPTION 'incorrect old password'; 
		ELSE 
			IF crypt(new_password, tempvar) = tempvar THEN
				RAISE EXCEPTION 'new password = old password';
			ELSE
				UPDATE users
					SET password_hash = crypt(new_password, tempvar) 
					WHERE user_id::TEXT = userid;
			END IF;
		END IF;
	END;
$$;


ALTER FUNCTION jwt_core.update_password(old_password text, new_password text) OWNER TO postgres;

--
-- Name: update_user_activity_time(text); Type: PROCEDURE; Schema: jwt_core; Owner: postgres
--

CREATE PROCEDURE jwt_core.update_user_activity_time(IN userid text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE jwt_core.users
			SET last_active = NOW()
			WHERE user_id::TEXT = userid;
	END;
$$;


ALTER PROCEDURE jwt_core.update_user_activity_time(IN userid text) OWNER TO postgres;

--
-- Name: update_user_info(text, text, text, text, text, text, jwt_core.gender, numeric, text); Type: FUNCTION; Schema: jwt_core; Owner: postgres
--

CREATE FUNCTION jwt_core.update_user_info(user_name text, user_email text, user_mobile text, user_role text, user_bio text, user_nationality text, user_gender jwt_core.gender, user_age numeric, pfp_id text) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		userid TEXT;
		user_token JSON;
	BEGIN
			userid := jwt_core.extract_payload_from_jwt() ->> 'uid';
				
			UPDATE jwt_core.users
				SET name = COALESCE(user_name, name),
					email = COALESCE(user_email, email),
					mobile = COALESCE(user_mobile, mobile),
					bio = COALESCE(user_bio, bio),
					nationality = COALESCE(user_nationality, nationality),
					age = COALESCE(user_age, age),
					gender = COALESCE(user_gender, gender),
					profile_picture_url = COALESCE(pfp_id, profile_picture_url)

				WHERE user_id::TEXT = userid;

			-- since info is updated, the token might become invalid

			user_token := jwt_core.generate_jwt(userid);

			RAISE NOTICE 'user info updated for user_id: %', userid;
	
			RETURN user_token;
	END;
$$;


ALTER FUNCTION jwt_core.update_user_info(user_name text, user_email text, user_mobile text, user_role text, user_bio text, user_nationality text, user_gender jwt_core.gender, user_age numeric, pfp_id text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: about_user; Type: TABLE; Schema: jwt_core; Owner: postgres
--

CREATE TABLE jwt_core.about_user (
    user_id uuid NOT NULL,
    smoking jwt_core.smoking,
    pets jwt_core.pets,
    party_habits jwt_core.party_habits,
    food_preference jwt_core.food_preference
);


ALTER TABLE jwt_core.about_user OWNER TO postgres;

--
-- Name: app_secrets; Type: TABLE; Schema: jwt_core; Owner: postgres
--

CREATE TABLE jwt_core.app_secrets (
    id integer NOT NULL,
    name text NOT NULL,
    value text NOT NULL
);


ALTER TABLE jwt_core.app_secrets OWNER TO postgres;

--
-- Name: app_secrets_id_seq; Type: SEQUENCE; Schema: jwt_core; Owner: postgres
--

CREATE SEQUENCE jwt_core.app_secrets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jwt_core.app_secrets_id_seq OWNER TO postgres;

--
-- Name: app_secrets_id_seq; Type: SEQUENCE OWNED BY; Schema: jwt_core; Owner: postgres
--

ALTER SEQUENCE jwt_core.app_secrets_id_seq OWNED BY jwt_core.app_secrets.id;


--
-- Name: users; Type: TABLE; Schema: jwt_core; Owner: postgres
--

CREATE TABLE jwt_core.users (
    user_id uuid NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    mobile character varying(30) NOT NULL,
    password_hash character(64) NOT NULL,
    role_id character varying NOT NULL,
    profile_picture_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    last_active timestamp without time zone NOT NULL,
    bio text NOT NULL,
    nationality text NOT NULL,
    age integer NOT NULL,
    gender jwt_core.gender NOT NULL
);


ALTER TABLE jwt_core.users OWNER TO postgres;

--
-- Name: app_secrets id; Type: DEFAULT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.app_secrets ALTER COLUMN id SET DEFAULT nextval('jwt_core.app_secrets_id_seq'::regclass);


--
-- Name: about_user about_user_pk; Type: CONSTRAINT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.about_user
    ADD CONSTRAINT about_user_pk PRIMARY KEY (user_id);


--
-- Name: app_secrets app_secrets_name_key; Type: CONSTRAINT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.app_secrets
    ADD CONSTRAINT app_secrets_name_key UNIQUE (name);


--
-- Name: app_secrets app_secrets_pkey; Type: CONSTRAINT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.app_secrets
    ADD CONSTRAINT app_secrets_pkey PRIMARY KEY (id);


--
-- Name: users pk_1; Type: CONSTRAINT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.users
    ADD CONSTRAINT pk_1 PRIMARY KEY (user_id);


--
-- Name: users users_unique; Type: CONSTRAINT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.users
    ADD CONSTRAINT users_unique UNIQUE (email, mobile);


--
-- Name: users users_unique_1; Type: CONSTRAINT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.users
    ADD CONSTRAINT users_unique_1 UNIQUE (email);


--
-- Name: users trigger_update_last_active; Type: TRIGGER; Schema: jwt_core; Owner: postgres
--

CREATE TRIGGER trigger_update_last_active BEFORE UPDATE ON jwt_core.users FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE FUNCTION jwt_core.update_last_active();


--
-- Name: about_user about_user_users_fk; Type: FK CONSTRAINT; Schema: jwt_core; Owner: postgres
--

ALTER TABLE ONLY jwt_core.about_user
    ADD CONSTRAINT about_user_users_fk FOREIGN KEY (user_id) REFERENCES jwt_core.users(user_id);


--
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA api TO web_anon;
GRANT USAGE ON SCHEMA api TO web_user;


--
-- Name: SCHEMA jwt_core; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA jwt_core TO web_anon;
GRANT USAGE ON SCHEMA jwt_core TO iotuser;
GRANT USAGE ON SCHEMA jwt_core TO web_user;


--
-- Name: FUNCTION debug_headers(); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.debug_headers() TO web_anon;


--
-- Name: FUNCTION delete_user(user_password text); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.delete_user(user_password text) TO web_user;


--
-- Name: FUNCTION login(user_email text, user_password text); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.login(user_email text, user_password text) TO web_anon;


--
-- Name: FUNCTION nginx_auth(); Type: ACL; Schema: api; Owner: postgres
--

GRANT ALL ON FUNCTION api.nginx_auth() TO web_user;
GRANT ALL ON FUNCTION api.nginx_auth() TO web_anon;


--
-- Name: FUNCTION extract_token_from_jwt(); Type: ACL; Schema: jwt_core; Owner: postgres
--

GRANT ALL ON FUNCTION jwt_core.extract_token_from_jwt() TO web_user;


--
-- Name: TABLE about_user; Type: ACL; Schema: jwt_core; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jwt_core.about_user TO web_user;
GRANT SELECT,INSERT ON TABLE jwt_core.about_user TO web_anon;


--
-- Name: TABLE app_secrets; Type: ACL; Schema: jwt_core; Owner: postgres
--

GRANT SELECT ON TABLE jwt_core.app_secrets TO web_anon;
GRANT SELECT ON TABLE jwt_core.app_secrets TO web_user;


--
-- Name: TABLE users; Type: ACL; Schema: jwt_core; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE jwt_core.users TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jwt_core.users TO web_user;


--
-- PostgreSQL database dump complete
--

