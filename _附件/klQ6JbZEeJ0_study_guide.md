# IPv6 Configuration and Proxy Integration Study Guide

This study guide provides a comprehensive overview of IPv6 implementation within OpenWrt environments, specifically focusing on its interaction with proxy tools like HomeProxy (Sing-box) and OpenClash (Mihomo). It outlines configuration scenarios, technical workflows, and troubleshooting strategies for maintaining a stable network environment.

---

## 1. Core Concepts and Technical Workflow

### IPv6 Address Generation and SLAAC
IPv6 addresses are 128 bits long. In a typical configuration, the first 64 bits represent the **Prefix** (provided by the ISP), and the last 64 bits are the **Interface Identifier** (suffix). 

*   **Stateless Address Autoconfiguration (SLAAC):** A mechanism where a device generates its own IPv6 address using a prefix received from a router. 
*   **A-Flag (Autonomous):** Within a Router Advertisement (RA) packet, if the A-flag is set to 1, the client device will use the provided prefix to generate an IPv6 address.
*   **EUI-64:** A method of generating the 64-bit suffix using the device's MAC address. Because MAC addresses are 48 bits, the sequence `ff:fe` is inserted in the middle.
*   **Privacy Extensions:** Modern operating systems often ignore EUI-64 to prevent tracking. Instead, they generate **Random Suffixes** and **Temporary Addresses** for outbound traffic to enhance privacy.

### The Address Lifecycle
IPv6 addresses transition through various states based on timers included in the RA data:
1.  **Tentative:** The initial state during **Duplicate Address Detection (DAD)**, where the device checks if the IP is already in use.
2.  **Preferred:** The state where the address can normally send and receive data.
3.  **Deprecated:** Occurs when the **Preferred Lifetime (PLT)** expires. The address can maintain existing connections but cannot initiate new ones.
4.  **Invalid:** Occurs when the **Valid Lifetime (VLT)** expires. The address is removed from the interface.

### DNS in IPv6 Environments
A common misconception is that an IPv6 DNS server is required to resolve IPv6 addresses (AAAA records). In reality:
*   IPv4 DNS servers can return IPv6 addresses.
*   IPv6 DNS servers can return IPv4 addresses.
*   Disabling IPv6 DNS servers in a proxy environment is often recommended to prevent **DNS Pollution** and **DNS Leaks**, as many proxy plugins struggle to hijack IPv6 DNS traffic correctly.

---

## 2. OpenWrt Configuration Scenarios

The following table summarizes the primary methods for configuring IPv6 based on the home network environment:

| Scenario | Connection Type | Recommended Configuration | Key Action |
| :--- | :--- | :--- | :--- |
| **Bridge Mode** | Optical modem is a bridge; OpenWrt performs PPPoE dialing. | **Prefix Delegation (PD)** | Ensure the WAN6 interface receives a prefix (e.g., /60 or /64). |
| **Router Mode (with PD)** | Optical modem is a router; OpenWrt is secondary. | **DHCPv6 Client** | Create a WAN6 interface using the DHCPv6 client protocol to request PD from the modem. |
| **Router Mode (no PD)** | Optical modem does not pass Prefix Delegation. | **Relay Mode** | Set RA, DHCPv6, and NDP to "Relay" on both WAN and LAN interfaces. |
| **Extreme/Campus** | WAN only receives a single /128 address. | **NAT66** | Set a Unique Local Address (ULA) prefix and enable IPv6 Masquerading in the firewall. |

---

## 3. Proxy Integration (HomeProxy & OpenClash)

### HomeProxy (Sing-box) Implementation
HomeProxy utilizes different DNS strategies that affect how IPv6 is handled:
*   **IPv4 Only Strategy:** The plugin intercepts DNS requests and only returns IPv4 addresses, forcing the device to use IPv4 even if IPv6 is available.
*   **Default Strategy:** Returns both IPv4 and IPv6 addresses. Devices usually prioritize IPv6.
*   **Traffic Hijacking:** If IPv6 support is enabled in the plugin, IPv6 traffic is intercepted by the core (Sing-box) and filtered according to routing rules (Direct or Proxy). If disabled, IPv6 traffic bypasses the proxy entirely.

### OpenClash (Fake-IP) Implementation
OpenClash typically operates in **Fake-IP** mode:
*   The device receives a Fake-IP (IPv4) from OpenClash.
*   The proxy core resolves the actual destination (which could be an IPv6 address) and handles the connection.
*   This creates a "NAT-like" effect where the target website sees the router's IPv6 address rather than the client device's address.

---

## 4. Short-Answer Practice Questions

1.  **Why is it often recommended to remove the ULA (Unique Local Address) prefix in a standard IPv6 setup?**
    *   *Answer:* Removing the ULA prefix helps avoid routing conflicts and ensures the system prioritizes public IPv6 addresses for global connectivity.
2.  **What is the purpose of Duplicate Address Detection (DAD)?**
    *   *Answer:* DAD involves sending a multicast packet to the local network to ensure no other device is using the same IPv6 address before it is assigned to an interface.
3.  **In the context of EUI-64, why is it considered a privacy risk?**
    *   *Answer:* Because EUI-64 uses the device's unique physical MAC address to generate the IP suffix, the device can be tracked across different networks by its consistent IPv6 suffix.
4.  **What happens to an IPv6 address when its Preferred Lifetime (PLT) reaches zero?**
    *   *Answer:* The address enters a "Deprecated" state; it can no longer be used to initiate new connection requests but can continue to support active ones until the Valid Lifetime expires.
5.  **How can a user resolve IPv6 addresses for websites if they have disabled IPv6 DNS servers on their router?**
    *   *Answer:* The user can use IPv4 DNS servers, which are fully capable of resolving AAAA (IPv6) records.

---

## 5. Essay Prompts for Deeper Exploration

1.  **The "Chemical Reaction" of IPv6 and Proxies:** Explain why enabling IPv6 in a poorly configured proxy environment often leads to DNS leaks and routing failures. Discuss the specific role of DNS hijacking in this conflict.
2.  **Comparison of NAT66 vs. Prefix Delegation:** Contrast the technical implementation and the philosophical differences between using NAT66 (similar to IPv4 NAT) and Prefix Delegation (end-to-end connectivity) in a modern home network.
3.  **The Role of RA and RS in Network Discovery:** Describe the handshake process between a client device and a router using Router Solicitation (RS) and Router Advertisement (RA) packets. How do the flags within these packets dictate client behavior?

---

## 6. Glossary of Important Terms

*   **DHCPv6:** A network protocol for configuring IPv6 hosts with IP addresses and other configuration data. It can be "stateful" (assigning IPs) or "stateless" (assigning only DNS/info).
*   **Fake-IP:** A technique used by proxies where the DNS server returns a temporary, fake IPv4 address to the client, allowing the proxy core to handle the actual resolution and routing.
*   **Link-Local Address:** An IPv6 address (typically starting with `fe80::`) used for communication within a single local network segment; it is not routable on the public internet.
*   **Masquerading (IPv6):** A firewall function (NAT) that allows multiple devices on a local network to share the single IPv6 address of the router's WAN interface.
*   **NDP (Neighbor Discovery Protocol):** Used by IPv6 to determine the link-layer addresses of neighbors on the same link and to find neighboring routers.
*   **PD (Prefix Delegation):** A mechanism where an ISP delegates a short IPv6 prefix to a customer's router, which then sub-divides that prefix for use on internal LAN segments.
*   **ULA (Unique Local Address):** IPv6 addresses intended for local use (starting with `fc00::` or `fd00::`), analogous to private IPv4 ranges like `192.168.x.x`.