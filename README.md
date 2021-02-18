# WORK-IN-PROGRESS

This repo contains a helm chart to create a mirrored repository to 
support the mirroring & caching of RPMs to build the driver for
the gpu-operator. Periodically, the repos at cdn.redhat.com are
not available at time of building the gpu driver.

## Prerequisites

* entitlement certificate and key in .pem format
* you have connectivity to cdn.redhat.com from within the cluster
* worker nodes must be configured to use pod-based entitlements
* the helm chart is deployed into gpu-operator-resources
* the gpu-operator is configured to use the service (httpd) as
  the repo

## Download entitlement

## Enable entitled builds on OpenShift with a pod in a namespace

https://www.openshift.com/blog/how-to-use-entitled-image-builds-to-build-drivercontainers-with-ubi-on-openshift

Create a machineset that will disable the automounting of subscriptions. By default,
CRI-O will automount certificates already on the host.  UBI image contains all of the
files needed for pod-entitled builds.

Apply the following to your cluster.  It will be applied to all worker nodes.
If your requirement is on a different machineconfiguration, change the "worker" 
value.

```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 50-disable-secret-automount
spec:
  config:
    ignition:
      version: 2.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,Cg==
        filesystem: root
        mode: 0644
        path: /etc/containers/mounts.conf
```

To validate that the change was successful, you can `oc debug node/<worker>`
and `cat /host/etc/containers/mounts.conf`.  After a successful rollout, 
the file should exist and be empty.  In a failed MachineConfig rollout, 
the file would not exist.


