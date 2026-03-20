# Study Guide: Configuring Windows as a Bypass Gateway for Network-Wide Proxy Access

This study guide provides a comprehensive overview of the methods, configurations, and technical considerations for transforming a Windows-based computer into a bypass gateway (sidecar router). This setup allows all devices on a local area network (LAN)—including smartphones, TV boxes, and game consoles—to access restricted network environments without running individual proxy clients.

---

## 1. Key Concepts and Theoretical Framework

### Proxy Sharing vs. Gateway Sharing
The document distinguishes between different modes of sharing network access within a LAN:
*   **Proxy Sharing:** Typically used by tools like Clash or V2Ray where a port is opened to share the proxy. Devices must manually configure proxy settings (IP and Port) within specific applications.
*   **Gateway Sharing (Bypass Gateway):** The Windows PC acts as a network gateway. Other devices set the PC's IP as their "Default Gateway." All network traffic from those devices passes through the Windows PC, which then handles the routing and proxying transparently.

### IP Forwarding
A critical prerequisite for gateway sharing. By default, Windows does not forward network packets intended for other destinations. Enabling IP forwarding allows the Windows system to act as a router, receiving traffic from LAN devices and directing it toward the appropriate network interface or proxy tunnel.

### TUN Mode
A virtual network interface mode used by proxy clients (like Clash and V2RayN). TUN mode intercepts traffic at the network layer (Layer 3), allowing the software to capture and redirect all system traffic—and by extension, traffic forwarded from other devices—through the proxy tunnel.

### The Routing Loop Problem
When a device is configured as a gateway, it must distinguish between traffic that needs to go into the proxy tunnel and traffic that is the proxy tunnel's own encrypted data. If the proxy server's own IP address is routed back into the tunnel, a "routing loop" occurs, causing the proxy client to crash or the network to hang. This is managed by adding "Additional Routes" to ensure proxy server traffic bypasses the TUN interface.

---

## 2. Implementation Procedures

### Phase I: Initial Windows Configuration
To serve as a gateway, the host Windows PC must have a stable network presence:
1.  **Static IP Assignment:** The PC's IP must be fixed (e.g., `192.168.0.140`) within the router's subnet.
2.  **DNS and Gateway:** The PC's own DNS and Gateway should initially point to the main router (e.g., `192.168.0.1`).
3.  **Enable IP Forwarding:** This is achieved via a specialized routing configuration tool or command-line adjustments. A system restart may be required to activate this feature.

### Phase II: Proxy Client Configuration

The guide outlines three primary methods for handling the proxying logic:

| Method | Tool | Characteristics | Configuration Requirements |
| :--- | :--- | :--- | :--- |
| **Method 1** | **Clash** | Robust but requires manual care to avoid loops. | Must run as Administrator; TUN mode enabled; Proxy server IPs/domains added to "Additional Routes." |
| **Method 2** | **V2RayN** | Recommended; utilizes the sing-box kernel. | Must run as Administrator; TUN mode enabled; "Global" routing mode; Proxy server IPs added to "Additional Routes." |
| **Method 3** | **SSTap** | Easiest setup; legacy tool. | Uses SOCKS5 from Clash/V2Ray; does not require manual routing tables; prone to DNS pollution and speed decay. |

### Phase III: Client Device Configuration
Once the Windows PC is configured, other devices on the network must be directed to use it.

*   **Manual Configuration:** On a smartphone or another PC, change the "Gateway" in the Wi-Fi/Ethernet settings to the Windows PC’s static IP. Set DNS to a public server (e.g., `1.1.1.1`).
*   **Router-Level Configuration (DHCP):** Modify the DHCP server settings on the main router to broadcast the Windows PC’s IP as the "Default Gateway" for the entire house. 
    *   *Note:* Some routers (e.g., certain Xiaomi models) do not support custom DHCP gateway settings. In such cases, one must either use manual configuration or disable the router's DHCP and host a DHCP server elsewhere.

---

## 3. Short-Answer Practice Questions

1.  **Why is it necessary to set a static IP for the Windows computer acting as the gateway?**
    *   *Answer:* Other devices on the network identify the gateway by its IP address. If the IP changes via DHCP, the connection will be lost as the client devices will be pointing to a non-existent gateway.

2.  **What is the primary function of "Additional Routes" in this configuration?**
    *   *Answer:* They prevent routing loops by ensuring that traffic destined for the proxy server itself is routed directly through the physical network interface rather than being sucked into the virtual TUN interface.

3.  **How does the setup verify that IP forwarding is successfully enabled?**
    *   *Answer:* It can be verified through the routing configuration tool or by entering `ipconfig /all` in the command line to check if the IP routing is enabled.

4.  **What is the main disadvantage of using SSTap compared to V2RayN or Clash?**
    *   *Answer:* SSTap does not perform DNS hijacking, leading to potential DNS pollution. It also tends to experience significant speed reduction (decay) compared to the other methods.

5.  **What must be done if a proxy airport uses many different IP addresses for its nodes?**
    *   *Answer:* All unique node IP addresses or domains must be added to the "Additional Routes" list to ensure they are excluded from the TUN interface.

---

## 4. Essay Questions for Deeper Exploration

1.  **Analyze the technical challenges of using Windows as a bypass gateway compared to Linux-based solutions (like OpenWrt).**
    *   *Discussion Point:* The document notes that Windows does not natively support gateway sharing as easily as Linux. In Linux, enabling IP forwarding and a TUN interface often works "out of the box" for transparent proxying. In Windows, the user must manually manage the routing table to prevent loops and use third-party tools to facilitate packet forwarding between the physical and virtual interfaces.

2.  **Evaluate the trade-offs between manual client configuration and DHCP-level configuration for a home network.**
    *   *Discussion Point:* Manual configuration allows for granular control (only specific devices use the gateway), which is useful if the Windows PC is not always powered on. DHCP-level configuration is more "transparent" and convenient for all users but can cause a total network outage for all devices if the Windows PC goes offline or the configuration fails.

---

## 5. Glossary of Important Terms

*   **Bypass Gateway (旁路网关 / 旁路由):** A secondary gateway on a network that handles specific traffic (usually for proxying or filtering) without replacing the main router.
*   **DHCP (Dynamic Host Configuration Protocol):** A network protocol used to automatically assign IP addresses and other communication parameters (like the default gateway) to devices on a network.
*   **DNS Pollution (DNS 污染):** A situation where a DNS server returns incorrect IP addresses for a domain, often used to block access to certain websites.
*   **Global Mode (全局模式):** A setting in proxy clients where all outgoing traffic is sent through the proxy tunnel, regardless of the destination.
*   **IP Forwarding (路由转发):** The process of a computer taking a packet from one network interface and sending it out through another to reach its final destination.
*   **Routing Loop (路由环路):** An error condition where a data packet is continuously routed through the same series of nodes without ever reaching its destination.
*   **SOCKS5:** An internet protocol that exchanges network packets between a client and server through a proxy server.
*   **Transparent Proxy (透明代理):** A proxy that intercepts connection requests without requiring any special configuration on the client's web browser or applications.