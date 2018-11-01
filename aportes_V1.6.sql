SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS aportesV1.6;
CREATE SCHEMA aportesV1.6;
USE aportesV1.6;


--
-- Table structure for table `users1`
--

CREATE TABLE t_users1 (
  dni INT UNSIGNED NOT NULL,
  apellido VARCHAR(45) NOT NULL,
  nombres VARCHAR(45) NOT NULL,
  profesion ENUM('Ingeniero','Contador','Medico','Abogado','Sicologo','Escribano','Lic Admin Empresas','Arquitecto','Otra','N/D') DEFAULT 'N/D',
  email_1 VARCHAR(50) DEFAULT NULL,
  email_2 VARCHAR(50) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (dni)
  )ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `users2`
--

CREATE TABLE t_users2 (
  dni INT UNSIGNED NOT NULL,
  cuil VARCHAR(14) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_fk_dni (dni),
  CONSTRAINT fk_users2_dni FOREIGN KEY (dni) REFERENCES t_users1 (dni) ON DELETE RESTRICT ON UPDATE CASCADE
  )ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
  
CREATE TABLE t_especialidad_user (
  dni INT UNSIGNED NOT NULL,
  especialidad VARCHAR(14) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_fk_dni (dni),
  CONSTRAINT fk_especialidad_dni FOREIGN KEY (dni) REFERENCES t_users1 (dni) ON DELETE RESTRICT ON UPDATE CASCADE,
  KEY idx_fk_especialidad (especialidad),
  CONSTRAINT fk_especialidades_especialidad FOREIGN KEY (especialidad) REFERENCES t_especialidades (especialidad) ON DELETE RESTRICT ON UPDATE RESTRICT
  )ENGINE=InnoDB DEFAULT CHARSET=utf8;

  
CREATE TABLE t_estado_user (
  dni INT UNSIGNED NOT NULL,
  estado ENUM ('Asignado','Disponible','ND_Temp','De_Baja','Con_Restricc','Interno','Puntual','Desconoc') DEFAULT 'Desconoc',
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  consideraciones TINYTEXT (256) DEFAULT NULL,   
  KEY idx_fk_dni (dni),
  CONSTRAINT fk_estado_dni FOREIGN KEY (dni) REFERENCES t_users1 (dni) ON DELETE RESTRICT ON UPDATE CASCADE
  )ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Tablas fijas

CREATE TABLE t_roles (
	rol VARCHAR 6 NOT NULL,
	descr_rol VARCHAR 32 DEFAULT NULL,
	PRIMARY KEY (rol)
	)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE t_especialidades (
  especialidad VARCHAR(14) NOT NULL,
  PRIMARY KEY  (especialidad)
  )
  
-- CREATE TABLE t_estados (
  -- estado ENUM ('Asignado','Disponible','ND_Temp','De_Baja','Con_Restricc','Interno','Puntual','Desconoc') DEFAULT 'Desconoc',
  -- estado VARCHAR(14),
  -- PRIMARY KEY (estado)
  -- )ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- Carga de datos en Tablas Fijas

\. SQL_Ins_T_fijas/2018-10-31_0018_ESPEC.sql

INSERT INTO t_roles (rol,descr_rol)
VALUES
('DP','Director/a de Proyectos'),
('DC','Director/a de Contactos'),
('PMO','Project Management Office'),
('DPI','Director/a Programas Institucionales'),
('ASIST','Asistente'),
('VOL','Voluntaria/o'),
('VC','Voluntaria/o de Contacto')
;

-- No hace falta insertar esto para esta version de la BD
-- Ya que esta en t_estado_user
-- \. SQL_Ins_T_fijas/2018-10-31_1029_ESTADO.sql

