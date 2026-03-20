# Comprehensive Study Guide: Network Proxy Modes and Architectures

This study guide explores the technical foundations of network communication, the mechanisms of various proxy modes—including System Proxy, TUN/TAP, and True VPNs—and how these technologies manage system-wide data traffic.

---

## 1. Fundamentals of Network Communication

### The Standard Communication Flow
In a typical home network without a proxy, data travels through a series of encapsulations and decapsulations across the TCP/IP four-layer model:

1.  **Application Layer:** A browser generates a request (e.g., for Baidu) and encapsulates it into an HTTP packet.
2.  **Transport Layer (TCP):** The system adds source and target ports. The target port for web traffic is typically 80 or 443.
3.  **Network Layer (IP):** The system adds the source IP (local/internal IP) and the target IP (server IP).
4.  **Interface Layer:** The system adds MAC addresses and sends the data through the physical network cable to the default gateway (the router).

### The Role of the Router and NAT
*   **PPPoE:** The router connects to the ISP via PPPoE to obtain a public IP address (e.g., 2.2.2.2).
*   **DHCP:** The router assigns internal IPs (e.g., 192.168.0.x) to local devices and identifies itself as the default gateway and DNS server.
*   **NAT (Network Address Translation):** The router replaces the internal source IP of an outgoing packet with its public IP. When receiving data, it reverses the process to ensure the data reaches the correct internal device.

---

## 2. Proxy Modes and Mechanisms

### System Proxy (HTTP/SOCKS)
This is the most common mode for desktop users of clients like Clash or V2Ray.
*   **Mechanism:** The software sets a system-level configuration that tells compliant applications to send their requests to a local port (SOCKS or HTTP) managed by the proxy client.
*   **Traffic Flow:** The browser sends data to the proxy client. The client checks "split-tunneling" (分流) rules. If the destination requires a proxy, the client encrypts and encapsulates the data (using protocols like SS) before sending it through the standard network stack to the proxy server.
*   **Limitations:**
    *   **Developer Dependence:** It only works if the software is programmed to follow system proxy settings. Many applications and games ignore these settings.
    *   **Protocol Support:** HTTP/SOCKS proxies often do not support UDP traffic, making them unsuitable for most gaming.

### TUN/TAP Mode (Virtual Network Interface)
TUN/TAP captures traffic at the Network Layer by creating a virtual network card. This is the default mode for mobile devices and is highly effective for global traffic hijacking.
*   **TUN vs. TAP:** TUN operates at the Network Layer (IP), while TAP operates at the Data Link Layer (Ethernet/MAC). TUN is generally recommended as MAC addresses are unnecessary for most proxy tasks.
*   **Routing Table Manipulation:** When TUN is enabled, the proxy client modifies the system routing table (viewable via `route print` on Windows). It inserts high-priority routes that cover all IP ranges, directing traffic to the virtual network card instead of the physical one.
*   **Execution:** Because all internet traffic must pass through the Network Layer, the virtual card intercepts 100% of the data, regardless of whether the software "supports" proxies.

### Transparent Proxy
A transparent proxy is achieved by moving the TUN/TAP logic from the local device to the router (often a "soft router" or a device running Clash/sing-box).
*   **Benefit:** The process is completely transparent to the end device. Software and games cannot detect that a proxy is being used because no virtual network cards or proxy settings are active on the local machine; the gateway simply handles the encryption.

### True VPN
A "True VPN" is defined by its ability to encapsulate Network Layer data to create a Virtual Private Network.
*   **Core Purpose:** Its primary goal is to allow a remote device to behave as if it is on the same local network as a distant router, enabling internal network access and "Intranet Penetration."
*   **Technical Distinction:** Unlike SS or VMess (which are primarily for bypassing censorship), True VPN protocols (like WireGuard or OpenVPN) can encapsulate ICMP protocols. This allows tools like `ping` to return real latency and genuine IPs, whereas TUN proxies often return "fake" 1ms latencies for proxied addresses.
*   **Censorship Bypassing:** While VPNs provide encryption, they are not specifically designed to hide traffic characteristics. Their traffic patterns are often easily identified compared to dedicated proxy protocols.

---

## 3. Short-Answer Practice Questions

1.  **Why do some applications work with a proxy while others (like games) do not when using "System Proxy" mode?**
    *   *Answer:* System Proxy depends on the application developer to respect system-wide settings. Many apps ignore these settings. Additionally, system proxies (HTTP/SOCKS) often lack UDP support, which is required for games.

2.  **How does TUN mode ensure that all system traffic is captured?**
    *   *Answer:* It creates a virtual network card and modifies the system's routing table to ensure that all IP-bound traffic is directed to that virtual interface instead of the physical one.

3.  **What is the difference between the "gVisor" and "System" stacks in Clash TUN settings?**
    *   *Answer:* `gVisor` is a user-space implementation that offers better performance by resolving data more efficiently. `System` uses the operating system's own stack, which is more stable but may involve more data copying.

4.  **Why might a user prefer a "Transparent Proxy" on a router over a local TUN client?**
    *   *Answer:* It makes the proxy invisible to the local device, preventing anti-cheat systems or strict software from detecting the presence of a virtual network card or proxy tool.

5.  **What is the technical requirement for a protocol to be considered a "True VPN"?**
    *   *Answer:* It must be able to encapsulate Network Layer (Layer 3) data packets to facilitate "site-to-site" networking or internal network access.

---

## 4. Essay Prompts for Deeper Exploration

1.  **The Evolution of Proxy Technology:** Compare the architectural differences between System Proxies and TUN-based proxies. Analyze why the industry has shifted toward virtual network interfaces for mobile and global traffic management.
2.  **The Misnomer of "VPN":** In the context of the source, explain why tools like Shadowsocks (SS) or VMess are technically distinct from "True VPNs" and evaluate the pros and cons of using a True VPN for the specific purpose of bypassing network restrictions.
3.  **Encapsulation and Decapsulation:** Detail the journey of a data packet from a browser to a remote server when using a TUN-mode proxy. Include the roles of the virtual network card, the proxy client, the routing table, and the physical router.

---

## 5. Glossary of Important Terms

| Term | Definition |
| :--- | :--- |
| **NAT (Network Address Translation)** | The process of mapping internal (private) IP addresses to a single public IP address on a router. |
| **Encapsulation** | The process of wrapping data in protocol headers (HTTP, TCP, IP) as it moves down the network stack. |
| **Decapsulation** | The process of removing protocol headers to retrieve the original data as it moves up the network stack. |
| **TUN (Network Tunnel)** | A virtual network interface that operates at the Network Layer (IP packets). |
| **TAP (Network Tap)** | A virtual network interface that operates at the Data Link Layer (Ethernet frames). |
| **ICMP** | The protocol used by network tools like `ping` to test connectivity and latency; typically not supported by standard SOCKS proxies. |
| **PPPoE** | A protocol used by many ISPs to allow routers to establish a connection and receive a public IP. |
| **Split-tunneling (分流)** | The logic used by proxy clients to decide which traffic stays local (Direct) and which traffic is sent through a proxy server. |
| **User-space Stack (gVisor)** | A method of processing network data within the application itself rather than relying on the operating system's kernel, often used to improve proxy performance. |