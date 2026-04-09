#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#######################################################################################
#                                                                                     #
#                                        README                                       #
#                                                                                     #
#######################################################################################
#    Available Parameters :                                                           #
#        1. `-c`: for Check items only                                                #
#        2. `-b`: for Backup items only                                               #
#    If no parameter is specified, all items will be executed.                        #
#######################################################################################


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

# ===== Parameter Initial =====
current_ccdadm_version=$(cat /etc/eccd/eccd_image_version.ini | grep -i release | awk -F "=" '{print $2}')
ccd_nodes=$(kubectl get nodes -o wide | awk 'NR>1 {print $6}')

# ===== Print Command =====
print_cmd() {
    printf "\n${BOLD}${PURPLE}[COMMAND]${RESET} %s\n" "$1";
}

#  ===== Check CCD Version =====
#  ===== Check if the current CCD cluster in the newer version than 2.30.5 =====
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

# ===== run_check function =====
run_check() {
    local DESC="$1"
    local CMD="$2"

    log_info "$DESC"
    print_cmd "$CMD"

    if bash -c "$CMD"; then
      log_ok "$DESC Completed"
    else
      log_error "$DESC Failed"
    fi
}

# ===== run_check_all_nodes function =====
run_check_all_nodes() {
    local DESC="$1"
    local CMD="$2"

    log_info "$DESC"

    local failed=0

    for NODE in $ccd_nodes; do
        print_cmd "[$NODE] $CMD"

        if ssh -o ConnectTimeout=5 \
               -o StrictHostKeyChecking=no \
               "$NODE" "$CMD"; then
            log_ok "[$NODE] Success"
        else
            log_error "[$NODE] Failed"
            failed=1
        fi
    done

    if [ $failed -eq 0 ]; then
        log_ok "$DESC Completed"
    else
        log_error "$DESC Failed for some nodes, please check log for more further information!"
        return 1
    fi
}



# ===== 1. Backup Part =====
# ===== 1.1 Get CCD Version =====
get_ccd_version() {
    run_check_all_nodes "Get CCD Version on All Nodes" "cat /etc/eccd/eccd_image_version.ini"
}

# ===== 1.2 Get IP Interface on all CCD Nodes =====
get_ip_interface_on_all_nodes() {
    run_check_all_nodes "Get IP Interface on all CCD Nodes" "ip a"
}

# ===== 1.3 Get IP Route on all CCD Nodes =====
get_ip_route_on_all_nodes() {
    run_check_all_nodes "Get IP Route on all CCD Nodes" "ip r"
}

# ===== 1.4 Get /etc/hosts on all CCD Nodes =====
get_hosts_file() {
    run_check_all_nodes "Get /etc/hosts on all CCD Nodes" "cat /etc/hosts"
}

# ===== 1.5 Get resolv.conf on all CCD Nodes =====
get_DNS_server_info() {
    run_check_all_nodes "Get resolv.conf on all CCD Nodes" "cat /etc/resolv.conf"
}

# ===== 2. CCD General Health Check Part =====
# ===== 2.1 Access Active Alarm List =====
access_active_alarm() {
    local CMD_Newer_Than_2_30_0='curl -sk https://$(kubectl get svc/eric-pm-alertmanager -n monitoring -o jsonpath='\''{.spec.clusterIP}'\''):9093/api/v2/alerts | jq'
    local CMD_Older_Than_2_30_0='curl -sk http://$(kubectl get svc/eric-pm-alertmanager -n monitoring -o jsonpath='\''{.spec.clusterIP}'\''):9093/api/v1/alerts | jq'
    CMD=$(select_command_for_2_30_0 "$CMD_Newer_Than_2_30_0" "$CMD_Older_Than_2_30_0")
    run_check "Access Active Alarm List" "$CMD"
}

# ===== 2.2 Get CCD Nodes =====
get_ccd_nodes() {
    run_check "Get CCD Nodes" "kubectl get nodes -owide"
}

# ===== 2.3 Get BMH Status =====
get_bmh_status() {
    run_check "Get BMH Status" "kubectl get bmh -A"
}

# ===== 2.4 Get Machine Status =====
get_machine_status() {
    run_check "Get Machine Status" "kubectl get machine -A"
}

# ===== 2.5 Get PDB Status =====
get_PDB_status() {
    run_check "Get All PDB Status" "kubectl get pdb -A"

    log_warn "Check Problematic PDB"
    CMD='kubectl get pdb -A -o custom-columns=Namespace:.metadata.namespace,Name:.metadata.name,MinAvailable:.spec.minAvailable,MaxUnavailable:.spec.maxUnavailable,AllowedDisruptions:.status.disruptionsAllowed,CurrentHealthy:.status.currentHealthy,DesiredHealthy:.status.desiredHealthy,Expected:.status.expectedPods | awk '\''NR==1 || ($5=="0" && $8!="0")'\'''
    print_cmd "$CMD"
    OUTPUT=$(eval "$CMD" | tail -n +2 || true)
    if [[ -z "$OUTPUT" ]]; then
      log_ok "No Potential PDB Problem!"
    else
      log_warn "Problematic PDB List:"
      printf "%s\n" "$OUTPUT"
    fi
}

# ===== 2.6 Get Pods from All Namespaces =====
get_pod_status() {
    log_info "Get Pod List from All Namespaces"
    ns=$(kubectl get ns --no-headers | awk '{print $1}')
    for ns in $ns; do
      run_check "Get Pods from Namespaces: $ns" "kubectl get pods -owide -n $ns"
    done

    log_warn "Check Problematic PODs"
    CMD='kubectl get pods -A -o wide | grep -iv Running| grep -iv Completed'
    print_cmd "$CMD"
    OUTPUT=$(eval "$CMD" | tail -n +2 || true)
    if [[ -z "$OUTPUT" ]]; then
      log_ok "All pods are running well!"
    else
      log_warn "Pods in abnormal status:"
     printf "%s\n" "$OUTPUT"
    fi

    log_warn "Check if pods are fully running"
    CMD='kubectl get pod -A | awk -F"[ /]+" '\''BEGIN{found=0} !/NAME/ {if ($3!=$4) { found=1; print $0}}'\'''
    print_cmd "$CMD"
    OUTPUT=$(eval "$CMD" | tail -n +2 || true)
    if [[ -z "$OUTPUT" ]]; then
      log_ok "All Containers are UP!"
    else
      log_warn "Pods who has container in abnormal status:"
      printf "%s\n" "$OUTPUT"
    fi
}

# ===== 2.7 Get SVC Status =====
get_svc_status() {
    run_check "Get SVC Status" "kubectl get svc -A"

    log_warn "Check if any SVC is in pending status"
    CMD='kubectl get svc -A | grep -i pending'
    print_cmd "$CMD"
    OUTPUT=$(eval "$CMD" | tail -n +2 || true)
    if [[ -z "$OUTPUT" ]]; then
      log_ok "No SVC is in pending state!"
    else
      log_warn "Pending SVC:"
      printf "%s\n" "$OUTPUT"
    fi
}

# ===== 2.8 Get ETCD Status =====
get_etcd_status() {
    run_check "Get ETCD Member List" 'sudo bash -c ". /etc/profile.d/etcdctl.sh && etcdctl3 member list"'
    run_check "Get ETCD Endpoint List" 'sudo bash -c ". /etc/profile.d/etcdctl.sh && etcdctl3 endpoint status --cluster -wtable"'
    run_check "Check ETCD Endpoint Health" 'sudo bash -c ". /etc/profile.d/etcdctl.sh && etcdctl3 endpoint health --cluster -wtable"'
}

# ===== 2.9 Check BGP Session Status =====
get_bgp_status() {
    run_check "Check BGP Session Status" 'for i in $(kubectl get pods -n kube-system | grep -i speak | awk '\''{print $1}'\'') ;  do echo $i; kubectl exec $i -n kube-system -- birdcl show pr ;  done'
    run_check "Check BFD Session Status" 'for i in $(kubectl get pods -n kube-system | grep -i speak | awk '\''{print $1}'\'') ;  do echo $i; kubectl exec $i -n kube-system -- birdcl show bfd session;  done'
}

# ===== 2.10 Check kubeadm cert expiration =====
get_kubeadm_cert_info() {
    run_check "Check kubeadm cert expiration" 'sudo /usr/local/bin/kubeadm certs check-expiration'
}

# ===== 2.11 Check CEPH Cluster Status =====
get_ceph_cluster_status() {
    local CMD_Newer_Than_2_30_0='/var/lib/eccd/ceph_cli.sh ceph'
    local CMD_Older_Than_2_30_0='/var/lib/eccd/ceph_cli.sh'
    CMD=$(select_command_for_2_30_0 "$CMD_Newer_Than_2_30_0" "$CMD_Older_Than_2_30_0")
    run_check "Check CEPH SW Version" "$CMD version"
    run_check "Check CEPH Status" "$CMD -s"
    run_check "Check CEPH Pool Storage Usage" "$CMD df"
    run_check "Check CEPH OSD Storage Usage_1" "$CMD osd df"
    run_check "Check CEPH OSD Storage Usage_2" "$CMD osd utilization"
    run_check "Check CEPH OSD Tree" "$CMD osd tree"
    run_check "Check CEPH Device List" "$CMD device ls"
    run_check "Check CEPH Quorum Status" "$CMD quorum_status --format json-pretty"
    run_check "Check CEPH MON Status" "$CMD mon stat"
    run_check "Check CEPH MDS Status" "$CMD mds stat"
}

# ===== 2.12 Check NTP status =====
get_ntp_status() {
    local CMD='echo "=== timedatectl ==="; timedatectl | grep NTP; timedatectl | grep synchronized; echo; echo "=== chronyc sources ==="; chronyc sources'
    run_check_all_nodes "Check NTP Status on All CCD Nodes" "$CMD"
}

# ===== 2.13 Check Latest Log of Pod ccd-license-consumer =====
get_license_consumer_log() {
    local CMD='kubectl logs -n kube-system $(kubectl get pods -n kube-system -o name | grep ccd-license-consumer) | grep -A 2 "Requesting license" | tail -n 10'
    run_check "Get Latest Log of Pod ccd-license-consumer" "$CMD"
}

# ===== 2.14 Get Deploy eric-app-sys-info-handler Info =====
get_sys_info_handler_info() {
    run_check "Get Deploy eric-app-sys-info-handler Info" "kubectl describe deployments eric-app-sys-info-handler -n kube-system"
}


# ===== Definition for Two Options `-c` and `-b` =====
if [[  $# -eq 0 ]]; then
    log_info "No option specified, Running all Check...."
    access_active_alarm
    get_ccd_nodes
    get_bmh_status
    get_machine_status
    get_PDB_status
    get_pod_status
    get_svc_status
    get_etcd_status
    get_bgp_status
    get_kubeadm_cert_info
    get_ceph_cluster_status
    get_ntp_status
    get_license_consumer_log
    get_sys_info_handler_info
    get_ccd_version
    get_ip_interface_on_all_nodes
    get_ip_route_on_all_nodes
    get_hosts_file
    get_DNS_server_info

else
    case "$1" in
      -c)
        access_active_alarm
        get_ccd_nodes
        get_bmh_status
        get_machine_status
        get_PDB_status
        get_pod_status
        get_svc_status
        get_etcd_status
        get_bgp_status
        get_kubeadm_cert_info
        get_ceph_cluster_status
        get_ntp_status
        get_license_consumer_log
        get_sys_info_handler_info
        ;;
      -b)
        get_ccd_version
        get_ip_interface_on_all_nodes
        get_ip_route_on_all_nodes
        get_hosts_file
        get_DNS_server_info
    esac
fi
