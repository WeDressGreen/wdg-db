/*
**	wdgdb.f_rank_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_rank_exist (
	p_id_rank		wdgdb.ref_ranks.id_rank%TYPE
) RETURNS BOOLEAN AS $f_rank_exist$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_ranks AS ranks
			WHERE 1=1
				AND ranks.flg_active
				AND ranks.id_rank = p_id_rank
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_rank_exist$
LANGUAGE plpgsql;



/*
**	wdgdb.f_permission_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_permission_exist (
	p_ll_permission		wdgdb.lov_permissions.ll_permission%TYPE
) RETURNS BOOLEAN AS $f_permission_exist$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.lov_permissions AS permissions
			WHERE 1=1
				AND permissions.flg_active
				AND permissions.ll_permission = p_ll_permission
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_permission_exist$
LANGUAGE plpgsql;
