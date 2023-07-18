/*
**	members
*/
DROP FUNCTION IF EXISTS wdgdb.f_member_exist(text) CASCADE; -- id_member
DROP FUNCTION IF EXISTS wdgdb.f_member_exist_by_mail(text) CASCADE; -- ll_mail
DROP FUNCTION IF EXISTS wdgdb.f_member_mail_to_id(text) CASCADE; -- ll_mail
DROP FUNCTION IF EXISTS wdgdb.f_member_session_exist(uuid) CASCADE; -- id_member_session
DROP FUNCTION IF EXISTS wdgdb.f_member_session_is_ended(uuid) CASCADE; -- id_member_session

DROP FUNCTION IF EXISTS wdgdb.f_search_member(text) CASCADE; -- ll_search_terms
DROP FUNCTION IF EXISTS wdgdb.f_get_members() CASCADE;
DROP FUNCTION IF EXISTS wdgdb.f_get_member(text, boolean) CASCADE; -- id_member, flg_detailled
DROP FUNCTION IF EXISTS wdgdb.f_get_member_sessions(text) CASCADE; -- id_member
DROP FUNCTION IF EXISTS wdgdb.f_get_member_session(uuid) CASCADE; -- id_member_session

DROP FUNCTION IF EXISTS wdgdb.f_create_member(text, text, text) CASCADE; -- ll_mail, ll_psswd, ll_name

DROP FUNCTION IF EXISTS wdgdb.f_update_member(text, text, text, text, integer) CASCADE; -- id_member, ll_mail, ll_psswd, ll_name, id_rank
DROP FUNCTION IF EXISTS wdgdb.f_update_member_name(text, text) CASCADE; -- id_member, ll_name
DROP FUNCTION IF EXISTS wdgdb.f_update_member_mail(text, text) CASCADE; -- id_member, ll_mail
DROP FUNCTION IF EXISTS wdgdb.f_update_member_psswd(text, text) CASCADE; -- id_member, ll_psswd
DROP FUNCTION IF EXISTS wdgdb.f_update_member_rank(text, integer) CASCADE; -- id_member, id_rank

DROP FUNCTION IF EXISTS wdgdb.f_create_member_session(text) CASCADE; -- id_member
DROP FUNCTION IF EXISTS wdgdb.f_end_member_session(text) CASCADE; -- id_member
DROP FUNCTION IF EXISTS wdgdb.f_end_member_session(uuid) CASCADE; -- id_member_session

DROP FUNCTION IF EXISTS wdgdb.f_delete_member(text) CASCADE; -- id_member


/*
**	Ranks
*/
DROP FUNCTION IF EXISTS wdgdb.f_rank_exist(integer) CASCADE; -- id_rank
DROP FUNCTION IF EXISTS wdgdb.f_permission_exist(text) CASCADE; -- ll_permission

DROP FUNCTION IF EXISTS wdgdb.f_get_ranks() CASCADE;
DROP FUNCTION IF EXISTS wdgdb.f_get_permissions() CASCADE;
DROP FUNCTION IF EXISTS wdgdb.f_get_rank(integer) CASCADE; -- id_rank
DROP FUNCTION IF EXISTS wdgdb.f_get_rank_permissions(integer) CASCADE; -- id_rank
DROP FUNCTION IF EXISTS wdgdb.f_get_rank_full_permissions(integer) CASCADE; -- id_rank
DROP FUNCTION IF EXISTS wdgdb.f_get_rank_full_permissions_to_text(integer) CASCADE; -- id_rank

DROP FUNCTION IF EXISTS wdgdb.f_create_rank(text, integer) CASCADE; -- ll_rank, id_child

DROP FUNCTION IF EXISTS wdgdb.f_update_rank(integer, text, integer) CASCADE; -- id_rank, ll_rank, id_child
DROP FUNCTION IF EXISTS wdgdb.f_update_rank_name(integer, text) CASCADE; -- id_rank, ll_rank
DROP FUNCTION IF EXISTS wdgdb.f_update_rank_child(integer, integer) CASCADE; -- id_rank, id_child

DROP FUNCTION IF EXISTS wdgdb.f_add_rank_permission(integer, text) CASCADE; -- id_rank, ll_permission
DROP FUNCTION IF EXISTS wdgdb.f_remove_rank_permission(integer, text) CASCADE; -- id_rank, ll_permission

DROP FUNCTION IF EXISTS wdgdb.f_delete_rank(integer) CASCADE; -- id_rank


/*
**	Shop
*/
DROP FUNCTION IF EXISTS wdgdb.f_shop_item_exist(integer) CASCADE; -- id_shop_item
DROP FUNCTION IF EXISTS wdgdb.f_shop_pack_exist(integer) CASCADE; -- id_shop_pack
DROP FUNCTION IF EXISTS wdgdb.f_shop_purchase_exist(uuid) CASCADE; -- id_shop_purchase
DROP FUNCTION IF EXISTS wdgdb.f_shop_coupon_exist(integer) CASCADE; -- id_coupon

DROP FUNCTION IF EXISTS wdgdb.f_get_shop_items() CASCADE;
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_packs() CASCADE;
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_puchases() CASCADE;
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_puchases_by_member(uuid) CASCADE; -- id_member
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_coupons() CASCADE;

DROP FUNCTION IF EXISTS wdgdb.f_get_shop_item(integer) CASCADE; -- id_shop_item
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_pack(integer) CASCADE; -- id_shop_pack
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_pack_items(integer) CASCADE; -- id_shop_pack
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_purchase(uuid) CASCADE; -- id_shop_purchase
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_purchase_items(uuid) CASCADE; -- id_shop_purchase
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_coupon(integer) CASCADE; -- id_coupon
DROP FUNCTION IF EXISTS wdgdb.f_get_shop_coupon_items(integer) CASCADE; -- id_coupon

DROP FUNCTION IF EXISTS wdgdb.f_get_basket_items(uuid) CASCADE; -- id_member

-- DROP FUNCTION IF EXISTS wdgdb.f_create_shop_item(text, integer, boolean, integer) CASCADE; -- ll_shop_item, nb_coins, flg_buy_solo, nb_limit
-- DROP FUNCTION IF EXISTS wdgdb.f_create_shop_pack(text, integer) CASCADE; -- ll_shop_pack, nb_coins
-- DROP FUNCTION IF EXISTS wdgdb.f_create_shop_coupon(text, integer, boolean) CASCADE; -- ll_coupon, nb_percent, flg_global

-- DROP FUNCTION IF EXISTS wdgdb.f_update_shop_item(integer, text, integer, boolean, integer) CASCADE; -- id_shop_item, ll_shop_item, nb_coins, flg_buy_solo, nb_limit
-- DROP FUNCTION IF EXISTS wdgdb.f_update_shop_pack(integer, text, integer) CASCADE; -- id_shop_pack, ll_shop_pack, nb_coins
-- DROP FUNCTION IF EXISTS wdgdb.f_update_shop_coupon(integer, text, integer, boolean) CASCADE; -- id_coupon, ll_coupon, nb_percent, flg_global

-- DROP FUNCTION IF EXISTS wdgdb.f_add_shop_pack_item(integer, integer) CASCADE; -- id_shop_pack, id_shop_item
DROP FUNCTION IF EXISTS wdgdb.f_remove_shop_pack_item(integer, integer) CASCADE; -- id_shop_pack, id_shop_item

-- DROP FUNCTION IF EXISTS wdgdb.f_add_shop_coupon_item(integer, integer) CASCADE; -- id_coupon, id_shop_item
DROP FUNCTION IF EXISTS wdgdb.f_remove_shop_coupon_item(integer, integer) CASCADE; -- id_coupon, id_shop_item

-- DROP FUNCTION IF EXISTS wdgdb.f_add_shop_basket_item(uuid, integer) CASCADE; -- id_member, id_shop_item
DROP FUNCTION IF EXISTS wdgdb.f_remove_shop_basket_item(uuid, integer) CASCADE; -- id_member, id_shop_item

DROP FUNCTION IF EXISTS wdgdb.f_delete_shop_item(integer) CASCADE; -- id_shop_item
DROP FUNCTION IF EXISTS wdgdb.f_delete_shop_pack(integer) CASCADE; -- id_shop_pack
DROP FUNCTION IF EXISTS wdgdb.f_delete_shop_coupon(integer) CASCADE; -- id_coupon
