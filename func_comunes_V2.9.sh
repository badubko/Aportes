# !/bin/bash
#-------------------------------------------------------------------------------
# Funciones comunes a ser incluidas en los transformers

#-------------------------------------------------------------------------------
linea_guiones ()
{
echo "-- --------------------------------------------------------------"  
}

#-------------------------------------------------------------------------------
run_data()
#-------------------------------------------------------------------------------
{
# RUN_DATE Fecha y hora de la ejecucion del script
RUN_DATE="$(date  +\#\ %Y\/%m\/%d\ %H:%M)"
RUN_DATE_FILE="$(date  +%Y-%m-%d_%H%M)"    # Nuevo formato para usar en nombres de Archivo

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

#-------------------------------------------------------------------------------
genera_banner ()
#-------------------------------------------------------------------------------
{	
	
BANNER=$1

# Aca viene el banner y la lista de variables a incluir
DIR_REF=${PWD}


FLAG_TERM="FALSE"           # Si algun parametro no esta definido terminar temprano

if [ ! -f  "${CSV_IN_FILE}" ]
then
	echo "El Archivo ${CSV_IN_FILE} NO existe"
	exit
fi


case ${BANNER} in 
SQL_OUT_FILE )
	if [ !  -d "${SQL_OUT_FILE%/*}" ]
	then
	  echo "${NOM_ABREV}: No se puede generar: ${SQL_OUT_FILE} No existe el directorio"
	  exit
	fi

	  linea_guiones 										>${SQL_OUT_FILE}
	  echo "-- Nombre    :  ${SQL_OUT_FILE}"				>>${SQL_OUT_FILE}
	  echo "-- Creado por: $0     Run_date  : ${RUN_DATE}"	>>${SQL_OUT_FILE}
	  printf "%s\n" "--"									>>${SQL_OUT_FILE}
	  echo "-- Directorio Origen:  ${PWD}" 					>>${SQL_OUT_FILE}
	  echo "-- CSV_IN_FILE :				${CSV_IN_FILE}"	>>${SQL_OUT_FILE}
	  linea_guiones 										>>${SQL_OUT_FILE}
	# echo "-- Variables incluidas:"			  	        >>${SQL_OUT_FILE}	
;;
#------------------------------------------------------------------------------
ERROR_LOG )
	
	if [ ! -d "${ERROR_LOG%/*}" ]
	then
	  echo "${NOM_ABREV}: No se puede generar: ${ERROR_LOG} No existe el directorio"
	  exit
	fi

	  linea_guiones 										>${ERROR_LOG}
	  echo "-- Nombre    :  ${ERROR_LOG}"					>>${ERROR_LOG}
	  echo "-- Creado por: $0     Run_date  : ${RUN_DATE}"	>>${ERROR_LOG}
	  printf "%s\n" "--"									>>${ERROR_LOG}
	  echo "-- Directorio Origen:  ${PWD}" 					>>${ERROR_LOG}
	  echo "-- CSV_IN_FILE :				${CSV_IN_FILE}"	>>${ERROR_LOG}
	  linea_guiones 										>>${ERROR_LOG}
;;
#------------------------------------------------------------------------------
PRELIM_OUT_FILE )

	if [ ! -d "${PRELIM_OUT_FILE%/*}" ]
	then
	  echo "${NOM_ABREV}: No se puede generar: ${PRELIM_OUT_FILE} No existe el directorio"
	  exit
	fi


	  linea_guiones 										>${PRELIM_OUT_FILE}
	  echo "-- Nombre    :  ${PRELIM_OUT_FILE}"				>>${PRELIM_OUT_FILE}
	  echo "-- Creado por: $0     Run_date  : ${RUN_DATE}"	>>${PRELIM_OUT_FILE}
	  printf "%s\n" "--"									>>${PRELIM_OUT_FILE}
	  echo "-- Directorio Origen:  ${PWD}" 					>>${PRELIM_OUT_FILE}
	  echo "-- CSV_IN_FILE :				${CSV_IN_FILE}"	>>${PRELIM_OUT_FILE}
	  linea_guiones 										>>${PRELIM_OUT_FILE}
;;
* )
	echo "Valor imposible de banner" "${BANNER}"
	exit
;;
esac

return
}

#-------------------------------------------------------------------------------
validate_line()
#-------------------------------------------------------------------------------
{
	
if [ ${#VAL_COL[@]}  -ne ${NUM_COLS}     ]
then
	LINE_IS_VALID="FALSE"
	if [ ${#VAL_COL[@]} -le ${NUM_COLS}    ]
	then
		echo "Hay un c/r en la linea" "${VAL_COL[0]}" "${VAL_COL[1]}"
#		echo "Error   -->" ${VAL_COL[@]}
	else
		if [ ${#VAL_COL[@]} -gt ${NUM_COLS}  ]  # Este if se podria omitir...
		then
			echo "Hay DEMASIADAS comas en la linea" "${VAL_COL[0]}" "${VAL_COL[1]}"
#			echo "Error   -->" ${VAL_COL[@]}
		fi
	fi
else
    NUM_COL=0  						# Indice para recorrer las columnas
									# Eliminando caracteres espureos
	while [ ${NUM_COL} -le ${NUM_COLS} ]
	do
	  VAL_COL[${NUM_COL}]=${VAL_COL[${NUM_COL}]//\'/ }
	  let NUM_COL++
	done
    
	LINE_IS_VALID="TRUE"
fi	
return
}
#-------------------------------------------------------------------------------
