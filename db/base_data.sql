-- create the association types
INSERT INTO association_types (name) VALUES ('OR');
INSERT INTO association_types (name) VALUES ('AND');

INSERT INTO selectors (name, label, include_events, include_announcements) VALUES ('Example Selector', 'example_selector', 1, 1);

INSERT INTO layouts (user_id) VALUES (NULL);
INSERT INTO layouts_selectors (layout_id, selector_id, rank) SELECT layouts.id, selectors.id, 100 FROM selectors, layouts WHERE layouts.user_id IS NULL;
