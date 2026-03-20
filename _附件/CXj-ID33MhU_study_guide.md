# Hysteria 2 Protocol: Architecture, Implementation, and Performance Optimization

This study guide provides a comprehensive overview of Hysteria 2, a high-performance proxy protocol designed to optimize network speeds on sub-optimal VPS lines. It covers the technical transition from TCP to UDP-based protocols, the mechanics of bandwidth negotiation, and the practical implementation of the protocol across various platforms.

## Key Concepts and Technical Foundations

### The Evolution of Hysteria
Hysteria is a low-level encrypted proxy protocol based on UDP. The second generation, Hysteria 2, introduces significant improvements over its predecessor, including enhanced performance, better stability, reverse proxy camouflage, and increased anti-censorship capabilities. Notably, Hysteria 2 is completely incompatible with Hysteria 1 due to extensive architectural changes.

### TCP vs. UDP and Congestion Control
*   **TCP (Transmission Control Protocol):** Traditionally used by HTTP and many proxy protocols (like SS and V2Ray). It is a connection-oriented, reliable protocol. However, its congestion control algorithms (such as BBR or Cubic) automatically reduce transmission speeds when packet loss occurs to alleviate network congestion. Improving TCP performance typically requires complex kernel-level modifications.
*   **UDP (User Datagram Protocol):** A simpler design without native congestion control or reliable transmission. It is easier to promote and implement because it does not require operating system kernel changes.
*   **QUIC and HTTP/3:** Modern internet standards are shifting toward HTTP/3, which utilizes the QUIC protocol built on top of UDP. QUIC implements reliable transmission and congestion control (BBR/Cubic) at the application layer.

### The "Brutal" Congestion Control Algorithm
Hysteria 2’s primary speed advantage stems from its modification of the QUIC congestion control algorithm, known as "Brutal." While standard algorithms proactively slow down during congestion, the Brutal algorithm maintains a fixed transmission rate based on user-defined parameters in the configuration file. This allows the protocol to "claim" more bandwidth in high-loss environments where other users' protocols are backing off.

## Implementation and Configuration

### Server-Side Setup
Deployment typically involves a Linux VPS (e.g., Ubuntu 22.04) using an official installation script. Key configuration elements include:
*   **Port:** Defaulted to 443.
*   **Authentication:** A password-based system.
*   **Certificates:** Can use either self-signed certificates or CA-issued certificates. CA certificates require an associated domain name and the opening of TCP ports 80 and 443 for the ACME challenge.
*   **Camouflage:** A masquerade URL (e.g., bing.com) is used to hide the proxy's nature. Note that camouflage is based on UDP (HTTP/3), meaning it may not be immediately visible via standard TCP-based browser requests without specific tools.

### Client-Side Platforms
*   **Windows:** Utilizes a combination of the `v2rayN` client and the Hysteria 2 core.
*   **Mobile (Android/iOS):** Currently requires `sing-box` (version 1.5 or higher). iOS users may need to use the TestFlight version if the official App Store version does not yet support Hysteria 2.

### Bandwidth Negotiation Logic
The protocol uses a "minimum value" negotiation rule to determine transmission speeds:

| Direction | Comparison Logic | Result |
| :--- | :--- | :--- |
| **Client Download** | Client Download vs. Server Upload | The smaller value is used. |
| **Client Upload** | Client Upload vs. Server Download | The smaller value is used. |

If the server does not set a bandwidth limit, the client's settings prevail. If the client does not set a rate, the system defaults to the traditional BBR congestion control algorithm.

---

## Short-Answer Practice Questions

**1. What is the fundamental difference between Hysteria 2 and Hysteria 1?**
Hysteria 2 is a major update that improves performance, stability, and anti-censorship capabilities, but it is entirely incompatible with the first generation.

**2. Why does Hysteria 2 perform better than TCP-based protocols on high-latency or high-loss lines?**
Hysteria 2 uses the Brutal algorithm, which maintains a fixed sending rate regardless of network congestion, whereas TCP protocols (like SS or V2Ray) automatically reduce their speed when they detect packet loss.

**3. What protocol serves as the basis for Hysteria 2's transport layer?**
Hysteria 2 is based on UDP and modifies the QUIC protocol.

**4. In the context of bandwidth configuration, what happens if the server setting is "10 Mbps" and the client setting is "100 Mbps"?**
The connection will operate at 10 Mbps because the protocol follows the "smaller value wins" principle.

**5. How can a user enable traditional BBR congestion control in Hysteria 2 instead of the Brutal algorithm?**
A user can set the upload and download bandwidth values to zero in the configuration file, or the server administrator can use the `ignore_client_bandwidth` parameter to force BBR.

**6. Which ports must be open on a firewall for the ACME protocol to successfully apply for a CA certificate?**
TCP ports 80 and 443 must be open.

---

## Essay Prompts for Deeper Exploration

1.  **The Ethics of Aggressive Congestion Control:** Discuss the controversy surrounding Hysteria 2's "Brutal" algorithm. Is it "immoral" to ignore network congestion to maintain personal speeds, or is this behavior a justified response to poor service from internet service providers?
2.  **The Shift to UDP-Based Infrastructure:** Analyze why modern protocols like QUIC and Hysteria are moving away from TCP. What are the advantages of implementing reliability and congestion control at the application layer rather than the kernel layer?
3.  **Camouflage and Censorship Resistance:** Explain the mechanism of Hysteria 2’s reverse proxy camouflage. Why might a standard web browser fail to see the camouflage site initially, and how does this contribute to evading detection?

---

## Glossary of Important Terms

*   **ACL (Access Control List):** A mechanism used for advanced routing, such as directing specific traffic to secondary proxies to unlock region-restricted content like Netflix.
*   **BBR (Bottleneck Bandwidth and Round-trip propagation time):** A traditional TCP congestion control algorithm that aims to maximize throughput by responding to network congestion.
*   **Brutal Algorithm:** The specific congestion control modification used by Hysteria that forces data transmission at a fixed, user-defined rate regardless of packet loss.
*   **Insecure Mode:** A configuration setting (often set to `true` when using self-signed certificates) that allows the client to skip strict certificate validation.
*   **Port Hopping:** A future feature (planned for version 2.1) designed to mitigate ISP-imposed rate limiting on specific ports.
*   **QUIC:** A multiplexed, transport-layer network protocol designed by Google that provides security equivalent to TLS/SSL while reducing connection and transport latency.
*   **Sing-box:** A universal proxy platform and the primary client software for using Hysteria 2 on mobile operating systems (Android and iOS).
*   **TUN Mode:** A network layer proxy mode that allows all system traffic to be routed through the proxy, often requiring administrator privileges.