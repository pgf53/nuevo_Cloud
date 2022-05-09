#!/bin/sh

echo "en el script de lanzamiento"
pwd
# Cargar variables de configuracion
. ${CLOUD_CONFIG_INTERNA}


clear
printf "\n\n%s\n\n%s\n" "¿Seguro que desea EJECUTAR la Tarea \"${NOMBRE_TAREA}\" en los equipos \"${EQUIPOS_LT}\"?." "Pulse una tecla para continuar... (Ctrl-C para Salir)"
[ "${FAST_MODE}" -eq 0 ] && read tecla

#Antes de proceder con el envío de la tarea comrobamos si se está ejecutando el script
#de recogida automática.

proceso=$(basename "${SCRIPT_MENSAJE_UDP}")
existe_proceso=$(ps ax | pgrep "${proceso}")
if [ "${existe_proceso}" = "" ]; then
	"${SCRIPT_LANZAR_ESCUCHA}"
else
	printf "Proceso de escucha en ejecución\n"
fi

printf "\nEjecutando Scripts de Estado...\n"
export TIPO_ESTADO="lanzamiento"
eval "${SCRIPT_ESTADO} \"${EQUIPOS_LT}\""

for i in ${EQUIPOS_LT}; do

	#Determinamos el tipo de acceso SSH
	. "${SCRIPT_CHECK_SSH}" "${i}"

	if [ "$(ls ${DIR_ESTRUCTURA_CLONADA}${PREFIJO_NOMBRE_EQUIPO}${i}/${SUBDIR_TAREA_ENTRADA})" ]; then
		printf "\n\n###### Ejecutando Tarea en Equipo LT$i (Tarea \"${NOMBRE_TAREA}\") ###########\n"


		# Ejecutar script remoto
		${SSH_COMANDO} "${USER_REMOTO}"@${PREFIJO_NOMBRE_EQUIPO}$i "cd ${DIR_REMOTO_ENVIO}; chmod +x ${FILE_SCRIPT_REMOTO} ${FILE_SCRIPT_ENVIA_UDP} ${FILE_SCRIPT_MONITORIZA_SALIDA}; ./${FILE_SCRIPT_REMOTO} $i"

		printf "\n\n\n### Tarea \"${NOMBRE_TAREA}\" lanzada en Equipo \"$i\"...\n\n"
	fi
done

rm -f "${VAR_MEMORIA_SALIR}"  1>/dev/null 2>&1
