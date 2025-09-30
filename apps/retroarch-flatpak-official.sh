#!/bin/bash

readonly APPLICATION_NAME="Retroarch (emulators + improvements configs) [official Flatpak]"
readonly APPLICATION_ID="org.libretro.RetroArch"

readonly APPLICATION_CONFIG_DIR="$HOME/.var/app/$APPLICATION_ID/config/retroarch"
readonly RETROARCH_CONFIG_SHADERS_DIR="${APPLICATION_CONFIG_DIR}/shaders"
readonly RETROARCH_CONFIG_SYSTEM_DIR="${APPLICATION_CONFIG_DIR}/system"

# Base URL for RetroArch cores
readonly RETROARCH_CORES_BASE_URL="https://buildbot.libretro.com/nightly/linux/x86_64/latest/"

# Base URL for RetroArch assets
readonly RETROARCH_ASSETS_BASE_URL="https://buildbot.libretro.com/assets"
readonly RETROARCH_ASSETS_FRONTEND_BASE_URL="${RETROARCH_ASSETS_BASE_URL}/frontend"
readonly RETROARCH_ASSETS_SYSTEM_BASE_URL="${RETROARCH_ASSETS_BASE_URL}/system"

# Flatpak Sandbox
readonly FLATPAK_SANDBOX_SHARED_DIR="$(flatpak info --show-location org.libretro.RetroArch)"
readonly FLATPAK_SANDBOX_SHADERS_DIR="$FLATPAK_SANDBOX_SHARED_DIR/files/share/libretro/shaders"

# Shaders
readonly SHADER_CRT=$(
    cat << 'EOF'
#reference "../../shaders/seven-selection/crt@fakelottes.slangp"
EOF
)

function perform_install() {
    flatpak_install "$APPLICATION_ID"
    echo "This script manager to set configurations to better visual and audio quality, requiring a better PC, not recommended to use with retropie"

    echo "Give access to /tmp folder, useful for scripts that automatically extracts file"
    flatpak override --user --filesystem=/tmp "org.libretro.RetroArch"

    echo "First execution to create config folder"
    (flatpak run $APPLICATION_ID &)
    sleep 3
    killall retroarch

    update_cores

    # Flatpak already has all assets and shaders packed: https://github.com/flathub/org.libretro.RetroArch/issues/184
    # update_assets

    echo "Copying shaders from Flatpak sandbox to config folder"
    cp -rT "$FLATPAK_SANDBOX_SHADERS_DIR" "$RETROARCH_CONFIG_SHADERS_DIR"
    create_preferred_shaders

    apply_configurations

    echo -e "Config location: $APPLICATION_CONFIG_DIR"
    echo -e "Launch content commando line:"
    echo -e "flatpak run org.libretro.RetroArch -L chailove_libretro.so FloppyBird.chailove"
}

function perform_uninstall() {
    flatpak_uninstall "$APPLICATION_ID"
}

function perform_check() {
    flatpak_is_installed "$APPLICATION_ID"
}

function update_assets() {
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
        FILE_PATH="${APPLICATION_CONFIG_DIR}/${FILE}"
        DIR_PATH="${FILE_PATH%.*}"

        # Download asset file
        wget --no-verbose --output-document="$FILE_PATH" "${RETROARCH_ASSETS_FRONTEND_BASE_URL}/${FILE}"

        # Extract asset file
        unzip -q "$FILE_PATH" -d "$DIR_PATH"

        # Remove zip file
        rm "$FILE_PATH"
    done

    echo "Assets update completed!"
}

create_preferred_shaders() {
    echo "Creating shaders directory: ${RETROARCH_CONFIG_SHADERS_DIR}/shaders_slang/seven-selection"
    DEST_SHADERS_DIR="${RETROARCH_CONFIG_SHADERS_DIR}/seven-selection"
    mkdir -p "$DEST_SHADERS_DIR"

    echo "Cloning shaders selection repository into: ${DEST_SHADERS_DIR}"
    git clone --depth=1 https://github.com/evandro777/shaders-selection.git "${DEST_SHADERS_DIR}"
    git -C "${DEST_SHADERS_DIR}" pull origin master # If already exists, try to update
}

function update_cores() {
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

        # NeoGeo CD
        "neocd"
    )

    IFS=$'\n' # Internal Field Separator > Change the default (space) to new line separator
    for CORE in ${CORES_LIST[@]}; do
        echo -e "Downloading core: ${ORANGE}${CORE}${NC}"
        wget --no-verbose --output-document="${APPLICATION_CONFIG_DIR}/cores/$CORE.zip" "${RETROARCH_CORES_BASE_URL}${CORE}_libretro.so.zip"
        unzip -q -o "${APPLICATION_CONFIG_DIR}/cores/$CORE.zip" -d "${APPLICATION_CONFIG_DIR}/cores/"
        rm "${APPLICATION_CONFIG_DIR}/cores/${CORE}.zip"

        # Start retroarch loading the core to generate default config file for the core
        case $CORE in
            "mame" | "atari800" | "opera" | "scummvm")
                # Force kill, these cores will load frontend
                (flatpak run $APPLICATION_ID -L "${CORE}" &)
                sleep 3
                killall retroarch
                ;;
            *)
                flatpak run $APPLICATION_ID -L "${CORE}"
                ;;
        esac
    done

    echo -e "Core download and extraction completed!"

    echo -e "Installing core system (bios) files"

    echo -e "Source for (bios) files from:"
    echo -e "libretro: https://github.com/Abdess/retroarch_system/tree/libretro"
    echo -e "PS1 & PS2 bios: https://github.com/Abdess/retroarch_system/tree/Other"
    echo -e "Retroarch system: https://github.com/Abdess/retroarch_system/tree/RetroArch"
    echo -e "Trying to download bios files..."

    patch_temp_folder="/tmp/retroarch_system/"
    # git clone --depth=1 --branch RetroArch https://github.com/Abdess/retroarch_system.git "${patch_temp_folder}"
    # mv -f "${patch_temp_folder}system/"* "${RETROARCH_CONFIG_SYSTEM_DIR}/" 2> /dev/null
    git clone --depth=1 https://github.com/Abdess/retroarch_system.git "${patch_temp_folder}"

    declare -A mapping=(
        ["3DO Company, The - 3DO"]=""
        ["Atari - Lynx"]=""
        ["Sega - Saturn"]=""
        ["Sega - Mega CD - Sega CD"]=""
        ["NEC - PC-98"]="np2kai/"
        ["Nintendo - Famicom Disk System"]=""
        ["Commodore - Amiga"]=""
        ["SNK - NeoGeo CD"]="neocd/"
    )

    for downloaded_core_path in "${!mapping[@]}"; do
        system_subfolder_path="${mapping[$downloaded_core_path]}"
        mv -f "${patch_temp_folder}${downloaded_core_path}"* "${RETROARCH_CONFIG_SYSTEM_DIR}/${system_subfolder_path}" 2> /dev/null
    done

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
        wget --no-verbose --output-document="${RETROARCH_CONFIG_SYSTEM_DIR}/${CORE}.zip" "${RETROARCH_ASSETS_SYSTEM_BASE_URL}/${CORE}.zip"
        unzip -q -o "${RETROARCH_CONFIG_SYSTEM_DIR}/${CORE}.zip" -d "${RETROARCH_CONFIG_SYSTEM_DIR}/"
        rm "${RETROARCH_CONFIG_SYSTEM_DIR}/${CORE}.zip"
    done

    # ScummVM extras plus
    RETROARCH_CONFIG_SYSTEM_SCUMMVM_DIR="${RETROARCH_CONFIG_SYSTEM_DIR}/scummvm/extra"
    wget --no-verbose --output-document="${RETROARCH_CONFIG_SYSTEM_SCUMMVM_DIR}/CM32L_CONTROL.ROM" "https://github.com/Abdess/retroarch_system/raw/refs/heads/RetroArch/system/CM32L_CONTROL.ROM"
    wget --no-verbose --output-document="${RETROARCH_CONFIG_SYSTEM_SCUMMVM_DIR}/CM32L_PCM.ROM" "https://github.com/Abdess/retroarch_system/raw/refs/heads/RetroArch/system/CM32L_PCM.ROM"
    wget --no-verbose --output-document="${RETROARCH_CONFIG_SYSTEM_SCUMMVM_DIR}/MT32_CONTROL.ROM" "https://github.com/Abdess/retroarch_system/raw/refs/heads/RetroArch/system/MT32_CONTROL.ROM"
    wget --no-verbose --output-document="${RETROARCH_CONFIG_SYSTEM_SCUMMVM_DIR}/MT32_PCM.ROM" "https://github.com/Abdess/retroarch_system/raw/refs/heads/RetroArch/system/MT32_PCM.ROM"

    # New ps1 bios from psp
    wget --no-verbose --output-document="${RETROARCH_CONFIG_SYSTEM_DIR}/PSXONPSP660.bin" "https://github.com/Abdess/retroarch_system/raw/refs/heads/Other/Sony%20-%20PlayStation/PSXONPSP660.BIN"

    echo -e "Core systems download and extraction completed!"

    echo -e "${RED}Some cores need to manually install bios roms into system folder '${RETROARCH_CONFIG_SYSTEM_DIR}/':${NC}"
    echo -e "${RED}MAME into {system folder}/mame/bios${NC}"
    echo -e "${RED}Commodore - Amiga (PUAE) into {system folder} => capsimg.so${NC}"

    # echo -e "${RED}Playstation (swanstation and mednafen_psx_hw) into root {system folder}${NC}"
    # echo -e "${RED}Sega Saturn (mednafen_saturn) into root {system folder}${NC}"
    # echo -e "${RED}Lynx (mednafen_lynx) into root {system folder} => lynxboot.img${NC}"
    # echo -e "${RED}3DO (Opera) into root {system folder}${NC}"
}

function apply_configurations() {
    echo -e "Applying retroarch base configurations"

    # Change default configurations
    RETROARCH_CONFIG_FILE="${APPLICATION_CONFIG_DIR}/retroarch.cfg"
    crudini --set "$RETROARCH_CONFIG_FILE" "" "input_exit_emulator" '"nul"'          # Remove ESC as exit emulator > conflicts with ScummVM
    crudini --set "$RETROARCH_CONFIG_FILE" "" "menu_swap_ok_cancel_buttons" '"true"' # OK button: A | Cancel button: B
    crudini --set "$RETROARCH_CONFIG_FILE" "" "fps_show" '"true"'
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_driver" '"vulkan"'
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_adaptive_vsync" '"true"'
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_frame_delay_auto" '"true"'  # Reduce input lag
    crudini --set "$RETROARCH_CONFIG_FILE" "" "input_poll_type_behavior" '"0"'   # Reduce input lag
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_max_swapchain_images" '"2"' # Reduce input lag
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_fullscreen" '"true"'
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_shader_enable" '"true"'
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_shader_remember_last_dir" '"true"'
    crudini --set "$RETROARCH_CONFIG_FILE" "" "auto_shaders_enable" '"true"'
    crudini --set "$RETROARCH_CONFIG_FILE" "" "video_shader_dir" '"'"$RETROARCH_CONFIG_SHADERS_DIR"'"'

    echo -e "Applying configurations: Genesis Plus GX > Mega Drive, Mega-CD, Master System, Game Gear, SG-1000"
    GENESIS_PLUS_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/Genesis Plus GX"
    GENESIS_PLUS_CONFIG_FILE="${GENESIS_PLUS_CONFIG_DIR}/Genesis Plus GX.opt"
    crudini --set "$GENESIS_PLUS_CONFIG_FILE" "" "genesis_plus_gx_left_border" '"left border"'
    crudini --set "$GENESIS_PLUS_CONFIG_FILE" "" "genesis_plus_gx_ym2413" '"enabled"'
    crudini --set "$GENESIS_PLUS_CONFIG_FILE" "" "genesis_plus_gx_ym2413_core" '"nuked"'
    crudini --set "$GENESIS_PLUS_CONFIG_FILE" "" "genesis_plus_gx_ym2612" '"mame (enhanced ym3438)"'
    crudini --set "$GENESIS_PLUS_CONFIG_FILE" "" "genesis_plus_gx_audio_filter" '"low-pass"'
    echo "$SHADER_CRT" > "${GENESIS_PLUS_CONFIG_DIR}/Genesis Plus GX.slangp"

    echo -e "Applying configurations: PicoDrive > Sega 32x, Mega Drive, Master System"
    PICO_DRIVE_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/PicoDrive"
    PICO_DRIVE_CONFIG_FILE="${PICO_DRIVE_CONFIG_DIR}/PicoDrive.opt"
    crudini --set "$PICO_DRIVE_CONFIG_FILE" "" "picodrive_audio_filter" '"low-pass"'
    crudini --set "$PICO_DRIVE_CONFIG_FILE" "" "picodrive_fm_filter" '"on"'
    crudini --set "$PICO_DRIVE_CONFIG_FILE" "" "picodrive_sprlim" '"enabled"'
    echo "$SHADER_CRT" > "${PICO_DRIVE_CONFIG_DIR}/PicoDrive.slangp"

    echo -e "Applying configurations: SNES > Snes9x"
    SNES_9x_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/Snes9x"
    SNES_9x_CONFIG_FILE="${SNES_9x_CONFIG_DIR}/Snes9x.opt"
    echo "$SHADER_CRT" > "${SNES_9x_CONFIG_DIR}/Snes9x.slangp"

    echo -e "Applying configurations: SNES > bsnes-hd beta"
    BSNES_HD_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/bsnes-hd beta"
    BSNES_HD_CONFIG_FILE="${BSNES_HD_CONFIG_DIR}/bsnes-hd beta.opt"
    echo "$SHADER_CRT" > "${BSNES_HD_CONFIG_DIR}/bsnes-hd beta.slangp"

    echo -e "Applying configurations: SNES > bsnes-mercury"
    BSNES_MERCURY_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/bsnes-mercury"
    BSNES_MERCURY_CONFIG_FILE="${BSNES_MERCURY_CONFIG_DIR}/bsnes-mercury.opt"
    echo "$SHADER_CRT" > "${BSNES_MERCURY_CONFIG_DIR}/bsnes-mercury.slangp"

    echo -e "Applying configurations: Arcade > FinalBurn Neo"
    FINAL_BURN_NEO_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/FinalBurn Neo"
    FINAL_BURN_NEO_CONFIG_FILE="${FINAL_BURN_NEO_CONFIG_DIR}/FinalBurn Neo.opt"
    crudini --set "$FINAL_BURN_NEO_CONFIG_FILE" "" "fbneo-allow-patched-romsets" '"disabled"' # Disabled to use with retroachievements hardcore mode
    echo "$SHADER_CRT" > "${FINAL_BURN_NEO_CONFIG_DIR}/FinalBurn Neo.slangp"

    echo -e "Applying configurations: Arcade > MAME"
    MAME_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/MAME"
    MAME_CONFIG_FILE="${MAME_CONFIG_DIR}/MAME.opt"
    echo "$SHADER_CRT" > "${MAME_CONFIG_DIR}/MAME.slangp"

    echo -e "Applying configurations: NeoGeo CD > neocd"
    NEOCD_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/NeoCD"
    NEOCD_CONFIG_FILE="${NEOCD_CONFIG_DIR}/NeoCD.opt"
    echo "$SHADER_CRT" > "${NEOCD_CONFIG_DIR}/NeoCD.slangp"

    echo -e "Applying configurations: NES > Mesen"
    MESEN_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/Mesen"
    MESEN_CONFIG_FILE="${MESEN_CONFIG_DIR}/Mesen.opt"
    echo "$SHADER_CRT" > "${MESEN_CONFIG_DIR}/Mesen.slangp"

    echo -e "Applying configurations: 3DO > Opera"
    OPERA_3DO_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/Opera"
    OPERA_3DO_CONFIG_FILE="${OPERA_3DO_CONFIG_DIR}/Opera.opt"
    crudini --set "$OPERA_3DO_CONFIG_FILE" "" "opera_high_resolution" '"enabled"'
    echo "$SHADER_CRT" > "${OPERA_3DO_CONFIG_DIR}/Opera.slangp"

    echo -e "Applying configurations: Playstation > SwanStation"
    PS_SWANSTATION_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/SwanStation"
    PS_SWANSTATION_CONFIG_FILE="${PS_SWANSTATION_CONFIG_DIR}/SwanStation.opt"
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CDROM_LoadImagePatches" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CDROM_PreCacheCHD" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CPU_FastmemRewrite" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_CPU_RecompilerICache" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_ChromaSmoothing24Bit" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_DownsampleMode" '"Adaptive"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_MSAA" '"8"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPColorCorrection" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPDepthBuffer" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPEnable" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPPreserveProjFP" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_PGXPVertexCache" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_Renderer" '"Vulkan"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_ResolutionScale" '"2"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_TrueColor" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_UseSoftwareRendererForReadbacks" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_GPU_WidescreenHack" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_TextureReplacements_EnableVRAMWriteReplacements" '"true"'
    crudini --set "$PS_SWANSTATION_CONFIG_FILE" "" "swanstation_TextureReplacements_PreloadTextures" '"true"'
    echo "$SHADER_CRT" > "${PS_SWANSTATION_CONFIG_DIR}/SwanStation.slangp"

    echo -e "Applying configurations: Playstation > Beetle PSX HW"
    PS_BEETLE_PSX_HW_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/Beetle PSX HW"
    PS_BEETLE_PSX_HW_CONFIG_FILE="${PS_BEETLE_PSX_HW_CONFIG_DIR}/Beetle PSX HW.opt"
    crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_override_bios" '"psxonpsp"'
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
    crudini --set "$PS_BEETLE_PSX_HW_CONFIG_FILE" "" "beetle_psx_hw_internal_resolution" '"2x"'
    PS_BEETLE_PSX_HW_CONFIG_OVERRIDE_FILE="${APPLICATION_CONFIG_DIR}/config/Beetle PSX HW/Beetle PSX HW.cfg"
    crudini --set "$PS_BEETLE_PSX_HW_CONFIG_OVERRIDE_FILE" "" "fastforward_frameskip" '"false"'    # Disable fastforward "SPACE BAR" > Breaks emulator
    crudini --set "$PS_BEETLE_PSX_HW_CONFIG_OVERRIDE_FILE" "" "run_ahead_enabled" '"false"'        # Disable run ahead > Breaks emulator
    crudini --set "$PS_BEETLE_PSX_HW_CONFIG_OVERRIDE_FILE" "" "preemptive_frames_enable" '"false"' # Disable preemptive frames > Breaks emulator
    echo "$SHADER_CRT" > "${PS_BEETLE_PSX_HW_CONFIG_DIR}/Beetle PSX HW.slangp"

    echo -e "Applying configurations: Saturn > Beetle Saturn"
    BEETLE_SATURN_CONFIG_DIR="${APPLICATION_CONFIG_DIR}/config/Beetle Saturn"
    BEETLE_SATURN_CONFIG_FILE="${BEETLE_SATURN_CONFIG_DIR}/Beetle Saturn.opt"
    crudini --set "$BEETLE_SATURN_CONFIG_FILE" "" "beetle_saturn_cdimagecache" '"enabled"'
    crudini --set "$BEETLE_SATURN_CONFIG_FILE" "" "beetle_saturn_midsync" '"enabled"'
    echo "$SHADER_CRT" > "${BEETLE_SATURN_CONFIG_DIR}/Beetle Saturn.slangp"

    echo -e "Applying configurations: ScummVM"
    SCUMMVM_CONFIG_FILE="${RETROARCH_CONFIG_SYSTEM_DIR}/scummvm.ini"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "themepath" "${RETROARCH_CONFIG_SYSTEM_DIR}/scummvm/theme"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "extrapath" "${RETROARCH_CONFIG_SYSTEM_DIR}/scummvm/extra"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "gui_theme" "scummmodern"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "gui_scale" "125"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "music_driver" "auto"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "native_mt32" "false"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "opl_driver" "nuked"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "gm_device" "fluidsynth"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "fluidsynth_misc_interpolation" "7th"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "multi_midi" "true"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "mt32_device" "mt32"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "speech_mute" "false"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "subtitles" "true"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "fullscreen" "true"
    crudini --set "$SCUMMVM_CONFIG_FILE" "scummvm" "soundfont" "${RETROARCH_CONFIG_SYSTEM_DIR}/scummvm/extra/Roland_SC-55.sf2"
    echo "$SHADER_CRT" > "${BEETLE_SATURN_CONFIG_DIR}/Beetle Saturn.slangp"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
