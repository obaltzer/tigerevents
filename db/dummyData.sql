INSERT INTO group_classes (name) VALUES ('DSU');
INSERT INTO group_classes (name, parent_id) VALUES ('Level A', 1);
INSERT INTO group_classes (name, parent_id) VALUES ('Level E', 1);

INSERT INTO groups (name, description, group_class_id, approved) VALUES ('CSS', 'Computer Science Society', 2, 1);
INSERT INTO groups (name, description, group_class_id, approved) VALUES ('Dal-ACM', 'Dalhousie Student Chapter of the ACM', 3, 1);
INSERT INTO groups (name, description, group_class_id, approved) VALUES ('DSU', 'Dalhousie Student Union', 1, 1);

INSERT INTO categories (name) VALUES ('Social');
INSERT INTO categories (name) VALUES ('Varsity');
INSERT INTO categories (name) VALUES ('Scholarships');
INSERT INTO categories (name) VALUES ('Beer');

INSERT INTO priorities (name, rank) VALUES ('Headline 1', 1);
INSERT INTO priorities (name, rank) VALUES ('Headline 2', 2);
INSERT INTO priorities (name, rank) VALUES ('Important', 50);
INSERT INTO priorities (name, rank) VALUES ('Normal', 100);

INSERT INTO events (group_id, title, description, startTime, priority_id) VALUES (1, 'GeekBeer', 'All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy.', DATE_ADD(NOW(), INTERVAL 1 DAY), 3);
INSERT INTO events (group_id, title, description, startTime, priority_id) VALUES (1, 'Citizenship Award Celebration', 'Social Hangout', DATE_ADD(NOW(), INTERVAL 1 DAY), 4);
INSERT INTO events (group_id, title, description, startTime, priority_id) VALUES (2, 'Baltzer Award', 'Baltzer Award for outstanding coolness', DATE_ADD(NOW(), INTERVAL 1 DAY), 1);
INSERT INTO events (group_id, title, description, startTime, priority_id) VALUES (2, 'Dal-ACM thumb wrestling championship', 'Coolest sports event ever', DATE_ADD(NOW(), INTERVAL 1 DAY), 2);
INSERT INTO events (group_id, title, description, startTime, priority_id) VALUES (1, 'CSS Soccer', 'CSS Soccer', DATE_ADD(NOW(), INTERVAL 1 DAY), 4);
INSERT INTO events (group_id, title, description, startTime, priority_id) VALUES (3, 'my.dsu.ca launch', 'Launch of the best website ever', DATE_ADD(NOW(), INTERVAL 1 DAY), 1);
INSERT INTO events (announcement, group_id, title, description, startTime, endTime, priority_id) VALUES (1, 2, 'Dal-ACM Announcement', 'Some cool stuff Dal-ACM has to say.', DATE_ADD(NOW(), INTERVAL -1 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY), 2);
INSERT INTO events (announcement, group_id, title, description, startTime, endTime, priority_id) VALUES (1, 1, 'CSS Announcement', 'Not much to announce.', DATE_ADD(NOW(), INTERVAL -1 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY), 4);
INSERT INTO events (announcement, group_id, title, description, startTime, endTime, priority_id) VALUES (1, 3, 'Oliver wins the Universe Awesomeness Award', 'Add a lot of text here to make the description to be cut off. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy.', DATE_ADD(NOW(), INTERVAL -1 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY), 1);


INSERT INTO categories_events (event_id, category_id) VALUES (1, 4);
INSERT INTO categories_events (event_id, category_id) VALUES (2, 3);
INSERT INTO categories_events (event_id, category_id) VALUES (3, 3);
INSERT INTO categories_events (event_id, category_id) VALUES (4, 2);
INSERT INTO categories_events (event_id, category_id) VALUES (5, 2);
INSERT INTO categories_events (event_id, category_id) VALUES (6, 1);

INSERT INTO association_types (name) VALUES ('OR');
INSERT INTO association_types (name) VALUES ('AND');

-- 6
INSERT INTO selectors (name, label, include_events) VALUES ('DSU', 'dsu', 1);
-- 1, 2, 5
INSERT INTO selectors (name, label, include_events) VALUES ('Computer Science Society', 'computer_science_society', 1);
-- 3, 4, 6
INSERT INTO selectors (name, label, include_events, include_announcements) VALUES ('Headlines', 'headlines', 1, 1);
-- 1, 4, 5
INSERT INTO selectors (name, label, include_events) VALUES ('Varsity or Beer', 'varsity_or_beer', 1);
-- 4
INSERT INTO selectors (name, label, include_events) VALUES ('Level E and Varsity', 'level_e_and_varsity', 1);
-- 1, 2, 3, 4, 5, 6
INSERT INTO selectors (name, label, include_events) VALUES ('All Events', 'all_events', 1);
-- 7, 8, 9
INSERT INTO selectors (name, label, include_announcements) VALUES ('All Announcements', 'all_announcements', 1);

INSERT INTO categories_selectors (selector_id, category_id, association_type_id) VALUES (4, 2, 1);
INSERT INTO categories_selectors (selector_id, category_id, association_type_id) VALUES (5, 2, 2);
INSERT INTO categories_selectors (selector_id, category_id, association_type_id) VALUES (4, 4, 1);

INSERT INTO priorities_selectors (selector_id, priority_id, association_type_id) VALUES (3, 1, 2);
INSERT INTO priorities_selectors (selector_id, priority_id, association_type_id) VALUES (3, 2, 2);

INSERT INTO group_classes_selectors (selector_id, group_class_id, association_type_id) VALUES (1, 1, 2);
INSERT INTO group_classes_selectors (selector_id, group_class_id, association_type_id) VALUES (5, 3, 2);

INSERT INTO groups_selectors (selector_id, group_id, association_type_id) VALUES (2, 1, 2);

-- add a user to the database to be associated with the events
INSERT INTO users (login, fullname) VALUES ('dummy', 'DUMMY USER');
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM events, users WHERE users.login = 'dummy';
INSERT INTO groups_users (user_id, group_id, authorized) SELECT users.id, groups.id, 1 FROM groups, users WHERE users.login = 'dummy';

-- add anonymous user layouts, put headlines and announcements on top
INSERT INTO layouts (user_id) VALUES (NULL);
INSERT INTO layouts_selectors (layout_id, selector_id, rank) SELECT layouts.id, selectors.id, 100 FROM selectors, layouts WHERE layouts.user_id IS NULL;
UPDATE layouts_selectors SET rank = 1 WHERE selector_id = 3 OR selector_id = 7;

--add user / event data to test user group management
--Chris, approved for CSS, event posted for CSS
INSERT INTO users (login, fullname) VALUES ('cpjordan', 'Chris Jordan');
INSERT INTO groups_users (user_id, group_id, authorized) SELECT users.id, groups.id, 1 FROM groups, users WHERE users.login = 'cpjordan' AND groups.name = 'CSS';
INSERT INTO events (group_id, title, description, startTime, priority_id) SELECT groups.id, 'Chris\'s Event', 'This is the test event for Chris. He belongs to CSS', DATE_ADD(NOW(), INTERVAL 1 DAY), 3 FROM groups where groups.name = 'CSS';
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Chris\'s Event' AND categories.name = 'Social';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'cpjordan' AND events.title = 'Chris\'s Event';

INSERT INTO events (group_id, title, description, startTime, priority_id) VALUES (1, 'GeekBeer 1', 'startTime before now 3 days, no endtime', DATE_ADD(NOW(), INTERVAL -3 DAY), 3);
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'GeekBeer 1' AND categories.name = 'Social';
INSERT INTO events (group_id, title, description, startTime, endTime, priority_id) VALUES (1, 'GeekBeer 2', 'startTime before now 1 day, endtime after now 5 days', DATE_ADD(NOW(), INTERVAL -1 DAY), DATE_ADD(NOW(), INTERVAL 5 DAY), 3);
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'GeekBeer 2' AND categories.name = 'Social';
INSERT INTO events (group_id, title, description, startTime, endTime, priority_id) VALUES (1, 'GeekBeer 3', 'startTime after now 14 days, endtime after now 18 days', DATE_ADD(NOW(), INTERVAL 14 DAY), DATE_ADD(NOW(), INTERVAL 18 DAY), 3);
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'GeekBeer 3' AND categories.name = 'Social';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'cpjordan' AND events.title = 'GeekBeer 1';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'cpjordan' AND events.title = 'GeekBeer 2';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'cpjordan' AND events.title = 'GeekBeer 3';
--Oliver, unapproved for CSS, event posted for CSS
INSERT INTO users (login, fullname) VALUES ('obaltzer', 'Oliver Baltzer');
INSERT INTO groups_users (user_id, group_id, authorized) SELECT users.id, groups.id, 0 FROM groups, users WHERE users.login = 'obaltzer' AND groups.name = 'CSS';
INSERT INTO events (group_id, title, description, startTime, priority_id) SELECT groups.id, 'Oliver\'s Event', 'This is the test event for Oliver. He belongs to CSS', DATE_ADD(NOW(), INTERVAL 1 DAY), 3 FROM groups where groups.name = 'CSS';
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Oliver\'s Event' AND categories.name = 'Social';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'obaltzer' AND events.title = 'Oliver\'s Event';
--Sean, approved for CSS, event posted for CSS
INSERT INTO users (login, fullname) VALUES ('ssmith', 'Sean Smith');
INSERT INTO groups_users (user_id, group_id, authorized) SELECT users.id, groups.id, 1 FROM groups, users WHERE users.login = 'ssmith' AND groups.name = 'CSS';
INSERT INTO events (group_id, title, description, startTime, priority_id) SELECT groups.id, 'Sean\'s Event', 'This is the test event for Sean. He belongs to CSS', DATE_ADD(NOW(), INTERVAL 1 DAY), 3 FROM groups where groups.name = 'CSS';
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Sean\'s Event' AND categories.name = 'Social';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'ssmith' AND events.title = 'Sean\'s Event';

--Oliver, approved for Dal-ACM, event and announcements posted for Dal-ACM
INSERT INTO groups_users (user_id, group_id, authorized) SELECT users.id, groups.id, 1 FROM groups, users WHERE users.login = 'obaltzer' AND groups.name = 'Dal-ACM';
INSERT INTO events (group_id, title, description, startTime, priority_id) SELECT groups.id, 'Oliver\'s Dal-ACM Event', 'This is the test event for Oliver. He belongs to Dal-ACM', DATE_ADD(NOW(), INTERVAL 1 DAY), 3 FROM groups where groups.name = 'Dal-ACM';
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Oliver\'s Dal-ACM Event' AND categories.name = 'Beer';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'obaltzer' AND events.title = 'Oliver\'s Dal-ACM Event';

INSERT INTO events (announcement, group_id, title, description, startTime, endTime, priority_id) VALUES (1, 2, 'Dal-ACM Announcement 1', 'start before now 3 days, end before now 1 day', DATE_ADD(NOW(), INTERVAL -3 DAY), DATE_ADD(NOW(), INTERVAL -1 DAY), 2);
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Dal-ACM Announcement 1' AND categories.name = 'Beer';
INSERT INTO events (announcement, group_id, title, description, startTime, endTime, priority_id) VALUES (1, 2, 'Dal-ACM Announcement 2', 'start after now 2 days, end after now 24 days', DATE_ADD(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 24 DAY), 2);
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Dal-ACM Announcement 2' AND categories.name = 'Beer';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'obaltzer' AND events.title = 'Dal-ACM Announcement 1';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'obaltzer' AND events.title = 'Dal-ACM Announcement 2';
--Sean, approved for Dal-ACM, event posted for Dal-ACM
INSERT INTO groups_users (user_id, group_id, authorized) SELECT users.id, groups.id, 1 FROM groups, users WHERE users.login = 'ssmith' AND groups.name = 'Dal-ACM';
INSERT INTO events (group_id, title, description, startTime, priority_id) SELECT groups.id, 'Sean\'s Dal-ACM Event', 'This is the test event for Sean. He belongs to Dal-ACM', DATE_ADD(NOW(), INTERVAL 1 DAY), 3 FROM groups where groups.name = 'Dal-ACM';
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Sean\'s Dal-ACM Event' AND categories.name = 'Beer';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'ssmith' AND events.title = 'Sean\'s Dal-ACM Event';
--Chris, unapproved for Dal-ACM, event posted for Dal-ACM
INSERT INTO groups_users (user_id, group_id, authorized) SELECT users.id, groups.id, 0 FROM groups, users WHERE users.login = 'cpjordan' AND groups.name = 'Dal-ACM';
INSERT INTO events (group_id, title, description, startTime, priority_id) SELECT groups.id, 'Chris\'s Dal-ACM Event', 'This is the test event for Chris. He belongs to Dal-ACM', DATE_ADD(NOW(), INTERVAL 1 DAY), 3 FROM groups where groups.name = 'Dal-ACM';
INSERT INTO categories_events (event_id, category_id) SELECT events.id, categories.id FROM events, categories WHERE events.title = 'Chris\'s Dal-ACM Event' AND categories.name = 'Beer';
INSERT INTO activities (event_id, user_id, action) SELECT events.id, users.id, 'CREATE' FROM users, events WHERE users.login = 'cpjordan' AND events.title = 'Chris\'s Dal-ACM Event';

INSERT INTO groups (name, description, group_class_id, approved) VALUES ("DASSS", "Dalhousie Arts And Social Sciences Society", 1, 0);
