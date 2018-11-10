use aportesV1;
SELECT 
	   e.dni
--	   e.especialidad 
	FROM
	  t_especialidad_user e
    GROUP BY e.dni
   HAVING e.especialidad = "Sistemas" OR e.especialidad  = "Procesos" ;
-- WHERE e.especialidad IN ("Sistemas", "Procesos") ;
