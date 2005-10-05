-- add a few example group classes
INSERT INTO group_classes (name) VALUES ('Departmental Group');
INSERT INTO group_classes (name) VALUES ('Team');

-- define a few example groups
INSERT INTO groups (name, description, group_class_id, approved) VALUES ('PR Department', 'The PR department publishes public announcements.', 1, 1);
INSERT INTO groups (name, description, group_class_id, approved) VALUES ('Workgroup A', 'Working on project A.', 2, 1);
INSERT INTO groups (name, description, group_class_id, approved) VALUES ('Workgroup B', 'Working on project B.', 2, 1);

-- some 
INSERT INTO categories (name) VALUES ('Social');
INSERT INTO categories (name) VALUES ('Educational');

INSERT INTO priorities (name, rank) VALUES ('Headline', 1);
INSERT INTO priorities (name, rank) VALUES ('Normal', 100);

INSERT INTO selectors (name, label, include_events) VALUES ('Departmental', 'departmental', 1);
INSERT INTO group_classes_selectors (selector_id, group_class_id, association_type_id) VALUES (2, 1, 2);


