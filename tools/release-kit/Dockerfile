
FROM ubuntu:22.04

# Prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root user and group with UID and GID 1000
RUN groupadd --gid 1000 ziskuser && \
    useradd --uid 1000 --gid 1000 --create-home ziskuser

# Install sudo and allow passwordless sudo for the user
RUN apt update && apt install -y sudo && \
    echo "ziskuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Prepare /output directory with correct permissions
RUN mkdir -p /home/ziskuser/output && chown ziskuser:ziskuser /home/ziskuser/output

# Copy all project files to the new user's home directory
COPY ./ /home/ziskuser/zisk-release-kit/

# Change ownership and make all files executable
RUN chown -R ziskuser:ziskuser /home/ziskuser && \
    find /home/ziskuser/zisk-release-kit -type f -exec chmod +x {} \;

# Switch to the non-root user
USER ziskuser

# Set working directory
WORKDIR /home/ziskuser/zisk-release-kit
