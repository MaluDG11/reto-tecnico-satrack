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

CREATE TABLE devices (
    device_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    imei VARCHAR(20) NOT NULL,
    vehicle_plate VARCHAR(10) NOT NULL,
    status VARCHAR(10) NOT NULL
);

CREATE TABLE positions (
    position_id INT PRIMARY KEY,
    device_id INT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    speed DECIMAL(6,1) NOT NULL,
    recorded_at DATETIME NOT NULL,
    CONSTRAINT FK_positions_devices FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

CREATE TABLE alerts (
    alert_id INT PRIMARY KEY,
    device_id INT NOT NULL,
    alert_type VARCHAR(30) NOT NULL,
    description VARCHAR(200) NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT FK_alerts_devices FOREIGN KEY (device_id) REFERENCES devices(device_id)
);