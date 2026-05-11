# GNSS-FLEX — Branch `Estrella`

GNSS-FLEX is a MATLAB toolkit for evaluating and comparing GNSS receiver performance across different hardware implementations. The project originated at INTA/UCLM in the context of airborne GNSS research and produces analysis figures and statistics for conference papers and technical reports.

This branch, **Estrella**, adds a ground test campaign (Grisolia, 2026-03-16) using a **USRP X310 4-antenna array** running GNSS-SDR, designed to characterise the impact of Heading Determination (HD) and a Max-Likelihood Filter (MLF) on positioning observables.

---

## Context

### Receivers under test

| Tag | Hardware | Format |
|-----|----------|--------|
| **EME Rx Basic** | Custom software-defined receiver (basic) | Binary `.dat` (187-byte PVT blocks) |
| **EME Rx Advanced** | Custom software-defined receiver (advanced) | Binary `.dat` |
| **MOSAIC-X5** | Septentrio Mosaic X5 (commercial reference) | `.sbf` → ASCII PVT + RINEX |
| **GNSS-SDR** | Open-source SDR on USRP X310 (4 ant.) | RINEX `.26O` + GNSS-SDR logs |

### Data campaigns

| Campaign | Location | Date | Condition |
|----------|----------|------|-----------|
| CEDEA flight 2 (`vuelo_2`) | Airborne | 2025-07-17 | Launch 08:32 UTC — Recovery 09:23 UTC |
| Grisolia static | Ground (vehicle) | 2026-02-19 | Static, GNSS-SDR single antenna |
| **Grisolia Estrella** | Ground (vehicle) | **2026-03-16** | Static & dynamic, USRP X310 + 4-antenna array |

### Estrella test matrix

The Estrella campaign evaluates two processing toggles across two motion profiles:

| Configuration | Motion | Heading Det. (HD) | MLF 50 Hz |
|--------------|--------|-------------------|-----------|
| `Estáticos_sinHD_MLF50` | Static | No | Yes |
| `Estáticos_HD_MLF50` | Static | Yes | Yes |
| `Dinámicos_sinHD_MLF50` | Dynamic | No | Yes |
| `Dinámicos_HD_MLF50` | Dynamic | Yes | Yes |

Each configuration contains **10 independent runs** (Prueba0–Prueba9). Signal capture parameters: GPS L1 C/A at 1575.42 MHz, 4 MSPS, 25 dB gain, USRP X310 (`addr=192.168.30.2`), 16-bit complex integer samples.

---

## Repository layout

```
gnss-flex/
├── src/
│   ├── main_PVT_compare.m          # Pipeline 1 — PVT multi-receiver comparison
│   ├── main_RINEX_compare.m        # Pipeline 2 — RINEX observable comparison
│   └── utils/
│       ├── read_pvt_bin.m          # EME binary PVT parser
│       ├── read_pvt_septentrio.m   # Septentrio ASCII PVT parser
│       ├── RINEX_process_postproc.m
│       ├── compare_rinex_observables.m
│       ├── GNSS_SDR_OBSERVABLES_process.m
│       ├── GNSS_SDR_OBSERVABLES_process_binned.m
│       ├── SPIRENT_csv_process.m
│       ├── Sv_on_view.m
│       ├── import_GT_postproc.m
│       ├── plot_data_spirent.m
│       └── utm2deg.m
├── data/
│   ├── CEDEA/
│   │   ├── vuelo_2_eme_rx_basic/
│   │   ├── vuelo_2_eme_rx_adv/
│   │   └── vuelo_2_mosaicX5/
│   ├── grisolia/                   # Single-antenna ground test (Feb 2026)
│   └── grisolia_usrpx310_4_Estrella/  # 4-antenna Estrella campaign (Mar 2026)
│       ├── Config_*.conf           # GNSS-SDR configuration files (6 variants)
│       └── GNSS-SDR/
│           ├── Dinámicos_HD_MLF50-GPS/     (Prueba0–Prueba9)
│           ├── Dinámicos_sinHD_MLF50-GPS/  (Prueba0–Prueba9)
│           ├── Estáticos_HD_MLF50-GPS/     (Prueba0–Prueba9)
│           └── Estáticos_sinHD_MLF50-GPS/  (Prueba0–Prueba9)
├── results/
│   ├── plots_PVT/
│   ├── plots_OBS/
│   ├── plots_LOS/
│   └── skyplots/
├── paper/
│   └── eme_cttc_EuroGNC/          # EuroGNC 2026 conference paper material
│       ├── figures/               # 9 PNG figures used in the paper
│       └── LaTeX/
└── TFM/
    └── src/
        ├── Comparación_Spirent_y_GNSS-SDR/   # Pipeline 3 — Spirent vs GNSS-SDR
        └── Órbita/                           # Orbital mechanics visualisation
```

---

## Pipelines

### Pipeline 1 — PVT multi-receiver comparison (`main_PVT_compare.m`)

Compares position, velocity, and time solutions across three receivers simultaneously.

**Inputs:**
- `data/CEDEA/vuelo_2_eme_rx_basic/.../PVT.dat` — EME Basic binary log
- `data/CEDEA/vuelo_2_eme_rx_adv/.../PVT.dat` — EME Advanced binary log
- `data/CEDEA/vuelo_2_mosaicX5/..._PVTGeodetic2.txt` — Mosaic X5 ASCII log (reference)

**Processing steps:**
1. Parse binary/ASCII PVT logs (`read_pvt_bin`, `read_pvt_septentrio`).
2. Cache parsed data to `.mat` on first load to avoid re-parsing.
3. Time-synchronise all three datasets to a common UTC vector (intersection of time ranges, interpolated with `interp1`).
4. Compute pairwise differences: geodetic position (converted to North/East/Up metres via WGS-84 ellipsoid), ECEF position, velocity (ECEF → ENU), DOP values, clock bias, satellite count, solution type.
5. Generate comparison plots (trajectories on map, DOP time series, error histograms, height differences).
6. Optionally compute summary statistics table (mean and 95th-percentile horizontal/vertical/3D position error, velocity error, RTK fix percentage, average satellite count).

**Outputs** (`results/plots_PVT/`):
- Time-series plots: DOP differences, ECEF/ENU position differences, velocity, covariance, AR ratio
- 2D trajectory scatter on geodetic map (`geoscatter`)
- Histograms: height, ECEF components, North/East components — for all three receiver pairs
- Optional `.mat` export of processed data

**Configuration** (top of script):
```matlab
options.SAVE_PLOT = true;
cache_file = '../data/pvt_cache_flight_2.mat';
log_filename1  = '..\data\CEDEA\vuelo_2_eme_rx_basic\...\PVT.dat';
log_filename2  = '..\data\CEDEA\vuelo_2_eme_rx_adv\...\PVT.dat';
log_filename_septentrio = '..\data\CEDEA\vuelo_2_mosaicX5\..._PVTGeodetic2.txt';
```

---

### Pipeline 2 — RINEX observable comparison (`main_RINEX_compare.m`)

Compares raw GNSS observables (C/N0, pseudorange, Doppler, carrier phase) from RINEX observation files across multiple receivers per constellation.

**Inputs:**
- RINEX `.25O` / `.26O` observation files from each receiver
- Navigation `.25P` / `.nav` files for satellite positions
- Optionally pre-processed `.mat` cache files

**Processing steps:**
1. For each receiver, process RINEX with `RINEX_process_postproc` (extracts observables per PRN per constellation, computes skyplot positions, filters by C/N0 threshold).
2. Cache per-receiver struct to `.mat` on first run.
3. Compare all defined receiver pairs with `compare_rinex_observables` for GPS and Galileo separately.
4. Annotate plots with user-defined events (e.g. launch/recovery times).

**Comparison pairs (CEDEA flight 2):**
- Basic vs Advanced — GPS & Galileo
- Basic vs Mosaic X5 — GPS & Galileo
- Advanced vs Mosaic X5 — GPS & Galileo

**Outputs** (`results/plots_OBS/`):
- C/N0 time series per PRN, per receiver
- Pseudorange and Doppler residuals between receiver pairs
- Skyplots (decimated)
- Line-of-sight (LOS) observable plots

**Key options:**
```matlab
options.SAVE_PLOT           = false;
options.process_individual  = true;
options.process_comparision = true;
options.decimation_skyplot  = 100;
```

---

### Pipeline 3 — Spirent simulator vs GNSS-SDR (`TFM/src/Comparación_Spirent_y_GNSS-SDR/`)

Thesis-level analysis comparing a Spirent hardware simulator (ground truth) against GNSS-SDR output. Designed to characterise the SDR receiver's error floor in a controlled RF environment.

**Inputs:**
- Spirent CSV motion profiles (position, velocity, signal power, Doppler per PRN)
- GNSS-SDR RINEX observable files and PVT logs

**Processing steps:**
1. `main.m` — master configuration (receiver colours, constellation filters, data paths).
2. Load Spirent CSV (`SPIRENT_csv_process`) and GNSS-SDR observables; cache both to `.mat`.
3. Compute temporal drift between simulator and SDR time bases.
4. Compute observable errors: pseudorange, Doppler, C/N0 residuals.
5. Compute PVT errors: 1D/2D/3D position error, velocity error, DOP.
6. Compute satellite visibility, skyplots, EGNOS availability.
7. Export KPI CSV and histograms.

**Constellations supported:** GPS (`G`), Galileo (`E`), EGNOS (`SBAS`).

---

## Quick start

**Requirements:** MATLAB R2020b or later. No additional toolboxes required beyond Mapping Toolbox (for `geoscatter`) and standard signal processing.

```matlab
% Add utilities to path
addpath(genpath(fullfile(pwd, 'src')));

% Pipeline 1 — PVT comparison (edit paths at top of script)
run('src/main_PVT_compare.m');

% Pipeline 2 — RINEX observable comparison
run('src/main_RINEX_compare.m');
```

For the Estrella GNSS-SDR data, the RINEX `.26O` files from each `PruebaX` folder feed into Pipeline 2 with the paths adjusted to `data/grisolia_usrpx310_4_Estrella/GNSS-SDR/<config>/PruebaX/`.

### GNSS-SDR signal replay (Estrella)

Raw IQ files were captured with UHD at 4 MSPS and replayed offline with one of the six `.conf` files:

```bash
gnss-sdr --config_file=Config_dinámicos_HD_MLF50-GPS.conf
```

Signal acquisition: GPS L1 C/A PCPS, 12 channels, Doppler search ±40 kHz, threshold 3.  
Tracking: DLL-PLL on GPS L1 C/A.

---

## Output artefacts

| Folder | Contents |
|--------|----------|
| `results/plots_PVT/` | PVT time series, trajectory maps, error histograms (`.png` + `.fig`) |
| `results/plots_OBS/` | C/N0, pseudorange, Doppler per constellation and receiver pair |
| `results/plots_LOS/` | Line-of-sight range and range-rate analysis |
| `results/skyplots/` | Polar satellite visibility plots |
| `paper/eme_cttc_EuroGNC/figures/` | Figures included in EuroGNC 2026 paper |

---

## Related publication

Material in `paper/eme_cttc_EuroGNC/` supports the EuroGNC 2026 conference paper comparing the EME receiver implementations (Basic, Advanced) against the Septentrio Mosaic X5 reference during the CEDEA flight campaign. Key figures include: horizontal error CDF, 2D position error histograms, satellite availability, LOS range acceleration, reference trajectory kinematics, and worst-case PLL sigma equivalent.

---

## Authors

- Miguel Gómez López (`miguel.gomezlopez@uclm.es`) — UCLM / INTA
