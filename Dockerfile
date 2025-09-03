# Builder stage to set up Tor from Tor Project's Trixie repository
FROM debian:bookworm-slim AS builder

# Install prerequisites
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    gnupg \
    wget \
    && apt-get clean

# Add Tor Project repository for Debian Trixie
RUN echo "deb [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org bookworm main" > /etc/apt/sources.list.d/tor.list \
    && echo "deb-src [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org bookworm main" >> /etc/apt/sources.list.d/tor.list

# Add Tor Project GPG key
RUN wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null

# Install Tor and the keyring package
RUN apt-get update && apt-get install -y \
    tor \
    && apt-get clean

# Find and copy Tor binary and its dependencies
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then ARCH=aarch64; fi && \
    mkdir -p /tor-libs/lib/${ARCH}-linux-gnu && \
    ldd /usr/bin/tor | grep -o '/lib[^ ]*' | xargs -r -I {} cp {} /tor-libs/lib/${ARCH}-linux-gnu

# Add Tor data/log dirs and set numeric ownership so it is preserved when copied to the final nonroot image
RUN mkdir -p /var/lib/tor /var/log/tor && \
    chown -R 65532:65532 /var/lib/tor /var/log/tor

# Copy Tor binary and necessary libraries to distroless
FROM gcr.io/distroless/base-debian12:nonroot
COPY --from=builder /tor-libs/lib /lib/
COPY --from=builder /usr/bin/tor /usr/bin/tor

# copy the prepared data/log dirs
COPY --from=builder --chown=65532:65532 --chmod=700 /var/lib/tor /var/lib/tor
COPY --from=builder --chown=65532:65532 --chmod=700 /var/log/tor /var/log/tor

# expose those paths as volumes by default
VOLUME ["/var/lib/tor", "/var/log/tor"]

# Run Tor with the specified configuration file
ENTRYPOINT ["/usr/bin/tor", "-f", "/etc/tor/torrc"]