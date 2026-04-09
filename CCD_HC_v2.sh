#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ===== Color Definition =====
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
RESET="\033[0m"
BOLD="\033[1m"

# ===== Log Level =====
log_info()  { printf "\n${BOLD}${BLUE}[INFO] %s${RESET}\n" "$1"; }
log_ok()    { printf "\n${BOLD}${GREEN}[OK] %s${RESET}\n" "$1"; }
log_warn()  { printf "\n${BOLD}${YELLOW}[WARN] %s${RESET}\n" "$1"; }
log_error() { printf "\n${BOLD}${RED}[ERROR] %s${RESET}\n" "$1"; }

# ===== get_ccd_om_sp =====
read -rp "Please enter CCD_OM_SP VIP for target CCD cluster: " CCD_OM_SP

if [[ -z "$CCD_OM_SP" ]]; then
    echo "ERROR: CCD VIP cannot be empty!"
    exit 1
fi

echo "Using CCD VIP: $CCD_OM_SP"

# ===== Parameter Initial =====
current_ccdadm_version=$(cat /etc/eccd/eccd_image_version.ini | grep -i release | awk -F "=" '{print $2}')
ccd_nodes=$(kubectl get nodes -o wide | awk 'NR>1 {print $6}')

# ===== Print Command =====
print_cmd() {
    printf "\n${BOLD}${PURPLE}[COMMAND]${RESET} %s\n" "$1";
}

#  ===== Check CCD Version =====
#  ===== Check if the current CCD cluster in the newer version than 2.30.0 =====
select_command_for_2_30_0() {
    local CMD_Newer_Than_2_30_0="$1"
    local CMD_Older_Than_2_30_0="$2"
    local target_ccdadm_version
    target_ccdadm_version="2.30.0"

    if [[ "$(printf "%s\n" "$current_ccdadm_version" "$target_ccdadm_version" | sort -V | head -n 1)" == "$target_ccdadm_version" ]]; then
      echo "$CMD_Newer_Than_2_30_0"
    else
      echo "$CMD_Older_Than_2_30_0"
    fi
}

# ===== local_run_check function =====
local_check() {
    local DESC="$1"
    local CMD="$2"

    log_info "$DESC"
    print_cmd "$CMD"

    if bash -c "$CMD"; then
      log_ok "$DESC completed"
    else
      log_error "$DESC failed"
    fi
}

# ===== remote_check_on_ctrl function =====
remote_check_on_ctrl() {
    local DESC="$1"
    local CMD="$2"

    log_info "$DESC"
    print_cmd "$CMD"
    local ssh_cmd=("ssh" "-o" "StrictHostKeyChecking=no" "eccd@$CCD_OM_SP" "$CMD")

    if "${ssh_cmd[@]}"; then
        log_ok "$DESC completed"
    else
        log_error "$DESC failed"
    fi
}

# ===== remote_check_on_all_nodes function =====
remote_check_on_all_nodes() {
    local DESC="$1"
    local CMD="$2"

    log_info "$DESC on all CCD nodes"

    ssh -o StrictHostKeyChecking=no "eccd@$CCD_OM_SP" bash -s <<EOF
NODES="$ccd_nodes"
DESC="$DESC"
CMD="$CMD"

run_check() {
    local DESC="\$1"
    local CMD="\$2"

    printf "[INFO] %s\n" "\$DESC"
    printf "[COMMAND] %s\n" "\$CMD"

    if eval "\$CMD"; then
        printf "[OK] %s completed\n" "\$DESC"
    else
        printf "[ERROR] %s failed\n" "\$DESC"
    fi
}

for NODE in \$NODES; do
    run_check "Check hostname on \$NODE" "ssh -q \$NODE hostname"
done
EOF

    if [[ $? -eq 0 ]]; then
        log_ok "$DESC completed"
    else
        log_error "$DESC failed"
    fi
}


echo "=========================================="
echo "   CCD Health Check"
echo "   Time: $(date)"
echo "=========================================="
