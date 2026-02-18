#!/bin/bash

ruta_TFM="/mnt/c/users/Estrella/gnss-flex/TFM"

ruta_config="${ruta_TFM}/config_GNSS-SDR"
ruta_resultados="${ruta_TFM}/data/GNSS-SDR"
ruta_signal="${ruta_TFM}/data/Spirent/2025_08_13_12_44_05.int8"

echo -e "Los resultados de todas las pruebas se guardarán en: ${ruta_resultados}\n"

#echo "---> Ejecutando la primera prueba..."
#gnss-sdr --config_file="${ruta_config}/Config_pruebitas.conf" --signal_source=$ruta_signal --log_dir="${ruta_resultados}/GPS_Galileo"
#echo -e "~~~~~~~~ Primera prueba concluida ~~~~~~~~\n"

#echo "------------------------------------------------------------------------------"
#echo "---> Ejecutando la segunda prueba..."
#gnss-sdr --config_file="${ruta_config}/Config_canal_para_cada_sat-GPS.conf" --signal_source=$ruta_signal --log_dir="${ruta_resultados}/Canal_para_cada_satélite"
#echo -e "~~~~~~~~ Segunda prueba concluida ~~~~~~~~\n"

#echo "------------------------------------------------------------------------------"
#echo "---> Ejecutando la tercera prueba..."
#gnss-sdr --config_file="${ruta_config}/Config_canal_para_cada_sat-GPS.conf" --signal_source=$ruta_signal --log_dir="${ruta_resultados}/Arreglo_chi-cuadrado"
#echo -e "~~~~~~~~ Tercera prueba concluida ~~~~~~~~\n"

#echo "------------------------------------------------------------------------------"
#echo "---> Ejecutando la cuarta prueba..."
#gnss-sdr --config_file="${ruta_config}/Config_canal_para_cada_sat-GPS(max_lock_fail).conf" --signal_source=$ruta_signal --log_dir="${ruta_resultados}/Max_lock_fail"
#echo -e "~~~~~~~~ Cuarta prueba concluida ~~~~~~~~\n"

#echo "------------------------------------------------------------------------------"
#echo "---> Ejecutando la quinta prueba..."
#gnss-sdr --config_file="${ruta_config}/Config_canal_para_cada_sat-GPS(high_dynamics).conf" --signal_source=$ruta_signal --log_dir="${ruta_resultados}/High_dynamics"
#echo -e "~~~~~~~~ Quinta prueba concluida ~~~~~~~~\n"

#echo "------------------------------------------------------------------------------"
#echo "---> Ejecutando la sexta prueba..."
#gnss-sdr --config_file="${ruta_config}/Config_canal_para_cada_sat-GPS(combinación).conf" --signal_source=$ruta_signal --log_dir="${ruta_resultados}/Combinación"
#echo -e "~~~~~~~~ Sexta prueba concluida ~~~~~~~~\n"

#echo "------------------------------------------------------------------------------"
#echo "---> Ejecutando la séptima prueba..."
#gnss-sdr --config_file="${ruta_config}/Config_canal_para_cada_sat-GPS(max_lock_fail_5).conf" --signal_source=$ruta_signal --log_dir="${ruta_resultados}/Max_lock_fail_5"
#echo -e "~~~~~~~~ Séptima prueba concluida ~~~~~~~~\n"

echo -e "----------------------- BATERÍA DE PRUEBAS -----------------------\n"

echo "---> [1] Ejecutando las pruebas: canales estáticos, High_dynamics y Max_lock_fail=50..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Estáticos_HD_MLF50-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [1] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Estáticos_HD_MLF50-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_HD_MLF50-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [1] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [1] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [2] Ejecutando las pruebas: canales estáticos, sin High_dynamics y Max_lock_fail=50..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Estáticos_sinHD_MLF50-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [2] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Estáticos_sinHD_MLF50-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_sinHD_MLF50-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [2] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [2] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [3] Ejecutando las pruebas: canales estáticos, High_dynamics y Max_lock_fail=20..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Estáticos_HD_MLF20-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [3] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Estáticos_HD_MLF20-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_HD_MLF20-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [3] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [3] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [4] Ejecutando las pruebas: canales estáticos, sin High_dynamics y Max_lock_fail=20..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Estáticos_sinHD_MLF20-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [4] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Estáticos_sinHD_MLF20-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_sinHD_MLF20-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [4] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [4] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [5] Ejecutando las pruebas: canales estáticos, High_dynamics y Max_lock_fail=5..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Estáticos_HD_MLF5-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [5] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Estáticos_HD_MLF5-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_HD_MLF5-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [5] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [5] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [6] Ejecutando las pruebas: canales estáticos, sin High_dynamics y Max_lock_fail=5..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Estáticos_sinHD_MLF5-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [6] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Estáticos_sinHD_MLF5-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_estáticos_sinHD_MLF5-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [6] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [6] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [7] Ejecutando las pruebas: canales dinámicos, High_dynamics y Max_lock_fail=50..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_HD_MLF50-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [7] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_HD_MLF50-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_HD_MLF50-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [7] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [7] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [8] Ejecutando las pruebas: canales dinámicos, sin High_dynamics y Max_lock_fail=50..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_sinHD_MLF50-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [8] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_sinHD_MLF50-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_sinHD_MLF50-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [8] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [8] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [9] Ejecutando las pruebas: canales dinámicos, High_dynamics y Max_lock_fail=20..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_HD_MLF20-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [9] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_HD_MLF20-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_HD_MLF20-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [9] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [9] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [10] Ejecutando las pruebas: canales dinámicos, sin High_dynamics y Max_lock_fail=20..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_sinHD_MLF20-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [10] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_sinHD_MLF20-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_sinHD_MLF20-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [10] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [10] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [11] Ejecutando las pruebas: canales dinámicos, High_dynamics y Max_lock_fail=5..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_HD_MLF5-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [11] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_HD_MLF5-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_HD_MLF5-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [11] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [11] Pruebas concluidas ~~~~~~~~~~\n"

echo "---> [12] Ejecutando las pruebas: canales dinámicos, sin High_dynamics y Max_lock_fail=5..."
echo "------------------------------------------------------------------------------"
ruta_prueba="${ruta_resultados}/Dinámicos_sinHD_MLF5-GPS"
for ((i=0; i<10; i++))
do
	echo "---> [12] Ejecutando prueba $((i+1))/10..."
	ruta_subprueba="${ruta_prueba}/Dinámicos_sinHD_MLF5-Prueba$i"
	mkdir -p $ruta_subprueba
	sed "s|RUTA_SUBPRUEBA|${ruta_subprueba}|g" ${ruta_config}/Config_dinámicos_sinHD_MLF5-GPS.conf > ${ruta_config}/temp.conf
	gnss-sdr --config_file="${ruta_config}/temp.conf" --signal_source=$ruta_signal --log_dir=$ruta_subprueba 
	echo "~~~~~~ [12] Prueba $((i+1))/10 concluida ~~~~~~"
done
echo -e "~~~~~~~~~~ [12] Pruebas concluidas ~~~~~~~~~~\n"

# Demás pruebas...
