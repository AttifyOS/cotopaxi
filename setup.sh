#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${APM_TMP_DIR}" ]]; then
    echo "APM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_INSTALL_DIR}" ]]; then
    echo "APM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_BIN_DIR}" ]]; then
    echo "APM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.8.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $APM_TMP_DIR/cpython-3.8.13.tar.gz
  tar xf $APM_TMP_DIR/cpython-3.8.13.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/cpython-3.8.13.tar.gz

  $APM_PKG_INSTALL_DIR/python/bin/pip3.8 install cotopaxi[all]==1.6.0
  for tool in service_ping server_fingerprinter device_identification traffic_analyzer resource_listing protocol_fuzzer client_proto_fuzzer vulnerability_tester client_vuln_tester amplifier_detector active_scanner
  do
    echo '#!/usr/bin/env sh' > $APM_PKG_BIN_DIR/cotopaxi.$tool
    echo "$APM_PKG_INSTALL_DIR/python/bin/python3.8 -m cotopaxi.$tool \"\$@\"" >> $APM_PKG_BIN_DIR/cotopaxi.$tool
    chmod +x $APM_PKG_BIN_DIR/cotopaxi.$tool
  done

  echo "This package adds the commands:"
  for tool in service_ping server_fingerprinter device_identification traffic_analyzer resource_listing protocol_fuzzer client_proto_fuzzer vulnerability_tester client_vuln_tester amplifier_detector active_scanner
  do
    echo " - cotopaxi.$tool"
  done
}

uninstall() {
  rm -rf $APM_PKG_BIN_DIR/python
  for tool in service_ping server_fingerprinter device_identification traffic_analyzer resource_listing protocol_fuzzer client_proto_fuzzer vulnerability_tester client_vuln_tester amplifier_detector active_scanner
  do
    rm $APM_PKG_BIN_DIR/cotopaxi.$tool
  done
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1