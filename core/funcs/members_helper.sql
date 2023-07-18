/*
**	wdgdb.f_member_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_member_exist (
	p_id		wdgdb.ref_members.id_member%TYPE
) RETURNS BOOLEAN AS $f_member_exist$

BEGIN

	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_members AS members
			WHERE 1=1
				AND members.flg_active
				AND members.id_member = p_id
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_member_exist$
LANGUAGE plpgsql;



/*
**	wdgdb.f_member_exist_by_mail
*/
CREATE OR REPLACE FUNCTION wdgdb.f_member_exist_by_mail (
	p_ll_mail		wdgdb.ref_members.ll_mail%TYPE
) RETURNS BOOLEAN AS $f_member_exist_by_mail$

BEGIN

	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_members AS members
			WHERE 1=1
				AND members.flg_active
				AND members.ll_mail = p_ll_mail
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_member_exist_by_mail$
LANGUAGE plpgsql;


/*
**	wdgdb.f_member_session_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_member_session_exist (
	p_id_member_session		wdgdb.ref_members_sessions.id_member_session%TYPE
) RETURNS BOOLEAN AS $f_member_session_exist$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_members_sessions AS members_sessions
			WHERE 1=1
				AND members_sessions.id_member_session = p_id_member_session
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_member_session_exist$
LANGUAGE plpgsql;




/*
**	wdgdb.f_member_last_session_id
*/
CREATE OR REPLACE FUNCTION wdgdb.f_member_last_session_id (
	p_id_member		wdgdb.ref_members_sessions.id_member%TYPE
) RETURNS UUID AS $f_member_last_session_id$

BEGIN
	RETURN(
		SELECT id_member_session
			FROM wdgdb.ref_members_sessions AS members_sessions
		WHERE 1=1
			AND members_sessions.id_member = p_id_member
			AND members_sessions.ts_end_at IS NULL
		ORDER BY members_sessions.ts_start_at DESC
		LIMIT 1
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_member_last_session_id$
LANGUAGE plpgsql;



/*
**	wdgdb.f_member_session_is_ended
*/
CREATE OR REPLACE FUNCTION wdgdb.f_member_session_is_ended (
	p_id_member_session		wdgdb.ref_members_sessions.id_member_session%TYPE
) RETURNS BOOLEAN AS $f_member_session_is_ended$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_members_sessions AS members_sessions
			WHERE 1=1
				AND members_sessions.id_member_session = p_id_member_session
				AND members_sessions.ts_end_at IS NOT NULL
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_member_session_is_ended$
LANGUAGE plpgsql;


/*
**	wdgdb.f_member_mail_to_id
*/
CREATE OR REPLACE FUNCTION wdgdb.f_member_mail_to_id (
	p_ll_mail		wdgdb.ref_members.ll_mail%TYPE
) RETURNS UUID AS $f_member_mail_to_id$

BEGIN

	RETURN(
		SELECT members.id_member
			FROM wdgdb.ref_members AS members
		WHERE 1=1
			AND members.flg_active
			AND members.ll_mail = p_ll_mail
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_member_mail_to_id$
LANGUAGE plpgsql;


/*
**	wdgdb.f_search_member
*/
CREATE OR REPLACE FUNCTION wdgdb.f_search_member (
	p_ll_search		TEXT
) RETURNS JSONB AS $f_search_member$
DECLARE
	v_members	JSONB;
BEGIN
	IF (LENGTH(p_ll_search) < 3) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 412
				, 'error'		, 'ERROR_INVALID_member_SEARCH_TERMS'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'search'		, p_ll_search
				)
			)
		;
	END IF;

	SELECT
		COALESCE(
			JSONB_AGG(
				main.member
			),
			JSONB_BUILD_ARRAY()
		) INTO v_members
	FROM (
		SELECT
			(SELECT wdgdb.f_get_member(members.id_member))->'data'->'member' AS member
		FROM wdgdb.ref_members AS members
		WHERE 1=1
			AND members.flg_active
			AND (
				(members.id_member LIKE '%' || REPLACE(LOWER(p_ll_search), ' ', '') || '%')
				OR
				(REPLACE(LOWER(members.ll_name), ' ', '') LIKE '%' || REPLACE(LOWER(p_ll_search), ' ', '') || '%')
				OR
				(LOWER(members.ll_mail) LIKE '%' || REPLACE(LOWER(p_ll_search), ' ', '') || '%')
			)
		LIMIT 2
	) AS main;

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

	$f_search_member$
LANGUAGE plpgsql;
