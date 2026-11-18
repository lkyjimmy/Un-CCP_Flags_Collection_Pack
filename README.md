# ETS2 旗幟配件模組 — 開發者技術說明文件 (Un-CCP Flags Collection Pack)

## 1. 模組概覽與源碼目錄結構

本模組（**Un-CCP Flags Collection Pack**，製作：**通番救國政治部 / PDSNCF**）為《歐洲卡車模擬 2》（Euro Truck Simulator 2）的車窗旗幟配件包，同時支援官方卡車與官方客車（Coaches DLC）。源碼根目錄為 `Un-CCP_Flags_Collection_Pack/`：

```text
Un-CCP_Flags_Collection_Pack/
├── LICENSE                             # 授權條款文件
├── README.md                           # 開發者技術說明文件 (Markdown)
├── README.txt                          # 純文字版說明文件
├── mod_icon.jpg                        # 模組縮圖 (276x162 JPG 格式)
├── Un-CCP_Flags_Collection_Pack.sh     # 全自動檢查、補齊材質與雙軌打包腳本
├── material/ui/accessory/flag/         # 改裝介面 UI 圖示 (.dds, .mat, .tobj)
└── vehicle/truck/upgrade/flag/         # 3D 旗幟模型貼圖 (.dds, .mat, .tobj)
```

*(註：執行 `.sh` 打包腳本後，會自動生成 `def/` 定義檔、本地測試用 `Un-CCP_Flags_Collection_Pack.scs`，以及可直接交由 SCS Workshop Uploader 上傳的 `Un-CCP_Flags_Collection_Pack_Workshop/` 目錄。)*

---

## 2. 二進位檔案與圖片資源規格

模組內的圖片資源分為 **3D 實體貼圖** 與 **改裝選單 UI 圖示** 兩大類，皆包含 `.dds`（DirectDraw Surface 紋理檔）、`.tobj`（SCS 紋理物件二進位索引檔）與 `.mat`（材質定義檔）。

### A. 旗幟代號對照表（10 組獨立樣式）

為避免與其他旗幟模組產生槽位與單元名稱衝突，本模組直接採用各旗幟的專屬英文代號作為配件定義檔（`{代號}_l.sii` / `{代號}_r.sii`）、內部單元 ID（`{代號}.{車型}.flag_l/r`）與貼圖檔案名稱：

| 內部代號 (ID) | 配件定義檔名稱 (`def/.../accessory/`) | 3D 實體貼圖路徑 (`vehicle/truck/upgrade/flag/`) | UI 選單圖示路徑 (`material/ui/accessory/flag/`) |
| :--- | :--- | :--- | :--- |
| **`hkguk`** | `hkguk_l.sii` / `hkguk_r.sii` | `hkguk.dds` / `hkguk.tobj` / `hkguk.mat` | `flag_hkguk.dds` / `.tobj` / `.mat` |
| **`hkcab`** | `hkcab_l.sii` / `hkcab_r.sii` | `hkcab.dds` / `hkcab.tobj` / `hkcab.mat` | `flag_hkcab.dds` / `.tobj` / `.mat` |
| **`tsnec`** | `tsnec_l.sii` / `tsnec_r.sii` | `tsnec.dds` / `tsnec.tobj` / `tsnec.mat` | `flag_tsnec.dds` / `.tobj` / `.mat` |
| **`hkred`** | `hkred_l.sii` / `hkred_r.sii` | `hkred.dds` / `hkred.tobj` / `hkred.mat` | `flag_hkred.dds` / `.tobj` / `.mat` |
| **`hkgim`** | `hkgim_l.sii` / `hkgim_r.sii` | `hkgim.dds` / `hkgim.tobj` / `hkgim.mat` | `flag_hkgim.dds` / `.tobj` / `.mat` |
| **`china`** | `china_l.sii` / `china_r.sii` | `china.dds` / `china.tobj` / `china.mat` | `flag_china.dds` / `.tobj` / `.mat` |
| **`twdpp`** | `twdpp_l.sii` / `twdpp_r.sii` | `twdpp.dds` / `twdpp.tobj` / `twdpp.mat` | `flag_twdpp.dds` / `.tobj` / `.mat` |
| **`tibet`** | `tibet_l.sii` / `tibet_r.sii` | `tibet.dds` / `tibet.tobj` / `tibet.mat` | `flag_tibet.dds` / `.tobj` / `.mat` |
| **`kokba`** | `kokba_l.sii` / `kokba_r.sii` | `kokba.dds` / `kokba.tobj` / `kokba.mat` | `flag_kokba.dds` / `.tobj` / `.mat` |
| **`hkgam`** | `hkgam_l.sii` / `hkgam_r.sii` | `hkgam.dds` / `hkgam.tobj` / `hkgam.mat` | `flag_hkgam.dds` / `.tobj` / `.mat` |

### B. 圖片格式與尺寸規範（供再開發替換用）

以下為 SCS 引擎的標準開發規範與檔案特徵說明：

* **3D 旗幟實體貼圖 (`*.dds`)**：採用 DXT5 (BC3) 壓縮格式（支援 Alpha 透明通道），標準 2 的次方比例（建議 `512x256` 或 `1024x512` 像素，視長寬比而定），需包含 Mipmaps。
* **UI 配件圖示 (`flag_*.dds`)**：採用無壓縮 A8R8G8B8 或 DXT5 格式，SCS 改裝介面標準尺寸為 `256x64` 像素（不含 Mipmaps）。
* **模組預覽圖 (`mod_icon.jpg`)**：標準 JPEG 格式，SCS 官方規定尺寸必須精準為 `276x162` 像素。
* **二進位索引檔 (`*.tobj`)**：包含對應 `.dds` 檔案的相對路徑字串與 SCS 官方標準 40-byte 二進位檔頭。透過自動化打包腳本執行時，系統會自動根據貼圖類型生成對應的 `.tobj` 與 `.mat` 檔案。

---

## 3. 支援車輛清單（Def 定義檔架構）

本模組透過自動化腳本在 `def/vehicle/` 下為每款車輛分別建立了左側（`accessory/flag_l/{代號}_l.sii`）與右側（`accessory/flag_r/{代號}_r.sii`）的配件掛載定義（共 26 款卡車 + 3 款客車）：

### 卡車系列 (`def/vehicle/truck/`)
* **DAF**：`daf.xf`、`daf.xf_euro6`、`daf.2021`、`daf.xd`
* **Iveco**：`iveco.stralis`、`iveco.hiway`、`iveco.sway`
* **MAN**：`man.tgx`、`man.tgx_euro6`、`man.tgx_2020`
* **Mercedes-Benz**：`mercedes.actros`、`mercedes.actros2014`、`mercedes.newactros`
* **Renault**：`renault.magnum`、`renault.premium`、`renault.t`、`renault.etech_t`
* **Scania**：`scania.r`、`scania.streamline`、`scania.r_2016`、`scania.s_2016`、`scania.25l`
* **Volvo**：`volvo.fh16`、`volvo.fh16_2012`、`volvo.fh_2021`、`volvo.fh_2024`

### 客車系列 (`def/vehicle/bus/`)
* **MAN**：`man.lions_24` (MAN Lion's Coach)
* **Scania**：`scania.touring_23` (Scania Touring)
* **Volvo**：`volvo.9700_23` (Volvo 9700 DD)

*(註：使用本模組需擁有並安裝官方「Euro Truck Simulator 2 - Window Flags」DLC；另目前版本暫不支援 DAF NGD、MAN TGX 新世代部分車型及 Volvo FH5 獨立架構)。*

---

## 4. 二次開發與自動化打包指南

1. **替換旗幟圖案**：直接覆蓋 `vehicle/truck/upgrade/flag/` 與 `material/ui/accessory/flag/` 下對應代號的 `.dds` 檔案即可。
2. **新增旗幟或支援車型**：直接編輯打包腳本中的 `flag_names`、`all_trucks` 或 `all_buses` 陣列，填入目標代號（注意 ETS2 引擎限制單一配件 ID 長度不得超過 12 個字元）。
3. **一鍵自動化生成與雙軌封裝**：
   * 在 Linux / macOS 終端機或 Windows Git Bash / WSL 環境中執行 `chmod +x *.sh && ./<腳本名稱>.sh`。
   * 腳本執行時會自動進行 **DDS 貼圖完整性檢查**、`mod_icon.jpg`（`276x162` JPEG）自動驗證與縮放修復、補齊所有 `.mat` 與官方標準二進位 `.tobj` 檔，並同步輸出本地測試用的 `.scs` 模組與 Steam Workshop 專用上傳目錄（內含 `versions.sii` 與 `universal/`）。
