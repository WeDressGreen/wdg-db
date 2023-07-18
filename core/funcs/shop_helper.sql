/*
**	wdgdb.f_shop_item_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_shop_item_exist (
	p_id_shop_item		wdgdb.ref_shop_items.id_shop_item%TYPE
) RETURNS BOOLEAN AS $f_shop_item_exist$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_shop_items AS shop_items
			WHERE 1=1
				AND shop_items.flg_active
				AND shop_items.id_shop_item = p_id_shop_item
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_shop_item_exist$
LANGUAGE plpgsql;



/*
**	wdgdb.f_shop_pack_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_shop_pack_exist (
	p_id_shop_pack		wdgdb.ref_shop_packs.id_shop_pack%TYPE
) RETURNS BOOLEAN AS $f_shop_pack_exist$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_shop_packs AS shop_packs
			WHERE 1=1
				AND shop_packs.flg_active
				AND shop_packs.id_shop_pack = p_id_shop_pack
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_shop_pack_exist$
LANGUAGE plpgsql;



/*
**	wdgdb.f_shop_purchase_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_shop_purchase_exist (
	p_id_shop_purchase		wdgdb.ref_shop_purchases.id_shop_purchase%TYPE
) RETURNS BOOLEAN AS $f_shop_purchase_exist$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_shop_purchases AS shop_purchases
			WHERE 1=1
				AND shop_purchases.flg_active
				AND shop_purchases.id_shop_purchase = p_id_shop_purchase
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_shop_purchase_exist$
LANGUAGE plpgsql;



/*
**	wdgdb.f_shop_coupon_exist
*/
CREATE OR REPLACE FUNCTION wdgdb.f_shop_coupon_exist (
	p_id_coupon		wdgdb.ref_coupons.id_coupon%TYPE
) RETURNS BOOLEAN AS $f_shop_coupon_exist$

BEGIN
	RETURN(
		EXISTS(
			SELECT 1
				FROM wdgdb.ref_coupons AS coupons
			WHERE 1=1
				AND coupons.flg_active
				AND coupons.id_shop_coupon = p_id_coupon
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_shop_coupon_exist$
LANGUAGE plpgsql;
