#!/bin/bash

# ==============================================================================
# 🔒 【編碼防呆設定】 強制鎖定 UTF-8，防止 Windows 環境執行時中文變亂碼或截斷
# ==============================================================================
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# ==============================================================================
# 歐卡 2 多合一窗旗「全車系卡車 (含 Actros 2014) + Coaches DLC 客運巴士」全自動生成腳本
# ==============================================================================

# 1. 目錄防錯檢查
if [ ! -d "vehicle" ] || [ ! -d "material" ]; then
    echo "❌ 錯誤：找不到 vehicle 或 material 資料夾！"
    echo "💡 請確保此腳本放置在 MOD 的源碼根目錄再執行。"
    exit 1
fi

# ==============================================================================
# ⚙️ 【核心配置區域】 統一版本號、模組名稱與實體檔案代號
# ==============================================================================

MOD_VERSION=$(date +"%Y%m%d%H%M")
PKG_NAME="Un-CCP_Flags_Collection_Pack"
DISPLAY_NAME="Un-CCP Flags Collection Pack"

# 旗幟代號清單
flag_names=(
    "hkguk" "hkcab" "tsnec" "hkred" "hkgim" "china" "twdpp" "tibet" "kokba" "hkgam"
)

flag_list=("${flag_names[@]}")
TEX_PREFIX=""

# ==============================================================================
# 🚗 【車輛清單區域】 卡車 (def/vehicle/truck) 與 客運巴士 (def/vehicle/bus)
# ==============================================================================

all_trucks=(
    "daf.xf" "daf.xf_euro6" "daf.2021" "daf.xd"
    "iveco.stralis" "iveco.hiway" "iveco.sway"
    "man.tgx" "man.tgx_euro6" "man.tgx_2020"
    "mercedes.actros" "mercedes.newactros" "mercedes.actros2014"
    "renault.magnum" "renault.premium" "renault.t" "renault.etech_t"
    "scania.r" "scania.streamline" "scania.r_2016" "scania.s_2016" "scania.25l"
    "volvo.fh16" "volvo.fh16_2012" "volvo.fh_2021" "volvo.fh_2024"
)

all_buses=(
    "man.lions_24"
    "scania.touring_23"
    "volvo.9700_23"
)

# ==============================================================================
# 🛡️ [1/5] DDS 貼圖檔案與 mod_icon.jpg 完整性防呆檢查及自動修復
# ==============================================================================

echo "--------------------------------------------------"
echo "🔍 [1/5] 正在檢查 .dds 貼圖檔案與 mod_icon.jpg 規範..."
echo "--------------------------------------------------"

missing_dds=()
for FNAME in "${flag_names[@]}"; do
    UI_DDS="material/ui/accessory/flag/flag_${FNAME}.dds"
    FLAG_DDS="vehicle/truck/upgrade/flag/${TEX_PREFIX}${FNAME}.dds"
    [ ! -f "$UI_DDS" ] && missing_dds+=("$UI_DDS")
    [ ! -f "$FLAG_DDS" ] && missing_dds+=("$FLAG_DDS")
done

if [ ${#missing_dds[@]} -gt 0 ]; then
    echo "❌ 嚴重錯誤：發現 ${#missing_dds[@]} 個缺失的 .dds 貼圖檔案！打包已中止："
    for m in "${missing_dds[@]}"; do
        echo "   - 缺少：$m"
    done
    echo "💡 請補齊上述貼圖檔案後再重新執行腳本。"
    exit 1
fi
echo "✅ 貼圖檢查通過！全部 $((${#flag_names[@]} * 2)) 個 .dds 檔案均已就緒。"

# 檢查並自動修復 mod_icon.jpg (必須為真實 JPEG 且精準 276x162)
python3 -c '
import os, sys, struct, shutil, subprocess

icon_path = "mod_icon.jpg"
if not os.path.isfile(icon_path) or os.path.getsize(icon_path) == 0:
    print("❌ 嚴重錯誤：找不到有效的 mod_icon.jpg（或檔案為 0 KB）！SCS Workshop Uploader 禁止空白圖示。")
    sys.exit(1)

def check_jpeg(path):
    with open(path, "rb") as f:
        data = f.read()
    if not data.startswith(b"\xff\xd8"):
        return False, 0, 0
    i = 2
    w = h = 0
    while i < len(data) - 9:
        if data[i] == 0xFF and data[i+1] in (0xC0, 0xC1, 0xC2):
            h, w = struct.unpack(">HH", data[i+5:i+9])
            break
        if data[i] == 0xFF and data[i+1] != 0xFF:
            length = struct.unpack(">H", data[i+2:i+4])[0]
            i += 2 + length
        else:
            i += 1
    return True, w, h

is_jpg, w, h = check_jpeg(icon_path)
if is_jpg and (w, h) == (276, 162):
    print(f"✅ mod_icon.jpg 驗證通過！(標準 JPEG 格式，解析度 {w}x{h})")
    sys.exit(0)

print(f"⚠️ 警告：mod_icon.jpg 不符合規範 (JPEG={is_jpg}, 目前尺寸={w}x{h})，正在嘗試自動修復為 276x162 JPEG...")
backup_path = "mod_icon_backup.img"
shutil.copy2(icon_path, backup_path)

fixed = False
if shutil.which("convert"):
    res = subprocess.run(["convert", backup_path, "-resize", "276x162!", "-colorspace", "sRGB", icon_path], capture_output=True)
    fixed = (res.returncode == 0)
elif shutil.which("magick"):
    res = subprocess.run(["magick", backup_path, "-resize", "276x162!", "-colorspace", "sRGB", icon_path], capture_output=True)
    fixed = (res.returncode == 0)
elif shutil.which("ffmpeg"):
    res = subprocess.run(["ffmpeg", "-y", "-i", backup_path, "-vf", "scale=276:162", icon_path], capture_output=True)
    fixed = (res.returncode == 0)
else:
    try:
        from PIL import Image
        with Image.open(backup_path) as img:
            img.convert("RGB").resize((276, 162), Image.Resampling.LANCZOS).save(icon_path, "JPEG", quality=95)
        fixed = True
    except ImportError:
        pass

if fixed:
    is_jpg2, w2, h2 = check_jpeg(icon_path)
    if is_jpg2 and (w2, h2) == (276, 162):
        os.remove(backup_path)
        print(f"🔧 自動修復成功！mod_icon.jpg 已轉換為標準 JPEG 格式 ({w2}x{h2})。")
        sys.exit(0)

shutil.move(backup_path, icon_path)
print("❌ 自動修復失敗：找不到 convert / magick / ffmpeg 或 Python PIL 套件，請手動將 mod_icon.jpg 轉為 276x162 的真實 JPEG 檔案！")
sys.exit(1)
' || exit 1

# ==============================================================================
# 🎨 [2/5] 自動補齊 UI 與 3D 旗幟專用的 .mat 與二進位 .tobj 檔
# ==============================================================================

echo "--------------------------------------------------"
echo "🎨 [2/5] 正在自動生成 .mat 材質檔與二進位 .tobj 指標檔..."
echo "--------------------------------------------------"

mkdir -p "material/ui/accessory/flag"
mkdir -p "vehicle/truck/upgrade/flag"

generate_tobj() {
    python3 -c '
import sys, struct
out_path = sys.argv[1]
dds_path = sys.argv[2].encode("utf-8")
is_ui = sys.argv[3] == "1"
header = struct.pack("<IIIIIIBBBBBBBBII",
    0x70B10A01, 0, 0, 0, 0,
    2, 2, 0,
    1 if is_ui else 0, 0,
    2 if is_ui else 0,
    2 if is_ui else 0,
    0, 0, len(dds_path), 0
)
with open(out_path, "wb") as f:
    f.write(header + dds_path)
' "$1" "$2" "$3"
}

for FNAME in "${flag_names[@]}"; do
    cat << EOF > "material/ui/accessory/flag/flag_${FNAME}.mat"
material : "ui"
{
	texture : "flag_${FNAME}.tobj"
	texture_name : "texture"
}
EOF
    generate_tobj "material/ui/accessory/flag/flag_${FNAME}.tobj" "/material/ui/accessory/flag/flag_${FNAME}.dds" "1"

    cat << EOF > "vehicle/truck/upgrade/flag/${FNAME}.mat"
material : "eut2.dif.shadow"
{
	texture : "${TEX_PREFIX}${FNAME}.tobj"
	texture_name : "texture_base"
	add_ambient : 0
	diffuse : { 1.0 , 1.0 , 1.0 }
	reflection : 0
	shininess : 4
	specular : { 0.0 , 0.0 , 0.0 }
}
EOF
    generate_tobj "vehicle/truck/upgrade/flag/${TEX_PREFIX}${FNAME}.tobj" "/vehicle/truck/upgrade/flag/${TEX_PREFIX}${FNAME}.dds" "0"
done

# ==============================================================================
# 🚀 [3/5] 生成全車系卡車與客運巴士的 .sii 設定檔
# ==============================================================================

echo "--------------------------------------------------"
echo "🚀 [3/5] 正在為 ${#all_trucks[@]} 款卡車與 ${#all_buses[@]} 款客運巴士生成窗旗設定..."
echo "--------------------------------------------------"

rm -rf def/

generate_flags() {
    local VTYPE="$1"
    local VEHICLE="$2"

    mkdir -p "def/vehicle/${VTYPE}/${VEHICLE}/accessory/flag_r"
    mkdir -p "def/vehicle/${VTYPE}/${VEHICLE}/accessory/flag_l"

    for i in "${!flag_list[@]}"; do
        FID="${flag_list[$i]}"
        FNAME="${flag_names[$i]}"

        cat << EOF > "def/vehicle/${VTYPE}/${VEHICLE}/accessory/flag_r/${FID}_r.sii"
SiiNunit
{
accessory_addon_patch_data : ${FID}.${VEHICLE}.flag_r
{
        name: " ${FNAME} (R)"
        price: 10
        icon: "flag/flag_${FNAME}"

        exterior_model: "/vehicle/truck/upgrade/flag/flag_right.pmd"
        interior_model: "/vehicle/truck/upgrade/flag/flag_right.pmd"
        coll: "/vehicle/truck/upgrade/flag/flag_right.pmc"
        data: .patch.phys_data
}
physics_patch_data : .patch.phys_data
{
        material: "/vehicle/truck/upgrade/flag/${FNAME}.mat"
        area_density: 0.08
        linear_stiffness: 0.92
        drag_coefficient: 2.5
        lift_coefficient: 4.5
        aero_model_type: "AT_two_side_lift_drag"
        x_res: 14
        y_res: 10
        x_size: 0.55
        y_size: 0.38
}
}
EOF

        cat << EOF > "def/vehicle/${VTYPE}/${VEHICLE}/accessory/flag_l/${FID}_l.sii"
SiiNunit
{
accessory_addon_patch_data : ${FID}.${VEHICLE}.flag_l
{
        name: " ${FNAME} (L)"
        price: 10
        icon: "flag/flag_${FNAME}"

        exterior_model: "/vehicle/truck/upgrade/flag/flag_left.pmd"
        interior_model: "/vehicle/truck/upgrade/flag/flag_left.pmd"
        coll: "/vehicle/truck/upgrade/flag/flag_left.pmc"
        data: .patch.phys_data
}
physics_patch_data : .patch.phys_data
{
        material: "/vehicle/truck/upgrade/flag/${FNAME}.mat"
        area_density: 0.08
        linear_stiffness: 0.92
        drag_coefficient: 2.5
        lift_coefficient: 4.5
        aero_model_type: "AT_two_side_lift_drag"
        x_res: 14
        y_res: 10
        x_size: 0.55
        y_size: 0.38
}
}
EOF
    done
}

for truck in "${all_trucks[@]}"; do generate_flags "truck" "$truck"; done
for bus in "${all_buses[@]}"; do generate_flags "bus" "$bus"; done

# ==============================================================================
# 📝 [4/5] 生成 manifest.sii 與 mod_description.txt
# ==============================================================================

echo "--------------------------------------------------"
echo "📝 [4/5] 正在生成模組清單與說明文件..."
echo "--------------------------------------------------"

cat << 'EOF' > manifest.sii
SiiNunit
{
mod_package : .package_name
{
    package_version: "__MOD_VERSION__"
    display_name: "Un-CCP Flags Collection Pack"
    author: "通番救國政治部"
    category[]: "accessory"
    icon: "mod_icon.jpg"
    description_file: "mod_description.txt"
    mp_mod_optional: true
}
}
EOF
sed -i "s/__MOD_VERSION__/${MOD_VERSION}/g" manifest.sii
sed -i "s/Un-CCP Flags Collection Pack/${DISPLAY_NAME}/g" manifest.sii

cat << 'EOF' > mod_description.txt
Un-CCP Flags Collection Pack v __MOD_VERSION__

您需要擁有並安裝官方的「Euro Truck Simulator 2 - Window Flags」DLC！才能使用，

製作 通番救國政治部


該模組為遊戲中所有標準 SCS 卡車及巴士添加旗幟

以下卡車不支持：

DAF NGD

MAN TGX

VOLVO FH5
EOF
sed -i "s/__MOD_VERSION__/${MOD_VERSION}/g" mod_description.txt
sed -i "s/Un-CCP Flags Collection Pack/${DISPLAY_NAME}/g" mod_description.txt

# ==============================================================================
# 📦 [5/5] 雙軌打包：本地測試用 .scs + Steam Workshop 上傳結構
# ==============================================================================

echo "--------------------------------------------------"
echo "📦 [5/5] 正在打包本地 .scs 檔與 Steam Workshop 上傳結構..."
echo "--------------------------------------------------"

# 1. 打包本地 .scs
rm -f "${PKG_NAME}.scs"
zip -0 -r "${PKG_NAME}.scs" def material vehicle manifest.sii mod_description.txt mod_icon.jpg > /dev/null

# 2. 生成 Steam Workshop 上傳目錄結構
WS_DIR="${PKG_NAME}_Workshop"
rm -rf "${WS_DIR}" "${WS_DIR}.zip"
mkdir -p "${WS_DIR}/universal"

cat << 'EOF' > "${WS_DIR}/versions.sii"
SiiNunit
{
package_version_info : .universal
{
    package_name: "universal"
}
}
EOF

cp -r def material vehicle manifest.sii mod_description.txt mod_icon.jpg "${WS_DIR}/universal/"
zip -0 -r "${WS_DIR}.zip" "${WS_DIR}" > /dev/null

echo "=========================================================="
echo "🎉 完美完成！(版本: v ${MOD_VERSION})"
echo "👉 本地測試檔：${PKG_NAME}.scs"
echo "👉 工作坊目錄：${WS_DIR}/ (可直接用 SCS Workshop Uploader 選擇此資料夾)"
echo "👉 工作坊備份：${WS_DIR}.zip"
echo "=========================================================="
