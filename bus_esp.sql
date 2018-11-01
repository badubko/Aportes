SELECT 
	esp.dni,
	u1.apellido,
--	e.estado
	esp.especialidad
FROM
	t_users1 u1
INNER JOIN 
--   t_especialidad_user esp ON u1.dni = esp.dni
   t_especialidad_user esp USING (dni)
WHERE
	especialidad = "Sistemas" ;
	
-- AND especialidad = "Procesos" ;

-- ORDER BY especialidad
;
-- ORDER BY
-- e.dni ;
