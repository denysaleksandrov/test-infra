#!/bin/bash
#!/usr/bin/env bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2023 The Nephio Authors.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

## TEST METADATA
## TEST-NAME: Deploy free5gc UPF to edge clusters
##

set -o pipefail
set -o errexit
set -o nounset
[[ "${DEBUG:-false}" != "true" ]] || set -o xtrace

export HOME=${HOME:-/home/ubuntu/}
export E2EDIR=${E2EDIR:-$HOME/test-infra/e2e}
export TESTDIR=${TESTDIR:-$E2EDIR/tests}
export LIBDIR=${LIBDIR:-$E2EDIR/lib}

source "${LIBDIR}/k8s.sh"

kubeconfig="$HOME/.kube/config"

k8s_apply "$kubeconfig" "$TESTDIR/006-edge-free5gc-upf.yaml"

for cluster in "edge01" "edge02"; do
  k8s_wait_exists "$kubeconfig" 600 "default" "packagevariant" "edge-free5gc-upf-${cluster}-free5gc-upf"
done

for cluster in "edge01" "edge02"; do
  k8s_wait_ready "$kubeconfig" 600 "default" "packagevariant" "edge-free5gc-upf-${cluster}-free5gc-upf"
done

for cluster in "edge01" "edge02"; do
  cluster_kubeconfig=$(k8s_get_capi_kubeconfig "$kubeconfig" "default" "$cluster")
  k8s_wait_exists "$cluster_kubeconfig" 600 "free5gc-upf" "deployment" "free5gc-upf"
  k8s_wait_ready_replicas "$cluster_kubeconfig" 600 "free5gc-upf" "deployment" "free5gc-upf"
done
