-- ButlerX PostgreSQL Schema
-- Database: butlerx
-- Run: psql -h localhost -U postgres -d butlerx -f schema.sql

-- ── Conversations ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS conversations (
    id          TEXT        PRIMARY KEY,
    user_id     TEXT        NOT NULL,
    title       TEXT        NOT NULL,
    created_at  BIGINT      NOT NULL,   -- milliseconds since epoch
    updated_at  BIGINT                  -- nullable
);

CREATE INDEX IF NOT EXISTS idx_conversations_user_id_created_at
    ON conversations (user_id, created_at DESC);

-- ── Chat Messages ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_messages (
    id                  TEXT    PRIMARY KEY,
    conversation_id     TEXT    NOT NULL
        REFERENCES conversations(id) ON DELETE CASCADE,
    role                TEXT    NOT NULL,   -- 'user' | 'assistant' | 'system'
    content             TEXT    NOT NULL,
    created_at          BIGINT  NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_id_created_at
    ON chat_messages (conversation_id, created_at ASC);

-- ── Appointments ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS appointments (
    id                  TEXT        PRIMARY KEY,
    user_id             TEXT        NOT NULL,
    title               TEXT        NOT NULL,
    start_at            BIGINT      NOT NULL,
    end_at              BIGINT,
    description         TEXT,
    location            TEXT,
    reminder_offset     INTEGER     NOT NULL DEFAULT 15,  -- minutes
    source              TEXT        NOT NULL,  -- 'voice' | 'manual' | 'ai'
    raw_transcript      TEXT,
    created_at          BIGINT      NOT NULL,
    updated_at          BIGINT      NOT NULL,
    notification_id     INTEGER
);

CREATE INDEX IF NOT EXISTS idx_appointments_user_id_start_at
    ON appointments (user_id, start_at ASC);

-- ── Special Occasions ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS special_occasions (
    id          TEXT        PRIMARY KEY,
    user_id     TEXT,
    label       TEXT        NOT NULL,
    month       INTEGER     NOT NULL CHECK (month BETWEEN 1 AND 12),
    day         INTEGER     NOT NULL CHECK (day BETWEEN 1 AND 31),
    year        INTEGER,
    category    TEXT        NOT NULL,   -- 'birthday' | 'anniversary' | 'holiday' | etc.
    is_lunar    BOOLEAN     NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_special_occasions_user_id
    ON special_occasions (user_id);

-- ── Health Records ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS health_records (
    id                          TEXT            PRIMARY KEY,
    user_id                     TEXT            NOT NULL,
    recorded_at                 BIGINT          NOT NULL,
    weight_kg                   DOUBLE PRECISION,
    height_cm                   DOUBLE PRECISION,
    blood_pressure_systolic     INTEGER,
    blood_pressure_diastolic    INTEGER,
    heart_rate_bpm              INTEGER,
    blood_sugar_mmol            DOUBLE PRECISION,
    notes                       TEXT
);

CREATE INDEX IF NOT EXISTS idx_health_records_user_id_recorded_at
    ON health_records (user_id, recorded_at DESC);

-- ── Reminders ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reminders (
    id                      TEXT        PRIMARY KEY,
    user_id                 TEXT        NOT NULL,
    title                   TEXT        NOT NULL,
    body                    TEXT,
    scheduled_at            BIGINT      NOT NULL,
    repeat_rule             TEXT        NOT NULL DEFAULT 'none',  -- 'none' | 'daily' | 'weekly' | etc.
    is_active               BOOLEAN     NOT NULL DEFAULT TRUE,
    linked_appointment_id   TEXT,       -- optional FK to appointments
    created_at              BIGINT      NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_reminders_user_id_scheduled_at
    ON reminders (user_id, scheduled_at ASC);
CREATE INDEX IF NOT EXISTS idx_reminders_user_id_is_active
    ON reminders (user_id, is_active) WHERE is_active = TRUE;
