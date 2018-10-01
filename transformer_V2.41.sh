# !/bin/bash
#-------------------------------------------------------------------------------
# Formatear datos
#-------------------------------------------------------------------------------
# Version:

procesar_dni_cuil()
{
HAY_DNI="FALSE"

if [ ${#VAL_COL[21]} = 0 ]  # No hay cargado DNI ni CUIL
then
	HAY_DNI="FALSE" ; 	DNI="${DNI_NO_DISPONIBLE}"
	HAY_CUIL="FALSE" ; 	CUIL="${CUIL_NO_DISPONIBLE}"
	return
fi

/bin/grep -q -e "^ *DNI" <<< ${VAL_COL[21]^^}    # EL patron DNI (may o min) precedido de blancos
if [ $? = 0 ]
then
#	echo "Remover DNI y tomar los digitos"
	HAY_DNI="TRUE"
	DNI=${VAL_COL[21]^^}
	DNI=${DNI#DNI }
	DNI=${DNI//./}
	
	HAY_CUIL="FALSE" ; 	CUIL="${CUIL_NO_DISPONIBLE}"
	return
fi

/bin/grep -q -e "${PATRON_CUIL}" <<< ${VAL_COL[21]^^}  # Hay un CUIL y de el tomaremos el DNI
if [ $? = 0 ]
then
#	echo "Obtener DNI y guardar CUIL"
	HAY_DNI="TRUE"
	HAY_CUIL="TRUE"
	DNI=$( cut -d\- -f2 <<<${VAL_COL[21]} )
	CUIL=$( sed -r 's/.*([0-9]{2}-)([0-9]{8}-)([0-9]{1}) .*/\1\2\3/' <<<${VAL_COL[21]} ) 
	return
else
	HAY_DNI="FALSE" ; 	DNI="${DNI_NO_DISPONIBLE}"
	HAY_CUIL="FALSE" ; 	CUIL="${CUIL_NO_DISPONIBLE}"
fi
	

}

procesar_especialidad ()
{
if [ ${#VAL_COL[9]} = 0 ]
then
	HAY_ESPEC=FALSE
	return
fi

IFS_ANT=${IFS}

VAL_COL[9]=${VAL_COL[9]//\#/}	 #  Eliminamos el caracter "#"

IFS=';'  read -r -a ESPECIALIDADES <<< ${VAL_COL[9]}

let TOT_ESPEC=${#ESPECIALIDADES[@]}-1

let i=0

while [ $i -le ${TOT_ESPEC} ]
do
	printf "%s %s %s\n" "SQL Insertar=" ${DNI} ${ESPECIALIDADES[$i]}
	let i++
done

IFS=${IFS_ANT}
	
}



#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------
declare -a NOMBRE_COL
declare -a NCM_Lineas 
declare -a VAL_COL
declare -a ESPECIALIDADES
declare -i TOT_ESPEC i

DNI_NO_DISPONIBLE=""
CUIL_NO_DISPONIBLE="N/D"

PATRON_CUIL="^ *[0-9]\{2\}\-[0-9]\{8\}\-[0-9]\{1\}"

LISTADO_DATOS="../Datos/Libro2_V1.1.csv"

TABLE_NAME_1="T_VOLS1"
TABLE_NAME_2="T_VOLS2"

if [ ! -f  "${LISTADO_DATOS}" ]
then
	echo "El Archivo ${LISTADO_DATOS} NO existe"
	exit
fi

# NOMBRE_COL	Nombre Col			   COL	Nombre Excel
#		[Indice]
NOMBRE_COL[0]="apellido"			#	A	Apellido
NOMBRE_COL[1]="nombres"				#	B	Nombre	
NOMBRE_COL[2]="estado"				#	C	Estado
NOMBRE_COL[3]="comentarios"			#	D	Comentarios
NOMBRE_COL[4]="f_ingreso"			#	E	Fecha de ingreso
NOMBRE_COL[5]="socio"				#	F	Socio
NOMBRE_COL[6]=""					#	G	Proyectos	 N/A
NOMBRE_COL[7]=""					#	H	Area de trabajo del proyecto
NOMBRE_COL[8]=""					#	I	Aptitud
NOMBRE_COL[9]="especialidad"		#	J	Especialidad (parsear y a otra tabla)
NOMBRE_COL[10]=""					#	K	Asertividad
NOMBRE_COL[11]=""					#	L	Sociabilidad
NOMBRE_COL[12]=""					#	M	Actitud
NOMBRE_COL[13]=""					#	N	Talleres
NOMBRE_COL[14]=""					#	O	Actividades
NOMBRE_COL[15]="acuerdo"			#	P	Acuerdo
NOMBRE_COL[16]=""					#	Q	Z
NOMBRE_COL[17]="tel_1"				#	R	Telefono 1
NOMBRE_COL[18]=""					#	S	Presentacion
NOMBRE_COL[19]="referido_por"		#	T	Referido por
NOMBRE_COL[20]="tel_2"				#	U	Telefono 2
NOMBRE_COL[21]="cuil"				#	V	CUIL	
NOMBRE_COL[22]="email_1"			#	W	E-mail
NOMBRE_COL[23]="entrevistado_por" 	# 	X	Entrevistado por
NOMBRE_COL[24]=""					#	Y	Item type
NOMBRE_COL[25]=""					#	Z	PATH

# Columnas que no estan en la planilla
NOMBRE_COL[30]="dni"
NOMBRE_COL[31]="profesion"
NOMBRE_COL[32]="email_2"
NOMBRE_COL[33]="rol"



echo ${NOMBRE_COL[0]} ${NOMBRE_COL[1]} ${NOMBRE_COL[2]} ${NOMBRE_COL[3]}



#Insert into city
 #(`city_id`,`city`,`country_id`,`last_update`)
#Values
#('261','Kanchrapara','44','2006-02-15 04:45:25.000')


OLDIFS=$IFS
IFS=,


while IFS=','  read -ra VAL_COL
do
	procesar_dni_cuil
	
	#if [ ${HAY_DNI} = "TRUE" ]
	#then
		#printf "%s %s %s %s %s %s %s \n" ${VAL_COL[0]} ${VAL_COL[1]}  ${VAL_COL[21]} "dni=" ${DNI} "cuil" ${CUIL}
		#procesar_especialidad
	#else
		#printf "%s %s %s \n" ${VAL_COL[0]} ${VAL_COL[1]} "-->SIN_DNI"
	#fi
		
	if [ ${HAY_DNI} = "TRUE" ]
	then
		printf "%s %s \n" "Insert into"  ${TABLE_NAME_1}
		printf "(\`%s\`,\`%s\`,\`%s\`,\`%s\`,\`%s\`)\n" ${NOMBRE_COL[0]} ${NOMBRE_COL[1]} ${NOMBRE_COL[2]} ${NOMBRE_COL[3]}\
		${NOMBRE_COL[9]}
		printf "%s\n" "Values"
		printf "('%s','%s','%s','%s','%s')\n" ${VAL_COL[0]} ${VAL_COL[1]} ${VAL_COL[2]} ${VAL_COL[3]} ${VAL_COL[9]}
		printf ";\n"
		
 	else
		printf "%s %s %s \n" ${NOMBRE_COL[0]} ${NOMBRE_COL[1]} "-->SIN DNI"
	fi
	
	#if [ ${HAY_DNI} = "TRUE" ]
	#then
		#procesar_especialidad
	#fi	
	
	
done < ${LISTADO_DATOS}

IFS=$OLDIFS
	