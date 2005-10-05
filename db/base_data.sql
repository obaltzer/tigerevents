-- create the association types
INSERT INTO association_types (name) VALUES ('OR');
INSERT INTO association_types (name) VALUES ('AND');

-- one selector that displays all events and announcements
INSERT INTO selectors (name, label, include_events, include_announcements) VALUES ('All Events & Announcements', 'all_events_announcements', 1, 1);
-- insert the selector in the default user's layout
INSERT INTO layouts (user_id, selector_id, rank) VALUES (NULL, 1, 1);
