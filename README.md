# gnss-flex

Toolkit to analyze **GNSS-FLEX** project data: PVT logs, RINEX, observables, and experiment reports. Designed for repeatable analysis, fast comparisons, and clean figures.

## ✨ Features

- **PVT comparison** between two or more runs (time-aligned; stats & plots).
- **Observable analysis** (C/N0, pseudorange, Doppler, carrier phase) with per-constellation filters.
- **RINEX compare** (RINEX v2/3) with automatic observable mapping.
- **Caching**: heavy binary loads are parsed **once** and cached to `.mat`.
- **Batch processing** of flight/test campaigns with a YAML config.
- **Figure export** (PNG/SVG/PDF) and CSV summaries for reports.
- **Reproducible**: deterministic seeds, versioned parameters.

> Primary language: **MATLAB** (per project preference). Optional Python helpers for I/O and reporting.

## 📁 Repo Layout (proposed)

```
./
├── data/
├── docs/
├── matlab/
│   ├── core/
│   ├── plots/
│   ├── workflows/
│   └── +gnssflex/
├── python/
├── config/
├── figures/
├── results/
├── tests/
├── .gitignore
├── README.md
└── LICENSE
```

## 🚀 Quick Start

```matlab
addpath(genpath(fullfile(pwd, 'matlab')));
root = fullfile('data','CEDEA','vuelo_2_eme_rx_adv','run_2025-07-05_00-18');
a = fullfile(root,'receiver_A','logs','pvt_log.bin');
b = fullfile(root,'receiver_B','logs','pvt_log.bin');
S1 = cache_pvt(a);
S2 = cache_pvt(b);
out = plot_pvt_compare(S1, S2, 'saveDir', 'figures');
```

## 🧠 Design Notes

- **One-pass loaders** with hash-based `.mat` cache.
- **Unified compare** for GNSS-SDR and Spirent.
- **Constellation filters** (`systems={'G','E','R','C'}`).
- **Robust time base** with GPS time normalization.

## 🔧 Key MATLAB APIs (stubs)

### `cache_pvt.m`

```matlab
function S = cache_pvt(pvtPath, varargin)
%CACHE_PVT Parse heavy PVT binary once and cache to .mat
p = inputParser; p.addParameter('force', false); p.parse(varargin{:});
opts = p.Results;
matPath = [pvtPath, '.mat'];
rawHash = gnssflex.hash_file(pvtPath);
S = [];
if ~opts.force && exist(matPath,'file')
    L = load(matPath, 'S', 'rawHash');
    if isfield(L,'rawHash') && strcmp(L.rawHash, rawHash)
        S = L.S; return;
    end
end
S = read_pvt_bin(pvtPath);
save(matPath, 'S', 'rawHash','-v7.3');
```

## ⚙️ YAML Campaign Config (example)

```yaml
campaign: CEDEA_vuelo2
runs:
  - name: rx_adv_run1
    root: data/CEDEA/vuelo_2_eme_rx_adv/run_2025-07-05_00-18
    pvt: receiver_A/logs/pvt_log.bin
    rinex: receiver_A/rinex/obs.23o
  - name: rx_adv_run2
    root: data/CEDEA/vuelo_2_eme_rx_adv/run_2025-07-05_00-18
    pvt: receiver_B/logs/pvt_log.bin
filters:
  systems: [G, E]
  prns: [1, 3, 5, 11]
plots:
  save_dir: figures
  formats: [png, pdf]
  dpi: 200
```

## 📊 Outputs

- **Figures**: error time series, C/N0, availability, residuals.
- **CSV**: KPIs per run.
- **MD/HTML**: optional report cards.

## 🤝 Contributing

1. Create a feature branch (`feat/...`).
2. Add tests/fixtures.
3. Update README and examples.

## 📄 License

TBD (MIT or BSD-3-Clause recommended).

the tr
