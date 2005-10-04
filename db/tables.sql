CREATE TABLE IF NOT EXISTS users (
  id int(11) NOT NULL auto_increment,
  login varchar(80) NOT NULL UNIQUE,
  fullname varchar(80) NOT NULL,
  email varchar(100) NOT NULL,
  hashed_pass char(40) NULL,
  banned tinyint(1) NOT NULL default '0',
  superuser tinyint(1) NOT NULL default '0',
  created_on timestamp(14) NOT NULL,
  updated_on timestamp(14) NOT NULL,
  PRIMARY KEY (id),
  FULLTEXT (fullname)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS activities (
  id int(11) NOT NULL auto_increment,
  action varchar(100) NOT NULL,
  user_id int(11) NOT NULL,
  event_id int(11) NOT NULL,
  created_on timestamp(14) NOT NULL,
  updated_on timestamp(14) NOT NULL,
  PRIMARY KEY  (id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (event_id) REFERENCES events(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS events (
  id int(11) NOT NULL auto_increment,
  announcement int(1) NOT NULL default '0',
  group_id int(11),
  description text NOT NULL,
  title varchar(100) NOT NULL,
  startTime datetime NOT NULL,
  endTime datetime,
  priority_id int(11),
  url varchar(100),
  deleted int(1) NOT NULL default '0',
  created_on timestamp(14) NOT NULL,
  updated_on timestamp(14) NOT NULL,
  PRIMARY KEY  (id),
  FULLTEXT KEY eventIndex (description,title),
  FOREIGN KEY (group_id) REFERENCES groups(id),
  FOREIGN KEY (priority_id) REFERENCES priorities(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS categories_events (
  event_id int(11) NOT NULL,
  category_id int(11) NOT NULL,
  FOREIGN KEY (event_id) REFERENCES events(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS categories (
  id int(11) NOT NULL auto_increment,
  name varchar(100) NOT NULL,
  hide tinyint(1) NOT NULL default '0',
  created_on timestamp(14) NOT NULL,
  updated_on timestamp(14) NOT NULL,
  created_by int(11) NOT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS eventratings (
  id int(11) NOT NULL auto_increment,
  event_id int(11) NOT NULL,
  score int(11) NOT NULL,
  PRIMARY KEY  (id),
  FOREIGN KEY (event_id) REFERENCES events(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS groups_users (
  user_id int(11) NOT NULL,
  group_id int(11) NOT NULL,
  authorized tinyint(1) NOT NULL default '0',
  PRIMARY KEY(user_id, group_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (group_id) REFERENCES groups(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS groups (
  id int(11) NOT NULL auto_increment,
  name varchar(100) NOT NULL UNIQUE,
  description text NOT NULL,
  group_class_id int(11),
  approved tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (id),
  FOREIGN KEY (group_class_id) REFERENCES group_classes(id),
  FULLTEXT KEY groupsIndex (description,name)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS group_classes (
  id int(11) NOT NULL auto_increment,
  name varchar(100) NOT NULL,
  parent_id int(11),
  PRIMARY KEY  (id),
  FOREIGN KEY (parent_id) REFERENCES group_classes(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS group_classes_users (
  user_id int(11) NOT NULL,
  group_class_id int(11) NOT NULL,
  PRIMARY KEY(user_id, group_class_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (group_class_id) REFERENCES group_class(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS bookmarks (
  id int(11) NOT NULL auto_increment,
  user_id int(11) NOT NULL,
  event_id int(11) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (event_id) REFERENCES events(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS layouts (
  id int(11) NOT NULL auto_increment,
  user_id int(11),
  selector_id int(11) NOT NULL,
  rank int(11) NOT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (selector_id) REFERENCES selectors(id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS priorities (
  id int(11) NOT NULL auto_increment,
  name varchar(30) NOT NULL,
  rank int(4) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS selectors (
  id int(11) NOT NULL auto_increment,
  name varchar(100) NOT NULL,
  label varchar(100) NOT NULL,
  include_events tinyint(1) NOT NULL default '0',
  include_announcements tinyint(1) NOT NULL default '0',
  PRIMARY KEY (id)
) TYPE=MyISAM;

CREATE TABLE IF NOT EXISTS association_types (
  id int(11) NOT NULL auto_increment,
  name varchar(10) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS categories_selectors (
  selector_id int(11) NOT NULL,
  category_id int(11) NOT NULL,
  association_type_id int(11) NOT NULL,
  FOREIGN KEY (selector_id) REFERENCES selectors(id),
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (association_type_id) REFERENCES association_types(id)
);

CREATE TABLE IF NOT EXISTS group_classes_selectors (
  selector_id int(11) NOT NULL,
  group_class_id int(11) NOT NULL,
  association_type_id int(11) NOT NULL,
  FOREIGN KEY (selector_id) REFERENCES selectors(id),
  FOREIGN KEY (group_class_id) REFERENCES group_classes(id),
  FOREIGN KEY (association_type_id) REFERENCES association_types(id)
);

CREATE TABLE IF NOT EXISTS groups_selectors (
  selector_id int(11) NOT NULL,
  group_id int(11) NOT NULL,
  association_type_id int(11) NOT NULL,
  FOREIGN KEY (selector_id) REFERENCES selectors(id),
  FOREIGN KEY (group_id) REFERENCES groups(id),
  FOREIGN KEY (association_type_id) REFERENCES association_types(id)
);

CREATE TABLE IF NOT EXISTS priorities_selectors (
  selector_id int(11) NOT NULL,
  priority_id int(11) NOT NULL,
  association_type_id int(11) NOT NULL,
  FOREIGN KEY (selector_id) REFERENCES selectors(id),
  FOREIGN KEY (priority_id) REFERENCES priorities(id),
  FOREIGN KEY (association_type_id) REFERENCES association_types(id)
);
