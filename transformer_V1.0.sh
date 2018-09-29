# !/bin/bash
#-------------------------------------------------------------------------------
# Formatear datos
#-------------------------------------------------------------------------------
# Version:


declare -a NOMBRE_COL
declare -a NCM_Lineas 
declare -a VAL_COL

LISTADO_DATOS="../Datos/Libro2_V1.0.csv"

if [ ! -f  "${LISTADO_DATOS}" ]
then
	echo "El Archivo ${LISTADO_DATOS} NO existe"
	exit
fi

# NOMBRE_COL[Indice]		COL			Nombre Excel

NOMBRE_COL[0]="apellido"		#	A	Apellido
NOMBRE_COL[1]="nombres"			#	B	Nombre	
NOMBRE_COL[2]="estado"			#	C	Estado
NOMBRE_COL[3]="comentarios"		#	D	Comentarios
NOMBRE_COL[4]="F_ingreso"		#	E	Fecha de ingreso
NOMBRE_COL[5]="socio"			#	F	Socio
NOMBRE_COL[6]=""				# 	G	Proyectos	 N/A
NOMBRE_COL[7]=""				#	H	Area de trabajo del proyecto
NOMBRE_COL[8]=""				#	I	Aptitud
NOMBRE_COL[9]="especialidad"	#	J	Especialidad (parsear y a otra tabla)
NOMBRE_COL[10]=""				#	K	Asertividad
NOMBRE_COL[11]=""				#	L	Sociabilidad
NOMBRE_COL[12]=""				#	M	Actitud
NOMBRE_COL[13]=""				#	N	Talleres
NOMBRE_COL[14]=""				#	O	Actividades
NOMBRE_COL[15]="acuerdo"		#	P	Acuerdo
NOMBRE_COL[16]=""				#	Q	Z
NOMBRE_COL[17]="telefono_1"		#	R	Telefono 1
NOMBRE_COL[18]=""				#	S	Presentacion
NOMBRE_COL[19]="referido_por"	#	T	Referido por
NOMBRE_COL[20]="telefono_2"		#	U	Telefono 2
NOMBRE_COL[21]="cuil"			#	V	CUIL	
NOMBRE_COL[22]="e_mail"			#	W	E-mail
NOMBRE_COL[23]="entrevistado_por" # X	Entrevistado por
NOMBRE_COL[24]=""				#	Y	Item type
NOMBRE_COL[25]=""				#	Z	PATH


# mapfile -t NCM_Lineas <  <( grep -v -e '^#.*' -e '^$' ${LISTADO_DATOS} )
mapfile -t NCM_Lineas <  <(cat ${LISTADO_DATOS} )
printf "Cant de Lineas de Datos: %4s\n"  ${#NCM_Lineas[@]}

let NCM_TOT_LIN=${#NCM_Lineas[@]}-1
let NCM_linecount=0

echo ${NOMBRE_COL[0]} ${NOMBRE_COL[1]} ${NOMBRE_COL[2]} ${NOMBRE_COL[3]}

IFS=,
while [ ${NCM_linecount} -le ${NCM_TOT_LIN} ]
do
	read -ra VAL_COL <<<${NCM_Lineas[${NCM_linecount}]}
	
	echo ${VAL_COL[0]} ${VAL_COL[1]} ${VAL_COL[2]} ${VAL_COL[3]}
#	echo ${VAL_COL[0]} 
	printf "\n"
	let NCM_linecount++
done

#INPUT=data.cvs
#OLDIFS=$IFS
#IFS=,
#[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
#while read flname dob ssn tel status
#do
	#echo "Name : $flname"
	#echo "DOB : $dob"
	#echo "SSN : $ssn"
	#echo "Telephone : $tel"
	#echo "Status : $status"
#done < $INPUT
#IFS=$OLDIFS
	
