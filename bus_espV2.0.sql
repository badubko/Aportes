SELECT 
	dni,
	apellido,
--	estado
	especialidad
FROM
	t_users1
WHERE
	dni IN (SELECT 
	   dni
	FROM
	  t_especialidad_user
    GROUP BY dni
    HAVING especialidad = "Sistemas" OR especialidad = "Procesos" ) 
 ;


