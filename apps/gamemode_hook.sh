#!/usr/bin/env bash
# GameMode performance tuning script
# Dynamic tweaks with persistent state caching

CONFIG_DIR="$HOME/.config/gamemode"
CACHE_FILE="$CONFIG_DIR/persist.conf"
LOG_FILE="$CONFIG_DIR/debug.log"

mkdir -p "$CONFIG_DIR"

# Redirect output to log
exec >>"$LOG_FILE" 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Helper: key=value persistence
function save_state() {
    local key="$1"
    local value="$2"
    grep -q "^${key}=" "$CACHE_FILE" 2>/dev/null || echo "${key}=${value}" >> "$CACHE_FILE"
}

function get_state() {
    local key="$1"
    grep "^${key}=" "$CACHE_FILE" 2>/dev/null | cut -d'=' -f2-
}

function get_unique_prefixes() {
    local k
    for k in "${!tweaks[@]}"; do
        echo "${k%%,*}"
    done | sort -u
}

# ---------- Parameter validation ----------
mode="$1"
if [[ "$mode" != "start" && "$mode" != "end" ]]; then
    echo "Usage: $0 {start|end}"
    exit 1
fi

if [ "$mode" == "start" ]; then
    :> $LOG_FILE
fi

log "--- Gamemode $mode ---"

function handler_bluetooth_apply() {
    local prefix="bluetooth"
    local rf_state service_state connected
    log "Handler apply: bluetooth -> handler_bluetooth_apply"

    # rf_state: "yes" (soft blocked) or "no" (unblocked)
    rf_state="$(rfkill list bluetooth 2>/dev/null | grep -m1 'Soft blocked' | awk '{print $3}' || true)"
    service_state="$(systemctl is-active bluetooth.service 2>/dev/null || true)"

    # Only query bluetoothctl if the service is active
    if [ "$service_state" = "active" ]; then
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            connected="$(bluetoothctl devices Connected 2>/dev/null | grep -c '^Device ' || true)"
        else
            connected=0
        fi
    else
        connected=0
    fi

    # persist originals
    save_state "${prefix}_rf" "${rf_state:-unknown}"
    save_state "${prefix}_service" "${service_state:-unknown}"
    save_state "${prefix}_connected" "${connected:-0}"

    # If no connected devices, we can disable bluetooth
    if [ "${connected:-0}" -eq 0 ]; then
        # If adapter was unblocked (rf_state == "no"), block it and mark we did it
        if [ "${rf_state}" = "no" ]; then
            log "handler_bluetooth_apply: adapter unblocked -> blocking adapter"
            sudo rfkill block bluetooth 2>&1 | tee -a "$LOG_FILE" >/dev/null || log "WARN: rfkill block failed"
            save_state "${prefix}_blocked_by_gamemode" "yes"
        else
            save_state "${prefix}_blocked_by_gamemode" "no"
        fi

        # Stop service only if it was active
        if [ "${service_state}" = "active" ]; then
            log "handler_bluetooth_apply: stopping bluetooth.service"
            sudo systemctl stop bluetooth.service 2>&1 | tee -a "$LOG_FILE" >/dev/null || log "WARN: failed to stop bluetooth.service"
            save_state "${prefix}_service_stopped_by_gamemode" "yes"
        else
            save_state "${prefix}_service_stopped_by_gamemode" "no"
        fi
    else
        log "handler_bluetooth_apply: device(s) connected (${connected}) -> keeping adapter/service"
        save_state "${prefix}_blocked_by_gamemode" "no"
        save_state "${prefix}_service_stopped_by_gamemode" "no"
    fi
}

function handler_bluetooth_undo() {
    local prefix="bluetooth"
    log "Handler undo: bluetooth -> handler_bluetooth_undo"

    local rf_state service_state connected blocked_by service_stopped_by
    rf_state="$(get_state "${prefix}_rf")"
    service_state="$(get_state "${prefix}_service")"
    connected="$(get_state "${prefix}_connected")"
    blocked_by="$(get_state "${prefix}_blocked_by_gamemode")"
    service_stopped_by="$(get_state "${prefix}_service_stopped_by_gamemode")"

    # Restore service if we stopped it
    if [ "${service_stopped_by}" = "yes" ]; then
        current="$(systemctl is-active bluetooth.service 2>/dev/null || true)"
        if [ "$current" != "active" ]; then
            log "handler_bluetooth_undo: starting bluetooth.service (was stopped by gamemode)"
            sudo systemctl start bluetooth.service 2>&1 | tee -a "$LOG_FILE" >/dev/null || log "WARN: failed to start bluetooth.service"
        else
            log "handler_bluetooth_undo: bluetooth.service already active"
        fi
    else
        log "handler_bluetooth_undo: bluetooth.service was not stopped by gamemode"
    fi

    # Restore adapter block state: if gamemode blocked it, we should unblock
    if [ "${blocked_by}" = "yes" ]; then
        # only unblock if currently blocked
        cur_rf="$(rfkill list bluetooth 2>/dev/null | grep -m1 'Soft blocked' | awk '{print $3}' || true)"
        if [ "$cur_rf" = "yes" ]; then
            log "handler_bluetooth_undo: unblocking adapter (was blocked by gamemode)"
            sudo rfkill unblock bluetooth 2>&1 | tee -a "$LOG_FILE" >/dev/null || log "WARN: failed to rfkill unblock bluetooth"
        else
            log "handler_bluetooth_undo: adapter not blocked now, skipping unblock"
        fi
    else
        log "handler_bluetooth_undo: adapter was not blocked by gamemode, leaving as-is"
    fi
}

# ---------- Tweaks definition ----------
declare -A tweaks

# CPU Power Profile
tweaks[cpu_profile,name]="CPU Power Profile"
tweaks[cpu_profile,check]="powerprofilesctl get"
tweaks[cpu_profile,apply]="powerprofilesctl set performance"
tweaks[cpu_profile,undo]="powerprofilesctl set %s"

# CPU Idle States
tweaks[idle_states,name]="CPU idle states"
tweaks[idle_states,check]="cpupower idle-info | grep -c '(DISABLED)'"
tweaks[idle_states,apply]="sudo cpupower idle-set --disable-by-latency 1"
tweaks[idle_states,undo]="sudo cpupower idle-set --enable-all"

# Muffin unredirect fullscreen
tweaks[muffin_unredirect,name]="Muffin unredirect fullscreen windows"
tweaks[muffin_unredirect,check]="gsettings get org.cinnamon.muffin unredirect-fullscreen-windows"
tweaks[muffin_unredirect,apply]="gsettings set org.cinnamon.muffin unredirect-fullscreen-windows true"
tweaks[muffin_unredirect,undo]="gsettings set org.cinnamon.muffin unredirect-fullscreen-windows %s"

# Night Light
tweaks[night_light,name]="Night Light"
tweaks[night_light,check]="gsettings get org.cinnamon.settings-daemon.plugins.color night-light-enabled"
tweaks[night_light,apply]="gsettings set org.cinnamon.settings-daemon.plugins.color night-light-enabled false"
tweaks[night_light,undo]="gsettings set org.cinnamon.settings-daemon.plugins.color night-light-enabled %s"

# USB Autosuspend
tweaks[usb_autosuspend,name]="USB autosuspend"
tweaks[usb_autosuspend,check]="cat /sys/module/usbcore/parameters/autosuspend"
tweaks[usb_autosuspend,apply]="echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend >/dev/null"
tweaks[usb_autosuspend,undo]="bash -c 'echo %s | sudo tee /sys/module/usbcore/parameters/autosuspend >/dev/null'"

# Bluetooth (handled separately)
tweaks[bluetooth,name]="Bluetooth"
tweaks[bluetooth,apply]="handler_bluetooth_apply"
tweaks[bluetooth,undo]="handler_bluetooth_undo"

# Nvidia status for GPUPowerMizerMode: nvidia-settings -q GPUPowerMizerMode
# Nvidia parameters list: nvidia-settings --describe=all
# Check if nvidia-settings command exists
if command -v nvidia-settings >/dev/null 2>&1; then
    tweaks[nvidia_power,name]="NVIDIA PowerMizer mode"
    tweaks[nvidia_power,check]="nvidia-settings -q GPUPowerMizerMode | grep 'Attribute' | grep -o '[0-9]\+' | tail -n1"
    tweaks[nvidia_power,apply]="nvidia-settings -a GPUPowerMizerMode=1"
    tweaks[nvidia_power,undo]="nvidia-settings -a GPUPowerMizerMode=%s"
fi

# ---------- Apply tweaks ----------
if [ "$mode" == "start" ]; then
    if [ ! -s "$CACHE_FILE" ]; then
        notify-send "🎮 GameMode" "Performance mode started"
        log "Capturing original state to $CACHE_FILE"

        for prefix in $(get_unique_prefixes); do
            name="${tweaks[$prefix,name]}"
            check_cmd="${tweaks[$prefix,check]}"
            apply_cmd="${tweaks[$prefix,apply]}"

            [ -z "$apply_cmd" ] && continue

            orig_value=$(eval "$check_cmd" 2>/dev/null)
            save_state "$prefix" "$orig_value"
            log "Applying > $name (orig=$orig_value)"

            if [[ "$apply_cmd" =~ ^handler_ ]]; then
                $apply_cmd
            else
                eval "$apply_cmd" || log "FAIL: apply $prefix"
            fi
            log "OK: applied $prefix"
        done
    else
        notify-send "🎮 GameMode" "Performance mode started (cached)"
        log "Using cached system state — no overwrite."
    fi
fi

# ---------- Undo tweaks ----------
if [ "$mode" == "end" ]; then
    if [ -s "$CACHE_FILE" ]; then
        notify-send "🎮 GameMode" "Performance mode ended"
        log "Restoring original state from $CACHE_FILE"

        for prefix in $(get_unique_prefixes); do
            name="${tweaks[$prefix,name]}"
            undo_cmd="${tweaks[$prefix,undo]}"

            orig_value=$(get_state "$prefix")
            log "Restoring > $name (orig=$orig_value)"

            if [[ "$undo_cmd" =~ ^handler_ ]]; then
                $undo_cmd
            elif [ -n "$orig_value" ]; then
                eval "${undo_cmd//%s/$orig_value}" || log "FAIL: restore $prefix"
            else
                log "SKIP: no value for $prefix"
            fi
        done

        rm -f "$CACHE_FILE"
        log "Restore complete and cache removed"
    else
        notify-send "🎮 GameMode" "Performance mode ended (nothing to restore)"
        log "No previous state found — nothing to restore."
    fi
fi
