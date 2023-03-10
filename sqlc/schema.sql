CREATE TABLE bookmarks (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  url         TEXT        NOT NULL,
  title       TEXT        NOT NULL,
  description TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMPTZ NOT NULL    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
  id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name       VARCHAR(100) NOT NULL,
  color      VARCHAR(7)   NOT NULL,
  created_at TIMESTAMPTZ  NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ  NOT NULL    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  bookmark_id UUID        NOT NULL    REFERENCES bookmarks(id) ON DELETE CASCADE,
  body        TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMPTZ NOT NULL    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bookmark_has_tags (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  bookmark_id UUID        NOT NULL    REFERENCES bookmarks(id) ON DELETE CASCADE,
  tag_id      UUID        NOT NULL    REFERENCES tags(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMPTZ NOT NULL    DEFAULT CURRENT_TIMESTAMP
);
