CREATE TABLE audit_event (
  id            bigserial PRIMARY KEY,
  ts            timestamptz NOT NULL DEFAULT now(),
  signal_id     uuid NOT NULL,
  agent         text NOT NULL,
  stage         text NOT NULL,
  decision      text NOT NULL,
  symbol        text,
  rationale     text NOT NULL,
  data_source   text NOT NULL,
  model_version text NOT NULL,
  payload       jsonb NOT NULL
);
-- Application role: INSERT and SELECT only. No UPDATE or DELETE.
