CREATE OR REPLACE FUNCTION search_contacts(pattern TEXT)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    phone VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.name, p.phone
    FROM phonebook p
    WHERE p.name ILIKE '%' || pattern || '%'
       OR p.phone ILIKE '%' || pattern || '%'
    ORDER BY p.name;
END;
$$;

CREATE OR REPLACE FUNCTION get_contacts_paginated(
    page_size INTEGER,
    page_number INTEGER
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    phone VARCHAR,
    total_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    offset_val INTEGER;
    total BIGINT;
BEGIN
    offset_val := (page_number - 1) * page_size;
    
    SELECT COUNT(*) INTO total FROM phonebook;
    
    RETURN QUERY
    SELECT p.id, p.name, p.phone, total
    FROM phonebook p
    ORDER BY p.id
    LIMIT page_size OFFSET offset_val;
END;
$$;
