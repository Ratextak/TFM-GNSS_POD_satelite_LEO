#!/bin/bash

ruta_TFM="/mnt/c/users/Estrella/gnss-flex/TFM"

ruta_archivos="${ruta_TFM}/config_GNSS-SDR"
ruta_resultados="${ruta_TFM}/data/GNSS-SDR/"
ruta_signal="${ruta_TFM}/data/Spirent/2025_08_13_12_44_05.int8"

echo -e "Los resultados de todas las pruebas se guardarán en: ${ruta_resultados}\n"

#echo "---> Ejecutando la primera prueba..."
#gnss-sdr --config_file="${ruta_archivos}/Config_pruebitas.conf" --signal_source=$ruta_signal
#echo -e "~~~~~~~~ Primera prueba concluida ~~~~~~~~\n"

echo "------------------------------------------------------------------------------"
echo "---> Ejecutando la segunda prueba..."
gnss-sdr --config_file="${ruta_archivos}/Config_canal_para_cada_sat-GPS.conf" --signal_source=$ruta_signal
echo -e "~~~~~~~~ Segunda prueba concluida ~~~~~~~~\n"

# Demás pruebas...
