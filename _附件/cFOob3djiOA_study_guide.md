# Comprehensive Study Guide: Side Router Architectures and Configuration

This study guide explores the technical implementation, benefits, and challenges of "Side Router" (旁路由) setups within home networks. It covers the fundamental mechanics of transparent gateways, traffic diversion strategies, and the technical controversies surrounding these configurations.

---

## 1. Core Concepts and Overview

### What is a Side Router?
A side router is an additional routing device (often a soft router running OpenWrt) connected to the LAN port of a main router. Unlike a traditional secondary router, it does not create a new sub-network. Instead, it sits "beside" the main router to handle specific tasks—such as encrypted proxying or "scientific internet access"—while the main router continues to handle the primary internet connection (PPPoE) and basic network stability.

### Problems Solved by Side Routers
*   **Network Stability:** If the soft router crashes or requires plugin updates, the main router continues to function, ensuring the entire household does not lose internet access.
*   **Structural Simplicity:** It does not require changing the physical wiring or the primary role of the main router.
*   **Device-Specific Diversion:** It allows users to choose which devices (e.g., a computer) use the proxy service and which devices (e.g., a parent's phone) bypass it to access the internet directly.

---

## 2. Configuration Workflow

The following table outlines the standard procedure for setting up an OpenWrt device as a side router:

| Step | Action | Description |
| :--- | :--- | :--- |
| **1** | **Identify Subnet** | Determine the main router's IP and subnet (e.g., `192.168.2.1`). |
| **2** | **Physical Connection** | Connect the soft router's LAN port to the computer to access the management interface. |
| **3** | **Interface Setup** | Delete the WAN interface; edit the LAN interface to use a **Static IP** within the main router's subnet (e.g., `192.168.2.2`). |
| **4** | **Gateway/DNS** | Set the side router's Gateway and DNS to the main router's IP (`192.168.2.1`). |
| **5** | **Physical Bridge** | Bind all physical ports to the `br-lan` bridge to allow them to act as a switch. |
| **6** | **DHCP Management** | Disable DHCP on the main router and enable it on the side router to control network-wide traffic. |

---

## 3. Advanced Traffic Diversion: DHCP Tagging

To achieve selective traffic routing without manually changing settings on every device, users can leverage `dnsmasq` configurations within OpenWrt to assign different gateways based on device tags.

### Tagging Logic
By using MAC address binding and DHCP options, the side router can "tell" specific devices which gateway to use:
*   **Option 3:** Sets the Default Gateway.
*   **Option 6:** Sets the DNS Server.

### Example Scenarios
1.  **Small Group Bypass:** Set a `Direct` tag for specific MAC addresses. Configure DHCP options to give these tagged devices the main router's IP as their gateway/DNS.
2.  **Small Group Proxy:** Set a `Proxy` tag for specific devices. Use the conditional `tag:!proxy` to ensure every device *except* the tagged ones receives the main router's gateway, while the tagged device receives the side router's gateway.

---

## 4. Technical Challenges and Controversies

### Asymmetric Routing
Asymmetric routing occurs when data packets leave the network through one path (PC → Side Router → Main Router → Internet) but return through another (Internet → Main Router → PC). 
*   **The Issue:** The side router remembers the outgoing request but never sees the "handshake" return packet because the main router sends it directly to the PC.
*   **The Consequence:** The side router may flag subsequent outgoing packets from the PC as "invalid" and drop them if the firewall is set to "Discard Invalid Packets."
*   **The Fix:** Disable "Discard Invalid Packets" or enable **IP Dynamic Masquerade** (SNAT) on the side router.

### The WiFi/NAT Issue
On some routers, WiFi data is processed by the CPU and filtered through `iptables`. Because the side router forwards packets without changing the source IP, the main router might see the same packet twice (once from the PC, once from the side router) and fail to perform NAT correctly. Enabling **IP Dynamic Masquerade** on the side router forces the traffic to appear as if it is coming from the side router itself, resolving the NAT conflict but slightly impacting performance.

### IPv6 Bypassing
IPv6 often bypasses side router configurations because its gateway is not typically assigned via standard DHCP. If a device receives an IPv6 address, it may prioritize the main router’s IPv6 gateway, effectively rendering the side router's proxy services useless for that traffic.

---

## 5. Short-Answer Practice Questions

1.  **Why is the "Side Router" terminology controversial?**
    It is technically a "Gateway Mode" or "Transparent Gateway" rather than a traditional router. Many users in technical circles find the term inaccurate as the device functions as a gateway within a single subnet.

2.  **What is the function of "IP Dynamic Masquerade" in a side router setup?**
    It performs NAT, replacing the original device's internal IP with the side router's IP. This ensures traffic remains "symmetric" and prevents the main router from discarding packets due to internal IP conflicts or filtering.

3.  **How does a side router handle domestic vs. international traffic?**
    The side router uses proxy tools and diversion rules. If a destination IP is domestic, the side router forwards it directly to the main router. If international, it encrypts the data before forwarding it to the node via the main router.

4.  **What happens if you have two DHCP servers active in the same local network?**
    It causes a conflict. Devices may randomly receive IP and gateway information from either server, leading to inconsistent network behavior and potential connectivity loss.

---

## 6. Essay Prompts for Deeper Exploration

1.  **The Trade-off of Transparency:** Analyze the benefits of using a side router for network "non-intrusiveness" versus the performance and complexity costs of managing asymmetric routing and double NAT.
2.  **The Evolution of the "Gateway":** Explore how devices like Android phones, Mac Minis, and Apple TVs can be repurposed as side gateways. What does this suggest about the future of specialized networking hardware?
3.  **The IPv6 Conflict:** Discuss why IPv6 represents a significant hurdle for side router configurations and evaluate the recommendation to disable IPv6 for users who do not specifically require it for public network access.

---

## 7. Glossary of Terms

| Term | Definition |
| :--- | :--- |
| **Main Router** | The primary device connected to the ISP (Optical Modem) that handles PPPoE dialing and NAT. |
| **Soft Router** | A computer or specialized hardware running a router OS (like OpenWrt) instead of proprietary firmware. |
| **Transparent Gateway** | A network node that forwards traffic to another network without requiring configuration on the client device. |
| **Asymmetric Routing** | A situation where the path taken by a packet from Source to Destination differs from the path taken from Destination to Source. |
| **IP Forwarding** | The ability of an operating system or device to accept incoming network packets and forward them to another network. |
| **Static IP Binding** | Mapping a specific MAC address to a permanent IP address within the DHCP server. |
| **NAT (Network Address Translation)** | The process of remapping one IP address space into another by modifying network address information in the IP header of packets. |
| **PPPoE** | Point-to-Point Protocol over Ethernet; the standard method for connecting to an ISP to receive a public IP. |