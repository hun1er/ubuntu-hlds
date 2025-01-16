# Base image
FROM ubuntu:latest

# Build arguments
ARG TZ="Europe/Kiev" \
    LANG="en_US.UTF-8" \
    HLDS_DIR="/hlds" \
    HLDS_BUILD="8684"

# Environment variables
ENV TZ="$TZ" \
    LANG="$LANG" \
    HLDS_DIR="$HLDS_DIR" \
    HLDS_BUILD="$HLDS_BUILD"

# Copy scripts to container
COPY "scripts/*" "/tmp/"

# Container setup
RUN set -eu; \
    # Switch to temp directory
    cd /tmp; \
    \
    # Enable 32-bit architecture support
    dpkg --add-architecture i386; \
    \
    # Update and upgrade the system
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get dist-upgrade -y; \
    \
    # Configure system timezone
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime; \
    echo "$TZ" > /etc/timezone; \
    \
    # Install prerequisites
    apt-get install -y \
    ca-certificates \
    bzip2 \
    curl \
    locales \
    tar \
    wget \
    zlib1g \
    libc6 libc6:i386 \
    libstdc++6 libstdc++6:i386 \
    libgcc-s1 libgcc-s1:i386 \
    gdb gdb-doc gdbserver; \
    \
    # Generate and configure the locale
    locale-gen "$LANG"; \
    \
    # Execute setup scripts
    ./install_steamcmd.sh; \
    ./install_hlds.sh; \
    \
    # Clean up the system
    apt-get autoremove -y --purge; \
    apt-get autoclean -y; \
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/*; \
    rm -rf /var/log/*; \
    rm -rf /tmp/*;

# Set the working directory
WORKDIR "$HLDS_DIR"

# Set entrypoint and default arguments
ENTRYPOINT ["./hlds_run"]
CMD ["-debug", "-norestart", "-game", "cstrike", "-noipx", "-tos", "+sys_ticrate", "0", "+maxplayers", "32", "+map", "de_dust2"]
