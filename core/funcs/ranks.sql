/*
**	wdgdb.f_get_ranks
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_ranks (
) RETURNS JSONB AS $f_get_ranks$
DECLARE
	v_ranks	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_rank(ranks.id_rank))->'data'->'rank'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_ranks
	FROM wdgdb.ref_ranks AS ranks
	WHERE 1=1
		AND ranks.flg_active;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'ranks'	, v_ranks
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_ranks$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_permissions
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_permissions (
) RETURNS JSONB AS $f_get_permissions$
DECLARE
	v_permissions	TEXT[];
BEGIN
	SELECT ARRAY_AGG(permissions.ll_permission) INTO v_permissions
	FROM wdgdb.lov_permissions as permissions
	WHERE 1=1
		AND permissions.flg_active;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'permissions'	, v_permissions
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_permissions$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_rank
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_rank (
	p_id_rank	wdgdb.ref_ranks.id_rank%TYPE
) RETURNS JSONB AS $f_get_rank$
DECLARE
	v_rank	JSONB;
BEGIN
	IF ((SELECT wdgdb.f_rank_exist(p_id_rank)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_RANK_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'	, p_id_rank
				)
			)
		;
	END IF;

	SELECT
		JSONB_BUILD_OBJECT(
			'id', ranks.id_rank,
			'label', ranks.ll_rank,
			'idChild', ranks.id_child,
			'permissions', (SELECT wdgdb.f_get_rank_permissions(ranks.id_rank))
		) INTO v_rank
	FROM wdgdb.ref_ranks AS ranks
	WHERE 1=1
		AND ranks.flg_active
		AND ranks.id_rank = p_id_rank;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'rank'	, v_rank
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_rank$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_rank_permissions
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_rank_permissions (
	p_id_rank	wdgdb.ref_ranks.id_rank%TYPE
) RETURNS TEXT[] AS $f_get_rank_permissions$
DECLARE
	v_rank_permissions TEXT[];
BEGIN
	IF ((SELECT wdgdb.f_rank_exist(p_id_rank)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_RANK_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'	, p_id_rank
				)
			)
		;
	END IF;

	SELECT ARRAY_AGG(rank_permissions.ll_permission) INTO v_rank_permissions
	FROM wdgdb.ref_ranks_permissions as rank_permissions
	WHERE 1=1
		AND rank_permissions.flg_active
		AND rank_permissions.id_rank = p_id_rank;

	RETURN (COALESCE(v_rank_permissions, ARRAY[]::TEXT[]));

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_rank_permissions$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_rank_full_permissions
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_rank_full_permissions (
	p_id_rank	wdgdb.ref_ranks.id_rank%TYPE
) RETURNS JSONB AS $f_get_rank_full_permissions$
DECLARE
	v_rank_permissions 		JSONB[]	:= NULL;
	v_id					INTEGER;
	v_sub_rank				JSONB;
	v_sub_rank_permissions	TEXT[];
	v_sub_rank_permission	TEXT;
	v_sub_rank_permission_j	JSONB;
BEGIN
	v_id := p_id_rank;

	WHILE v_id IS NOT NULL
	LOOP
		SELECT wdgdb.f_get_rank(v_id)->'data'->'rank' INTO v_sub_rank;
		SELECT wdgdb.f_get_rank_permissions(v_id) INTO v_sub_rank_permissions;

		FOREACH v_sub_rank_permission IN ARRAY v_sub_rank_permissions
		LOOP
			v_sub_rank_permission_j := JSONB_BUILD_OBJECT(
				'permission', v_sub_rank_permission
				, 'flgSub', (SELECT v_id <> p_id_rank)
			);

			v_rank_permissions := ARRAY_APPEND(v_rank_permissions, v_sub_rank_permission_j);
		END LOOP;

		v_id = CASE WHEN v_sub_rank->'idChild' IS NULL THEN NULL ELSE CAST(v_sub_rank->'idChild' #>> '{}' AS INTEGER) END;
	END LOOP;

	RETURN (
		TO_JSONB(
			COALESCE(
				v_rank_permissions,
				ARRAY[]::JSONB[]
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_rank_full_permissions$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_rank_full_permissions_to_text
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_rank_full_permissions_to_text (
	p_id_rank	wdgdb.ref_ranks.id_rank%TYPE
) RETURNS TEXT[] AS $f_get_rank_full_permissions_to_text$
BEGIN
	RETURN (
		SELECT ARRAY_AGG(
			CAST(permissions->'permission' #>> '{}' AS TEXT)
		) FROM JSONB_ARRAY_ELEMENTS(
			(SELECT wdgdb.f_get_rank_full_permissions(p_id_rank))
		) AS permissions
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_rank_full_permissions_to_text$
LANGUAGE plpgsql;



/*
**	wdgdb.f_create_rank
*/
CREATE OR REPLACE FUNCTION wdgdb.f_create_rank (
	p_ll_rank			wdgdb.ref_ranks.ll_rank%TYPE				,
	p_id_child			wdgdb.ref_ranks.id_child%TYPE	DEFAULT NULL
) RETURNS JSONB AS $f_create_rank$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_rank		JSONB;
	v_id_rank 	INTEGER;
BEGIN
	IF (p_id_child IS NOT NULL AND (SELECT wdgdb.f_rank_exist(p_id_child)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_RANK_CHILD_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_child
				)
			)
		;
	END IF;

	IF (LENGTH(p_ll_rank) < 3) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 412
				, 'error'		, 'ERROR_INVALID_RANK_NAME'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_rank
				)
			)
		;
	END IF;

	INSERT INTO wdgdb.ref_ranks (ll_rank, id_child)
	VALUES (
		p_ll_rank,
		p_id_child
	) RETURNING id_rank INTO v_id_rank;
	GET DIAGNOSTICS v_ins = ROW_COUNT;

	SELECT wdgdb.f_get_rank(v_id_rank)->'data'->'rank' INTO v_rank;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'rank'		, v_rank
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_create_rank$
LANGUAGE plpgsql;



/*
**	wdgdb.f_update_rank
*/
CREATE OR REPLACE FUNCTION wdgdb.f_update_rank (
	p_id_rank			wdgdb.ref_ranks.id_rank%TYPE				,
	p_ll_rank			wdgdb.ref_ranks.ll_rank%TYPE	DEFAULT NULL,
	p_id_child			wdgdb.ref_ranks.id_child%TYPE	DEFAULT NULL
) RETURNS JSONB AS $f_update_rank$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_rank		JSONB;
	v_query		JSONB;
BEGIN
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

	IF (p_ll_rank IS NOT NULL AND LENGTH(p_ll_rank) < 3) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 412
				, 'error'		, 'ERROR_INVALID_RANK_NAME'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'name'		, p_ll_rank
				)
			)
		;
	END IF;

	IF (p_id_child IS NOT NULL AND (SELECT wdgdb.f_rank_exist(p_id_child)) <> TRUE) THEN
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

	IF (p_ll_rank IS NOT NULL) THEN
		SELECT wdgdb.f_update_rank_name(p_id_rank, p_ll_rank) INTO v_query;
		v_ins := v_ins + (v_query->'inserted')::integer;
		v_upd := v_upd + (v_query->'updated')::integer;
		v_del := v_del + (v_query->'deleted')::integer;
	END IF;

	IF (p_id_child IS NOT NULL) THEN
		SELECT wdgdb.f_update_rank_child(p_id_rank, p_id_child) INTO v_query;
		v_ins := v_ins + (v_query->'inserted')::integer;
		v_upd := v_upd + (v_query->'updated')::integer;
		v_del := v_del + (v_query->'deleted')::integer;
	END IF;

	SELECT wdgdb.f_get_rank(p_id_rank)->'data'->'rank' INTO v_rank;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'rank'		, v_rank
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_update_rank$
LANGUAGE plpgsql;



/*
**	wdgdb.f_update_rank_name
*/
CREATE OR REPLACE FUNCTION wdgdb.f_update_rank_name (
	p_id_rank			wdgdb.ref_ranks.id_rank%TYPE,
	p_ll_rank			wdgdb.ref_ranks.ll_rank%TYPE
) RETURNS JSONB AS $f_update_rank_name$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_rank		JSONB;
BEGIN
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

	IF (LENGTH(p_ll_rank) < 3) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 412
				, 'error'		, 'ERROR_INVALID_RANK_NAME'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'name'		, p_ll_rank
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_ranks AS ranks
	SET
		ll_rank = p_ll_rank,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND ranks.flg_active
		AND ranks.id_rank = p_id_rank;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	SELECT wdgdb.f_get_rank(p_id_rank)->'data'->'rank' INTO v_rank;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'rank'		, v_rank
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_update_rank_name$
LANGUAGE plpgsql;



/*
**	wdgdb.f_update_rank_child
*/
CREATE OR REPLACE FUNCTION wdgdb.f_update_rank_child (
	p_id_rank			wdgdb.ref_ranks.id_rank%TYPE,
	p_id_child			wdgdb.ref_ranks.id_child%TYPE
) RETURNS JSONB AS $f_update_rank_child$
DECLARE
	v_ins		INTEGER	:= 0;
	v_upd		INTEGER	:= 0;
	v_del		INTEGER	:= 0;

	v_rank		JSONB;
BEGIN
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

	IF (p_id_child IS  NOT NULL AND (SELECT wdgdb.f_rank_exist(p_id_child)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_RANK_CHILD_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_child
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_ranks AS ranks
	SET
		id_child = p_id_child,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND ranks.flg_active
		AND ranks.id_rank = p_id_rank;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	SELECT wdgdb.f_get_rank(p_id_rank)->'data'->'rank' INTO v_rank;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'data'  		, JSONB_BUILD_OBJECT (
				'rank'		, v_rank
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_update_rank_child$
LANGUAGE plpgsql;



/*
**	wdgdb.f_add_rank_permission
*/
CREATE OR REPLACE FUNCTION wdgdb.f_add_rank_permission (
	p_id_rank			wdgdb.ref_ranks.id_rank%TYPE,
	p_ll_permission		wdgdb.lov_permissions.ll_permission%TYPE
) RETURNS JSONB AS $f_add_rank_permission$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
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

	IF ((SELECT wdgdb.f_permission_exist(p_ll_permission)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_PERMISSION_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'permission', p_ll_permission
				)
			)
		;
	END IF;

	IF (SELECT p_ll_permission = ANY(SELECT UNNEST(wdgdb.f_get_rank_permissions(p_id_rank)))) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 409
				, 'error'		, 'ERROR_RANK_ALREADY_HAVE_PERMISSION'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'permission', p_ll_permission
				)
			)
		;
	END IF;

	INSERT INTO wdgdb.ref_ranks_permissions (ll_permission, id_rank)
	VALUES (
		p_ll_permission,
		p_id_rank
	);
	GET DIAGNOSTICS v_ins = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'id'       	, p_id_rank,
				'permission', p_ll_permission
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_add_rank_permission$
LANGUAGE plpgsql;



/*
**	wdgdb.f_remove_rank_permission
*/
CREATE OR REPLACE FUNCTION wdgdb.f_remove_rank_permission (
	p_id_rank			wdgdb.ref_ranks.id_rank%TYPE,
	p_ll_permission		wdgdb.lov_permissions.ll_permission%TYPE
) RETURNS JSONB AS $f_remove_rank_permission$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
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

	IF ((SELECT wdgdb.f_permission_exist(p_ll_permission)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_PERMISSION_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'permission', p_ll_permission
				)
			)
		;
	END IF;

	IF ((SELECT p_ll_permission = ANY(SELECT UNNEST(wdgdb.f_get_rank_permissions(p_id_rank)))) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 412
				, 'error'		, 'ERROR_RANK_DONT_HAVE_PERMISSION'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'permission', p_ll_permission
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_ranks_permissions AS ranks_permissions
	SET
		flg_active = FALSE
	WHERE  1=1
		AND ranks_permissions.flg_active
		AND ranks_permissions.id_rank = p_id_rank
		AND ranks_permissions.ll_permission = p_ll_permission;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'id'       	, p_id_rank,
				'permission', p_ll_permission
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_remove_rank_permission$
LANGUAGE plpgsql;



/*
**	wdgdb.f_delete_rank
*/
CREATE OR REPLACE FUNCTION wdgdb.f_delete_rank (
	p_id_rank	wdgdb.ref_ranks.id_rank%TYPE
) RETURNS JSONB AS $f_delete_rank$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
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

	UPDATE wdgdb.ref_ranks AS ranks
	SET
		flg_active = FALSE,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND ranks.flg_active
		AND ranks.id_rank = p_id_rank;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'id'       	, p_id_rank
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_delete_rank$
LANGUAGE plpgsql;
