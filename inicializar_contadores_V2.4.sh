#!/bin/bash
#-------------------------------------------------------------------------------
# inicializar_contadores
#-------------------------------------------------------------------------------
# Version:
#         0.6 01/08/17 11:48:58  Creado este file, copiando de Gen_list...V0.6
#	  0.8 07/08/17 14:41:03  Agregado de contadores para Dir0 y Dir1
#			Se agrego variable EN_AMBOS_REP y INF_REV_Y_NO_COPIAR
#	      24/08/17 23:24:52  Se agrego declare -A Lista_files_index; 
#	      25/08/17 18:28:47 se pone como comentario
#	  1.1 25/08/17 21:37:41 Deja de ser una funcion para ser un "include"
#                               Se agrega definicion de arrays:  Lista_files_index  Tam_file
#          	04/09/17 10:50:38 Se agrega array asociativo Fecha_File
#	       	07/09/17 22:57:33 Se agrega la variable Det_por_fecha
#	       	10/09/17 12:52:42 Se agrega variable TOT_ESPUREOS_CEL
#	       	11/09/17 12:33:01 Se agregan variables   Tipo_Canon Tipo_General Tipo_Otra_Cosa
#			15/09/17 11:23:37 Se agrega la inicializacion en "NO"
#			22/09/17 01:15:59 Se agrega array indexado Lista_files_estr_temp
#			26/09/17 22:08:42 Se agregan contadores de Foto y Video
#     1.7	04/10/17 20:54:58 Se agregan variables para Lista files NO COPIAR en memoria
#							  NO IMPLEMENTADO as of 28/11/17 00:25:44
# 	1.8		22/11/17 15:16:33 Se agregan nuevos contadores como EN_AMBOS_REP_Y_NO_COPIAR		 
#			26/11/17 13:51:54 Se agrega array CONT_ESTADO, que contedra el conteo de todos los casos.
#			27/11/17 11:20:54 Se agregan los arrays de titulos para la impresion de reportes de estado
#							  Se agrega la lista de colores y las matrices con colores y sin colores
#	1.9		05/12/17 21:34:18 Se agregan arrays para Gen_list_files_NO_copiar
#	1.91	06/12/17 12:43:30 Se agregaron arrays para computo tiempos
#			08/01/18 11:10:30 Se agrego la variable del contador Det_por_tamano
#			09/01/18 12:24:14 Se agregaron las variables  Det_por_fecha_en_NC Det_por_tamano_en_NC
#			22/01/18 19:02:31 Se agrego declare -iA CANT_CANON CANT_GENERAL CANT_OTRA_COSA
#	2.0		16/04/18 13:01:38 Se agregan variables REP_CANT_SINON
#			23/04/18 15:38:47 Se agregan variables UNZIPED Z_TOT_FILES Z_TOT_ESPUREOS
#			12/05/18 22:14:18 Se agrego REP_CANT_COP

# Contadores en cero.

#  declare -i TOT_FILES_DEL_CEL=0

let INF_REV=0
let INF_REV_Y_NO_COPIAR=0
let NO_ACCION=0
let AGR_A_ESTR_TEMP=0
let AGR_A_NO_COPIAR=0

let TAM_EQ0=0
let TAM_GT0=0

let ESTABA_EN_NO_COPIAR=0
let ESTABA_EN_ESTR_TEMP=0

let EN_AMBOS_REP=0
let EN_AMBOS_REP_Y_NO_COPIAR=0

declare -a EN_REPOS=(NO NO)      	# Previendo que solo usemos 1 repositorio, para evitar que la "regla" falle
declare -ai ESTABA_EN_REPOSIT=(0 0)



declare -A Lista_files_index  # Los indices seran ${PREFIJO[$NUM_REPOS]}${FNAME}
declare -A Tam_File
declare -A Fecha_File
declare -iA REP_CANT_SINON     # La cantidad de sinonimos (Duplicados) encontrados para ese FNAME
declare -iA REP_CANT_COP		# La cantidad de Copias encontradas para ese FNAME

declare -A UNZIPED			   # TRUE  si el arch estaba en un zip (o FALSE)
declare -i Z_TOT_FILES
declare -i Z_TOT_ESPUREOS


declare -A Lista_files_estr_temp

let EQ0_Y_EN_REP=0

# No se usan por limitacion del case.
# EXT_TIPO_VIDEO='WAV | wav | 3gp | AVI | avi | MOV | mov | mp4' 
# EXT_TIPO_FOTO='jpg | jpeg'

let Tipo_Foto=0
let Tipo_Video=0

let Tipo_Canon=0        
let Tipo_General=0
let Tipo_Otra_Cosa=0

let Tot_Tipo_Canon=0        
let Tot_Tipo_General=0
let Tot_Tipo_Otra_Cosa=0

let Det_por_fecha=0       # Contabilizamos para ver realmente cuantos casos de esto hubo
let Det_por_tamano=0

let Det_por_fecha_en_NC=0
let Det_por_tamano_en_NC=0

let TOT_ESPUREOS_CEL=0

# Array para el computo de tiempos

declare -iA TIEMPO
declare -iA ACUM_TIEMPOS


# Para Lista_files_No_Copiar en array
declare -a NCM_Lineas 
declare -a NCM_Lin_pru  # Solo para la prueba de concepto --->> ELIMINAR
declare -i NCM_linecount NCM_TOT_LIN
declare -A NCM_TAM_INDX NCM_FECHA_INDX 
declare -iA NCM_SINON_INDX

#---------------------------------------------------------------------------------------
#	V2.2 13/06/18 12:17:12 Inclusion de variables que vienen de vars_misc (antes
#						 en carga_parametros)
#---------------------------------------------------------------------------------------	
# RUN_DATE Fecha y hora de la ejecucion del script
RUN_DATE="$(date  +\#\ %Y\/%m\/%d\ %H:%M)"
RUN_DATE_FILE="$(date  +%Y-%m-%d_%H%M)"    # Nuevo formato para usar en nombres de Archivo



#-------------------------------------------------------------------------------------
# Nombre abreviado del script en ejecucion... para que los mensajes sean mas legibles.

VERS=${0##*_} 		# Elimina /abc/def/ghi/./Gen_list_files_cel_NO_copiar_  Queda "V0.5.sh"
VERS=${VERS%.*} 	# Elimina ".sh"  Queda "V0.5"

COM=${0%_*}    				#; echo $COM   # ELimina "_V0.5.sh"
COM=${COM##*/} 				#; echo $COM   # Elimina "/abc/def/ghi/./"
COMANDO_COMPLETO=${COM}   	# Para determinar que secciones ejecutar en Verifica.. y Genera
COM=${COM:0:4} 				#; echo $COM   # Solo los primeros 4 caracteres

NOM_ABREV=${COM}'..'${VERS}

#-------------------------------------------------------------------------------------
#
# String para convertir fecha de exiftool   
#             AAAA:MM:DD HH:MM:SS
# a formato   AAAA-MM-DD_HH:MM:SS

Str_conv_fecha='s/.*([0-9]{4}):([0-9]{2}):([0-9]{2}) (.*)/\1-\2-\3_\4/'

#------------------------------------------------------------------------------------

# Colores para impresion

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Matriz de contadores de Estado

declare -a EN_REPOS=(NO NO)

declare -iA CONT_ESTADO
declare -iA CANT_CANON CANT_GENERAL CANT_OTRA_COSA

declare -A TITULO_F           # Titulos para Fotos_cel_a_Est_Temp
declare -A TITULO_F_NC

declare -A TITULO_G			  # Titulos para Gen_list_files_cel_NO_copiar
declare -A TITULO_G_NC

# Definir colores

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Para Fotos_Cel_a_Estr_Temp

# TITULOS para la matriz de contadores de ESTADO
# Con los Colores

TITULO_F[GT0_SI_NO_NO]="${GREEN}En Rep1${NORMAL}"
TITULO_F[GT0_NO_SI_NO]="${GREEN}En Rep0${NORMAL}"
TITULO_F[GT0_NO_NO_SI]="${GREEN}En N/C ${NORMAL}"
TITULO_F[GT0_SI_SI_NO]="${YELLOW}En Ambos Rep${NORMAL}"
TITULO_F[GT0_SI_NO_SI]="${YELLOW}En Rep1 y N/C${NORMAL}"
TITULO_F[GT0_NO_SI_SI]="${YELLOW}En Rep0 y N/C${NORMAL}"
TITULO_F[GT0_SI_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_F[GT0_NO_NO_NO]="${GREEN}En NINGUN lado${NORMAL}"

TITULO_F[EQ0_SI_NO_NO]="${YELLOW}En Rep1${NORMAL}"
TITULO_F[EQ0_NO_SI_NO]="${YELLOW}En Rep0${NORMAL}"
TITULO_F[EQ0_NO_NO_SI]="${GREEN}En N/C ${NORMAL}"
TITULO_F[EQ0_SI_SI_NO]="${YELLOW}En Ambos Rep${NORMAL}"
TITULO_F[EQ0_SI_NO_SI]="${YELLOW}En Rep1 y N/C${NORMAL}"
TITULO_F[EQ0_NO_SI_SI]="${YELLOW}En Rep0 y N/C${NORMAL}"
TITULO_F[EQ0_SI_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_F[EQ0_NO_NO_NO]="${GREEN}En NINGUN lado${NORMAL}"

# Sin los colores

TITULO_F_NC[GT0_SI_NO_NO]="En Rep1"
TITULO_F_NC[GT0_NO_SI_NO]="En Rep0"
TITULO_F_NC[GT0_NO_NO_SI]="En N/C "
TITULO_F_NC[GT0_SI_SI_NO]="En Ambos Rep"
TITULO_F_NC[GT0_SI_NO_SI]="En Rep1 y N/C"
TITULO_F_NC[GT0_NO_SI_SI]="En Rep0 y N/C"
TITULO_F_NC[GT0_SI_SI_SI]="-->CASO ANOMALO"
TITULO_F_NC[GT0_NO_NO_NO]="En NINGUN lado"

TITULO_F_NC[EQ0_SI_NO_NO]="En Rep1"
TITULO_F_NC[EQ0_NO_SI_NO]="En Rep0"
TITULO_F_NC[EQ0_NO_NO_SI]="En N/C "
TITULO_F_NC[EQ0_SI_SI_NO]="En Ambos Rep"
TITULO_F_NC[EQ0_SI_NO_SI]="En Rep1 y N/C"
TITULO_F_NC[EQ0_NO_SI_SI]="En Rep0 y N/C"
TITULO_F_NC[EQ0_SI_SI_SI]="-->CASO ANOMALO"
TITULO_F_NC[EQ0_NO_NO_NO]="En NINGUN lado"

#-------------------------------------------------------------------------------
# Para Gen_List_Files_NO_Copiar

# Con los Colores

# Regla2 V2.0
# TAM GT0
# CONT  EN_REPOS1 EN_REPOS0  EN_NO_COPIAR EN_ESTR_TEMP ACCION      
# 1         SI      NO          NO          NO			NADA      	<- Fue copiado antes
# 2         SI      NO          NO          SI       	INFORMAR <- !!! Es un error !!!
# 3         SI      NO          SI          NO       	INFORMAR <- !!! Es un error !!!
# 4         SI      NO          SI          SI       	INFORMAR <- !!! Es un error !!!

# 5         SI      SI          NO          NO       	INFORMAR    !!! Es un error !!!	<- EN_AMBOS_REP
# 6         SI      SI          NO          SI       	INFORMAR <- !!! Es un error !!! <- EN_AMBOS_REP
# 7         SI      SI          SI          NO       	INFORMAR <- !!! Es un error !!! <- EN_AMBOS_REP
# 8         SI      SI          SI          SI       	INFORMAR <- !!! Es un error !!!	<- EN_AMBOS_REP

# 9          NO      NO          NO          NO  --->   Agregar a N/C 	<-fue eliminado de Es/Temp
# 10         NO      NO          NO          SI         NADA       	<- Se movera a REPOS 1 o 0
# 11         NO      NO          SI          NO       	NADA       	<- Fue marcado N/C antes
# 12         NO      NO          SI          SI       	INFORMAR<- !!! Es un error !!!

# 13         NO      SI          NO          NO       	NADA       	<- Fue copiado antes
# 14         NO      SI          NO          SI       	INFORMAR <- !!! Es un error !!!
# 15         NO      SI          SI          NO       	INFORMAR <- !!! Es un error !!!
# 16         NO      SI          SI          SI 		INFORMAR <- !!! Es un error !!!

TITULO_G[GT0_SI_NO_NO_NO]="${GREEN}En Rep1${NORMAL}"
TITULO_G[GT0_SI_NO_NO_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[GT0_SI_NO_SI_NO]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[GT0_SI_NO_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"

TITULO_G[GT0_SI_SI_NO_NO]="${YELLOW}En Ambos Rep${NORMAL}"
TITULO_G[GT0_SI_SI_NO_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[GT0_SI_SI_SI_NO]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[GT0_SI_SI_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"

TITULO_G[GT0_NO_NO_NO_NO]="${GREEN}En NINGUN lado${NORMAL}"
TITULO_G[GT0_NO_NO_NO_SI]="${GREEN}En Es/Temp${NORMAL}"
TITULO_G[GT0_NO_NO_SI_NO]="${GREEN}En N/C ${NORMAL}"
TITULO_G[GT0_NO_NO_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"

TITULO_G[GT0_NO_SI_NO_NO]="${GREEN}En Rep0${NORMAL}"
TITULO_G[GT0_NO_SI_NO_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[GT0_NO_SI_SI_NO]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[GT0_NO_SI_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"

   
# Regla2 V2.0
# TAM EQ0
# CONT  EN_REPOS1 EN_REPOS0  EN_NO_COPIAR EN_ESTR_TEMP          
# 1         SI      NO          NO          NO          Agregar a NO COPIAR; Reportar; Verif TAM en Repos? 
#														Posiblemente archivo que se corrompio en cel
# 2         SI      NO          NO          SI          INFORMAR <- !!! Es un error !!!
# 3         SI      NO          SI          NO          INFORMAR <- !!! Es un error !!! (????)
# 4         SI      NO          SI          SI          INFORMAR <- !!! Es un error !!!

# 5         SI      SI          NO          NO          INFORMAR 	<- EN_AMBOS_REP 
# 6         SI      SI          NO          SI          INFORMAR <- !!! Es un error !!!
# 7         SI      SI          SI          NO          INFORMAR 	<- EN_AMBOS_REP Se corrompio en cel
#														y ya se agrego a N/C
# 8         SI      SI          SI          SI          INFORMAR <- !!! Es un error !!!

# 9         NO      NO          NO          NO  --->    Agregar a N/C    
# 10         NO      NO          NO          SI         INFORMAR <- !!! Es un error !!!
# 11         NO      NO          SI          NO         NADA <-- Fue marcado N/C antes
# 12         NO      NO          SI          SI         INFORMAR <- !!! Es un error !!!

# 13         NO      SI          NO          NO         Agregar a NO COPIAR; Reportar; Verif TAM en Repos? 
#														Posiblemente archivo que se corrompio en cel
# 14         NO      SI          NO          SI         INFORMAR <- !!! Es un error !!!
# 15         NO      SI          SI          NO         INFORMAR <- !!! Es un error !!!  (????)       
# 16         NO      SI          SI          SI         INFORMAR <- !!! Es un error !!!
#

TITULO_G[EQ0_SI_NO_NO_NO]="${YELLOW}En Rep1${NORMAL}"
TITULO_G[EQ0_SI_NO_NO_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[EQ0_SI_NO_SI_NO]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[EQ0_SI_NO_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"

TITULO_G[EQ0_SI_SI_NO_NO]="${YELLOW}En Ambos Rep${NORMAL}"
TITULO_G[EQ0_SI_SI_NO_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[EQ0_SI_SI_SI_NO]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[EQ0_SI_SI_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"

TITULO_G[EQ0_NO_NO_NO_NO]="${GREEN}En NINGUN lado${NORMAL}"
TITULO_G[EQ0_NO_NO_NO_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[EQ0_NO_NO_SI_NO]="${GREEN}En N/C ${NORMAL}"
TITULO_G[EQ0_NO_NO_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"

TITULO_G[EQ0_NO_SI_NO_NO]="${YELLOW}En Rep0${NORMAL}"
TITULO_G[EQ0_NO_SI_NO_SI]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[EQ0_NO_SI_SI_NO]="${RED}-->CASO ANOMALO${NORMAL}"
TITULO_G[EQ0_NO_SI_SI_SI]="${RED}-->CASO ANOMALO${NORMAL}"


# Sin los colores

# GT0

TITULO_G_NC[GT0_SI_NO_NO_NO]="En Rep1"
TITULO_G_NC[GT0_SI_NO_NO_SI]="-->CASO ANOMALO"
TITULO_G_NC[GT0_SI_NO_SI_NO]="-->CASO ANOMALO"
TITULO_G_NC[GT0_SI_NO_SI_SI]="-->CASO ANOMALO"

TITULO_G_NC[GT0_SI_SI_NO_NO]="En Ambos Rep"
TITULO_G_NC[GT0_SI_SI_NO_SI]="-->CASO ANOMALO"
TITULO_G_NC[GT0_SI_SI_SI_NO]="-->CASO ANOMALO"
TITULO_G_NC[GT0_SI_SI_SI_SI]="-->CASO ANOMALO"

TITULO_G_NC[GT0_NO_NO_NO_NO]="En NINGUN lado"
TITULO_G_NC[GT0_NO_NO_NO_SI]="En Es/Temp"
TITULO_G_NC[GT0_NO_NO_SI_NO]="En N/C "
TITULO_G_NC[GT0_NO_NO_SI_SI]="-->CASO ANOMALO"

TITULO_G_NC[GT0_NO_SI_NO_NO]="En Rep0"
TITULO_G_NC[GT0_NO_SI_NO_SI]="-->CASO ANOMALO"
TITULO_G_NC[GT0_NO_SI_SI_NO]="-->CASO ANOMALO"
TITULO_G_NC[GT0_NO_SI_SI_SI]="-->CASO ANOMALO"

# EQ0

TITULO_G_NC[EQ0_SI_NO_NO_NO]="En Rep1"
TITULO_G_NC[EQ0_SI_NO_NO_SI]="-->CASO ANOMALO"
TITULO_G_NC[EQ0_SI_NO_SI_NO]="-->CASO ANOMALO"
TITULO_G_NC[EQ0_SI_NO_SI_SI]="-->CASO ANOMALO"

TITULO_G_NC[EQ0_SI_SI_NO_NO]="En Ambos Rep"
TITULO_G_NC[EQ0_SI_SI_NO_SI]="-->CASO ANOMALO"
TITULO_G_NC[EQ0_SI_SI_SI_NO]="-->CASO ANOMALO"
TITULO_G_NC[EQ0_SI_SI_SI_SI]="-->CASO ANOMALO"

TITULO_G_NC[EQ0_NO_NO_NO_NO]="En NINGUN lado"
TITULO_G_NC[EQ0_NO_NO_NO_SI]="-->CASO ANOMALO"
TITULO_G_NC[EQ0_NO_NO_SI_NO]="En N/C "
TITULO_G_NC[EQ0_NO_NO_SI_SI]="-->CASO ANOMALO"

TITULO_G_NC[EQ0_NO_SI_NO_NO]="En Rep0"
TITULO_G_NC[EQ0_NO_SI_NO_SI]="-->CASO ANOMALO"
TITULO_G_NC[EQ0_NO_SI_SI_NO]="-->CASO ANOMALO"
TITULO_G_NC[EQ0_NO_SI_SI_SI]="-->CASO ANOMALO"

#-------------------------------------------------------------------------------
