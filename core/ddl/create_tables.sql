/*
** lov_informations
*/
DROP TABLE IF EXISTS wdgdb.lov_informations CASCADE;
CREATE TABLE wdgdb.lov_informations (
	ll_key			TEXT			NOT NULL,
	ll_value		TEXT			NOT NULL
);

ALTER TABLE wdgdb.lov_informations ADD CONSTRAINT pk_informations PRIMARY KEY ( ll_key );



/*
** ref_members
*/
DROP TABLE IF EXISTS wdgdb.ref_members CASCADE;
CREATE TABLE wdgdb.ref_members (
    id_member		TEXT			NOT NULL	DEFAULT gen_random_uuid()	,
	id_group		INTEGER			NOT NULL	DEFAULT RANDOM()			,
	ll_mail			TEXT			NOT NULL								,
	ll_psswd		TEXT			NOT NULL								,
	ll_name			TEXT			NOT NULL								,
	id_rank			INTEGER			NOT NULL	DEFAULT 1					,
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active		BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_members ADD CONSTRAINT pk_members PRIMARY KEY ( id_member );



/*
** ref_ranks
*/
DROP TABLE IF EXISTS wdgdb.ref_ranks CASCADE;
CREATE TABLE wdgdb.ref_ranks (
	id_rank			SERIAL			NOT NULL								,
	ll_rank			TEXT			NOT NULL								,
	id_child		INTEGER													,
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active		BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_ranks ADD CONSTRAINT pk_rank PRIMARY KEY ( id_rank );



/*
** lov_permissions
*/
DROP TABLE IF EXISTS wdgdb.lov_permissions CASCADE;
CREATE TABLE wdgdb.lov_permissions (
	ll_permission	TEXT		NOT NULL								,
	ts_created_at	TIMESTAMP	NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active		BOOLEAN		NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.lov_permissions ADD CONSTRAINT pk_permission PRIMARY KEY ( ll_permission );



/*
** ref_ranks_permissions
*/
DROP TABLE IF EXISTS wdgdb.ref_ranks_permissions CASCADE;
CREATE TABLE wdgdb.ref_ranks_permissions (
	ll_permission	TEXT		NOT NULL								,
	id_rank			INTEGER		NOT NULL								,
	ts_created_at	TIMESTAMP	NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active		BOOLEAN		NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_ranks_permissions ADD CONSTRAINT pk_rank_permission PRIMARY KEY ( ll_permission, id_rank );
ALTER TABLE wdgdb.ref_ranks_permissions ADD CONSTRAINT fk_rank_permission_rank FOREIGN KEY ( ll_permission ) REFERENCES wdgdb.lov_permissions( ll_permission ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE wdgdb.ref_ranks_permissions ADD CONSTRAINT fk_rank_permission_permission FOREIGN KEY ( id_rank ) REFERENCES wdgdb.ref_ranks( id_rank ) ON DELETE CASCADE ON UPDATE CASCADE;



/*
** ref_members_sessions
*/
DROP TABLE IF EXISTS wdgdb.ref_members_sessions CASCADE;
CREATE TABLE wdgdb.ref_members_sessions (
	id_member_session	UUID			NOT NULL	DEFAULT gen_random_uuid()	,
	id_member			TEXT			NOT NULL								,
	ts_start_at			TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_end_at			TIMESTAMP
);

ALTER TABLE wdgdb.ref_members_sessions ADD CONSTRAINT pk_member_session PRIMARY KEY ( id_member_session );
ALTER TABLE wdgdb.ref_members_sessions ADD CONSTRAINT fk_member_session_member FOREIGN KEY ( id_member ) REFERENCES wdgdb.ref_members( id_member ) ON DELETE CASCADE ON UPDATE CASCADE;



/*
** ref_shop_items
*/
DROP TABLE IF EXISTS wdgdb.ref_shop_items CASCADE;
CREATE TABLE wdgdb.ref_shop_items (
	id_shop_item	SERIAL			NOT NULL													,
	ll_shop_item	TEXT			NOT NULL													,
	nb_coins		INTEGER			NOT NULL								CHECK (nb_coins > 0),
	flg_buy_solo	BOOLEAN			NOT NULL	DEFAULT TRUE									,
	nb_limit		INTEGER													CHECK (nb_limit > 0),
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP						,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP						,
	flg_active		BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_shop_items ADD CONSTRAINT pk_shop_item PRIMARY KEY ( id_shop_item );



/*
** ref_shop_packs
*/
DROP TABLE IF EXISTS wdgdb.ref_shop_packs CASCADE;
CREATE TABLE wdgdb.ref_shop_packs (
	id_shop_pack	SERIAL			NOT NULL													,
	ll_shop_pack	TEXT			NOT NULL													,
	nb_coins		INTEGER			NOT NULL								CHECK (nb_coins > 0),
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP						,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP						,
	flg_active		BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_shop_packs ADD CONSTRAINT pk_shop_pack PRIMARY KEY ( id_shop_pack );



/*
** ref_shop_packed_items
*/
DROP TABLE IF EXISTS wdgdb.ref_shop_packed_items CASCADE;
CREATE TABLE wdgdb.ref_shop_packed_items (
	id_shop_pack	INTEGER			NOT NULL								,
	id_shop_item	INTEGER			NOT NULL								,
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE wdgdb.ref_shop_packed_items ADD CONSTRAINT pk_shop_packed_items PRIMARY KEY ( id_shop_pack, id_shop_item );
ALTER TABLE wdgdb.ref_shop_packed_items ADD CONSTRAINT fk_shop_packed_items_pack FOREIGN KEY ( id_shop_pack ) REFERENCES wdgdb.ref_shop_packs( id_shop_pack ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE wdgdb.ref_shop_packed_items ADD CONSTRAINT fk_shop_packed_items_item FOREIGN KEY ( id_shop_item ) REFERENCES wdgdb.ref_shop_items( id_shop_item ) ON DELETE CASCADE ON UPDATE CASCADE;



/*
** ref_coupons
*/
DROP TABLE IF EXISTS wdgdb.ref_coupons CASCADE;
CREATE TABLE wdgdb.ref_coupons (
	id_coupon		SERIAL			NOT NULL																,
	ll_coupon		TEXT			NOT NULL								CHECK (LENGTH(ll_coupon) > 3)	,
	nb_percent		INTEGER			NOT NULL																,
	flg_global		BOOLEAN			NOT NULL	DEFAULT FALSE												,
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP									,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP									,
	flg_active		BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_coupons ADD CONSTRAINT pk_coupon PRIMARY KEY ( id_coupon );
ALTER TABLE wdgdb.ref_coupons ADD CONSTRAINT uf_coupon_label UNIQUE ( ll_coupon );



/*
** ref_coupons_items
*/
DROP TABLE IF EXISTS wdgdb.ref_coupons_items CASCADE;
CREATE TABLE wdgdb.ref_coupons_items (
	id_coupon		INTEGER			NOT NULL								,
	id_shop_item	INTEGER			NOT NULL								,
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active		BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_coupons_items ADD CONSTRAINT pk_coupons_item PRIMARY KEY ( id_coupon, id_shop_item );
ALTER TABLE wdgdb.ref_coupons_items ADD CONSTRAINT fk_coupons_item_coupon FOREIGN KEY ( id_coupon ) REFERENCES wdgdb.ref_coupons( id_coupon ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE wdgdb.ref_coupons_items ADD CONSTRAINT fk_coupons_item_item FOREIGN KEY ( id_shop_item ) REFERENCES wdgdb.ref_shop_items( id_shop_item ) ON DELETE CASCADE ON UPDATE CASCADE;



/*
** ref_shop_purchases
*/
DROP TABLE IF EXISTS wdgdb.ref_shop_purchases CASCADE;
CREATE TABLE wdgdb.ref_shop_purchases (
	id_shop_purchase	UUID			NOT NULL	DEFAULT gen_random_uuid()	,
	id_member			TEXT			NOT NULL								,
	id_coupon			INTEGER													,
	ts_created_at		TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_updated_at		TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active			BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_shop_purchases ADD CONSTRAINT pk_shop_purchase PRIMARY KEY ( id_shop_purchase );
ALTER TABLE wdgdb.ref_shop_purchases ADD CONSTRAINT fk_shop_purchase_member FOREIGN KEY ( id_member ) REFERENCES wdgdb.ref_members( id_member ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE wdgdb.ref_shop_purchases ADD CONSTRAINT fk_shop_purchase_coupon FOREIGN KEY ( id_coupon ) REFERENCES wdgdb.ref_coupons( id_coupon ) ON DELETE CASCADE ON UPDATE CASCADE;



/*
** ref_shop_purchase_items
*/
DROP TABLE IF EXISTS wdgdb.ref_shop_purchase_items CASCADE;
CREATE TABLE wdgdb.ref_shop_purchase_items (
	id_shop_purchase	UUID			NOT NULL								,
	id_shop_item		INTEGER			NOT NULL								,
	ts_created_at		TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_updated_at		TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active			BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_shop_purchase_items ADD CONSTRAINT pk_shop_purchase_item PRIMARY KEY ( id_shop_purchase, id_shop_item );
ALTER TABLE wdgdb.ref_shop_purchase_items ADD CONSTRAINT fk_shop_purchase_items_purchase FOREIGN KEY ( id_shop_purchase ) REFERENCES wdgdb.ref_shop_purchases( id_shop_purchase ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE wdgdb.ref_shop_purchase_items ADD CONSTRAINT fk_shop_purchase_items_item FOREIGN KEY ( id_shop_item ) REFERENCES wdgdb.ref_shop_items( id_shop_item ) ON DELETE CASCADE ON UPDATE CASCADE;



/*
** ref_basket_items
*/
DROP TABLE IF EXISTS wdgdb.ref_basket_items CASCADE;
CREATE TABLE wdgdb.ref_basket_items (
	id_member		TEXT			NOT NULL								,
	id_shop_item	INTEGER			NOT NULL								,
	ts_created_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	ts_updated_at	TIMESTAMP		NOT NULL	DEFAULT CURRENT_TIMESTAMP	,
	flg_active		BOOLEAN			NOT NULL	DEFAULT TRUE
);

ALTER TABLE wdgdb.ref_basket_items ADD CONSTRAINT pk_basket_item PRIMARY KEY ( id_member, id_shop_item );
ALTER TABLE wdgdb.ref_basket_items ADD CONSTRAINT fk_basket_item_member FOREIGN KEY ( id_member ) REFERENCES wdgdb.ref_members( id_member ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE wdgdb.ref_basket_items ADD CONSTRAINT fk_basket_item_item FOREIGN KEY ( id_shop_item ) REFERENCES wdgdb.ref_shop_items( id_shop_item ) ON DELETE CASCADE ON UPDATE CASCADE;
