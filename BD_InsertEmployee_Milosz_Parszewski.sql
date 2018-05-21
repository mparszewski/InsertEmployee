create or replace PROCEDURE InsertEmployee (p_first_name IN VARCHAR2,
                                            p_last_name IN VARCHAR2,
                                            p_email IN VARCHAR2,
                                            p_phone_number IN VARCHAR2,
                                            p_hire_date IN DATE,
                                            p_job_id IN VARCHAR2,
                                            p_salary IN NUMBER,
                                            p_commission_PCT IN NUMBER,
                                            p_manager_id IN NUMBER,
                                            p_department_id IN NUMBER) IS
                                 
    v_employee_id NUMBER;
    v_manager NUMBER;
    v_department NUMBER;
    v_job VARCHAR2 (10 BYTE);
    v_min_salary NUMBER;
    v_max_salary NUMBER;
    v_days_between NUMBER;
    
    NULL_EXCEPTION EXCEPTION;
    MANAGER_NOT_FOUND_EXCEPTION EXCEPTION;
    DEPARTMENT_NOT_FOUND_EXCEPTION EXCEPTION;
    JOB_NOT_FOUND_EXCEPTION EXCEPTION;
    SALARY_OUT_OF_SCOPE_EXCEPTION EXCEPTION;
    FUTURE_DATE_EXCEPTION EXCEPTION;
    PHONE_NUMBER_PATTERN_EXCEPTION EXCEPTION;
    
BEGIN
    -- WARUNKI DO STAWIANIA WYJATKU
    
    -- 1. STAWIANIE WYJATKU NIE PODANIA WARTO�CI NULL DLA POLA Z WARUNKIEM NOT NULL 
    IF p_last_name IS NULL OR p_email IS NULL OR p_hire_date IS NULL OR p_job_id IS NULL THEN
        RAISE NULL_EXCEPTION;
    END IF;
    
    -- 2. STAWIANIE WYJATKU NIEWLASCIWEEGO LUB NIE ISTNIEJACEGO KODU MANAGERA (PRZELOZONEGO)
    IF p_manager_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_manager FROM EMPLOYEES
        WHERE EMPLOYEE_ID = p_manager_id;
    END IF;
    
    IF p_manager_id IS NULL OR v_manager = 0 THEN
        RAISE MANAGER_NOT_FOUND_EXCEPTION;
    END IF;
    
    -- 3. STAWIANIE WYJATKU NIEISTNIEJACEGO KODU DEPARTAMENTU
    IF p_department_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_department FROM DEPARTMENTS
        WHERE DEPARTMENT_ID = p_department_id;
    END IF;
    
    IF p_department_id IS NULL OR v_department = 0 THEN
        RAISE DEPARTMENT_NOT_FOUND_EXCEPTION;
    END IF;
    
    -- 4. STAWIANIE WYJATKU NIEISTNIEJACEGO KODU 
    IF p_job_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_job FROM JOBS
        WHERE JOB_ID = p_job_id;
    END IF;
    
    IF p_job_id IS NULL OR v_job = 0 THEN
        RAISE JOB_NOT_FOUND_EXCEPTION;
    END IF;

    -- 5. STAWIANIE WYJATKU PENSJI SPOZA ZAKRESU PRZYSLUGUJACEGO WYNAGRODZENIA DLA ZAJMOWANEGO STANOWISKA
    SELECT MIN_SALARY, MAX_SALARY INTO v_min_salary, v_max_salary
    FROM JOBS
    WHERE JOB_ID = p_job_id;
    
    IF p_salary > v_max_salary OR p_salary < v_min_salary THEN 
        RAISE SALARY_OUT_OF_SCOPE_EXCEPTION;
    END IF;
    
    -- 6. STAWIANIE WYJATKU PRZYSZLEJ DATY ZATRUDNIENIA
    SELECT SYSDATE - p_hire_date INTO v_days_between
    FROM DUAL;
    
    IF v_days_between < 0 THEN
        RAISE FUTURE_DATE_EXCEPTION;
    END IF;
    
    -- 7. STAWIANIE WYJATKU NUMERU TELEOFNU NIE PASUJACEGO DO WZORCA
    IF p_phone_number NOT LIKE '%%%.%%%.%%%%' AND p_phone_number NOT LIKE '%%%.%%.%%%%.%%%%%%' THEN
        RAISE PHONE_NUMBER_PATTERN_EXCEPTION;
    END IF;

    INSERT INTO EMPLOYEES (EMPLOYEE_ID,
                           FIRST_NAME,
                           LAST_NAME,
                           EMAIL,
                           PHONE_NUMBER,
                           HIRE_DATE,
                           JOB_ID,
                           SALARY,
                           COMMISSION_PCT,
                           MANAGER_ID,
                           DEPARTMENT_ID)
    VALUES (SEQ_EMPLOYEE_ID.NEXTVAL,
            p_first_name,
            p_last_name,
            p_email,
            p_phone_number,
            p_hire_date,
            p_job_id,
            p_salary,
            p_commission_pct,
            p_manager_id,
            p_department_id);

EXCEPTION 
    WHEN NULL_EXCEPTION THEN
        RAISE_APPLICATION_ERROR (-20099, 'Nie podano warto�ci dla pola NOT NULL');
    WHEN MANAGER_NOT_FOUND_EXCEPTION THEN
        RAISE_APPLICATION_ERROR (-20098, 'Podano bledy numer przelozonego');
    WHEN DEPARTMENT_NOT_FOUND_EXCEPTION THEN
        RAISE_APPLICATION_ERROR (-20097, 'Podano niewla�ciwe ID departamentu');
    WHEN JOB_NOT_FOUND_EXCEPTION THEN
        RAISE_APPLICATION_ERROR (-20096, 'Podano niewla�ciwe ID zawodu');
    WHEN SALARY_OUT_OF_SCOPE_EXCEPTION THEN
        RAISE_APPLICATION_ERROR (-20095, 'Podano warto�� zarobk�w przekraczajaca zakres przysluigujacy na wskazanym stanowisku');
    WHEN FUTURE_DATE_EXCEPTION THEN
        RAISE_APPLICATION_ERROR (-20094, 'Podano przyszla dat� zatrudnienia');
    WHEN PHONE_NUMBER_PATTERN_EXCEPTION THEN
        RAISE_APPLICATION_ERROR (-20093, 'Podano numer telefonu nie pasujacy do szablonu');
        

END;
/
SHOW ERROR;