CREATE OR REPLACE PROCEDURE upsert_contact(
    p_name VARCHAR,
    p_phone VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM phonebook WHERE phone = p_phone) THEN
        UPDATE phonebook SET name = p_name WHERE phone = p_phone;
        RAISE NOTICE 'Contact updated: name=%, phone=%', p_name, p_phone;
    ELSE
        INSERT INTO phonebook (name, phone) VALUES (p_name, p_phone);
        RAISE NOTICE 'Contact inserted: name=%, phone=%', p_name, p_phone;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE bulk_insert_contacts(
    contacts_data TEXT[][]
)
LANGUAGE plpgsql
AS $$
DECLARE
    i INTEGER;
    contact_name VARCHAR;
    contact_phone VARCHAR;
    invalid_data TEXT := '';
BEGIN
    FOR i IN 1..array_length(contacts_data, 1) LOOP
        contact_name := contacts_data[i][1];
        contact_phone := contacts_data[i][2];
        
        IF contact_phone ~ '^[0-9+\-\(\) ]+$' AND LENGTH(contact_phone) >= 5 THEN
            CALL upsert_contact(contact_name, contact_phone);
        ELSE
            invalid_data := invalid_data || format('Name: %s, Phone: %s (invalid); ', 
                                                   contact_name, contact_phone);
        END IF;
    END LOOP;
    
    IF invalid_data != '' THEN
        RAISE WARNING 'Invalid contacts skipped: %', invalid_data;
    END IF;
    
    RAISE NOTICE 'Bulk insert completed. Total processed: %', array_length(contacts_data, 1);
END;
$$;

CREATE OR REPLACE PROCEDURE delete_contact(
    p_name VARCHAR DEFAULT NULL,
    p_phone VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    IF p_name IS NOT NULL THEN
        DELETE FROM phonebook WHERE name = p_name;
        GET DIAGNOSTICS deleted_count = ROW_COUNT;
        RAISE NOTICE 'Deleted % contact(s) with name: %', deleted_count, p_name;
    ELSIF p_phone IS NOT NULL THEN
        DELETE FROM phonebook WHERE phone = p_phone;
        GET DIAGNOSTICS deleted_count = ROW_COUNT;
        RAISE NOTICE 'Deleted % contact(s) with phone: %', deleted_count, p_phone;
    ELSE
        RAISE EXCEPTION 'Either name or phone must be provided for deletion';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_all_contacts()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM phonebook;
    RAISE NOTICE 'All contacts have been deleted';
END;
$$;
