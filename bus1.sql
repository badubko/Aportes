SELECT 
	e.dni,
	u1.apellido,
	e.estado
FROM
	t_users1 u1
LEFT JOIN
	t_estado_user e ON u1.dni = e.dni
WHERE
	estado = "Asignado" ;
