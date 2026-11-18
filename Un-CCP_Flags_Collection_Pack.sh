#!/bin/bash

# ==============================================================================
# 🔒 【編碼防呆設定】 強制鎖定 UTF-8，防止 Windows 環境執行時中文變亂碼或截斷
# ==============================================================================
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# ==============================================================================
# 歐卡 2 多合一窗旗「全車系卡車 (含 Actros 2014) + Coaches DLC 客運巴士」自動生成腳本
# ==============================================================================

# 1. 防錯檢查：確保用戶是在含有貼圖的目錄下執行
if [ ! -d "vehicle" ] || [ ! -d "material" ]; then
    echo "❌ 錯誤：找不到 vehicle 或 material 資料夾！"
    echo "💡 請確保此腳本放置在 MOD 的源碼根目錄再執行。"
    exit 1
fi

# ==============================================================================
# ⚙️ 【核心配置區域】 統一版本號與實體檔案名稱
# ==============================================================================

# 統一版本號（自動同步套用至 manifest.sii 與 mod_description.txt）
MOD_VERSION=$(date +"%Y%m%d%H%M")

# 旗幟代號清單
flag_names=(
    "hkguk" "hkcab" "tsnec" "hkred" "hkgim" "china" "twdpp" "tibet" "kokba" "hkgam"
)

# 直接讓 ID 與代號相同，徹底避免與其他模組的 flag1~flag10 衝突
flag_list=("${flag_names[@]}")

# 貼圖檔案前綴（Un-CCP 留空 ""；若是 TW 模組且貼圖名為 twtpe.tobj，請改為 "tw"）
TEX_PREFIX=""

# ==============================================================================
# 🚗 【車輛清單區域】 卡車 (def/vehicle/truck) 與 客運巴士 (def/vehicle/bus)
# ==============================================================================

# 26 款卡車清單 (含 mercedes.actros2014)
all_trucks=(
    "daf.xf" "daf.xf_euro6" "daf.2021" "daf.xd"
    "iveco.stralis" "iveco.hiway" "iveco.sway"
    "man.tgx" "man.tgx_euro6" "man.tgx_2020"
    "mercedes.actros" "mercedes.newactros" "mercedes.actros2014"
    "renault.magnum" "renault.premium" "renault.t" "renault.etech_t"
    "scania.r" "scania.streamline" "scania.r_2016" "scania.s_2016" "scania.25l"
    "volvo.fh16" "volvo.fh16_2012" "volvo.fh_2021" "volvo.fh_2024"
)

# 3 款官方客運巴士真實代號
all_buses=(
    "man.lions_24"
    "scania.touring_23"
    "volvo.9700_23"
)

# ==============================================================================
# 🚀 【自動化執行核心】
# ==============================================================================

if [ ${#flag_list[@]} -ne ${#flag_names[@]} ]; then
    echo "❌ 設定錯誤：flag_list 的數量 (${#flag_list[@]}) 與 flag_names 的數量 (${#flag_names[@]}) 不一致！"
    exit 1
fi

echo "--------------------------------------------------"
echo "🎨 [1/4] 正在自動補齊 UI 選單與 3D 旗幟專用的 .mat 材質檔..."
echo "--------------------------------------------------"

mkdir -p "material/ui/accessory/flag"
mkdir -p "vehicle/truck/upgrade/flag"

for FNAME in "${flag_names[@]}"; do
    # 1. 生成 UI 選單圖示材質檔
    cat << EOF > "material/ui/accessory/flag/flag_${FNAME}.mat"
material : "ui"
{
	texture : "flag_${FNAME}.tobj"
	texture_name : "texture"
}
EOF

    # 2. 生成 3D 旗幟本體材質檔
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
done

echo "--------------------------------------------------"
echo "🚀 [2/4] 正在為 ${#all_trucks[@]} 款卡車與 ${#all_buses[@]} 款客運巴士生成自訂窗旗..."
echo "--------------------------------------------------"

# 清理舊的 def 設定目錄
rm -rf def/

# 定義通用生成函式 (參數 1: truck 或 bus, 參數 2: 車輛代號)
generate_flags() {
    local VTYPE="$1"
    local VEHICLE="$2"

    mkdir -p "def/vehicle/${VTYPE}/${VEHICLE}/accessory/flag_r"
    mkdir -p "def/vehicle/${VTYPE}/${VEHICLE}/accessory/flag_l"

    for i in "${!flag_list[@]}"; do
        FID="${flag_list[$i]}"
        FNAME="${flag_names[$i]}"

        # 寫入右窗旗 (flag_r)，名稱前方加空格使其在選單中自動置頂
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

        # 寫入左窗旗 (flag_l)，名稱前方加空格使其在選單中自動置頂
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

# 執行卡車生成
for truck in "${all_trucks[@]}"; do
    generate_flags "truck" "$truck"
done

# 執行客運巴士生成
for bus in "${all_buses[@]}"; do
    generate_flags "bus" "$bus"
done

# 建立聯運專用 manifest.sii 檔案（防截斷寫法）
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

# 自動生成 mod_description.txt 模組說明檔
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

total_vehicles=$((${#all_trucks[@]} + ${#all_buses[@]}))
total_files=$((total_vehicles * ${#flag_list[@]} * 2))

echo "📥 [3/4] 全車系 (${#all_trucks[@]} 卡車 + ${#all_buses[@]} 巴士) 共 ${total_files} 個 .sii 設定檔及說明檔生成完畢！"
echo "--------------------------------------------------"
echo "📦 [4/4] 正在以「零壓縮」格式打包為 .scs 模組檔..."
echo "--------------------------------------------------"

if [ ! -s "mod_icon.jpg" ]; then
    echo "⚠️ 警告：找不到有效的 mod_icon.jpg（或檔案為 0 KB），請確認封面圖片已放入目錄！"
    touch mod_icon.jpg
fi

rm -f Un-CCP_Flags_Collection_Pack.scs
zip -0 -r Un-CCP_Flags_Collection_Pack.scs def material vehicle manifest.sii mod_description.txt mod_icon.jpg

echo "=========================================================="
echo "🎉 完美完成！[Un-CCP_Flags_Collection_Pack.scs] (v ${MOD_VERSION}) 已成功打包！"
echo "👉 請將此檔案覆蓋到遊戲的 mod 資料夾中重新測試！"
echo "=========================================================="
