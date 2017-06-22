--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.7
-- Dumped by pg_dump version 9.5.7

-- Started on 2017-06-18 16:21:59 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE parelon;
--
-- TOC entry 3158 (class 1262 OID 18564)
-- Name: parelon; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE parelon WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'it_IT.UTF-8' LC_CTYPE = 'it_IT.UTF-8';


\connect parelon

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12397)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3160 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 707 (class 1247 OID 18566)
-- Name: application_access_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE application_access_level AS ENUM (
    'member',
    'full',
    'pseudonymous',
    'anonymous'
);


--
-- TOC entry 3161 (class 0 OID 0)
-- Dependencies: 707
-- Name: TYPE application_access_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE application_access_level IS 'DEPRECATED, WILL BE REMOVED! Access privileges for applications using the API';


--
-- TOC entry 710 (class 1247 OID 18576)
-- Name: author_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE author_type AS ENUM (
    'elected',
    'other'
);


--
-- TOC entry 713 (class 1247 OID 18582)
-- Name: issue_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE issue_state AS ENUM (
    'admission',
    'discussion',
    'verification',
    'voting',
    'canceled_revoked_before_accepted',
    'canceled_issue_not_accepted',
    'canceled_after_revocation_during_discussion',
    'canceled_after_revocation_during_verification',
    'canceled_no_initiative_admitted',
    'finished_without_winner',
    'finished_with_winner'
);


--
-- TOC entry 3162 (class 0 OID 0)
-- Dependencies: 713
-- Name: TYPE issue_state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE issue_state IS 'State of issues';


--
-- TOC entry 716 (class 1247 OID 18607)
-- Name: check_issue_persistence; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE check_issue_persistence AS (
	state issue_state,
	phase_finished boolean,
	issue_revoked boolean,
	snapshot_created boolean,
	harmonic_weights_set boolean,
	closed_voting boolean
);


--
-- TOC entry 3163 (class 0 OID 0)
-- Dependencies: 716
-- Name: TYPE check_issue_persistence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE check_issue_persistence IS 'Type of data returned by "check_issue" function, to be passed to subsequent calls of the same function';


--
-- TOC entry 719 (class 1247 OID 18609)
-- Name: delegation_chain_loop_tag; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE delegation_chain_loop_tag AS ENUM (
    'first',
    'intermediate',
    'last',
    'repetition'
);


--
-- TOC entry 3164 (class 0 OID 0)
-- Dependencies: 719
-- Name: TYPE delegation_chain_loop_tag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE delegation_chain_loop_tag IS 'Type for loop tags in "delegation_chain_row" type';


--
-- TOC entry 722 (class 1247 OID 18618)
-- Name: delegation_scope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE delegation_scope AS ENUM (
    'unit',
    'area',
    'issue'
);


--
-- TOC entry 3165 (class 0 OID 0)
-- Dependencies: 722
-- Name: TYPE delegation_scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE delegation_scope IS 'Scope for delegations: ''unit'', ''area'', or ''issue'' (order is relevant)';


--
-- TOC entry 725 (class 1247 OID 18627)
-- Name: delegation_chain_row; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE delegation_chain_row AS (
	index integer,
	member_id integer,
	member_valid boolean,
	participation boolean,
	overridden boolean,
	scope_in delegation_scope,
	scope_out delegation_scope,
	disabled_out boolean,
	loop delegation_chain_loop_tag
);


--
-- TOC entry 3166 (class 0 OID 0)
-- Dependencies: 725
-- Name: TYPE delegation_chain_row; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE delegation_chain_row IS 'Type of rows returned by "delegation_chain" function';


--
-- TOC entry 3167 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN delegation_chain_row.index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_chain_row.index IS 'Index starting with 0 and counting up';


--
-- TOC entry 3168 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN delegation_chain_row.participation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_chain_row.participation IS 'In case of delegation chains for issues: interest, for areas: membership, for global delegation chains: always null';


--
-- TOC entry 3169 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN delegation_chain_row.overridden; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_chain_row.overridden IS 'True, if an entry with lower index has "participation" set to true';


--
-- TOC entry 3170 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN delegation_chain_row.scope_in; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_chain_row.scope_in IS 'Scope of used incoming delegation';


--
-- TOC entry 3171 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN delegation_chain_row.scope_out; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_chain_row.scope_out IS 'Scope of used outgoing delegation';


--
-- TOC entry 3172 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN delegation_chain_row.disabled_out; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_chain_row.disabled_out IS 'Outgoing delegation is explicitly disabled by a delegation with trustee_id set to NULL';


--
-- TOC entry 3173 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN delegation_chain_row.loop; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_chain_row.loop IS 'Not null, if member is part of a loop, see "delegation_chain_loop_tag" type';


--
-- TOC entry 728 (class 1247 OID 18629)
-- Name: delegation_info_loop_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE delegation_info_loop_type AS ENUM (
    'own',
    'first',
    'first_ellipsis',
    'other',
    'other_ellipsis'
);


--
-- TOC entry 3174 (class 0 OID 0)
-- Dependencies: 728
-- Name: TYPE delegation_info_loop_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE delegation_info_loop_type IS 'Type of "delegation_loop" in "delegation_info_type"; ''own'' means loop to self, ''first'' means loop to first trustee, ''first_ellipsis'' means loop to ellipsis after first trustee, ''other'' means loop to other trustee, ''other_ellipsis'' means loop to ellipsis after other trustee''';


--
-- TOC entry 731 (class 1247 OID 18641)
-- Name: delegation_info_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE delegation_info_type AS (
	own_participation boolean,
	own_delegation_scope delegation_scope,
	first_trustee_id integer,
	first_trustee_participation boolean,
	first_trustee_ellipsis boolean,
	other_trustee_id integer,
	other_trustee_participation boolean,
	other_trustee_ellipsis boolean,
	delegation_loop delegation_info_loop_type,
	participating_member_id integer
);


--
-- TOC entry 3175 (class 0 OID 0)
-- Dependencies: 731
-- Name: TYPE delegation_info_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE delegation_info_type IS 'Type of result returned by "delegation_info" function; For meaning of "participation" check comment on "delegation_chain_row" type';


--
-- TOC entry 3176 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.own_participation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.own_participation IS 'Member is directly participating';


--
-- TOC entry 3177 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.own_delegation_scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.own_delegation_scope IS 'Delegation scope of member';


--
-- TOC entry 3178 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.first_trustee_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.first_trustee_id IS 'Direct trustee of member';


--
-- TOC entry 3179 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.first_trustee_participation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.first_trustee_participation IS 'Direct trustee of member is participating';


--
-- TOC entry 3180 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.first_trustee_ellipsis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.first_trustee_ellipsis IS 'Ellipsis in delegation chain after "first_trustee"';


--
-- TOC entry 3181 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.other_trustee_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.other_trustee_id IS 'Another relevant trustee (due to participation)';


--
-- TOC entry 3182 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.other_trustee_participation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.other_trustee_participation IS 'Another trustee is participating (redundant field: if "other_trustee_id" is set, then "other_trustee_participation" is always TRUE, else "other_trustee_participation" is NULL)';


--
-- TOC entry 3183 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.other_trustee_ellipsis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.other_trustee_ellipsis IS 'Ellipsis in delegation chain after "other_trustee"';


--
-- TOC entry 3184 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.delegation_loop; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.delegation_loop IS 'Non-NULL value, if delegation chain contains a circle; See comment on "delegation_info_loop_type" for details';


--
-- TOC entry 3185 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN delegation_info_type.participating_member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation_info_type.participating_member_id IS 'First participating member in delegation chain';


--
-- TOC entry 734 (class 1247 OID 18643)
-- Name: event_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE event_type AS ENUM (
    'issue_state_changed',
    'initiative_created_in_new_issue',
    'initiative_created_in_existing_issue',
    'initiative_revoked',
    'new_draft_created',
    'suggestion_created'
);


--
-- TOC entry 3186 (class 0 OID 0)
-- Dependencies: 734
-- Name: TYPE event_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE event_type IS 'Type used for column "event" of table "event"';


--
-- TOC entry 737 (class 1247 OID 18656)
-- Name: member_image_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE member_image_type AS ENUM (
    'photo',
    'avatar'
);


--
-- TOC entry 3187 (class 0 OID 0)
-- Dependencies: 737
-- Name: TYPE member_image_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE member_image_type IS 'Types of images for a member';


--
-- TOC entry 740 (class 1247 OID 18662)
-- Name: notify_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE notify_level AS ENUM (
    'none',
    'voting',
    'verification',
    'discussion',
    'all'
);


--
-- TOC entry 3188 (class 0 OID 0)
-- Dependencies: 740
-- Name: TYPE notify_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE notify_level IS 'Level of notification: ''none'' = no notifications, ''voting'' = notifications about finished issues and issues in voting, ''verification'' = notifications about finished issues, issues in voting and verification phase, ''discussion'' = notifications about everything except issues in admission phase, ''all'' = notifications about everything';


--
-- TOC entry 743 (class 1247 OID 18674)
-- Name: scan_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE scan_type AS ENUM (
    'id_front',
    'id_rear',
    'id_picture',
    'nin',
    'health_insurance'
);


--
-- TOC entry 746 (class 1247 OID 18686)
-- Name: snapshot_event; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE snapshot_event AS ENUM (
    'periodic',
    'end_of_admission',
    'half_freeze',
    'full_freeze'
);


--
-- TOC entry 3189 (class 0 OID 0)
-- Dependencies: 746
-- Name: TYPE snapshot_event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE snapshot_event IS 'Reason for snapshots: ''periodic'' = due to periodic recalculation, ''end_of_admission'' = saved state at end of admission period, ''half_freeze'' = saved state at end of discussion period, ''full_freeze'' = saved state at end of verification period';


--
-- TOC entry 293 (class 1255 OID 18695)
-- Name: add_vote_delegations(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION add_vote_delegations(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "member_id_v" "member"."id"%TYPE;
    BEGIN
      PERFORM "require_transaction_isolation"();
      FOR "member_id_v" IN
        SELECT "member_id" FROM "direct_voter"
        WHERE "issue_id" = "issue_id_p"
      LOOP
        UPDATE "direct_voter" SET
          "weight" = "weight" + "weight_of_added_vote_delegations"(
            "issue_id_p",
            "member_id_v",
            '{}'
          )
          WHERE "member_id" = "member_id_v"
          AND "issue_id" = "issue_id_p";
      END LOOP;
      RETURN;
    END;
  $$;


--
-- TOC entry 3190 (class 0 OID 0)
-- Dependencies: 293
-- Name: FUNCTION add_vote_delegations(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION add_vote_delegations(issue_id_p integer) IS 'Helper function for "close_voting" function';


--
-- TOC entry 294 (class 1255 OID 18696)
-- Name: autocreate_interest_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION autocreate_interest_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NOT EXISTS (
        SELECT NULL FROM "initiative" JOIN "interest"
        ON "initiative"."issue_id" = "interest"."issue_id"
        WHERE "initiative"."id" = NEW."initiative_id"
        AND "interest"."member_id" = NEW."member_id"
      ) THEN
        BEGIN
          INSERT INTO "interest" ("issue_id", "member_id")
            SELECT "issue_id", NEW."member_id"
            FROM "initiative" WHERE "id" = NEW."initiative_id";
        EXCEPTION WHEN unique_violation THEN END;
      END IF;
      RETURN NEW;
    END;
  $$;


--
-- TOC entry 3191 (class 0 OID 0)
-- Dependencies: 294
-- Name: FUNCTION autocreate_interest_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION autocreate_interest_trigger() IS 'Implementation of trigger "autocreate_interest" on table "supporter"';


--
-- TOC entry 307 (class 1255 OID 18697)
-- Name: autocreate_supporter_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION autocreate_supporter_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NOT EXISTS (
        SELECT NULL FROM "suggestion" JOIN "supporter"
        ON "suggestion"."initiative_id" = "supporter"."initiative_id"
        WHERE "suggestion"."id" = NEW."suggestion_id"
        AND "supporter"."member_id" = NEW."member_id"
      ) THEN
        BEGIN
          INSERT INTO "supporter" ("initiative_id", "member_id")
            SELECT "initiative_id", NEW."member_id"
            FROM "suggestion" WHERE "id" = NEW."suggestion_id";
        EXCEPTION WHEN unique_violation THEN END;
      END IF;
      RETURN NEW;
    END;
  $$;


--
-- TOC entry 3192 (class 0 OID 0)
-- Dependencies: 307
-- Name: FUNCTION autocreate_supporter_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION autocreate_supporter_trigger() IS 'Implementation of trigger "autocreate_supporter" on table "opinion"';


--
-- TOC entry 290 (class 1255 OID 18698)
-- Name: autofill_initiative_id_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION autofill_initiative_id_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NEW."initiative_id" ISNULL THEN
        SELECT "initiative_id" INTO NEW."initiative_id"
          FROM "suggestion" WHERE "id" = NEW."suggestion_id";
      END IF;
      RETURN NEW;
    END;
  $$;


--
-- TOC entry 3193 (class 0 OID 0)
-- Dependencies: 290
-- Name: FUNCTION autofill_initiative_id_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION autofill_initiative_id_trigger() IS 'Implementation of trigger "autofill_initiative_id" on table "opinion"';


--
-- TOC entry 291 (class 1255 OID 18699)
-- Name: autofill_issue_id_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION autofill_issue_id_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NEW."issue_id" ISNULL THEN
        SELECT "issue_id" INTO NEW."issue_id"
          FROM "initiative" WHERE "id" = NEW."initiative_id";
      END IF;
      RETURN NEW;
    END;
  $$;


--
-- TOC entry 3194 (class 0 OID 0)
-- Dependencies: 291
-- Name: FUNCTION autofill_issue_id_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION autofill_issue_id_trigger() IS 'Implementation of triggers "autofill_issue_id" on tables "supporter" and "vote"';


--
-- TOC entry 308 (class 1255 OID 18700)
-- Name: calculate_member_counts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION calculate_member_counts() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM "require_transaction_isolation"();
      DELETE FROM "member_count";
      INSERT INTO "member_count" ("total_count")
        SELECT "total_count" FROM "member_count_view";
      UPDATE "unit" SET "member_count" = "view"."member_count"
        FROM "unit_member_count" AS "view"
        WHERE "view"."unit_id" = "unit"."id";
      UPDATE "area" SET
        "direct_member_count" = "view"."direct_member_count",
        "member_weight"       = "view"."member_weight"
        FROM "area_member_count" AS "view"
        WHERE "view"."area_id" = "area"."id";
      RETURN;
    END;
  $$;


--
-- TOC entry 3195 (class 0 OID 0)
-- Dependencies: 308
-- Name: FUNCTION calculate_member_counts(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION calculate_member_counts() IS 'Updates "member_count" table and "member_count" column of table "area" by materializing data from views "member_count_view" and "area_member_count"';


--
-- TOC entry 309 (class 1255 OID 18701)
-- Name: calculate_ranks(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION calculate_ranks(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_row"         "issue"%ROWTYPE;
      "policy_row"        "policy"%ROWTYPE;
      "dimension_v"       INTEGER;
      "vote_matrix"       INT4[][];  -- absolute votes
      "matrix"            INT8[][];  -- defeat strength / best paths
      "i"                 INTEGER;
      "j"                 INTEGER;
      "k"                 INTEGER;
      "battle_row"        "battle"%ROWTYPE;
      "rank_ary"          INT4[];
      "rank_v"            INT4;
      "done_v"            INTEGER;
      "winners_ary"       INTEGER[];
      "initiative_id_v"   "initiative"."id"%TYPE;
    BEGIN
      PERFORM "require_transaction_isolation"();
      SELECT * INTO "issue_row"
        FROM "issue" WHERE "id" = "issue_id_p";
      SELECT * INTO "policy_row"
        FROM "policy" WHERE "id" = "issue_row"."policy_id";
      SELECT count(1) INTO "dimension_v"
        FROM "battle_participant" WHERE "issue_id" = "issue_id_p";
      -- Create "vote_matrix" with absolute number of votes in pairwise
      -- comparison:
      "vote_matrix" := array_fill(NULL::INT4, ARRAY["dimension_v", "dimension_v"]);
      "i" := 1;
      "j" := 2;
      FOR "battle_row" IN
        SELECT * FROM "battle" WHERE "issue_id" = "issue_id_p"
        ORDER BY
        "winning_initiative_id" NULLS LAST,
        "losing_initiative_id" NULLS LAST
      LOOP
        "vote_matrix"["i"]["j"] := "battle_row"."count";
        IF "j" = "dimension_v" THEN
          "i" := "i" + 1;
          "j" := 1;
        ELSE
          "j" := "j" + 1;
          IF "j" = "i" THEN
            "j" := "j" + 1;
          END IF;
        END IF;
      END LOOP;
      IF "i" != "dimension_v" OR "j" != "dimension_v" + 1 THEN
        RAISE EXCEPTION 'Wrong battle count (should not happen)';
      END IF;
      -- Store defeat strengths in "matrix" using "defeat_strength"
      -- function:
      "matrix" := array_fill(NULL::INT8, ARRAY["dimension_v", "dimension_v"]);
      "i" := 1;
      LOOP
        "j" := 1;
        LOOP
          IF "i" != "j" THEN
            "matrix"["i"]["j"] := "defeat_strength"(
              "vote_matrix"["i"]["j"],
              "vote_matrix"["j"]["i"]
            );
          END IF;
          EXIT WHEN "j" = "dimension_v";
          "j" := "j" + 1;
        END LOOP;
        EXIT WHEN "i" = "dimension_v";
        "i" := "i" + 1;
      END LOOP;
      -- Find best paths:
      "i" := 1;
      LOOP
        "j" := 1;
        LOOP
          IF "i" != "j" THEN
            "k" := 1;
            LOOP
              IF "i" != "k" AND "j" != "k" THEN
                IF "matrix"["j"]["i"] < "matrix"["i"]["k"] THEN
                  IF "matrix"["j"]["i"] > "matrix"["j"]["k"] THEN
                    "matrix"["j"]["k"] := "matrix"["j"]["i"];
                  END IF;
                ELSE
                  IF "matrix"["i"]["k"] > "matrix"["j"]["k"] THEN
                    "matrix"["j"]["k"] := "matrix"["i"]["k"];
                  END IF;
                END IF;
              END IF;
              EXIT WHEN "k" = "dimension_v";
              "k" := "k" + 1;
            END LOOP;
          END IF;
          EXIT WHEN "j" = "dimension_v";
          "j" := "j" + 1;
        END LOOP;
        EXIT WHEN "i" = "dimension_v";
        "i" := "i" + 1;
      END LOOP;
      -- Determine order of winners:
      "rank_ary" := array_fill(NULL::INT4, ARRAY["dimension_v"]);
      "rank_v" := 1;
      "done_v" := 0;
      LOOP
        "winners_ary" := '{}';
        "i" := 1;
        LOOP
          IF "rank_ary"["i"] ISNULL THEN
            "j" := 1;
            LOOP
              IF
                "i" != "j" AND
                "rank_ary"["j"] ISNULL AND
                "matrix"["j"]["i"] > "matrix"["i"]["j"]
              THEN
                -- someone else is better
                EXIT;
              END IF;
              IF "j" = "dimension_v" THEN
                -- noone is better
                "winners_ary" := "winners_ary" || "i";
                EXIT;
              END IF;
              "j" := "j" + 1;
            END LOOP;
          END IF;
          EXIT WHEN "i" = "dimension_v";
          "i" := "i" + 1;
        END LOOP;
        "i" := 1;
        LOOP
          "rank_ary"["winners_ary"["i"]] := "rank_v";
          "done_v" := "done_v" + 1;
          EXIT WHEN "i" = array_upper("winners_ary", 1);
          "i" := "i" + 1;
        END LOOP;
        EXIT WHEN "done_v" = "dimension_v";
        "rank_v" := "rank_v" + 1;
      END LOOP;
      -- write preliminary results:
      "i" := 1;
      FOR "initiative_id_v" IN
        SELECT "id" FROM "initiative"
        WHERE "issue_id" = "issue_id_p" AND "admitted"
        ORDER BY "id"
      LOOP
        UPDATE "initiative" SET
          "direct_majority" =
            CASE WHEN "policy_row"."direct_majority_strict" THEN
              "positive_votes" * "policy_row"."direct_majority_den" >
              "policy_row"."direct_majority_num" * ("positive_votes"+"negative_votes")
            ELSE
              "positive_votes" * "policy_row"."direct_majority_den" >=
              "policy_row"."direct_majority_num" * ("positive_votes"+"negative_votes")
            END
            AND "positive_votes" >= "policy_row"."direct_majority_positive"
            AND "issue_row"."voter_count"-"negative_votes" >=
                "policy_row"."direct_majority_non_negative",
            "indirect_majority" =
            CASE WHEN "policy_row"."indirect_majority_strict" THEN
              "positive_votes" * "policy_row"."indirect_majority_den" >
              "policy_row"."indirect_majority_num" * ("positive_votes"+"negative_votes")
            ELSE
              "positive_votes" * "policy_row"."indirect_majority_den" >=
              "policy_row"."indirect_majority_num" * ("positive_votes"+"negative_votes")
            END
            AND "positive_votes" >= "policy_row"."indirect_majority_positive"
            AND "issue_row"."voter_count"-"negative_votes" >=
                "policy_row"."indirect_majority_non_negative",
          "schulze_rank"           = "rank_ary"["i"],
          "better_than_status_quo" = "rank_ary"["i"] < "rank_ary"["dimension_v"],
          "worse_than_status_quo"  = "rank_ary"["i"] > "rank_ary"["dimension_v"],
          "multistage_majority"    = "rank_ary"["i"] >= "rank_ary"["dimension_v"],
          "reverse_beat_path"      = "matrix"["dimension_v"]["i"] >= 0,
          "eligible"               = FALSE,
          "winner"                 = FALSE,
          "rank"                   = NULL  -- NOTE: in cases of manual reset of issue state
          WHERE "id" = "initiative_id_v";
        "i" := "i" + 1;
      END LOOP;
      IF "i" != "dimension_v" THEN
        RAISE EXCEPTION 'Wrong winner count (should not happen)';
      END IF;
      -- take indirect majorities into account:
      LOOP
        UPDATE "initiative" SET "indirect_majority" = TRUE
          FROM (
            SELECT "new_initiative"."id" AS "initiative_id"
            FROM "initiative" "old_initiative"
            JOIN "initiative" "new_initiative"
              ON "new_initiative"."issue_id" = "issue_id_p"
              AND "new_initiative"."indirect_majority" = FALSE
            JOIN "battle" "battle_win"
              ON "battle_win"."issue_id" = "issue_id_p"
              AND "battle_win"."winning_initiative_id" = "new_initiative"."id"
              AND "battle_win"."losing_initiative_id" = "old_initiative"."id"
            JOIN "battle" "battle_lose"
              ON "battle_lose"."issue_id" = "issue_id_p"
              AND "battle_lose"."losing_initiative_id" = "new_initiative"."id"
              AND "battle_lose"."winning_initiative_id" = "old_initiative"."id"
            WHERE "old_initiative"."issue_id" = "issue_id_p"
            AND "old_initiative"."indirect_majority" = TRUE
            AND CASE WHEN "policy_row"."indirect_majority_strict" THEN
              "battle_win"."count" * "policy_row"."indirect_majority_den" >
              "policy_row"."indirect_majority_num" *
              ("battle_win"."count"+"battle_lose"."count")
            ELSE
              "battle_win"."count" * "policy_row"."indirect_majority_den" >=
              "policy_row"."indirect_majority_num" *
              ("battle_win"."count"+"battle_lose"."count")
            END
            AND "battle_win"."count" >= "policy_row"."indirect_majority_positive"
            AND "issue_row"."voter_count"-"battle_lose"."count" >=
                "policy_row"."indirect_majority_non_negative"
          ) AS "subquery"
          WHERE "id" = "subquery"."initiative_id";
        EXIT WHEN NOT FOUND;
      END LOOP;
      -- set "multistage_majority" for remaining matching initiatives:
      UPDATE "initiative" SET "multistage_majority" = TRUE
        FROM (
          SELECT "losing_initiative"."id" AS "initiative_id"
          FROM "initiative" "losing_initiative"
          JOIN "initiative" "winning_initiative"
            ON "winning_initiative"."issue_id" = "issue_id_p"
            AND "winning_initiative"."admitted"
          JOIN "battle" "battle_win"
            ON "battle_win"."issue_id" = "issue_id_p"
            AND "battle_win"."winning_initiative_id" = "winning_initiative"."id"
            AND "battle_win"."losing_initiative_id" = "losing_initiative"."id"
          JOIN "battle" "battle_lose"
            ON "battle_lose"."issue_id" = "issue_id_p"
            AND "battle_lose"."losing_initiative_id" = "winning_initiative"."id"
            AND "battle_lose"."winning_initiative_id" = "losing_initiative"."id"
          WHERE "losing_initiative"."issue_id" = "issue_id_p"
          AND "losing_initiative"."admitted"
          AND "winning_initiative"."schulze_rank" <
              "losing_initiative"."schulze_rank"
          AND "battle_win"."count" > "battle_lose"."count"
          AND (
            "battle_win"."count" > "winning_initiative"."positive_votes" OR
            "battle_lose"."count" < "losing_initiative"."negative_votes" )
        ) AS "subquery"
        WHERE "id" = "subquery"."initiative_id";
      -- mark eligible initiatives:
      UPDATE "initiative" SET "eligible" = TRUE
        WHERE "issue_id" = "issue_id_p"
        AND "initiative"."direct_majority"
        AND "initiative"."indirect_majority"
        AND "initiative"."better_than_status_quo"
        AND (
          "policy_row"."no_multistage_majority" = FALSE OR
          "initiative"."multistage_majority" = FALSE )
        AND (
          "policy_row"."no_reverse_beat_path" = FALSE OR
          "initiative"."reverse_beat_path" = FALSE );
      -- mark final winner:
      UPDATE "initiative" SET "winner" = TRUE
        FROM (
          SELECT "id" AS "initiative_id"
          FROM "initiative"
          WHERE "issue_id" = "issue_id_p" AND "eligible"
          ORDER BY
            "schulze_rank",
            "id"
          LIMIT 1
        ) AS "subquery"
        WHERE "id" = "subquery"."initiative_id";
      -- write (final) ranks:
      "rank_v" := 1;
      FOR "initiative_id_v" IN
        SELECT "id"
        FROM "initiative"
        WHERE "issue_id" = "issue_id_p" AND "admitted"
        ORDER BY
          "winner" DESC,
          "eligible" DESC,
          "schulze_rank",
          "id"
      LOOP
        UPDATE "initiative" SET "rank" = "rank_v"
          WHERE "id" = "initiative_id_v";
        "rank_v" := "rank_v" + 1;
      END LOOP;
      -- set schulze rank of status quo and mark issue as finished:
      UPDATE "issue" SET
        "status_quo_schulze_rank" = "rank_ary"["dimension_v"],
        "state" =
          CASE WHEN EXISTS (
            SELECT NULL FROM "initiative"
            WHERE "issue_id" = "issue_id_p" AND "winner"
          ) THEN
            'finished_with_winner'::"issue_state"
          ELSE
            'finished_without_winner'::"issue_state"
          END,
        "closed" = "phase_finished",
        "phase_finished" = NULL
        WHERE "id" = "issue_id_p";
      RETURN;
    END;
  $$;


--
-- TOC entry 3196 (class 0 OID 0)
-- Dependencies: 309
-- Name: FUNCTION calculate_ranks(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION calculate_ranks(issue_id_p integer) IS 'Determine ranking (Votes have to be counted first)';


--
-- TOC entry 310 (class 1255 OID 18703)
-- Name: check_activity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_activity() RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "system_setting_row" "system_setting"%ROWTYPE;
    BEGIN
      PERFORM "dont_require_transaction_isolation"();
      SELECT * INTO "system_setting_row" FROM "system_setting";
      IF "system_setting_row"."member_ttl" NOTNULL THEN
        UPDATE "member" SET "active" = FALSE
          WHERE "active" = TRUE
          AND "last_activity" < (now() - "system_setting_row"."member_ttl")::DATE;
      END IF;
      RETURN;
    END;
  $$;


--
-- TOC entry 3197 (class 0 OID 0)
-- Dependencies: 310
-- Name: FUNCTION check_activity(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION check_activity() IS 'Deactivates members when "last_activity" is older than "system_setting"."member_ttl".';


--
-- TOC entry 311 (class 1255 OID 18704)
-- Name: check_everything(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_everything() RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_id_v" "issue"."id"%TYPE;
      "persist_v"  "check_issue_persistence";
    BEGIN
      RAISE WARNING 'Function "check_everything" should only be used for development and debugging purposes';
      DELETE FROM "expired_session";
      PERFORM "check_activity"();
      PERFORM "calculate_member_counts"();
      FOR "issue_id_v" IN SELECT "id" FROM "open_issue" LOOP
        "persist_v" := NULL;
        LOOP
          "persist_v" := "check_issue"("issue_id_v", "persist_v");
          EXIT WHEN "persist_v" ISNULL;
        END LOOP;
      END LOOP;
      RETURN;
    END;
  $$;


--
-- TOC entry 3198 (class 0 OID 0)
-- Dependencies: 311
-- Name: FUNCTION check_everything(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION check_everything() IS 'Amongst other regular tasks this function performs "check_issue" for every open issue. Use this function only for development and debugging purposes, as you may run into locking and/or serialization problems in productive environments.';


--
-- TOC entry 312 (class 1255 OID 18705)
-- Name: check_issue(integer, check_issue_persistence); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_issue(issue_id_p integer, persist check_issue_persistence) RETURNS check_issue_persistence
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_row"      "issue"%ROWTYPE;
      "policy_row"     "policy"%ROWTYPE;
      "initiative_row" "initiative"%ROWTYPE;
      "state_v"        "issue_state";
    BEGIN
      PERFORM "require_transaction_isolation"();
      IF "persist" ISNULL THEN
        SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p"
          FOR UPDATE;
        IF "issue_row"."closed" NOTNULL THEN
          RETURN NULL;
        END IF;
        "persist"."state" := "issue_row"."state";
        IF
          ( "issue_row"."state" = 'admission' AND now() >=
            "issue_row"."created" + "issue_row"."admission_time" ) OR
          ( "issue_row"."state" = 'discussion' AND now() >=
            "issue_row"."accepted" + "issue_row"."discussion_time" ) OR
          ( "issue_row"."state" = 'verification' AND now() >=
            "issue_row"."half_frozen" + "issue_row"."verification_time" ) OR
          ( "issue_row"."state" = 'voting' AND now() >=
            "issue_row"."fully_frozen" + "issue_row"."voting_time" )
        THEN
          "persist"."phase_finished" := TRUE;
        ELSE
          "persist"."phase_finished" := FALSE;
        END IF;
        IF
          NOT EXISTS (
            -- all initiatives are revoked
            SELECT NULL FROM "initiative"
            WHERE "issue_id" = "issue_id_p" AND "revoked" ISNULL
          ) AND (
            -- and issue has not been accepted yet
            "persist"."state" = 'admission' OR
            -- or verification time has elapsed
            ( "persist"."state" = 'verification' AND
              "persist"."phase_finished" ) OR
            -- or no initiatives have been revoked lately
            NOT EXISTS (
              SELECT NULL FROM "initiative"
              WHERE "issue_id" = "issue_id_p"
              AND now() < "revoked" + "issue_row"."verification_time"
            )
          )
        THEN
          "persist"."issue_revoked" := TRUE;
        ELSE
          "persist"."issue_revoked" := FALSE;
        END IF;
        IF "persist"."phase_finished" OR "persist"."issue_revoked" THEN
          UPDATE "issue" SET "phase_finished" = now()
            WHERE "id" = "issue_row"."id";
          RETURN "persist";
        ELSIF
          "persist"."state" IN ('admission', 'discussion', 'verification')
        THEN
          RETURN "persist";
        ELSE
          RETURN NULL;
        END IF;
      END IF;
      IF
        "persist"."state" IN ('admission', 'discussion', 'verification') AND
        coalesce("persist"."snapshot_created", FALSE) = FALSE
      THEN
        PERFORM "create_snapshot"("issue_id_p");
        "persist"."snapshot_created" = TRUE;
        IF "persist"."phase_finished" THEN
          IF "persist"."state" = 'admission' THEN
            PERFORM "set_snapshot_event"("issue_id_p", 'end_of_admission');
          ELSIF "persist"."state" = 'discussion' THEN
            PERFORM "set_snapshot_event"("issue_id_p", 'half_freeze');
          ELSIF "persist"."state" = 'verification' THEN
            PERFORM "set_snapshot_event"("issue_id_p", 'full_freeze');
            SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p";
            SELECT * INTO "policy_row" FROM "policy"
              WHERE "id" = "issue_row"."policy_id";
            FOR "initiative_row" IN
              SELECT * FROM "initiative"
              WHERE "issue_id" = "issue_id_p" AND "revoked" ISNULL
              FOR UPDATE
            LOOP
              IF
                "initiative_row"."polling" OR (
                  "initiative_row"."satisfied_supporter_count" > 0 AND
                  "initiative_row"."satisfied_supporter_count" *
                  "policy_row"."initiative_quorum_den" >=
                  "issue_row"."population" * "policy_row"."initiative_quorum_num"
                )
              THEN
                UPDATE "initiative" SET "admitted" = TRUE
                  WHERE "id" = "initiative_row"."id";
              ELSE
                UPDATE "initiative" SET "admitted" = FALSE
                  WHERE "id" = "initiative_row"."id";
              END IF;
            END LOOP;
          END IF;
        END IF;
        RETURN "persist";
      END IF;
      IF
        "persist"."state" IN ('admission', 'discussion', 'verification') AND
        coalesce("persist"."harmonic_weights_set", FALSE) = FALSE
      THEN
        PERFORM "set_harmonic_initiative_weights"("issue_id_p");
        "persist"."harmonic_weights_set" = TRUE;
        IF
          "persist"."phase_finished" OR
          "persist"."issue_revoked" OR
          "persist"."state" = 'admission'
        THEN
          RETURN "persist";
        ELSE
          RETURN NULL;
        END IF;
      END IF;
      IF "persist"."issue_revoked" THEN
        IF "persist"."state" = 'admission' THEN
          "state_v" := 'canceled_revoked_before_accepted';
        ELSIF "persist"."state" = 'discussion' THEN
          "state_v" := 'canceled_after_revocation_during_discussion';
        ELSIF "persist"."state" = 'verification' THEN
          "state_v" := 'canceled_after_revocation_during_verification';
        END IF;
        UPDATE "issue" SET
          "state"          = "state_v",
          "closed"         = "phase_finished",
          "phase_finished" = NULL
          WHERE "id" = "issue_id_p";
        RETURN NULL;
      END IF;
      IF "persist"."state" = 'admission' THEN
        SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p"
          FOR UPDATE;
        SELECT * INTO "policy_row"
          FROM "policy" WHERE "id" = "issue_row"."policy_id";
        IF EXISTS (
          SELECT NULL FROM "initiative"
          WHERE "issue_id" = "issue_id_p"
          AND "supporter_count" > 0
          AND "supporter_count" * "policy_row"."issue_quorum_den"
          >= "issue_row"."population" * "policy_row"."issue_quorum_num"
        ) THEN
          UPDATE "issue" SET
            "state"          = 'discussion',
            "accepted"       = coalesce("phase_finished", now()),
            "phase_finished" = NULL
            WHERE "id" = "issue_id_p";
        ELSIF "issue_row"."phase_finished" NOTNULL THEN
          UPDATE "issue" SET
            "state"          = 'canceled_issue_not_accepted',
            "closed"         = "phase_finished",
            "phase_finished" = NULL
            WHERE "id" = "issue_id_p";
        END IF;
        RETURN NULL;
      END IF;
      IF "persist"."phase_finished" THEN
        if "persist"."state" = 'discussion' THEN
          UPDATE "issue" SET
            "state"          = 'verification',
            "half_frozen"    = "phase_finished",
            "phase_finished" = NULL
            WHERE "id" = "issue_id_p";
          RETURN NULL;
        END IF;
        IF "persist"."state" = 'verification' THEN
          SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p"
            FOR UPDATE;
          SELECT * INTO "policy_row" FROM "policy"
            WHERE "id" = "issue_row"."policy_id";
          IF EXISTS (
            SELECT NULL FROM "initiative"
            WHERE "issue_id" = "issue_id_p" AND "admitted" = TRUE
          ) THEN
            UPDATE "issue" SET
              "state"          = 'voting',
              "fully_frozen"   = "phase_finished",
              "phase_finished" = NULL
              WHERE "id" = "issue_id_p";
          ELSE
            UPDATE "issue" SET
              "state"          = 'canceled_no_initiative_admitted',
              "fully_frozen"   = "phase_finished",
              "closed"         = "phase_finished",
              "phase_finished" = NULL
              WHERE "id" = "issue_id_p";
            -- NOTE: The following DELETE statements have effect only when
            --       issue state has been manipulated
            DELETE FROM "direct_voter"     WHERE "issue_id" = "issue_id_p";
            DELETE FROM "delegating_voter" WHERE "issue_id" = "issue_id_p";
            DELETE FROM "battle"           WHERE "issue_id" = "issue_id_p";
          END IF;
          RETURN NULL;
        END IF;
        IF "persist"."state" = 'voting' THEN
          IF coalesce("persist"."closed_voting", FALSE) = FALSE THEN
            PERFORM "close_voting"("issue_id_p");
            "persist"."closed_voting" = TRUE;
            RETURN "persist";
          END IF;
          PERFORM "calculate_ranks"("issue_id_p");
          RETURN NULL;
        END IF;
      END IF;
      RAISE WARNING 'should not happen';
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3199 (class 0 OID 0)
-- Dependencies: 312
-- Name: FUNCTION check_issue(issue_id_p integer, persist check_issue_persistence); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION check_issue(issue_id_p integer, persist check_issue_persistence) IS 'Precalculate supporter counts etc. for a given issue, and check, if status change is required, and perform the status change when necessary; Function must be called multiple times with the previous result as second parameter, until the result is NULL (see source code of function "check_everything")';


--
-- TOC entry 313 (class 1255 OID 18707)
-- Name: clean_issue(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION clean_issue(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_row" "issue"%ROWTYPE;
    BEGIN
      SELECT * INTO "issue_row"
        FROM "issue" WHERE "id" = "issue_id_p"
        FOR UPDATE;
      IF "issue_row"."cleaned" ISNULL THEN
        UPDATE "issue" SET
          "state"  = 'voting',
          "closed" = NULL
          WHERE "id" = "issue_id_p";
        DELETE FROM "delegating_voter"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "direct_voter"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegating_interest_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "direct_interest_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegating_population_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "direct_population_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "non_voter"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegation"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "supporter"
          USING "initiative"  -- NOTE: due to missing index on issue_id
          WHERE "initiative"."issue_id" = "issue_id_p"
          AND "supporter"."initiative_id" = "initiative_id";
        UPDATE "issue" SET
          "state"   = "issue_row"."state",
          "closed"  = "issue_row"."closed",
          "cleaned" = now()
          WHERE "id" = "issue_id_p";
      END IF;
      RETURN;
    END;
  $$;


--
-- TOC entry 3200 (class 0 OID 0)
-- Dependencies: 313
-- Name: FUNCTION clean_issue(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION clean_issue(issue_id_p integer) IS 'Delete discussion data and votes belonging to an issue';


--
-- TOC entry 314 (class 1255 OID 18708)
-- Name: close_voting(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION close_voting(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "area_id_v"   "area"."id"%TYPE;
      "unit_id_v"   "unit"."id"%TYPE;
      "member_id_v" "member"."id"%TYPE;
    BEGIN
      PERFORM "require_transaction_isolation"();
      SELECT "area_id" INTO "area_id_v" FROM "issue" WHERE "id" = "issue_id_p";
      SELECT "unit_id" INTO "unit_id_v" FROM "area"  WHERE "id" = "area_id_v";
      -- delete timestamp of voting comment:
      UPDATE "direct_voter" SET "comment_changed" = NULL
        WHERE "issue_id" = "issue_id_p";
      -- delete delegating votes (in cases of manual reset of issue state):
      DELETE FROM "delegating_voter"
        WHERE "issue_id" = "issue_id_p";
      -- delete votes from non-privileged voters:
      DELETE FROM "direct_voter"
        USING (
          SELECT
            "direct_voter"."member_id"
          FROM "direct_voter"
          JOIN "member" ON "direct_voter"."member_id" = "member"."id"
          LEFT JOIN "privilege"
          ON "privilege"."unit_id" = "unit_id_v"
          AND "privilege"."member_id" = "direct_voter"."member_id"
          WHERE "direct_voter"."issue_id" = "issue_id_p" AND (
            "member"."active" = FALSE OR
            "privilege"."voting_right" ISNULL OR
            "privilege"."voting_right" = FALSE
          )
        ) AS "subquery"
        WHERE "direct_voter"."issue_id" = "issue_id_p"
        AND "direct_voter"."member_id" = "subquery"."member_id";
      -- consider delegations:
      UPDATE "direct_voter" SET "weight" = 1
        WHERE "issue_id" = "issue_id_p";
      PERFORM "add_vote_delegations"("issue_id_p");
      -- materialize battle_view:
      -- NOTE: "closed" column of issue must be set at this point
      DELETE FROM "battle" WHERE "issue_id" = "issue_id_p";
      INSERT INTO "battle" (
        "issue_id",
        "winning_initiative_id", "losing_initiative_id",
        "count"
      ) SELECT
        "issue_id",
        "winning_initiative_id", "losing_initiative_id",
        "count"
        FROM "battle_view" WHERE "issue_id" = "issue_id_p";
      -- set voter count:
      UPDATE "issue" SET
        "voter_count" = (
          SELECT coalesce(sum("weight"), 0)
          FROM "direct_voter" WHERE "issue_id" = "issue_id_p"
        )
        WHERE "id" = "issue_id_p";
      -- copy "positive_votes" and "negative_votes" from "battle" table:
      UPDATE "initiative" SET
        "positive_votes" = "battle_win"."count",
        "negative_votes" = "battle_lose"."count"
        FROM "battle" AS "battle_win", "battle" AS "battle_lose"
        WHERE
          "battle_win"."issue_id" = "issue_id_p" AND
          "battle_win"."winning_initiative_id" = "initiative"."id" AND
          "battle_win"."losing_initiative_id" ISNULL AND
          "battle_lose"."issue_id" = "issue_id_p" AND
          "battle_lose"."losing_initiative_id" = "initiative"."id" AND
          "battle_lose"."winning_initiative_id" ISNULL;
    END;
  $$;


--
-- TOC entry 3201 (class 0 OID 0)
-- Dependencies: 314
-- Name: FUNCTION close_voting(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION close_voting(issue_id_p integer) IS 'Closes the voting on an issue, and calculates positive and negative votes for each initiative; The ranking is not calculated yet, to keep the (locking) transaction short.';


--
-- TOC entry 315 (class 1255 OID 18709)
-- Name: copy_timings_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_timings_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "policy_row" "policy"%ROWTYPE;
    BEGIN
      SELECT * INTO "policy_row" FROM "policy"
        WHERE "id" = NEW."policy_id";
      IF NEW."admission_time" ISNULL THEN
        NEW."admission_time" := "policy_row"."admission_time";
      END IF;
      IF NEW."discussion_time" ISNULL THEN
        NEW."discussion_time" := "policy_row"."discussion_time";
      END IF;
      IF NEW."verification_time" ISNULL THEN
        NEW."verification_time" := "policy_row"."verification_time";
      END IF;
      IF NEW."voting_time" ISNULL THEN
        NEW."voting_time" := "policy_row"."voting_time";
      END IF;
      RETURN NEW;
    END;
  $$;


--
-- TOC entry 3202 (class 0 OID 0)
-- Dependencies: 315
-- Name: FUNCTION copy_timings_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION copy_timings_trigger() IS 'Implementation of trigger "copy_timings" on table "issue"';


--
-- TOC entry 316 (class 1255 OID 18710)
-- Name: create_interest_snapshot(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_interest_snapshot(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "member_id_v" "member"."id"%TYPE;
    BEGIN
      PERFORM "require_transaction_isolation"();
      DELETE FROM "direct_interest_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic';
      DELETE FROM "delegating_interest_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic';
      DELETE FROM "direct_supporter_snapshot"
        USING "initiative"  -- NOTE: due to missing index on issue_id
        WHERE "initiative"."issue_id" = "issue_id_p"
        AND "direct_supporter_snapshot"."initiative_id" = "initiative"."id"
        AND "direct_supporter_snapshot"."event" = 'periodic';
      INSERT INTO "direct_interest_snapshot"
        ("issue_id", "event", "member_id")
        SELECT
          "issue_id_p"  AS "issue_id",
          'periodic'    AS "event",
          "member"."id" AS "member_id"
        FROM "issue"
        JOIN "area" ON "issue"."area_id" = "area"."id"
        JOIN "interest" ON "issue"."id" = "interest"."issue_id"
        JOIN "member" ON "interest"."member_id" = "member"."id"
        JOIN "privilege"
          ON "privilege"."unit_id" = "area"."unit_id"
          AND "privilege"."member_id" = "member"."id"
        WHERE "issue"."id" = "issue_id_p"
        AND "member"."active" AND "privilege"."voting_right";
      FOR "member_id_v" IN
        SELECT "member_id" FROM "direct_interest_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic'
      LOOP
        UPDATE "direct_interest_snapshot" SET
          "weight" = 1 +
            "weight_of_added_delegations_for_interest_snapshot"(
              "issue_id_p",
              "member_id_v",
              '{}'
            )
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
          AND "member_id" = "member_id_v";
      END LOOP;
      INSERT INTO "direct_supporter_snapshot"
        ( "issue_id", "initiative_id", "event", "member_id",
          "draft_id", "informed", "satisfied" )
        SELECT
          "issue_id_p"            AS "issue_id",
          "initiative"."id"       AS "initiative_id",
          'periodic'              AS "event",
          "supporter"."member_id" AS "member_id",
          "supporter"."draft_id"  AS "draft_id",
          "supporter"."draft_id" = "current_draft"."id" AS "informed",
          NOT EXISTS (
            SELECT NULL FROM "critical_opinion"
            WHERE "initiative_id" = "initiative"."id"
            AND "member_id" = "supporter"."member_id"
          ) AS "satisfied"
        FROM "initiative"
        JOIN "supporter"
        ON "supporter"."initiative_id" = "initiative"."id"
        JOIN "current_draft"
        ON "initiative"."id" = "current_draft"."initiative_id"
        JOIN "direct_interest_snapshot"
        ON "supporter"."member_id" = "direct_interest_snapshot"."member_id"
        AND "initiative"."issue_id" = "direct_interest_snapshot"."issue_id"
        AND "event" = 'periodic'
        WHERE "initiative"."issue_id" = "issue_id_p";
      RETURN;
    END;
  $$;


--
-- TOC entry 3203 (class 0 OID 0)
-- Dependencies: 316
-- Name: FUNCTION create_interest_snapshot(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION create_interest_snapshot(issue_id_p integer) IS 'This function creates a new ''periodic'' interest/supporter snapshot for the given issue. It does neither lock any tables, nor updates precalculated values in other tables.';


--
-- TOC entry 318 (class 1255 OID 18711)
-- Name: create_population_snapshot(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_population_snapshot(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "member_id_v" "member"."id"%TYPE;
    BEGIN
      PERFORM "require_transaction_isolation"();
      DELETE FROM "direct_population_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic';
      DELETE FROM "delegating_population_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic';
      INSERT INTO "direct_population_snapshot"
        ("issue_id", "event", "member_id")
        SELECT
          "issue_id_p"                 AS "issue_id",
          'periodic'::"snapshot_event" AS "event",
          "member"."id"                AS "member_id"
        FROM "issue"
        JOIN "area" ON "issue"."area_id" = "area"."id"
        JOIN "membership" ON "area"."id" = "membership"."area_id"
        JOIN "member" ON "membership"."member_id" = "member"."id"
        JOIN "privilege"
          ON "privilege"."unit_id" = "area"."unit_id"
          AND "privilege"."member_id" = "member"."id"
        WHERE "issue"."id" = "issue_id_p"
        AND "member"."active" AND "privilege"."voting_right"
        UNION
        SELECT
          "issue_id_p"                 AS "issue_id",
          'periodic'::"snapshot_event" AS "event",
          "member"."id"                AS "member_id"
        FROM "issue"
        JOIN "area" ON "issue"."area_id" = "area"."id"
        JOIN "interest" ON "issue"."id" = "interest"."issue_id"
        JOIN "member" ON "interest"."member_id" = "member"."id"
        JOIN "privilege"
          ON "privilege"."unit_id" = "area"."unit_id"
          AND "privilege"."member_id" = "member"."id"
        WHERE "issue"."id" = "issue_id_p"
        AND "member"."active" AND "privilege"."voting_right";
      FOR "member_id_v" IN
        SELECT "member_id" FROM "direct_population_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic'
      LOOP
        UPDATE "direct_population_snapshot" SET
          "weight" = 1 +
            "weight_of_added_delegations_for_population_snapshot"(
              "issue_id_p",
              "member_id_v",
              '{}'
            )
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
          AND "member_id" = "member_id_v";
      END LOOP;
      RETURN;
    END;
  $$;


--
-- TOC entry 3204 (class 0 OID 0)
-- Dependencies: 318
-- Name: FUNCTION create_population_snapshot(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION create_population_snapshot(issue_id_p integer) IS 'This function creates a new ''periodic'' population snapshot for the given issue. It does neither lock any tables, nor updates precalculated values in other tables.';


--
-- TOC entry 319 (class 1255 OID 18712)
-- Name: create_snapshot(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_snapshot(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "initiative_id_v"    "initiative"."id"%TYPE;
      "suggestion_id_v"    "suggestion"."id"%TYPE;
    BEGIN
      PERFORM "require_transaction_isolation"();
      PERFORM "create_population_snapshot"("issue_id_p");
      PERFORM "create_interest_snapshot"("issue_id_p");
      UPDATE "issue" SET
        "snapshot" = coalesce("phase_finished", now()),
        "latest_snapshot_event" = 'periodic',
        "population" = (
          SELECT coalesce(sum("weight"), 0)
          FROM "direct_population_snapshot"
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
        )
        WHERE "id" = "issue_id_p";
      FOR "initiative_id_v" IN
        SELECT "id" FROM "initiative" WHERE "issue_id" = "issue_id_p"
      LOOP
        UPDATE "initiative" SET
          "supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
          ),
          "informed_supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
            AND "ds"."informed"
          ),
          "satisfied_supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
            AND "ds"."satisfied"
          ),
          "satisfied_informed_supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
            AND "ds"."informed"
            AND "ds"."satisfied"
          )
          WHERE "id" = "initiative_id_v";
        FOR "suggestion_id_v" IN
          SELECT "id" FROM "suggestion"
          WHERE "initiative_id" = "initiative_id_v"
        LOOP
          UPDATE "suggestion" SET
            "minus2_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -2
              AND "opinion"."fulfilled" = FALSE
            ),
            "minus2_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -2
              AND "opinion"."fulfilled" = TRUE
            ),
            "minus1_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -1
              AND "opinion"."fulfilled" = FALSE
            ),
            "minus1_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -1
              AND "opinion"."fulfilled" = TRUE
            ),
            "plus1_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 1
              AND "opinion"."fulfilled" = FALSE
            ),
            "plus1_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 1
              AND "opinion"."fulfilled" = TRUE
            ),
            "plus2_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 2
              AND "opinion"."fulfilled" = FALSE
            ),
            "plus2_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 2
              AND "opinion"."fulfilled" = TRUE
            )
            WHERE "suggestion"."id" = "suggestion_id_v";
        END LOOP;
      END LOOP;
      RETURN;
    END;
  $$;


--
-- TOC entry 3205 (class 0 OID 0)
-- Dependencies: 319
-- Name: FUNCTION create_snapshot(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION create_snapshot(issue_id_p integer) IS 'This function creates a complete new ''periodic'' snapshot of population, interest and support for the given issue. All involved tables are locked, and after completion precalculated values in the source tables are updated.';


--
-- TOC entry 320 (class 1255 OID 18713)
-- Name: default_for_draft_id_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION default_for_draft_id_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NEW."draft_id" ISNULL THEN
        SELECT "id" INTO NEW."draft_id" FROM "current_draft"
          WHERE "initiative_id" = NEW."initiative_id";
      END IF;
      RETURN NEW;
    END;
  $$;


--
-- TOC entry 3206 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION default_for_draft_id_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION default_for_draft_id_trigger() IS 'Implementation of trigger "default_for_draft" on tables "supporter" and "suggestion"';


--
-- TOC entry 321 (class 1255 OID 18714)
-- Name: defeat_strength(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION defeat_strength(positive_votes_p integer, negative_votes_p integer) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    BEGIN
      IF "positive_votes_p" > "negative_votes_p" THEN
        RETURN ("positive_votes_p"::INT8 << 31) - "negative_votes_p"::INT8;
      ELSIF "positive_votes_p" = "negative_votes_p" THEN
        RETURN 0;
      ELSE
        RETURN -1;
      END IF;
    END;
  $$;


--
-- TOC entry 3207 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION defeat_strength(positive_votes_p integer, negative_votes_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION defeat_strength(positive_votes_p integer, negative_votes_p integer) IS 'Calculates defeat strength (INT8!) of a pairwise defeat primarily by the absolute number of votes for the winner and secondarily by the absolute number of votes for the loser';


--
-- TOC entry 322 (class 1255 OID 18715)
-- Name: delegation_chain(integer, integer, integer, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delegation_chain(member_id_p integer, unit_id_p integer, area_id_p integer, issue_id_p integer, simulate_trustee_id_p integer DEFAULT NULL::integer, simulate_default_p boolean DEFAULT false) RETURNS SETOF delegation_chain_row
    LANGUAGE plpgsql STABLE
    AS $$
    DECLARE
      "scope_v"            "delegation_scope";
      "unit_id_v"          "unit"."id"%TYPE;
      "area_id_v"          "area"."id"%TYPE;
      "issue_row"          "issue"%ROWTYPE;
      "visited_member_ids" INT4[];  -- "member"."id"%TYPE[]
      "loop_member_id_v"   "member"."id"%TYPE;
      "output_row"         "delegation_chain_row";
      "output_rows"        "delegation_chain_row"[];
      "simulate_v"         BOOLEAN;
      "simulate_here_v"    BOOLEAN;
      "delegation_row"     "delegation"%ROWTYPE;
      "row_count"          INT4;
      "i"                  INT4;
      "loop_v"             BOOLEAN;
    BEGIN
      IF "simulate_trustee_id_p" NOTNULL AND "simulate_default_p" THEN
        RAISE EXCEPTION 'Both "simulate_trustee_id_p" is set, and "simulate_default_p" is true';
      END IF;
      IF "simulate_trustee_id_p" NOTNULL OR "simulate_default_p" THEN
        "simulate_v" := TRUE;
      ELSE
        "simulate_v" := FALSE;
      END IF;
      IF
        "unit_id_p" NOTNULL AND
        "area_id_p" ISNULL AND
        "issue_id_p" ISNULL
      THEN
        "scope_v" := 'unit';
        "unit_id_v" := "unit_id_p";
      ELSIF
        "unit_id_p" ISNULL AND
        "area_id_p" NOTNULL AND
        "issue_id_p" ISNULL
      THEN
        "scope_v" := 'area';
        "area_id_v" := "area_id_p";
        SELECT "unit_id" INTO "unit_id_v"
          FROM "area" WHERE "id" = "area_id_v";
      ELSIF
        "unit_id_p" ISNULL AND
        "area_id_p" ISNULL AND
        "issue_id_p" NOTNULL
      THEN
        SELECT INTO "issue_row" * FROM "issue" WHERE "id" = "issue_id_p";
        IF "issue_row"."id" ISNULL THEN
          RETURN;
        END IF;
        IF "issue_row"."closed" NOTNULL THEN
          IF "simulate_v" THEN
            RAISE EXCEPTION 'Tried to simulate delegation chain for closed issue.';
          END IF;
          FOR "output_row" IN
            SELECT * FROM
            "delegation_chain_for_closed_issue"("member_id_p", "issue_id_p")
          LOOP
            RETURN NEXT "output_row";
          END LOOP;
          RETURN;
        END IF;
        "scope_v" := 'issue';
        SELECT "area_id" INTO "area_id_v"
          FROM "issue" WHERE "id" = "issue_id_p";
        SELECT "unit_id" INTO "unit_id_v"
          FROM "area"  WHERE "id" = "area_id_v";
      ELSE
        RAISE EXCEPTION 'Exactly one of unit_id_p, area_id_p, or issue_id_p must be NOTNULL.';
      END IF;
      "visited_member_ids" := '{}';
      "loop_member_id_v"   := NULL;
      "output_rows"        := '{}';
      "output_row"."index"         := 0;
      "output_row"."member_id"     := "member_id_p";
      "output_row"."member_valid"  := TRUE;
      "output_row"."participation" := FALSE;
      "output_row"."overridden"    := FALSE;
      "output_row"."disabled_out"  := FALSE;
      "output_row"."scope_out"     := NULL;
      LOOP
        IF "visited_member_ids" @> ARRAY["output_row"."member_id"] THEN
          "loop_member_id_v" := "output_row"."member_id";
        ELSE
          "visited_member_ids" :=
            "visited_member_ids" || "output_row"."member_id";
        END IF;
        IF "output_row"."participation" ISNULL THEN
          "output_row"."overridden" := NULL;
        ELSIF "output_row"."participation" THEN
          "output_row"."overridden" := TRUE;
        END IF;
        "output_row"."scope_in" := "output_row"."scope_out";
        "output_row"."member_valid" := EXISTS (
          SELECT NULL FROM "member" JOIN "privilege"
          ON "privilege"."member_id" = "member"."id"
          AND "privilege"."unit_id" = "unit_id_v"
          WHERE "id" = "output_row"."member_id"
          AND "member"."active" AND "privilege"."voting_right"
        );
        "simulate_here_v" := (
          "simulate_v" AND
          "output_row"."member_id" = "member_id_p"
        );
        "delegation_row" := ROW(NULL);
        IF "output_row"."member_valid" OR "simulate_here_v" THEN
          IF "scope_v" = 'unit' THEN
            IF NOT "simulate_here_v" THEN
              SELECT * INTO "delegation_row" FROM "delegation"
                WHERE "truster_id" = "output_row"."member_id"
                AND "unit_id" = "unit_id_v";
            END IF;
          ELSIF "scope_v" = 'area' THEN
            "output_row"."participation" := EXISTS (
              SELECT NULL FROM "membership"
              WHERE "area_id" = "area_id_p"
              AND "member_id" = "output_row"."member_id"
            );
            IF "simulate_here_v" THEN
              IF "simulate_trustee_id_p" ISNULL THEN
                SELECT * INTO "delegation_row" FROM "delegation"
                  WHERE "truster_id" = "output_row"."member_id"
                  AND "unit_id" = "unit_id_v";
              END IF;
            ELSE
              SELECT * INTO "delegation_row" FROM "delegation"
                WHERE "truster_id" = "output_row"."member_id"
                AND (
                  "unit_id" = "unit_id_v" OR
                  "area_id" = "area_id_v"
                )
                ORDER BY "scope" DESC;
            END IF;
          ELSIF "scope_v" = 'issue' THEN
            IF "issue_row"."fully_frozen" ISNULL THEN
              "output_row"."participation" := EXISTS (
                SELECT NULL FROM "interest"
                WHERE "issue_id" = "issue_id_p"
                AND "member_id" = "output_row"."member_id"
              );
            ELSE
              IF "output_row"."member_id" = "member_id_p" THEN
                "output_row"."participation" := EXISTS (
                  SELECT NULL FROM "direct_voter"
                  WHERE "issue_id" = "issue_id_p"
                  AND "member_id" = "output_row"."member_id"
                );
              ELSE
                "output_row"."participation" := NULL;
              END IF;
            END IF;
            IF "simulate_here_v" THEN
              IF "simulate_trustee_id_p" ISNULL THEN
                SELECT * INTO "delegation_row" FROM "delegation"
                  WHERE "truster_id" = "output_row"."member_id"
                  AND (
                    "unit_id" = "unit_id_v" OR
                    "area_id" = "area_id_v"
                  )
                  ORDER BY "scope" DESC;
              END IF;
            ELSE
              SELECT * INTO "delegation_row" FROM "delegation"
                WHERE "truster_id" = "output_row"."member_id"
                AND (
                  "unit_id" = "unit_id_v" OR
                  "area_id" = "area_id_v" OR
                  "issue_id" = "issue_id_p"
                )
                ORDER BY "scope" DESC;
            END IF;
          END IF;
        ELSE
          "output_row"."participation" := FALSE;
        END IF;
        IF "simulate_here_v" AND "simulate_trustee_id_p" NOTNULL THEN
          "output_row"."scope_out" := "scope_v";
          "output_rows" := "output_rows" || "output_row";
          "output_row"."member_id" := "simulate_trustee_id_p";
        ELSIF "delegation_row"."trustee_id" NOTNULL THEN
          "output_row"."scope_out" := "delegation_row"."scope";
          "output_rows" := "output_rows" || "output_row";
          "output_row"."member_id" := "delegation_row"."trustee_id";
        ELSIF "delegation_row"."scope" NOTNULL THEN
          "output_row"."scope_out" := "delegation_row"."scope";
          "output_row"."disabled_out" := TRUE;
          "output_rows" := "output_rows" || "output_row";
          EXIT;
        ELSE
          "output_row"."scope_out" := NULL;
          "output_rows" := "output_rows" || "output_row";
          EXIT;
        END IF;
        EXIT WHEN "loop_member_id_v" NOTNULL;
        "output_row"."index" := "output_row"."index" + 1;
      END LOOP;
      "row_count" := array_upper("output_rows", 1);
      "i"      := 1;
      "loop_v" := FALSE;
      LOOP
        "output_row" := "output_rows"["i"];
        EXIT WHEN "output_row" ISNULL;  -- NOTE: ISNULL and NOT ... NOTNULL produce different results!
        IF "loop_v" THEN
          IF "i" + 1 = "row_count" THEN
            "output_row"."loop" := 'last';
          ELSIF "i" = "row_count" THEN
            "output_row"."loop" := 'repetition';
          ELSE
            "output_row"."loop" := 'intermediate';
          END IF;
        ELSIF "output_row"."member_id" = "loop_member_id_v" THEN
          "output_row"."loop" := 'first';
          "loop_v" := TRUE;
        END IF;
        IF "scope_v" = 'unit' THEN
          "output_row"."participation" := NULL;
        END IF;
        RETURN NEXT "output_row";
        "i" := "i" + 1;
      END LOOP;
      RETURN;
    END;
  $$;


--
-- TOC entry 3208 (class 0 OID 0)
-- Dependencies: 322
-- Name: FUNCTION delegation_chain(member_id_p integer, unit_id_p integer, area_id_p integer, issue_id_p integer, simulate_trustee_id_p integer, simulate_default_p boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION delegation_chain(member_id_p integer, unit_id_p integer, area_id_p integer, issue_id_p integer, simulate_trustee_id_p integer, simulate_default_p boolean) IS 'Shows a delegation chain for unit, area, or issue; See "delegation_chain_row" type for more information';


--
-- TOC entry 323 (class 1255 OID 18717)
-- Name: delegation_chain_for_closed_issue(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delegation_chain_for_closed_issue(member_id_p integer, issue_id_p integer) RETURNS SETOF delegation_chain_row
    LANGUAGE plpgsql STABLE
    AS $$
    DECLARE
      "output_row"           "delegation_chain_row";
      "direct_voter_row"     "direct_voter"%ROWTYPE;
      "delegating_voter_row" "delegating_voter"%ROWTYPE;
    BEGIN
      "output_row"."index"         := 0;
      "output_row"."member_id"     := "member_id_p";
      "output_row"."member_valid"  := TRUE;
      "output_row"."participation" := FALSE;
      "output_row"."overridden"    := FALSE;
      "output_row"."disabled_out"  := FALSE;
      LOOP
        SELECT INTO "direct_voter_row" * FROM "direct_voter"
          WHERE "issue_id" = "issue_id_p"
          AND "member_id" = "output_row"."member_id";
        IF "direct_voter_row"."member_id" NOTNULL THEN
          "output_row"."participation" := TRUE;
          "output_row"."scope_out"     := NULL;
          "output_row"."disabled_out"  := NULL;
          RETURN NEXT "output_row";
          RETURN;
        END IF;
        SELECT INTO "delegating_voter_row" * FROM "delegating_voter"
          WHERE "issue_id" = "issue_id_p"
          AND "member_id" = "output_row"."member_id";
        IF "delegating_voter_row"."member_id" ISNULL THEN
          RETURN;
        END IF;
        "output_row"."scope_out" := "delegating_voter_row"."scope";
        RETURN NEXT "output_row";
        "output_row"."member_id" := "delegating_voter_row"."delegate_member_ids"[1];
        "output_row"."scope_in"  := "output_row"."scope_out";
      END LOOP;
    END;
  $$;


--
-- TOC entry 3209 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION delegation_chain_for_closed_issue(member_id_p integer, issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION delegation_chain_for_closed_issue(member_id_p integer, issue_id_p integer) IS 'Helper function for "delegation_chain" function, handling the special case of closed issues after voting';


--
-- TOC entry 324 (class 1255 OID 18718)
-- Name: delegation_info(integer, integer, integer, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delegation_info(member_id_p integer, unit_id_p integer, area_id_p integer, issue_id_p integer, simulate_trustee_id_p integer DEFAULT NULL::integer, simulate_default_p boolean DEFAULT false) RETURNS delegation_info_type
    LANGUAGE plpgsql STABLE
    AS $$
    DECLARE
      "current_row" "delegation_chain_row";
      "result"      "delegation_info_type";
    BEGIN
      "result"."own_participation" := FALSE;
      FOR "current_row" IN
        SELECT * FROM "delegation_chain"(
          "member_id_p",
          "unit_id_p", "area_id_p", "issue_id_p",
          "simulate_trustee_id_p", "simulate_default_p")
      LOOP
        IF
          "result"."participating_member_id" ISNULL AND
          "current_row"."participation"
        THEN
          "result"."participating_member_id" := "current_row"."member_id";
        END IF;
        IF "current_row"."member_id" = "member_id_p" THEN
          "result"."own_participation"    := "current_row"."participation";
          "result"."own_delegation_scope" := "current_row"."scope_out";
          IF "current_row"."loop" = 'first' THEN
            "result"."delegation_loop" := 'own';
          END IF;
        ELSIF
          "current_row"."member_valid" AND
          ( "current_row"."loop" ISNULL OR
            "current_row"."loop" != 'repetition' )
        THEN
          IF "result"."first_trustee_id" ISNULL THEN
            "result"."first_trustee_id"            := "current_row"."member_id";
            "result"."first_trustee_participation" := "current_row"."participation";
            "result"."first_trustee_ellipsis"      := FALSE;
            IF "current_row"."loop" = 'first' THEN
              "result"."delegation_loop" := 'first';
            END IF;
          ELSIF "result"."other_trustee_id" ISNULL THEN
            IF "current_row"."participation" AND NOT "current_row"."overridden" THEN
              "result"."other_trustee_id"            := "current_row"."member_id";
              "result"."other_trustee_participation" := TRUE;
              "result"."other_trustee_ellipsis"      := FALSE;
              IF "current_row"."loop" = 'first' THEN
                "result"."delegation_loop" := 'other';
              END IF;
            ELSE
              "result"."first_trustee_ellipsis" := TRUE;
              IF "current_row"."loop" = 'first' THEN
                "result"."delegation_loop" := 'first_ellipsis';
              END IF;
            END IF;
          ELSE
            "result"."other_trustee_ellipsis" := TRUE;
            IF "current_row"."loop" = 'first' THEN
              "result"."delegation_loop" := 'other_ellipsis';
            END IF;
          END IF;
        END IF;
      END LOOP;
      RETURN "result";
    END;
  $$;


--
-- TOC entry 3210 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION delegation_info(member_id_p integer, unit_id_p integer, area_id_p integer, issue_id_p integer, simulate_trustee_id_p integer, simulate_default_p boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION delegation_info(member_id_p integer, unit_id_p integer, area_id_p integer, issue_id_p integer, simulate_trustee_id_p integer, simulate_default_p boolean) IS 'Notable information about a delegation chain for unit, area, or issue; See "delegation_info_type" for more information';


--
-- TOC entry 325 (class 1255 OID 18719)
-- Name: delete_member(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_member(member_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      UPDATE "member" SET
        "last_login"                   = NULL,
        "login"                        = NULL,
        "password"                     = NULL,
        "locked"                       = TRUE,
        "active"                       = FALSE,
        "notify_email"                 = NULL,
        "notify_email_unconfirmed"     = NULL,
        "notify_email_secret"          = NULL,
        "notify_email_secret_expiry"   = NULL,
        "notify_email_lock_expiry"     = NULL,
        "password_reset_secret"        = NULL,
        "password_reset_secret_expiry" = NULL,
        "organizational_unit"          = NULL,
        "internal_posts"               = NULL,
        "realname"                     = NULL,
        "birthday"                     = NULL,
        "address"                      = NULL,
        "email"                        = NULL,
        "xmpp_address"                 = NULL,
        "website"                      = NULL,
        "phone"                        = NULL,
        "mobile_phone"                 = NULL,
        "profession"                   = NULL,
        "external_memberships"         = NULL,
        "external_posts"               = NULL,
        "statement"                    = NULL
        WHERE "id" = "member_id_p";
      -- "text_search_data" is updated by triggers
      DELETE FROM "setting"            WHERE "member_id" = "member_id_p";
      DELETE FROM "setting_map"        WHERE "member_id" = "member_id_p";
      DELETE FROM "member_relation_setting" WHERE "member_id" = "member_id_p";
      DELETE FROM "member_image"       WHERE "member_id" = "member_id_p";
      DELETE FROM "contact"            WHERE "member_id" = "member_id_p";
      DELETE FROM "ignored_member"     WHERE "member_id" = "member_id_p";
      DELETE FROM "session"            WHERE "member_id" = "member_id_p";
      DELETE FROM "area_setting"       WHERE "member_id" = "member_id_p";
      DELETE FROM "issue_setting"      WHERE "member_id" = "member_id_p";
      DELETE FROM "ignored_initiative" WHERE "member_id" = "member_id_p";
      DELETE FROM "initiative_setting" WHERE "member_id" = "member_id_p";
      DELETE FROM "suggestion_setting" WHERE "member_id" = "member_id_p";
      DELETE FROM "membership"         WHERE "member_id" = "member_id_p";
      DELETE FROM "delegation"         WHERE "truster_id" = "member_id_p";
      DELETE FROM "non_voter"          WHERE "member_id" = "member_id_p";
      DELETE FROM "direct_voter" USING "issue"
        WHERE "direct_voter"."issue_id" = "issue"."id"
        AND "issue"."closed" ISNULL
        AND "member_id" = "member_id_p";
      RETURN;
    END;
  $$;


--
-- TOC entry 3211 (class 0 OID 0)
-- Dependencies: 325
-- Name: FUNCTION delete_member(member_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION delete_member(member_id_p integer) IS 'Deactivate member and clear certain settings and data of this member (data protection)';


--
-- TOC entry 326 (class 1255 OID 18720)
-- Name: delete_private_data(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_private_data() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      DELETE FROM "member" WHERE "activated" ISNULL;
      UPDATE "member" SET
        "invite_code"                  = NULL,
        "invite_code_expiry"           = NULL,
        "admin_comment"                = NULL,
        "last_login"                   = NULL,
        "login"                        = NULL,
        "password"                     = NULL,
        "lang"                         = NULL,
        "notify_email"                 = NULL,
        "notify_email_unconfirmed"     = NULL,
        "notify_email_secret"          = NULL,
        "notify_email_secret_expiry"   = NULL,
        "notify_email_lock_expiry"     = NULL,
        "notify_level"                 = NULL,
        "password_reset_secret"        = NULL,
        "password_reset_secret_expiry" = NULL,
        "organizational_unit"          = NULL,
        "internal_posts"               = NULL,
        "realname"                     = NULL,
"nin"          = NULL,
        "birthday"                     = NULL,
        "address"                      = NULL,
        "email"                        = NULL,
        "xmpp_address"                 = NULL,
        "website"                      = NULL,
        "phone"                        = NULL,
        "mobile_phone"                 = NULL,
        "profession"                   = NULL,
        "external_memberships"         = NULL,
        "external_posts"               = NULL,
        "formatting_engine"            = NULL,
        "statement"                    = NULL;
      -- "text_search_data" is updated by triggers
      DELETE FROM "setting";
      DELETE FROM "setting_map";
      DELETE FROM "member_relation_setting";
      DELETE FROM "member_data";
      DELETE FROM "member_image";
      DELETE FROM "contact";
      DELETE FROM "ignored_member";
      DELETE FROM "session";
      DELETE FROM "area_setting";
      DELETE FROM "issue_setting";
      DELETE FROM "ignored_initiative";
      DELETE FROM "initiative_setting";
      DELETE FROM "suggestion_setting";
      DELETE FROM "non_voter";
      DELETE FROM "direct_voter" USING "issue"
        WHERE "direct_voter"."issue_id" = "issue"."id"
        AND "issue"."closed" ISNULL;
      RETURN;
    END;
  $$;


--
-- TOC entry 3212 (class 0 OID 0)
-- Dependencies: 326
-- Name: FUNCTION delete_private_data(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION delete_private_data() IS 'Used by lf_export script. DO NOT USE on productive database, but only on a copy! This function deletes all data which should not be publicly available, and can be used to create a database dump for publication. See source code to see which data is deleted. If you need a different behaviour, copy this function and modify lf_export accordingly, to avoid data-leaks after updating.';


--
-- TOC entry 292 (class 1255 OID 18721)
-- Name: direct_voter_deletes_non_voter_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION direct_voter_deletes_non_voter_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      DELETE FROM "non_voter"
        WHERE "issue_id" = NEW."issue_id" AND "member_id" = NEW."member_id";
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3213 (class 0 OID 0)
-- Dependencies: 292
-- Name: FUNCTION direct_voter_deletes_non_voter_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION direct_voter_deletes_non_voter_trigger() IS 'Implementation of trigger "direct_voter_deletes_non_voter" on table "direct_voter"';


--
-- TOC entry 317 (class 1255 OID 18722)
-- Name: dont_require_transaction_isolation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION dont_require_transaction_isolation() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF
        current_setting('transaction_isolation') IN
        ('repeatable read', 'serializable')
      THEN
        RAISE WARNING 'Unneccessary transaction isolation level: %',
          current_setting('transaction_isolation');
      END IF;
      RETURN;
    END;
  $$;


--
-- TOC entry 3214 (class 0 OID 0)
-- Dependencies: 317
-- Name: FUNCTION dont_require_transaction_isolation(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION dont_require_transaction_isolation() IS 'Raises a warning, if transaction isolation level is higher than READ COMMITTED';


--
-- TOC entry 327 (class 1255 OID 18723)
-- Name: forbid_changes_on_closed_issue_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION forbid_changes_on_closed_issue_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_id_v" "issue"."id"%TYPE;
      "issue_row"  "issue"%ROWTYPE;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        "issue_id_v" := OLD."issue_id";
      ELSE
        "issue_id_v" := NEW."issue_id";
      END IF;
      SELECT INTO "issue_row" * FROM "issue"
        WHERE "id" = "issue_id_v" FOR SHARE;
      IF "issue_row"."closed" NOTNULL THEN
        IF
          TG_RELID = 'direct_voter'::regclass AND
          TG_OP = 'UPDATE'
        THEN
          IF
            OLD."issue_id"  = NEW."issue_id"  AND
            OLD."member_id" = NEW."member_id" AND
            OLD."weight" = NEW."weight"
          THEN
            RETURN NULL;  -- allows changing of voter comment
          END IF;
        END IF;
        RAISE EXCEPTION 'Tried to modify data belonging to a closed issue.';
      ELSIF
        "issue_row"."state" = 'voting' AND
        "issue_row"."phase_finished" NOTNULL
      THEN
        IF TG_RELID = 'vote'::regclass THEN
          RAISE EXCEPTION 'Tried to modify data after voting has been closed.';
        END IF;
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3215 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION forbid_changes_on_closed_issue_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION forbid_changes_on_closed_issue_trigger() IS 'Implementation of triggers "forbid_changes_on_closed_issue" on tables "direct_voter", "delegating_voter" and "vote"';


--
-- TOC entry 328 (class 1255 OID 18724)
-- Name: highlight(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION highlight(body_p text, query_text_p text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    BEGIN
      RETURN ts_headline(
        'pg_catalog.simple',
        replace(replace("body_p", e'\\', e'\\\\'), '*', e'\\*'),
        "text_search_query"("query_text_p"),
        'StartSel=* StopSel=* HighlightAll=TRUE' );
    END;
  $$;


--
-- TOC entry 3216 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION highlight(body_p text, query_text_p text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION highlight(body_p text, query_text_p text) IS 'For a given a user query this function encapsulates all matches with asterisks. Asterisks and backslashes being already present are preceeded with one extra backslash.';


--
-- TOC entry 329 (class 1255 OID 18725)
-- Name: initiative_requires_first_draft_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION initiative_requires_first_draft_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NOT EXISTS (
        SELECT NULL FROM "draft" WHERE "initiative_id" = NEW."id"
      ) THEN
        --RAISE 'Cannot create initiative without an initial draft.' USING
        --  ERRCODE = 'integrity_constraint_violation',
        --  HINT    = 'Create issue, initiative and draft within the same transaction.';
        RAISE EXCEPTION 'Cannot create initiative without an initial draft.';
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3217 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION initiative_requires_first_draft_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION initiative_requires_first_draft_trigger() IS 'Implementation of trigger "initiative_requires_first_draft" on table "initiative"';


--
-- TOC entry 330 (class 1255 OID 18726)
-- Name: issue_requires_first_initiative_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION issue_requires_first_initiative_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NOT EXISTS (
        SELECT NULL FROM "initiative" WHERE "issue_id" = NEW."id"
      ) THEN
        --RAISE 'Cannot create issue without an initial initiative.' USING
        --  ERRCODE = 'integrity_constraint_violation',
        --  HINT    = 'Create issue, initiative, and draft within the same transaction.';
        RAISE EXCEPTION 'Cannot create issue without an initial initiative.';
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3218 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION issue_requires_first_initiative_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION issue_requires_first_initiative_trigger() IS 'Implementation of trigger "issue_requires_first_initiative" on table "issue"';


--
-- TOC entry 331 (class 1255 OID 18727)
-- Name: last_draft_deletes_initiative_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION last_draft_deletes_initiative_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "reference_lost" BOOLEAN;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        "reference_lost" := TRUE;
      ELSE
        "reference_lost" := NEW."initiative_id" != OLD."initiative_id";
      END IF;
      IF
        "reference_lost" AND NOT EXISTS (
          SELECT NULL FROM "draft" WHERE "initiative_id" = OLD."initiative_id"
        )
      THEN
        DELETE FROM "initiative" WHERE "id" = OLD."initiative_id";
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3219 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION last_draft_deletes_initiative_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION last_draft_deletes_initiative_trigger() IS 'Implementation of trigger "last_draft_deletes_initiative" on table "draft"';


--
-- TOC entry 332 (class 1255 OID 18728)
-- Name: last_initiative_deletes_issue_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION last_initiative_deletes_issue_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "reference_lost" BOOLEAN;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        "reference_lost" := TRUE;
      ELSE
        "reference_lost" := NEW."issue_id" != OLD."issue_id";
      END IF;
      IF
        "reference_lost" AND NOT EXISTS (
          SELECT NULL FROM "initiative" WHERE "issue_id" = OLD."issue_id"
        )
      THEN
        DELETE FROM "issue" WHERE "id" = OLD."issue_id";
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3220 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION last_initiative_deletes_issue_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION last_initiative_deletes_issue_trigger() IS 'Implementation of trigger "last_initiative_deletes_issue" on table "initiative"';


--
-- TOC entry 333 (class 1255 OID 18729)
-- Name: last_opinion_deletes_suggestion_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION last_opinion_deletes_suggestion_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "reference_lost" BOOLEAN;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        "reference_lost" := TRUE;
      ELSE
        "reference_lost" := NEW."suggestion_id" != OLD."suggestion_id";
      END IF;
      IF
        "reference_lost" AND NOT EXISTS (
          SELECT NULL FROM "opinion" WHERE "suggestion_id" = OLD."suggestion_id"
        )
      THEN
        DELETE FROM "suggestion" WHERE "id" = OLD."suggestion_id";
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3221 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION last_opinion_deletes_suggestion_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION last_opinion_deletes_suggestion_trigger() IS 'Implementation of trigger "last_opinion_deletes_suggestion" on table "opinion"';


--
-- TOC entry 334 (class 1255 OID 18730)
-- Name: lock_issue(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION lock_issue(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      -- The following locking order is used:
      -- 1st) row-level lock on the issue
      -- 2nd) table-level locks in order of occurrence in the core.sql file
      PERFORM NULL FROM "issue" WHERE "id" = "issue_id_p" FOR UPDATE;
      -- NOTE: The row-level exclusive lock in combination with the
      -- share_row_lock_issue(_via_initiative)_trigger functions (which
      -- acquire a row-level share lock on the issue) ensure that no data
      -- is changed, which could affect calculation of snapshots or
      -- counting of votes. Table "delegation" must be table-level-locked,
      -- as it also contains issue- and global-scope delegations.
      PERFORM NULL FROM "member" WHERE "active" FOR SHARE;
      -- NOTE: As we later cause implicit row-level share locks on many
      -- active members, we lock them before locking any other table
      -- to avoid deadlocks
      LOCK TABLE "member"     IN SHARE MODE;
      LOCK TABLE "privilege"  IN SHARE MODE;
      LOCK TABLE "membership" IN SHARE MODE;
      LOCK TABLE "policy"     IN SHARE MODE;
      LOCK TABLE "delegation" IN SHARE MODE;
      LOCK TABLE "direct_population_snapshot"     IN EXCLUSIVE MODE;
      LOCK TABLE "delegating_population_snapshot" IN EXCLUSIVE MODE;
      LOCK TABLE "direct_interest_snapshot"       IN EXCLUSIVE MODE;
      LOCK TABLE "delegating_interest_snapshot"   IN EXCLUSIVE MODE;
      LOCK TABLE "direct_supporter_snapshot"      IN EXCLUSIVE MODE;
      RETURN;
    END;
  $$;


--
-- TOC entry 3222 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION lock_issue(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION lock_issue(issue_id_p integer) IS 'Locks the issue and all other data which is used for calculating snapshots or counting votes.';


--
-- TOC entry 335 (class 1255 OID 18731)
-- Name: membership_weight(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION membership_weight(area_id_p integer, member_id_p integer) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$
    BEGIN
      RETURN "membership_weight_with_skipping"(
        "area_id_p",
        "member_id_p",
        ARRAY["member_id_p"]
      );
    END;
  $$;


--
-- TOC entry 3223 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION membership_weight(area_id_p integer, member_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION membership_weight(area_id_p integer, member_id_p integer) IS 'Calculates the potential voting weight of a member in a given area';


--
-- TOC entry 337 (class 1255 OID 18732)
-- Name: membership_weight_with_skipping(integer, integer, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION membership_weight_with_skipping(area_id_p integer, member_id_p integer, skip_member_ids_p integer[]) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$
    DECLARE
      "sum_v"          INT4;
      "delegation_row" "area_delegation"%ROWTYPE;
    BEGIN
      "sum_v" := 1;
      FOR "delegation_row" IN
        SELECT "area_delegation".*
        FROM "area_delegation" LEFT JOIN "membership"
        ON "membership"."area_id" = "area_id_p"
        AND "membership"."member_id" = "area_delegation"."truster_id"
        WHERE "area_delegation"."area_id" = "area_id_p"
        AND "area_delegation"."trustee_id" = "member_id_p"
        AND "membership"."member_id" ISNULL
      LOOP
        IF NOT
          "skip_member_ids_p" @> ARRAY["delegation_row"."truster_id"]
        THEN
          "sum_v" := "sum_v" + "membership_weight_with_skipping"(
            "area_id_p",
            "delegation_row"."truster_id",
            "skip_member_ids_p" || "delegation_row"."truster_id"
          );
        END IF;
      END LOOP;
      RETURN "sum_v";
    END;
  $$;


--
-- TOC entry 3224 (class 0 OID 0)
-- Dependencies: 337
-- Name: FUNCTION membership_weight_with_skipping(area_id_p integer, member_id_p integer, skip_member_ids_p integer[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION membership_weight_with_skipping(area_id_p integer, member_id_p integer, skip_member_ids_p integer[]) IS 'Helper function for "membership_weight" function';


--
-- TOC entry 338 (class 1255 OID 18733)
-- Name: nin_insert_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION nin_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE myrec int;
    BEGIN
       IF length (NEW.nin) = 16 OR NEW.nin ISNULL THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Wrong lenght';
      END IF;
      RETURN NULL;
   END;
  $$;


--
-- TOC entry 339 (class 1255 OID 18734)
-- Name: non_voter_deletes_direct_voter_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION non_voter_deletes_direct_voter_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      DELETE FROM "direct_voter"
        WHERE "issue_id" = NEW."issue_id" AND "member_id" = NEW."member_id";
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3225 (class 0 OID 0)
-- Dependencies: 339
-- Name: FUNCTION non_voter_deletes_direct_voter_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION non_voter_deletes_direct_voter_trigger() IS 'Implementation of trigger "non_voter_deletes_direct_voter" on table "non_voter"';


--
-- TOC entry 340 (class 1255 OID 18735)
-- Name: require_transaction_isolation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION require_transaction_isolation() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF
        current_setting('transaction_isolation') NOT IN
        ('repeatable read', 'serializable')
      THEN
        RAISE EXCEPTION 'Insufficient transaction isolation level';
      END IF;
      RETURN;
    END;
  $$;


--
-- TOC entry 3226 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION require_transaction_isolation(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION require_transaction_isolation() IS 'Throws an exception, if transaction isolation level is too low to provide a consistent snapshot';


--
-- TOC entry 341 (class 1255 OID 18736)
-- Name: set_harmonic_initiative_weights(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_harmonic_initiative_weights(issue_id_p integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "weight_row"   "remaining_harmonic_initiative_weight_summands"%ROWTYPE;
      "i"            INT4;
      "count_v"      INT4;
      "summand_v"    FLOAT;
      "id_ary"       INT4[];
      "weight_ary"   FLOAT[];
      "min_weight_v" FLOAT;
    BEGIN
      PERFORM "require_transaction_isolation"();
      UPDATE "initiative" SET "harmonic_weight" = NULL
        WHERE "issue_id" = "issue_id_p";
      LOOP
        "min_weight_v" := NULL;
        "i" := 0;
        "count_v" := 0;
        FOR "weight_row" IN
          SELECT * FROM "remaining_harmonic_initiative_weight_summands"
          WHERE "issue_id" = "issue_id_p"
          AND (
            coalesce("admitted", FALSE) = FALSE OR NOT EXISTS (
              SELECT NULL FROM "initiative"
              WHERE "issue_id" = "issue_id_p"
              AND "harmonic_weight" ISNULL
              AND coalesce("admitted", FALSE) = FALSE
            )
          )
          UNION ALL  -- needed for corner cases
          SELECT * FROM "remaining_harmonic_initiative_weight_dummies"
          WHERE "issue_id" = "issue_id_p"
          AND (
            coalesce("admitted", FALSE) = FALSE OR NOT EXISTS (
              SELECT NULL FROM "initiative"
              WHERE "issue_id" = "issue_id_p"
              AND "harmonic_weight" ISNULL
              AND coalesce("admitted", FALSE) = FALSE
            )
          )
          ORDER BY "initiative_id" DESC, "weight_den" DESC
          -- NOTE: non-admitted initiatives placed first (at last positions),
          --       latest initiatives treated worse in case of tie
        LOOP
          "summand_v" := "weight_row"."weight_num"::FLOAT / "weight_row"."weight_den"::FLOAT;
          IF "i" = 0 OR "weight_row"."initiative_id" != "id_ary"["i"] THEN
            "i" := "i" + 1;
            "count_v" := "i";
            "id_ary"["i"] := "weight_row"."initiative_id";
            "weight_ary"["i"] := "summand_v";
          ELSE
            "weight_ary"["i"] := "weight_ary"["i"] + "summand_v";
          END IF;
        END LOOP;
        EXIT WHEN "count_v" = 0;
        "i" := 1;
        LOOP
          "weight_ary"["i"] := "weight_ary"["i"]::NUMERIC(18,9)::NUMERIC(12,3);
          IF "min_weight_v" ISNULL OR "weight_ary"["i"] < "min_weight_v" THEN
            "min_weight_v" := "weight_ary"["i"];
          END IF;
          "i" := "i" + 1;
          EXIT WHEN "i" > "count_v";
        END LOOP;
        "i" := 1;
        LOOP
          IF "weight_ary"["i"] = "min_weight_v" THEN
            UPDATE "initiative" SET "harmonic_weight" = "min_weight_v"
              WHERE "id" = "id_ary"["i"];
            EXIT;
          END IF;
          "i" := "i" + 1;
        END LOOP;
      END LOOP;
      UPDATE "initiative" SET "harmonic_weight" = 0
        WHERE "issue_id" = "issue_id_p" AND "harmonic_weight" ISNULL;
    END;
  $$;


--
-- TOC entry 3227 (class 0 OID 0)
-- Dependencies: 341
-- Name: FUNCTION set_harmonic_initiative_weights(issue_id_p integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION set_harmonic_initiative_weights(issue_id_p integer) IS 'Calculates and sets "harmonic_weight" of initiatives in a given issue';


--
-- TOC entry 342 (class 1255 OID 18737)
-- Name: set_snapshot_event(integer, snapshot_event); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_snapshot_event(issue_id_p integer, event_p snapshot_event) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "event_v" "issue"."latest_snapshot_event"%TYPE;
    BEGIN
      PERFORM "require_transaction_isolation"();
      SELECT "latest_snapshot_event" INTO "event_v" FROM "issue"
        WHERE "id" = "issue_id_p" FOR UPDATE;
      UPDATE "issue" SET "latest_snapshot_event" = "event_p"
        WHERE "id" = "issue_id_p";
      UPDATE "direct_population_snapshot" SET "event" = "event_p"
        WHERE "issue_id" = "issue_id_p" AND "event" = "event_v";
      UPDATE "delegating_population_snapshot" SET "event" = "event_p"
        WHERE "issue_id" = "issue_id_p" AND "event" = "event_v";
      UPDATE "direct_interest_snapshot" SET "event" = "event_p"
        WHERE "issue_id" = "issue_id_p" AND "event" = "event_v";
      UPDATE "delegating_interest_snapshot" SET "event" = "event_p"
        WHERE "issue_id" = "issue_id_p" AND "event" = "event_v";
      UPDATE "direct_supporter_snapshot" SET "event" = "event_p"
        FROM "initiative"  -- NOTE: due to missing index on issue_id
        WHERE "initiative"."issue_id" = "issue_id_p"
        AND "direct_supporter_snapshot"."initiative_id" = "initiative"."id"
        AND "direct_supporter_snapshot"."event" = "event_v";
      RETURN;
    END;
  $$;


--
-- TOC entry 3228 (class 0 OID 0)
-- Dependencies: 342
-- Name: FUNCTION set_snapshot_event(issue_id_p integer, event_p snapshot_event); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION set_snapshot_event(issue_id_p integer, event_p snapshot_event) IS 'Change "event" attribute of the previous ''periodic'' snapshot';


--
-- TOC entry 343 (class 1255 OID 18738)
-- Name: suggestion_requires_first_opinion_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION suggestion_requires_first_opinion_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NOT EXISTS (
        SELECT NULL FROM "opinion" WHERE "suggestion_id" = NEW."id"
      ) THEN
        RAISE EXCEPTION 'Cannot create a suggestion without an opinion.';
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3229 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION suggestion_requires_first_opinion_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION suggestion_requires_first_opinion_trigger() IS 'Implementation of trigger "suggestion_requires_first_opinion" on table "suggestion"';


--
-- TOC entry 344 (class 1255 OID 18739)
-- Name: text_search_query(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION text_search_query(query_text_p text) RETURNS tsquery
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    BEGIN
      RETURN plainto_tsquery('pg_catalog.simple', "query_text_p");
    END;
  $$;


--
-- TOC entry 3230 (class 0 OID 0)
-- Dependencies: 344
-- Name: FUNCTION text_search_query(query_text_p text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION text_search_query(query_text_p text) IS 'Usage: WHERE "text_search_data" @@ "text_search_query"(''<user query>'')';


--
-- TOC entry 345 (class 1255 OID 18740)
-- Name: voter_comment_fields_only_set_when_voter_comment_is_set_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION voter_comment_fields_only_set_when_voter_comment_is_set_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NEW."comment" ISNULL THEN
        NEW."comment_changed" := NULL;
        NEW."formatting_engine" := NULL;
      END IF;
      RETURN NEW;
    END;
  $$;


--
-- TOC entry 3231 (class 0 OID 0)
-- Dependencies: 345
-- Name: FUNCTION voter_comment_fields_only_set_when_voter_comment_is_set_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION voter_comment_fields_only_set_when_voter_comment_is_set_trigger() IS 'Implementation of trigger "voter_comment_fields_only_set_when_voter_comment_is_set" ON table "direct_voter"';


--
-- TOC entry 346 (class 1255 OID 18741)
-- Name: weight_of_added_delegations_for_interest_snapshot(integer, integer, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION weight_of_added_delegations_for_interest_snapshot(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_delegation_row"  "issue_delegation"%ROWTYPE;
      "delegate_member_ids_v" "delegating_interest_snapshot"."delegate_member_ids"%TYPE;
      "weight_v"              INT4;
      "sub_weight_v"          INT4;
    BEGIN
      PERFORM "require_transaction_isolation"();
      "weight_v" := 0;
      FOR "issue_delegation_row" IN
        SELECT * FROM "issue_delegation"
        WHERE "trustee_id" = "member_id_p"
        AND "issue_id" = "issue_id_p"
      LOOP
        IF NOT EXISTS (
          SELECT NULL FROM "direct_interest_snapshot"
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
          AND "member_id" = "issue_delegation_row"."truster_id"
        ) AND NOT EXISTS (
          SELECT NULL FROM "delegating_interest_snapshot"
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
          AND "member_id" = "issue_delegation_row"."truster_id"
        ) THEN
          "delegate_member_ids_v" :=
            "member_id_p" || "delegate_member_ids_p";
          INSERT INTO "delegating_interest_snapshot" (
              "issue_id",
              "event",
              "member_id",
              "scope",
              "delegate_member_ids"
            ) VALUES (
              "issue_id_p",
              'periodic',
              "issue_delegation_row"."truster_id",
              "issue_delegation_row"."scope",
              "delegate_member_ids_v"
            );
          "sub_weight_v" := 1 +
            "weight_of_added_delegations_for_interest_snapshot"(
              "issue_id_p",
              "issue_delegation_row"."truster_id",
              "delegate_member_ids_v"
            );
          UPDATE "delegating_interest_snapshot"
            SET "weight" = "sub_weight_v"
            WHERE "issue_id" = "issue_id_p"
            AND "event" = 'periodic'
            AND "member_id" = "issue_delegation_row"."truster_id";
          "weight_v" := "weight_v" + "sub_weight_v";
        END IF;
      END LOOP;
      RETURN "weight_v";
    END;
  $$;


--
-- TOC entry 3232 (class 0 OID 0)
-- Dependencies: 346
-- Name: FUNCTION weight_of_added_delegations_for_interest_snapshot(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION weight_of_added_delegations_for_interest_snapshot(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]) IS 'Helper function for "create_interest_snapshot" function';


--
-- TOC entry 347 (class 1255 OID 18742)
-- Name: weight_of_added_delegations_for_population_snapshot(integer, integer, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION weight_of_added_delegations_for_population_snapshot(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_delegation_row"  "issue_delegation"%ROWTYPE;
      "delegate_member_ids_v" "delegating_population_snapshot"."delegate_member_ids"%TYPE;
      "weight_v"              INT4;
      "sub_weight_v"          INT4;
    BEGIN
      PERFORM "require_transaction_isolation"();
      "weight_v" := 0;
      FOR "issue_delegation_row" IN
        SELECT * FROM "issue_delegation"
        WHERE "trustee_id" = "member_id_p"
        AND "issue_id" = "issue_id_p"
      LOOP
        IF NOT EXISTS (
          SELECT NULL FROM "direct_population_snapshot"
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
          AND "member_id" = "issue_delegation_row"."truster_id"
        ) AND NOT EXISTS (
          SELECT NULL FROM "delegating_population_snapshot"
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
          AND "member_id" = "issue_delegation_row"."truster_id"
        ) THEN
          "delegate_member_ids_v" :=
            "member_id_p" || "delegate_member_ids_p";
          INSERT INTO "delegating_population_snapshot" (
              "issue_id",
              "event",
              "member_id",
              "scope",
              "delegate_member_ids"
            ) VALUES (
              "issue_id_p",
              'periodic',
              "issue_delegation_row"."truster_id",
              "issue_delegation_row"."scope",
              "delegate_member_ids_v"
            );
          "sub_weight_v" := 1 +
            "weight_of_added_delegations_for_population_snapshot"(
              "issue_id_p",
              "issue_delegation_row"."truster_id",
              "delegate_member_ids_v"
            );
          UPDATE "delegating_population_snapshot"
            SET "weight" = "sub_weight_v"
            WHERE "issue_id" = "issue_id_p"
            AND "event" = 'periodic'
            AND "member_id" = "issue_delegation_row"."truster_id";
          "weight_v" := "weight_v" + "sub_weight_v";
        END IF;
      END LOOP;
      RETURN "weight_v";
    END;
  $$;


--
-- TOC entry 3233 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION weight_of_added_delegations_for_population_snapshot(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION weight_of_added_delegations_for_population_snapshot(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]) IS 'Helper function for "create_population_snapshot" function';


--
-- TOC entry 336 (class 1255 OID 18743)
-- Name: weight_of_added_vote_delegations(integer, integer, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION weight_of_added_vote_delegations(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_delegation_row"  "issue_delegation"%ROWTYPE;
      "delegate_member_ids_v" "delegating_voter"."delegate_member_ids"%TYPE;
      "weight_v"              INT4;
      "sub_weight_v"          INT4;
    BEGIN
      PERFORM "require_transaction_isolation"();
      "weight_v" := 0;
      FOR "issue_delegation_row" IN
        SELECT * FROM "issue_delegation"
        WHERE "trustee_id" = "member_id_p"
        AND "issue_id" = "issue_id_p"
      LOOP
        IF NOT EXISTS (
          SELECT NULL FROM "direct_voter"
          WHERE "member_id" = "issue_delegation_row"."truster_id"
          AND "issue_id" = "issue_id_p"
        ) AND NOT EXISTS (
          SELECT NULL FROM "delegating_voter"
          WHERE "member_id" = "issue_delegation_row"."truster_id"
          AND "issue_id" = "issue_id_p"
        ) THEN
          "delegate_member_ids_v" :=
            "member_id_p" || "delegate_member_ids_p";
          INSERT INTO "delegating_voter" (
              "issue_id",
              "member_id",
              "scope",
              "delegate_member_ids"
            ) VALUES (
              "issue_id_p",
              "issue_delegation_row"."truster_id",
              "issue_delegation_row"."scope",
              "delegate_member_ids_v"
            );
          "sub_weight_v" := 1 +
            "weight_of_added_vote_delegations"(
              "issue_id_p",
              "issue_delegation_row"."truster_id",
              "delegate_member_ids_v"
            );
          UPDATE "delegating_voter"
            SET "weight" = "sub_weight_v"
            WHERE "issue_id" = "issue_id_p"
            AND "member_id" = "issue_delegation_row"."truster_id";
          "weight_v" := "weight_v" + "sub_weight_v";
        END IF;
      END LOOP;
      RETURN "weight_v";
    END;
  $$;


--
-- TOC entry 3234 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION weight_of_added_vote_delegations(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION weight_of_added_vote_delegations(issue_id_p integer, member_id_p integer, delegate_member_ids_p integer[]) IS 'Helper function for "add_vote_delegations" function';


--
-- TOC entry 348 (class 1255 OID 18744)
-- Name: write_event_initiative_or_draft_created_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION write_event_initiative_or_draft_created_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "initiative_row" "initiative"%ROWTYPE;
      "issue_row"      "issue"%ROWTYPE;
      "event_v"        "event_type";
    BEGIN
      SELECT * INTO "initiative_row" FROM "initiative"
        WHERE "id" = NEW."initiative_id";
      SELECT * INTO "issue_row" FROM "issue"
        WHERE "id" = "initiative_row"."issue_id";
      IF EXISTS (
        SELECT NULL FROM "draft"
        WHERE "initiative_id" = NEW."initiative_id"
        AND "id" != NEW."id"
      ) THEN
        "event_v" := 'new_draft_created';
      ELSE
        IF EXISTS (
          SELECT NULL FROM "initiative"
          WHERE "issue_id" = "initiative_row"."issue_id"
          AND "id" != "initiative_row"."id"
        ) THEN
          "event_v" := 'initiative_created_in_existing_issue';
        ELSE
          "event_v" := 'initiative_created_in_new_issue';
        END IF;
      END IF;
      INSERT INTO "event" (
          "event", "member_id",
          "issue_id", "state", "initiative_id", "draft_id"
        ) VALUES (
          "event_v",
          NEW."author_id",
          "initiative_row"."issue_id",
          "issue_row"."state",
          "initiative_row"."id",
          NEW."id" );
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3235 (class 0 OID 0)
-- Dependencies: 348
-- Name: FUNCTION write_event_initiative_or_draft_created_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION write_event_initiative_or_draft_created_trigger() IS 'Implementation of trigger "write_event_initiative_or_draft_created" on table "issue"';


--
-- TOC entry 349 (class 1255 OID 18745)
-- Name: write_event_initiative_revoked_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION write_event_initiative_revoked_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "issue_row"  "issue"%ROWTYPE;
      "draft_id_v" "draft"."id"%TYPE;
    BEGIN
      IF OLD."revoked" ISNULL AND NEW."revoked" NOTNULL THEN
        SELECT * INTO "issue_row" FROM "issue"
          WHERE "id" = NEW."issue_id";
        SELECT "id" INTO "draft_id_v" FROM "current_draft"
          WHERE "initiative_id" = NEW."id";
        INSERT INTO "event" (
            "event", "member_id", "issue_id", "state", "initiative_id", "draft_id"
          ) VALUES (
            'initiative_revoked',
            NEW."revoked_by_member_id",
            NEW."issue_id",
            "issue_row"."state",
            NEW."id",
            "draft_id_v");
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3236 (class 0 OID 0)
-- Dependencies: 349
-- Name: FUNCTION write_event_initiative_revoked_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION write_event_initiative_revoked_trigger() IS 'Implementation of trigger "write_event_initiative_revoked" on table "issue"';


--
-- TOC entry 350 (class 1255 OID 18746)
-- Name: write_event_issue_state_changed_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION write_event_issue_state_changed_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF NEW."state" != OLD."state" THEN
        INSERT INTO "event" ("event", "issue_id", "state")
          VALUES ('issue_state_changed', NEW."id", NEW."state");
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3237 (class 0 OID 0)
-- Dependencies: 350
-- Name: FUNCTION write_event_issue_state_changed_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION write_event_issue_state_changed_trigger() IS 'Implementation of trigger "write_event_issue_state_changed" on table "issue"';


--
-- TOC entry 351 (class 1255 OID 18747)
-- Name: write_event_suggestion_created_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION write_event_suggestion_created_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      "initiative_row" "initiative"%ROWTYPE;
      "issue_row"      "issue"%ROWTYPE;
    BEGIN
      SELECT * INTO "initiative_row" FROM "initiative"
        WHERE "id" = NEW."initiative_id";
      SELECT * INTO "issue_row" FROM "issue"
        WHERE "id" = "initiative_row"."issue_id";
      INSERT INTO "event" (
          "event", "member_id",
          "issue_id", "state", "initiative_id", "suggestion_id"
        ) VALUES (
          'suggestion_created',
          NEW."author_id",
          "initiative_row"."issue_id",
          "issue_row"."state",
          "initiative_row"."id",
          NEW."id" );
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3238 (class 0 OID 0)
-- Dependencies: 351
-- Name: FUNCTION write_event_suggestion_created_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION write_event_suggestion_created_trigger() IS 'Implementation of trigger "write_event_suggestion_created" on table "issue"';


--
-- TOC entry 352 (class 1255 OID 18748)
-- Name: write_member_history_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION write_member_history_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF
        ( NEW."active" != OLD."active" OR
          NEW."name"   != OLD."name" ) AND
        OLD."activated" NOTNULL
      THEN
        INSERT INTO "member_history"
          ("member_id", "active", "name")
          VALUES (NEW."id", OLD."active", OLD."name");
      END IF;
      RETURN NULL;
    END;
  $$;


--
-- TOC entry 3239 (class 0 OID 0)
-- Dependencies: 352
-- Name: FUNCTION write_member_history_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION write_member_history_trigger() IS 'Implementation of trigger "write_member_history" on table "member"';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 184 (class 1259 OID 18749)
-- Name: allowed_policy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE allowed_policy (
    area_id integer NOT NULL,
    policy_id integer NOT NULL,
    default_policy boolean DEFAULT false NOT NULL
);


--
-- TOC entry 3240 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE allowed_policy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE allowed_policy IS 'Selects which policies can be used in each area';


--
-- TOC entry 3241 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN allowed_policy.default_policy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN allowed_policy.default_policy IS 'One policy per area can be set as default.';


--
-- TOC entry 185 (class 1259 OID 18753)
-- Name: area; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE area (
    id integer NOT NULL,
    unit_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    direct_member_count integer,
    member_weight integer,
    text_search_data tsvector
);


--
-- TOC entry 3242 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE area; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE area IS 'Subject areas';


--
-- TOC entry 3243 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN area.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN area.active IS 'TRUE means new issues can be created in this area';


--
-- TOC entry 3244 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN area.direct_member_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN area.direct_member_count IS 'Number of active members of that area (ignoring their weight), as calculated from view "area_member_count"';


--
-- TOC entry 3245 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN area.member_weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN area.member_weight IS 'Same as "direct_member_count" but respecting delegations';


--
-- TOC entry 186 (class 1259 OID 18761)
-- Name: delegation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegation (
    id bigint NOT NULL,
    truster_id integer NOT NULL,
    trustee_id integer,
    scope delegation_scope NOT NULL,
    unit_id integer,
    area_id integer,
    issue_id integer,
    CONSTRAINT area_id_and_issue_id_set_according_to_scope CHECK ((((scope = 'unit'::delegation_scope) AND (unit_id IS NOT NULL) AND (area_id IS NULL) AND (issue_id IS NULL)) OR ((scope = 'area'::delegation_scope) AND (unit_id IS NULL) AND (area_id IS NOT NULL) AND (issue_id IS NULL)) OR ((scope = 'issue'::delegation_scope) AND (unit_id IS NULL) AND (area_id IS NULL) AND (issue_id IS NOT NULL)))),
    CONSTRAINT cant_delegate_to_yourself CHECK ((truster_id <> trustee_id)),
    CONSTRAINT no_unit_delegation_to_null CHECK (((trustee_id IS NOT NULL) OR (scope <> 'unit'::delegation_scope)))
);


--
-- TOC entry 3246 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE delegation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE delegation IS 'Delegation of vote-weight to other members';


--
-- TOC entry 3247 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN delegation.unit_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation.unit_id IS 'Reference to unit, if delegation is unit-wide, otherwise NULL';


--
-- TOC entry 3248 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN delegation.area_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation.area_id IS 'Reference to area, if delegation is area-wide, otherwise NULL';


--
-- TOC entry 3249 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN delegation.issue_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegation.issue_id IS 'Reference to issue, if delegation is issue-wide, otherwise NULL';


--
-- TOC entry 187 (class 1259 OID 18767)
-- Name: member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member (
    id integer NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    creator_id integer,
    invite_code text,
    invite_code_expiry timestamp with time zone,
    admin_comment text,
    activated timestamp with time zone,
    last_activity date,
    last_login timestamp with time zone,
    certified timestamp with time zone,
    certifier_id integer,
    login text,
    password text,
    locked boolean DEFAULT false NOT NULL,
    active boolean DEFAULT false NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    lang text,
    notify_email text,
    notify_email_unconfirmed text,
    notify_email_secret text,
    notify_email_secret_expiry timestamp with time zone,
    notify_email_lock_expiry timestamp with time zone,
    notify_level notify_level,
    password_reset_secret text,
    password_reset_secret_expiry timestamp with time zone,
    name text,
    firstname text,
    lastname text,
    identification text,
    authentication text,
    organizational_unit text,
    internal_posts text,
    realname text,
    birthday date,
    address text,
    email text,
    nin text,
    xmpp_address text,
    website text,
    phone text,
    rsa_public_key bytea,
    certification_level integer DEFAULT 0 NOT NULL,
    token_serial text,
    mobile_phone text,
    profession text,
    elected boolean,
    auditor boolean,
    lqfb_access boolean,
    unit_group_id integer,
    external_memberships text,
    external_posts text,
    formatting_engine text,
    statement text,
    text_search_data tsvector,
    CONSTRAINT active_requires_activated_and_last_activity CHECK (((active = false) OR ((activated IS NOT NULL) AND (last_activity IS NOT NULL)))),
    CONSTRAINT name_not_null_if_activated CHECK (((activated IS NULL) OR (name IS NOT NULL)))
);


--
-- TOC entry 3250 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE member; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE member IS 'Users of the system, e.g. members of an organization';


--
-- TOC entry 3251 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.created; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.created IS 'Creation of member record and/or invite code';


--
-- TOC entry 3252 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.creator_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.creator_id IS 'Auditor member who created this account';


--
-- TOC entry 3253 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.invite_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.invite_code IS 'Optional invite code, to allow a member to initialize his/her account the first time';


--
-- TOC entry 3254 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.invite_code_expiry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.invite_code_expiry IS 'Expiry data/time for "invite_code"';


--
-- TOC entry 3255 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.admin_comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.admin_comment IS 'Hidden comment for administrative purposes';


--
-- TOC entry 3256 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.activated; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.activated IS 'Timestamp of first activation of account (i.e. usage of "invite_code"); required to be set for "active" members';


--
-- TOC entry 3257 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.last_activity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.last_activity IS 'Date of last activity of member; required to be set for "active" members';


--
-- TOC entry 3258 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.last_login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.last_login IS 'Timestamp of last login';


--
-- TOC entry 3259 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.certified; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.certified IS 'Timestamp of certification of account';


--
-- TOC entry 3260 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.certifier_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.certifier_id IS 'Auditor member who certified this account';


--
-- TOC entry 3261 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.login IS 'Login name';


--
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.password IS 'Password (preferably as crypto-hash, depending on the frontend or access layer)';


--
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.locked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.locked IS 'Locked members can not log in.';


--
-- TOC entry 3264 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.active IS 'Memberships, support and votes are taken into account when corresponding members are marked as active. Automatically set to FALSE, if "last_activity" is older than "system_setting"."member_ttl".';


--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.admin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.admin IS 'TRUE for admins, which can administrate other users and setup policies and areas';


--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.lang IS 'Language code of the preferred language of the member';


--
-- TOC entry 3267 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.notify_email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.notify_email IS 'Email address where notifications of the system are sent to';


--
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.notify_email_unconfirmed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.notify_email_unconfirmed IS 'Unconfirmed email address provided by the member to be copied into "notify_email" field after verification';


--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.notify_email_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.notify_email_secret IS 'Secret sent to the address in "notify_email_unconformed"';


--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.notify_email_secret_expiry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.notify_email_secret_expiry IS 'Expiry date/time for "notify_email_secret"';


--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.notify_email_lock_expiry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.notify_email_lock_expiry IS 'Date/time until no further email confirmation mails may be sent (abuse protection)';


--
-- TOC entry 3272 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.notify_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.notify_level IS 'Selects which event notifications are to be sent to the "notify_email" mail address, may be NULL if member did not make any selection yet';


--
-- TOC entry 3273 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.name IS 'Distinct name of the member, may be NULL if account has not been activated yet';


--
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.firstname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.firstname IS 'Real first of the member, may be NULL if account has not been activated yet';


--
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.lastname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.lastname IS 'Real last of the member, may be NULL if account has not been activated yet';


--
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.identification; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.identification IS 'Optional identification number or code of the member';


--
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.authentication; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.authentication IS 'Information about how this member was authenticated';


--
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.organizational_unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.organizational_unit IS 'Branch or division of the organization the member belongs to';


--
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.internal_posts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.internal_posts IS 'Posts (offices) of the member inside the organization';


--
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.realname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.realname IS 'Real name of the member, may be identical with "name"';


--
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.email IS 'Published email address of the member; not used for system notifications';


--
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.nin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.nin IS 'National Insurance Number';


--
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.rsa_public_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.rsa_public_key IS 'RSA Public Key for member';


--
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.certification_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.certification_level IS '0 = non certificato, 1 = certificato, 2 = pec, 3 = token';


--
-- TOC entry 3285 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.token_serial; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.token_serial IS 'Token serial';


--
-- TOC entry 3286 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.elected; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.elected IS 'Member was selected by vote for an office';


--
-- TOC entry 3287 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.auditor; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.auditor IS 'Member is an auditor who can create, modify or certify other members';


--
-- TOC entry 3288 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.lqfb_access; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.lqfb_access IS 'Member has access to lqfb. If FALSE member can still use admin and auditor functions';


--
-- TOC entry 3289 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.unit_group_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.unit_group_id IS 'ID of city of location of residence';


--
-- TOC entry 3290 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.external_memberships; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.external_memberships IS 'Other organizations the member is involved in';


--
-- TOC entry 3291 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.external_posts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.external_posts IS 'Posts (offices) outside the organization';


--
-- TOC entry 3292 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.formatting_engine; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.formatting_engine IS 'Allows different formatting engines (i.e. wiki formats) to be used for "member"."statement"';


--
-- TOC entry 3293 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN member.statement; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member.statement IS 'Freely chosen text of the member for his/her profile';


--
-- TOC entry 188 (class 1259 OID 18780)
-- Name: privilege; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE privilege (
    unit_id integer NOT NULL,
    member_id integer NOT NULL,
    admin_manager boolean DEFAULT false NOT NULL,
    unit_manager boolean DEFAULT false NOT NULL,
    area_manager boolean DEFAULT false NOT NULL,
    member_manager boolean DEFAULT false NOT NULL,
    initiative_right boolean DEFAULT true NOT NULL,
    voting_right boolean DEFAULT true NOT NULL,
    polling_right boolean DEFAULT false NOT NULL
);


--
-- TOC entry 3294 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE privilege; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE privilege IS 'Members rights related to each unit';


--
-- TOC entry 3295 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN privilege.admin_manager; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN privilege.admin_manager IS 'Grant/revoke any privileges to/from other members';


--
-- TOC entry 3296 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN privilege.unit_manager; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN privilege.unit_manager IS 'Create and disable sub units';


--
-- TOC entry 3297 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN privilege.area_manager; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN privilege.area_manager IS 'Create and disable areas and set area parameters';


--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN privilege.member_manager; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN privilege.member_manager IS 'Adding/removing members from the unit, granting or revoking "initiative_right" and "voting_right"';


--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN privilege.initiative_right; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN privilege.initiative_right IS 'Right to create an initiative';


--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN privilege.voting_right; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN privilege.voting_right IS 'Right to support initiatives, create and rate suggestions, and to vote';


--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN privilege.polling_right; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN privilege.polling_right IS 'Right to create issues with policies having the "policy"."polling" flag set, and to add initiatives having the "initiative"."polling" flag set to those issues';


--
-- TOC entry 189 (class 1259 OID 18790)
-- Name: area_delegation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW area_delegation AS
 SELECT DISTINCT ON (area.id, delegation.truster_id) area.id AS area_id,
    delegation.id,
    delegation.truster_id,
    delegation.trustee_id,
    delegation.scope
   FROM (((area
     JOIN delegation ON (((delegation.unit_id = area.unit_id) OR (delegation.area_id = area.id))))
     JOIN member ON ((delegation.truster_id = member.id)))
     JOIN privilege ON (((area.unit_id = privilege.unit_id) AND (delegation.truster_id = privilege.member_id))))
  WHERE (member.active AND privilege.voting_right)
  ORDER BY area.id, delegation.truster_id, delegation.scope DESC;


--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 189
-- Name: VIEW area_delegation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW area_delegation IS 'Area delegations where trusters are active and have voting right';


--
-- TOC entry 190 (class 1259 OID 18795)
-- Name: area_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 190
-- Name: area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE area_id_seq OWNED BY area.id;


--
-- TOC entry 191 (class 1259 OID 18797)
-- Name: membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE membership (
    area_id integer NOT NULL,
    member_id integer NOT NULL
);


--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE membership; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE membership IS 'Interest of members in topic areas';


--
-- TOC entry 192 (class 1259 OID 18800)
-- Name: area_member_count; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW area_member_count AS
 SELECT area.id AS area_id,
    count(member.id) AS direct_member_count,
    COALESCE(sum(
        CASE
            WHEN (member.id IS NOT NULL) THEN membership_weight(area.id, member.id)
            ELSE 0
        END)) AS member_weight
   FROM (((area
     LEFT JOIN membership ON ((area.id = membership.area_id)))
     LEFT JOIN privilege ON (((privilege.unit_id = area.unit_id) AND (privilege.member_id = membership.member_id) AND privilege.voting_right)))
     LEFT JOIN member ON (((member.id = privilege.member_id) AND member.active)))
  GROUP BY area.id;


--
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 192
-- Name: VIEW area_member_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW area_member_count IS 'View used to update "direct_member_count" and "member_weight" columns of table "area"';


--
-- TOC entry 193 (class 1259 OID 18805)
-- Name: area_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE area_setting (
    member_id integer NOT NULL,
    key text NOT NULL,
    area_id integer NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE area_setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE area_setting IS 'Place for frontend to store area specific settings of members as strings';


--
-- TOC entry 194 (class 1259 OID 18811)
-- Name: attach_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attach_id_seq
    START WITH 13
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 195 (class 1259 OID 18813)
-- Name: battle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE battle (
    issue_id integer NOT NULL,
    winning_initiative_id integer,
    losing_initiative_id integer,
    count integer NOT NULL,
    CONSTRAINT initiative_ids_not_equal CHECK (((winning_initiative_id <> losing_initiative_id) OR (((winning_initiative_id IS NOT NULL) AND (losing_initiative_id IS NULL)) OR ((winning_initiative_id IS NULL) AND (losing_initiative_id IS NOT NULL)))))
);


--
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE battle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE battle IS 'Number of members preferring one initiative to another; Filled by "battle_view" when closing an issue; NULL as initiative_id denotes virtual "status-quo" initiative';


--
-- TOC entry 196 (class 1259 OID 18817)
-- Name: initiative; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE initiative (
    issue_id integer NOT NULL,
    id integer NOT NULL,
    name text NOT NULL,
    polling boolean DEFAULT false NOT NULL,
    discussion_url text,
    created timestamp with time zone DEFAULT now() NOT NULL,
    revoked timestamp with time zone,
    revoked_by_member_id integer,
    suggested_initiative_id integer,
    admitted boolean,
    supporter_count integer,
    informed_supporter_count integer,
    satisfied_supporter_count integer,
    satisfied_informed_supporter_count integer,
    harmonic_weight numeric(12,3),
    final_suggestion_order_calculated boolean DEFAULT false NOT NULL,
    positive_votes integer,
    negative_votes integer,
    direct_majority boolean,
    indirect_majority boolean,
    schulze_rank integer,
    better_than_status_quo boolean,
    worse_than_status_quo boolean,
    reverse_beat_path boolean,
    multistage_majority boolean,
    eligible boolean,
    winner boolean,
    rank integer,
    text_search_data tsvector,
    title text,
    brief_description text,
    competence_fields text,
    author_type author_type,
    CONSTRAINT all_or_none_of_revoked_and_revoked_by_member_id_must_be_null CHECK (((revoked IS NOT NULL) = (revoked_by_member_id IS NOT NULL))),
    CONSTRAINT better_excludes_worse CHECK ((NOT (better_than_status_quo AND worse_than_status_quo))),
    CONSTRAINT eligible_at_first_rank_is_winner CHECK (((eligible = false) OR (rank <> 1) OR (winner = true))),
    CONSTRAINT minimum_requirement_to_be_eligible CHECK (((eligible = false) OR (direct_majority AND indirect_majority AND better_than_status_quo))),
    CONSTRAINT non_admitted_initiatives_cant_contain_voting_results CHECK ((((admitted IS NOT NULL) AND (admitted = true)) OR ((positive_votes IS NULL) AND (negative_votes IS NULL) AND (direct_majority IS NULL) AND (indirect_majority IS NULL) AND (schulze_rank IS NULL) AND (better_than_status_quo IS NULL) AND (worse_than_status_quo IS NULL) AND (reverse_beat_path IS NULL) AND (multistage_majority IS NULL) AND (eligible IS NULL) AND (winner IS NULL) AND (rank IS NULL)))),
    CONSTRAINT non_revoked_initiatives_cant_suggest_other CHECK (((revoked IS NOT NULL) OR (suggested_initiative_id IS NULL))),
    CONSTRAINT revoked_initiatives_cant_be_admitted CHECK (((revoked IS NULL) OR (admitted IS NULL))),
    CONSTRAINT winner_must_be_eligible CHECK (((winner = false) OR (eligible = true))),
    CONSTRAINT winner_must_have_first_rank CHECK (((winner = false) OR (rank = 1)))
);


--
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE initiative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE initiative IS 'Group of members publishing drafts for resolutions to be passed; Frontends must ensure that initiatives of half_frozen issues are not revoked, and that initiatives of fully_frozen or closed issues are neither revoked nor created.';


--
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.polling; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.polling IS 'Initiative does not need to pass the initiative quorum (see "policy"."polling")';


--
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.discussion_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.discussion_url IS 'URL pointing to a discussion platform for this initiative';


--
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.revoked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.revoked IS 'Point in time, when one initiator decided to revoke the initiative';


--
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.revoked_by_member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.revoked_by_member_id IS 'Member, who decided to revoke the initiative';


--
-- TOC entry 3313 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.admitted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.admitted IS 'TRUE, if initiative reaches the "initiative_quorum" when freezing the issue';


--
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.supporter_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.supporter_count IS 'Calculated from table "direct_supporter_snapshot"';


--
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.informed_supporter_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.informed_supporter_count IS 'Calculated from table "direct_supporter_snapshot"';


--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.satisfied_supporter_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.satisfied_supporter_count IS 'Calculated from table "direct_supporter_snapshot"';


--
-- TOC entry 3317 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.satisfied_informed_supporter_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.satisfied_informed_supporter_count IS 'Calculated from table "direct_supporter_snapshot"';


--
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.harmonic_weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.harmonic_weight IS 'Indicates the relevancy of the initiative, calculated from the potential supporters weighted with the harmonic series to avoid a large number of clones affecting other initiative''s sorting positions too much; shall be used as secondary sorting key after "admitted" as primary sorting key';


--
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.final_suggestion_order_calculated; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.final_suggestion_order_calculated IS 'Set to TRUE, when "proportional_order" of suggestions has been calculated the last time';


--
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.positive_votes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.positive_votes IS 'Calculated from table "direct_voter"';


--
-- TOC entry 3321 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.negative_votes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.negative_votes IS 'Calculated from table "direct_voter"';


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.direct_majority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.direct_majority IS 'TRUE, if "positive_votes"/("positive_votes"+"negative_votes") is strictly greater or greater-equal than "direct_majority_num"/"direct_majority_den", and "positive_votes" is greater-equal than "direct_majority_positive", and ("positive_votes"+abstentions) is greater-equal than "direct_majority_non_negative"';


--
-- TOC entry 3323 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.indirect_majority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.indirect_majority IS 'Same as "direct_majority", but also considering indirect beat paths';


--
-- TOC entry 3324 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.schulze_rank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.schulze_rank IS 'Schulze-Ranking without tie-breaking';


--
-- TOC entry 3325 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.better_than_status_quo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.better_than_status_quo IS 'TRUE, if initiative has a schulze-ranking better than the status quo (without tie-breaking)';


--
-- TOC entry 3326 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.worse_than_status_quo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.worse_than_status_quo IS 'TRUE, if initiative has a schulze-ranking worse than the status quo (without tie-breaking)';


--
-- TOC entry 3327 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.reverse_beat_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.reverse_beat_path IS 'TRUE, if there is a beat path (may include ties) from this initiative to the status quo';


--
-- TOC entry 3328 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.multistage_majority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.multistage_majority IS 'TRUE, if either (a) this initiative has no better rank than the status quo, or (b) there exists a better ranked initiative X, which directly beats this initiative, and either more voters prefer X to this initiative than voters preferring X to the status quo or less voters prefer this initiative to X than voters preferring the status quo to X';


--
-- TOC entry 3329 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.eligible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.eligible IS 'Initiative has a "direct_majority" and an "indirect_majority", is "better_than_status_quo" and depending on selected policy the initiative has no "reverse_beat_path" or "multistage_majority"';


--
-- TOC entry 3330 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.winner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.winner IS 'Winner is the "eligible" initiative with best "schulze_rank" and in case of ties with lowest "id"';


--
-- TOC entry 3331 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.rank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.rank IS 'Unique ranking for all "admitted" initiatives per issue; lower rank is better; a winner always has rank 1, but rank 1 does not imply that an initiative is winner; initiatives with "direct_majority" AND "indirect_majority" always have a better (lower) rank than other initiatives';


--
-- TOC entry 3332 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.title IS 'Initiative full title';


--
-- TOC entry 3333 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.brief_description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.brief_description IS 'Brief description of the initiative';


--
-- TOC entry 3334 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.competence_fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.competence_fields IS 'Technical competence fields';


--
-- TOC entry 3335 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN initiative.author_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative.author_type IS 'Type of author';


--
-- TOC entry 197 (class 1259 OID 18835)
-- Name: issue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE issue (
    id integer NOT NULL,
    area_id integer NOT NULL,
    policy_id integer NOT NULL,
    member_id integer,
    state issue_state DEFAULT 'admission'::issue_state NOT NULL,
    phase_finished timestamp with time zone,
    created timestamp with time zone DEFAULT now() NOT NULL,
    accepted timestamp with time zone,
    half_frozen timestamp with time zone,
    fully_frozen timestamp with time zone,
    closed timestamp with time zone,
    cleaned timestamp with time zone,
    admission_time interval,
    discussion_time interval NOT NULL,
    verification_time interval NOT NULL,
    voting_time interval NOT NULL,
    snapshot timestamp with time zone,
    latest_snapshot_event snapshot_event,
    population integer,
    voter_count integer,
    status_quo_schulze_rank integer,
    title text,
    brief_description text,
    keywords tsvector,
    problem_description text,
    aim_description text,
    CONSTRAINT admission_time_not_null_unless_instantly_accepted CHECK (((admission_time IS NOT NULL) OR ((accepted IS NOT NULL) AND (accepted = created)))),
    CONSTRAINT freeze_requires_snapshot CHECK (((fully_frozen IS NULL) OR (snapshot IS NOT NULL))),
    CONSTRAINT last_snapshot_on_full_freeze CHECK ((snapshot = fully_frozen)),
    CONSTRAINT only_closed_issues_may_be_cleaned CHECK (((cleaned IS NULL) OR (closed IS NOT NULL))),
    CONSTRAINT phase_finished_only_when_not_closed CHECK (((phase_finished IS NULL) OR (closed IS NULL))),
    CONSTRAINT set_both_or_none_of_snapshot_and_latest_snapshot_event CHECK (((snapshot IS NOT NULL) = (latest_snapshot_event IS NOT NULL))),
    CONSTRAINT state_change_order CHECK (((created <= accepted) AND (accepted <= half_frozen) AND (half_frozen <= fully_frozen) AND (fully_frozen <= closed))),
    CONSTRAINT valid_state CHECK (((((accepted IS NULL) AND (half_frozen IS NULL) AND (fully_frozen IS NULL)) OR ((accepted IS NOT NULL) AND (half_frozen IS NULL) AND (fully_frozen IS NULL)) OR ((accepted IS NOT NULL) AND (half_frozen IS NOT NULL) AND (fully_frozen IS NULL)) OR ((accepted IS NOT NULL) AND (half_frozen IS NOT NULL) AND (fully_frozen IS NOT NULL))) AND (((state = 'admission'::issue_state) AND (closed IS NULL) AND (accepted IS NULL)) OR ((state = 'discussion'::issue_state) AND (closed IS NULL) AND (accepted IS NOT NULL) AND (half_frozen IS NULL)) OR ((state = 'verification'::issue_state) AND (closed IS NULL) AND (half_frozen IS NOT NULL) AND (fully_frozen IS NULL)) OR ((state = 'voting'::issue_state) AND (closed IS NULL) AND (fully_frozen IS NOT NULL)) OR ((state = 'canceled_revoked_before_accepted'::issue_state) AND (closed IS NOT NULL) AND (accepted IS NULL)) OR ((state = 'canceled_issue_not_accepted'::issue_state) AND (closed IS NOT NULL) AND (accepted IS NULL)) OR ((state = 'canceled_after_revocation_during_discussion'::issue_state) AND (closed IS NOT NULL) AND (half_frozen IS NULL)) OR ((state = 'canceled_after_revocation_during_verification'::issue_state) AND (closed IS NOT NULL) AND (fully_frozen IS NULL)) OR ((state = 'canceled_no_initiative_admitted'::issue_state) AND (closed IS NOT NULL) AND (fully_frozen IS NOT NULL) AND (closed = fully_frozen)) OR ((state = 'finished_without_winner'::issue_state) AND (closed IS NOT NULL) AND (fully_frozen IS NOT NULL) AND (closed <> fully_frozen)) OR ((state = 'finished_with_winner'::issue_state) AND (closed IS NOT NULL) AND (fully_frozen IS NOT NULL) AND (closed <> fully_frozen)))))
);


--
-- TOC entry 3336 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE issue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE issue IS 'Groups of initiatives';


--
-- TOC entry 3337 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.phase_finished; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.phase_finished IS 'Set to a value NOTNULL, if the current phase has finished, but calculations are pending; No changes in this issue shall be made by the frontend or API when this value is set';


--
-- TOC entry 3338 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.accepted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.accepted IS 'Point in time, when one initiative of issue reached the "issue_quorum"';


--
-- TOC entry 3339 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.half_frozen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.half_frozen IS 'Point in time, when "discussion_time" has elapsed; Frontends must ensure that for half_frozen issues a) initiatives are not revoked, b) no new drafts are created, c) no initiators are added or removed.';


--
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.fully_frozen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.fully_frozen IS 'Point in time, when "verification_time" has elapsed and voting has started; Frontends must ensure that for fully_frozen issues additionally to the restrictions for half_frozen issues a) initiatives are not created, b) no interest is created or removed, c) no supporters are added or removed, d) no opinions are created, changed or deleted.';


--
-- TOC entry 3341 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.closed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.closed IS 'Point in time, when "admission_time" or "voting_time" have elapsed, and issue is no longer active; Frontends must ensure that for closed issues additionally to the restrictions for half_frozen and fully_frozen issues a) no voter is added or removed to/from the direct_voter table, b) no votes are added, modified or removed.';


--
-- TOC entry 3342 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.cleaned; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.cleaned IS 'Point in time, when discussion data and votes had been deleted';


--
-- TOC entry 3343 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.admission_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.admission_time IS 'Copied from "policy" table at creation of issue';


--
-- TOC entry 3344 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.discussion_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.discussion_time IS 'Copied from "policy" table at creation of issue';


--
-- TOC entry 3345 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.verification_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.verification_time IS 'Copied from "policy" table at creation of issue';


--
-- TOC entry 3346 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.voting_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.voting_time IS 'Copied from "policy" table at creation of issue';


--
-- TOC entry 3347 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.snapshot IS 'Point in time, when snapshot tables have been updated and "population" and *_count values were precalculated';


--
-- TOC entry 3348 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.latest_snapshot_event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.latest_snapshot_event IS 'Event type of latest snapshot for issue; Can be used to select the latest snapshot data in the snapshot tables';


--
-- TOC entry 3349 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.population; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.population IS 'Sum of "weight" column in table "direct_population_snapshot"';


--
-- TOC entry 3350 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.voter_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.voter_count IS 'Total number of direct and delegating voters; This value is related to the final voting, while "population" is related to snapshots before the final voting';


--
-- TOC entry 3351 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.status_quo_schulze_rank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.status_quo_schulze_rank IS 'Schulze rank of status quo, as calculated by "calculate_ranks" function';


--
-- TOC entry 3352 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.title IS 'Issue full title';


--
-- TOC entry 3353 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.brief_description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.brief_description IS 'Brief description of the issue';


--
-- TOC entry 3354 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.keywords; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.keywords IS 'Keyword provided by the author';


--
-- TOC entry 3355 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.problem_description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.problem_description IS 'Description of the problem to be solved';


--
-- TOC entry 3356 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN issue.aim_description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN issue.aim_description IS 'Description of the issue aim';


--
-- TOC entry 198 (class 1259 OID 18851)
-- Name: battle_participant; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW battle_participant AS
 SELECT initiative.id,
    initiative.issue_id
   FROM (issue
     JOIN initiative ON ((issue.id = initiative.issue_id)))
  WHERE initiative.admitted
UNION ALL
 SELECT NULL::integer AS id,
    issue.id AS issue_id
   FROM issue;


--
-- TOC entry 3357 (class 0 OID 0)
-- Dependencies: 198
-- Name: VIEW battle_participant; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW battle_participant IS 'Helper view for "battle_view" containing admitted initiatives plus virtual "status-quo" initiative denoted by NULL reference';


--
-- TOC entry 199 (class 1259 OID 18856)
-- Name: direct_voter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE direct_voter (
    issue_id integer NOT NULL,
    member_id integer NOT NULL,
    weight integer,
    comment_changed timestamp with time zone,
    formatting_engine text,
    comment text,
    text_search_data tsvector
);


--
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE direct_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE direct_voter IS 'Members having directly voted for/against initiatives of an issue; Frontends must ensure that no voters are added or removed to/from this table when the issue has been closed.';


--
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN direct_voter.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_voter.weight IS 'Weight of member (1 or higher) according to "delegating_voter" table';


--
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN direct_voter.comment_changed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_voter.comment_changed IS 'Shall be set on comment change, to indicate a comment being modified after voting has been finished; Automatically set to NULL after voting phase; Automatically set to NULL by trigger, if "comment" is set to NULL';


--
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN direct_voter.formatting_engine; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_voter.formatting_engine IS 'Allows different formatting engines (i.e. wiki formats) to be used for "direct_voter"."comment"; Automatically set to NULL by trigger, if "comment" is set to NULL';


--
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN direct_voter.comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_voter.comment IS 'Is to be set or updated by the frontend, if comment was inserted or updated AFTER the issue has been closed. Otherwise it shall be set to NULL.';


--
-- TOC entry 200 (class 1259 OID 18862)
-- Name: vote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vote (
    issue_id integer NOT NULL,
    initiative_id integer NOT NULL,
    member_id integer NOT NULL,
    grade integer
);


--
-- TOC entry 3363 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE vote; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE vote IS 'Manual and delegated votes without abstentions; Frontends must ensure that no votes are added modified or removed when the issue has been closed.';


--
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN vote.issue_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vote.issue_id IS 'WARNING: No index: For selections use column "initiative_id" and join via table "initiative" where neccessary';


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN vote.grade; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vote.grade IS 'Values smaller than zero mean reject, values greater than zero mean acceptance, zero or missing row means abstention. Preferences are expressed by different positive or negative numbers.';


--
-- TOC entry 201 (class 1259 OID 18865)
-- Name: battle_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW battle_view AS
 SELECT issue.id AS issue_id,
    winning_initiative.id AS winning_initiative_id,
    losing_initiative.id AS losing_initiative_id,
    sum(
        CASE
            WHEN (COALESCE(better_vote.grade, 0) > COALESCE(worse_vote.grade, 0)) THEN direct_voter.weight
            ELSE 0
        END) AS count
   FROM (((((issue
     LEFT JOIN direct_voter ON ((issue.id = direct_voter.issue_id)))
     JOIN battle_participant winning_initiative ON ((issue.id = winning_initiative.issue_id)))
     JOIN battle_participant losing_initiative ON ((issue.id = losing_initiative.issue_id)))
     LEFT JOIN vote better_vote ON (((direct_voter.member_id = better_vote.member_id) AND (winning_initiative.id = better_vote.initiative_id))))
     LEFT JOIN vote worse_vote ON (((direct_voter.member_id = worse_vote.member_id) AND (losing_initiative.id = worse_vote.initiative_id))))
  WHERE ((issue.state = 'voting'::issue_state) AND (issue.phase_finished IS NOT NULL) AND ((winning_initiative.id <> losing_initiative.id) OR (((winning_initiative.id IS NOT NULL) AND (losing_initiative.id IS NULL)) OR ((winning_initiative.id IS NULL) AND (losing_initiative.id IS NOT NULL)))))
  GROUP BY issue.id, winning_initiative.id, losing_initiative.id;


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 201
-- Name: VIEW battle_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW battle_view IS 'Number of members preferring one initiative (or status-quo) to another initiative (or status-quo); Used to fill "battle" table';


--
-- TOC entry 202 (class 1259 OID 18870)
-- Name: checked_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE checked_event (
    event_id integer NOT NULL,
    member_id integer NOT NULL
);


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE checked_event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE checked_event IS 'Possibility to filter events';


--
-- TOC entry 203 (class 1259 OID 18873)
-- Name: contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contact (
    member_id integer NOT NULL,
    other_member_id integer NOT NULL,
    public boolean DEFAULT false NOT NULL,
    CONSTRAINT cant_save_yourself_as_contact CHECK ((member_id <> other_member_id))
);


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE contact; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE contact IS 'Contact lists';


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN contact.member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN contact.member_id IS 'Member having the contact list';


--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN contact.other_member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN contact.other_member_id IS 'Member referenced in the contact list';


--
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN contact.public; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN contact.public IS 'TRUE = display contact publically';


--
-- TOC entry 204 (class 1259 OID 18878)
-- Name: contingent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contingent (
    polling boolean NOT NULL,
    time_frame interval NOT NULL,
    text_entry_limit integer,
    initiative_limit integer
);


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE contingent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE contingent IS 'Amount of text entries or initiatives a user may create within a given time frame. Only one row needs to be fulfilled for a member to be allowed to post. This table must not be empty.';


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN contingent.polling; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN contingent.polling IS 'Determines if settings are for creating initiatives and new drafts of initiatives with "polling" flag set';


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN contingent.text_entry_limit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN contingent.text_entry_limit IS 'Number of new drafts or suggestions to be submitted by each member within the given time frame';


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN contingent.initiative_limit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN contingent.initiative_limit IS 'Number of new initiatives to be opened by each member within a given time frame';


--
-- TOC entry 205 (class 1259 OID 18881)
-- Name: opinion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE opinion (
    initiative_id integer NOT NULL,
    suggestion_id bigint NOT NULL,
    member_id integer NOT NULL,
    degree smallint NOT NULL,
    fulfilled boolean DEFAULT false NOT NULL,
    CONSTRAINT opinion_degree_check CHECK (((degree >= '-2'::integer) AND (degree <= 2) AND (degree <> 0)))
);


--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE opinion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE opinion IS 'Opinion on suggestions (criticism related to initiatives); Frontends must ensure that opinions are not created modified or deleted when related to fully_frozen or closed issues.';


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN opinion.degree; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN opinion.degree IS '2 = fulfillment required for support; 1 = fulfillment desired; -1 = fulfillment unwanted; -2 = fulfillment cancels support';


--
-- TOC entry 206 (class 1259 OID 18886)
-- Name: critical_opinion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW critical_opinion AS
 SELECT opinion.initiative_id,
    opinion.suggestion_id,
    opinion.member_id,
    opinion.degree,
    opinion.fulfilled
   FROM opinion
  WHERE (((opinion.degree = 2) AND (opinion.fulfilled = false)) OR ((opinion.degree = '-2'::integer) AND (opinion.fulfilled = true)));


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 206
-- Name: VIEW critical_opinion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW critical_opinion IS 'Opinions currently causing dissatisfaction';


--
-- TOC entry 207 (class 1259 OID 18890)
-- Name: draft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE draft (
    initiative_id integer NOT NULL,
    id bigint NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    author_id integer NOT NULL,
    formatting_engine text,
    content text NOT NULL,
    text_search_data tsvector
);


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE draft; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE draft IS 'Drafts of initiatives to solve issues; Frontends must ensure that new drafts for initiatives of half_frozen, fully_frozen or closed issues can''t be created.';


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN draft.formatting_engine; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN draft.formatting_engine IS 'Allows different formatting engines (i.e. wiki formats) to be used';


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN draft.content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN draft.content IS 'Text of the draft in a format depending on the field "formatting_engine"';


--
-- TOC entry 208 (class 1259 OID 18897)
-- Name: current_draft; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW current_draft AS
 SELECT draft.initiative_id,
    draft.id,
    draft.created,
    draft.author_id,
    draft.formatting_engine,
    draft.content,
    draft.text_search_data
   FROM (( SELECT initiative.id AS initiative_id,
            max(draft_1.id) AS draft_id
           FROM (initiative
             JOIN draft draft_1 ON ((initiative.id = draft_1.initiative_id)))
          GROUP BY initiative.id) subquery
     JOIN draft ON ((subquery.draft_id = draft.id)));


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 208
-- Name: VIEW current_draft; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW current_draft IS 'All latest drafts for each initiative';


--
-- TOC entry 209 (class 1259 OID 18902)
-- Name: delegating_interest_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegating_interest_snapshot (
    issue_id integer NOT NULL,
    event snapshot_event NOT NULL,
    member_id integer NOT NULL,
    weight integer,
    scope delegation_scope NOT NULL,
    delegate_member_ids integer[] NOT NULL
);


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE delegating_interest_snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE delegating_interest_snapshot IS 'Delegations increasing the weight of entries in the "direct_interest_snapshot" table';


--
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN delegating_interest_snapshot.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_interest_snapshot.event IS 'Reason for snapshot, see "snapshot_event" type for details';


--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN delegating_interest_snapshot.member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_interest_snapshot.member_id IS 'Delegating member';


--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN delegating_interest_snapshot.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_interest_snapshot.weight IS 'Intermediate weight';


--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN delegating_interest_snapshot.delegate_member_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_interest_snapshot.delegate_member_ids IS 'Chain of members who act as delegates; last entry referes to "member_id" column of table "direct_interest_snapshot"';


--
-- TOC entry 210 (class 1259 OID 18908)
-- Name: delegating_population_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegating_population_snapshot (
    issue_id integer NOT NULL,
    event snapshot_event NOT NULL,
    member_id integer NOT NULL,
    weight integer,
    scope delegation_scope NOT NULL,
    delegate_member_ids integer[] NOT NULL
);


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN delegating_population_snapshot.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_population_snapshot.event IS 'Reason for snapshot, see "snapshot_event" type for details';


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN delegating_population_snapshot.member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_population_snapshot.member_id IS 'Delegating member';


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN delegating_population_snapshot.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_population_snapshot.weight IS 'Intermediate weight';


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN delegating_population_snapshot.delegate_member_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_population_snapshot.delegate_member_ids IS 'Chain of members who act as delegates; last entry referes to "member_id" column of table "direct_population_snapshot"';


--
-- TOC entry 211 (class 1259 OID 18914)
-- Name: delegating_voter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegating_voter (
    issue_id integer NOT NULL,
    member_id integer NOT NULL,
    weight integer,
    scope delegation_scope NOT NULL,
    delegate_member_ids integer[] NOT NULL
);


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE delegating_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE delegating_voter IS 'Delegations increasing the weight of entries in the "direct_voter" table';


--
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN delegating_voter.member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_voter.member_id IS 'Delegating member';


--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN delegating_voter.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_voter.weight IS 'Intermediate weight';


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN delegating_voter.delegate_member_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN delegating_voter.delegate_member_ids IS 'Chain of members who act as delegates; last entry referes to "member_id" column of table "direct_voter"';


--
-- TOC entry 212 (class 1259 OID 18920)
-- Name: delegation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 212
-- Name: delegation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delegation_id_seq OWNED BY delegation.id;


--
-- TOC entry 213 (class 1259 OID 18922)
-- Name: direct_interest_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE direct_interest_snapshot (
    issue_id integer NOT NULL,
    event snapshot_event NOT NULL,
    member_id integer NOT NULL,
    weight integer
);


--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE direct_interest_snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE direct_interest_snapshot IS 'Snapshot of active members having an "interest" in the "issue"';


--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN direct_interest_snapshot.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_interest_snapshot.event IS 'Reason for snapshot, see "snapshot_event" type for details';


--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN direct_interest_snapshot.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_interest_snapshot.weight IS 'Weight of member (1 or higher) according to "delegating_interest_snapshot"';


--
-- TOC entry 214 (class 1259 OID 18925)
-- Name: direct_population_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE direct_population_snapshot (
    issue_id integer NOT NULL,
    event snapshot_event NOT NULL,
    member_id integer NOT NULL,
    weight integer
);


--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE direct_population_snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE direct_population_snapshot IS 'Delegations increasing the weight of entries in the "direct_population_snapshot" table';


--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN direct_population_snapshot.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_population_snapshot.event IS 'Reason for snapshot, see "snapshot_event" type for details';


--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN direct_population_snapshot.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_population_snapshot.weight IS 'Weight of member (1 or higher) according to "delegating_population_snapshot"';


--
-- TOC entry 215 (class 1259 OID 18928)
-- Name: direct_supporter_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE direct_supporter_snapshot (
    issue_id integer NOT NULL,
    initiative_id integer NOT NULL,
    event snapshot_event NOT NULL,
    member_id integer NOT NULL,
    draft_id bigint NOT NULL,
    informed boolean NOT NULL,
    satisfied boolean NOT NULL
);


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE direct_supporter_snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE direct_supporter_snapshot IS 'Snapshot of supporters of initiatives (weight is stored in "direct_interest_snapshot")';


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN direct_supporter_snapshot.issue_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_supporter_snapshot.issue_id IS 'WARNING: No index: For selections use column "initiative_id" and join via table "initiative" where neccessary';


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN direct_supporter_snapshot.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_supporter_snapshot.event IS 'Reason for snapshot, see "snapshot_event" type for details';


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN direct_supporter_snapshot.informed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_supporter_snapshot.informed IS 'Supporter has seen the latest draft of the initiative';


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN direct_supporter_snapshot.satisfied; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN direct_supporter_snapshot.satisfied IS 'Supporter has no "critical_opinion"s';


--
-- TOC entry 216 (class 1259 OID 18931)
-- Name: draft_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE draft_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 216
-- Name: draft_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE draft_id_seq OWNED BY draft.id;


--
-- TOC entry 217 (class 1259 OID 18933)
-- Name: event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE event (
    id bigint NOT NULL,
    occurrence timestamp with time zone DEFAULT now() NOT NULL,
    event event_type NOT NULL,
    member_id integer,
    issue_id integer,
    state issue_state,
    initiative_id integer,
    draft_id bigint,
    suggestion_id bigint,
    CONSTRAINT null_constraints_for_initiative_creation_or_revocation_or_new_d CHECK (((event <> ALL (ARRAY['initiative_created_in_new_issue'::event_type, 'initiative_created_in_existing_issue'::event_type, 'initiative_revoked'::event_type, 'new_draft_created'::event_type])) OR ((member_id IS NOT NULL) AND (issue_id IS NOT NULL) AND (state IS NOT NULL) AND (initiative_id IS NOT NULL) AND (draft_id IS NOT NULL) AND (suggestion_id IS NULL)))),
    CONSTRAINT null_constraints_for_issue_state_changed CHECK (((event <> 'issue_state_changed'::event_type) OR ((member_id IS NULL) AND (issue_id IS NOT NULL) AND (state IS NOT NULL) AND (initiative_id IS NULL) AND (draft_id IS NULL) AND (suggestion_id IS NULL)))),
    CONSTRAINT null_constraints_for_suggestion_creation CHECK (((event <> 'suggestion_created'::event_type) OR ((member_id IS NOT NULL) AND (issue_id IS NOT NULL) AND (state IS NOT NULL) AND (initiative_id IS NOT NULL) AND (draft_id IS NULL) AND (suggestion_id IS NOT NULL))))
);


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE event IS 'Event table, automatically filled by triggers';


--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN event.occurrence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.occurrence IS 'Point in time, when event occurred';


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN event.event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.event IS 'Type of event (see TYPE "event_type")';


--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN event.member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.member_id IS 'Member who caused the event, if applicable';


--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN event.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.state IS 'If issue_id is set: state of affected issue; If state changed: new state';


--
-- TOC entry 218 (class 1259 OID 18940)
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 218
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_id_seq OWNED BY event.id;


--
-- TOC entry 219 (class 1259 OID 18942)
-- Name: ignored_initiative; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ignored_initiative (
    initiative_id integer NOT NULL,
    member_id integer NOT NULL
);


--
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE ignored_initiative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE ignored_initiative IS 'Possibility to filter initiatives';


--
-- TOC entry 220 (class 1259 OID 18945)
-- Name: ignored_member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ignored_member (
    member_id integer NOT NULL,
    other_member_id integer NOT NULL
);


--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE ignored_member; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE ignored_member IS 'Possibility to filter other members';


--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN ignored_member.member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN ignored_member.member_id IS 'Member ignoring someone';


--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN ignored_member.other_member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN ignored_member.other_member_id IS 'Member being ignored';


--
-- TOC entry 221 (class 1259 OID 18948)
-- Name: interest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE interest (
    issue_id integer NOT NULL,
    member_id integer NOT NULL
);


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE interest; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE interest IS 'Interest of members in a particular issue; Frontends must ensure that interest for fully_frozen or closed issues is not added or removed.';


--
-- TOC entry 222 (class 1259 OID 18951)
-- Name: supporter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE supporter (
    issue_id integer NOT NULL,
    initiative_id integer NOT NULL,
    member_id integer NOT NULL,
    draft_id bigint NOT NULL
);


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE supporter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE supporter IS 'Members who support an initiative (conditionally); Frontends must ensure that supporters are not added or removed from fully_frozen or closed initiatives.';


--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN supporter.issue_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN supporter.issue_id IS 'WARNING: No index: For selections use column "initiative_id" and join via table "initiative" where neccessary';


--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN supporter.draft_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN supporter.draft_id IS 'Latest seen draft; should always be set by a frontend, but defaults to current draft of the initiative (implemented by trigger "default_for_draft_id")';


--
-- TOC entry 223 (class 1259 OID 18954)
-- Name: event_seen_by_member; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW event_seen_by_member AS
 SELECT member.id AS seen_by_member_id,
        CASE
            WHEN (event.state = ANY (ARRAY['voting'::issue_state, 'finished_without_winner'::issue_state, 'finished_with_winner'::issue_state])) THEN 'voting'::notify_level
            ELSE
            CASE
                WHEN (event.state = ANY (ARRAY['verification'::issue_state, 'canceled_after_revocation_during_verification'::issue_state, 'canceled_no_initiative_admitted'::issue_state])) THEN 'verification'::notify_level
                ELSE
                CASE
                    WHEN (event.state = ANY (ARRAY['discussion'::issue_state, 'canceled_after_revocation_during_discussion'::issue_state])) THEN 'discussion'::notify_level
                    ELSE 'all'::notify_level
                END
            END
        END AS notify_level,
    event.id,
    event.occurrence,
    event.event,
    event.member_id,
    event.issue_id,
    event.state,
    event.initiative_id,
    event.draft_id,
    event.suggestion_id
   FROM (((((((member
     CROSS JOIN event)
     LEFT JOIN issue ON ((event.issue_id = issue.id)))
     LEFT JOIN membership ON (((member.id = membership.member_id) AND (issue.area_id = membership.area_id))))
     LEFT JOIN interest ON (((member.id = interest.member_id) AND (event.issue_id = interest.issue_id))))
     LEFT JOIN supporter ON (((member.id = supporter.member_id) AND (event.initiative_id = supporter.initiative_id))))
     LEFT JOIN ignored_member ON (((member.id = ignored_member.member_id) AND (event.member_id = ignored_member.other_member_id))))
     LEFT JOIN ignored_initiative ON (((member.id = ignored_initiative.member_id) AND (event.initiative_id = ignored_initiative.initiative_id))))
  WHERE (((supporter.member_id IS NOT NULL) OR (interest.member_id IS NOT NULL) OR ((membership.member_id IS NOT NULL) AND (event.event = ANY (ARRAY['issue_state_changed'::event_type, 'initiative_created_in_new_issue'::event_type, 'initiative_created_in_existing_issue'::event_type, 'initiative_revoked'::event_type])))) AND (ignored_member.member_id IS NULL) AND (ignored_initiative.member_id IS NULL));


--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 223
-- Name: VIEW event_seen_by_member; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW event_seen_by_member IS 'Events as seen by a member, depending on its memberships, interests and support, but ignoring members "notify_level"';


--
-- TOC entry 224 (class 1259 OID 18959)
-- Name: session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE session (
    ident text NOT NULL,
    additional_secret text,
    expiry timestamp with time zone DEFAULT (now() + '24:00:00'::interval) NOT NULL,
    member_id bigint,
    lang text
);


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE session IS 'Sessions, i.e. for a web-frontend or API layer';


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN session.ident; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN session.ident IS 'Secret session identifier (i.e. random string)';


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN session.additional_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN session.additional_secret IS 'Additional field to store a secret, which can be used against CSRF attacks';


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN session.member_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN session.member_id IS 'Reference to member, who is logged in';


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN session.lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN session.lang IS 'Language code of the selected language';


--
-- TOC entry 225 (class 1259 OID 18966)
-- Name: expired_session; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW expired_session AS
 SELECT session.ident,
    session.additional_secret,
    session.expiry,
    session.member_id,
    session.lang
   FROM session
  WHERE (now() > session.expiry);


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 225
-- Name: VIEW expired_session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW expired_session IS 'View containing all expired sessions where DELETE is possible';


--
-- TOC entry 226 (class 1259 OID 18970)
-- Name: idcard_scan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE idcard_scan (
    member_id integer NOT NULL,
    scan_type scan_type NOT NULL,
    data bytea NOT NULL
);


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE idcard_scan; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE idcard_scan IS 'HQ scans of member picture, id cards and/or other idenfication documents';


--
-- TOC entry 227 (class 1259 OID 18976)
-- Name: individual_suggestion_ranking; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW individual_suggestion_ranking AS
 SELECT opinion.initiative_id,
    opinion.member_id,
    direct_interest_snapshot.weight,
        CASE
            WHEN (((opinion.degree = 2) AND (opinion.fulfilled = false)) OR ((opinion.degree = '-2'::integer) AND (opinion.fulfilled = true))) THEN 1
            ELSE
            CASE
                WHEN (((opinion.degree = 1) AND (opinion.fulfilled = false)) OR ((opinion.degree = '-1'::integer) AND (opinion.fulfilled = true))) THEN 2
                ELSE
                CASE
                    WHEN (((opinion.degree = 2) AND (opinion.fulfilled = true)) OR ((opinion.degree = '-2'::integer) AND (opinion.fulfilled = false))) THEN 3
                    ELSE 4
                END
            END
        END AS preference,
    opinion.suggestion_id
   FROM (((opinion
     JOIN initiative ON ((initiative.id = opinion.initiative_id)))
     JOIN issue ON ((issue.id = initiative.issue_id)))
     JOIN direct_interest_snapshot ON (((direct_interest_snapshot.issue_id = issue.id) AND (direct_interest_snapshot.event = issue.latest_snapshot_event) AND (direct_interest_snapshot.member_id = opinion.member_id))));


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 227
-- Name: VIEW individual_suggestion_ranking; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW individual_suggestion_ranking IS 'Helper view for "lf_update_suggestion_order" to allow a proportional ordering of suggestions within an initiative';


--
-- TOC entry 228 (class 1259 OID 18981)
-- Name: initiative_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE initiative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 228
-- Name: initiative_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE initiative_id_seq OWNED BY initiative.id;


--
-- TOC entry 229 (class 1259 OID 18983)
-- Name: initiative_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE initiative_setting (
    member_id integer NOT NULL,
    key text NOT NULL,
    initiative_id integer NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE initiative_setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE initiative_setting IS 'Place for frontend to store initiative specific settings of members as strings';


--
-- TOC entry 230 (class 1259 OID 18989)
-- Name: initiative_suggestion_order_calculation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW initiative_suggestion_order_calculation AS
 SELECT initiative.id AS initiative_id,
    ((issue.closed IS NOT NULL) OR (issue.fully_frozen IS NOT NULL)) AS final
   FROM (initiative
     JOIN issue ON ((initiative.issue_id = issue.id)))
  WHERE (((issue.closed IS NULL) AND (issue.fully_frozen IS NULL)) OR (initiative.final_suggestion_order_calculated = false));


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 230
-- Name: VIEW initiative_suggestion_order_calculation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW initiative_suggestion_order_calculation IS 'Initiatives, where the "proportional_order" of its suggestions has to be calculated';


--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN initiative_suggestion_order_calculation.final; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiative_suggestion_order_calculation.final IS 'Set to TRUE, if the issue is fully frozen or closed, and the calculation has to be done only once for one last time';


--
-- TOC entry 231 (class 1259 OID 18994)
-- Name: initiator; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE initiator (
    initiative_id integer NOT NULL,
    member_id integer NOT NULL,
    accepted boolean
);


--
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE initiator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE initiator IS 'Members who are allowed to post new drafts; Frontends must ensure that initiators are not added or removed from half_frozen, fully_frozen or closed initiatives.';


--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN initiator.accepted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN initiator.accepted IS 'If "accepted" is NULL, then the member was invited to be a co-initiator, but has not answered yet. If it is TRUE, the member has accepted the invitation, if it is FALSE, the member has rejected the invitation.';


--
-- TOC entry 232 (class 1259 OID 18997)
-- Name: issue_delegation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW issue_delegation AS
 SELECT DISTINCT ON (issue.id, delegation.truster_id) issue.id AS issue_id,
    delegation.id,
    delegation.truster_id,
    delegation.trustee_id,
    delegation.scope
   FROM ((((issue
     JOIN area ON ((area.id = issue.area_id)))
     JOIN delegation ON (((delegation.unit_id = area.unit_id) OR (delegation.area_id = area.id) OR (delegation.issue_id = issue.id))))
     JOIN member ON ((delegation.truster_id = member.id)))
     JOIN privilege ON (((area.unit_id = privilege.unit_id) AND (delegation.truster_id = privilege.member_id))))
  WHERE (member.active AND privilege.voting_right)
  ORDER BY issue.id, delegation.truster_id, delegation.scope DESC;


--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 232
-- Name: VIEW issue_delegation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW issue_delegation IS 'Issue delegations where trusters are active and have voting right';


--
-- TOC entry 233 (class 1259 OID 19002)
-- Name: issue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 233
-- Name: issue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issue_id_seq OWNED BY issue.id;


--
-- TOC entry 234 (class 1259 OID 19004)
-- Name: issue_keyword; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE issue_keyword (
    issue_id integer NOT NULL,
    keyword_id integer NOT NULL
);


--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE issue_keyword; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE issue_keyword IS 'Keywords to issues association';


--
-- TOC entry 235 (class 1259 OID 19007)
-- Name: issue_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE issue_setting (
    member_id integer NOT NULL,
    key text NOT NULL,
    issue_id integer NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE issue_setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE issue_setting IS 'Place for frontend to store issue specific settings of members as strings';


--
-- TOC entry 236 (class 1259 OID 19013)
-- Name: istat_comuni; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE istat_comuni (
    codice_regione character varying(2) DEFAULT NULL::character varying,
    codice_provincia character varying(3) DEFAULT NULL::character varying,
    sigla_provincia character varying(5) DEFAULT NULL::character varying,
    codice_comune character varying(6) DEFAULT ''::character varying NOT NULL,
    cap character varying(20) DEFAULT NULL::character varying,
    "Denominazione (italiano/tedesco)" character varying(60) DEFAULT NULL::character varying,
    nome_comune character varying(35) DEFAULT NULL::character varying,
    "Solo denominazione in tedesco" character varying(36) DEFAULT NULL::character varying,
    "Comune capoluogo di provincia" character varying(1) DEFAULT NULL::character varying,
    "Zona altimetrica" character varying(1) DEFAULT NULL::character varying,
    "Altitudine del centro (metri)" character varying(7) DEFAULT NULL::character varying,
    "Comune litoraneo" character varying(1) DEFAULT NULL::character varying,
    "Comune Montano" character varying(2) DEFAULT NULL::character varying,
    "Codice Sistema locale del lavoro 2001" character varying(3) DEFAULT NULL::character varying,
    "Denominazione Sistema locale del lavoro 2001" character varying(49) DEFAULT NULL::character varying,
    "Superficie territoriale totale (kmq)" character varying(7) DEFAULT NULL::character varying,
    "Popolazione legale 2001 (21/10/2001)" character varying(9) DEFAULT NULL::character varying,
    "Popolazione residente al 31/12/2008" character varying(9) DEFAULT NULL::character varying,
    "Popolazione residente al 31/12/2009" character varying(9) DEFAULT NULL::character varying,
    "Popolazione residente al 31/12/2010" character varying(9) DEFAULT NULL::character varying
);


--
-- TOC entry 237 (class 1259 OID 19036)
-- Name: istat_province; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE istat_province (
    codice_regione character varying(14) DEFAULT NULL::character varying,
    codice_provincia character varying(16) DEFAULT ''::character varying NOT NULL,
    nome_provincia character varying(28) DEFAULT NULL::character varying,
    sigla_provincia character varying(21) DEFAULT ''::character varying NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 19043)
-- Name: istat_regioni; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE istat_regioni (
    codice_regione character varying(255) NOT NULL,
    nome_regione character varying(255) NOT NULL
);


--
-- TOC entry 239 (class 1259 OID 19049)
-- Name: keyword; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE keyword (
    id integer NOT NULL,
    name text NOT NULL,
    technical_keyword boolean DEFAULT false NOT NULL
);


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE keyword; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE keyword IS 'Possibility to filter issues';


--
-- TOC entry 240 (class 1259 OID 19056)
-- Name: keyword_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE keyword_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 240
-- Name: keyword_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE keyword_id_seq OWNED BY keyword.id;


--
-- TOC entry 241 (class 1259 OID 19058)
-- Name: liquid_feedback_version; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW liquid_feedback_version AS
 SELECT subquery.string,
    subquery.major,
    subquery.minor,
    subquery.revision
   FROM ( VALUES ('2.2.1'::text,2,2,1)) subquery(string, major, minor, revision);


--
-- TOC entry 242 (class 1259 OID 19062)
-- Name: member_application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member_application (
    id bigint NOT NULL,
    member_id integer NOT NULL,
    name text NOT NULL,
    comment text,
    access_level application_access_level NOT NULL,
    key text NOT NULL,
    last_usage timestamp with time zone
);


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE member_application; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE member_application IS 'DEPRECATED, WILL BE REMOVED! Registered application being allowed to use the API';


--
-- TOC entry 243 (class 1259 OID 19068)
-- Name: member_application_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE member_application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 243
-- Name: member_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE member_application_id_seq OWNED BY member_application.id;


--
-- TOC entry 244 (class 1259 OID 19070)
-- Name: opening_draft; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW opening_draft AS
 SELECT draft.initiative_id,
    draft.id,
    draft.created,
    draft.author_id,
    draft.formatting_engine,
    draft.content,
    draft.text_search_data
   FROM (( SELECT initiative.id AS initiative_id,
            min(draft_1.id) AS draft_id
           FROM (initiative
             JOIN draft draft_1 ON ((initiative.id = draft_1.initiative_id)))
          GROUP BY initiative.id) subquery
     JOIN draft ON ((subquery.draft_id = draft.id)));


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 244
-- Name: VIEW opening_draft; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW opening_draft IS 'First drafts of all initiatives';


--
-- TOC entry 245 (class 1259 OID 19075)
-- Name: suggestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE suggestion (
    initiative_id integer NOT NULL,
    id bigint NOT NULL,
    draft_id bigint NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    author_id integer NOT NULL,
    name text NOT NULL,
    formatting_engine text,
    content text DEFAULT ''::text NOT NULL,
    text_search_data tsvector,
    minus2_unfulfilled_count integer,
    minus2_fulfilled_count integer,
    minus1_unfulfilled_count integer,
    minus1_fulfilled_count integer,
    plus1_unfulfilled_count integer,
    plus1_fulfilled_count integer,
    plus2_unfulfilled_count integer,
    plus2_fulfilled_count integer,
    proportional_order integer
);


--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE suggestion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE suggestion IS 'Suggestions to initiators, to change the current draft; must not be deleted explicitly, as they vanish automatically if the last opinion is deleted';


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.draft_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.draft_id IS 'Draft, which the author has seen when composing the suggestion; should always be set by a frontend, but defaults to current draft of the initiative (implemented by trigger "default_for_draft_id")';


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.minus2_unfulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.minus2_unfulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.minus2_fulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.minus2_fulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.minus1_unfulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.minus1_unfulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.minus1_fulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.minus1_fulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.plus1_unfulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.plus1_unfulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.plus1_fulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.plus1_fulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.plus2_unfulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.plus2_unfulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.plus2_fulfilled_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.plus2_fulfilled_count IS 'Calculated from table "direct_supporter_snapshot", not requiring informed supporters';


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN suggestion.proportional_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN suggestion.proportional_order IS 'To be used for sorting suggestions within an initiative; NULL values sort last; updated by "lf_update_suggestion_order"';


--
-- TOC entry 246 (class 1259 OID 19083)
-- Name: member_contingent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW member_contingent AS
 SELECT member.id AS member_id,
    contingent.polling,
    contingent.time_frame,
        CASE
            WHEN (contingent.text_entry_limit IS NOT NULL) THEN (( SELECT count(1) AS count
               FROM (draft
                 JOIN initiative ON ((initiative.id = draft.initiative_id)))
              WHERE ((draft.author_id = member.id) AND (initiative.polling = contingent.polling) AND (draft.created > (now() - contingent.time_frame)))) + ( SELECT count(1) AS count
               FROM (suggestion
                 JOIN initiative ON ((initiative.id = suggestion.initiative_id)))
              WHERE ((suggestion.author_id = member.id) AND (contingent.polling = false) AND (suggestion.created > (now() - contingent.time_frame)))))
            ELSE NULL::bigint
        END AS text_entry_count,
    contingent.text_entry_limit,
        CASE
            WHEN (contingent.initiative_limit IS NOT NULL) THEN ( SELECT count(1) AS count
               FROM (opening_draft draft
                 JOIN initiative ON ((initiative.id = draft.initiative_id)))
              WHERE ((draft.author_id = member.id) AND (initiative.polling = contingent.polling) AND (draft.created > (now() - contingent.time_frame))))
            ELSE NULL::bigint
        END AS initiative_count,
    contingent.initiative_limit
   FROM (member
     CROSS JOIN contingent);


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 246
-- Name: VIEW member_contingent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW member_contingent IS 'Actual counts of text entries and initiatives are calculated per member for each limit in the "contingent" table.';


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN member_contingent.text_entry_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_contingent.text_entry_count IS 'Only calculated when "text_entry_limit" is not null in the same row';


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN member_contingent.initiative_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_contingent.initiative_count IS 'Only calculated when "initiative_limit" is not null in the same row';


--
-- TOC entry 247 (class 1259 OID 19088)
-- Name: member_contingent_left; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW member_contingent_left AS
 SELECT member_contingent.member_id,
    member_contingent.polling,
    max((member_contingent.text_entry_limit - member_contingent.text_entry_count)) AS text_entries_left,
    max((member_contingent.initiative_limit - member_contingent.initiative_count)) AS initiatives_left
   FROM member_contingent
  GROUP BY member_contingent.member_id, member_contingent.polling;


--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 247
-- Name: VIEW member_contingent_left; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW member_contingent_left IS 'Amount of text entries or initiatives which can be posted now instantly by a member. This view should be used by a frontend to determine, if the contingent for posting is exhausted.';


--
-- TOC entry 248 (class 1259 OID 19092)
-- Name: member_count; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member_count (
    calculated timestamp with time zone DEFAULT now() NOT NULL,
    total_count integer NOT NULL
);


--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE member_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE member_count IS 'Contains one row which contains the total count of active(!) members and a timestamp indicating when the total member count and area member counts were calculated';


--
-- TOC entry 3463 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN member_count.calculated; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_count.calculated IS 'timestamp indicating when the total member count and area member counts were calculated';


--
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN member_count.total_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_count.total_count IS 'Total count of active(!) members';


--
-- TOC entry 249 (class 1259 OID 19096)
-- Name: member_count_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW member_count_view AS
 SELECT count(1) AS total_count
   FROM member
  WHERE member.active;


--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 249
-- Name: VIEW member_count_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW member_count_view IS 'View used to update "member_count" table';


--
-- TOC entry 250 (class 1259 OID 19100)
-- Name: member_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member_data (
    id integer NOT NULL,
    firstname text,
    lastname text,
    nin text,
    birthplace text NOT NULL,
    birthdate date NOT NULL,
    idcard text NOT NULL,
    email text NOT NULL,
    residence_address text NOT NULL,
    residence_city text NOT NULL,
    residence_province text NOT NULL,
    residence_postcode text NOT NULL,
    domicile_address text NOT NULL,
    domicile_city text NOT NULL,
    domicile_province text NOT NULL,
    domicile_postcode text NOT NULL,
    location text NOT NULL,
    rsa_public_key bytea,
    certification_level integer DEFAULT 0 NOT NULL,
    token_serial text NOT NULL
);


--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE member_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE member_data IS 'Member sensitive data collection';


--
-- TOC entry 251 (class 1259 OID 19107)
-- Name: member_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member_history (
    id bigint NOT NULL,
    member_id integer NOT NULL,
    until timestamp with time zone DEFAULT now() NOT NULL,
    active boolean NOT NULL,
    name text NOT NULL
);


--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE member_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE member_history IS 'Filled by trigger; keeps information about old names and active flag of members';


--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN member_history.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_history.id IS 'Primary key, which can be used to sort entries correctly (and time warp resistant)';


--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN member_history.until; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_history.until IS 'Timestamp until the data was valid';


--
-- TOC entry 252 (class 1259 OID 19114)
-- Name: member_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE member_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 252
-- Name: member_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE member_history_id_seq OWNED BY member_history.id;


--
-- TOC entry 253 (class 1259 OID 19116)
-- Name: member_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 253
-- Name: member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE member_id_seq OWNED BY member.id;


--
-- TOC entry 254 (class 1259 OID 19118)
-- Name: member_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member_image (
    member_id integer NOT NULL,
    image_type member_image_type NOT NULL,
    scaled boolean NOT NULL,
    content_type text,
    data bytea NOT NULL
);


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE member_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE member_image IS 'Images of members';


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN member_image.scaled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_image.scaled IS 'FALSE for original image, TRUE for scaled version of the image';


--
-- TOC entry 255 (class 1259 OID 19124)
-- Name: member_login; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member_login (
    member_id integer NOT NULL,
    login_time timestamp with time zone NOT NULL,
    geolat numeric(10,8),
    geolng numeric(11,8),
    browser text,
    os text
);


--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN member_login.geolat; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_login.geolat IS 'Latitude';


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN member_login.geolng; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_login.geolng IS 'Longitude';


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN member_login.browser; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_login.browser IS 'Browser';


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN member_login.os; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN member_login.os IS 'Operating system';


--
-- TOC entry 256 (class 1259 OID 19130)
-- Name: member_relation_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE member_relation_setting (
    member_id integer NOT NULL,
    key text NOT NULL,
    other_member_id integer NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE member_relation_setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE member_relation_setting IS 'Place to store a frontend specific setting related to relations between members as a string';


--
-- TOC entry 257 (class 1259 OID 19136)
-- Name: non_voter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE non_voter (
    issue_id integer NOT NULL,
    member_id integer NOT NULL
);


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE non_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE non_voter IS 'Members who decided to not vote directly on an issue';


--
-- TOC entry 258 (class 1259 OID 19139)
-- Name: notification_sent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE notification_sent (
    event_id bigint NOT NULL
);


--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE notification_sent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE notification_sent IS 'This table stores one row with the last event_id, for which notifications have been sent out';


--
-- TOC entry 259 (class 1259 OID 19142)
-- Name: open_issue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW open_issue AS
 SELECT issue.id,
    issue.area_id,
    issue.policy_id,
    issue.member_id,
    issue.state,
    issue.phase_finished,
    issue.created,
    issue.accepted,
    issue.half_frozen,
    issue.fully_frozen,
    issue.closed,
    issue.cleaned,
    issue.admission_time,
    issue.discussion_time,
    issue.verification_time,
    issue.voting_time,
    issue.snapshot,
    issue.latest_snapshot_event,
    issue.population,
    issue.voter_count,
    issue.status_quo_schulze_rank,
    issue.title,
    issue.brief_description,
    issue.keywords,
    issue.problem_description,
    issue.aim_description
   FROM issue
  WHERE (issue.closed IS NULL);


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 259
-- Name: VIEW open_issue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW open_issue IS 'All open issues';


--
-- TOC entry 260 (class 1259 OID 19147)
-- Name: policy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE policy (
    id integer NOT NULL,
    index integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    polling boolean DEFAULT false NOT NULL,
    admission_time interval,
    discussion_time interval,
    verification_time interval,
    voting_time interval,
    issue_quorum_num integer,
    issue_quorum_den integer,
    initiative_quorum_num integer NOT NULL,
    initiative_quorum_den integer NOT NULL,
    direct_majority_num integer DEFAULT 1 NOT NULL,
    direct_majority_den integer DEFAULT 2 NOT NULL,
    direct_majority_strict boolean DEFAULT true NOT NULL,
    direct_majority_positive integer DEFAULT 0 NOT NULL,
    direct_majority_non_negative integer DEFAULT 0 NOT NULL,
    indirect_majority_num integer DEFAULT 1 NOT NULL,
    indirect_majority_den integer DEFAULT 2 NOT NULL,
    indirect_majority_strict boolean DEFAULT true NOT NULL,
    indirect_majority_positive integer DEFAULT 0 NOT NULL,
    indirect_majority_non_negative integer DEFAULT 0 NOT NULL,
    no_reverse_beat_path boolean DEFAULT true NOT NULL,
    no_multistage_majority boolean DEFAULT false NOT NULL,
    CONSTRAINT issue_quorum_if_and_only_if_not_polling CHECK (((polling = (issue_quorum_num IS NULL)) AND (polling = (issue_quorum_den IS NULL)))),
    CONSTRAINT timing CHECK ((((polling = false) AND (admission_time IS NOT NULL) AND (discussion_time IS NOT NULL) AND (verification_time IS NOT NULL) AND (voting_time IS NOT NULL)) OR ((polling = true) AND (admission_time IS NULL) AND (discussion_time IS NOT NULL) AND (verification_time IS NOT NULL) AND (voting_time IS NOT NULL)) OR ((polling = true) AND (admission_time IS NULL) AND (discussion_time IS NULL) AND (verification_time IS NULL) AND (voting_time IS NULL))))
);


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE policy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE policy IS 'Policies for a particular proceeding type (timelimits, quorum)';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.index IS 'Determines the order in listings';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.active IS 'TRUE = policy can be used for new issues';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.polling; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.polling IS 'TRUE = special policy for non-user-generated issues without issue quorum, where certain initiatives (those having the "polling" flag set) do not need to pass the initiative quorum; "admission_time" MUST be set to NULL, the other timings may be set to NULL altogether, allowing individual timing for those issues';


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.admission_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.admission_time IS 'Maximum duration of issue state ''admission''; Maximum time an issue stays open without being "accepted"';


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.discussion_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.discussion_time IS 'Duration of issue state ''discussion''; Regular time until an issue is "half_frozen" after being "accepted"';


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.verification_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.verification_time IS 'Duration of issue state ''verification''; Regular time until an issue is "fully_frozen" (e.g. entering issue state ''voting'') after being "half_frozen"';


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.voting_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.voting_time IS 'Duration of issue state ''voting''; Time after an issue is "fully_frozen" but not "closed" (duration of issue state ''voting'')';


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.issue_quorum_num; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.issue_quorum_num IS 'Numerator of potential supporter quorum to be reached by one initiative of an issue to be "accepted" and enter issue state ''discussion''';


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.issue_quorum_den; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.issue_quorum_den IS 'Denominator of potential supporter quorum to be reached by one initiative of an issue to be "accepted" and enter issue state ''discussion''';


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.initiative_quorum_num; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.initiative_quorum_num IS 'Numerator of satisfied supporter quorum  to be reached by an initiative to be "admitted" for voting';


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.initiative_quorum_den; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.initiative_quorum_den IS 'Denominator of satisfied supporter quorum to be reached by an initiative to be "admitted" for voting';


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.direct_majority_num; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.direct_majority_num IS 'Numerator of fraction of neccessary direct majority for initiatives to be attainable as winner';


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.direct_majority_den; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.direct_majority_den IS 'Denominator of fraction of neccessary direct majority for initaitives to be attainable as winner';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.direct_majority_strict; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.direct_majority_strict IS 'If TRUE, then the direct majority must be strictly greater than "direct_majority_num"/"direct_majority_den", otherwise it may also be equal.';


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.direct_majority_positive; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.direct_majority_positive IS 'Absolute number of "positive_votes" neccessary for an initiative to be attainable as winner';


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.direct_majority_non_negative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.direct_majority_non_negative IS 'Absolute number of sum of "positive_votes" and abstentions neccessary for an initiative to be attainable as winner';


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.indirect_majority_num; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.indirect_majority_num IS 'Numerator of fraction of neccessary indirect majority (through beat path) for initiatives to be attainable as winner';


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.indirect_majority_den; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.indirect_majority_den IS 'Denominator of fraction of neccessary indirect majority (through beat path) for initiatives to be attainable as winner';


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.indirect_majority_strict; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.indirect_majority_strict IS 'If TRUE, then the indirect majority must be strictly greater than "indirect_majority_num"/"indirect_majority_den", otherwise it may also be equal.';


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.indirect_majority_positive; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.indirect_majority_positive IS 'Absolute number of votes in favor of the winner neccessary in a beat path to the status quo for an initaitive to be attainable as winner';


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.indirect_majority_non_negative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.indirect_majority_non_negative IS 'Absolute number of sum of votes in favor and abstentions in a beat path to the status quo for an initiative to be attainable as winner';


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.no_reverse_beat_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.no_reverse_beat_path IS 'Causes initiatives with "reverse_beat_path" flag to not be "eligible", thus disallowing them to be winner. See comment on column "initiative"."reverse_beat_path". This option ensures both that a winning initiative is never tied in a (weak) condorcet paradox with the status quo and a winning initiative always beats the status quo directly with a simple majority.';


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN policy.no_multistage_majority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN policy.no_multistage_majority IS 'Causes initiatives with "multistage_majority" flag to not be "eligible", thus disallowing them to be winner. See comment on column "initiative"."multistage_majority". This disqualifies initiatives which could cause an instable result. An instable result in this meaning is a result such that repeating the ballot with same preferences but with the winner of the first ballot as status quo would lead to a different winner in the second ballot. If there are no direct majorities required for the winner, or if in direct comparison only simple majorities are required and "no_reverse_beat_path" is true, then results are always stable and this flag does not have any effect on the winner (but still affects the "eligible" flag of an "initiative").';


--
-- TOC entry 261 (class 1259 OID 19170)
-- Name: policy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 261
-- Name: policy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE policy_id_seq OWNED BY policy.id;


--
-- TOC entry 262 (class 1259 OID 19172)
-- Name: remaining_harmonic_initiative_weight_dummies; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW remaining_harmonic_initiative_weight_dummies AS
 SELECT initiative.issue_id,
    initiative.id AS initiative_id,
    initiative.admitted,
    0 AS weight_num,
    1 AS weight_den
   FROM initiative
  WHERE (initiative.harmonic_weight IS NULL);


--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 262
-- Name: VIEW remaining_harmonic_initiative_weight_dummies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW remaining_harmonic_initiative_weight_dummies IS 'Helper view for function "set_harmonic_initiative_weights" providing dummy weights of zero value, which are needed for corner cases where there are no supporters for an initiative at all';


--
-- TOC entry 263 (class 1259 OID 19176)
-- Name: remaining_harmonic_supporter_weight; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW remaining_harmonic_supporter_weight AS
 SELECT direct_interest_snapshot.issue_id,
    direct_interest_snapshot.event,
    direct_interest_snapshot.member_id,
    direct_interest_snapshot.weight AS weight_num,
    count(initiative.id) AS weight_den
   FROM (((issue
     JOIN direct_interest_snapshot ON (((issue.id = direct_interest_snapshot.issue_id) AND (issue.latest_snapshot_event = direct_interest_snapshot.event))))
     JOIN initiative ON (((issue.id = initiative.issue_id) AND (initiative.harmonic_weight IS NULL))))
     JOIN direct_supporter_snapshot ON (((initiative.id = direct_supporter_snapshot.initiative_id) AND (direct_interest_snapshot.event = direct_supporter_snapshot.event) AND (direct_interest_snapshot.member_id = direct_supporter_snapshot.member_id) AND ((direct_supporter_snapshot.satisfied = true) OR (COALESCE(initiative.admitted, false) = false)))))
  GROUP BY direct_interest_snapshot.issue_id, direct_interest_snapshot.event, direct_interest_snapshot.member_id, direct_interest_snapshot.weight;


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 263
-- Name: VIEW remaining_harmonic_supporter_weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW remaining_harmonic_supporter_weight IS 'Helper view for function "set_harmonic_initiative_weights"';


--
-- TOC entry 264 (class 1259 OID 19181)
-- Name: remaining_harmonic_initiative_weight_summands; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW remaining_harmonic_initiative_weight_summands AS
 SELECT initiative.issue_id,
    initiative.id AS initiative_id,
    initiative.admitted,
    sum(remaining_harmonic_supporter_weight.weight_num) AS weight_num,
    remaining_harmonic_supporter_weight.weight_den
   FROM ((remaining_harmonic_supporter_weight
     JOIN initiative ON (((remaining_harmonic_supporter_weight.issue_id = initiative.issue_id) AND (initiative.harmonic_weight IS NULL))))
     JOIN direct_supporter_snapshot ON (((initiative.id = direct_supporter_snapshot.initiative_id) AND (remaining_harmonic_supporter_weight.event = direct_supporter_snapshot.event) AND (remaining_harmonic_supporter_weight.member_id = direct_supporter_snapshot.member_id) AND ((direct_supporter_snapshot.satisfied = true) OR (COALESCE(initiative.admitted, false) = false)))))
  GROUP BY initiative.issue_id, initiative.id, initiative.admitted, remaining_harmonic_supporter_weight.weight_den;


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 264
-- Name: VIEW remaining_harmonic_initiative_weight_summands; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW remaining_harmonic_initiative_weight_summands IS 'Helper view for function "set_harmonic_initiative_weights"';


--
-- TOC entry 265 (class 1259 OID 19186)
-- Name: rendered_draft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rendered_draft (
    draft_id bigint NOT NULL,
    format text NOT NULL,
    content text NOT NULL
);


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE rendered_draft; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE rendered_draft IS 'This table may be used by frontends to cache "rendered" drafts (e.g. HTML output generated from wiki text)';


--
-- TOC entry 266 (class 1259 OID 19192)
-- Name: rendered_member_statement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rendered_member_statement (
    member_id bigint NOT NULL,
    format text NOT NULL,
    content text NOT NULL
);


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE rendered_member_statement; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE rendered_member_statement IS 'This table may be used by frontends to cache "rendered" member statements (e.g. HTML output generated from wiki text)';


--
-- TOC entry 267 (class 1259 OID 19198)
-- Name: rendered_suggestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rendered_suggestion (
    suggestion_id bigint NOT NULL,
    format text NOT NULL,
    content text NOT NULL
);


--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE rendered_suggestion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE rendered_suggestion IS 'This table may be used by frontends to cache "rendered" drafts (e.g. HTML output generated from wiki text)';


--
-- TOC entry 268 (class 1259 OID 19204)
-- Name: rendered_voter_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rendered_voter_comment (
    issue_id integer NOT NULL,
    member_id integer NOT NULL,
    format text NOT NULL,
    content text NOT NULL
);


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE rendered_voter_comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE rendered_voter_comment IS 'This table may be used by frontends to cache "rendered" voter comments (e.g. HTML output generated from wiki text)';


--
-- TOC entry 269 (class 1259 OID 19210)
-- Name: resource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE resource (
    id bigint DEFAULT nextval('attach_id_seq'::regclass) NOT NULL,
    initiative_id bigint NOT NULL,
    type text,
    title text,
    url text NOT NULL
);


--
-- TOC entry 270 (class 1259 OID 19217)
-- Name: resource_issue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE resource_issue (
    id bigint DEFAULT nextval('attach_id_seq'::regclass) NOT NULL,
    issue_id bigint NOT NULL,
    type text,
    title text,
    url text NOT NULL
);


--
-- TOC entry 271 (class 1259 OID 19224)
-- Name: selected_event_seen_by_member; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW selected_event_seen_by_member AS
 SELECT member.id AS seen_by_member_id,
        CASE
            WHEN (event.state = ANY (ARRAY['voting'::issue_state, 'finished_without_winner'::issue_state, 'finished_with_winner'::issue_state])) THEN 'voting'::notify_level
            ELSE
            CASE
                WHEN (event.state = ANY (ARRAY['verification'::issue_state, 'canceled_after_revocation_during_verification'::issue_state, 'canceled_no_initiative_admitted'::issue_state])) THEN 'verification'::notify_level
                ELSE
                CASE
                    WHEN (event.state = ANY (ARRAY['discussion'::issue_state, 'canceled_after_revocation_during_discussion'::issue_state])) THEN 'discussion'::notify_level
                    ELSE 'all'::notify_level
                END
            END
        END AS notify_level,
    event.id,
    event.occurrence,
    event.event,
    event.member_id,
    event.issue_id,
    event.state,
    event.initiative_id,
    event.draft_id,
    event.suggestion_id
   FROM (((((((member
     CROSS JOIN event)
     LEFT JOIN issue ON ((event.issue_id = issue.id)))
     LEFT JOIN membership ON (((member.id = membership.member_id) AND (issue.area_id = membership.area_id))))
     LEFT JOIN interest ON (((member.id = interest.member_id) AND (event.issue_id = interest.issue_id))))
     LEFT JOIN supporter ON (((member.id = supporter.member_id) AND (event.initiative_id = supporter.initiative_id))))
     LEFT JOIN ignored_member ON (((member.id = ignored_member.member_id) AND (event.member_id = ignored_member.other_member_id))))
     LEFT JOIN ignored_initiative ON (((member.id = ignored_initiative.member_id) AND (event.initiative_id = ignored_initiative.initiative_id))))
  WHERE (((member.notify_level >= 'all'::notify_level) OR ((member.notify_level >= 'voting'::notify_level) AND (event.state = ANY (ARRAY['voting'::issue_state, 'finished_without_winner'::issue_state, 'finished_with_winner'::issue_state]))) OR ((member.notify_level >= 'verification'::notify_level) AND (event.state = ANY (ARRAY['verification'::issue_state, 'canceled_after_revocation_during_verification'::issue_state, 'canceled_no_initiative_admitted'::issue_state]))) OR ((member.notify_level >= 'discussion'::notify_level) AND (event.state = ANY (ARRAY['discussion'::issue_state, 'canceled_after_revocation_during_discussion'::issue_state])))) AND ((supporter.member_id IS NOT NULL) OR (interest.member_id IS NOT NULL) OR ((membership.member_id IS NOT NULL) AND (event.event = ANY (ARRAY['issue_state_changed'::event_type, 'initiative_created_in_new_issue'::event_type, 'initiative_created_in_existing_issue'::event_type, 'initiative_revoked'::event_type])))) AND (ignored_member.member_id IS NULL) AND (ignored_initiative.member_id IS NULL));


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 271
-- Name: VIEW selected_event_seen_by_member; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW selected_event_seen_by_member IS 'Events as seen by a member, depending on its memberships, interests, support and members "notify_level"';


--
-- TOC entry 272 (class 1259 OID 19229)
-- Name: setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE setting (
    member_id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE setting IS 'Place to store a frontend specific setting for members as a string';


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN setting.key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN setting.key IS 'Name of the setting, preceded by a frontend specific prefix';


--
-- TOC entry 273 (class 1259 OID 19235)
-- Name: setting_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE setting_map (
    member_id integer NOT NULL,
    key text NOT NULL,
    subkey text NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE setting_map; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE setting_map IS 'Place to store a frontend specific setting for members as a map of key value pairs';


--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN setting_map.key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN setting_map.key IS 'Name of the setting, preceded by a frontend specific prefix';


--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN setting_map.subkey; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN setting_map.subkey IS 'Key of a map entry';


--
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN setting_map.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN setting_map.value IS 'Value of a map entry';


--
-- TOC entry 274 (class 1259 OID 19241)
-- Name: suggestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE suggestion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3521 (class 0 OID 0)
-- Dependencies: 274
-- Name: suggestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE suggestion_id_seq OWNED BY suggestion.id;


--
-- TOC entry 275 (class 1259 OID 19243)
-- Name: suggestion_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE suggestion_setting (
    member_id integer NOT NULL,
    key text NOT NULL,
    suggestion_id bigint NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE suggestion_setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE suggestion_setting IS 'Place for frontend to store suggestion specific settings of members as strings';


--
-- TOC entry 276 (class 1259 OID 19249)
-- Name: system_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE system_setting (
    member_ttl interval,
    gui_preset text
);


--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE system_setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE system_setting IS 'This table contains only one row with different settings in each column.';


--
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN system_setting.member_ttl; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN system_setting.member_ttl IS 'Time after members get their "active" flag set to FALSE, if they do not show any activity.';


--
-- TOC entry 3525 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN system_setting.gui_preset; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN system_setting.gui_preset IS 'Choose from configured gui from the array config.gui_preset';


--
-- TOC entry 277 (class 1259 OID 19255)
-- Name: template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE template (
    id integer NOT NULL,
    name text,
    description text
);


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE template; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE template IS 'Template for areas';


--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN template.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN template.name IS 'Name for the template';


--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 277
-- Name: COLUMN template.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN template.description IS 'Description for the template';


--
-- TOC entry 278 (class 1259 OID 19261)
-- Name: template_area; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE template_area (
    id integer NOT NULL,
    template_id integer,
    name text,
    active boolean DEFAULT true NOT NULL,
    description text
);


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE template_area; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE template_area IS 'Template areas to be used within a template';


--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN template_area.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN template_area.name IS 'Name for template area';


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN template_area.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN template_area.active IS 'TRUE means new issues can be created in this area';


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN template_area.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN template_area.description IS 'Description for template area';


--
-- TOC entry 279 (class 1259 OID 19268)
-- Name: template_area_allowed_policy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE template_area_allowed_policy (
    template_area_id integer NOT NULL,
    policy_id integer NOT NULL,
    default_policy boolean DEFAULT false NOT NULL
);


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE template_area_allowed_policy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE template_area_allowed_policy IS 'Selects which policies can be used in each template area';


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN template_area_allowed_policy.default_policy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN template_area_allowed_policy.default_policy IS 'One policy per template area can be set as default.';


--
-- TOC entry 280 (class 1259 OID 19272)
-- Name: template_area_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE template_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 280
-- Name: template_area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE template_area_id_seq OWNED BY template_area.id;


--
-- TOC entry 281 (class 1259 OID 19274)
-- Name: template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 281
-- Name: template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE template_id_seq OWNED BY template.id;


--
-- TOC entry 282 (class 1259 OID 19276)
-- Name: unit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE unit (
    id integer NOT NULL,
    parent_id integer,
    active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    member_count integer,
    text_search_data tsvector,
    public boolean DEFAULT false NOT NULL
);


--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE unit IS 'Organizational units organized as trees; Delegations are not inherited through these trees.';


--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN unit.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN unit.parent_id IS 'Parent id of tree node; Multiple roots allowed';


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN unit.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN unit.active IS 'TRUE means new issues can be created in areas of this unit';


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN unit.member_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN unit.member_count IS 'Count of members as determined by column "voting_right" in table "privilege"';


--
-- TOC entry 283 (class 1259 OID 19285)
-- Name: unit_delegation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW unit_delegation AS
 SELECT unit.id AS unit_id,
    delegation.id,
    delegation.truster_id,
    delegation.trustee_id,
    delegation.scope
   FROM (((unit
     JOIN delegation ON ((delegation.unit_id = unit.id)))
     JOIN member ON ((delegation.truster_id = member.id)))
     JOIN privilege ON (((delegation.unit_id = privilege.unit_id) AND (delegation.truster_id = privilege.member_id))))
  WHERE (member.active AND privilege.voting_right);


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 283
-- Name: VIEW unit_delegation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW unit_delegation IS 'Unit delegations where trusters are active and have voting right';


--
-- TOC entry 284 (class 1259 OID 19290)
-- Name: unit_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE unit_group (
    id integer NOT NULL,
    name text DEFAULT ''::text NOT NULL
);


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE unit_group; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE unit_group IS 'Group of units (name)';


--
-- TOC entry 285 (class 1259 OID 19297)
-- Name: unit_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unit_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 285
-- Name: unit_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unit_group_id_seq OWNED BY unit_group.id;


--
-- TOC entry 286 (class 1259 OID 19299)
-- Name: unit_group_member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE unit_group_member (
    unit_group_id integer NOT NULL,
    unit_id integer NOT NULL
);


--
-- TOC entry 287 (class 1259 OID 19302)
-- Name: unit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 287
-- Name: unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unit_id_seq OWNED BY unit.id;


--
-- TOC entry 288 (class 1259 OID 19304)
-- Name: unit_member_count; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW unit_member_count AS
 SELECT unit.id AS unit_id,
    count(member.id) AS member_count
   FROM ((unit
     LEFT JOIN privilege ON (((privilege.unit_id = unit.id) AND privilege.voting_right)))
     LEFT JOIN member ON (((member.id = privilege.member_id) AND member.active)))
  GROUP BY unit.id;


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 288
-- Name: VIEW unit_member_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW unit_member_count IS 'View used to update "member_count" column of "unit" table';


--
-- TOC entry 289 (class 1259 OID 19309)
-- Name: unit_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE unit_setting (
    member_id integer NOT NULL,
    key text NOT NULL,
    unit_id integer NOT NULL,
    value text NOT NULL
);


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE unit_setting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE unit_setting IS 'Place for frontend to store unit specific settings of members as strings';


--
-- TOC entry 2543 (class 2604 OID 19315)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY area ALTER COLUMN id SET DEFAULT nextval('area_id_seq'::regclass);


--
-- TOC entry 2544 (class 2604 OID 19316)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation ALTER COLUMN id SET DEFAULT nextval('delegation_id_seq'::regclass);


--
-- TOC entry 2593 (class 2604 OID 19317)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY draft ALTER COLUMN id SET DEFAULT nextval('draft_id_seq'::regclass);


--
-- TOC entry 2595 (class 2604 OID 19318)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event ALTER COLUMN id SET DEFAULT nextval('event_id_seq'::regclass);


--
-- TOC entry 2567 (class 2604 OID 19319)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative ALTER COLUMN id SET DEFAULT nextval('initiative_id_seq'::regclass);


--
-- TOC entry 2579 (class 2604 OID 19320)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue ALTER COLUMN id SET DEFAULT nextval('issue_id_seq'::regclass);


--
-- TOC entry 2625 (class 2604 OID 19321)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY keyword ALTER COLUMN id SET DEFAULT nextval('keyword_id_seq'::regclass);


--
-- TOC entry 2553 (class 2604 OID 19322)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY member ALTER COLUMN id SET DEFAULT nextval('member_id_seq'::regclass);


--
-- TOC entry 2626 (class 2604 OID 19323)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_application ALTER COLUMN id SET DEFAULT nextval('member_application_id_seq'::regclass);


--
-- TOC entry 2633 (class 2604 OID 19324)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_history ALTER COLUMN id SET DEFAULT nextval('member_history_id_seq'::regclass);


--
-- TOC entry 2649 (class 2604 OID 19325)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY policy ALTER COLUMN id SET DEFAULT nextval('policy_id_seq'::regclass);


--
-- TOC entry 2629 (class 2604 OID 19326)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion ALTER COLUMN id SET DEFAULT nextval('suggestion_id_seq'::regclass);


--
-- TOC entry 2654 (class 2604 OID 19327)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY template ALTER COLUMN id SET DEFAULT nextval('template_id_seq'::regclass);


--
-- TOC entry 2656 (class 2604 OID 19328)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY template_area ALTER COLUMN id SET DEFAULT nextval('template_area_id_seq'::regclass);


--
-- TOC entry 2661 (class 2604 OID 19329)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit ALTER COLUMN id SET DEFAULT nextval('unit_id_seq'::regclass);


--
-- TOC entry 2663 (class 2604 OID 19330)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit_group ALTER COLUMN id SET DEFAULT nextval('unit_group_id_seq'::regclass);


--
-- TOC entry 2666 (class 2606 OID 20004)
-- Name: allowed_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY allowed_policy
    ADD CONSTRAINT allowed_policy_pkey PRIMARY KEY (area_id, policy_id);


--
-- TOC entry 2669 (class 2606 OID 20006)
-- Name: area_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- TOC entry 2706 (class 2606 OID 20008)
-- Name: area_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY area_setting
    ADD CONSTRAINT area_setting_pkey PRIMARY KEY (member_id, key, area_id);


--
-- TOC entry 2855 (class 2606 OID 20010)
-- Name: attach_initiative_id_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource
    ADD CONSTRAINT attach_initiative_id_url_key UNIQUE (initiative_id, url);


--
-- TOC entry 2859 (class 2606 OID 20012)
-- Name: attach_issue_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_issue
    ADD CONSTRAINT attach_issue_id_pkey PRIMARY KEY (id);


--
-- TOC entry 2861 (class 2606 OID 20014)
-- Name: attach_issue_id_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_issue
    ADD CONSTRAINT attach_issue_id_url_key UNIQUE (issue_id, url);


--
-- TOC entry 2857 (class 2606 OID 20016)
-- Name: attach_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource
    ADD CONSTRAINT attach_pkey PRIMARY KEY (id);


--
-- TOC entry 2738 (class 2606 OID 20018)
-- Name: checked_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY checked_event
    ADD CONSTRAINT checked_event_pkey PRIMARY KEY (event_id, member_id);


--
-- TOC entry 2741 (class 2606 OID 20020)
-- Name: contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (member_id, other_member_id);


--
-- TOC entry 2743 (class 2606 OID 20022)
-- Name: contingent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contingent
    ADD CONSTRAINT contingent_pkey PRIMARY KEY (polling, time_frame);


--
-- TOC entry 2756 (class 2606 OID 20024)
-- Name: delegating_interest_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_interest_snapshot
    ADD CONSTRAINT delegating_interest_snapshot_pkey PRIMARY KEY (issue_id, event, member_id);


--
-- TOC entry 2759 (class 2606 OID 20026)
-- Name: delegating_population_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_population_snapshot
    ADD CONSTRAINT delegating_population_snapshot_pkey PRIMARY KEY (issue_id, event, member_id);


--
-- TOC entry 2762 (class 2606 OID 20028)
-- Name: delegating_voter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_voter
    ADD CONSTRAINT delegating_voter_pkey PRIMARY KEY (issue_id, member_id);


--
-- TOC entry 2673 (class 2606 OID 20030)
-- Name: delegation_area_id_truster_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_area_id_truster_id_key UNIQUE (area_id, truster_id);


--
-- TOC entry 2675 (class 2606 OID 20032)
-- Name: delegation_issue_id_truster_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_issue_id_truster_id_key UNIQUE (issue_id, truster_id);


--
-- TOC entry 2677 (class 2606 OID 20034)
-- Name: delegation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_pkey PRIMARY KEY (id);


--
-- TOC entry 2681 (class 2606 OID 20036)
-- Name: delegation_unit_id_truster_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_unit_id_truster_id_key UNIQUE (unit_id, truster_id);


--
-- TOC entry 2765 (class 2606 OID 20038)
-- Name: direct_interest_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_interest_snapshot
    ADD CONSTRAINT direct_interest_snapshot_pkey PRIMARY KEY (issue_id, event, member_id);


--
-- TOC entry 2768 (class 2606 OID 20040)
-- Name: direct_population_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_population_snapshot
    ADD CONSTRAINT direct_population_snapshot_pkey PRIMARY KEY (issue_id, event, member_id);


--
-- TOC entry 2771 (class 2606 OID 20042)
-- Name: direct_supporter_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_supporter_snapshot
    ADD CONSTRAINT direct_supporter_snapshot_pkey PRIMARY KEY (initiative_id, event, member_id);


--
-- TOC entry 2732 (class 2606 OID 20044)
-- Name: direct_voter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_voter
    ADD CONSTRAINT direct_voter_pkey PRIMARY KEY (issue_id, member_id);


--
-- TOC entry 2750 (class 2606 OID 20046)
-- Name: draft_initiative_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY draft
    ADD CONSTRAINT draft_initiative_id_id_key UNIQUE (initiative_id, id);


--
-- TOC entry 2752 (class 2606 OID 20048)
-- Name: draft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY draft
    ADD CONSTRAINT draft_pkey PRIMARY KEY (id);


--
-- TOC entry 2774 (class 2606 OID 20050)
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- TOC entry 2777 (class 2606 OID 20052)
-- Name: ignored_initiative_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignored_initiative
    ADD CONSTRAINT ignored_initiative_pkey PRIMARY KEY (initiative_id, member_id);


--
-- TOC entry 2780 (class 2606 OID 20054)
-- Name: ignored_member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignored_member
    ADD CONSTRAINT ignored_member_pkey PRIMARY KEY (member_id, other_member_id);


--
-- TOC entry 2712 (class 2606 OID 20056)
-- Name: initiative_issue_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative
    ADD CONSTRAINT initiative_issue_id_id_key UNIQUE (issue_id, id);


--
-- TOC entry 2714 (class 2606 OID 20058)
-- Name: initiative_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative
    ADD CONSTRAINT initiative_pkey PRIMARY KEY (id);


--
-- TOC entry 2791 (class 2606 OID 20060)
-- Name: initiative_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative_setting
    ADD CONSTRAINT initiative_setting_pkey PRIMARY KEY (member_id, key, initiative_id);


--
-- TOC entry 2794 (class 2606 OID 20062)
-- Name: initiator_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiator
    ADD CONSTRAINT initiator_pkey PRIMARY KEY (initiative_id, member_id);


--
-- TOC entry 2783 (class 2606 OID 20064)
-- Name: interest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interest
    ADD CONSTRAINT interest_pkey PRIMARY KEY (issue_id, member_id);


--
-- TOC entry 2796 (class 2606 OID 20066)
-- Name: issue_keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_keyword
    ADD CONSTRAINT issue_keyword_pkey PRIMARY KEY (issue_id, keyword_id);


--
-- TOC entry 2728 (class 2606 OID 20068)
-- Name: issue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue
    ADD CONSTRAINT issue_pkey PRIMARY KEY (id);


--
-- TOC entry 2798 (class 2606 OID 20070)
-- Name: issue_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_setting
    ADD CONSTRAINT issue_setting_pkey PRIMARY KEY (member_id, key, issue_id);


--
-- TOC entry 2800 (class 2606 OID 20072)
-- Name: istat_comuni_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY istat_comuni
    ADD CONSTRAINT istat_comuni_pkey PRIMARY KEY (codice_comune);


--
-- TOC entry 2802 (class 2606 OID 20074)
-- Name: istat_province_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY istat_province
    ADD CONSTRAINT istat_province_pkey PRIMARY KEY (codice_provincia);


--
-- TOC entry 2804 (class 2606 OID 20076)
-- Name: istat_regioni_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY istat_regioni
    ADD CONSTRAINT istat_regioni_pkey PRIMARY KEY (codice_regione);


--
-- TOC entry 2806 (class 2606 OID 20078)
-- Name: keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keyword
    ADD CONSTRAINT keyword_pkey PRIMARY KEY (id);


--
-- TOC entry 2808 (class 2606 OID 20080)
-- Name: member_application_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_application
    ADD CONSTRAINT member_application_key_key UNIQUE (key);


--
-- TOC entry 2810 (class 2606 OID 20082)
-- Name: member_application_member_id_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_application
    ADD CONSTRAINT member_application_member_id_name_key UNIQUE (member_id, name);


--
-- TOC entry 2812 (class 2606 OID 20084)
-- Name: member_application_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_application
    ADD CONSTRAINT member_application_pkey PRIMARY KEY (id);


--
-- TOC entry 2821 (class 2606 OID 20086)
-- Name: member_data_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_data
    ADD CONSTRAINT member_data_id_key UNIQUE (id);


--
-- TOC entry 2823 (class 2606 OID 20088)
-- Name: member_data_idcard_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_data
    ADD CONSTRAINT member_data_idcard_key UNIQUE (idcard);


--
-- TOC entry 2825 (class 2606 OID 20090)
-- Name: member_data_nin_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_data
    ADD CONSTRAINT member_data_nin_key UNIQUE (nin);


--
-- TOC entry 2827 (class 2606 OID 20092)
-- Name: member_data_token_serial_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_data
    ADD CONSTRAINT member_data_token_serial_key UNIQUE (token_serial);


--
-- TOC entry 2830 (class 2606 OID 20094)
-- Name: member_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_history
    ADD CONSTRAINT member_history_pkey PRIMARY KEY (id);


--
-- TOC entry 2684 (class 2606 OID 20096)
-- Name: member_identification_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_identification_key UNIQUE (identification);


--
-- TOC entry 2832 (class 2606 OID 20098)
-- Name: member_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_image
    ADD CONSTRAINT member_image_pkey PRIMARY KEY (member_id, image_type, scaled);


--
-- TOC entry 2686 (class 2606 OID 20100)
-- Name: member_invite_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_invite_code_key UNIQUE (invite_code);


--
-- TOC entry 2688 (class 2606 OID 20102)
-- Name: member_login_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_login_key UNIQUE (login);


--
-- TOC entry 2834 (class 2606 OID 20104)
-- Name: member_login_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_login
    ADD CONSTRAINT member_login_pkey PRIMARY KEY (member_id, login_time);


--
-- TOC entry 2690 (class 2606 OID 20106)
-- Name: member_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_name_key UNIQUE (name);


--
-- TOC entry 2692 (class 2606 OID 20108)
-- Name: member_nin_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_nin_key UNIQUE (nin);


--
-- TOC entry 2694 (class 2606 OID 20110)
-- Name: member_notify_email_secret_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_notify_email_secret_key UNIQUE (notify_email_secret);


--
-- TOC entry 2696 (class 2606 OID 20112)
-- Name: member_password_reset_secret_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_password_reset_secret_key UNIQUE (password_reset_secret);


--
-- TOC entry 2698 (class 2606 OID 20114)
-- Name: member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- TOC entry 2836 (class 2606 OID 20116)
-- Name: member_relation_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_relation_setting
    ADD CONSTRAINT member_relation_setting_pkey PRIMARY KEY (member_id, key, other_member_id);


--
-- TOC entry 2704 (class 2606 OID 20118)
-- Name: membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY membership
    ADD CONSTRAINT membership_pkey PRIMARY KEY (area_id, member_id);


--
-- TOC entry 2839 (class 2606 OID 20120)
-- Name: non_voter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY non_voter
    ADD CONSTRAINT non_voter_pkey PRIMARY KEY (issue_id, member_id);


--
-- TOC entry 2746 (class 2606 OID 20122)
-- Name: opinion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opinion
    ADD CONSTRAINT opinion_pkey PRIMARY KEY (suggestion_id, member_id);


--
-- TOC entry 2843 (class 2606 OID 20124)
-- Name: policy_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY policy
    ADD CONSTRAINT policy_name_key UNIQUE (name);


--
-- TOC entry 2845 (class 2606 OID 20126)
-- Name: policy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY policy
    ADD CONSTRAINT policy_pkey PRIMARY KEY (id);


--
-- TOC entry 2701 (class 2606 OID 20128)
-- Name: privilege_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY privilege
    ADD CONSTRAINT privilege_pkey PRIMARY KEY (unit_id, member_id);


--
-- TOC entry 2847 (class 2606 OID 20130)
-- Name: rendered_draft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_draft
    ADD CONSTRAINT rendered_draft_pkey PRIMARY KEY (draft_id, format);


--
-- TOC entry 2849 (class 2606 OID 20132)
-- Name: rendered_member_statement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_member_statement
    ADD CONSTRAINT rendered_member_statement_pkey PRIMARY KEY (member_id, format);


--
-- TOC entry 2851 (class 2606 OID 20134)
-- Name: rendered_suggestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_suggestion
    ADD CONSTRAINT rendered_suggestion_pkey PRIMARY KEY (suggestion_id, format);


--
-- TOC entry 2853 (class 2606 OID 20136)
-- Name: rendered_voter_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_voter_comment
    ADD CONSTRAINT rendered_voter_comment_pkey PRIMARY KEY (issue_id, member_id, format);


--
-- TOC entry 2789 (class 2606 OID 20138)
-- Name: session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_pkey PRIMARY KEY (ident);


--
-- TOC entry 2867 (class 2606 OID 20140)
-- Name: setting_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY setting_map
    ADD CONSTRAINT setting_map_pkey PRIMARY KEY (member_id, key, subkey);


--
-- TOC entry 2864 (class 2606 OID 20142)
-- Name: setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (member_id, key);


--
-- TOC entry 2816 (class 2606 OID 20144)
-- Name: suggestion_initiative_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion
    ADD CONSTRAINT suggestion_initiative_id_id_key UNIQUE (initiative_id, id);


--
-- TOC entry 2818 (class 2606 OID 20146)
-- Name: suggestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion
    ADD CONSTRAINT suggestion_pkey PRIMARY KEY (id);


--
-- TOC entry 2869 (class 2606 OID 20148)
-- Name: suggestion_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion_setting
    ADD CONSTRAINT suggestion_setting_pkey PRIMARY KEY (member_id, key, suggestion_id);


--
-- TOC entry 2786 (class 2606 OID 20150)
-- Name: supporter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporter
    ADD CONSTRAINT supporter_pkey PRIMARY KEY (initiative_id, member_id);


--
-- TOC entry 2877 (class 2606 OID 20152)
-- Name: template_area_allowed_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY template_area_allowed_policy
    ADD CONSTRAINT template_area_allowed_policy_pkey PRIMARY KEY (template_area_id, policy_id);


--
-- TOC entry 2874 (class 2606 OID 20154)
-- Name: template_area_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY template_area
    ADD CONSTRAINT template_area_pkey PRIMARY KEY (id);


--
-- TOC entry 2872 (class 2606 OID 20156)
-- Name: template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY template
    ADD CONSTRAINT template_pkey PRIMARY KEY (id);


--
-- TOC entry 2718 (class 2606 OID 20158)
-- Name: unique_rank_per_issue; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative
    ADD CONSTRAINT unique_rank_per_issue UNIQUE (issue_id, rank);


--
-- TOC entry 2890 (class 2606 OID 20160)
-- Name: unit_group_member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit_group_member
    ADD CONSTRAINT unit_group_member_pkey PRIMARY KEY (unit_group_id, unit_id);


--
-- TOC entry 2886 (class 2606 OID 20162)
-- Name: unit_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit_group
    ADD CONSTRAINT unit_group_name_key UNIQUE (name);


--
-- TOC entry 2888 (class 2606 OID 20164)
-- Name: unit_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit_group
    ADD CONSTRAINT unit_group_pkey PRIMARY KEY (id);


--
-- TOC entry 2881 (class 2606 OID 20166)
-- Name: unit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (id);


--
-- TOC entry 2892 (class 2606 OID 20168)
-- Name: unit_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit_setting
    ADD CONSTRAINT unit_setting_pkey PRIMARY KEY (member_id, key, unit_id);


--
-- TOC entry 2736 (class 2606 OID 20170)
-- Name: vote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_pkey PRIMARY KEY (initiative_id, member_id);


--
-- TOC entry 2664 (class 1259 OID 20171)
-- Name: allowed_policy_one_default_per_area_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX allowed_policy_one_default_per_area_idx ON allowed_policy USING btree (area_id) WHERE default_policy;


--
-- TOC entry 2667 (class 1259 OID 20172)
-- Name: area_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX area_active_idx ON area USING btree (active);


--
-- TOC entry 2670 (class 1259 OID 20173)
-- Name: area_text_search_data_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX area_text_search_data_idx ON area USING gin (text_search_data);


--
-- TOC entry 2671 (class 1259 OID 20174)
-- Name: area_unit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX area_unit_id_idx ON area USING btree (unit_id);


--
-- TOC entry 2707 (class 1259 OID 20175)
-- Name: battle_null_losing_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX battle_null_losing_idx ON battle USING btree (issue_id, losing_initiative_id) WHERE (winning_initiative_id IS NULL);


--
-- TOC entry 2708 (class 1259 OID 20176)
-- Name: battle_winning_losing_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX battle_winning_losing_idx ON battle USING btree (issue_id, winning_initiative_id, losing_initiative_id);


--
-- TOC entry 2709 (class 1259 OID 20177)
-- Name: battle_winning_null_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX battle_winning_null_idx ON battle USING btree (issue_id, winning_initiative_id) WHERE (losing_initiative_id IS NULL);


--
-- TOC entry 2739 (class 1259 OID 20178)
-- Name: contact_other_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contact_other_member_id_idx ON contact USING btree (other_member_id);


--
-- TOC entry 2754 (class 1259 OID 20179)
-- Name: delegating_interest_snapshot_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delegating_interest_snapshot_member_id_idx ON delegating_interest_snapshot USING btree (member_id);


--
-- TOC entry 2757 (class 1259 OID 20180)
-- Name: delegating_population_snapshot_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delegating_population_snapshot_member_id_idx ON delegating_population_snapshot USING btree (member_id);


--
-- TOC entry 2760 (class 1259 OID 20181)
-- Name: delegating_voter_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delegating_voter_member_id_idx ON delegating_voter USING btree (member_id);


--
-- TOC entry 2678 (class 1259 OID 20182)
-- Name: delegation_trustee_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delegation_trustee_id_idx ON delegation USING btree (trustee_id);


--
-- TOC entry 2679 (class 1259 OID 20183)
-- Name: delegation_truster_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delegation_truster_id_idx ON delegation USING btree (truster_id);


--
-- TOC entry 2763 (class 1259 OID 20184)
-- Name: direct_interest_snapshot_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX direct_interest_snapshot_member_id_idx ON direct_interest_snapshot USING btree (member_id);


--
-- TOC entry 2766 (class 1259 OID 20185)
-- Name: direct_population_snapshot_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX direct_population_snapshot_member_id_idx ON direct_population_snapshot USING btree (member_id);


--
-- TOC entry 2769 (class 1259 OID 20186)
-- Name: direct_supporter_snapshot_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX direct_supporter_snapshot_member_id_idx ON direct_supporter_snapshot USING btree (member_id);


--
-- TOC entry 2730 (class 1259 OID 20187)
-- Name: direct_voter_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX direct_voter_member_id_idx ON direct_voter USING btree (member_id);


--
-- TOC entry 2733 (class 1259 OID 20188)
-- Name: direct_voter_text_search_data_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX direct_voter_text_search_data_idx ON direct_voter USING gin (text_search_data);


--
-- TOC entry 2747 (class 1259 OID 20189)
-- Name: draft_author_id_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX draft_author_id_created_idx ON draft USING btree (author_id, created);


--
-- TOC entry 2748 (class 1259 OID 20190)
-- Name: draft_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX draft_created_idx ON draft USING btree (created);


--
-- TOC entry 2753 (class 1259 OID 20191)
-- Name: draft_text_search_data_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX draft_text_search_data_idx ON draft USING gin (text_search_data);


--
-- TOC entry 2772 (class 1259 OID 20192)
-- Name: event_occurrence_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_occurrence_idx ON event USING btree (occurrence);


--
-- TOC entry 2775 (class 1259 OID 20193)
-- Name: ignored_initiative_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ignored_initiative_member_id_idx ON ignored_initiative USING btree (member_id);


--
-- TOC entry 2778 (class 1259 OID 20194)
-- Name: ignored_member_other_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ignored_member_other_member_id_idx ON ignored_member USING btree (other_member_id);


--
-- TOC entry 2710 (class 1259 OID 20195)
-- Name: initiative_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX initiative_created_idx ON initiative USING btree (created);


--
-- TOC entry 2715 (class 1259 OID 20196)
-- Name: initiative_revoked_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX initiative_revoked_idx ON initiative USING btree (revoked);


--
-- TOC entry 2716 (class 1259 OID 20197)
-- Name: initiative_text_search_data_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX initiative_text_search_data_idx ON initiative USING gin (text_search_data);


--
-- TOC entry 2792 (class 1259 OID 20198)
-- Name: initiator_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX initiator_member_id_idx ON initiator USING btree (member_id);


--
-- TOC entry 2781 (class 1259 OID 20199)
-- Name: interest_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX interest_member_id_idx ON interest USING btree (member_id);


--
-- TOC entry 2719 (class 1259 OID 20200)
-- Name: issue_accepted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_accepted_idx ON issue USING btree (accepted);


--
-- TOC entry 2720 (class 1259 OID 20201)
-- Name: issue_area_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_area_id_idx ON issue USING btree (area_id);


--
-- TOC entry 2721 (class 1259 OID 20202)
-- Name: issue_closed_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_closed_idx ON issue USING btree (closed);


--
-- TOC entry 2722 (class 1259 OID 20203)
-- Name: issue_closed_idx_canceled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_closed_idx_canceled ON issue USING btree (closed) WHERE (fully_frozen IS NULL);


--
-- TOC entry 2723 (class 1259 OID 20204)
-- Name: issue_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_created_idx ON issue USING btree (created);


--
-- TOC entry 2724 (class 1259 OID 20205)
-- Name: issue_created_idx_open; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_created_idx_open ON issue USING btree (created) WHERE (closed IS NULL);


--
-- TOC entry 2725 (class 1259 OID 20206)
-- Name: issue_fully_frozen_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_fully_frozen_idx ON issue USING btree (fully_frozen);


--
-- TOC entry 2726 (class 1259 OID 20207)
-- Name: issue_half_frozen_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_half_frozen_idx ON issue USING btree (half_frozen);


--
-- TOC entry 2729 (class 1259 OID 20208)
-- Name: issue_policy_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_policy_id_idx ON issue USING btree (policy_id);


--
-- TOC entry 2682 (class 1259 OID 20209)
-- Name: member_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX member_active_idx ON member USING btree (active);


--
-- TOC entry 2828 (class 1259 OID 20210)
-- Name: member_history_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX member_history_member_id_idx ON member_history USING btree (member_id);


--
-- TOC entry 2699 (class 1259 OID 20211)
-- Name: member_text_search_data_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX member_text_search_data_idx ON member USING gin (text_search_data);


--
-- TOC entry 2702 (class 1259 OID 20212)
-- Name: membership_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX membership_member_id_idx ON membership USING btree (member_id);


--
-- TOC entry 2837 (class 1259 OID 20213)
-- Name: non_voter_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX non_voter_member_id_idx ON non_voter USING btree (member_id);


--
-- TOC entry 2840 (class 1259 OID 20214)
-- Name: notification_sent_singleton_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX notification_sent_singleton_idx ON notification_sent USING btree ((1));


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 2840
-- Name: INDEX notification_sent_singleton_idx; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX notification_sent_singleton_idx IS 'This index ensures that "notification_sent" only contains one row maximum.';


--
-- TOC entry 2744 (class 1259 OID 20215)
-- Name: opinion_member_id_initiative_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX opinion_member_id_initiative_id_idx ON opinion USING btree (member_id, initiative_id);


--
-- TOC entry 2841 (class 1259 OID 20216)
-- Name: policy_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX policy_active_idx ON policy USING btree (active);


--
-- TOC entry 2787 (class 1259 OID 20217)
-- Name: session_expiry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_expiry_idx ON session USING btree (expiry);


--
-- TOC entry 2862 (class 1259 OID 20218)
-- Name: setting_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX setting_key_idx ON setting USING btree (key);


--
-- TOC entry 2865 (class 1259 OID 20219)
-- Name: setting_map_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX setting_map_key_idx ON setting_map USING btree (key);


--
-- TOC entry 2813 (class 1259 OID 20220)
-- Name: suggestion_author_id_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX suggestion_author_id_created_idx ON suggestion USING btree (author_id, created);


--
-- TOC entry 2814 (class 1259 OID 20221)
-- Name: suggestion_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX suggestion_created_idx ON suggestion USING btree (created);


--
-- TOC entry 2819 (class 1259 OID 20222)
-- Name: suggestion_text_search_data_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX suggestion_text_search_data_idx ON suggestion USING gin (text_search_data);


--
-- TOC entry 2784 (class 1259 OID 20223)
-- Name: supporter_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supporter_member_id_idx ON supporter USING btree (member_id);


--
-- TOC entry 2870 (class 1259 OID 20224)
-- Name: system_setting_singleton_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX system_setting_singleton_idx ON system_setting USING btree ((1));


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 2870
-- Name: INDEX system_setting_singleton_idx; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX system_setting_singleton_idx IS 'This index ensures that "system_setting" only contains one row maximum.';


--
-- TOC entry 2875 (class 1259 OID 20225)
-- Name: template_area_allowed_policy_one_default_per_area_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX template_area_allowed_policy_one_default_per_area_idx ON template_area_allowed_policy USING btree (template_area_id) WHERE default_policy;


--
-- TOC entry 2878 (class 1259 OID 20226)
-- Name: unit_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unit_active_idx ON unit USING btree (active);


--
-- TOC entry 2884 (class 1259 OID 20227)
-- Name: unit_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unit_group_idx ON unit_group USING btree (id);


--
-- TOC entry 2879 (class 1259 OID 20228)
-- Name: unit_parent_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unit_parent_id_idx ON unit USING btree (parent_id);


--
-- TOC entry 2882 (class 1259 OID 20229)
-- Name: unit_root_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unit_root_idx ON unit USING btree (id) WHERE (parent_id IS NULL);


--
-- TOC entry 2883 (class 1259 OID 20230)
-- Name: unit_text_search_data_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unit_text_search_data_idx ON unit USING gin (text_search_data);


--
-- TOC entry 2734 (class 1259 OID 20231)
-- Name: vote_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vote_member_id_idx ON vote USING btree (member_id);


--
-- TOC entry 3153 (class 2618 OID 20232)
-- Name: delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE delete AS
    ON DELETE TO expired_session DO INSTEAD  DELETE FROM session
  WHERE (session.ident = old.ident);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 3153
-- Name: RULE delete ON expired_session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON RULE delete ON expired_session IS 'Rule allowing DELETE on rows in "expired_session" view, i.e. DELETE FROM "expired_session"';


--
-- TOC entry 3007 (class 2620 OID 20233)
-- Name: autocreate_interest; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER autocreate_interest BEFORE INSERT ON supporter FOR EACH ROW EXECUTE PROCEDURE autocreate_interest_trigger();


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 3007
-- Name: TRIGGER autocreate_interest ON supporter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER autocreate_interest ON supporter IS 'Supporting an initiative implies interest in the issue, thus automatically creates an entry in the "interest" table';


--
-- TOC entry 3000 (class 2620 OID 20234)
-- Name: autocreate_supporter; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER autocreate_supporter BEFORE INSERT ON opinion FOR EACH ROW EXECUTE PROCEDURE autocreate_supporter_trigger();


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 3000
-- Name: TRIGGER autocreate_supporter ON opinion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER autocreate_supporter ON opinion IS 'Opinions can only be added for supported initiatives. This trigger automatrically creates an entry in the "supporter" table, if not existent yet.';


--
-- TOC entry 3001 (class 2620 OID 20235)
-- Name: autofill_initiative_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER autofill_initiative_id BEFORE INSERT ON opinion FOR EACH ROW EXECUTE PROCEDURE autofill_initiative_id_trigger();


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 3001
-- Name: TRIGGER autofill_initiative_id ON opinion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER autofill_initiative_id ON opinion IS 'Set "initiative_id" field automatically, if NULL';


--
-- TOC entry 2998 (class 2620 OID 20236)
-- Name: autofill_issue_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER autofill_issue_id BEFORE INSERT ON vote FOR EACH ROW EXECUTE PROCEDURE autofill_issue_id_trigger();


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 2998
-- Name: TRIGGER autofill_issue_id ON vote; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER autofill_issue_id ON vote IS 'Set "issue_id" field automatically, if NULL';


--
-- TOC entry 3008 (class 2620 OID 20237)
-- Name: autofill_issue_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER autofill_issue_id BEFORE INSERT ON supporter FOR EACH ROW EXECUTE PROCEDURE autofill_issue_id_trigger();


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 3008
-- Name: TRIGGER autofill_issue_id ON supporter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER autofill_issue_id ON supporter IS 'Set "issue_id" field automatically, if NULL';


--
-- TOC entry 2991 (class 2620 OID 20238)
-- Name: copy_timings; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER copy_timings BEFORE INSERT OR UPDATE ON issue FOR EACH ROW EXECUTE PROCEDURE copy_timings_trigger();


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 2991
-- Name: TRIGGER copy_timings ON issue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER copy_timings ON issue IS 'If timing fields are NULL, copy values from policy.';


--
-- TOC entry 3010 (class 2620 OID 20239)
-- Name: default_for_draft_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER default_for_draft_id BEFORE INSERT OR UPDATE ON suggestion FOR EACH ROW EXECUTE PROCEDURE default_for_draft_id_trigger();


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 3010
-- Name: TRIGGER default_for_draft_id ON suggestion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER default_for_draft_id ON suggestion IS 'If "draft_id" is NULL, then use the current draft of the initiative as default';


--
-- TOC entry 3009 (class 2620 OID 20240)
-- Name: default_for_draft_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER default_for_draft_id BEFORE INSERT OR UPDATE ON supporter FOR EACH ROW EXECUTE PROCEDURE default_for_draft_id_trigger();


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 3009
-- Name: TRIGGER default_for_draft_id ON supporter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER default_for_draft_id ON supporter IS 'If "draft_id" is NULL, then use the current draft of the initiative as default';


--
-- TOC entry 2994 (class 2620 OID 20241)
-- Name: direct_voter_deletes_non_voter; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER direct_voter_deletes_non_voter AFTER INSERT OR UPDATE ON direct_voter FOR EACH ROW EXECUTE PROCEDURE direct_voter_deletes_non_voter_trigger();


--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 2994
-- Name: TRIGGER direct_voter_deletes_non_voter ON direct_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER direct_voter_deletes_non_voter ON direct_voter IS 'An entry in the "direct_voter" table deletes an entry in the "non_voter" table (and vice versa due to trigger "non_voter_deletes_direct_voter" on table "non_voter")';


--
-- TOC entry 2995 (class 2620 OID 20242)
-- Name: forbid_changes_on_closed_issue; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER forbid_changes_on_closed_issue AFTER INSERT OR DELETE OR UPDATE ON direct_voter FOR EACH ROW EXECUTE PROCEDURE forbid_changes_on_closed_issue_trigger();


--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 2995
-- Name: TRIGGER forbid_changes_on_closed_issue ON direct_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER forbid_changes_on_closed_issue ON direct_voter IS 'Ensures that frontends can''t tamper with votings of closed issues, in case of programming errors';


--
-- TOC entry 3006 (class 2620 OID 20243)
-- Name: forbid_changes_on_closed_issue; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER forbid_changes_on_closed_issue AFTER INSERT OR DELETE OR UPDATE ON delegating_voter FOR EACH ROW EXECUTE PROCEDURE forbid_changes_on_closed_issue_trigger();


--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 3006
-- Name: TRIGGER forbid_changes_on_closed_issue ON delegating_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER forbid_changes_on_closed_issue ON delegating_voter IS 'Ensures that frontends can''t tamper with votings of closed issues, in case of programming errors';


--
-- TOC entry 2999 (class 2620 OID 20244)
-- Name: forbid_changes_on_closed_issue; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER forbid_changes_on_closed_issue AFTER INSERT OR DELETE OR UPDATE ON vote FOR EACH ROW EXECUTE PROCEDURE forbid_changes_on_closed_issue_trigger();


--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 2999
-- Name: TRIGGER forbid_changes_on_closed_issue ON vote; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER forbid_changes_on_closed_issue ON vote IS 'Ensures that frontends can''t tamper with votings of closed issues, in case of programming errors';


--
-- TOC entry 2987 (class 2620 OID 20246)
-- Name: initiative_requires_first_draft; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER initiative_requires_first_draft AFTER INSERT OR UPDATE ON initiative DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE initiative_requires_first_draft_trigger();


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 2987
-- Name: TRIGGER initiative_requires_first_draft ON initiative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER initiative_requires_first_draft ON initiative IS 'Ensure that new initiatives have at least one draft';


--
-- TOC entry 2992 (class 2620 OID 20248)
-- Name: issue_requires_first_initiative; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER issue_requires_first_initiative AFTER INSERT OR UPDATE ON issue DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE issue_requires_first_initiative_trigger();


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 2992
-- Name: TRIGGER issue_requires_first_initiative ON issue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER issue_requires_first_initiative ON issue IS 'Ensure that new issues have at least one initiative';


--
-- TOC entry 3003 (class 2620 OID 20250)
-- Name: last_draft_deletes_initiative; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER last_draft_deletes_initiative AFTER DELETE OR UPDATE ON draft DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE last_draft_deletes_initiative_trigger();


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 3003
-- Name: TRIGGER last_draft_deletes_initiative ON draft; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER last_draft_deletes_initiative ON draft IS 'Removing the last draft of an initiative deletes the initiative';


--
-- TOC entry 2988 (class 2620 OID 20252)
-- Name: last_initiative_deletes_issue; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER last_initiative_deletes_issue AFTER DELETE OR UPDATE ON initiative DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE last_initiative_deletes_issue_trigger();


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 2988
-- Name: TRIGGER last_initiative_deletes_issue ON initiative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER last_initiative_deletes_issue ON initiative IS 'Removing the last initiative of an issue deletes the issue';


--
-- TOC entry 3002 (class 2620 OID 20254)
-- Name: last_opinion_deletes_suggestion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER last_opinion_deletes_suggestion AFTER DELETE OR UPDATE ON opinion DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE last_opinion_deletes_suggestion_trigger();


--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 3002
-- Name: TRIGGER last_opinion_deletes_suggestion ON opinion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER last_opinion_deletes_suggestion ON opinion IS 'Removing the last opinion of a suggestion deletes the suggestion';


--
-- TOC entry 2984 (class 2620 OID 20255)
-- Name: nin_validation; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER nin_validation BEFORE INSERT OR UPDATE ON member FOR EACH ROW EXECUTE PROCEDURE nin_insert_trigger();


--
-- TOC entry 3014 (class 2620 OID 20256)
-- Name: non_voter_deletes_direct_voter; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER non_voter_deletes_direct_voter AFTER INSERT OR UPDATE ON non_voter FOR EACH ROW EXECUTE PROCEDURE non_voter_deletes_direct_voter_trigger();


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 3014
-- Name: TRIGGER non_voter_deletes_direct_voter ON non_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER non_voter_deletes_direct_voter ON non_voter IS 'An entry in the "non_voter" table deletes an entry in the "direct_voter" table (and vice versa due to trigger "direct_voter_deletes_non_voter" on table "direct_voter")';


--
-- TOC entry 3011 (class 2620 OID 20258)
-- Name: suggestion_requires_first_opinion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER suggestion_requires_first_opinion AFTER INSERT OR UPDATE ON suggestion DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE suggestion_requires_first_opinion_trigger();


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 3011
-- Name: TRIGGER suggestion_requires_first_opinion ON suggestion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER suggestion_requires_first_opinion ON suggestion IS 'Ensure that new suggestions have at least one opinion';


--
-- TOC entry 2985 (class 2620 OID 20259)
-- Name: update_text_search_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_text_search_data BEFORE INSERT OR UPDATE ON member FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_search_data', 'pg_catalog.simple', 'name', 'identification', 'organizational_unit', 'internal_posts', 'realname', 'external_memberships', 'external_posts', 'statement');


--
-- TOC entry 2983 (class 2620 OID 20260)
-- Name: update_text_search_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_text_search_data BEFORE INSERT OR UPDATE ON area FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_search_data', 'pg_catalog.simple', 'name', 'description');


--
-- TOC entry 2989 (class 2620 OID 20261)
-- Name: update_text_search_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_text_search_data BEFORE INSERT OR UPDATE ON initiative FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_search_data', 'pg_catalog.simple', 'name', 'discussion_url');


--
-- TOC entry 3004 (class 2620 OID 20262)
-- Name: update_text_search_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_text_search_data BEFORE INSERT OR UPDATE ON draft FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_search_data', 'pg_catalog.simple', 'content');


--
-- TOC entry 3012 (class 2620 OID 20263)
-- Name: update_text_search_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_text_search_data BEFORE INSERT OR UPDATE ON suggestion FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_search_data', 'pg_catalog.simple', 'name', 'content');


--
-- TOC entry 2996 (class 2620 OID 20264)
-- Name: update_text_search_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_text_search_data BEFORE INSERT OR UPDATE ON direct_voter FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_search_data', 'pg_catalog.simple', 'comment');


--
-- TOC entry 3015 (class 2620 OID 20265)
-- Name: update_text_search_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_text_search_data BEFORE INSERT OR UPDATE ON unit FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('text_search_data', 'pg_catalog.simple', 'name', 'description');


--
-- TOC entry 2997 (class 2620 OID 20266)
-- Name: voter_comment_fields_only_set_when_voter_comment_is_set; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER voter_comment_fields_only_set_when_voter_comment_is_set BEFORE INSERT OR UPDATE ON direct_voter FOR EACH ROW EXECUTE PROCEDURE voter_comment_fields_only_set_when_voter_comment_is_set_trigger();


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 2997
-- Name: TRIGGER voter_comment_fields_only_set_when_voter_comment_is_set ON direct_voter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER voter_comment_fields_only_set_when_voter_comment_is_set ON direct_voter IS 'If "comment" is set to NULL, then other comment related fields are also set to NULL.';


--
-- TOC entry 3005 (class 2620 OID 20267)
-- Name: write_event_initiative_or_draft_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER write_event_initiative_or_draft_created AFTER INSERT ON draft FOR EACH ROW EXECUTE PROCEDURE write_event_initiative_or_draft_created_trigger();


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 3005
-- Name: TRIGGER write_event_initiative_or_draft_created ON draft; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER write_event_initiative_or_draft_created ON draft IS 'Create entry in "event" table on draft creation';


--
-- TOC entry 2990 (class 2620 OID 20268)
-- Name: write_event_initiative_revoked; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER write_event_initiative_revoked AFTER UPDATE ON initiative FOR EACH ROW EXECUTE PROCEDURE write_event_initiative_revoked_trigger();


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 2990
-- Name: TRIGGER write_event_initiative_revoked ON initiative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER write_event_initiative_revoked ON initiative IS 'Create entry in "event" table, when an initiative is revoked';


--
-- TOC entry 2993 (class 2620 OID 20269)
-- Name: write_event_issue_state_changed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER write_event_issue_state_changed AFTER UPDATE ON issue FOR EACH ROW EXECUTE PROCEDURE write_event_issue_state_changed_trigger();


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 2993
-- Name: TRIGGER write_event_issue_state_changed ON issue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER write_event_issue_state_changed ON issue IS 'Create entry in "event" table on "state" change';


--
-- TOC entry 3013 (class 2620 OID 20270)
-- Name: write_event_suggestion_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER write_event_suggestion_created AFTER INSERT ON suggestion FOR EACH ROW EXECUTE PROCEDURE write_event_suggestion_created_trigger();


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 3013
-- Name: TRIGGER write_event_suggestion_created ON suggestion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER write_event_suggestion_created ON suggestion IS 'Create entry in "event" table on suggestion creation';


--
-- TOC entry 2986 (class 2620 OID 20271)
-- Name: write_member_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER write_member_history AFTER UPDATE ON member FOR EACH ROW EXECUTE PROCEDURE write_member_history_trigger();


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 2986
-- Name: TRIGGER write_member_history ON member; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER write_member_history ON member IS 'When changing certain fields of a member, create a history entry in "member_history" table';


--
-- TOC entry 2893 (class 2606 OID 20272)
-- Name: allowed_policy_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY allowed_policy
    ADD CONSTRAINT allowed_policy_area_id_fkey FOREIGN KEY (area_id) REFERENCES area(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2901 (class 2606 OID 20277)
-- Name: area_setting_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY area_setting
    ADD CONSTRAINT area_setting_area_id_fkey FOREIGN KEY (area_id) REFERENCES area(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2902 (class 2606 OID 20282)
-- Name: area_setting_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY area_setting
    ADD CONSTRAINT area_setting_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2972 (class 2606 OID 20287)
-- Name: attach_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource
    ADD CONSTRAINT attach_initiative_id_fkey FOREIGN KEY (initiative_id) REFERENCES initiative(id);


--
-- TOC entry 2973 (class 2606 OID 20292)
-- Name: attach_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_issue
    ADD CONSTRAINT attach_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id);


--
-- TOC entry 2903 (class 2606 OID 20297)
-- Name: battle_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY battle
    ADD CONSTRAINT battle_issue_id_fkey FOREIGN KEY (issue_id, winning_initiative_id) REFERENCES initiative(issue_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2904 (class 2606 OID 20302)
-- Name: battle_issue_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY battle
    ADD CONSTRAINT battle_issue_id_fkey1 FOREIGN KEY (issue_id, losing_initiative_id) REFERENCES initiative(issue_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2913 (class 2606 OID 20307)
-- Name: checked_event_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY checked_event
    ADD CONSTRAINT checked_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2914 (class 2606 OID 20312)
-- Name: checked_event_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY checked_event
    ADD CONSTRAINT checked_event_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2915 (class 2606 OID 20317)
-- Name: contact_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2916 (class 2606 OID 20322)
-- Name: contact_other_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_other_member_id_fkey FOREIGN KEY (other_member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2921 (class 2606 OID 20327)
-- Name: delegating_interest_snapshot_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_interest_snapshot
    ADD CONSTRAINT delegating_interest_snapshot_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2922 (class 2606 OID 20332)
-- Name: delegating_interest_snapshot_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_interest_snapshot
    ADD CONSTRAINT delegating_interest_snapshot_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2923 (class 2606 OID 20337)
-- Name: delegating_population_snapshot_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_population_snapshot
    ADD CONSTRAINT delegating_population_snapshot_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2924 (class 2606 OID 20342)
-- Name: delegating_population_snapshot_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_population_snapshot
    ADD CONSTRAINT delegating_population_snapshot_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2925 (class 2606 OID 20347)
-- Name: delegating_voter_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_voter
    ADD CONSTRAINT delegating_voter_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2926 (class 2606 OID 20352)
-- Name: delegating_voter_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegating_voter
    ADD CONSTRAINT delegating_voter_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2894 (class 2606 OID 20357)
-- Name: delegation_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_area_id_fkey FOREIGN KEY (area_id) REFERENCES area(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2895 (class 2606 OID 20362)
-- Name: delegation_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2896 (class 2606 OID 20367)
-- Name: delegation_trustee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_trustee_id_fkey FOREIGN KEY (trustee_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2897 (class 2606 OID 20372)
-- Name: delegation_truster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation
    ADD CONSTRAINT delegation_truster_id_fkey FOREIGN KEY (truster_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2927 (class 2606 OID 20377)
-- Name: direct_interest_snapshot_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_interest_snapshot
    ADD CONSTRAINT direct_interest_snapshot_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2928 (class 2606 OID 20382)
-- Name: direct_interest_snapshot_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_interest_snapshot
    ADD CONSTRAINT direct_interest_snapshot_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2929 (class 2606 OID 20387)
-- Name: direct_population_snapshot_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_population_snapshot
    ADD CONSTRAINT direct_population_snapshot_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2930 (class 2606 OID 20392)
-- Name: direct_population_snapshot_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_population_snapshot
    ADD CONSTRAINT direct_population_snapshot_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2931 (class 2606 OID 20397)
-- Name: direct_supporter_snapshot_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_supporter_snapshot
    ADD CONSTRAINT direct_supporter_snapshot_initiative_id_fkey FOREIGN KEY (initiative_id, draft_id) REFERENCES draft(initiative_id, id) ON UPDATE CASCADE;


--
-- TOC entry 2932 (class 2606 OID 20402)
-- Name: direct_supporter_snapshot_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_supporter_snapshot
    ADD CONSTRAINT direct_supporter_snapshot_issue_id_fkey FOREIGN KEY (issue_id, initiative_id) REFERENCES initiative(issue_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2933 (class 2606 OID 20407)
-- Name: direct_supporter_snapshot_issue_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_supporter_snapshot
    ADD CONSTRAINT direct_supporter_snapshot_issue_id_fkey1 FOREIGN KEY (issue_id, event, member_id) REFERENCES direct_interest_snapshot(issue_id, event, member_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2934 (class 2606 OID 20412)
-- Name: direct_supporter_snapshot_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_supporter_snapshot
    ADD CONSTRAINT direct_supporter_snapshot_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2909 (class 2606 OID 20417)
-- Name: direct_voter_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_voter
    ADD CONSTRAINT direct_voter_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2910 (class 2606 OID 20422)
-- Name: direct_voter_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direct_voter
    ADD CONSTRAINT direct_voter_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2919 (class 2606 OID 20427)
-- Name: draft_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY draft
    ADD CONSTRAINT draft_author_id_fkey FOREIGN KEY (author_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2920 (class 2606 OID 20432)
-- Name: draft_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY draft
    ADD CONSTRAINT draft_initiative_id_fkey FOREIGN KEY (initiative_id) REFERENCES initiative(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2935 (class 2606 OID 20437)
-- Name: event_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_initiative_id_fkey FOREIGN KEY (initiative_id, draft_id) REFERENCES draft(initiative_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2936 (class 2606 OID 20442)
-- Name: event_initiative_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_initiative_id_fkey1 FOREIGN KEY (initiative_id, suggestion_id) REFERENCES suggestion(initiative_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2937 (class 2606 OID 20447)
-- Name: event_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2938 (class 2606 OID 20452)
-- Name: event_issue_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_issue_id_fkey1 FOREIGN KEY (issue_id, initiative_id) REFERENCES initiative(issue_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2939 (class 2606 OID 20457)
-- Name: event_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2940 (class 2606 OID 20462)
-- Name: ignored_initiative_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignored_initiative
    ADD CONSTRAINT ignored_initiative_initiative_id_fkey FOREIGN KEY (initiative_id) REFERENCES initiative(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2941 (class 2606 OID 20467)
-- Name: ignored_initiative_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignored_initiative
    ADD CONSTRAINT ignored_initiative_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2942 (class 2606 OID 20472)
-- Name: ignored_member_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignored_member
    ADD CONSTRAINT ignored_member_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2943 (class 2606 OID 20477)
-- Name: ignored_member_other_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignored_member
    ADD CONSTRAINT ignored_member_other_member_id_fkey FOREIGN KEY (other_member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2905 (class 2606 OID 20482)
-- Name: initiative_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative
    ADD CONSTRAINT initiative_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2906 (class 2606 OID 20487)
-- Name: initiative_revoked_by_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative
    ADD CONSTRAINT initiative_revoked_by_member_id_fkey FOREIGN KEY (revoked_by_member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2949 (class 2606 OID 20492)
-- Name: initiative_setting_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative_setting
    ADD CONSTRAINT initiative_setting_initiative_id_fkey FOREIGN KEY (initiative_id) REFERENCES initiative(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2950 (class 2606 OID 20497)
-- Name: initiative_setting_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative_setting
    ADD CONSTRAINT initiative_setting_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2907 (class 2606 OID 20502)
-- Name: initiative_suggested_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiative
    ADD CONSTRAINT initiative_suggested_initiative_id_fkey FOREIGN KEY (suggested_initiative_id) REFERENCES initiative(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2951 (class 2606 OID 20507)
-- Name: initiator_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiator
    ADD CONSTRAINT initiator_initiative_id_fkey FOREIGN KEY (initiative_id) REFERENCES initiative(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2952 (class 2606 OID 20512)
-- Name: initiator_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY initiator
    ADD CONSTRAINT initiator_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2944 (class 2606 OID 20517)
-- Name: interest_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interest
    ADD CONSTRAINT interest_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2945 (class 2606 OID 20522)
-- Name: interest_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interest
    ADD CONSTRAINT interest_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2908 (class 2606 OID 20527)
-- Name: issue_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue
    ADD CONSTRAINT issue_area_id_fkey FOREIGN KEY (area_id) REFERENCES area(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2953 (class 2606 OID 20532)
-- Name: issue_keyword_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_keyword
    ADD CONSTRAINT issue_keyword_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2954 (class 2606 OID 20537)
-- Name: issue_keyword_keyword_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_keyword
    ADD CONSTRAINT issue_keyword_keyword_id_fkey FOREIGN KEY (keyword_id) REFERENCES keyword(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2955 (class 2606 OID 20542)
-- Name: issue_setting_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_setting
    ADD CONSTRAINT issue_setting_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2956 (class 2606 OID 20547)
-- Name: issue_setting_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY issue_setting
    ADD CONSTRAINT issue_setting_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2957 (class 2606 OID 20552)
-- Name: member_application_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_application
    ADD CONSTRAINT member_application_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2961 (class 2606 OID 20557)
-- Name: member_history_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_history
    ADD CONSTRAINT member_history_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2962 (class 2606 OID 20562)
-- Name: member_image_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_image
    ADD CONSTRAINT member_image_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2963 (class 2606 OID 20567)
-- Name: member_login_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_login
    ADD CONSTRAINT member_login_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2964 (class 2606 OID 20572)
-- Name: member_relation_setting_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_relation_setting
    ADD CONSTRAINT member_relation_setting_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2965 (class 2606 OID 20577)
-- Name: member_relation_setting_other_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY member_relation_setting
    ADD CONSTRAINT member_relation_setting_other_member_id_fkey FOREIGN KEY (other_member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2899 (class 2606 OID 20582)
-- Name: membership_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY membership
    ADD CONSTRAINT membership_area_id_fkey FOREIGN KEY (area_id) REFERENCES area(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2900 (class 2606 OID 20587)
-- Name: membership_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY membership
    ADD CONSTRAINT membership_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2966 (class 2606 OID 20592)
-- Name: non_voter_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY non_voter
    ADD CONSTRAINT non_voter_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES issue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2967 (class 2606 OID 20597)
-- Name: non_voter_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY non_voter
    ADD CONSTRAINT non_voter_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2917 (class 2606 OID 20602)
-- Name: opinion_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opinion
    ADD CONSTRAINT opinion_initiative_id_fkey FOREIGN KEY (initiative_id, suggestion_id) REFERENCES suggestion(initiative_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2918 (class 2606 OID 20607)
-- Name: opinion_initiative_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opinion
    ADD CONSTRAINT opinion_initiative_id_fkey1 FOREIGN KEY (initiative_id, member_id) REFERENCES supporter(initiative_id, member_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2898 (class 2606 OID 20612)
-- Name: privilege_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY privilege
    ADD CONSTRAINT privilege_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2968 (class 2606 OID 20617)
-- Name: rendered_draft_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_draft
    ADD CONSTRAINT rendered_draft_draft_id_fkey FOREIGN KEY (draft_id) REFERENCES draft(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2969 (class 2606 OID 20622)
-- Name: rendered_member_statement_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_member_statement
    ADD CONSTRAINT rendered_member_statement_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2970 (class 2606 OID 20627)
-- Name: rendered_suggestion_suggestion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_suggestion
    ADD CONSTRAINT rendered_suggestion_suggestion_id_fkey FOREIGN KEY (suggestion_id) REFERENCES suggestion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2971 (class 2606 OID 20632)
-- Name: rendered_voter_comment_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rendered_voter_comment
    ADD CONSTRAINT rendered_voter_comment_issue_id_fkey FOREIGN KEY (issue_id, member_id) REFERENCES direct_voter(issue_id, member_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2948 (class 2606 OID 20637)
-- Name: session_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE SET NULL;


--
-- TOC entry 2975 (class 2606 OID 20642)
-- Name: setting_map_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY setting_map
    ADD CONSTRAINT setting_map_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2974 (class 2606 OID 20647)
-- Name: setting_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2958 (class 2606 OID 20652)
-- Name: suggestion_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion
    ADD CONSTRAINT suggestion_author_id_fkey FOREIGN KEY (author_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2959 (class 2606 OID 20657)
-- Name: suggestion_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion
    ADD CONSTRAINT suggestion_initiative_id_fkey FOREIGN KEY (initiative_id) REFERENCES initiative(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2960 (class 2606 OID 20662)
-- Name: suggestion_initiative_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion
    ADD CONSTRAINT suggestion_initiative_id_fkey1 FOREIGN KEY (initiative_id, draft_id) REFERENCES draft(initiative_id, id) ON UPDATE CASCADE;


--
-- TOC entry 2976 (class 2606 OID 20667)
-- Name: suggestion_setting_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion_setting
    ADD CONSTRAINT suggestion_setting_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2977 (class 2606 OID 20672)
-- Name: suggestion_setting_suggestion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suggestion_setting
    ADD CONSTRAINT suggestion_setting_suggestion_id_fkey FOREIGN KEY (suggestion_id) REFERENCES suggestion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2946 (class 2606 OID 20677)
-- Name: supporter_initiative_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporter
    ADD CONSTRAINT supporter_initiative_id_fkey FOREIGN KEY (initiative_id, draft_id) REFERENCES draft(initiative_id, id) ON UPDATE CASCADE;


--
-- TOC entry 2947 (class 2606 OID 20682)
-- Name: supporter_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supporter
    ADD CONSTRAINT supporter_issue_id_fkey FOREIGN KEY (issue_id, member_id) REFERENCES interest(issue_id, member_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2979 (class 2606 OID 20687)
-- Name: template_area_allowed_policy_template_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY template_area_allowed_policy
    ADD CONSTRAINT template_area_allowed_policy_template_area_id_fkey FOREIGN KEY (template_area_id) REFERENCES template_area(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2978 (class 2606 OID 20692)
-- Name: template_area_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY template_area
    ADD CONSTRAINT template_area_template_id_fkey FOREIGN KEY (template_id) REFERENCES template(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2981 (class 2606 OID 20697)
-- Name: unit_group_member_unit_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit_group_member
    ADD CONSTRAINT unit_group_member_unit_group_id_fkey FOREIGN KEY (unit_group_id) REFERENCES unit_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2980 (class 2606 OID 20702)
-- Name: unit_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit
    ADD CONSTRAINT unit_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2982 (class 2606 OID 20707)
-- Name: unit_setting_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unit_setting
    ADD CONSTRAINT unit_setting_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2911 (class 2606 OID 20712)
-- Name: vote_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_issue_id_fkey FOREIGN KEY (issue_id, initiative_id) REFERENCES initiative(issue_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2912 (class 2606 OID 20717)
-- Name: vote_issue_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_issue_id_fkey1 FOREIGN KEY (issue_id, member_id) REFERENCES direct_voter(issue_id, member_id) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2017-06-18 16:21:59 CEST

--
-- PostgreSQL database dump complete
--

BEGIN;

INSERT INTO "member" (
      "invite_code",
      "invite_code_expiry",
      "lqfb_access",
      "admin"
   ) VALUES (
      'admin',
      NOW() + '1 year',
      TRUE,
      TRUE
   );

INSERT INTO "system_setting" ("member_ttl") VALUES ('31 days');

INSERT INTO "contingent" (polling, "time_frame", "text_entry_limit", "initiative_limit") VALUES
  (TRUE, '60 minutes', 6, 1),
  (TRUE, '1 day', 60, 10),
  (FALSE, '1 week', 120, 20);

INSERT INTO "policy" (
    "index",
    "name",
    "admission_time",
    "discussion_time",
    "verification_time",
    "voting_time",
    "issue_quorum_num", "issue_quorum_den",
    "initiative_quorum_num", "initiative_quorum_den",
    "direct_majority_num", "direct_majority_den", "direct_majority_strict",
    "indirect_majority_num", "indirect_majority_den", "indirect_majority_strict",
    "no_reverse_beat_path", "no_multistage_majority"
  ) VALUES (
    1,
    'amendment of the statutes (solar system)',
    '8 days', '15 days', '8 days', '15 days',
    10, 100,
    10, 100,
    1, 2, TRUE,
    2, 3, FALSE,
    TRUE, FALSE
  ), (
    2,
    'amendment of the statutes (earth moon federation)',
    '8 days', '15 days', '8 days', '15 days',
    10, 100,
    10, 100,
    1, 2, TRUE,
    2, 3, FALSE,
    TRUE, FALSE
  ), (
    3,
    'amendment of the statutes (united mars colonies)',
    '8 days', '15 days', '8 days', '15 days',
    10, 100,
    10, 100,
    1, 2, TRUE,
    2, 3, FALSE,
    TRUE, FALSE
  ), (
    4,
    'proposition',
    '8 days', '15 days', '8 days', '15 days',
    10, 100,
    10, 100,
    1, 2, TRUE,
    1, 2, TRUE,
    TRUE, FALSE
  ), (
    5,
    'non-binding survey',
    '2 days', '3 days', '2 days', '3 days',
    5, 100,
    5, 100,
    1, 2, TRUE,
    1, 2, TRUE,
    TRUE, FALSE
  ), (
    6,
    'non-binding survey (super fast)',
    '1 hour', '30 minutes', '15 minutes', '30 minutes',
    5, 100,
    5, 100,
    1, 2, TRUE,
    1, 2, TRUE,
    TRUE, FALSE
  );

INSERT INTO "unit" ("parent_id", "name") VALUES
  (NULL, 'Solar System'),           -- id 1
  (1   , 'Earth Moon Federation'),  -- id 2
  (2   , 'Earth'),                  -- id 3
  (2   , 'Moon'),                   -- id 4
  (1   , 'Mars');                   -- id 5

INSERT INTO "area" ("unit_id", "name") VALUES
  ( 1, 'Statutes of the United Solar System'),       -- id  1
  ( 2, 'Statutes of the Earth Moon Federation'),     -- id  2
  ( 5, 'Statutes of the United Mars Colonies'),      -- id  3
  ( 1, 'Intra solar space travel'),                  -- id  4
  ( 1, 'Intra solar system trade and taxation'),     -- id  5
  ( 1, 'Comet defense and black holes management'),  -- id  6
  ( 1, 'Alien affairs'),                             -- id  7
  ( 2, 'Foreign affairs'),                           -- id  8
  ( 3, 'Moon affairs'),                              -- id  9
  ( 4, 'Earth affairs'),                             -- id 10
  ( 4, 'Moon tourism'),                              -- id 11
  ( 5, 'Foreign affairs'),                           -- id 12
  ( 2, 'Department of space vehicles'),              -- id 13
  ( 3, 'Environment'),                               -- id 14
  ( 4, 'Energy and oxygen'),                         -- id 15
  ( 5, 'Energy and oxygen'),                         -- id 16
  ( 5, 'Mineral resources');                         -- id 17

INSERT INTO "allowed_policy" ("area_id", "policy_id", "default_policy") VALUES
  ( 1, 1, TRUE),
  ( 1, 5, FALSE),
  ( 1, 6, FALSE),
  ( 2, 2, TRUE),
  ( 2, 5, FALSE),
  ( 2, 6, FALSE),
  ( 3, 3, TRUE),
  ( 3, 5, FALSE),
  ( 3, 6, FALSE),
  ( 4, 4, TRUE),
  ( 4, 5, FALSE),
  ( 4, 6, FALSE),
  ( 5, 4, TRUE),
  ( 5, 5, FALSE),
  ( 5, 6, FALSE),
  ( 6, 4, TRUE),
  ( 6, 5, FALSE),
  ( 6, 6, FALSE),
  ( 7, 4, TRUE),
  ( 7, 5, FALSE),
  ( 7, 6, FALSE),
  ( 8, 4, TRUE),
  ( 8, 5, FALSE),
  ( 8, 6, FALSE),
  ( 9, 4, TRUE),
  ( 9, 5, FALSE),
  ( 9, 6, FALSE),
  (10, 4, TRUE),
  (10, 5, FALSE),
  (10, 6, FALSE),
  (11, 4, TRUE),
  (11, 5, FALSE),
  (11, 6, FALSE),
  (12, 4, TRUE),
  (12, 5, FALSE),
  (12, 6, FALSE),
  (13, 4, TRUE),
  (13, 5, FALSE),
  (13, 6, FALSE),
  (14, 4, TRUE),
  (14, 5, FALSE),
  (14, 6, FALSE),
  (15, 4, TRUE),
  (15, 5, FALSE),
  (15, 6, FALSE),
  (16, 4, TRUE),
  (16, 5, FALSE),
  (16, 6, FALSE),
  (17, 4, TRUE),
  (17, 5, FALSE),
  (17, 6, FALSE);

END;
