# Tor wrapped in Google Distroless running as non-root

```
docker pull ghcr.io/cozybear-dev/tor-relay:latest
```

By hash is also possible, you can find the hash as the short hash for each commit in the GitHub UI or as a tag at the package section.

```
docker pull ghcr.io/cozybear-dev/tor-relay:sha-71b91c5
```

To perform attestation for a given tag (requires github cli):

```
gh attestation verify oci://ghcr.io/cozybear-dev/tor-relay:latest -R cozybear-dev/tor-relay
```

It is recommended to fork this repo and always perform attestation to minimize supply chain risk. If you want to go even further, simply build locally.
