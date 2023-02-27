# gitaction

This repository is used to collect the github action toolings, sample work flows and documentations.

## Runner in container

To build the containerized runner,
```
podman build --build-arg RUNNER_VERSION=2.301.1 --tag quay.io/jianzzha/runner:2.301.1 .
```

To run the containerized runner,
```
podman run --name runner -it --rm --privileged -e GH_TOKEN='<you github token>' -e GH_OWNER='<your github id>' -e GH_REPOSITORY='<repo name>' -v <host dir>:<container dir> quay.io/jianzzha/runner:2.301.1
```

To run the containerized runner as a systemd service,
```
cat <<EOF >/etc/systemd/system/runner.service
[Unit]
Description="github self runner"
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/podman run --name runner --rm --privileged -e GH_TOKEN='<you github token>' -e GH_OWNER='jianzzha' -e GH_REPOSITORY='<repo name>' -v <host dir>:<container dir> quay.io/jianzzha/runner:2.301.1
ExecStop=/usr/bin/podman stop runner

[Install]
WantedBy=multi-user.target
EOF

systemctl enable runner --now
```




