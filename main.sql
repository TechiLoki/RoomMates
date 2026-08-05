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
-- Name: roommates_api; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA roommates_api;


ALTER SCHEMA roommates_api OWNER TO postgres;

--
-- Name: roommates_core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA roommates_core;


ALTER SCHEMA roommates_core OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA roommates_core;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA roommates_core;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: food_preference; Type: TYPE; Schema: roommates_core; Owner: postgres
--

CREATE TYPE roommates_core.food_preference AS ENUM (
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'No preference'
);


ALTER TYPE roommates_core.food_preference OWNER TO postgres;

--
-- Name: gender; Type: TYPE; Schema: roommates_core; Owner: postgres
--

CREATE TYPE roommates_core.gender AS ENUM (
    'Male',
    'Female',
    'Other'
);


ALTER TYPE roommates_core.gender OWNER TO postgres;

--
-- Name: listing_type; Type: TYPE; Schema: roommates_core; Owner: postgres
--

CREATE TYPE roommates_core.listing_type AS ENUM (
    'Apartment',
    'House'
);


ALTER TYPE roommates_core.listing_type OWNER TO postgres;

--
-- Name: party_habits; Type: TYPE; Schema: roommates_core; Owner: postgres
--

CREATE TYPE roommates_core.party_habits AS ENUM (
    'Occasionally',
    'Frequently',
    'Never',
    'No preference'
);


ALTER TYPE roommates_core.party_habits OWNER TO postgres;

--
-- Name: pets; Type: TYPE; Schema: roommates_core; Owner: postgres
--

CREATE TYPE roommates_core.pets AS ENUM (
    'Yes',
    'No'
);


ALTER TYPE roommates_core.pets OWNER TO postgres;

--
-- Name: roommate_gender; Type: TYPE; Schema: roommates_core; Owner: postgres
--

CREATE TYPE roommates_core.roommate_gender AS ENUM (
    'Male',
    'Female',
    'No preference'
);


ALTER TYPE roommates_core.roommate_gender OWNER TO postgres;

--
-- Name: smoking; Type: TYPE; Schema: roommates_core; Owner: postgres
--

CREATE TYPE roommates_core.smoking AS ENUM (
    'Non-Smoker',
    'No preference',
    'Smoker'
);


ALTER TYPE roommates_core.smoking OWNER TO postgres;

--
-- Name: add_listing(text, text, text, integer, integer, integer, roommates_core.listing_type, roommates_core.smoking, roommates_core.pets, roommates_core.roommate_gender, roommates_core.party_habits, roommates_core.food_preference); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.add_listing(listing_city text, listing_address text, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, smoking roommates_core.smoking, pets roommates_core.pets, roommate_gender roommates_core.roommate_gender, party_habits roommates_core.party_habits, food_preference roommates_core.food_preference) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		picture_id text;
	BEGIN
		picture_id := roommates_core.add_listing(listing_city, listing_address, 
											listing_description, listing_price, 
											listing_area, listing_bedroom_count, listing_cat);

		PERFORM roommates_core.add_preferences(pets, smoking, roommate_gender, party_habits, food_preference);

		RETURN json_build_object('png_id', picture_id);
	END;
$$;


ALTER FUNCTION roommates_api.add_listing(listing_city text, listing_address text, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, smoking roommates_core.smoking, pets roommates_core.pets, roommate_gender roommates_core.roommate_gender, party_habits roommates_core.party_habits, food_preference roommates_core.food_preference) OWNER TO postgres;

--
-- Name: add_listing_temporary(text, text, text, integer, integer, integer, roommates_core.listing_type, roommates_core.smoking, roommates_core.pets, roommates_core.roommate_gender, roommates_core.party_habits, roommates_core.food_preference); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.add_listing_temporary(listing_city text, listing_address text, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, smoking roommates_core.smoking, pets roommates_core.pets, roommate_gender roommates_core.roommate_gender, party_habits roommates_core.party_habits, food_preference roommates_core.food_preference) RETURNS text
    LANGUAGE plpgsql
    AS $$
	DECLARE 
		temp_list_id_returning_stuff TEXT;
	BEGIN
		temp_list_id_returning_stuff := roommates_core.add_listing_temporary (listing_city, listing_address,
--		PERFORM roommates_core.add_listing(listing_city, listing_address, 
											listing_description, listing_price, 
											listing_area, listing_bedroom_count, listing_cat);

		PERFORM roommates_core.add_preferences(pets, smoking, roommate_gender, party_habits, food_preference);

--		RETURN;
		RETURN temp_list_id_returning_stuff;
	END;
$$;


ALTER FUNCTION roommates_api.add_listing_temporary(listing_city text, listing_address text, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, smoking roommates_core.smoking, pets roommates_core.pets, roommate_gender roommates_core.roommate_gender, party_habits roommates_core.party_habits, food_preference roommates_core.food_preference) OWNER TO postgres;

--
-- Name: admin_add_city(text); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.admin_add_city(city_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN

		PERFORM roommates_core.admin_add_city(city_name);

		RETURN;

	END		
$$;


ALTER FUNCTION roommates_api.admin_add_city(city_name text) OWNER TO postgres;

--
-- Name: debug_headers(); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.debug_headers() RETURNS text
    LANGUAGE plpgsql
    AS $$
	BEGIN
		return current_setting('request.method', TRUE);
	END;
$$;


ALTER FUNCTION roommates_api.debug_headers() OWNER TO postgres;

--
-- Name: delete_listing(); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.delete_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		PERFORM roommates_core.delete_preferences();
		PERFORM roommates_core.delete_listing();
	END;
$$;


ALTER FUNCTION roommates_api.delete_listing() OWNER TO postgres;

--
-- Name: get_all_listings(); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.get_all_listings() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN roommates_core.get_all_listings();
	END;
$$;


ALTER FUNCTION roommates_api.get_all_listings() OWNER TO postgres;

--
-- Name: get_listing(uuid, uuid); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.get_listing(listing_id uuid DEFAULT NULL::uuid, user_id uuid DEFAULT NULL::uuid) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		lid UUID;
	BEGIN
		IF listing_id IS NULL THEN
			SELECT listings.listing_id INTO lid FROM roommates_core.listings
				WHERE owner_id = user_id;
			RETURN roommates_core.get_listing(lid);
		ELSE
			RETURN roommates_core.get_listing(listing_id);
		END IF;
	END;
$$;


ALTER FUNCTION roommates_api.get_listing(listing_id uuid, user_id uuid) OWNER TO postgres;

--
-- Name: main_delete_user(); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.main_delete_user() RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		debug_record RECORD;
	BEGIN
		
	PERFORM roommates_core.delete_listing();
		PERFORM roommates_core.delete_preferences();
		
		DELETE from roommates_core.users
			WHERE user_id::TEXT = roommates_core.extract_payload_from_jwt() ->> 'uid';
	END;
$$;


ALTER FUNCTION roommates_api.main_delete_user() OWNER TO postgres;

--
-- Name: search_listings(text[], integer, integer, integer, integer, integer[], integer); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.search_listings(search_city text[] DEFAULT NULL::text[], search_price_min integer DEFAULT NULL::integer, search_price_max integer DEFAULT NULL::integer, search_area_min integer DEFAULT NULL::integer, search_area_max integer DEFAULT NULL::integer, search_bedrooms integer[] DEFAULT NULL::integer[], current_page integer DEFAULT 1) RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN roommates_core.search_listings(search_city, search_price_min, search_price_max, search_area_min, search_area_max, search_bedrooms, current_page);
	END;
$$;


ALTER FUNCTION roommates_api.search_listings(search_city text[], search_price_min integer, search_price_max integer, search_area_min integer, search_area_max integer, search_bedrooms integer[], current_page integer) OWNER TO postgres;

--
-- Name: test_endpoint(); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.test_endpoint() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
      RETURN '{"test_title":"test_text"}'::json;
	END;
$$;


ALTER FUNCTION roommates_api.test_endpoint() OWNER TO postgres;

--
-- Name: update_listing(text, text, text, integer, text, integer, integer, integer, roommates_core.listing_type, roommates_core.pets, roommates_core.smoking, roommates_core.roommate_gender, roommates_core.party_habits, roommates_core.food_preference, text); Type: FUNCTION; Schema: roommates_api; Owner: postgres
--

CREATE FUNCTION roommates_api.update_listing(lid text DEFAULT NULL::text, listing_city_change text DEFAULT NULL::text, listing_address_change text DEFAULT NULL::text, listing_floor_change integer DEFAULT NULL::integer, listing_description_change text DEFAULT NULL::text, listing_price_change integer DEFAULT NULL::integer, listing_area_change integer DEFAULT NULL::integer, listing_bedroom_count_change integer DEFAULT NULL::integer, listing_cat_change roommates_core.listing_type DEFAULT NULL::roommates_core.listing_type, pets_change roommates_core.pets DEFAULT NULL::roommates_core.pets, smoking_change roommates_core.smoking DEFAULT NULL::roommates_core.smoking, roommate_gender_change roommates_core.roommate_gender DEFAULT NULL::roommates_core.roommate_gender, party_habits_change roommates_core.party_habits DEFAULT NULL::roommates_core.party_habits, food_preference_change roommates_core.food_preference DEFAULT NULL::roommates_core.food_preference, listing_picture_change text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		llid TEXT;
	BEGIN

		llid := lid;

		IF llid IS NULL OR llid = '' THEN
			SELECT listing_id INTO llid
				FROM roommates_core.listings 
				WHERE owner_id::TEXT = roommates_core.extract_payload_from_jwt() ->> 'uid';
		END IF;
	
		PERFORM roommates_core.update_listing(llid, listing_city_change, listing_address_change, listing_floor_change, 
												listing_description_change, listing_price_change, listing_area_change, 
												listing_bedroom_count_change, listing_cat_change, listing_picture_change);
	
		PERFORM roommates_core.update_preferences(pets_change, smoking_change, roommate_gender_change, party_habits_change, food_preference_change);

		RETURN;
	END;
$$;


ALTER FUNCTION roommates_api.update_listing(lid text, listing_city_change text, listing_address_change text, listing_floor_change integer, listing_description_change text, listing_price_change integer, listing_area_change integer, listing_bedroom_count_change integer, listing_cat_change roommates_core.listing_type, pets_change roommates_core.pets, smoking_change roommates_core.smoking, roommate_gender_change roommates_core.roommate_gender, party_habits_change roommates_core.party_habits, food_preference_change roommates_core.food_preference, listing_picture_change text) OWNER TO postgres;

--
-- Name: add_listing(text, text, text, integer, integer, integer, roommates_core.listing_type); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.add_listing(listing_city text, listing_address text, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type) RETURNS text
    LANGUAGE plpgsql
    AS $$
	DECLARE
		uid UUID;
		cid UUID;
		picture_id UUID;
	BEGIN
		uid := (roommates_core.extract_payload_from_jwt() ->> 'uid')::UUID;
		picture_id := roommates_core.gen_random_uuid();

		SELECT city_id INTO	cid
			FROM roommates_core.cities WHERE name = listing_city;

		INSERT INTO listings (listing_id, owner_id,
								city, precise_address, custom_description,
								price, date_added,
								area, bedroom_count, listing_category, png_id)

			VALUES (gen_random_uuid(), uid,
					cid, listing_address, listing_description, 
					listing_price, NOW(), 
					listing_area, listing_bedroom_count, listing_cat, picture_id::UUID);
		RETURN picture_id;
	END;
$$;


ALTER FUNCTION roommates_core.add_listing(listing_city text, listing_address text, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type) OWNER TO postgres;

--
-- Name: add_listing_temporary(text, text, integer, text, integer, integer, integer, roommates_core.listing_type); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.add_listing_temporary(listing_city text, listing_address text, listing_floor integer, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type) RETURNS text
    LANGUAGE plpgsql
    AS $$
	DECLARE
		uid UUID;
		cid UUID;

		temp_listing_id TEXT;
	BEGIN

		temp_listing_id := gen_random_uuid()::TEXT;


		uid := (roommates_core.extract_payload_from_jwt() ->> 'uid')::UUID;

		SELECT city_id INTO	cid
			FROM roommates_core.cities WHERE name = listing_city;

		INSERT INTO listings (listing_id, owner_id,
								city, precise_address, custom_description,
								images, price, floor, date_added,
								area, bedroom_count, listing_category)

			VALUES (temp_listing_id::UUID, uid,
					cid, listing_address, listing_description, 
					'temp/link/to.image', listing_price, listing_floor, NOW(), 
					listing_area, listing_bedroom_count, listing_cat);

		RETURN temp_listing_id;

	END;
$$;


ALTER FUNCTION roommates_core.add_listing_temporary(listing_city text, listing_address text, listing_floor integer, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type) OWNER TO postgres;

--
-- Name: add_preferences(roommates_core.pets, roommates_core.smoking, roommates_core.roommate_gender, roommates_core.party_habits, roommates_core.food_preference); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.add_preferences(upets roommates_core.pets, usmoking roommates_core.smoking, uroommate_gender roommates_core.roommate_gender, uparty_habits roommates_core.party_habits, ufood_preference roommates_core.food_preference) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO roommates_core.preferences(user_id, pets, smoking, 
											roommate_gender, party_habits, food_preference) 
			VALUES ((roommates_core.extract_payload_from_jwt() ->> 'uid')::UUID, upets, usmoking,
											uroommate_gender::roommate_gender, uparty_habits, ufood_preference);
	END;
$$;


ALTER FUNCTION roommates_core.add_preferences(upets roommates_core.pets, usmoking roommates_core.smoking, uroommate_gender roommates_core.roommate_gender, uparty_habits roommates_core.party_habits, ufood_preference roommates_core.food_preference) OWNER TO postgres;

--
-- Name: admin_add_city(text); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.admin_add_city(city_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO cities(city_id, name)
			VALUES (roommates_core.gen_random_uuid(), city_name);
	END;
$$;


ALTER FUNCTION roommates_core.admin_add_city(city_name text) OWNER TO postgres;

--
-- Name: delete_listing(); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.delete_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
	
		DELETE FROM roommates_core.listings
			WHERE owner_id::TEXT = roommates_core.extract_payload_from_jwt() ->> 'uid';

	END;
$$;


ALTER FUNCTION roommates_core.delete_listing() OWNER TO postgres;

--
-- Name: delete_preferences(); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.delete_preferences() RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN

		DELETE FROM preferences
			WHERE user_id::TEXT = roommates_core.extract_payload_from_jwt() ->> 'uid';

	END;
$$;


ALTER FUNCTION roommates_core.delete_preferences() OWNER TO postgres;

--
-- Name: extract_payload_from_jwt(); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.extract_payload_from_jwt() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
	DECLARE
		user_token TEXT;
		unencrypted_token RECORD;
		
	BEGIN
		user_token := roommates_core.extract_token_from_jwt();
		
		SELECT * INTO unencrypted_token
			FROM verify(user_token, roommates_core.secret());
    		

	RETURN unencrypted_token.payload::JSONB;

	END;
$$;


ALTER FUNCTION roommates_core.extract_payload_from_jwt() OWNER TO postgres;

--
-- Name: extract_token_from_jwt(); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.extract_token_from_jwt() RETURNS text
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


ALTER FUNCTION roommates_core.extract_token_from_jwt() OWNER TO postgres;

--
-- Name: get_all_listings(); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.get_all_listings() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
		
RETURN response;
		RETURN json_agg(listings) FROM listings;
	END;
$$;


ALTER FUNCTION roommates_core.get_all_listings() OWNER TO postgres;

--
-- Name: get_listing(uuid); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.get_listing(lid uuid) RETURNS json
    LANGUAGE plpgsql
    AS $$
	DECLARE
		listing RECORD;
		preference RECORD;		
		city_name TEXT;
	BEGIN
		SELECT * INTO listing
			FROM roommates_core.listings WHERE listing_id = lid;

		IF listing IS NULL THEN
			RAISE EXCEPTION 'error, listing not found: %', lid; 
		END IF;

		SELECT * INTO preference
			FROM roommates_core.preferences WHERE user_id = listing.owner_id;

		SELECT name INTO city_name
			FROM roommates_core.cities WHERE city_id = listing.city;

		RETURN json_build_object('listing_id', listing.listing_id,
								'owner_id', listing.owner_id,
								'city', city_name,
								'precise_address', listing.precise_address,
								'custom_description', listing.custom_description,
								'price', listing.price,
								'date_added', listing.date_added,
								'area', listing.area,
								'bedroom_count', listing.bedroom_count,
								'listing_category', listing.listing_category,
								'png_id', listing.png_id,
								'pets', preference.pets,
								'smoking', preference.smoking,
								'roommate_gender', preference.roommate_gender,
								'party_habits', preference.party_habits,
								'food_preference', preference.food_preference);
	END;
$$;


ALTER FUNCTION roommates_core.get_listing(lid uuid) OWNER TO postgres;

--
-- Name: roommates_auth_checktoken(); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.roommates_auth_checktoken() RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		user_token TEXT;
		secret TEXT;
		iss_time INT;
		curr_time INT;
		signature_verified boolean;
		payload JSONB;
		headers JSONB;
	BEGIN
		user_token = roommates_core.extract_token_from_jwt();
--
--		--if no token
		IF user_token IS NULL OR user_token = '' THEN
			RAISE SQLSTATE '42501'
				USING HINT = 'no jwt provided',
					  MESSAGE = 'the incoming Authorization header has empty value';
					  
		END IF;		

		payload := roommates_core.extract_payload_from_jwt();

		--check signature

		SELECT valid INTO signature_verified
			FROM verify(user_token, roommates_core.secret());

		IF signature_verified IS NOT TRUE THEN
			RAISE SQLSTATE '0L000'
				USING HINT = 'this token has invalid signature';
		END IF;	
		

		-- if user is POSTing something, there is a high chance that we'll need their record in this db
		-- therefore, we're storing info only on POST because it's gonna break with GET
		-- (INSERT in a read-only transaction)
		IF current_setting('request.method', TRUE) = 'POST' THEN
			IF NOT EXISTS (SELECT 1 FROM roommates_core.users WHERE user_id::TEXT = payload ->> 'uid') THEN 
				--add jwt payload to users table
				INSERT INTO roommates_core.users(user_id, name, role_id)
					VALUES ((payload ->> 'uid')::UUID, payload ->> 'name', payload ->> 'user_role');
	
				ELSE 
					UPDATE roommates_core.users
					--update user info in case they have new name or smth
						SET name = payload ->> 'name',
							role_id = payload ->> 'user_role'
						WHERE user_id::TEXT = payload ->> 'uid'; 
			END IF;
		END IF;
END;
	
$$;


ALTER FUNCTION roommates_core.roommates_auth_checktoken() OWNER TO postgres;

--
-- Name: search_listings(text[], integer, integer, integer, integer, integer[], integer); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.search_listings(search_city text[], search_price_min integer, search_price_max integer, search_area_min integer, search_area_max integer, search_bedrooms integer[], current_page integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
    DECLARE
		listing_count NUMERIC;
		page_size INT;
	BEGIN
		page_size := 12;


		SELECT COUNT(*) INTO listing_count
				FROM roommates_core.listings_view
				WHERE (array_length(search_city, 1) IS NULL OR city = ANY(search_city))
				      AND (search_price_min IS NULL OR price >= search_price_min)
				      AND (search_price_max IS NULL OR price <= search_price_max)
				      AND (search_area_min IS NULL OR area >= search_area_min)
				      AND (search_area_max IS NULL OR area <= search_area_max)
				      AND (
				          array_length(search_bedrooms, 1) IS NULL
				          OR bedroom_count = ANY(search_bedrooms)
				          OR (-1 = ANY(search_bedrooms) AND bedroom_count > 3)
				      );
													
		RETURN json_build_object('listings',	(SELECT json_agg(t) FROM (SELECT *
																		  FROM roommates_core.listings_view
																		  WHERE (array_length(search_city, 1) IS NULL OR city = ANY(search_city))
																		        AND (search_price_min IS NULL OR price >= search_price_min)
																		        AND (search_price_max IS NULL OR price <= search_price_max)
																		        AND (search_area_min IS NULL OR area >= search_area_min)
																		        AND (search_area_max IS NULL OR area <= search_area_max)
																		        AND (
																	  				array_length(search_bedrooms, 1) IS NULL
																		        	OR bedroom_count = ANY(search_bedrooms)
																		        	OR (-1 = ANY(search_bedrooms) AND bedroom_count > 3)
																		        )
																		ORDER BY date_added DESC
																		LIMIT page_size
																		OFFSET (current_page - 1) * page_size) t),

								'meta',			json_build_object('total_pages', 	CEIL(listing_count / page_size),
														   		  'current_page', 	current_page));
		
	END;
$$;


ALTER FUNCTION roommates_core.search_listings(search_city text[], search_price_min integer, search_price_max integer, search_area_min integer, search_area_max integer, search_bedrooms integer[], current_page integer) OWNER TO postgres;

--
-- Name: secret(); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.secret() RETURNS text
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


ALTER FUNCTION roommates_core.secret() OWNER TO postgres;

--
-- Name: update_listing(text, text, text, integer, text, integer, integer, integer, roommates_core.listing_type, text); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.update_listing(lid text, listing_city text, listing_address text, listing_floor integer, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, listing_picture text) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE 
		cid UUID;
	BEGIN
		SELECT city_id INTO cid
			FROM roommates_core.cities WHERE name = listing_city;


		UPDATE listings
			SET city = COALESCE(cid, city),
				precise_address = COALESCE(listing_address, precise_address),
				custom_description = COALESCE(listing_description, custom_description),
				price = COALESCE(listing_price, price),
				area = COALESCE(listing_area, area),
				bedroom_count = COALESCE(listing_bedroom_count, bedroom_count),
				listing_category = COALESCE(listing_cat, listing_category),
				png_id = COALESCE(listing_picture::UUID, png_id)

			WHERE listing_id::TEXT = lid;

	END;
$$;


ALTER FUNCTION roommates_core.update_listing(lid text, listing_city text, listing_address text, listing_floor integer, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, listing_picture text) OWNER TO postgres;

--
-- Name: update_preferences(roommates_core.pets, roommates_core.smoking, roommates_core.roommate_gender, roommates_core.party_habits, roommates_core.food_preference); Type: FUNCTION; Schema: roommates_core; Owner: postgres
--

CREATE FUNCTION roommates_core.update_preferences(upets roommates_core.pets, usmoking roommates_core.smoking, uroommate_gender roommates_core.roommate_gender, uparty_habits roommates_core.party_habits, ufood_preference roommates_core.food_preference) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		payload JSONB;
	BEGIN

			payload := roommates_core.extract_payload_from_jwt();			

			UPDATE roommates_core.preferences
				SET pets = coalesce(pets, upets),
					smoking = COALESCE(usmoking, smoking),
					roommate_gender = COALESCE(uroommate_gender, roommate_gender),
					party_habits = COALESCE(uparty_habits, party_habits),
					food_preference = COALESCE(ufood_preference, food_preference)
					
				WHERE user_id::TEXT = payload ->> 'uid';

			RAISE NOTICE 'user preferences updated for user_id: %', payload ->> 'uid';
		RETURN;
	END;
$$;


ALTER FUNCTION roommates_core.update_preferences(upets roommates_core.pets, usmoking roommates_core.smoking, uroommate_gender roommates_core.roommate_gender, uparty_habits roommates_core.party_habits, ufood_preference roommates_core.food_preference) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_secrets; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.app_secrets (
    id integer NOT NULL,
    name text NOT NULL,
    value text NOT NULL
);


ALTER TABLE roommates_core.app_secrets OWNER TO postgres;

--
-- Name: app_secrets_id_seq; Type: SEQUENCE; Schema: roommates_core; Owner: postgres
--

CREATE SEQUENCE roommates_core.app_secrets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE roommates_core.app_secrets_id_seq OWNER TO postgres;

--
-- Name: app_secrets_id_seq; Type: SEQUENCE OWNED BY; Schema: roommates_core; Owner: postgres
--

ALTER SEQUENCE roommates_core.app_secrets_id_seq OWNED BY roommates_core.app_secrets.id;


--
-- Name: cities; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.cities (
    city_id uuid NOT NULL,
    name text NOT NULL
);


ALTER TABLE roommates_core.cities OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.images (
    image_id uuid NOT NULL,
    listing_id uuid NOT NULL,
    image_url text NOT NULL
);


ALTER TABLE roommates_core.images OWNER TO postgres;

--
-- Name: listings; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.listings (
    listing_id uuid NOT NULL,
    owner_id uuid NOT NULL,
    city uuid NOT NULL,
    precise_address text NOT NULL,
    custom_description text NOT NULL,
    price integer NOT NULL,
    date_added timestamp without time zone NOT NULL,
    area integer NOT NULL,
    bedroom_count integer NOT NULL,
    listing_category roommates_core.listing_type NOT NULL,
    png_id uuid NOT NULL
);


ALTER TABLE roommates_core.listings OWNER TO postgres;

--
-- Name: listings_view; Type: VIEW; Schema: roommates_core; Owner: postgres
--

CREATE VIEW roommates_core.listings_view AS
 SELECT l.listing_id,
    l.city AS city_id,
    c.name AS city,
    l.precise_address,
    l.price,
    l.area,
    l.bedroom_count,
    l.listing_category,
    l.png_id,
    l.date_added
   FROM (roommates_core.listings l
     LEFT JOIN roommates_core.cities c ON ((l.city = c.city_id)));


ALTER VIEW roommates_core.listings_view OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.logs (
    log_id uuid NOT NULL,
    "time" timestamp without time zone NOT NULL,
    user_id uuid NOT NULL,
    action text NOT NULL,
    response text NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE roommates_core.logs OWNER TO postgres;

--
-- Name: message_documents; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.message_documents (
    document_id uuid NOT NULL,
    message_id uuid NOT NULL,
    file_name text NOT NULL,
    file_location text NOT NULL
);


ALTER TABLE roommates_core.message_documents OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.messages (
    message_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    receiver_id uuid NOT NULL,
    sent_at timestamp without time zone NOT NULL,
    read_at timestamp without time zone NOT NULL,
    is_reply_to text NOT NULL,
    body text NOT NULL,
    attached_documents_id uuid NOT NULL
);


ALTER TABLE roommates_core.messages OWNER TO postgres;

--
-- Name: preferences; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.preferences (
    user_id uuid NOT NULL,
    pets roommates_core.pets NOT NULL,
    smoking roommates_core.smoking NOT NULL,
    roommate_gender roommates_core.roommate_gender NOT NULL,
    party_habits roommates_core.party_habits NOT NULL,
    food_preference roommates_core.food_preference NOT NULL
);


ALTER TABLE roommates_core.preferences OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.roles (
    role_id integer NOT NULL,
    can_upload_images boolean NOT NULL,
    can_create_listings boolean NOT NULL,
    can_send_messages boolean NOT NULL,
    role_name character varying NOT NULL
);


ALTER TABLE roommates_core.roles OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: roommates_core; Owner: postgres
--

CREATE SEQUENCE roommates_core.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE roommates_core.roles_role_id_seq OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: roommates_core; Owner: postgres
--

ALTER SEQUENCE roommates_core.roles_role_id_seq OWNED BY roommates_core.roles.role_id;


--
-- Name: users; Type: TABLE; Schema: roommates_core; Owner: postgres
--

CREATE TABLE roommates_core.users (
    user_id uuid NOT NULL,
    name text NOT NULL,
    email text,
    mobile character varying(30),
    password_hash character(64),
    role_id character varying NOT NULL,
    profile_picture_url text,
    created_at timestamp without time zone,
    last_active time without time zone,
    bio text,
    nationality text,
    age integer,
    gender roommates_core.gender
);


ALTER TABLE roommates_core.users OWNER TO postgres;

--
-- Name: users_role_id_seq; Type: SEQUENCE; Schema: roommates_core; Owner: postgres
--

CREATE SEQUENCE roommates_core.users_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE roommates_core.users_role_id_seq OWNER TO postgres;

--
-- Name: users_role_id_seq; Type: SEQUENCE OWNED BY; Schema: roommates_core; Owner: postgres
--

ALTER SEQUENCE roommates_core.users_role_id_seq OWNED BY roommates_core.users.role_id;


--
-- Name: app_secrets id; Type: DEFAULT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.app_secrets ALTER COLUMN id SET DEFAULT nextval('roommates_core.app_secrets_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.roles ALTER COLUMN role_id SET DEFAULT nextval('roommates_core.roles_role_id_seq'::regclass);


--
-- Name: listings listings_unique; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.listings
    ADD CONSTRAINT listings_unique UNIQUE (owner_id, listing_id);


--
-- Name: users pk_1; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.users
    ADD CONSTRAINT pk_1 PRIMARY KEY (user_id);


--
-- Name: logs pk_11; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.logs
    ADD CONSTRAINT pk_11 PRIMARY KEY (log_id);


--
-- Name: message_documents pk_12; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.message_documents
    ADD CONSTRAINT pk_12 PRIMARY KEY (document_id);


--
-- Name: listings pk_2; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.listings
    ADD CONSTRAINT pk_2 PRIMARY KEY (listing_id);


--
-- Name: messages pk_3; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.messages
    ADD CONSTRAINT pk_3 PRIMARY KEY (message_id);


--
-- Name: preferences pk_4; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.preferences
    ADD CONSTRAINT pk_4 PRIMARY KEY (user_id);


--
-- Name: cities pk_5; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.cities
    ADD CONSTRAINT pk_5 PRIMARY KEY (city_id);


--
-- Name: roles pk_6; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.roles
    ADD CONSTRAINT pk_6 PRIMARY KEY (role_id);


--
-- Name: images pk_7; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.images
    ADD CONSTRAINT pk_7 PRIMARY KEY (image_id);


--
-- Name: roles roles_unique; Type: CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.roles
    ADD CONSTRAINT roles_unique UNIQUE (role_name);


--
-- Name: listings fk_1; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.listings
    ADD CONSTRAINT fk_1 FOREIGN KEY (owner_id) REFERENCES roommates_core.users(user_id);


--
-- Name: logs fk_17; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.logs
    ADD CONSTRAINT fk_17 FOREIGN KEY (user_id) REFERENCES roommates_core.users(user_id);


--
-- Name: message_documents fk_18; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.message_documents
    ADD CONSTRAINT fk_18 FOREIGN KEY (message_id) REFERENCES roommates_core.messages(message_id);


--
-- Name: messages fk_19; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.messages
    ADD CONSTRAINT fk_19 FOREIGN KEY (attached_documents_id) REFERENCES roommates_core.message_documents(document_id);


--
-- Name: messages fk_2; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.messages
    ADD CONSTRAINT fk_2 FOREIGN KEY (sender_id) REFERENCES roommates_core.users(user_id);


--
-- Name: messages fk_3; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.messages
    ADD CONSTRAINT fk_3 FOREIGN KEY (receiver_id) REFERENCES roommates_core.users(user_id);


--
-- Name: preferences fk_4; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.preferences
    ADD CONSTRAINT fk_4 FOREIGN KEY (user_id) REFERENCES roommates_core.users(user_id);


--
-- Name: listings fk_7; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.listings
    ADD CONSTRAINT fk_7 FOREIGN KEY (city) REFERENCES roommates_core.cities(city_id);


--
-- Name: images fk_9; Type: FK CONSTRAINT; Schema: roommates_core; Owner: postgres
--

ALTER TABLE ONLY roommates_core.images
    ADD CONSTRAINT fk_9 FOREIGN KEY (listing_id) REFERENCES roommates_core.listings(listing_id);


--
-- Name: SCHEMA roommates_api; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA roommates_api TO web_user;


--
-- Name: SCHEMA roommates_core; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA roommates_core TO web_anon;
GRANT USAGE ON SCHEMA roommates_core TO web_user;


--
-- Name: FUNCTION update_listing(lid text, listing_city text, listing_address text, listing_floor integer, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, listing_picture text); Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT ALL ON FUNCTION roommates_core.update_listing(lid text, listing_city text, listing_address text, listing_floor integer, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, listing_picture text) TO web_user;
GRANT ALL ON FUNCTION roommates_core.update_listing(lid text, listing_city text, listing_address text, listing_floor integer, listing_description text, listing_price integer, listing_area integer, listing_bedroom_count integer, listing_cat roommates_core.listing_type, listing_picture text) TO web_anon;


--
-- Name: FUNCTION update_preferences(upets roommates_core.pets, usmoking roommates_core.smoking, uroommate_gender roommates_core.roommate_gender, uparty_habits roommates_core.party_habits, ufood_preference roommates_core.food_preference); Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT ALL ON FUNCTION roommates_core.update_preferences(upets roommates_core.pets, usmoking roommates_core.smoking, uroommate_gender roommates_core.roommate_gender, uparty_habits roommates_core.party_habits, ufood_preference roommates_core.food_preference) TO web_anon;
GRANT ALL ON FUNCTION roommates_core.update_preferences(upets roommates_core.pets, usmoking roommates_core.smoking, uroommate_gender roommates_core.roommate_gender, uparty_habits roommates_core.party_habits, ufood_preference roommates_core.food_preference) TO web_user;


--
-- Name: TABLE app_secrets; Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT SELECT ON TABLE roommates_core.app_secrets TO web_user;


--
-- Name: TABLE cities; Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE roommates_core.cities TO web_user;


--
-- Name: TABLE listings; Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE roommates_core.listings TO web_user;


--
-- Name: TABLE listings_view; Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE roommates_core.listings_view TO web_user;


--
-- Name: TABLE preferences; Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE roommates_core.preferences TO web_user;


--
-- Name: TABLE users; Type: ACL; Schema: roommates_core; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE roommates_core.users TO web_anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE roommates_core.users TO web_user;


--
-- PostgreSQL database dump complete
--

