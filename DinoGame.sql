-- Crear la base de datos DinoGame
CREATE DATABASE DinoGame;
GO

-- Usar la base de datos
USE DinoGame;
GO

-- Crear tabla de Usuarios
CREATE TABLE Usuarios (
    idUsuario INT IDENTITY(1,1) PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    correo VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    fechaRegistro DATETIME DEFAULT GETDATE()
);
GO

-- Crear tabla de Partidas
CREATE TABLE Partidas (
    idPartida INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario INT NOT NULL,
    puntuacion INT NOT NULL,
    tiempoJugado INT NOT NULL,
    fechaPartida DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Partidas_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario)
);
GO

-- Crear tabla de Logros
CREATE TABLE Logros (
    idLogro INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);
GO

-- Crear tabla de Logros de Usuario
CREATE TABLE UsuarioLogros (
    idUsuarioLogro INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario INT NOT NULL,
    idLogro INT NOT NULL,
    fechaObtenido DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UsuarioLogros_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario),
    CONSTRAINT FK_UsuarioLogros_Logros FOREIGN KEY (idLogro) REFERENCES Logros(idLogro),
    CONSTRAINT UC_UsuarioLogro UNIQUE (idUsuario, idLogro)
);
GO

-- Insertar logros predeterminados
INSERT INTO Logros (nombre, descripcion) VALUES 
('Primera partida', 'Completar tu primera partida'),
('Puntuación 100', 'Alcanzar 100 puntos en una partida'),
('Puntuación 500', 'Alcanzar 500 puntos en una partida'),
('Puntuación 1000', 'Alcanzar 1000 puntos en una partida'),
('Experto', 'Alcanzar 2000 puntos en una partida');
GO

-- Crear índices para mejorar el rendimiento
CREATE INDEX IX_Usuarios_Usuario ON Usuarios(usuario);
CREATE INDEX IX_Usuarios_Correo ON Usuarios(correo);
CREATE INDEX IX_Partidas_IdUsuario ON Partidas(idUsuario);
CREATE INDEX IX_Partidas_Puntuacion ON Partidas(puntuacion DESC);
CREATE INDEX IX_UsuarioLogros_IdUsuario ON UsuarioLogros(idUsuario);
GO

-- Procedimientos almacenados para operaciones comunes

-- Procedimiento para registrar usuario
CREATE PROCEDURE sp_RegistrarUsuario
    @usuario VARCHAR(50),
    @correo VARCHAR(100),
    @contrasena VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        INSERT INTO Usuarios (usuario, correo, contrasena)
        VALUES (@usuario, @correo, @contrasena);
        
        SELECT SCOPE_IDENTITY() as idUsuario, @usuario as usuario;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrorMessage, 1;
    END CATCH
END;
GO

-- Procedimiento para login de usuario
CREATE PROCEDURE sp_LoginUsuario
    @usuario VARCHAR(50),
    @contrasena VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT idUsuario, usuario 
    FROM Usuarios 
    WHERE usuario = @usuario AND contrasena = @contrasena;
END;
GO

-- Procedimiento para guardar partida
CREATE PROCEDURE sp_GuardarPartida
    @idUsuario INT,
    @puntuacion INT,
    @tiempoJugado INT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Partidas (idUsuario, puntuacion, tiempoJugado)
    VALUES (@idUsuario, @puntuacion, @tiempoJugado);
    
    SELECT SCOPE_IDENTITY() as idPartida;
END;
GO

-- Procedimiento para obtener leaderboard
CREATE PROCEDURE sp_ObtenerLeaderboard
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 10 
        u.usuario, 
        MAX(p.puntuacion) as max_score
    FROM Partidas p
    INNER JOIN Usuarios u ON p.idUsuario = u.idUsuario
    GROUP BY u.usuario
    ORDER BY max_score DESC;
END;
GO

-- Procedimiento para obtener logros de usuario
CREATE PROCEDURE sp_ObtenerLogrosUsuario
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        l.nombre, 
        l.descripcion
    FROM UsuarioLogros ul
    INNER JOIN Logros l ON ul.idLogro = l.idLogro
    WHERE ul.idUsuario = @idUsuario
    ORDER BY ul.fechaObtenido DESC;
END;
GO

-- Procedimiento para verificar y asignar logros
CREATE PROCEDURE sp_VerificarLogros
    @idUsuario INT,
    @puntuacion INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @partidasCount INT;
    
    -- Contar partidas del usuario
    SELECT @partidasCount = COUNT(*) 
    FROM Partidas 
    WHERE idUsuario = @idUsuario;
    
    -- Asignar logro de primera partida
    IF @partidasCount = 1
    BEGIN
        MERGE INTO UsuarioLogros AS target
        USING (VALUES (@idUsuario, 1)) AS source (idUsuario, idLogro)
        ON target.idUsuario = source.idUsuario AND target.idLogro = source.idLogro
        WHEN NOT MATCHED THEN INSERT (idUsuario, idLogro) VALUES (source.idUsuario, source.idLogro);
    END
    
    -- Asignar logros por puntuación
    IF @puntuacion >= 100
    BEGIN
        MERGE INTO UsuarioLogros AS target
        USING (VALUES (@idUsuario, 2)) AS source (idUsuario, idLogro)
        ON target.idUsuario = source.idUsuario AND target.idLogro = source.idLogro
        WHEN NOT MATCHED THEN INSERT (idUsuario, idLogro) VALUES (source.idUsuario, source.idLogro);
    END
    
    IF @puntuacion >= 500
    BEGIN
        MERGE INTO UsuarioLogros AS target
        USING (VALUES (@idUsuario, 3)) AS source (idUsuario, idLogro)
        ON target.idUsuario = source.idUsuario AND target.idLogro = source.idLogro
        WHEN NOT MATCHED THEN INSERT (idUsuario, idLogro) VALUES (source.idUsuario, source.idLogro);
    END
    
    IF @puntuacion >= 1000
    BEGIN
        MERGE INTO UsuarioLogros AS target
        USING (VALUES (@idUsuario, 4)) AS source (idUsuario, idLogro)
        ON target.idUsuario = source.idUsuario AND target.idLogro = source.idLogro
        WHEN NOT MATCHED THEN INSERT (idUsuario, idLogro) VALUES (source.idUsuario, source.idLogro);
    END
    
    IF @puntuacion >= 2000
    BEGIN
        MERGE INTO UsuarioLogros AS target
        USING (VALUES (@idUsuario, 5)) AS source (idUsuario, idLogro)
        ON target.idUsuario = source.idUsuario AND target.idLogro = source.idLogro
        WHEN NOT MATCHED THEN INSERT (idUsuario, idLogro) VALUES (source.idUsuario, source.idLogro);
    END
END;
GO

-- Procedimiento para actualizar perfil de usuario
CREATE PROCEDURE sp_ActualizarUsuario
    @idUsuario INT,
    @usuario VARCHAR(50),
    @correo VARCHAR(100),
    @contrasena VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Verificar que el nuevo usuario no exista (excluyendo el actual)
        IF EXISTS (SELECT 1 FROM Usuarios WHERE usuario = @usuario AND idUsuario != @idUsuario)
        BEGIN
            THROW 50001, 'El nombre de usuario ya está en uso', 1;
        END
        
        -- Verificar que el nuevo correo no exista (excluyendo el actual)
        IF EXISTS (SELECT 1 FROM Usuarios WHERE correo = @correo AND idUsuario != @idUsuario)
        BEGIN
            THROW 50002, 'El correo electrónico ya está en uso', 1;
        END
        
        -- Actualizar con o sin contraseña
        IF @contrasena IS NOT NULL
        BEGIN
            UPDATE Usuarios 
            SET usuario = @usuario, correo = @correo, contrasena = @contrasena
            WHERE idUsuario = @idUsuario;
        END
        ELSE
        BEGIN
            UPDATE Usuarios 
            SET usuario = @usuario, correo = @correo
            WHERE idUsuario = @idUsuario;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrorMessage, 1;
    END CATCH
END;
GO

-- Procedimiento para obtener datos de usuario
CREATE PROCEDURE sp_ObtenerDatosUsuario
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT usuario, correo
    FROM Usuarios
    WHERE idUsuario = @idUsuario;
END;
GO

-- Vista para el leaderboard extendido
CREATE VIEW vw_LeaderboardCompleto AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY MAX(p.puntuacion) DESC) as posicion,
    u.usuario,
    MAX(p.puntuacion) as mejor_puntuacion,
    COUNT(p.idPartida) as total_partidas,
    AVG(p.puntuacion) as promedio_puntuacion,
    MAX(p.fechaPartida) as ultima_partida
FROM Partidas p
INNER JOIN Usuarios u ON p.idUsuario = u.idUsuario
GROUP BY u.usuario;
GO

-- Vista para estadísticas de usuario
CREATE VIEW vw_EstadisticasUsuario AS
SELECT 
    u.idUsuario,
    u.usuario,
    COUNT(p.idPartida) as total_partidas,
    MAX(p.puntuacion) as mejor_puntuacion,
    AVG(p.puntuacion) as promedio_puntuacion,
    SUM(p.tiempoJugado) as tiempo_total_jugado,
    COUNT(ul.idUsuarioLogro) as total_logros
FROM Usuarios u
LEFT JOIN Partidas p ON u.idUsuario = p.idUsuario
LEFT JOIN UsuarioLogros ul ON u.idUsuario = ul.idUsuario
GROUP BY u.idUsuario, u.usuario;
GO

-- Script para crear usuario de aplicación (opcional)
CREATE LOGIN DinoGameApp WITH PASSWORD = 'StrongPassword123!';
CREATE USER DinoGameApp FOR LOGIN DinoGameApp;
GO

-- Asignar permisos al usuario de la aplicación
GRANT EXECUTE ON sp_RegistrarUsuario TO DinoGameApp;
GRANT EXECUTE ON sp_LoginUsuario TO DinoGameApp;
GRANT EXECUTE ON sp_GuardarPartida TO DinoGameApp;
GRANT EXECUTE ON sp_ObtenerLeaderboard TO DinoGameApp;
GRANT EXECUTE ON sp_ObtenerLogrosUsuario TO DinoGameApp;
GRANT EXECUTE ON sp_VerificarLogros TO DinoGameApp;
GRANT EXECUTE ON sp_ActualizarUsuario TO DinoGameApp;
GRANT EXECUTE ON sp_ObtenerDatosUsuario TO DinoGameApp;
GRANT SELECT ON vw_LeaderboardCompleto TO DinoGameApp;
GRANT SELECT ON vw_EstadisticasUsuario TO DinoGameApp;
GO

-- Mensaje de confirmación
PRINT 'Base de datos DinoGame creada exitosamente!';
PRINT 'Tablas: Usuarios, Partidas, Logros, UsuarioLogros';
PRINT 'Procedimientos almacenados creados';
PRINT 'Datos de ejemplo insertados';
PRINT 'Vistas y permisos configurados';
GO
select * from Usuarios
select * from UsuarioLogros
select * from Partidas


-- Crear procedimiento para backup completo
CREATE PROCEDURE sp_BackupCompletoDinoGame
AS
BEGIN
    DECLARE @fecha VARCHAR(20) = CONVERT(VARCHAR(20), GETDATE(), 112);
    DECLARE @hora VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '');
    DECLARE @rutaBackup VARCHAR(255);
    
    SET @rutaBackup = 'C:\Backups\DinoGame\DinoGame_Full_' + @fecha + '_' + @hora + '.bak';
    
    BACKUP DATABASE DinoGame 
    TO DISK = @rutaBackup
    WITH INIT, NAME = 'DinoGame-Full Database Backup', STATS = 10;
END;
GO

-- Crear procedimiento para backup diferencial
CREATE PROCEDURE sp_BackupDiferencialDinoGame
AS
BEGIN
    DECLARE @fecha VARCHAR(20) = CONVERT(VARCHAR(20), GETDATE(), 112);
    DECLARE @hora VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '');
    DECLARE @rutaBackup VARCHAR(255);
    
    SET @rutaBackup = 'C:\Backups\DinoGame\DinoGame_Diff_' + @fecha + '_' + @hora + '.bak';
    
    BACKUP DATABASE DinoGame 
    TO DISK = @rutaBackup
    WITH DIFFERENTIAL, INIT, NAME = 'DinoGame-Differential Database Backup', STATS = 10;
END;
GO

-- Crear procedimiento para backup de transacciones
CREATE PROCEDURE sp_BackupLogDinoGame
AS
BEGIN
    DECLARE @fecha VARCHAR(20) = CONVERT(VARCHAR(20), GETDATE(), 112);
    DECLARE @hora VARCHAR(20) = REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '');
    DECLARE @rutaBackup VARCHAR(255);
    
    SET @rutaBackup = 'C:\Backups\DinoGame\DinoGame_Log_' + @fecha + '_' + @hora + '.trn';
    
    BACKUP LOG DinoGame 
    TO DISK = @rutaBackup
    WITH INIT, NAME = 'DinoGame-Transaction Log Backup', STATS = 10;
END;
GO

-- Procedimiento para reindexar tablas
CREATE PROCEDURE sp_ReindexarBaseDatos
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Reconstruir índices fragmentados
    DECLARE @Tabla VARCHAR(255);
    DECLARE @Indice VARCHAR(255);
    DECLARE @Fragmentacion FLOAT;
    
    DECLARE curIndices CURSOR FOR
    SELECT 
        OBJECT_NAME(ips.object_id) as TableName,
        si.name as IndexName,
        ips.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ips
    INNER JOIN sys.indexes si ON ips.object_id = si.object_id AND ips.index_id = si.index_id
    WHERE ips.avg_fragmentation_in_percent > 30 -- Solo índices con más del 30% de fragmentación
    AND si.name IS NOT NULL;
    
    OPEN curIndices;
    FETCH NEXT FROM curIndices INTO @Tabla, @Indice, @Fragmentacion;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Reconstruyendo índice: ' + @Indice + ' en tabla: ' + @Tabla + ' (Fragmentación: ' + CAST(@Fragmentacion AS VARCHAR) + '%)';
        
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = 'ALTER INDEX ' + QUOTENAME(@Indice) + ' ON ' + QUOTENAME(@Tabla) + ' REBUILD';
        
        EXEC sp_executesql @sql;
        
        FETCH NEXT FROM curIndices INTO @Tabla, @Indice, @Fragmentacion;
    END
    
    CLOSE curIndices;
    DEALLOCATE curIndices;
    
    -- Actualizar estadísticas
    EXEC sp_updatestats;
    
    PRINT 'Mantenimiento de base de datos completado.';
END;
GO

-- Procedimiento para limpiar datos antiguos
CREATE PROCEDURE sp_LimpiarDatosAntiguos
    @diasRetencion INT = 365 -- Conservar datos de 1 año por defecto
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @fechaLimite DATETIME = DATEADD(DAY, -@diasRetencion, GETDATE());
    
    -- Limpiar partidas antiguas
    DELETE FROM Partidas 
    WHERE fechaPartida < @fechaLimite;
    
    PRINT 'Limpieza de datos antiguos completada. Fecha límite: ' + CONVERT(VARCHAR, @fechaLimite);
END;
GO

-- Crear tabla para logs de alertas
CREATE TABLE AlertasLog (
    idAlerta INT IDENTITY(1,1) PRIMARY KEY,
    tipoAlerta VARCHAR(50) NOT NULL,
    descripcion VARCHAR(500) NOT NULL,
    severidad VARCHAR(20) CHECK (severidad IN ('BAJA', 'MEDIA', 'ALTA', 'CRITICA')),
    fechaAlerta DATETIME DEFAULT GETDATE(),
    resuelta BIT DEFAULT 0,
    fechaResolucion DATETIME NULL
);
GO

-- Procedimiento para verificar espacio en disco
CREATE PROCEDURE sp_VerificarEspacioDisco
AS
BEGIN
    DECLARE @espacioLibreMB INT;
    DECLARE @umbralAlerta INT = 1024; -- 1GB
    
    SELECT @espacioLibreMB = available_bytes / 1048576
    FROM sys.dm_os_volume_stats(DB_ID('DinoGame'), NULL);
    
    IF @espacioLibreMB < @umbralAlerta
    BEGIN
        INSERT INTO AlertasLog (tipoAlerta, descripcion, severidad)
        VALUES ('ESPACIO_DISCO', 
                'Espacio libre en disco crítico: ' + CAST(@espacioLibreMB AS VARCHAR) + 'MB libres. Umbral: ' + CAST(@umbralAlerta AS VARCHAR) + 'MB',
                'ALTA');
    END
END;
GO

-- Procedimiento para verificar crecimiento de base de datos
CREATE PROCEDURE sp_VerificarCrecimientoBD
AS
BEGIN
    DECLARE @tamanoActualMB DECIMAL(18,2);
    DECLARE @crecimientoSemanalMB DECIMAL(18,2);
    DECLARE @umbralCrecimientoMB INT = 500; -- 500MB por semana
    
    -- Obtener tamaño actual
    SELECT @tamanoActualMB = SUM(size) * 8 / 1024.0
    FROM sys.master_files
    WHERE database_id = DB_ID('DinoGame');
    
    -- Verificar crecimiento semanal (ejemplo simplificado)
    IF @tamanoActualMB > 5000 -- Si la BD supera 5GB
    BEGIN
        INSERT INTO AlertasLog (tipoAlerta, descripcion, severidad)
        VALUES ('CRECIMIENTO_BD', 
                'Base de datos creciendo rápidamente. Tamaño actual: ' + CAST(@tamanoActualMB AS VARCHAR) + 'MB',
                'MEDIA');
    END
END;
GO

-- Procedimiento para verificar bloqueos prolongados
CREATE PROCEDURE sp_VerificarBloqueos
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM sys.dm_tran_locks l
        JOIN sys.dm_os_waiting_tasks w ON l.request_session_id = w.session_id
        WHERE w.wait_duration_ms > 30000 -- Bloqueos de más de 30 segundos
    )
    BEGIN
        INSERT INTO AlertasLog (tipoAlerta, descripcion, severidad)
        VALUES ('BLOQUEOS', 
                'Se detectaron bloqueos prolongados en la base de datos',
                'ALTA');
    END
END;
GO




-- Crear tabla de auditoría
CREATE TABLE AuditoriaUsuarios (
    idAuditoria INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario INT NULL,
    accion VARCHAR(50) NOT NULL,
    descripcion VARCHAR(500) NOT NULL,
    fechaAuditoria DATETIME DEFAULT GETDATE(),
    ipAddress VARCHAR(50) NULL,
    usuarioAplicacion VARCHAR(50) NULL
);
GO

-- Triggers para auditoría
CREATE TRIGGER tr_AuditoriaUsuarios_Insert
ON Usuarios
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditoriaUsuarios (idUsuario, accion, descripcion)
    SELECT 
        i.idUsuario,
        'CREACION_USUARIO',
        'Nuevo usuario creado: ' + i.usuario
    FROM inserted i;
END;
GO

CREATE TRIGGER tr_AuditoriaUsuarios_Update
ON Usuarios
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditoriaUsuarios (idUsuario, accion, descripcion)
    SELECT 
        i.idUsuario,
        'ACTUALIZACION_USUARIO',
        'Usuario actualizado: ' + i.usuario
    FROM inserted i;
END;
GO

CREATE TRIGGER tr_AuditoriaPartidas_Insert
ON Partidas
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditoriaUsuarios (idUsuario, accion, descripcion)
    SELECT 
        i.idUsuario,
        'NUEVA_PARTIDA',
        'Nueva partida registrada. Puntuación: ' + CAST(i.puntuacion AS VARCHAR)
    FROM inserted i;
END;
GO



-- Crear procedimiento para ejecutar mantenimiento diario
CREATE PROCEDURE sp_MantenimientoDiario
AS
BEGIN
    PRINT 'Iniciando mantenimiento diario - ' + CONVERT(VARCHAR, GETDATE());
    
    -- Backup de transacciones cada 4 horas
    EXEC sp_BackupLogDinoGame;
    
    -- Verificar espacio en disco
    EXEC sp_VerificarEspacioDisco;
    
    -- Verificar bloqueos
    EXEC sp_VerificarBloqueos;
    
    PRINT 'Mantenimiento diario completado - ' + CONVERT(VARCHAR, GETDATE());
END;
GO

-- Crear procedimiento para mantenimiento semanal
CREATE PROCEDURE sp_MantenimientoSemanal
AS
BEGIN
    PRINT 'Iniciando mantenimiento semanal - ' + CONVERT(VARCHAR, GETDATE());
    
    -- Backup diferencial
    EXEC sp_BackupDiferencialDinoGame;
    
    -- Reindexar base de datos
    EXEC sp_ReindexarBaseDatos;
    
    -- Verificar crecimiento
    EXEC sp_VerificarCrecimientoBD;
    
    -- Limpiar alertas antiguas (más de 30 días)
    DELETE FROM AlertasLog 
    WHERE fechaAlerta < DATEADD(DAY, -30, GETDATE()) 
    AND resuelta = 1;
    
    PRINT 'Mantenimiento semanal completado - ' + CONVERT(VARCHAR, GETDATE());
END;
GO

-- Crear procedimiento para mantenimiento mensual
CREATE PROCEDURE sp_MantenimientoMensual
AS
BEGIN
    PRINT 'Iniciando mantenimiento mensual - ' + CONVERT(VARCHAR, GETDATE());
    
    -- Backup completo
    EXEC sp_BackupCompletoDinoGame;
    
    -- Limpiar datos antiguos (conservar 1 año)
    EXEC sp_LimpiarDatosAntiguos 365;
    
    -- Limpiar auditoría antigua (más de 1 año)
    DELETE FROM AuditoriaUsuarios 
    WHERE fechaAuditoria < DATEADD(YEAR, -1, GETDATE());
    
    PRINT 'Mantenimiento mensual completado - ' + CONVERT(VARCHAR, GETDATE());
END;
GO

-- Procedimiento para reporte de uso diario
CREATE PROCEDURE sp_ReporteUsoDiario
    @fecha DATE = NULL
AS
BEGIN
    IF @fecha IS NULL
        SET @fecha = CAST(GETDATE() AS DATE);
    
    SELECT 
        @fecha as Fecha,
        COUNT(DISTINCT idUsuario) as UsuariosActivos,
        COUNT(*) as TotalPartidas,
        SUM(tiempoJugado) as TiempoTotalJugado,
        AVG(puntuacion) as PuntuacionPromedio,
        MAX(puntuacion) as PuntuacionMaxima
    FROM Partidas
    WHERE CAST(fechaPartida AS DATE) = @fecha;
END;
GO

-- Procedimiento para reporte de crecimiento
CREATE PROCEDURE sp_ReporteCrecimiento
    @dias INT = 30
AS
BEGIN
    SELECT 
        CAST(fechaPartida AS DATE) as Fecha,
        COUNT(*) as PartidasPorDia,
        COUNT(DISTINCT idUsuario) as UsuariosPorDia,
        AVG(puntuacion) as PuntuacionPromediaDia
    FROM Partidas
    WHERE fechaPartida >= DATEADD(DAY, -@dias, GETDATE())
    GROUP BY CAST(fechaPartida AS DATE)
    ORDER BY Fecha DESC;
END;
GO


-- Otorgar permisos adicionales al usuario de aplicación
GRANT EXECUTE ON sp_BackupLogDinoGame TO DinoGameApp;
GRANT EXECUTE ON sp_ReindexarBaseDatos TO DinoGameApp;
GRANT EXECUTE ON sp_VerificarEspacioDisco TO DinoGameApp;
GRANT EXECUTE ON sp_ReporteUsoDiario TO DinoGameApp;
GRANT SELECT ON AlertasLog TO DinoGameApp;
GRANT SELECT ON AuditoriaUsuarios TO DinoGameApp;
GO

-- Crear rol para monitoreo
CREATE ROLE MonitorRole;
GO

GRANT EXECUTE ON sp_VerificarEspacioDisco TO MonitorRole;
GRANT EXECUTE ON sp_VerificarBloqueos TO MonitorRole;
GRANT EXECUTE ON sp_ReporteUsoDiario TO MonitorRole;
GRANT SELECT ON vw_LeaderboardCompleto TO MonitorRole;
GRANT SELECT ON vw_EstadisticasUsuario TO MonitorRole;
GRANT SELECT ON AlertasLog TO MonitorRole;
GO

-- Crear directorio de backups si no existe (ejecutar en CMD si es necesario)
-- mkdir C:\Backups
-- mkdir C:\Backups\DinoGame

-- Ejecutar primer backup completo
EXEC sp_BackupCompletoDinoGame;
GO

-- Crear índices adicionales para mejorar rendimiento
CREATE INDEX IX_Partidas_Fecha ON Partidas(fechaPartida DESC);
CREATE INDEX IX_AlertasLog_Fecha ON AlertasLog(fechaAlerta DESC);
CREATE INDEX IX_AuditoriaUsuarios_Fecha ON AuditoriaUsuarios(fechaAuditoria DESC);
GO

-- Insertar configuración inicial
INSERT INTO AlertasLog (tipoAlerta, descripcion, severidad, resuelta)
VALUES ('SISTEMA_INICIADO', 'Sistema de alertas y backups configurado correctamente', 'BAJA', 1);
GO

PRINT 'Sistema de mantenimiento, backups y alertas configurado exitosamente!';
PRINT 'Procedimientos de backup creados';
PRINT 'Sistema de alertas implementado';
PRINT 'Mecanismos de auditoría configurados';
PRINT 'Procedimientos de mantenimiento programados';
GO