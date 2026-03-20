# Understanding Network Censorship: A Study Guide to openfw and GFW Simulation

This study guide explores the technical mechanisms of the Great Firewall (GFW) through the lens of **openfw**, an open-source project designed to replicate censorship functions on home routers. By simulating SNI blocking, DNS pollution, and protocol detection, users can gain a deeper understanding of how international internet access is regulated and how various "circumvention" tools operate.

---

## 1. Technical Overview of openfw

The **openfw** project is a tool that allows users to deploy GFW-like features on personal hardware, specifically targeting routers running the OpenWrt system. Interestingly, the project was developed by the creator of **Hysteria**, a popular circumvention protocol, illustrating a "spear and shield" dynamic in network security development.

### Core Capabilities
*   **SNI Blocking:** Detecting and interrupting connections based on the Server Name Indication in HTTPS requests.
*   **DNS Pollution:** Intercepting DNS queries and returning incorrect IP addresses to prevent users from reaching specific destinations.
*   **Protocol Identification:** Detecting and blocking encrypted proxy protocols such as Shadowsocks, VMess (TCP), and Trojan.
*   **QUIC Blocking:** Filtering traffic based on the QUIC protocol, which is used by HTTP/3 and Hysteria.

---

## 2. Setup and Implementation

Deploying openfw requires a specific environment and configuration to function as a network gatekeeper.

### System Requirements and Compilation
*   **Environment:** The program is written in the **Go** language, requiring the installation of the Go environment for compilation.
*   **Cross-Compilation:** Because routers use various architectures (e.g., ARM64 for R2S), the program must be cross-compiled for the target system (e.g., `GOOS=linux`, `GOARCH=arm64`).
*   **Dependencies:** On OpenWrt, specific dependencies must be installed via the package manager (`opkg update && opkg install ...`).

### Router Configuration
To ensure openfw can intercept traffic, the following router settings are necessary:
1.  **Disable Software Flow Offloading:** This feature is incompatible with openfw's monitoring.
2.  **Enable IP Dynamic Masquerading:** Required if the device is part of a bypass routing structure.
3.  **Forward Chain Integration:** The program must be configured to work on the "Forward" chain of the firewall to monitor all data passing through the router.

---

## 3. Mechanisms of Interference

The document identifies several ways openfw (and by extension, the GFW) disrupts network traffic:

| Mechanism | Description | Example from Source |
| :--- | :--- | :--- |
| **SNI Inspection** | Analyzes the plaintext hostname in the TLS handshake. | Blocking access to "Baidu" or specific keywords like "HT" in HTTPS requests. |
| **DNS Pollution** | Modifies the response of a DNS query to an unreachable or incorrect IP. | Redirecting "Zhihu" queries to the Cloudflare IP `1.1.1.1`, causing certificate errors. |
| **Active Probing/Detection** | Identifies protocols based on data characteristics (e.g., fully encrypted data). | Blocking Shadowsocks and VMess+TCP because they appear as fully encrypted "random" data. |
| **Protocol Filtering** | Blocking entire classes of transport protocols. | Disabling HTTP/3 or Hysteria by blocking QUIC traffic. |

---

## 4. Short-Answer Practice Questions

**Q1: Why does openfw require "Software Flow Offloading" to be disabled on OpenWrt?**
*   **Answer:** Software Flow Offloading is incompatible with the way openfw intercepts and monitors network traffic; leaving it enabled prevents the program from correctly processing the data packets.

**Q2: What is the primary difference between how openfw treats Shadowsocks vs. VMess over WebSocket (WS)?**
*   **Answer:** Shadowsocks and VMess+TCP use fully encrypted data packets which openfw is designed to detect and block. VMess+WS, however, does not appear as fully encrypted "raw" data in the same way, making it harder for the current version of openfw to detect.

**Q3: How does DNS pollution manifest to an end-user in a web browser?**
*   **Answer:** The user will often see a certificate warning (e.g., "Your connection is not private") because the polluted IP leads to a server whose SSL certificate does not match the requested domain. If the IP is redirected to a service like Cloudflare, a specific error page (like Error 1016) may appear.

**Q4: Can openfw block the Hysteria protocol?**
*   **Answer:** While openfw may not have a dedicated Hysteria parser, it can block Hysteria by targeting the QUIC protocol it relies on or by blocking the specific SNI associated with the Hysteria node.

---

## 5. Essay Prompts for Deeper Exploration

1.  **The Evolution of the "Spear and Shield":** The author of openfw also created Hysteria. Discuss the implications of developers creating both the tools for censorship and the tools for circumvention. How does this "magical realism" (as described in the text) contribute to the rapid evolution of network security?
2.  **DNS Pollution and Leaks:** The source states: "As long as you encounter DNS pollution when accessing Google, it means your configuration definitely has a DNS leak." Explain the technical relationship between DNS leaks and the effectiveness of GFW-style pollution.
3.  **Limitations of Simple Firewalls:** While openfw can block standard Shadowsocks and specific SNIs, why is it described as "not yet mature"? Discuss why real-world GFW rules are more complex than the "black and white" rules used in the openfw demonstration.

---

## 6. Glossary of Important Terms

*   **GFW (Great Firewall):** The legislative and technological mechanism operated by the Chinese government to regulate the internet domestically.
*   **SNI (Server Name Indication):** An extension of the TLS protocol that indicates which hostname the client is attempting to connect to at the start of the handshaking process.
*   **DNS Pollution:** A technique used to tell a DNS server a false IP address for a domain name, effectively redirecting or blocking the user.
*   **QUIC:** A UDP-based network protocol designed by Google; it is the foundation for HTTP/3 and certain proxy protocols like Hysteria.
*   **OpenWrt:** An open-source project for embedded operating systems based on Linux, primarily used on routers to route network traffic.
*   **Cross-Compilation:** The process of creating executable code for a platform other than the one on which the compiler is running (e.g., compiling on Windows for a Linux-based router).
*   **Forward Chain:** A stage in a firewall's processing where it handles packets that are sent to the router but are destined for another device.