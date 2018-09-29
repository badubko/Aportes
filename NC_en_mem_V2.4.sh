#! /bin/bash

# V1.95 11/01/18 10:26:51 Creada esta version a partir de gen_NC_MEM_V4.5.sh
# 							para incluir en los 2 main.
#		15/05/18 20:37:34 Por las dudas se pasa la extension a minuscula 
#
#
#-----------------------------------------------------------------------------

lee_NC_a_mem ()
{
# Descartamos las lineas con comentarios y las lineas en blanco.
mapfile -t NCM_Lineas <  <( grep -v -e '^#.*' -e '^$' ${LISTA_FILES_NO_COPIAR} )
printf "Cant de Lineas de NC: %4s\n"  ${#NCM_Lineas[@]}


if [ ${#NCM_Lineas[@]} = 0  ]
then  # No hay elementos en el file NC
	NCM_NOMBRE="TRUCHEX"
	NCM_TAM_INDX[${NCM_NOMBRE}]="-1"
	NCM_FECHA_INDX[${NCM_NOMBRE}]="????"
	NCM_SINON_INDX[${NCM_NOMBRE}]=0
	return
fi

let NCM_TOT_LIN=${#NCM_Lineas[@]}-1
let NCM_linecount=0

while [ ${NCM_linecount} -le ${NCM_TOT_LIN} ]
do
	read NCM_NOMBRE NCM_TAM NCM_FECHA NCM_COMMENT <<<${NCM_Lineas[${NCM_linecount}]}
	
	NCM_TIPO_EXTENS=${NCM_NOMBRE##*.}  		# --->>>> Obtener Extension de tipo
   
	NCM_TIPO_EXTENS="${NCM_TIPO_EXTENS,,}" 		# Pasamos a minuscula el tipo de extension para simplificar la lista.
	
	NCM_NOMBRE=${NCM_NOMBRE%.*}"."${NCM_TIPO_EXTENS}  # Sustituimos la extension en minuscula
    
    if [ ${#NCM_TAM_INDX[${NCM_NOMBRE}]}  = 0 ]
	then  # No hay ocupante primario
		NCM_TAM_INDX[${NCM_NOMBRE}]=${NCM_TAM}
		NCM_FECHA_INDX[${NCM_NOMBRE}]=${NCM_FECHA}
		NCM_SINON_INDX[${NCM_NOMBRE}]=0    # Este es el primario, por lo tanto 
										   # el contador de sinonimos es "0"
	else  # Insertar sinonimos
		let NCM_SINON_INDX[${NCM_NOMBRE}]++    # Incrementamos el cont de sinonimos.
		cont=${NCM_SINON_INDX[${NCM_NOMBRE}]}  # Solo para tener una variable mas corta
											   # para el proximo paso
		NCM_TAM_INDX[${NCM_NOMBRE}"__D"${cont}]=${NCM_TAM}
		NCM_FECHA_INDX[${NCM_NOMBRE}"__D"${cont}]=${NCM_FECHA}
	fi
	let NCM_linecount++
done
	
	
	
}

#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
reporta_hallado_en_NC ()
{
if [ ${REPORTA_HALLADO_EN_NC} = "TRUE" ]
then
echo "Del Cel:            ${FNAME} ${Tam_file_cel} ${Fecha_file_cel} ${TIPO_ARCH} ${TIPO_NOM_ARCH} "		>> $ARCHIVO_LOG
echo "En N/C  ${EN_NO_COPIAR} -- ${1} --> ${2} ${NCM_TAM_INDX[${2}]:-N/A} ${NCM_FECHA_INDX[${2}]:-N/A} "   	>> $ARCHIVO_LOG
# printf "\n"
fi

}

#-----------------------------------------------------------------------------
buscar_en_NC_en_mem ()
{

if [ ${#NCM_TAM_INDX[${FNAME}]}  = 0 ]
then
    # Entonces:
	# NO esta en LISTA_FILES_NO_COPIAR
	EN_NO_COPIAR=NO
	reporta_hallado_en_NC 0 "NO_Esta"			#--------->>>#
	
	return
else #3   
	if [ ${Tam_file_cel} = 0 ] #2.2   # Podriamos preguntar ${Tam_file_cel} = 0 
	then
	    # Listo! no sabemos que archivo era, pero ya esta en NO_COPIAR
	    # Seguramente es un archivo que se corrompio en la "media"
	    EN_NO_COPIAR=SI
	    reporta_hallado_en_NC 1 ${FNAME}			#--------->>>#
	    return
	fi  #2.2	
		
    case ${TIPO_NOM_ARCH} in
 	GENERAL ) 
 		# En este caso al ser los nombres iguales consideramos que es el mismo archivo...
 		# ya que la fecha esta en el nombre.
 		# Aca asumimos que es poco probable que haya 2 archivos de contenido totalmente distinto
 		# con la misma fecha a nivel de HH:MM:SS...  
 		EN_NO_COPIAR=SI	
 		reporta_hallado_en_NC 2 ${FNAME}			#--------->>>#
 		return
 		;;
 	CANON | OTRA_COSA )
 		# Ya esta en LISTA_FILES_NO_COPIAR; pero ... ¿Es el mismo archivo?
 		
 		let cont=0
 		SUFIJO=""
 		
 #		set -xv
 		while [ ${cont} -le "${NCM_SINON_INDX[${FNAME}]}" ]
 		do
 		
 			INDEX=${FNAME}"${SUFIJO}"

 				# la Fecha_file_cel ya esta determinada previamente ya que 
 				# se averiguo en buscar_en_repositorio_V1.8 (y posteriores?) 
 				# FALSO lo de arriba: si el file no esta en el repositorio no
 				# se averigua la fecha...
                # El if 1.1 si tiene sentido... 
 				if [ "${Fecha_file_cel}" = "0" ]  #1.1
 				then
# 					echo "Fecha File Cel= ${Fecha_file_cel}  Se deberia averiguar"
 					Fecha_file_cel="$( obtener_fecha ${FNAME_FULL} )" #--------->>>#
 				fi #1.1
             if [ ${Fecha_file_cel} = "????" ] #2.5
	         then
				let Det_por_tamano_en_NC++   # 
				if [ "${Tam_file_cel}" = "${NCM_TAM_INDX[${INDEX}]}" ] #1.4
				then
				  EN_NO_COPIAR=SI
 				  reporta_hallado_en_NC 3 ${INDEX}		#--------->>>#
 				  return
 			    fi #1.4
 			 else #2.5	
 				# echo  "Fecha_cel ""${Fecha_file_cel}"  "NC_FECHA " "${NC_FECHA}"
 				if [ "${Fecha_file_cel}" = "${NCM_FECHA_INDX[${INDEX}]}" ] #1.5
 				then
					let Det_por_fecha_en_NC++
					EN_NO_COPIAR=SI
					reporta_hallado_en_NC 4 ${INDEX}	#--------->>>#
#					set +xv
 					return
 				fi  #1.5	
			fi #2.5
 			let cont++
 			SUFIJO="__D""${cont}"
 		done
		set +xv
		EN_NO_COPIAR=NO
		reporta_hallado_en_NC 5 ${INDEX}		#--------->>>#
	;;
	esac
	
fi #3	


}


