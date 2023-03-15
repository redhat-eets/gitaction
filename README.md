# gitaction

This repository is used to collect the github action toolings, sample work flows and documentations.

## Runner in container

To build the containerized runner,
```
podman build --build-arg RUNNER_VERSION=2.301.1 --tag quay.io/jianzzha/runner:2.301.1 .
```

To see what runner releases are available to use for `RUNNER_VERSION`, check on https://github.com/actions/runner/releases

Set up a podman secret for the github access token,
```
echo "your github access token" > token && podman secret create github_token token && rm -rf token
```

In the above step, one must use `github_token` as the secret name, as this is the default secret file name that the container will look for. If one choose a different name instead, then the enviroment variable ` GH_TOKEN_PATH` can be used to specify the secret file path when running podman to start the container.  

Prior to starting containerized runner make sure you have access to runner settings in your target repo: Settings -> Actions -> Runners. Otherwise runner registration will fail.

To run the containerized runner with this podman secret,
```
podman run --secret github_token --name runner -it --rm --privileged -e GH_OWNER='<your github id>' -e GH_REPOSITORY='<repo name>' -v <host dir>:<container dir> quay.io/jianzzha/runner:2.301.1
```

For illustration purpose, in the above podman command, we use -v option to pass some extra files from the host to the container, such as configuration files and testbed information, as our git action workflow will need them. You don't necessaily need to have such a volume mapping.

As mentioned earlier, if a different podman secret name is created, then an extra -e for `GH_TOKEN_PATH` can be added to specify the secret file path, for example,
```
-e GH_TOKEN_PATH=/run/secrets/<podman secret name>
```

To run the containerized runner as a systemd service,
```
cat <<EOF >/etc/systemd/system/runner.service
[Unit]
Description="github self runner"
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/podman run --secret github_token --name runner --rm --privileged -e GH_OWNER='<your github id>' -e GH_REPOSITORY='<repo name>' -v <host dir>:<container dir> quay.io/jianzzha/runner:2.301.1
ExecStop=/usr/bin/podman stop runner; /usr/bin/podman rm -i runner

[Install]
WantedBy=multi-user.target
EOF

systemctl enable runner --now
```

## Runner in OpenShift

Create secret for your github token,
```
kubectl create secret generic gh-token --from-literal=github_token=<your github token>
```

Create a folder and store the config.yaml and testbed.yaml in this folder,
```
$ls /home/jianzzha/sriov-testconfig
config.yaml
testbed.yaml
```

Create configuration from this folder,
```
oc create configmap test-config --from-file=/home/jianzzha/sriov-testconfig
```

Create deployment for the github runner, 
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: runner-deployment
  labels:
    app: runner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: runner
  template:
    metadata:
      labels:
        app: runner
    spec:
      volumes:
      - name: secret-volume
        secret:
          secretName: gh-token
      - name: config-volume
        configMap:
          name: test-config
      containers:
      - name: runner
        image: quay.io/jianzzha/runner:2.301.1
        securityContext:
          privileged: true
        env:
        - name: GH_OWNER
          value: "redhat-partner-solutions"
        - name: GH_REPOSITORY
          value: "rhel-sriov-test"
        - name: GH_TOKEN_PATH
          value: "/etc/gh_secrets/github_token"
        volumeMounts:
        - name: secret-volume
          readOnly: true
          mountPath: "/etc/gh_secrets"
        - name: config-volume
          mountPath: "/config"
```





