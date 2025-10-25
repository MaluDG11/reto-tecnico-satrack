
-- ==========================================================
-- Script SQL 
-- Prueba Consulta SQL_Empresa_de_Monitoreo_Satelital_GeoTrack
-- Requerimientos 2.1 a 2.10
-- Fecha: [25/10/2025]
-- Analista: Marta David Gallego
-- ==========================================================

-- =================================================
-- Velocidad promedio por vehículo (últimos 30 días)
-- =================================================

SELECT 
    d.vehicle_plate,
    AVG(p.speed) AS Velocidad_promedio
FROM positions p
JOIN devices d ON p.device_id = d.device_id
WHERE p.recorded_at >= DATEADD(DAY, -30, GETDATE())
GROUP BY d.vehicle_plate
ORDER BY velocidad_promedio DESC;

-- =================================================
-- Clientes con dispositivos inactivos
-- =================================================

SELECT 
    c.name AS Nombre_cliente,
    COUNT(d.device_id) AS Dispositivos_inactivos
FROM clients c
JOIN devices d ON c.client_id = d.client_id
WHERE d.status = 'inactive'
GROUP BY c.name
HAVING COUNT(d.device_id) >= 1;


-- =================================================
-- Última posición de cada vehículo
-- =================================================
SELECT 
    d.vehicle_plate AS Placa_Vehiculo,
    p.longitude AS Latitud,
    p.latitude AS Longitud,
    p.recorded_at AS Fecha
FROM devices d
JOIN positions p ON d.device_id = p.device_id
WHERE p.recorded_at = (
    SELECT MAX(p2.recorded_at)
    FROM positions p2
    WHERE p2.device_id = d.device_id
);
-- =========================================================================
-- Vehículos con múltiples alertas de exceso de velocidad (últimos 7 días)
-- =========================================================================

SELECT 
    d.vehicle_plate AS Placa_Vehiculo,
    COUNT(a.alert_id) AS Alertas_exceso_velocidad
FROM alerts a
JOIN devices d ON a.device_id = d.device_id
WHERE a.alert_type = 'Overspeed'
  AND a.created_at >= DATEADD(DAY, -7, GETDATE())
GROUP BY d.vehicle_plate
HAVING COUNT(a.alert_id) > 2;
---------------------------------------------------

---tipos de alertas que existen
SELECT DISTINCT alert_type FROM alerts;


SELECT * FROM alerts;


--- Todos los vehículos que han tenido al menos una alerta de exceso de velocidad
SELECT 
    d.vehicle_plate AS Placa_Vehiculo,
    COUNT(a.alert_id) AS Alertas_exceso_velocidad
FROM alerts a
JOIN devices d ON a.device_id = d.device_id
WHERE a.alert_type = 'Overspeed'
GROUP BY d.vehicle_plate
HAVING COUNT(a.alert_id) > 0;

-- =================================================
-- Vehículos sin reporte en 24 horas
-- =================================================

SELECT 
    d.vehicle_plate AS Placa_Vehiculo,
    MAX(p.recorded_at) AS Ultimo_reporte
FROM devices d
LEFT JOIN positions p ON d.device_id = p.device_id
GROUP BY d.vehicle_plate
HAVING MAX(p.recorded_at) < DATEADD(HOUR, -24, GETDATE()) 
       OR MAX(p.recorded_at) IS NULL;


-- =================================================
-- Tiempo promedio entre reportes (en minutos)
-- =================================================

WITH diffs AS (
    SELECT 
        device_id,
        DATEDIFF(MINUTE, 
                 LAG(recorded_at) OVER(PARTITION BY device_id ORDER BY recorded_at),
                 recorded_at) AS diferencia_minutos
    FROM positions
)
SELECT 
    d.vehicle_plate AS Placa_Vehiculo,
    AVG(diffs.diferencia_minutos) AS promedio_de_minutos_entre_informes
FROM diffs
JOIN devices d ON diffs.device_id = d.device_id
WHERE diffs.diferencia_minutos IS NOT NULL
GROUP BY d.vehicle_plate ;



-- =================================================
-- Top 3 clientes con más alertas en 30 días
-- =================================================
SELECT TOP 3
    c.name AS Nombre_del_cliente,
    COUNT(a.alert_id) AS Cantidad_de_alertas
FROM alerts a
JOIN devices d ON a.device_id = d.device_id
JOIN clients c ON d.client_id = c.client_id
WHERE a.created_at >= DATEADD(DAY, -30, GETDATE())
GROUP BY c.name
ORDER BY Cantidad_de_alertas DESC;


-- =======================================================
-- Velocidades >100 km/h sin alerta Overspeed ±10 min
-- =======================================================

------------- Con alertas Overspeed >100 km/h -------------

SELECT 
    d.vehicle_plate AS Placa_Vehiculo,
    p.latitude AS Latitud,
    p.longitude AS Longitud,
    p.speed AS Velocidad,
    p.recorded_at AS Fecha_de_registro,
    a.alert_type AS Tipo_Alerta,
    a.description AS Alerta
FROM positions p
JOIN devices d ON p.device_id = d.device_id
LEFT JOIN alerts a 
    ON a.device_id = p.device_id
   AND a.alert_type = 'Overspeed'
   AND a.created_at BETWEEN DATEADD(MINUTE, -10, p.recorded_at)
                         AND DATEADD(MINUTE, 10, p.recorded_at)
WHERE p.speed > 100;

-------------Sin alertas Overspeed ±10 min -------------

SELECT 
 
    d.vehicle_plate AS Placa_Vehiculo,
    p.longitude AS Latitud,
    p.latitude AS Longitud,
    p.speed AS Velocidad,
    p.recorded_at As Fecha_de_registro
FROM positions p
JOIN devices d ON p.device_id = d.device_id
WHERE p.speed > 100
  AND NOT EXISTS (
      SELECT 1
      FROM alerts a
      WHERE a.device_id = p.device_id
        AND a.alert_type = 'Overspeed'
        AND a.created_at BETWEEN DATEADD(MINUTE, -10, p.recorded_at)
                              AND DATEADD(MINUTE, 10, p.recorded_at)
  );


-- =================================================
-- Tiempo desde el último reporte (en horas)
-- =================================================

SELECT 
    d.vehicle_plate AS Placa_Vehiculo,
    DATEDIFF(HOUR, MAX(p.recorded_at), GETDATE()) AS horas_desde_el_último_reporte
FROM devices d
LEFT JOIN positions p ON d.device_id = p.device_id
GROUP BY d.vehicle_plate;


-- =================================================
-- Vehículo más activo por cliente (últimos 30 días)
-- =================================================

WITH counts AS (
    SELECT 
        d.client_id,
        d.vehicle_plate,
        COUNT(p.position_id) AS cantidad_posiciones
    FROM positions p
    JOIN devices d ON p.device_id = d.device_id
    WHERE p.recorded_at >= DATEADD(DAY, -30, GETDATE())
    GROUP BY d.client_id, d.vehicle_plate
)
SELECT 
    c.name AS nombre_cliente, 
    cts.vehicle_plate AS placa_vehiculo, 
    cts.cantidad_posiciones
FROM (
    SELECT 
        client_id, 
        vehicle_plate, 
        cantidad_posiciones,
        ROW_NUMBER() OVER(PARTITION BY client_id ORDER BY cantidad_posiciones DESC) AS rn
    FROM counts
) cts
JOIN clients c ON cts.client_id = c.client_id
WHERE cts.rn = 1;