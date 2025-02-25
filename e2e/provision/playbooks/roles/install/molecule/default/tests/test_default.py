#   Copyright (c) 2023 The Nephio Authors.
#
#   Licensed under the Apache License, Version 2.0 (the "License"); you may
#   not use this file except in compliance with the License. You may obtain
#   a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#   License for the specific language governing permissions and limitations
#   under the License.
#


def test_deployments(host):
    expected = {
        "config-management-monitoring": ["otel-collector"],
        "config-management-system": [
            "config-management-operator",
            "reconciler-manager",
        ],
        "porch-system": [
            "function-runner",
            "porch-controllers",
            "porch-server",
        ],
        "nephio-system": [
            "ipam-controller",
            "nephio-5gc-controller",
            "nf-injector-controller",
            "package-deployment-controller-controller",
        ],
        "nephio-webui": ["nephio-webui"],
        "resource-group-system": ["resource-group-controller-manager"],
    }
    got = host.check_output(
        'kubectl get deploy -A \
-o jsonpath=\'{range .items[*]}{.metadata.name}{" "}{.metadata.namespace}\
{"\\n"}{end}\''
    )
    for namespace, deployments in expected.items():
        for deploy in deployments:
            assert deploy + " " + namespace in got
