/*
**	wdgdb.f_get_shop_items
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_items (
) RETURNS JSONB AS $f_get_shop_items$
DECLARE
	v_shop_items	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_shop_item(shop_items.id_shop_item))->'data'->'shopItem'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_shop_items
	FROM wdgdb.ref_shop_items AS shop_items
	WHERE 1=1
		AND shop_items.flg_active;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopItems'	, v_shop_items
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_items$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_packs
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_packs (
) RETURNS JSONB AS $f_get_shop_packs$
DECLARE
	v_shop_packs	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_shop_pack(shop_packs.id_shop_pack))->'data'->'shopPack'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_shop_packs
	FROM wdgdb.ref_shop_packs AS shop_packs
	WHERE 1=1
		AND shop_packs.flg_active;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopPacks'	, v_shop_packs
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_packs$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_purchases
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_purchases (
) RETURNS JSONB AS $f_get_shop_purchases$
DECLARE
	v_shop_purchases	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_shop_purchase(shop_purchases.id_shop_purchase))->'data'->'shopPurchase'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_shop_purchases
	FROM wdgdb.ref_shop_purchases AS shop_purchases
	WHERE 1=1
		AND shop_purchases.flg_active;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopPurchases'	, v_shop_purchases
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_purchases$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_puchases_by_member
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_puchases_by_member (
	p_id_member		wdgdb.ref_members.id_member%TYPE
) RETURNS JSONB AS $f_get_shop_puchases_by_member$
DECLARE
	v_shop_purchases	JSONB;
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
				(SELECT wdgdb.f_get_shop_purchase(shop_purchases.id_shop_purchase))->'data'->'shopPurchase'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_shop_purchases
	FROM wdgdb.ref_shop_purchases AS shop_purchases
	WHERE 1=1
		AND shop_purchases.flg_active
		AND shop_purchases.id_member = p_id_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopPurchases'	, v_shop_purchases
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_puchases_by_member$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_coupons
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_coupons (
) RETURNS JSONB AS $f_get_shop_coupons$
DECLARE
	v_coupons	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_shop_coupon(coupons.id_coupon))->'data'->'coupon'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_coupons
	FROM wdgdb.ref_coupons AS coupons
	WHERE 1=1
		AND coupons.flg_active;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'coupons'	, v_coupons
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_coupons$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_item
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_item (
	p_id_shop_item	wdgdb.ref_shop_items.id_shop_item%TYPE
) RETURNS JSONB AS $f_get_shop_item$
DECLARE
	v_shop_item	JSONB;
BEGIN
	IF ((SELECT wdgdb.f_shop_item_exist(p_id_shop_item)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_ITEM_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'	, p_id_shop_item
				)
			)
		;
	END IF;

	SELECT
		JSONB_BUILD_OBJECT(
			'id', shop_items.id_shop_item,
			'label', shop_items.ll_shop_item,
			'coins', shop_items.nb_coins,
			'buySolo', shop_items.flg_buy_solo,
			'limit', shop_items.nb_limit
		) INTO v_shop_item
	FROM wdgdb.ref_shop_items AS shop_items
	WHERE 1=1
		AND shop_items.flg_active
		AND shop_items.id_shop_item = p_id_shop_item;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopItem'	, v_shop_item
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_item$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_pack
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_pack (
	p_id_shop_pack	wdgdb.ref_shop_packs.id_shop_pack%TYPE
) RETURNS JSONB AS $f_get_shop_pack$
DECLARE
	v_shop_pack	JSONB;
BEGIN
	IF ((SELECT wdgdb.f_shop_pack_exist(p_id_shop_pack)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_PACK_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'	, p_id_shop_pack
				)
			)
		;
	END IF;

	SELECT
		JSONB_BUILD_OBJECT(
			'id', shop_packs.id_shop_pack,
			'label', shop_packs.ll_shop_pack,
			'coins', shop_packs.nb_coins,
			'items', (SELECT wdgdb.f_get_shop_pack_items(shop_packs.id_shop_pack))->'data'->'shopPackItems'
		) INTO v_shop_pack
	FROM wdgdb.ref_shop_packs AS shop_packs
	WHERE 1=1
		AND shop_packs.flg_active
		AND shop_packs.id_shop_pack = p_id_shop_pack;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopPack'	, v_shop_pack
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_pack$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_pack_items
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_pack_items (
	p_id_shop_pack		wdgdb.ref_shop_packs.id_shop_pack%TYPE
) RETURNS JSONB AS $f_get_shop_pack_items$
DECLARE
	v_shop_pack_items	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_shop_item(shop_pack_items.id_shop_item))->'data'->'shopItem'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_shop_pack_items
	FROM wdgdb.ref_shop_packed_items AS shop_pack_items
	WHERE 1=1
		AND shop_pack_items.flg_active
		AND shop_pack_items.id_shop_pack = p_id_shop_pack;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopPackItems'	, v_shop_pack_items
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_pack_items$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_purchase
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_purchase (
	p_id_shop_purchase	wdgdb.ref_shop_purchases.id_shop_purchase%TYPE
) RETURNS JSONB AS $f_get_shop_purchase$
DECLARE
	v_shop_purchase	JSONB;
BEGIN
	IF ((SELECT wdgdb.f_shop_purchase_exist(p_id_shop_purchase)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_PURCHASE_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'	, p_id_shop_purchase
				)
			)
		;
	END IF;

	SELECT
		JSONB_BUILD_OBJECT(
			'id', shop_purchases.id_shop_purchase,
			'member', shop_purchases.id_member,
			'coupon', (SELECT wdgdb.f_get_shop_coupon(shop_purchases.id_coupon))->'data'->'coupon',
			'items', (SELECT wdgdb.f_get_shop_purchase_items(shop_purchases.id_shop_purchase))->'data'->'shopPurchaseItems'
		) INTO v_shop_purchase
	FROM wdgdb.ref_shop_purchases AS shop_purchases
	WHERE 1=1
		AND shop_purchases.flg_active
		AND shop_purchases.id_shop_purchase = p_id_shop_purchase;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopPurchase'	, v_shop_purchase
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_purchase$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_purchase_items
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_purchase_items (
	p_id_shop_purchase		wdgdb.ref_shop_purchases.id_shop_purchase%TYPE
) RETURNS JSONB AS $f_get_shop_purchase_items$
DECLARE
	v_shop_purchase_items	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_shop_item(shop_purchase_items.id_shop_item))->'data'->'shopItem'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_shop_purchase_items
	FROM wdgdb.ref_shop_purchase_items AS shop_purchase_items
	WHERE 1=1
		AND shop_purchase_items.flg_active
		AND shop_purchase_items.id_shop_purchase = p_id_shop_purchase;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'shopPurchaseItems'	, v_shop_purchase_items
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_purchase_items$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_coupon
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_coupon (
	p_id_coupon		wdgdb.ref_coupons.id_coupon%TYPE
) RETURNS JSONB AS $f_get_shop_coupon$
DECLARE
	v_coupon	JSONB;
BEGIN
	IF ((SELECT wdgdb.f_shop_coupon_exist(p_id_coupon)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_COUPON_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'	, p_id_coupon
				)
			)
		;
	END IF;

	SELECT
		JSONB_BUILD_OBJECT(
			'id', coupons.id_coupon,
			'label', coupons.ll_coupon,
			'percent', coupons.nb_percent,
			'global', coupons.flg_global,
			'items', (SELECT wdgdb.f_get_shop_coupon_items(coupons.id_coupon))->'data'->'couponItems'
		) INTO v_coupon
	FROM wdgdb.ref_coupons AS coupons
	WHERE 1=1
		AND coupons.flg_active
		AND coupons.id_coupon = p_id_coupon;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'coupon'	, v_coupon
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_coupon$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_shop_coupon_items
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_shop_coupon_items (
	p_id_coupon		wdgdb.ref_coupons.id_coupon%TYPE
) RETURNS JSONB AS $f_get_shop_coupon_items$
DECLARE
	v_coupon_items	JSONB;
BEGIN
	SELECT
		COALESCE(
			JSONB_AGG(
				(SELECT wdgdb.f_get_shop_item(shop_purchase_items.id_shop_item))->'data'->'shopItem'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_coupon_items
	FROM wdgdb.ref_coupons_items AS coupon_items
	WHERE 1=1
		AND coupon_items.flg_active
		AND coupon_items.id_coupon = p_id_coupon;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'couponItems'	, v_coupon_items
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_shop_coupon_items$
LANGUAGE plpgsql;



/*
**	wdgdb.f_get_basket_items
*/
CREATE OR REPLACE FUNCTION wdgdb.f_get_basket_items (
	p_id_member		wdgdb.ref_members.id_member%TYPE
) RETURNS JSONB AS $f_get_basket_items$
DECLARE
	v_basket_items	JSONB;
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
				(SELECT wdgdb.f_get_shop_item(basket_items.id_shop_item))->'data'->'shopItem'
			),
			JSONB_BUILD_ARRAY()
		) INTO v_basket_items
	FROM wdgdb.ref_basket_items AS basket_items
	WHERE 1=1
		AND basket_items.flg_active
		AND basket_items.id_member = p_id_member;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'data'  , JSONB_BUILD_OBJECT (
				'basketItems'	, v_basket_items
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_get_basket_items$
LANGUAGE plpgsql;



/*
**	wdgdb.f_remove_shop_pack_item
*/
CREATE OR REPLACE FUNCTION wdgdb.f_remove_shop_pack_item (
	p_id_shop_pack		wdgdb.ref_shop_packs.id_shop_pack%TYPE,
	p_id_shop_item		wdgdb.ref_shop_items.id_shop_item%TYPE
) RETURNS JSONB AS $f_remove_shop_pack_item$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
	IF ((SELECT wdgdb.f_shop_pack_exist(p_id_shop_pack)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_PACK_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_shop_pack
				)
			)
		;
	END IF;

	IF ((SELECT wdgdb.f_shop_item_exist(p_id_shop_item)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_ITEM_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_shop_item
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_shop_pack_items AS shop_pack_items
	SET
		flg_active = FALSE,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND shop_pack_items.flg_active
		AND shop_pack_items.id_shop_pack = p_id_shop_pack
		AND shop_pack_items.id_shop_item = p_id_shop_item;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'itemId'       	, p_id_shop_item
				, 'packId'		, p_id_shop_pack
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_remove_shop_pack_item$
LANGUAGE plpgsql;



/*
**	wdgdb.f_remove_shop_coupon_item
*/
CREATE OR REPLACE FUNCTION wdgdb.f_remove_shop_coupon_item (
	p_id_coupon			wdgdb.ref_coupons.id_coupon%TYPE		,
	p_id_shop_item		wdgdb.ref_shop_items.id_shop_item%TYPE
) RETURNS JSONB AS $f_remove_shop_coupon_item$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
	IF ((SELECT wdgdb.f_shop_coupon_exist(p_id_coupon)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_COUPON_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_coupon
				)
			)
		;
	END IF;

	IF ((SELECT wdgdb.f_shop_item_exist(p_id_shop_item)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_ITEM_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_shop_item
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_coupons_items AS coupon_items
	SET
		flg_active = FALSE,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND coupon_items.flg_active
		AND coupon_items.id_coupon = p_id_coupon
		AND coupon_items.id_shop_item = p_id_shop_item;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'itemId'       	, p_id_shop_item
				, 'couponId'	, p_id_coupon
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_remove_shop_coupon_item$
LANGUAGE plpgsql;



/*
**	wdgdb.f_remove_shop_basket_item
*/
CREATE OR REPLACE FUNCTION wdgdb.f_remove_shop_basket_item (
	p_id_member			wdgdb.ref_members.id_member%TYPE		,
	p_id_shop_item		wdgdb.ref_shop_items.id_shop_item%TYPE
) RETURNS JSONB AS $f_remove_shop_basket_item$
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

	IF ((SELECT wdgdb.f_shop_item_exist(p_id_shop_item)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_ITEM_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_shop_item
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_basket_items AS basket_items
	SET
		flg_active = FALSE,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND basket_items.flg_active
		AND basket_items.id_member = p_id_member
		AND basket_items.id_shop_item = p_id_shop_item;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'itemId'       	, p_id_shop_item
				, 'memberId'	, p_id_member
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_remove_shop_basket_item$
LANGUAGE plpgsql;



/*
**	wdgdb.f_delete_shop_item
*/
CREATE OR REPLACE FUNCTION wdgdb.f_delete_shop_item (
	p_id_shop_item		wdgdb.ref_shop_items.id_shop_item%TYPE
) RETURNS JSONB AS $f_delete_shop_item$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
	IF ((SELECT wdgdb.f_shop_item_exist(p_id_shop_item)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_ITEM_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_shop_item
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_shop_items AS shop_items
	SET
		flg_active = FALSE,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND shop_items.flg_active
		AND shop_items.id_shop_item = p_id_shop_item;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'id'       	, p_id_shop_item
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_delete_shop_item$
LANGUAGE plpgsql;



/*
**	wdgdb.f_delete_shop_pack
*/
CREATE OR REPLACE FUNCTION wdgdb.f_delete_shop_pack (
	p_id_shop_pack		wdgdb.ref_shop_packs.id_shop_pack%TYPE
) RETURNS JSONB AS $f_delete_shop_pack$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
	IF ((SELECT wdgdb.f_shop_pack_exist(p_id_shop_pack)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_SHOP_PACK_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_shop_pack
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_shop_packs AS shop_packs
	SET
		flg_active = FALSE,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND shop_packs.flg_active
		AND shop_packs.id_shop_pack = p_id_shop_pack;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'id'       	, p_id_shop_pack
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_delete_shop_pack$
LANGUAGE plpgsql;



/*
**	wdgdb.f_delete_shop_coupon
*/
CREATE OR REPLACE FUNCTION wdgdb.f_delete_shop_coupon (
	p_id_coupon		wdgdb.ref_coupons.id_coupon%TYPE
) RETURNS JSONB AS $f_delete_shop_coupon$
DECLARE
	v_ins	INTEGER	:= 0;
	v_upd	INTEGER	:= 0;
	v_del	INTEGER	:= 0;
BEGIN
	IF ((SELECT wdgdb.f_shop_coupon_exist(p_id_coupon)) <> TRUE) THEN
		RAISE EXCEPTION '{!}%{!}',
			JSONB_BUILD_OBJECT (
				'info'          , 'execko'
				, 'code'		, 404
				, 'error'		, 'ERROR_COUPON_DOES_NOT_EXIST'
				, 'additional'	, JSONB_BUILD_OBJECT (
					'id'		, p_id_coupon
				)
			)
		;
	END IF;

	UPDATE wdgdb.ref_coupons AS coupons
	SET
		flg_active = FALSE,
		ts_updated_at = CURRENT_TIMESTAMP(1)
	WHERE  1=1
		AND coupons.flg_active
		AND coupons.id_coupon = p_id_coupon;
	GET DIAGNOSTICS v_upd = ROW_COUNT;

	RETURN (
		JSONB_BUILD_OBJECT (
			'info'          , 'execok'
			, 'inserted'    , v_ins
			, 'updated'     , v_upd
			, 'deleted'     , v_del
			, 'additional'  , JSONB_BUILD_OBJECT (
				'id'       	, p_id_coupon
			)
		)
	);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN RAISE EXCEPTION 'ERROR_NO_DATA_FOUND';
		WHEN CASE_NOT_FOUND THEN RAISE EXCEPTION 'ERROR_CASE_STATEMENT_NOT_FOUND';
		WHEN OTHERS THEN RAISE;
END;

	$f_delete_shop_coupon$
LANGUAGE plpgsql;
