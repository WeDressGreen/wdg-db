/*
**	wdgdb.f_get_members
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_members (
) RETURNS JSONB AS $f_get_members$
DECLARE
	v_members	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_member(members.id_member))->'data'->'member'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_members
	FROM wdgdb.ref_members AS members
	WHERE 1=1
		AND members.flg_active;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  		, JSONB_BUILD_OBJECT (
				'members'	, v_members
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_members$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_member
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_member (
	p_id				wdgdb.ref_members.id_member%TYPE,
	p_flg_detailled		BOOLEAN DEFAULT FALSE
) RETURNS JSONB AS $f_get_member$
DECLARE
	v_member	JSONB;
BEGIN

	IF ((SELECT wdgdb.f_member_exist(p_id)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id
				)
			)
		;
	END IF;

	SELECT
		(CASE WHEN p_flg_detailled THEN
			JSONB_BUILD_OBJECT(
				'id', members.id_member,
				'idGroup', members.id_group,
				'name', members.ll_name,
				'psswd', members.ll_psswd,
				'mail', members.ll_mail,
				'rank', (SELECT wdgdb.f_get_rank(members.id_rank)->'data'->'rank'),
				'sessions', (SELECT wdgdb.f_get_member_sessions(members.id_member)->'data'->'sessions')
			)
		ELSE
			JSONB_BUILD_OBJECT(
				'id', members.id_member,
				'name', members.ll_name,
				'mail', members.ll_mail,
				'psswd', members.ll_psswd,
				'rank', (SELECT wdgdb.f_get_rank(members.id_rank)->'data'->'rank')
			)
		END) INTO v_member
	FROM wdgdb.ref_members AS members
	WHERE 1=1
		AND members.flg_active
		AND members.id_member = p_id;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  		, JSONB_BUILD_OBJECT (
				'member'	, v_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_member$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_member_sessions
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_member_sessions (
	p_id_member			wdgdb.ref_members.id_member%TYPE
) RETURNS JSONB AS $f_get_member_sessions$
DECLARE
	v_sessions	JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_member_session(members_sessions.id_member_session))->'data'->'session'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_sessions
	FROM wdgdb.ref_members_sessions AS members_sessions
	WHERE 1=1
		AND members_sessions.id_member = p_id_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  		, JSONB_BUILD_OBJECT (
				'member'	, p_id_member
				,'sessions'	, v_sessions
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_member_sessions$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_member_session
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_member_session (
	p_id_session		wdgdb.ref_members_sessions.id_member_session%TYPE
) RETURNS JSONB AS $f_get_member_session$
DECLARE
	v_session	JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_session_exist(p_id_session)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_SESSION_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_session
				)
			)
		;
	END IF;

	SELECT
		JSONB_BUILD_OBJECT(
			'id', members_sessions.id_member_session,
			'idSteam', members_sessions.id_member,
			'start', members_sessions.ts_start_at,
			'end', members_sessions.ts_end_at
		) INTO v_session
	FROM wdgdb.ref_members_sessions AS members_sessions
	WHERE 1=1
		AND members_sessions.id_member_session = p_id_session;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  		, JSONB_BUILD_OBJECT (
				'session'	, v_session
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_member_session$
LANGUAGE plpgsql;



/*
**	wdgdb.f_create_member
*/
CREATE OR REPLACE FUNCTION wdgdb.f_create_member (
	p_ll_mail		wdgdb.ref_members.ll_mail%TYPE,
	p_ll_psswd		wdgdb.ref_members.ll_psswd%TYPE,
	p_ll_name		wdgdb.ref_members.ll_name%TYPE
) RETURNS JSONB AS $f_create_member$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;

	v_member_id	UUID;
	v_member	JSONB;
BEGIN
	IF (SELECT wdgdb.f_member_exist_by_mail(p_ll_mail)) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 409
				, 'error'		, 'ERROR_MEMBER_ALREADY_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'mail'		, p_ll_mail
				)
			)
		;
	END IF;

	IF (LENGTH(p_ll_name) < 3) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 412
				, 'error'		, 'ERROR_INVALID_NAME'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'mail'		, p_ll_mail
					,'name'		, p_ll_name
				)
			)
		;
	END IF;

	INSERT INTO wdgdb.ref_members (ll_mail, ll_psswd, ll_name)
	VALUES (
		p_ll_mail,
		p_ll_psswd,
		p_ll_name
	);
	GET DIAGNOSTICS v_ins = ROW_COUNT;

	SELECT wdgdb.f_member_mail_to_id(p_ll_mail) INTO v_member_id;
	SELECT wdgdb.f_get_member(v_member_id, TRUE)->'data'->'member' INTO v_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'member'	, v_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_create_member$
LANGUAGE plpgsql;



/*
**	wdgdb.f_update_member_name
*/
CREATE OR REPLACE FUNCTION wdgdb.f_update_member_name (
	p_id_member			wdgdb.ref_members.id_member%TYPE,
	p_ll_name			wdgdb.ref_members.ll_name%TYPE DEFAULT NULL
) RETURNS JSONB AS $f_update_member_name$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_member		JSONB;
	v_query			JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	IF (LENGTH(p_ll_name) < 3) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 412
				, 'error'		, 'ERROR_INVALID_NAME'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
					,'name'		, p_ll_name
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_members AS members
	SET
		ll_name = p_ll_name,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND members.flg_active
		AND members.id_member = p_id_member;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	SELECT wdgdb.f_get_member(p_id_member, TRUE)->'data'->'member' INTO v_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'member'	, v_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_update_member_name$
LANGUAGE plpgsql;



/*
**	wdgdb.f_update_member_mail
*/
CREATE OR REPLACE FUNCTION wdgdb.f_update_member_mail (
	p_id_member		wdgdb.ref_members.id_member%TYPE,
	p_ll_mail		wdgdb.ref_members.ll_mail%TYPE
) RETURNS JSONB AS $f_update_member_mail$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_member		JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_members AS members
	SET
		ll_mail = p_ll_mail,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND members.flg_active
		AND members.id_member = p_id_member;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	SELECT wdgdb.f_get_member(p_id_member, TRUE)->'data'->'member' INTO v_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'member'	, v_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_update_member_mail$
LANGUAGE plpgsql;



/*
**	wdgdb.f_update_member_psswd
*/
CREATE OR REPLACE FUNCTION wdgdb.f_update_member_psswd (
	p_id_member		wdgdb.ref_members.id_member%TYPE,
	p_ll_psswd		wdgdb.ref_members.ll_psswd%TYPE
) RETURNS JSONB AS $f_update_member_psswd$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_member		JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_members AS members
	SET
		ll_psswd = p_ll_psswd,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND members.flg_active
		AND members.id_member = p_id_member;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	SELECT wdgdb.f_get_member(p_id_member, TRUE)->'data'->'member' INTO v_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'member'	, v_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_update_member_psswd$
LANGUAGE plpgsql;



/*
**	wdgdb.f_update_member_rank
*/
CREATE OR REPLACE FUNCTION wdgdb.f_update_member_rank (
	p_id_member		wdgdb.ref_members.id_member%TYPE,
	p_id_rank		wdgdb.ref_members.id_rank%TYPE
) RETURNS JSONB AS $f_update_member_rank$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_member		JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	IF ((SELECT wdgdb.f_rank_exist(p_id_rank)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_RANK_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_rank
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_members AS members
	SET
		id_rank = p_id_rank,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND members.flg_active
		AND members.id_member = p_id_member;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	SELECT wdgdb.f_get_member(p_id_member, TRUE)->'data'->'member' INTO v_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'member'	, v_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_update_member_rank$
LANGUAGE plpgsql;



/*
**	wdgdb.f_create_member_session
*/
CREATE OR REPLACE FUNCTION wdgdb.f_create_member_session (
	p_id_member		wdgdb.ref_members.id_member%TYPE
) RETURNS JSONB AS $f_create_member_session$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
	v_tmp	INTEGER := 0;

	v_id_session		UUID;
	v_id_last_session	UUID := NULL;
	v_session			JSONB;
	v_query				JSONB;
	v_err				JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	SELECT wdgdb.f_end_member_session(p_id_member) INTO v_query;
	v_ins := v_ins + (v_query->'inserted')::integer;
	v_upd := v_upd + (v_query->'updated')::integer;
	v_del := v_del + (v_query->'deleted')::integer;

	INSERT INTO wdgdb.ref_members_sessions (id_member)
	VALUES (
		p_id_member
	) RETURNING id_member_session INTO v_id_session;
	GET DIAGNOSTICS v_tmp = ROW_COUNT;
	v_ins := v_ins + v_tmp;

	SELECT wdgdb.f_get_member_session(v_id_session)->'data'->'session' INTO v_session;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'session'	, v_session
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_create_member_session$
LANGUAGE plpgsql;



/*
**	wdgdb.f_end_member_session
*/
CREATE OR REPLACE FUNCTION wdgdb.f_end_member_session (
	p_id_member		wdgdb.ref_members.id_member%TYPE
) RETURNS JSONB AS $f_end_member_session$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;

	v_id_last_session	UUID := NULL;
	v_session			JSONB := NULL;
	v_query				JSONB;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	SELECT wdgdb.f_member_last_session_id(p_id_member) INTO v_id_last_session;

	IF (v_id_last_session IS NOT NULL AND (SELECT wdgdb.f_member_session_is_ended(v_id_last_session)) <> TRUE) THEN
		SELECT wdgdb.f_end_member_session(v_id_last_session) INTO v_query;
		v_ins := v_ins + (v_query->'inserted')::integer;
		v_upd := v_upd + (v_query->'updated')::integer;
		v_del := v_del + (v_query->'deleted')::integer;

		SELECT wdgdb.f_get_member_session(v_id_last_session)->'data'->'session' INTO v_session;
	END IF;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'session'	, v_session
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_end_member_session$
LANGUAGE plpgsql;



/*
**	wdgdb.f_end_member_session
*/
CREATE OR REPLACE FUNCTION wdgdb.f_end_member_session (
	p_id_member_session		wdgdb.ref_members_sessions.id_member_session%TYPE
) RETURNS JSONB AS $f_end_member_session$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;

	v_id_last_session	UUID := NULL;
	v_session			JSONB := NULL;
BEGIN
	IF ((SELECT wdgdb.f_member_session_exist(p_id_member_session)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_SESSION_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member_session
				)
			)
		;
	END IF;

	IF (SELECT wdgdb.f_member_session_is_ended(p_id_member_session)) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 409
				, 'error'		, 'ERROR_MEMBER_SESSION_ALREADY_ENDED'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member_session
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_members_sessions AS members_sessions
	SET ts_end_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND members_sessions.id_member_session = p_id_member_session;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	SELECT wdgdb.f_get_member_session(p_id_member_session)->'data'->'session' INTO v_session;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'session'	, v_session
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_end_member_session$
LANGUAGE plpgsql;



/*
**	wdgdb.f_delete_member
*/
CREATE OR REPLACE FUNCTION wdgdb.f_delete_member (
	p_id_member	wdgdb.ref_members.id_member%TYPE
) RETURNS JSONB AS $f_delete_member$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
	IF ((SELECT wdgdb.f_member_exist(p_id_member)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_MEMBER_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_member
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_members AS members
	SET
		flg_active = FALSE,
		id_member = id_member || '_' || EXTRACT(epoch FROM CURRENT_TIMESTAMP(1)),
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND members.flg_active
		AND members.id_member = p_id_member;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'id'       	, p_id_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_delete_member$
LANGUAGE plpgsql;
