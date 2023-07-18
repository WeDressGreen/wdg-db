/*
** lov_informations
*/
INSERT INTO wdgdb.lov_informations (ll_key, ll_value)
VALUES
('sql_version', 'beta-1.0.0');

/*
** ref_ranks
*/
INSERT INTO wdgdb.ref_ranks (ll_rank, id_child)
VALUES
('Acheteur', null),
('Vendeur', 1),
('Administrateur', 2);

/*
** lov_permissions
*/
INSERT INTO wdgdb.lov_permissions (ll_permission)
VALUES
('wdg.items.list'),
('wdg.items.create'),
('wdg.items.delete'),
('wdg.items.update'),
('wdg.comment.list'),
('wdg.comment.create'),
('wdg.comment.delete'),
('wdg.comment.update'),
('wdg.ranks.create'),
('wdg.ranks.delete'),
('wdg.ranks.update'),
('wdg.members.list'),
('wdg.members.delete'),
('wdg.members.update'),
('wdg.members.sessions.list');
