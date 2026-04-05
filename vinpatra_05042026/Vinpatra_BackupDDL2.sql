create or replace PACKAGE XX_Vinpatra_AUDIT_PKG AS

    PROCEDURE LOG_CHANGE (
        p_table_name   VARCHAR2,
        p_column_name  VARCHAR2,
        p_pk           VARCHAR2,
        p_old          VARCHAR2,
        p_new          VARCHAR2,
        p_action       VARCHAR2
    );

    FUNCTION IS_AUDIT_ENABLED (
        p_table_name  VARCHAR2,
        p_column_name VARCHAR2
    ) RETURN BOOLEAN;

END;
/



create or replace PACKAGE BODY XX_Vinpatra_AUDIT_PKG AS

    FUNCTION IS_AUDIT_ENABLED (
        p_table_name  VARCHAR2,
        p_column_name VARCHAR2
    ) RETURN BOOLEAN
    IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM XX_Vinpatra_AUDIT_CONFIG
        WHERE TABLE_NAME = UPPER(p_table_name)
          AND COLUMN_NAME = UPPER(p_column_name)
          AND AUDIT_YN = 'Y';

        RETURN v_count > 0;
    END;

    PROCEDURE LOG_CHANGE (
        p_table_name   VARCHAR2,
        p_column_name  VARCHAR2,
        p_pk           VARCHAR2,
        p_old          VARCHAR2,
        p_new          VARCHAR2,
        p_action       VARCHAR2
    )
    IS
    BEGIN
        INSERT INTO XX_Vinpatra_AUDIT_LOG (
            TABLE_NAME,
            COLUMN_NAME,
            PK_VALUE,
            OLD_VALUE,
            NEW_VALUE,
            ACTION_TYPE,
            CHANGED_BY,
            CHANGED_DATE,
            SESSION_ID,
            MODULE
        )
        VALUES (
            p_table_name,
            p_column_name,
            p_pk,
            p_old,
            p_new,
            p_action,
            NVL(V('APP_USER'), USER),
            SYSDATE,
            V('APP_SESSION'),
            V('APP_ID')
        );
    END;

END;
/