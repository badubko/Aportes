use aportesV1;
SELECT
   dni,
   apellido
from
	t_users1
WHERE
    dni IN (
         
		 SELECT DISTINCT
			dni  
		FROM
			t_especialidad_user 
		WHERE especialidad IN ("Sistemas", "Chantologia") 
		
		
--		( SELECT dni FROM t_estado_user WHERE estado = "Interno" )
		
		);



-- ORDER BY dni;

