FROM debian:bullseye-slim
LABEL Description="Deploy an application using the Balena CLI."

RUN apt-get update && apt-get --yes install curl wget && rm -rf /var/lib/apt/lists/*

# download the standalone balena-cli
# balena-cli-*-linux-x64-standalone.tar.gz
RUN curl -s https://api.github.com/repos/balena-io/balena-cli/releases/latest \
	| grep "linux" \
	| grep "x64" \
	| cut -d : -f 12,3 \
	| tr -d \" \
	| grep github | head -n1 \
	| xargs -I {} sh -c "wget https:{}" && \
	tar -xzf balena-cli-*-linux-x64-standalone.tar.gz

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
CMD ["/bin/bash", "/entrypoint.sh"]
