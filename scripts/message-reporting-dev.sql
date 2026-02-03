DROP TABLE IF EXISTS all_hashes;
CREATE TABLE all_hashes (
    table_name text,
    hashed_row text
);

DO $$
DECLARE 
    r record;
    dyn_sql text;
BEGIN
    FOR r IN 
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
          AND table_type = 'BASE TABLE'
    LOOP
        dyn_sql := format(
            'INSERT INTO all_hashes (table_name, hashed_row)
             SELECT %L, md5(t::text)
             FROM %I.%I t;',
            r.table_name,
            r.table_schema,
            r.table_name
        );
        EXECUTE dyn_sql;
    END LOOP;
END $$;

SELECT * FROM all_hashes;
DROP TABLE IF EXISTS all_hashes;
