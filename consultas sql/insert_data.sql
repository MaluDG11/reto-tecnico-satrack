
-- =================================================
-- USAR BD
-- =================================================

USE GeoTrack;
GO

-- =================================================
-- CREAR TABLAS
-- =================================================

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at DATE NOT NULL
);

-- =================================================
-- INSERTAR DATOS EN clients
-- =================================================

INSERT INTO clients (client_id, name, email, created_at)
VALUES
(1, 'Transporte Andino', 'contacto@andino.com', '2024-01-10'),
(2, 'Logística Express', 'info@express.com', '2024-02-15'),
(3, 'Rutas del Café', 'rutas@cafe.com', '2024-03-01');

-- =================================================
-- INSERTAR DATOS EN devices
-- =================================================
INSERT INTO devices (device_id, client_id, imei, vehicle_plate, status)
VALUES
(1, 1, '12345678901', 'ABC123', 'active'),
(2, 1, '98765432109', 'XYZ789', 'active'),
(3, 2, '55566677788', 'LMN456', 'inactive'),
(4, 3, '00011122233', 'CAF321', 'active');

-- =================================================
-- INSERTAR DATOS EN positions
-- Usamos fechas relativas con DATEADD para las que indican "X horas/días antes de hoy"
-- =================================================
INSERT INTO positions (position_id, device_id, latitude, longitude, speed, recorded_at)
VALUES
(1, 1, 5.070000, -75.520000, 60.5, '2024-04-01 08:30:00'),
(2, 1, 5.072000, -75.522000, 82.0, '2024-04-01 08:45:00'),
(3, 1, 5.075000, -75.525000, 40.0, DATEADD(DAY, -5, GETDATE())),     -- 5 días antes de hoy
(4, 2, 5.080000, -75.530000, 0.0, '2024-04-01 09:00:00'),
(5, 2, 5.081500, -75.531000, 10.0, DATEADD(HOUR, -30, GETDATE())),   -- 30 horas antes de hoy
(6, 3, 5.100000, -75.540000, 45.0, '2024-04-01 09:15:00'),
(7, 4, 5.115000, -75.545000, 65.0, DATEADD(HOUR, -1, GETDATE())),    -- 1 hora antes de hoy
(8, 4, 5.118000, -75.548000, 110.0, DATEADD(HOUR, -2, GETDATE()));   -- 2 horas antes de hoy

-- =================================================
-- INSERTAR DATOS EN alerts
-- =================================================
INSERT INTO alerts (alert_id, device_id, alert_type, description, created_at)
VALUES
(1, 1, 'Overspeed', 'Velocidad mayor a 80 km/h', '2024-04-01 08:46:00'),
(2, 2, 'NoSignal', 'Dispositivo sin señal por 30 min', '2024-04-01 09:30:00'),
(3, 4, 'Overspeed', 'Exceso de velocidad en autopista', DATEADD(HOUR, -2, GETDATE())),
(4, 4, 'Overspeed', 'Reincidencia exceso velocidad', DATEADD(HOUR, -20, GETDATE())),
(5, 4, 'Geofence', 'Salida de zona permitida', DATEADD(DAY, -2, GETDATE())),
(6, 1, 'NoSignal', 'Sin reporte 24h', DATEADD(DAY, -3, GETDATE()));