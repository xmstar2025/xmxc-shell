# HY2 with a trusted IP certificate

Run `bash network/hy2/install.sh PUBLIC_IPV4 [PORT] [ACME_EMAIL]` from a GitHub
checkout under `/home/work/`, as root with uv installed. TCP/80 must be reachable
and free for the standalone ACME challenge, including future renewals. The
installer supports Rocky Linux x86_64, pins the same sing-box 1.13.11 build as
ds02 and verifies the release SHA-256. Python dependencies use uv.lock.

The server exposes authenticated HY2 on UDP/29885 by default, with 1000 Mbps
upload/download settings. Existing TCP congestion control is preserved.
This configured bandwidth is not a measured throughput guarantee.

Certificates are issued directly for the IP by Let's Encrypt using its
`shortlived` profile. No domain or insecure TLS option is needed. Certbot 5.10.0
checks renewal every six hours and restarts only this HY2 service after a
successful renewal. Changing the public IP requires running installation for
the new IP. Existing passwords are retained when installation is rerun.

Services: `xmxc-hy2.service`, `xmxc-hy2-cert-renew.service`, and
`xmxc-hy2-cert-renew.timer`. Runtime files are under `/home/work/xmxc-hy2/`;
secrets and certificates are under `/etc/xmxc-hy2/`, accessible only to root.
Client URI, sing-box JSON, and Mihomo JSON are generated there and must not be
committed to Git or published in a public subscription.

Verify with `systemctl status xmxc-hy2.service xmxc-hy2-cert-renew.timer`,
`ss -lunp`, and an external HY2 client with certificate verification enabled.
Exercise renewal with the generated Certbot command plus `renew --dry-run`.
