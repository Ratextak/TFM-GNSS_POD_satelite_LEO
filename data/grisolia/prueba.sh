#!/bin/bash

ruta_TFM="/mnt/c/users/Estrella/gnss-flex/data/grisolia"

ruta_config="${ruta_TFM}"
ruta_resultados="${ruta_TFM}/GNSS-SDR"
ruta_signal="${ruta_TFM}/static_spirent_8bits_8.192msps_1antenna.dat"

echo -e "Los resultados de todas las pruebas se guardarán en: ${ruta_resultados}\n"


echo "---> Ejecutando las pruebas: canales dinámicos, sin High_dynamics, Max_lock_fail=50..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_sinHD_MLF50-GPS"
num_pruebas=15
for ((i=0; i<$num_pruebas; i++))
do
	echo "---> Ejecutando prueba $((i+1))/$num_pruebas..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_sinHD_MLF50-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_sinHD_MLF50-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ Prueba $((i+1))/$num_pruebas concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ Pruebas concluidas ~~~~~~~~~~\n"

echo "---> Ejecutando las pruebas: canales estáticos, sin High_dynamics, Max_lock_fail=50..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Estáticos_sinHD_MLF50-GPS"
num_pruebas=15
for ((i=0; i<$num_pruebas; i++))
do
	echo "---> Ejecutando prueba $((i+1))/$num_pruebas..."
	ruta_subprueba="${ruta_prueba}/Estáticos_sinHD_MLF50-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_sinHD_MLF50-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ Prueba $((i+1))/$num_pruebas concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ Pruebas concluidas ~~~~~~~~~~\n"

# Demás pruebas...
