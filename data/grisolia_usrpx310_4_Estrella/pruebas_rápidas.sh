#!/bin/bash

ruta_TFM="/mnt/c/users/Estrella/gnss-flex/data/grisolia_usrpx310_4_Estrella"

ruta_config="${ruta_TFM}"
ruta_resultados="${ruta_TFM}/GNSS-SDR_1min"
ruta_signal="${ruta_TFM}/gps_L1_4msps.iq"

echo -e "Los resultados de todas las pruebas se guardarán en: ${ruta_resultados}\n"


echo "---> [1] Ejecutando las pruebas: canales dinámicos, sin High_dynamics, Max_lock_fail=50..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_sinHD-GPS"
num_pruebas=100
for ((i=0; i<$num_pruebas; i++))
do
	echo "---> [1] Ejecutando prueba $((i+1))/$num_pruebas..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_sinHD-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_sinHD-GPS_1min.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [1] Prueba $((i+1))/$num_pruebas concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [1] Pruebas concluidas ~~~~~~~~~~\n"

# echo "---> [2] Ejecutando las pruebas: canales estáticos, sin High_dynamics, Max_lock_fail=50..."
# echo "------------------------------------------------------------------------------"
# ruta_prueba="${ruta_resultados}/Estáticos_sinHD-GPS"
# num_pruebas=100
# for ((i=0; i<$num_pruebas; i++))
# do
	# echo "---> [2] Ejecutando prueba $((i+1))/$num_pruebas..."
	# ruta_subprueba="${ruta_prueba}/Estáticos_sinHD-Prueba$i"
	# mkdir -p $ruta_subprueba
	# sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_sinHD-GPS_1min.conf > ${ruta_config}/temp.conf
	# gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	# echo "~~~~~~ [2] Prueba $((i+1))/$num_pruebas concluida ~~~~~~"
# done
# echo -e "~~~~~~~~~~ [2] Pruebas concluidas ~~~~~~~~~~\n"

# Demás pruebas...
