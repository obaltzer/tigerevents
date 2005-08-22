DROP DATABASE IF EXISTS tigerevents;
CREATE DATABASE IF NOT EXISTS tigerevents;
USE tigerevents;
SOURCE tables.sql;

INSERT INTO association_types (name) VALUES ('OR');
INSERT INTO association_types (name) VALUES ('AND');

INSERT INTO categories (name) VALUES ('Athletics');

INSERT INTO priorities (name, rank) VALUES ('Normal', 100);

-- Add the super user accounts as in #118
INSERT INTO users (login, fullname, superuser) VALUES ('dsuvpi', 'DSU VP Internal', 1);
INSERT INTO users (login, fullname, superuser) VALUES ('dsupres', 'DSU President', 1);
INSERT INTO users (login, fullname, superuser) VALUES ('dsuvpfo', 'DSU VP Finance and Operations', 1);
INSERT INTO users (login, fullname, superuser) VALUES ('jpelley', 'DSU Commissioner', 1);

-- Add the standard group_classes as in #119
INSERT INTO group_classes (name) VALUES ('DSU');
INSERT INTO group_classes (name) VALUES ('Society');
INSERT INTO group_classes (name) VALUES ('Varsity');
INSERT INTO group_classes (name) VALUES ('Metro / Downtown');
INSERT INTO group_classes (name) VALUES ('Faculty');
INSERT INTO group_classes (name) VALUES ('Department');
INSERT INTO group_classes (name) VALUES ('Other');

-- Add the selectors as described in #120
INSERT INTO selectors (name, label, include_events, include_announcements) VALUES ('DSU / Campus', 'dsu_campus_selector', 1, 1);
INSERT INTO group_classes_selectors (selector_id, group_class_id, association_type_id) SELECT selectors.id, group_classes.id, association_types.id FROM selectors, group_classes, association_types WHERE group_classes.name IN ('DSU', 'Faculty', 'Department', 'Other') AND association_types.name = 'OR' AND selectors.name = 'DSU / Campus';

INSERT INTO selectors (name, label, include_events, include_announcements) VALUES ('Societies', 'societies_selector', 1, 1);
INSERT INTO group_classes_selectors (selector_id, group_class_id, association_type_id) SELECT selectors.id, group_classes.id, association_types.id FROM selectors, group_classes, association_types WHERE group_classes.name IN ('Society') AND association_types.name = 'OR' AND selectors.name = 'Societies';

INSERT INTO selectors (name, label, include_events, include_announcements) VALUES ('Athletics', 'athletics_selector', 1, 1);
INSERT INTO group_classes_selectors (selector_id, group_class_id, association_type_id) SELECT selectors.id, group_classes.id, association_types.id FROM selectors, group_classes, association_types WHERE group_classes.name IN ('Varsity') AND association_types.name = 'OR' AND selectors.name = 'Athletics';
INSERT INTO categories_selectors (selector_id, category_id, association_type_id) SELECT selectors.id, categories.id, association_types.id FROM selectors, categories, association_types WHERE categories.name IN ('Athletics') AND association_types.name = 'OR' AND selectors.name = 'Athletics';

INSERT INTO selectors (name, label, include_events, include_announcements) VALUES ('Metro / Downtown', 'metro_selector', 1, 1);
INSERT INTO group_classes_selectors (selector_id, group_class_id, association_type_id) SELECT selectors.id, group_classes.id, association_types.id FROM selectors, group_classes, association_types WHERE group_classes.name IN ('Metro / Downtown') AND association_types.name = 'OR' AND selectors.name = 'Metro / Downtown';

-- adding the selectors to the layout in the order that is specified in #120
INSERT INTO layouts (user_id, selector_id, rank) SELECT NULL, selectors.id, selectors.id FROM selectors;
