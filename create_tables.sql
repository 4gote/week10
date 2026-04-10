DROP TABLE IF EXISTS phonebook CASCADE;

CREATE TABLE phonebook (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE
);

CREATE INDEX idx_phonebook_name ON phonebook(name);
CREATE INDEX idx_phonebook_phone ON phonebook(phone);
