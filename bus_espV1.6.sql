use aportesV1;
SELECT DISTINCT
	   dni

	FROM
	  t_especialidad_user 

WHERE especialidad IN ("Sistemas", "Chantologia")
 ORDER BY dni;
