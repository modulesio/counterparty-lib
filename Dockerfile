FROM counterparty/base

MAINTAINER Counterparty Developers <dev@counterparty.io>

# Install bitcoind
WORKDIR /
RUN curl -L https://github.com/btcdrak/bitcoin/releases/download/v0.13.2-addrindex/bitcoin-0.13.2-addrindex-x86_64-linux-gnu.tar.gz | tar -zx && mv bitcoin* bitcoin

# Install counterparty-lib
COPY . /counterparty-lib
WORKDIR /counterparty-lib
RUN pip3 install -r requirements.txt
RUN python3 setup.py develop
RUN python3 setup.py install_apsw
RUN python3 setup.py install_serpent

# HACK: https://github.com/CounterpartyXCP/counterparty-lib/blob/113aa54fe246ae16eab9dea37212b263a3751e82/docker/start.sh#L11
RUN rm -rf /usr/local/lib/python3.5/dist-packages/bitcoin /usr/local/lib/python3.5/dist-packages/python_bitcoinlib-*.dist-info
RUN pip3 install --upgrade git+https://github.com/CounterpartyXCP/python-bitcoinlib.git@112d66b11cde30b9c7e10895f057baab13cc35ec#egg=python-bitcoinlib-0.7.0

# Install counterparty-cli
# NOTE: By default, check out the counterparty-cli master branch. You can override the BRANCH build arg for a different
# branch (as you should check out the same branch as what you have with counterparty-lib, or a compatible one)
# NOTE2: In the future, counterparty-lib and counterparty-cli will go back to being one repo...
ARG CLI_BRANCH=master
ENV CLI_BRANCH ${CLI_BRANCH}
RUN git clone -b ${CLI_BRANCH} https://github.com/CounterpartyXCP/counterparty-cli.git /counterparty-cli
WORKDIR /counterparty-cli
RUN pip3 install -r requirements.txt
RUN python3 setup.py develop

# Additional setup
COPY start.sh /root/start.sh
COPY docker/server.conf /root/.config/counterparty/server.conf
COPY docker/bitcoin.conf /root/.bitcoin/bitcoin.conf

# Pull the mainnet and testnet DB boostraps
# RUN counterparty-server bootstrap --quiet
RUN counterparty-server --testnet bootstrap --quiet

EXPOSE 4000 14000 8332 18332

# NOTE: Defaults to running on mainnet, specify -e TESTNET=1 to start up on testnet
ENTRYPOINT ["/bin/bash"]
