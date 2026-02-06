CREATE OR ALTER FUNCTION dbo.fn_EstadoEstudiante(
    @M12CAR VARCHAR(20),   -- Carnet del estudiante
    @M01COD VARCHAR(10),   -- Facultad
    @M02COD VARCHAR(10),   -- Carrera
    @M03COD VARCHAR(10),   -- Énfasis
    @M04COD VARCHAR(10)    -- Plan de estudios
)
RETURNS VARCHAR(2)
AS
BEGIN
    DECLARE @resultado VARCHAR(2) = 'IS'
    DECLARE @tipoPeriodo INT
    DECLARE @anioActual INT = YEAR(GETDATE())
    DECLARE @mesActual INT = MONTH(GETDATE())
    DECLARE @seqActual INT
    DECLARE @seqMinimo INT

    -- Obtener el tipo de periodo a partir del registro más reciente
    -- del estudiante en la carrera especificada
    SELECT TOP 1 @tipoPeriodo = M19COD
    FROM M33ARC
    WHERE M12CAR = @M12CAR
      AND M01COD = @M01COD
      AND M02COD = @M02COD
      AND M03COD = @M03COD
      AND M04COD = @M04COD
    ORDER BY M18COD DESC, M19COD DESC

    -- Si no tiene registros, se considera inactivo
    IF @tipoPeriodo IS NULL
        RETURN 'IS'

    ---------------------------------------------------------------------------
    -- CUATRIMESTRAL (periodos 1, 2, 3) — 3 periodos por año
    -- Inactivo si no registra matrícula en los últimos 3 periodos
    ---------------------------------------------------------------------------
    IF @tipoPeriodo IN (1, 2, 3)
    BEGIN
        -- Posición actual: mes 1-4 → 1, mes 5-8 → 2, mes 9-12 → 3
        SET @seqActual = @anioActual * 3 + CEILING(CAST(@mesActual AS DECIMAL) / 4.0)
        SET @seqMinimo = @seqActual - 3 + 1

        IF EXISTS (
            SELECT 1 FROM M33ARC
            WHERE M12CAR = @M12CAR AND M01COD = @M01COD AND M02COD = @M02COD
              AND M03COD = @M03COD AND M04COD = @M04COD
              AND M19COD IN (1, 2, 3)
              AND (M18COD * 3 + M19COD) BETWEEN @seqMinimo AND @seqActual
        )
            SET @resultado = 'AS'
    END

    ---------------------------------------------------------------------------
    -- TRIMESTRAL (periodos 5, 6, 7, 8) — 4 periodos por año
    -- Inactivo si no registra matrícula en los últimos 4 periodos
    ---------------------------------------------------------------------------
    ELSE IF @tipoPeriodo IN (5, 6, 7, 8)
    BEGIN
        -- Posición actual: mes 1-3 → 1, mes 4-6 → 2, mes 7-9 → 3, mes 10-12 → 4
        SET @seqActual = @anioActual * 4 + CEILING(CAST(@mesActual AS DECIMAL) / 3.0)
        SET @seqMinimo = @seqActual - 4 + 1

        IF EXISTS (
            SELECT 1 FROM M33ARC
            WHERE M12CAR = @M12CAR AND M01COD = @M01COD AND M02COD = @M02COD
              AND M03COD = @M03COD AND M04COD = @M04COD
              AND M19COD IN (5, 6, 7, 8)
              AND (M18COD * 4 + (M19COD - 4)) BETWEEN @seqMinimo AND @seqActual
        )
            SET @resultado = 'AS'
    END

    ---------------------------------------------------------------------------
    -- BIMENSUAL (periodos 60, 61, 62, 63, 64, 65) — 6 periodos por año
    -- Inactivo si no registra matrícula en los últimos 6 periodos
    ---------------------------------------------------------------------------
    ELSE IF @tipoPeriodo IN (60, 61, 62, 63, 64, 65)
    BEGIN
        -- Posición actual: mes 1-2 → 1, mes 3-4 → 2, ..., mes 11-12 → 6
        SET @seqActual = @anioActual * 6 + CEILING(CAST(@mesActual AS DECIMAL) / 2.0)
        SET @seqMinimo = @seqActual - 6 + 1

        IF EXISTS (
            SELECT 1 FROM M33ARC
            WHERE M12CAR = @M12CAR AND M01COD = @M01COD AND M02COD = @M02COD
              AND M03COD = @M03COD AND M04COD = @M04COD
              AND M19COD IN (60, 61, 62, 63, 64, 65)
              AND (M18COD * 6 + (M19COD - 59)) BETWEEN @seqMinimo AND @seqActual
        )
            SET @resultado = 'AS'
    END

    ---------------------------------------------------------------------------
    -- BIMENSUAL (periodos 31, 33, 35, 37, 39, 41) — 6 periodos por año
    -- Inactivo si no registra matrícula en los últimos 6 periodos
    ---------------------------------------------------------------------------
    ELSE IF @tipoPeriodo IN (31, 33, 35, 37, 39, 41)
    BEGIN
        SET @seqActual = @anioActual * 6 + CEILING(CAST(@mesActual AS DECIMAL) / 2.0)
        SET @seqMinimo = @seqActual - 6 + 1

        IF EXISTS (
            SELECT 1 FROM M33ARC
            WHERE M12CAR = @M12CAR AND M01COD = @M01COD AND M02COD = @M02COD
              AND M03COD = @M03COD AND M04COD = @M04COD
              AND M19COD IN (31, 33, 35, 37, 39, 41)
              AND (M18COD * 6 + (M19COD - 31) / 2 + 1) BETWEEN @seqMinimo AND @seqActual
        )
            SET @resultado = 'AS'
    END

    ---------------------------------------------------------------------------
    -- BIMENSUAL (periodos 80, 81, 82, 83, 84, 85) — 6 periodos por año
    -- Inactivo si no registra matrícula en los últimos 6 periodos
    ---------------------------------------------------------------------------
    ELSE IF @tipoPeriodo IN (80, 81, 82, 83, 84, 85)
    BEGIN
        SET @seqActual = @anioActual * 6 + CEILING(CAST(@mesActual AS DECIMAL) / 2.0)
        SET @seqMinimo = @seqActual - 6 + 1

        IF EXISTS (
            SELECT 1 FROM M33ARC
            WHERE M12CAR = @M12CAR AND M01COD = @M01COD AND M02COD = @M02COD
              AND M03COD = @M03COD AND M04COD = @M04COD
              AND M19COD IN (80, 81, 82, 83, 84, 85)
              AND (M18COD * 6 + (M19COD - 79)) BETWEEN @seqMinimo AND @seqActual
        )
            SET @resultado = 'AS'
    END

    ---------------------------------------------------------------------------
    -- MENSUAL (periodos 11..22) — 12 periodos por año
    -- Inactivo si no registra matrícula en los últimos 12 periodos
    ---------------------------------------------------------------------------
    ELSE IF @tipoPeriodo IN (11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22)
    BEGIN
        -- Posición actual: mes directamente (1-12)
        SET @seqActual = @anioActual * 12 + @mesActual
        SET @seqMinimo = @seqActual - 12 + 1

        IF EXISTS (
            SELECT 1 FROM M33ARC
            WHERE M12CAR = @M12CAR AND M01COD = @M01COD AND M02COD = @M02COD
              AND M03COD = @M03COD AND M04COD = @M04COD
              AND M19COD IN (11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22)
              AND (M18COD * 12 + (M19COD - 10)) BETWEEN @seqMinimo AND @seqActual
        )
            SET @resultado = 'AS'
    END

    ---------------------------------------------------------------------------
    -- ANUAL (periodo 52) — 1 periodo por año
    -- Inactivo si no registra matrícula en el último periodo
    ---------------------------------------------------------------------------
    ELSE IF @tipoPeriodo = 52
    BEGIN
        IF EXISTS (
            SELECT 1 FROM M33ARC
            WHERE M12CAR = @M12CAR AND M01COD = @M01COD AND M02COD = @M02COD
              AND M03COD = @M03COD AND M04COD = @M04COD
              AND M19COD = 52
              AND M18COD = @anioActual
        )
            SET @resultado = 'AS'
    END

    RETURN @resultado
END
GO
