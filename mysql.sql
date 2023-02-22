-- Migration number: 0000 	 2022-12-05T20:27:34.391Z

drop TABLE actors;
drop TABLE actor_following;
drop TABLE objects;
drop TABLE inbox_objects;
drop TABLE outbox_objects;
drop TABLE actor_notifications;
drop TABLE actor_favourites;
drop TABLE actor_reblogs;
drop TABLE clients;
drop TABLE actor_replies;
drop TABLE peers;
/* drop TABLE idempotency_keys; */
drop TABLE note_hashtags;
drop TABLE subscriptions;


CREATE TABLE actors (
  id varchar(255) PRIMARY KEY,
  type varchar(255) NOT NULL,
  email varchar(255),
  privkey blob,
  privkey_salt blob,
  pubkey varchar(255),
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  properties varchar(255) NOT NULL DEFAULT ('{}')
);

CREATE INDEX actors_email ON actors(email);

CREATE TABLE actor_following (
  id varchar(255) PRIMARY KEY,
  actor_id varchar(255) NOT NULL,
  target_actor_id varchar(255) NOT NULL,
  target_actor_acct varchar(255) NOT NULL,
  state varchar(255) NOT NULL DEFAULT 'pending',
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX actor_following_actor_id ON actor_following(actor_id);
CREATE INDEX actor_following_target_actor_id ON actor_following(target_actor_id);

CREATE TABLE objects (
  id varchar(255) PRIMARY KEY,
  mastodon_id varchar(255) UNIQUE NOT NULL,
  type varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  original_actor_id varchar(255),
  original_object_id varchar(255) UNIQUE,
  reply_to_object_id varchar(255),
  properties varchar(255) NOT NULL DEFAULT ('{}'),
  local INTEGER NOT NULL
);

CREATE TABLE inbox_objects (
  id varchar(255) PRIMARY KEY,
  actor_id varchar(255) NOT NULL,
  object_id varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE outbox_objects (
  id varchar(255) PRIMARY KEY,
  actor_id varchar(255) NOT NULL,
  object_id varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  published_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE actor_notifications (
  id SERIAL PRIMARY KEY,
  type varchar(255) NOT NULL,
  actor_id varchar(255) NOT NULL,
  from_actor_id varchar(255) NOT NULL,
  object_id varchar(255),
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE INDEX actor_notifications_actor_id ON actor_notifications(actor_id);

CREATE TABLE actor_favourites (
  id varchar(255) PRIMARY KEY,
  actor_id varchar(255) NOT NULL,
  object_id varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE INDEX actor_favourites_actor_id ON actor_favourites(actor_id);
CREATE INDEX actor_favourites_object_id ON actor_favourites(object_id);

CREATE TABLE actor_reblogs (
  id varchar(255) PRIMARY KEY,
  actor_id varchar(255) NOT NULL,
  object_id varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE INDEX actor_reblogs_actor_id ON actor_reblogs(actor_id);
CREATE INDEX actor_reblogs_object_id ON actor_reblogs(object_id);

CREATE TABLE clients (
  id varchar(255) PRIMARY KEY,
  secret varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  redirect_uris varchar(255) NOT NULL,
  website varchar(255),
  scopes varchar(255),
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE actor_replies (
  id varchar(255) PRIMARY KEY,
  actor_id varchar(255) NOT NULL,
  object_id varchar(255) NOT NULL,
  in_reply_to_object_id varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE INDEX actor_replies_in_reply_to_object_id ON actor_replies(in_reply_to_object_id);
-- Migration number: 0001 	 2023-01-16T13:09:04.033Z

CREATE UNIQUE INDEX unique_actor_following ON actor_following (actor_id, target_actor_id);
-- Migration number: 0002 	 2023-01-16T13:46:54.975Z

ALTER TABLE outbox_objects
  ADD target varchar(255) NOT NULL DEFAULT 'https://www.w3.org/ns/activitystreams#Public';
-- Migration number: 0003 	 2023-02-02T15:03:27.478Z

CREATE TABLE peers (
  domain varchar(255) UNIQUE NOT NULL
);
-- Migration number: 0004 	 2023-02-03T17:17:19.099Z

CREATE INDEX outbox_objects_actor_id ON outbox_objects(actor_id);
CREATE INDEX outbox_objects_target ON outbox_objects(target);
-- Migration number: 0005 	 2023-02-07T10:57:21.848Z

/* CREATE TABLE idempotency_keys ( */
/*   key varchar(255) PRIMARY KEY, */
/*   object_id varchar(255) NOT NULL, */
/*   expires_at TIMESTAMP NOT NULL */

/* ); */
-- Migration number: 0006 	 2023-02-13T11:18:03.485Z

CREATE TABLE note_hashtags (
  value varchar(255) NOT NULL,
  object_id varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
-- Migration number: 0007 	 2023-02-15T11:01:46.585Z

CREATE TABLE subscriptions (
  id SERIAL PRIMARY KEY,
  actor_id varchar(255) NOT NULL,
  client_id varchar(255) NOT NULL,
  endpoint varchar(255) NOT NULL,
  key_p256dh varchar(255) NOT NULL,
  key_auth varchar(255) NOT NULL,
  alert_mention INTEGER NOT NULL,
  alert_status INTEGER NOT NULL,
  alert_reblog INTEGER NOT NULL,
  alert_follow INTEGER NOT NULL,
  alert_follow_request INTEGER NOT NULL,
  alert_favourite INTEGER NOT NULL,
  alert_poll INTEGER NOT NULL,
  alert_update INTEGER NOT NULL,
  alert_admin_sign_up INTEGER NOT NULL,
  alert_admin_report INTEGER NOT NULL,
  policy varchar(255) NOT NULL,
  cdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE(actor_id, client_id)
);
