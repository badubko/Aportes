# !/bin/bash
#-------------------------------------------------------------------------------
# Formatear datos
#-------------------------------------------------------------------------------
# Version:

linea_guiones ()
{
echo "----------------------------------------------------------------"  
}


run_data()
{	
#-------------------------------------------------------------------------------
# RUN_DATE Fecha y hora de la ejecucion del script
RUN_DATE="$(date  +\#\ %Y\/%m\/%d\ %H:%M)"
RUN_DATE_FILE="$(date  +%Y-%m-%d_%H%M)"    # Nuevo formato para usar en nombres de Archivo
#-------------------------------------------------------------------------------
# Nombre abreviado del script en ejecucion... para que los mensajes sean mas legibles.

VERS=${0##*_} 		# Elimina /abc/def/ghi/./Gen_list_files_cel_NO_copiar_  Queda "V0.5.sh"
VERS=${VERS%.*} 	# Elimina ".sh"  Queda "V0.5"

COM=${0%_*}    				#; echo $COM   # ELimina "_V0.5.sh"
COM=${COM##*/} 				#; echo $COM   # Elimina "/abc/def/ghi/./"
COMANDO_COMPLETO=${COM}   	# Para determinar que secciones ejecutar en Verifica.. y Genera
COM=${COM:0:4} 				#; echo $COM   # Solo los primeros 4 caracteres

NOM_ABREV=${COM}'..'${VERS}
return
}
#-------------------------------------------------------------------------------

genera_banner ()
{	
# Aca viene el banner y la lista de variables a incluir
DIR_REF=${PWD}

FLAG_TERM="FALSE"           # Si algun parametro no esta definido terminar temprano

if [ ! -f  "${CSV_IN_FILE}" ]
then
	echo "El Archivo ${CSV_IN_FILE} NO existe"
	exit
fi

if [  -d "${SQL_OUT_FILE}" ]
then
  echo "${NOM_ABREV}: No se puede generar: ${SQL_OUT_FILE} Es un directorio"
  exit
fi


  linea_guiones 										>${SQL_OUT_FILE}
  echo "-- Nombre    :  ${SQL_OUT_FILE}"				>>${SQL_OUT_FILE}
  echo "-- Creado por: $0     Run_date  : ${RUN_DATE}"	>>${SQL_OUT_FILE}
  printf "%s\n" "--"									>>${SQL_OUT_FILE}
  echo "-- Directorio Origen:  ${PWD}" 					>>${SQL_OUT_FILE}
  echo "-- CSV_IN_FILE :				${CSV_IN_FILE}"	>>${SQL_OUT_FILE}
  linea_guiones 										>>${SQL_OUT_FILE}
  echo "-- Variables incluidas:"			  	        >>${SQL_OUT_FILE}	
return	
}

#------------------------------------------------------------------------------
procesar_dni_cuil()
#------------------------------------------------------------------------------
{
HAY_DNI="FALSE"

if [ ${#VAL_COL[21]} = 0 ]  # No hay cargado DNI ni CUIL
then
	HAY_DNI="FALSE" ; 	DNI="${DNI_NO_DISPONIBLE}"
	HAY_CUIL="FALSE" ; 	CUIL="${CUIL_NO_DISPONIBLE}"
	return
fi

/bin/grep -q -e "^ *DNI" <<< ${VAL_COL[21]^^}	# EL patron DNI (may o min) 
												# al comienzo de la linea
												# precedido de blancos o no
if [ $? = 0 ]
then
#	echo "Remover DNI y tomar los digitos"
	HAY_DNI="TRUE"
	DNI=${VAL_COL[21]^^}
	DNI=${DNI#DNI }
#	DNI=${DNI//./}
	VAL_COL[30]=${DNI//./} # ESta es la columna DNI
	HAY_CUIL="FALSE" ; 	CUIL="${CUIL_NO_DISPONIBLE}" ; VAL_COL[21]=${CUIL}
	return
fi

/bin/grep -q -e "${PATRON_CUIL}" <<< ${VAL_COL[21]^^}  # Hay un CUIL y de el tomaremos el DNI
if [ $? = 0 ]
then
#	echo "Obtener DNI y guardar CUIL"
	HAY_DNI="TRUE"
	HAY_CUIL="TRUE"
#	DNI=$( cut -d\- -f2 <<<${VAL_COL[21]} )
	VAL_COL[30]=$( cut -d\- -f2 <<<${VAL_COL[21]} )   # ESta es la columna DNI
#	CUIL=$( sed -r 's/.*([0-9]{2}-)([0-9]{8}-)([0-9]{1}) .*/\1\2\3/' <<<${VAL_COL[21]} ) 
	VAL_COL[21]=$( sed -r 's/.*([0-9]{2}-)([0-9]{8}-)([0-9]{1}) .*/\1\2\3/' <<<${VAL_COL[21]} ) # Este es el CUIL
	return
else
	HAY_DNI="FALSE" ; 	DNI="${DNI_NO_DISPONIBLE}"
	HAY_CUIL="FALSE" ; 	CUIL="${CUIL_NO_DISPONIBLE}"
fi
	

}
#------------------------------------------------------------------------------
procesar_especialidad ()
#------------------------------------------------------------------------------
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
#	printf "%s %s %s\n" "SQL Insertar=" ${DNI} ${ESPECIALIDADES[$i]}
    VAL_COL[100]=${ESPECIALIDADES[$i]}
	generar_insert ${TABLE_NAME_3}
	let i++
done

IFS=${IFS_ANT}
	
}
#------------------------------------------------------------------------------
generar_insert()
#------------------------------------------------------------------------------
{
# Imprimimos las lineas de sentencias SQL
	

TABLE_NAME=${1}  # Le pasamos como parametro el nombre de la tabla

CURR_IFS=$IFS
IFS=$OLDIFS

FORM_NOM_COL="("
FORM_VAL="("
LINEA_NOM=""

printf "%s %s \n" "Insert into"  ${TABLE_NAME}

COL=${LISTA_COLUMNAS[0]} 						# Cual es la primer columna
printf "(%s%s%s"  '`' "${NOMBRE_COL[${COL}]}" '`' 

PRIMERA_COL=TRUE

for INDEX in ${LISTA_COLUMNAS[@]}
do
	if [ ${PRIMERA_COL} = "TRUE" ]
	then
		PRIMERA_COL=FALSE             # salteamos la 1a col por el tema de las comas
		continue
	else
		printf  ",\`%s\`" "${NOMBRE_COL[${INDEX}]}"
	fi
done

printf ")\n" 


printf "%s\n" "Values"

printf "('%s'" "${VAL_COL[${COL}]}" 
PRIMERA_COL=TRUE

for INDEX in ${LISTA_COLUMNAS[@]}
do
	if [ ${PRIMERA_COL} = "TRUE" ]
	then
		PRIMERA_COL=FALSE
		continue
	else
		printf ",'%s'" "${VAL_COL[${INDEX}]}"
	fi
done

printf "%s\n" ")"

printf ";\n"

IFS=$CURR_IFS

return
}

#------------------------------------------------------------------------------
estandarizar_estado()
#------------------------------------------------------------------------------
{
# Se editan aca los contenidos de la columna esta para normalizarla

# Estado en					Estado en
# Planilla 					Tabla
#-----------------------------
# Asignado					ASIGNADO
# Disponible				DISPONIBLE
# No Disponible Temp.		NO_DISP_TEMP
# Interno					INTERNO	
# De Baja					DE_BAJA				(*) No sabemos si es correcto
# Con Restricciones			CON_RESTRICC		(*) No sabemos si es correcto
# Puntual					PUNTUAL				(*) No sabemos si es correcto
#

# Se editan aca los contenidos de la columna esta para estandarizarlos
# 

# SOlo estandarizar estado 

for cont in ${#ESTADO_EN_PLANILLA[@]}-1
do
	if [ ${VAL_COL[2]} = ${ESTADO_EN_PLANILLA[${$cont}]}   ]
	then
		${VAL_COL[2]}=${ESTADO_EN_TABLA[${$cont}]} 
		return
	fi
done


}


#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------
declare -a NOMBRE_COL
declare -a NCM_Lineas 
declare -a VAL_COL
declare -a ESPECIALIDADES
declare -i TOT_ESPEC i
declare -a LISTA_COLUMNAS
declare -a LISTA_COLUMNAS_1=(0 1 2 30 21)
# declare -a LISTA_COLUMNAS_2  ( habra que elegir las COLUMNAS )
declare -a LISTA_COLUMNAS_3=(30 100)
declare -a ESTADO_EN_PLANILLA ESTADO_EN_TABLA

run_data								#---->

DNI_NO_DISPONIBLE=""
CUIL_NO_DISPONIBLE="N/D"

SQL_SCRIPT_NAME="VOLS"
CSV_IN_FILE="../Datos/Libro2_V1.1.csv"
SQL_OUT_FILE=../SQL_Scripts/"${RUN_DATE_FILE}_${SQL_SCRIPT_NAME}"".sql"

TABLE_NAME_1="T_VOLS1"
TABLE_NAME_2="T_VOLS2"
TABLE_NAME_3="T_ESPECIALIDADES"

genera_banner								#---->

PATRON_CUIL="^ *[0-9]\{2\}\-[0-9]\{8\}\-[0-9]\{1\}"


# Estado en										Estado en
# Planilla 										Tabla
#---------------------------------------------------------------------------
ESTADO_EN_PLANILLA[0]="Asignado"			; ESTADO_EN_TABLA[0]="ASIGNADO"		
ESTADO_EN_PLANILLA[1]="Disponible"			; ESTADO_EN_TABLA[1]="DISPONIBLE"	
ESTADO_EN_PLANILLA[2]="No Disponible Temp."	; ESTADO_EN_TABLA[2]="NO_DISP_TEMP"
ESTADO_EN_PLANILLA[3]="Interno"				; ESTADO_EN_TABLA[3]="INTERNO"
ESTADO_EN_PLANILLA[4]="De Baja"				; ESTADO_EN_TABLA[4]="DE_BAJA"		(*) No sabemos si es correcto
ESTADO_EN_PLANILLA[5]="Con Restricciones"	; ESTADO_EN_TABLA[5]="CON_RESTRICC"	(*) No sabemos si es correcto
ESTADO_EN_PLANILLA[6]="Puntual"				; ESTADO_EN_TABLA[6]="PUNTUAL"		(*) No sabemos si es correcto



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
NOMBRE_COL[9]="array_especialidad"	#	J	Especialidad (parsear y a otra tabla)
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

# Columnas auxiliares para recibir datos parseados
NOMBRE_COL[100]="especialidad"
# NOMBRE_COL[101]=""


# echo ${NOMBRE_COL[0]} ${NOMBRE_COL[1]} ${NOMBRE_COL[2]} ${NOMBRE_COL[3]}


OLDIFS=$IFS
IFS=,

while IFS=','  read -ra VAL_COL
do
	procesar_dni_cuil								#---->
	
	if [ ${HAY_DNI} = "TRUE" ]
	then
#		printf "%s %s %s %s %s %s %s \n" ${VAL_COL[0]} ${VAL_COL[1]}  ${VAL_COL[21]} "dni=" ${DNI} "cuil" ${CUIL}

#		printf "(\`%s\`,\`%s\`,\`%s\`,\`%s\`)\n" ${NOMBRE_COL[0]} ${NOMBRE_COL[1]} ${NOMBRE_COL[30]} ${NOMBRE_COL[21]}
#		printf "('%s','%s','%s','%s')\n" ${VAL_COL[0]} ${VAL_COL[1]} ${VAL_COL[30]} ${VAL_COL[21]} 

        unset LISTA_COLUMNAS
        LISTA_COLUMNAS=("${LISTA_COLUMNAS_1[@]}")
        estandarizar_estado							#---->
		generar_insert ${TABLE_NAME_1}				#---->

        unset LISTA_COLUMNAS
        LISTA_COLUMNAS=("${LISTA_COLUMNAS_3[@]}")
		procesar_especialidad						#---->
	else
		printf "%s %s %s %s \n" "--"${VAL_COL[0]} ${VAL_COL[1]} "-->SIN_DNI"
	fi
		

	
done < ${CSV_IN_FILE}

IFS=$OLDIFS
	
