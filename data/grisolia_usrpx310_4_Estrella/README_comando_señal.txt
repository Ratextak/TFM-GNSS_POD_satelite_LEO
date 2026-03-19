labnav@labnav-Raider-GE78-HX-14VGG:~/test$ uhd_rx_cfile gps_l1_4msps_10min.sc16 \
 --args="addr=192.168.30.2" \
 -f 1575.42e6 \
 -r 4000000 \
 -g 25 \
 -N 2400000000 \
 -s --wire-format=sc16
[INFO] [UHD] linux; GNU C++ version 13.2.0; Boost_108300; UHD_4.6.0.0+ds1-5.1ubuntu0.24.04.1
[INFO] [X300] X300 initialization sequence...
[INFO] [X300] Maximum frame size: 8000 bytes.
[INFO] [GPS] Found an internal GPSDO: LC_XO, Firmware Rev 0.929a
[INFO] [X300] Radio 1x clock: 200 MHz
labnav@labnav-Raider-GE78-HX-14VGG:~/test$ ls
gps_l1_4msps_10min.sc16  gps_l1_4msps.dat
labnav@labnav-Raider-GE78-HX-14VGG:~/test$ 

