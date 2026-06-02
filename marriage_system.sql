SET SERVEROUTPUT ON;
SPOOL "C:\Users\kamil\OneDrive\Stalinis kompiuteris\VU\Oracle PL_SQL\1_lab\rezultatass.txt"

DROP TABLE sekmingaSantuoka;
DROP TABLE santuoka;
DROP TABLE sekmingaPora;
DROP TABLE sekmingiMoteruMetai;
DROP TABLE sekmingiVyruMetai;
DROP TABLE zenklas;
DROP TABLE error_log;
DROP TABLE error_message;

DROP PACKAGE marriage_pkg;
DROP PACKAGE errors_pkg;

-- Klaidu lenteles
CREATE TABLE error_message (
    error_number NUMBER(5) PRIMARY KEY,
    name         VARCHAR2(4000)
);

INSERT INTO error_message VALUES (-20001, 'Klaida: santuoka nera sekminga.');
INSERT INTO error_message VALUES (-20002, 'Klaida: nurodytas zodiako zenklas neegzistuoja.');
INSERT INTO error_message VALUES (-20003, 'Klaida: santuoku lenteleje nera duomenu.');

CREATE TABLE error_log (
    error_code      NUMBER(5),
    error_message   VARCHAR2(4000),
    program_owner   VARCHAR2(128),
    program_name    VARCHAR2(200),
    error_stack     VARCHAR2(4000),
    error_backtrace VARCHAR2(4000),
    error_user      VARCHAR2(128),
    error_time      DATE
);

-- Klaidu apdorojimo paketas
CREATE OR REPLACE PACKAGE errors_pkg AS
    c_unsuccessful_marriage CONSTANT PLS_INTEGER := -20001;
    exc_unsuccessful_marriage EXCEPTION;
    PRAGMA EXCEPTION_INIT(exc_unsuccessful_marriage, -20001);

    c_sign_not_found CONSTANT PLS_INTEGER := -20002;
    exc_sign_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(exc_sign_not_found, -20002);

    c_no_marriages_found CONSTANT PLS_INTEGER := -20003;
    exc_no_marriages_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(exc_no_marriages_found, -20003);

    FUNCTION get_error_message(i_errnum IN PLS_INTEGER) RETURN VARCHAR2;
    PROCEDURE raise_error(i_errnum IN PLS_INTEGER);

    PROCEDURE save_error(i_program_name IN VARCHAR2);

    PROCEDURE save_error(
        i_program_name  IN VARCHAR2,
        i_error_code    IN PLS_INTEGER,
        i_error_message IN VARCHAR2
    );
END errors_pkg;
/

CREATE OR REPLACE PACKAGE BODY errors_pkg AS
    FUNCTION get_error_message(i_errnum IN PLS_INTEGER) RETURN VARCHAR2 IS
        l_message VARCHAR2(4000);
    BEGIN
        SELECT name
        INTO l_message
        FROM error_message
        WHERE error_number = i_errnum;

        RETURN l_message;
    END get_error_message;

    PROCEDURE raise_error(i_errnum IN PLS_INTEGER) IS
    BEGIN
        RAISE_APPLICATION_ERROR(i_errnum, get_error_message(i_errnum));
    END raise_error;

    PROCEDURE save_error(
        i_program_name  IN VARCHAR2,
        i_error_code    IN PLS_INTEGER,
        i_error_message IN VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO error_log (
            error_code,
            error_message,
            program_owner,
            program_name,
            error_stack,
            error_backtrace,
            error_user,
            error_time
        )
        VALUES (
            i_error_code,
            i_error_message,
            SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'),
            i_program_name,
            DBMS_UTILITY.FORMAT_ERROR_STACK,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            USER,
            SYSDATE
        );

        COMMIT;
    END save_error;

    PROCEDURE save_error(i_program_name IN VARCHAR2) IS
    BEGIN
        save_error(i_program_name, SQLCODE, SQLERRM);
    END save_error;
END errors_pkg;
/

-- 3_lab lenteles
CREATE TABLE zenklas (
    zenklas VARCHAR2(20) PRIMARY KEY,
    aprasas VARCHAR2(100)
);

CREATE TABLE sekmingiVyruMetai (
    metai   NUMBER(4) NOT NULL,
    zenklas VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_sekmingiVyruMetai PRIMARY KEY (metai, zenklas),
    CONSTRAINT fk_sekmingiVyruMetai_zenklas
        FOREIGN KEY (zenklas) REFERENCES zenklas(zenklas)
);

CREATE TABLE sekmingiMoteruMetai (
    metai   NUMBER(4) NOT NULL,
    zenklas VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_sekmingiMoteruMetai PRIMARY KEY (metai, zenklas),
    CONSTRAINT fk_sekmingiMoteruMetai_zenklas
        FOREIGN KEY (zenklas) REFERENCES zenklas(zenklas)
);

CREATE TABLE sekmingaPora (
    motersZenklas VARCHAR2(20) NOT NULL,
    vyroZenklas   VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_sekmingaPora PRIMARY KEY (motersZenklas, vyroZenklas),
    CONSTRAINT fk_sekmingaPora_motersZenklas
        FOREIGN KEY (motersZenklas) REFERENCES zenklas(zenklas),
    CONSTRAINT fk_sekmingaPora_vyroZenklas
        FOREIGN KEY (vyroZenklas) REFERENCES zenklas(zenklas)
);

CREATE TABLE santuoka (
    numeris           NUMBER(6) PRIMARY KEY,
    registracijosData DATE NOT NULL,
    motersZenklas     VARCHAR2(20) NOT NULL,
    vyroZenklas       VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_santuoka_motersZenklas
        FOREIGN KEY (motersZenklas) REFERENCES zenklas(zenklas),
    CONSTRAINT fk_santuoka_vyroZenklas
        FOREIGN KEY (vyroZenklas) REFERENCES zenklas(zenklas)
);

CREATE TABLE sekmingaSantuoka (
    numeris           NUMBER(6) PRIMARY KEY,
    registracijosData DATE NOT NULL,
    motersZenklas     VARCHAR2(20) NOT NULL,
    vyroZenklas       VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_sekmingaSantuoka_motersZenklas
        FOREIGN KEY (motersZenklas) REFERENCES zenklas(zenklas),
    CONSTRAINT fk_sekmingaSantuoka_vyroZenklas
        FOREIGN KEY (vyroZenklas) REFERENCES zenklas(zenklas)
);

-- Test. duomenys
INSERT INTO zenklas VALUES ('Avinas', 'Energiskas ir drasus');
INSERT INTO zenklas VALUES ('Jautis', 'Kantrus ir stabilus');
INSERT INTO zenklas VALUES ('Dvyniai', 'Smalsus ir bendraujantis');
INSERT INTO zenklas VALUES ('Vezys', 'Jautrus ir rupestingas');
INSERT INTO zenklas VALUES ('Liutas', 'Pasitikintis savimi');
INSERT INTO zenklas VALUES ('Mergele', 'Kruopsti ir analitiska');
INSERT INTO zenklas VALUES ('Svarstykles', 'Diplomatiskas');
INSERT INTO zenklas VALUES ('Skorpionas', 'Istikimas');
INSERT INTO zenklas VALUES ('Saulys', 'Optimistiskas');
INSERT INTO zenklas VALUES ('Oziaragis', 'Atsakingas');
INSERT INTO zenklas VALUES ('Vandenis', 'Originalus');
INSERT INTO zenklas VALUES ('Zuvys', 'Jautrios');

INSERT INTO sekmingiVyruMetai VALUES (2024, 'Avinas');
INSERT INTO sekmingiVyruMetai VALUES (2025, 'Jautis');
INSERT INTO sekmingiVyruMetai VALUES (2026, 'Liutas');
INSERT INTO sekmingiVyruMetai VALUES (2024, 'Svarstykles');
INSERT INTO sekmingiVyruMetai VALUES (2025, 'Skorpionas');
INSERT INTO sekmingiVyruMetai VALUES (2023, 'Dvyniai');

INSERT INTO sekmingiMoteruMetai VALUES (2024, 'Jautis');
INSERT INTO sekmingiMoteruMetai VALUES (2025, 'Vezys');
INSERT INTO sekmingiMoteruMetai VALUES (2026, 'Mergele');
INSERT INTO sekmingiMoteruMetai VALUES (2024, 'Svarstykles');
INSERT INTO sekmingiMoteruMetai VALUES (2025, 'Liutas');
INSERT INTO sekmingiMoteruMetai VALUES (2023, 'Zuvys');

INSERT INTO sekmingaPora VALUES ('Jautis', 'Avinas');
INSERT INTO sekmingaPora VALUES ('Vezys', 'Jautis');
INSERT INTO sekmingaPora VALUES ('Mergele', 'Liutas');
INSERT INTO sekmingaPora VALUES ('Svarstykles', 'Svarstykles');
INSERT INTO sekmingaPora VALUES ('Liutas', 'Skorpionas');
INSERT INTO sekmingaPora VALUES ('Zuvys', 'Dvyniai');

INSERT INTO santuoka VALUES (1, DATE '2024-06-10', 'Jautis', 'Avinas');
INSERT INTO santuoka VALUES (2, DATE '2025-07-15', 'Vezys', 'Jautis');
INSERT INTO santuoka VALUES (3, DATE '2026-03-20', 'Mergele', 'Liutas');
INSERT INTO santuoka VALUES (4, DATE '2024-09-01', 'Svarstykles', 'Svarstykles');
INSERT INTO santuoka VALUES (5, DATE '2025-11-12', 'Liutas', 'Skorpionas');
INSERT INTO santuoka VALUES (6, DATE '2023-05-18', 'Zuvys', 'Dvyniai');
INSERT INTO santuoka VALUES (7, DATE '2024-08-08', 'Oziaragis', 'Avinas');
INSERT INTO santuoka VALUES (8, DATE '2025-01-10', 'Avinas', 'Saulys');
INSERT INTO santuoka VALUES (9, DATE '2026-02-14', 'Mergele', 'Jautis');
INSERT INTO santuoka VALUES (10, DATE '2023-12-01', 'Zuvys', 'Liutas');
INSERT INTO santuoka VALUES (11, DATE '2024-09-01', 'Svarstykles', 'Svarstykles');

COMMIT;


-- Santuoku apdorojimo paketas
CREATE OR REPLACE PACKAGE marriage_pkg AS
    PROCEDURE clear_successful_marriages;
    PROCEDURE fill_successful_marriages;

    PROCEDURE save_successful_marriage(
        p_numeris           IN santuoka.numeris%TYPE,
        p_registracijosData IN santuoka.registracijosData%TYPE,
        p_motersZenklas     IN santuoka.motersZenklas%TYPE,
        p_vyroZenklas       IN santuoka.vyroZenklas%TYPE
    );

    FUNCTION delete_unsuccessful_marriages
    RETURN PLS_INTEGER;
END marriage_pkg;
/

CREATE OR REPLACE PACKAGE BODY marriage_pkg AS
    TYPE t_number_tab IS TABLE OF santuoka.numeris%TYPE;
    TYPE t_date_tab IS TABLE OF DATE;
    TYPE t_varchar_tab IS TABLE OF VARCHAR2(20);

    FUNCTION sign_exists(
        p_zenklas IN zenklas.zenklas%TYPE
    ) RETURN BOOLEAN IS
        CURSOR c_sign(cp_zenklas zenklas.zenklas%TYPE) IS
            SELECT zenklas, cp_zenklas
            FROM zenklas;

        v_zenklas    zenklas.zenklas%TYPE;
        v_tikrinamas zenklas.zenklas%TYPE;
        v_exists     BOOLEAN := FALSE;
    BEGIN
        OPEN c_sign(p_zenklas);

        LOOP
            FETCH c_sign INTO v_zenklas, v_tikrinamas;
            EXIT WHEN c_sign%NOTFOUND;

            IF v_zenklas = v_tikrinamas THEN
                v_exists := TRUE;
            END IF;
        END LOOP;

        CLOSE c_sign;

        RETURN v_exists;
    END sign_exists;


    FUNCTION is_successful_pair(
        p_motersZenklas IN sekmingaPora.motersZenklas%TYPE,
        p_vyroZenklas   IN sekmingaPora.vyroZenklas%TYPE
    ) RETURN BOOLEAN IS
        CURSOR c_pair(
            cp_motersZenklas sekmingaPora.motersZenklas%TYPE,
            cp_vyroZenklas   sekmingaPora.vyroZenklas%TYPE
        ) IS
            SELECT motersZenklas, vyroZenklas, cp_motersZenklas, cp_vyroZenklas
            FROM sekmingaPora;

        v_motersZenklas     sekmingaPora.motersZenklas%TYPE;
        v_vyroZenklas       sekmingaPora.vyroZenklas%TYPE;
        v_tikrinamas_moters sekmingaPora.motersZenklas%TYPE;
        v_tikrinamas_vyro   sekmingaPora.vyroZenklas%TYPE;
        v_successful        BOOLEAN := FALSE;
    BEGIN
        OPEN c_pair(p_motersZenklas, p_vyroZenklas);

        LOOP
            FETCH c_pair
            INTO v_motersZenklas, v_vyroZenklas, v_tikrinamas_moters, v_tikrinamas_vyro;

            EXIT WHEN c_pair%NOTFOUND;

            IF v_motersZenklas = v_tikrinamas_moters
               AND v_vyroZenklas = v_tikrinamas_vyro THEN
                v_successful := TRUE;
            END IF;
        END LOOP;

        CLOSE c_pair;

        RETURN v_successful;
    END is_successful_pair;


    FUNCTION is_successful_male_year(
        p_metai   IN NUMBER,
        p_zenklas IN sekmingiVyruMetai.zenklas%TYPE
    ) RETURN BOOLEAN IS
        CURSOR c_male_year(
            cp_metai   NUMBER,
            cp_zenklas sekmingiVyruMetai.zenklas%TYPE
        ) IS
            SELECT metai, zenklas, cp_metai, cp_zenklas
            FROM sekmingiVyruMetai;

        v_metai           sekmingiVyruMetai.metai%TYPE;
        v_zenklas         sekmingiVyruMetai.zenklas%TYPE;
        v_tikrinami_metai sekmingiVyruMetai.metai%TYPE;
        v_tikrinamas      sekmingiVyruMetai.zenklas%TYPE;
        v_successful      BOOLEAN := FALSE;
    BEGIN
        OPEN c_male_year(p_metai, p_zenklas);

        LOOP
            FETCH c_male_year
            INTO v_metai, v_zenklas, v_tikrinami_metai, v_tikrinamas;

            EXIT WHEN c_male_year%NOTFOUND;

            IF v_metai = v_tikrinami_metai
               AND v_zenklas = v_tikrinamas THEN
                v_successful := TRUE;
            END IF;
        END LOOP;

        CLOSE c_male_year;

        RETURN v_successful;
    END is_successful_male_year;


    FUNCTION is_successful_female_year(
        p_metai   IN NUMBER,
        p_zenklas IN sekmingiMoteruMetai.zenklas%TYPE
    ) RETURN BOOLEAN IS
        CURSOR c_female_year(
            cp_metai   NUMBER,
            cp_zenklas sekmingiMoteruMetai.zenklas%TYPE
        ) IS
            SELECT metai, zenklas, cp_metai, cp_zenklas
            FROM sekmingiMoteruMetai;

        v_metai           sekmingiMoteruMetai.metai%TYPE;
        v_zenklas         sekmingiMoteruMetai.zenklas%TYPE;
        v_tikrinami_metai sekmingiMoteruMetai.metai%TYPE;
        v_tikrinamas      sekmingiMoteruMetai.zenklas%TYPE;
        v_successful      BOOLEAN := FALSE;
    BEGIN
        OPEN c_female_year(p_metai, p_zenklas);

        LOOP
            FETCH c_female_year
            INTO v_metai, v_zenklas, v_tikrinami_metai, v_tikrinamas;

            EXIT WHEN c_female_year%NOTFOUND;

            IF v_metai = v_tikrinami_metai
               AND v_zenklas = v_tikrinamas THEN
                v_successful := TRUE;
            END IF;
        END LOOP;

        CLOSE c_female_year;

        RETURN v_successful;
    END is_successful_female_year;


    FUNCTION is_successful_marriage(
        p_registracijosData IN santuoka.registracijosData%TYPE,
        p_motersZenklas     IN santuoka.motersZenklas%TYPE,
        p_vyroZenklas       IN santuoka.vyroZenklas%TYPE
    ) RETURN BOOLEAN IS
        v_metai NUMBER(4);
    BEGIN
        v_metai := EXTRACT(YEAR FROM p_registracijosData);

        RETURN is_successful_pair(p_motersZenklas, p_vyroZenklas)
           AND is_successful_male_year(v_metai, p_vyroZenklas)
           AND is_successful_female_year(v_metai, p_motersZenklas);
    END is_successful_marriage;


    PROCEDURE clear_successful_marriages IS
    BEGIN
        DELETE FROM sekmingaSantuoka;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            errors_pkg.save_error('marriage_pkg.clear_successful_marriages');
            RAISE;
    END clear_successful_marriages;


    PROCEDURE fill_successful_marriages IS
        c_santuokos SYS_REFCURSOR;

        l_numeriai      t_number_tab;
        l_datos         t_date_tab;
        l_motersZenklai t_varchar_tab;
        l_vyroZenklai   t_varchar_tab;

        l_ok_numeriai      t_number_tab := t_number_tab();
        l_ok_datos         t_date_tab := t_date_tab();
        l_ok_motersZenklai t_varchar_tab := t_varchar_tab();
        l_ok_vyroZenklai   t_varchar_tab := t_varchar_tab();

        v_any_rows BOOLEAN := FALSE;
    BEGIN
        clear_successful_marriages;

        OPEN c_santuokos FOR
            SELECT numeris, registracijosData, motersZenklas, vyroZenklas
            FROM santuoka;

        LOOP
            FETCH c_santuokos BULK COLLECT
            INTO l_numeriai, l_datos, l_motersZenklai, l_vyroZenklai
            LIMIT 100;

            EXIT WHEN l_numeriai.COUNT = 0;

            v_any_rows := TRUE;

            l_ok_numeriai.DELETE;
            l_ok_datos.DELETE;
            l_ok_motersZenklai.DELETE;
            l_ok_vyroZenklai.DELETE;

            FOR i IN 1 .. l_numeriai.COUNT LOOP
                IF is_successful_marriage(
                    l_datos(i),
                    l_motersZenklai(i),
                    l_vyroZenklai(i)
                ) THEN
                    l_ok_numeriai.EXTEND;
                    l_ok_datos.EXTEND;
                    l_ok_motersZenklai.EXTEND;
                    l_ok_vyroZenklai.EXTEND;

                    l_ok_numeriai(l_ok_numeriai.COUNT) := l_numeriai(i);
                    l_ok_datos(l_ok_datos.COUNT) := l_datos(i);
                    l_ok_motersZenklai(l_ok_motersZenklai.COUNT) := l_motersZenklai(i);
                    l_ok_vyroZenklai(l_ok_vyroZenklai.COUNT) := l_vyroZenklai(i);
                END IF;
            END LOOP;

            IF l_ok_numeriai.COUNT > 0 THEN
                FORALL i IN 1 .. l_ok_numeriai.COUNT
                    INSERT INTO sekmingaSantuoka (
                        numeris,
                        registracijosData,
                        motersZenklas,
                        vyroZenklas
                    )
                    VALUES (
                        l_ok_numeriai(i),
                        l_ok_datos(i),
                        l_ok_motersZenklai(i),
                        l_ok_vyroZenklai(i)
                    );
            END IF;
        END LOOP;

        CLOSE c_santuokos;

        IF NOT v_any_rows THEN
            errors_pkg.raise_error(errors_pkg.c_no_marriages_found);
        END IF;
    EXCEPTION
        WHEN errors_pkg.exc_no_marriages_found THEN
            errors_pkg.save_error('marriage_pkg.fill_successful_marriages');
            RAISE;
        WHEN VALUE_ERROR THEN
            errors_pkg.save_error('marriage_pkg.fill_successful_marriages');
            RAISE;
        WHEN INVALID_CURSOR THEN
            errors_pkg.save_error('marriage_pkg.fill_successful_marriages');
            RAISE;
        WHEN ROWTYPE_MISMATCH THEN
            errors_pkg.save_error('marriage_pkg.fill_successful_marriages');
            RAISE;
    END fill_successful_marriages;


    PROCEDURE save_successful_marriage(
        p_numeris           IN santuoka.numeris%TYPE,
        p_registracijosData IN santuoka.registracijosData%TYPE,
        p_motersZenklas     IN santuoka.motersZenklas%TYPE,
        p_vyroZenklas       IN santuoka.vyroZenklas%TYPE
    ) IS
    BEGIN
        IF NOT sign_exists(p_motersZenklas)
           OR NOT sign_exists(p_vyroZenklas) THEN
            errors_pkg.raise_error(errors_pkg.c_sign_not_found);
        END IF;

        IF NOT is_successful_marriage(
            p_registracijosData,
            p_motersZenklas,
            p_vyroZenklas
        ) THEN
            errors_pkg.raise_error(errors_pkg.c_unsuccessful_marriage);
        END IF;

        INSERT INTO santuoka (
            numeris,
            registracijosData,
            motersZenklas,
            vyroZenklas
        )
        VALUES (
            p_numeris,
            p_registracijosData,
            p_motersZenklas,
            p_vyroZenklas
        );

        INSERT INTO sekmingaSantuoka (
            numeris,
            registracijosData,
            motersZenklas,
            vyroZenklas
        )
        VALUES (
            p_numeris,
            p_registracijosData,
            p_motersZenklas,
            p_vyroZenklas
        );
    EXCEPTION
        WHEN errors_pkg.exc_sign_not_found THEN
            errors_pkg.save_error('marriage_pkg.save_successful_marriage');
            RAISE;
        WHEN errors_pkg.exc_unsuccessful_marriage THEN
            errors_pkg.save_error('marriage_pkg.save_successful_marriage');
            RAISE;
        WHEN VALUE_ERROR THEN
            errors_pkg.save_error('marriage_pkg.save_successful_marriage');
            RAISE;
    END save_successful_marriage;


    FUNCTION delete_unsuccessful_marriages
    RETURN PLS_INTEGER IS
        c_santuokos SYS_REFCURSOR;

        l_numeriai      t_number_tab;
        l_datos         t_date_tab;
        l_motersZenklai t_varchar_tab;
        l_vyroZenklai   t_varchar_tab;

        l_delete_ids              t_number_tab := t_number_tab();
        l_deleted_santuoka_ids    t_number_tab := t_number_tab();
        l_deleted_successful_ids  t_number_tab := t_number_tab();

        v_any_rows      BOOLEAN := FALSE;
        v_deleted_count PLS_INTEGER := 0;
    BEGIN
        OPEN c_santuokos FOR
            SELECT numeris, registracijosData, motersZenklas, vyroZenklas
            FROM santuoka;

        LOOP
            FETCH c_santuokos BULK COLLECT
            INTO l_numeriai, l_datos, l_motersZenklai, l_vyroZenklai
            LIMIT 100;

            EXIT WHEN l_numeriai.COUNT = 0;

            v_any_rows := TRUE;
            l_delete_ids.DELETE;

            FOR i IN 1 .. l_numeriai.COUNT LOOP
                IF NOT is_successful_marriage(
                    l_datos(i),
                    l_motersZenklai(i),
                    l_vyroZenklai(i)
                ) THEN
                    l_delete_ids.EXTEND;
                    l_delete_ids(l_delete_ids.COUNT) := l_numeriai(i);
                END IF;
            END LOOP;

            IF l_delete_ids.COUNT > 0 THEN
                l_deleted_successful_ids.DELETE;

                FORALL i IN 1 .. l_delete_ids.COUNT
                    DELETE FROM sekmingaSantuoka
                    WHERE numeris = l_delete_ids(i)
                    RETURNING numeris BULK COLLECT INTO l_deleted_successful_ids;

                l_deleted_santuoka_ids.DELETE;

                FORALL i IN 1 .. l_delete_ids.COUNT
                    DELETE FROM santuoka
                    WHERE numeris = l_delete_ids(i)
                    RETURNING numeris BULK COLLECT INTO l_deleted_santuoka_ids;

                v_deleted_count := v_deleted_count + l_deleted_santuoka_ids.COUNT;
            END IF;
        END LOOP;

        CLOSE c_santuokos;

        IF NOT v_any_rows THEN
            errors_pkg.raise_error(errors_pkg.c_no_marriages_found);
        END IF;

        DBMS_OUTPUT.PUT_LINE('Is santuoka pasalinta: ' || v_deleted_count);
        DBMS_OUTPUT.PUT_LINE('Is sekmingaSantuoka pasalinta: ' || l_deleted_successful_ids.COUNT);

        RETURN v_deleted_count;
    EXCEPTION
        WHEN errors_pkg.exc_no_marriages_found THEN
            errors_pkg.save_error('marriage_pkg.delete_unsuccessful_marriages');
            RAISE;
        WHEN VALUE_ERROR THEN
            errors_pkg.save_error('marriage_pkg.delete_unsuccessful_marriages');
            RAISE;
        WHEN INVALID_CURSOR THEN
            errors_pkg.save_error('marriage_pkg.delete_unsuccessful_marriages');
            RAISE;
    END delete_unsuccessful_marriages;
END marriage_pkg;
/

-- 
DECLARE
    v_deleted_count PLS_INTEGER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testavimmas');

    marriage_pkg.fill_successful_marriages;
    DBMS_OUTPUT.PUT_LINE('Sekmingos santuokos uzpildytos.');

    marriage_pkg.save_successful_marriage(
        p_numeris           => 12,
        p_registracijosData => DATE '2024-10-10',
        p_motersZenklas     => 'Jautis',
        p_vyroZenklas       => 'Avinas'
    );
    DBMS_OUTPUT.PUT_LINE('Issaugota viena sekminga santuoka.');

    v_deleted_count := marriage_pkg.delete_unsuccessful_marriages;
    DBMS_OUTPUT.PUT_LINE('Is viso pasalinta nesekmingu santuoku: ' || v_deleted_count);

    BEGIN
        marriage_pkg.save_successful_marriage(
            p_numeris           => 13,
            p_registracijosData => DATE '2025-01-10',
            p_motersZenklas     => 'Avinas',
            p_vyroZenklas       => 'Saulys'
        );
    EXCEPTION
        WHEN errors_pkg.exc_unsuccessful_marriage THEN
            DBMS_OUTPUT.PUT_LINE('Patikrinta klaida -20001: santuoka nera sekminga.');
    END;

    BEGIN
        marriage_pkg.save_successful_marriage(
            p_numeris           => 14,
            p_registracijosData => DATE '2024-01-01',
            p_motersZenklas     => 'Nezinomas',
            p_vyroZenklas       => 'Avinas'
        );
    EXCEPTION
        WHEN errors_pkg.exc_sign_not_found THEN
            DBMS_OUTPUT.PUT_LINE('Patikrinta klaida -20002: zodiako zenklas neegzistuoja.');
    END;

    DELETE FROM sekmingaSantuoka;
    DELETE FROM santuoka;

    BEGIN
        marriage_pkg.fill_successful_marriages;
    EXCEPTION
        WHEN errors_pkg.exc_no_marriages_found THEN
            DBMS_OUTPUT.PUT_LINE('Patikrinta klaida -20003: santuoku lenteleje nera duomenu.');
    END;

    INSERT INTO santuoka VALUES (1, DATE '2024-06-10', 'Jautis', 'Avinas');
    INSERT INTO santuoka VALUES (2, DATE '2025-07-15', 'Vezys', 'Jautis');
    INSERT INTO santuoka VALUES (3, DATE '2026-03-20', 'Mergele', 'Liutas');
    INSERT INTO santuoka VALUES (5, DATE '2025-11-12', 'Liutas', 'Skorpionas');
    INSERT INTO santuoka VALUES (6, DATE '2023-05-18', 'Zuvys', 'Dvyniai');
    INSERT INTO santuoka VALUES (7, DATE '2025-01-10', 'Avinas', 'Saulys');

    BEGIN
        marriage_pkg.fill_successful_marriages;
    END;
    
    
    DBMS_OUTPUT.PUT_LINE('Pabaiga');
END;
/

SPOOL OFF
