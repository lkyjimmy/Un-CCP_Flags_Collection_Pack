# ETS2 旗幟配件模組 — 開發者技術說明文件 (Developer README)

## 1. 模組概覽與目錄結構

本模組為《歐洲卡車模擬 2》（Euro Truck Simulator 2）的車窗旗幟配件包，同時支援官方卡車與官方客車（Coaches DLC）。模組採用標準的 SCS 封裝結構（根目錄為 `Un-CCP_Flags_Collection_Pack/`）：

```text
Un-CCP_Flags_Collection_Pack/
├── versions.sii                        # 遊戲版本相容性清單
└── universal/                          # 通用版本資源目錄
    ├── manifest.sii                    # 模組基本資訊與描述設定
    ├── mod_description.txt             # 模組商店/管理員顯示文字
    ├── mod_icon.jpg                    # 模組縮圖 (JPG 格式)
    ├── Un-CCP_Flags_Collection_Pack.scs # 封裝檔案/備份
    ├── Un-CCP_Flags_Collection_Pack.sh  # 打包腳本 (Shell Script)
    ├── def/vehicle/                    # 車輛配件定義檔 (.sii)
    ├── material/ui/accessory/flag/     # 改裝介面 UI 圖示 (.dds, .mat, .tobj)
    └── vehicle/truck/upgrade/flag/     # 3D 旗幟模型貼圖 (.dds, .mat, .tobj)
```

---

## 2. 二進位檔案與圖片資源規格

模組內的圖片資源分為 **3D 實體貼圖** 與 **改裝選單 UI 圖示** 兩大類，皆包含 `.dds`（DirectDraw Surface 紋理檔）、`.tobj`（SCS 紋理物件二進位索引檔）與 `.mat`（材質定義檔）。

### A. 旗幟代號對照表（10 組獨立樣式）

所有配件定義檔（`flag1` 至 `flag10`）與貼圖檔案皆遵循固定的內部代號命名規範：

| 槽位編號 | 內部代號 (ID) | 3D 實體貼圖路徑 (`vehicle/truck/upgrade/flag/`) | UI 選單圖示路徑 (`material/ui/accessory/flag/`) |
| :--- | :--- | :--- | :--- |
| **Flag 1** | `hkguk` | `hkguk.dds` / `hkguk.tobj` / `hkguk.mat` | `flag_hkguk.dds` / `.tobj` / `.mat` |
| **Flag 2** | `hkgam` | `hkgam.dds` / `hkgam.tobj` / `hkgam.mat` | `flag_hkgam.dds` / `.tobj` / `.mat` |
| **Flag 3** | `hkgim` | `hkgim.dds` / `hkgim.tobj` / `hkgim.mat` | `flag_hkgim.dds` / `.tobj` / `.mat` |
| **Flag 4** | `hkcab` | `hkcab.dds` / `hkcab.tobj` / `hkcab.mat` | `flag_hkcab.dds` / `.tobj` / `.mat` |
| **Flag 5** | `hkred` | `hkred.dds` / `hkred.tobj` / `hkred.mat` | `flag_hkred.dds` / `.tobj` / `.mat` |
| **Flag 6** | `twdpp` | `twdpp.dds` / `twdpp.tobj` / `twdpp.mat` | `flag_twdpp.dds` / `.tobj` / `.mat` |
| **Flag 7** | `kokba` | `kokba.dds` / `kokba.tobj` / `kokba.mat` | `flag_kokba.dds` / `.tobj` / `.mat` |
| **Flag 8** | `tibet` | `tibet.dds` / `tibet.tobj` / `tibet.mat` | `flag_tibet.dds` / `.tobj` / `.mat` |
| **Flag 9** | `tsnec` | `tsnec.dds` / `tsnec.tobj` / `tsnec.mat` | `flag_tsnec.dds` / `.tobj` / `.mat` |
| **Flag 10** | `china` | `china.dds` / `china.tobj` / `china.mat` | `flag_china.dds` / `.tobj` / `.mat` |

### B. 圖片格式與尺寸規範（供再開發替換用）

以下為 SCS 引擎的標準開發規範與檔案特徵說明：

* **3D 旗幟實體貼圖 (`*.dds`)**：採用 DXT5 (BC3) 壓縮格式（支援 Alpha 透明通道），標準 2 的次方比例（建議 `512x256` 或 `1024x512` 像素，視長寬比而定），需包含 Mipmaps。
* **UI 配件圖示 (`flag_*.dds`)**：採用無壓縮 A8R8G8B8 或 DXT5 格式，SCS 改裝介面標準尺寸為 `256x64` 像素（不含 Mipmaps）。
* **模組預覽圖 (`mod_icon.jpg`)**：標準 JPEG 格式，SCS 官方規定尺寸必須為 `276x162` 像素。
* **二進位索引檔 (`*.tobj`)**：包含對應 `.dds` 檔案的相對路徑字串與紋理定址模式（如 `clamp_to_edge`）。若第三方開發者修改檔名，必須使用 TOBJ 編輯器同步修改內部路徑指針，否則遊戲將顯示紅色遺失貼圖。

---

## 3. 支援車輛清單（Def 定義檔架構）

本模組在 `universal/def/vehicle/` 下為每款車輛分別建立了左側（`accessory/flag_l/flag1_l.sii` ~ `flag10_l.sii`）與右側（`accessory/flag_r/flag1_r.sii` ~ `flag10_r.sii`）的配件掛載定義。

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

---

## 4. 二次開發與擴充指南

1. **替換旗幟圖案**：直接覆蓋 `vehicle/truck/upgrade/flag/` 與 `material/ui/accessory/flag/` 下對應代號的 `.dds` 檔案即可，無需更動 `.mat`、`.tobj` 或 `.sii` 結構。
2. **新增支援車型（如模組卡車或客車）**：
   * 在 `def/vehicle/truck/` 或 `def/vehicle/bus/` 下建立目標車輛的內部代號資料夾。
   * 複製現有車型的 `accessory/flag_l/` 與 `accessory/flag_r/` 資料夾。
   * 批次修改所有 `.sii` 檔案內的配件單元名稱（`accessory_addon_data` 的命名空間需對應新車型代號）。
3. **封裝打包**：目錄內附有 `Un-CCP_Flags_Collection_Pack.sh` 腳本，開發者在 Linux/macOS 環境或 WSL 下可直接執行該腳本進行自動化打包（注意 `.dds` 與音訊檔在 `.scs`/`.zip` 封裝時建議使用無壓縮 `Store` 模式以確保遊戲讀取效能）。
