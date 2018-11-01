SELECT 
	esp.dni,
	u1.apellido,
--	e.estado
	esp.especialidad
FROM
	t_users1 u1
LEFT JOIN 
   t_especialidad_user esp ON u1.dni = esp.dni
WHERE
	especialidad = "Coaching" 
LEFT JOIN
    
;
-- ORDER BY
-- e.dni ;
-- LEFT JOIN
	-- t_estado_user e ON u1.dni = e.dni
-- WHERE
	-- estado = "Disponible"

-- FROM
	-- t_especialidad_user esp
	
