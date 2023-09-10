#!/bin/bash

# COLORS
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${ORANGE}Installing RetroArch - Official PPA [+custom configs]${NC}"

sudo apt add-repository -y ppa:libretro/stable
sudo apt update
sudo apt install -y retroarch

# Base URL for RetroArch cores
CORES_BASE_URL="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"

# Base URL for RetroArch assets
ASSETS_BASE_URL="https://buildbot.libretro.com/assets/"
ASSETS_FRONTEND_BASE_URL="${ASSETS_BASE_URL}/frontend/"
ASSETS_SYSTEM_BASE_URL="${ASSETS_BASE_URL}/system/"

# Destination directory for RetroArch cores and assets
RETROARCH_DIR="$HOME/.config/retroarch/"
SHADERS_BASE_DIR="${RETROARCH_DIR}shaders/"

ASSET_FILES=(
    "assets/assets.zip"
    "autoconfig/autoconfig.zip"
    "cheats/cheats.zip"
    "cores/cores.zip"
    "overlay/overlay.zip"
    "shaders/shaders_glsl.zip"
    "shaders/shaders_slang.zip"
    "database/database-rdb.zip"
)

for FILE in ${ASSET_FILES[@]}; do
    FILE_PATH="$RETROARCH_DIR/$FILE"
    DIR_PATH="${FILE_PATH%.*}"

    # Download asset file
    curl -L -o "$FILE_PATH" "$ASSETS_FRONTEND_BASE_URL/$FILE"

    # Extract asset file
    unzip "$FILE_PATH" -d "$DIR_PATH"
    
    # Remove zip file
    rm "$FILE_PATH"
done

echo "Assets update completed!"

# Download core files
CORES_LIST=(
    # Arcade & Konami M2 & Neo Geo [MVS - Multi Video System (arcade), CD, HNG-64]
    "mame"
    "fbneo"
    "mame2003_plus"

    # Nintendo > SNES
    "snes9x"
    "bsnes_hd_beta"
    "bsnes_mercury_balanced"

    # Nintendo > NES
    "mesen"
    "nestopia"

    # Nintendo > Game Boy Advance (+ Game Boy/Color)
    "mgba"

    # Nintendo > Game Boy/Color
    "gambatte"
    "sameboy"

    # Nintendo > DS
    "melonds"
    "desmume"

    # Nintendo > 3DS
    "citra"

    # Nintendo > 64
    "mupen64plus_next"

    # Nintendo > GameCube & Wii
    "dolphin"

    # Sega > Genesis (Mega Drive) & CD & Master System & Game Gear & SG-1000
    "genesis_plus_gx"
    "genesis_plus_gx_wide"

    # Sega > 32x & Pico
    "picodrive"

    # Sega > Saturn
    "mednafen_saturn"

    # Sega > Dreamcast
    "flycast"

    # Atari > Lynx
    "mednafen_lynx"

    # Atari > Jaguar
    "virtualjaguar"

    # Atari > 2600
    "stella"

    # Atari > 5200
    "atari800"

    # Atari > 7800
    "prosystem"

    # Atari > ST
    "hatari"

    # Sony > PlayStation
    "swanstation"
    "mednafen_psx_hw"

    # Sony > PlayStation 2
    "pcsx2"

    # Sony > PlayStation Portable
    "ppsspp"

    # 3DO Interactive Multiplayer
    "opera"

    # ScummVM
    "scummvm"

    # Bandai > WonderSwan, WonderSwan Color & SwanCrystal
    "mednafen_wswan"

    # GCE - Vectrex
    "vecx"

    # NEC - TurboGrafx 16, NEC - TurboGrafx-CD, NEC - SuperGrafx
    "mednafen_supergrafx"
    "mednafen_pce"

    # MSX, Sega SG-1000, SC-3000, SF-7000 and ColecoVision emulator > Discontinued: Can be played with FinalBurn Neo, but need to download other type of roms
    # "bluemsx"
)

IFS=$'\n' # Internal Field Separator > Change the default (space) to new line separator
for CORE in ${CORES_LIST[@]}; do
    echo "Downloading core: ${ORANGE}${CORE}${NC}"
    curl -L -o "${RETROARCH_DIR}cores/$CORE.zip" "${CORES_BASE_URL}${CORE}_libretro.so.zip"
    unzip -o "${RETROARCH_DIR}cores/$CORE.zip" -d "${RETROARCH_DIR}cores/"
    rm "${RETROARCH_DIR}cores/${CORE}.zip"

    # Start retroarch loading the core to generate default config file for the core
    case $CORE in
        "opera" | "scummvm")
            # Force kill, these cores will load frontend
            (retroarch -L "${CORE}" &); sleep 3; killall retroarch
            ;;
        *)
            retroarch -L "${CORE}"
        ;;
    esac
done

echo -e "Core download and extraction completed!"

# Core system files for specific cores
CORES_SYSTEM_LIST=(
    "MAME 2003-Plus"
    "Dolphin"
    "PPSSPP"
    "ScummVM"
)

IFS=$'\n' # Internal Field Separator > Change the default (space) to new line separator
for CORE in ${CORES_SYSTEM_LIST[@]}; do
    echo -e "Downloading core system: ${ORANGE}${CORE}${NC}"
    curl -L -o "${RETROARCH_DIR}system/$CORE.zip" "${ASSETS_SYSTEM_BASE_URL}${CORE}.zip"
    unzip -o "${RETROARCH_DIR}system/$CORE.zip" -d "${RETROARCH_DIR}system/"
    rm "${RETROARCH_DIR}system/${CORE}.zip"
done

echo -e "Core systems download and extraction completed!"

echo -e "Some cores need to manually install bios roms into system folder:"
echo -e "Playstation [swanstation and mednafen_psx_hw]"
echo -e "Lynx [mednafen_lynx]: lynxboot.img"

# Copying / Symlink to selected shaders

# Create the destination directory
SHADERS_DIR="${SHADERS_BASE_DIR}shaders_slang/"
DEST_SHADERS_SELECTION_DIR="${SHADERS_DIR}seven_selection"
DEST_SHADERS_DIR="$DEST_SHADERS_SELECTION_DIR/shaders"
mkdir -p "$DEST_SHADERS_SELECTION_DIR"
mkdir -p "$DEST_SHADERS_DIR"

echo -e "${ORANGE}Symlinking selected shaders into '$DEST_SHADERS_SELECTION_DIR'${NC}"

# Define the desired shader files
SHADER_FILES=(
    "anti-aliasing/advanced-aa"
    "crt/crt-guest-advanced"
    "crt/crt-aperture"
    "crt/crt-easymode"
    "crt/crt-royale"
    "crt/crt-royale-fake-bloom"
    "crt/crt-yo6-KV-M1420B-sharp"
    "crt/yeetron"
    "crt/zfast-crt"
    "denoisers/crt-fast-bilateral-super-xbr"
    "dithering/cbod_v1"
    "dithering/mdapt"
    "eagle/super-2xsai-fix-pixel-shift"
    "handheld/dot"
    "handheld/retro-v2"
    "handheld/retro-v3"
    "handheld/zfast-lcd"
    "hqx/hq4x"
    "nnedi3/nnedi3-nns64-2x-nns32-4x-rgb"
    "ntsc/ntsc-256px-svideo-scanline"
    "omniscale/omniscale"
    "presets/crt-royale-ntsc-svide"
    "presets/crt-royale-xm29plus"
    "presets/retro-v2+gba-color"
    "presets/retro-v2+image-adjustment"
    "presets/retro-v2+psp-color"
    "reshade/bsnes-gamma-ramp"
    "scalefx/scalefx"
    "scalenx/epx"
    "scalenx/scale3x"
    "sharpen/super-xbr-super-res"
    "windowed/lanczos3-fast"
    "xbr/xbr-lv3-sharp"
    "xbr/xbr-lv2"
    "xbr/xbr-lv3"
    "xbr/other presets/xbr-lv3-multipass"
    "xbr/other presets/xbr-lv3-9x-standalone"
    "xbr/other presets/xbr-lv3-standalone"
    "xbr/other presets/xbr-hybrid"
    "xbrz/4xbrz-linear"
    "xsal/4xsal-level2-crt"
    "xsal/4xsal-level2-hq"
    "xsoft/4xsoftSdB"
)

# Loop through the desired files and symlink them to the destination directory
for FILE in "${SHADER_FILES[@]}"
do
    FILE="$FILE.slangp"
    # Get the file name from the path
    FILENAME=$(basename "$FILE")
    
    # Check if the file exists
    if [ -f "${SHADERS_DIR}$FILE" ]; then
        # Create the destination path for the shader file
        DEST_PATH="$DEST_SHADERS_SELECTION_DIR/$FILENAME"
        
        # Create the symbolic link to the destination directory
        ln -s -f "${SHADERS_DIR}$FILE" "$DEST_PATH"
        
        # Print a message indicating the file was symlinked
        # echo -e "${GREEN}Symlinked${NC} $FILE to $DEST_PATH"
        
        # Get the path of the shaders directory for this shader file
        SHADERS_PATH="$(dirname "$FILE")/shaders"
        
        # Check if the shaders directory for this shader file has already been symlinked
        if ! [[ " ${SYMLINKED_SHADERS[@]} " =~ " ${SHADERS_PATH} " ]]; then
            # Add the shaders directory to the array of symlinked shader folders
            SYMLINKED_SHADERS+=("$SHADERS_PATH")
            
            # Create a symlink for each file and directory in the shaders directory for this shader file
            # echo -e "${ORANGE}Symlinking all files and folders inside subfolder '$SHADERS_PATH'${NC}"
            find "${SHADERS_DIR}$SHADERS_PATH" -mindepth 1 -print0 | while IFS= read -r -d $'\0' SHADER_FILE
            do
                # Get the file name from the path
                SHADER_FILENAME=$(basename "$SHADER_FILE")
                
                # Create the destination path for the shader file
                DEST_SHADER_PATH="$DEST_SHADERS_DIR/$SHADER_FILENAME"
                
                # Create the symbolic link to the destination directory
                ln -s -f "$SHADER_FILE" "$DEST_SHADER_PATH"
            done
        fi
    else
        # Print a message indicating the file was not found
        echo -e "${RED}$FILE${NC} not found in $SHADERS_DIR"
    fi
done

echo -e "Applying retroarch base configurations"

# Change default configurations
RETROARCH_CONFIG_FILE="${RETROARCH_DIR}retroarch.cfg"
crudini --set "$RETROARCH_CONFIG_FILE" "" "input_exit_emulator" '"nul"' # Remove ESC as exit emulator > conflicts with ScummVM
crudini --set "$RETROARCH_CONFIG_FILE" "" "fps_show" '"true"'
crudini --set "$RETROARCH_CONFIG_FILE" "" "video_shader_enable" '"true"'
crudini --set "$RETROARCH_CONFIG_FILE" "" "video_shader_remember_last_dir" '"true"'
crudini --set "$RETROARCH_CONFIG_FILE" "" "video_driver" '"vulcan"'

echo -e "Applying configurations: 3DO > Opera"
3DO_OPERA_CONFIG_FILE="${RETROARCH_DIR}config/Opera/Opera.opt"
crudini --set "$3DO_OPERA_CONFIG_FILE" "" "opera_high_resolution" '"enabled"'

echo -e "Applying configurations: Playstation > SwanStation"
PS_SWANSTATION_CONFIG_FILE="${RETROARCH_DIR}config/SwanStation/SwanStation.opt"
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CDROM_LoadImagePatches" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CDROM_PreCacheCHD" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CPU_FastmemRewrite" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CPU_RecompilerICache" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_ChromaSmoothing24Bit" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_DownsampleMode" '"Box"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_MSAA" '"8"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPColorCorrection" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPDepthBuffer" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPEnable" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPPreserveProjFP" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPVertexCache" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_Renderer" '"Vulkan"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_ResolutionScale" '"5"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_TrueColor" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_UseSoftwareRendererForReadbacks" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_WidescreenHack" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_TextureReplacements_EnableVRAMWriteReplacements" '"true"'
crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_TextureReplacements_PreloadTextures" '"true"'

echo -e "Applying configurations: Playstation > Beetle PSX HW"
PS_BEETLE_PSX_HW_CONFIG_FILE="${RETROARCH_DIR}config/Beetle PSX HW/Beetle PSX HW.opt"
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_adaptive_smoothing" '"enabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_cd_access_method" '"precache"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_dither_mode" '"disabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_frame_duping" '"enabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_mdec_yuv" '"enabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_msaa" '"16x"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_pal_video_timing_override" '"enabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_pgxp_mode" '"memory only"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_pgxp_texture" '"enabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_pgxp_vertex" '"enabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_renderer" '"hardware_vk"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_replace_textures" '"enabled"'
crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_track_textures" '"enabled"'

echo -e "Applying configurations: ScummVM"
SCUMMVM_CONFIG_FILE="${RETROARCH_DIR}/system/scummvm.ini"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "themepath" "${RETROARCH_DIR}system/scummvm/theme"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "extrapath" "${RETROARCH_DIR}system/scummvm/extra"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "gui_theme" "scummmodern"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "opl_driver" "nuked"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "gm_device" "fluidsynth"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "multi_midi" "true"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "mt32_device" "mt32"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "speech_mute" "false"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "subtitles" "true"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "fullscreen" "true"
crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "soundfont" "${RETROARCH_DIR}system/scummvm/extra/Roland_SC-55.sf2"

# echo -e "${RED}RetroArch: To fix black boxes icons. Start RetroArch > Main Menu > Online Updater > Update Assets${NC}"
