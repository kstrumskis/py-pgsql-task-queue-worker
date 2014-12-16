CREATE SCHEMA "task-queue-worker";

CREATE TABLE "task-queue-worker".client
(
  id serial NOT NULL,
  "timestamp" timestamp with time zone NOT NULL DEFAULT now(),
  category text,
  hostname text,
  hostip text,
  CONSTRAINT client_pkey PRIMARY KEY (id)
);

CREATE TABLE "task-queue-worker".task_type
(
	id serial NOT NULL,
	"timestamp" timestamp with time zone NOT NULL DEFAULT now(),
	name text,
	comment text,
	CONSTRAINT task_category_pkey PRIMARY KEY (id)
);

INSERT INTO "task-queue-worker".task_type (name) VALUES ('tasks.custom_task');

CREATE TABLE "task-queue-worker".task_queue
(
  id serial NOT NULL,
  "timestamp" timestamp with time zone NOT NULL DEFAULT now(),
  type integer,
  completed boolean NOT NULL DEFAULT false,
  completed_timestamp timestamp with time zone,
  reserved boolean NOT NULL DEFAULT false,
  reserved_timestamp timestamp with time zone,
  started boolean NOT NULL DEFAULT false,
  started_timestamp timestamp with time zone,
  reference_id integer,
  client integer,
  fallen boolean DEFAULT false, -- task that hadn't responded for long time
  CONSTRAINT task_queue_pkey PRIMARY KEY (id),
  CONSTRAINT task_queue_client_fkey FOREIGN KEY (client)
      REFERENCES "task-queue-worker".client (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT task_queue_type_fkey FOREIGN KEY (type)
      REFERENCES "task-queue-worker".task_type (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON COLUMN "task-queue-worker".task_queue.fallen IS 'task that hadn''t responded for long time';

CREATE INDEX task_queue_type_reserved_completed_idx ON "task-queue-worker".task_queue
  USING btree
  (type NULLS FIRST, reserved NULLS FIRST, completed NULLS FIRST);

CREATE TABLE "task-queue-worker".task_queue_completed
(
  id serial NOT NULL,
  "timestamp" timestamp with time zone NOT NULL DEFAULT now(),
  type integer,
  completed boolean,
  completed_timestamp timestamp with time zone,
  reserved boolean,
  reserved_timestamp timestamp with time zone,
  started boolean,
  started_timestamp timestamp with time zone,
  reference_id integer,
  client integer,
  fallen boolean,
  CONSTRAINT task_queue_completed_pkey PRIMARY KEY (id)
);

CREATE TABLE "task-queue-worker".task_queue_errored
(
  id serial NOT NULL,
  "timestamp" timestamp with time zone NOT NULL DEFAULT now(),
  type integer,
  completed boolean,
  completed_timestamp timestamp with time zone,
  reserved boolean,
  reserved_timestamp timestamp with time zone,
  started boolean,
  started_timestamp timestamp with time zone,
  reference_id integer,
  client integer,
  fallen boolean,
  CONSTRAINT task_queue_errored_pkey PRIMARY KEY (id)
);

-------------------

CREATE OR REPLACE FUNCTION "task-queue-worker".clean_errors()
  RETURNS trigger AS
$BODY$BEGIN

-- WITH data2 AS (DELETE FROM "task-queue-worker".task_queue WHERE completed=False 
-- and reserved=True and gid_created < (now()-'03:00:00'::interval) RETURNING *)
--    INSERT INTO "task-queue-worker".task_queue_errored SELECT * FROM data2;

RETURN NEW;

END$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION "task-queue-worker".update_completed_timestamp()
  RETURNS trigger AS
$BODY$BEGIN
NEW.completed_timestamp := NOW();
RETURN NEW;
END$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION "task-queue-worker".update_reserved_timestamp()
  RETURNS trigger AS
$BODY$BEGIN
NEW.reserved_timestamp := NOW();
RETURN NEW;
END$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION "task-queue-worker".update_started_timestamp()
  RETURNS trigger AS
$BODY$BEGIN
NEW.started_timestamp := NOW();
RETURN NEW;
END$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION "task-queue-worker".clean_task_queue()
  RETURNS void AS
$BODY$BEGIN

WITH data1 AS (DELETE FROM "task-queue-worker".task_queue WHERE completed=True and completed_timestamp < (now()-'01:00:00'::interval) RETURNING *)
    INSERT INTO "task-queue-worker".task_queue_completed SELECT * FROM data1;

WITH data2 AS (DELETE FROM "task-queue-worker".task_queue WHERE completed=False 
and reserved=True and reserved_timestamp < (now()-'01:00:00'::interval) RETURNING *)
    INSERT INTO "task-queue-worker".task_queue_errored SELECT * FROM data2;

END$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

-------------------

CREATE TRIGGER clean_errors
  AFTER INSERT
  ON "task-queue-worker".task_queue
  FOR EACH STATEMENT
  EXECUTE PROCEDURE "task-queue-worker".clean_errors();
;

CREATE TRIGGER task_queue_completed_trigger
  BEFORE UPDATE OF completed
  ON "task-queue-worker".task_queue
  FOR EACH ROW
  EXECUTE PROCEDURE "task-queue-worker".update_completed_timestamp();

CREATE TRIGGER task_queue_reserved_trigger
  BEFORE UPDATE OF reserved
  ON "task-queue-worker".task_queue
  FOR EACH ROW
  EXECUTE PROCEDURE "task-queue-worker".update_reserved_timestamp();

CREATE TRIGGER task_queue_started_trigger
  BEFORE UPDATE OF started
  ON "task-queue-worker".task_queue
  FOR EACH ROW
  EXECUTE PROCEDURE "task-queue-worker".update_started_timestamp();


  CREATE OR REPLACE VIEW "task-queue-worker".v_task_queue_fresh AS 
 SELECT task_queue.id, task_queue."timestamp", 
 task_queue.type, task_queue.completed, task_queue.completed_timestamp, task_queue.reserved, 
 task_queue.reserved_timestamp, task_queue.started, task_queue.started_timestamp, task_queue.reference_id, task_queue.client
   FROM "task-queue-worker".task_queue
  WHERE task_queue.completed = false AND task_queue.fallen <> true;


  CREATE OR REPLACE VIEW "task-queue-worker".v_tasks_completed_per_hour AS 
 SELECT date_trunc('hour'::text, task_queue.completed_timestamp) AS date_trunc, count(*) AS count
   FROM "task-queue-worker".task_queue_completed task_queue
  WHERE task_queue.completed = true
  GROUP BY date_trunc('hour'::text, task_queue.completed_timestamp)
  ORDER BY date_trunc('hour'::text, task_queue.completed_timestamp);

  CREATE OR REPLACE VIEW "task-queue-worker".v_tasks_completed_per_hour_per_type AS 
 SELECT date_trunc('hour'::text, task_queue.completed_timestamp) AS date_trunc, task_type.name, count(*) AS count
   FROM "task-queue-worker".task_queue_completed task_queue
   JOIN "task-queue-worker".task_type ON task_type.id = task_queue.type
  WHERE task_queue.completed = true
  GROUP BY date_trunc('hour'::text, task_queue.completed_timestamp), task_type.name
  ORDER BY date_trunc('hour'::text, task_queue.completed_timestamp);

