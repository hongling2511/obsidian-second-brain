# Multi-Account Network Isolation and Residential IP Management Study Guide

This study guide provides a comprehensive overview of using OpenWrt-based soft routers to manage multiple cross-border e-commerce accounts, specifically for platforms like TikTok. It details the technical configurations required to isolate devices through independent WiFi signals or specific IP assignments while utilizing residential IP nodes and chain proxying for enhanced security and performance.

---

## 1. Core Concepts and Objectives

### The Purpose of Network Isolation
In cross-border e-commerce, operating multiple accounts on a single device or the same IP address often leads to "account association," which can result in bans or restricted reach. The primary objective is to ensure that each account operates on a unique device with a unique residential IP address.

### The Advantage of Soft Routers
While individual devices can run proxy software, centralized management on a router offers several benefits:
*   **Reduced Detection:** Because proxy tools are not running directly on the mobile device, the "camouflage" or stealth of the connection is improved.
*   **Simplified Management:** Nodes are configured once on the router rather than on every individual phone.
*   **Hardware Isolation:** One router can simulate multiple independent network environments.

---

## 2. Implementation Strategies

### Method 1: One WiFi Per Node IP
This method requires a soft router capable of transmitting WiFi signals (often a hardware router flashed with OpenWrt).

1.  **WiFi Creation:** Create multiple SSIDs (e.g., `tk01`, `tk02`). Each physical band (2.4GHz and 5GHz) can typically support up to 16 SSIDs, allowing for a total of 32 unique WiFi networks on supported hardware like the Redmi AX6000.
2.  **Interface Configuration:** Each WiFi SSID must be assigned to its own network interface with a unique static internal IP segment (e.g., `192.168.11.1` for `tk01` and `192.168.12.1` for `tk02`).
3.  **DHCP Setup:** Enable DHCP for each interface so devices connecting to a specific WiFi are automatically assigned an IP within that specific segment.
4.  **SSID Management:** To avoid attracting unwanted attention or "neighborhood suspicion," SSIDs can be hidden, requiring manual connection on the device.

### Method 2: Device-Specific IP Mapping (Single WiFi)
This is the recommended method for setups where the soft router does not have a wireless card or is connected to a separate Access Point (AP).

1.  **Unified WiFi:** All devices connect to the same WiFi signal provided by an AP.
2.  **Static IP Binding:** Although modern devices use virtual MAC addresses, they generally maintain a consistent IP within the same network. For absolute stability, these IPs can be bound as "Static" within the router's configuration.
3.  **Rule-Based Routing:** Instead of segregating by WiFi segment, the router identifies the device by its specific internal IP (e.g., `192.168.2.235`) and routes its traffic through a designated proxy node.

---

## 3. Proxy and Node Configuration

### Residential IP Integration
True residential IPs (such as those provided by providers like ATT) are essential for platform trust. These are typically added to the router via SOCKS5 or VPS links. 

### Chain Proxying (Forward Proxy)
Directly connecting to residential IPs via SOCKS5 or SS can be unstable or "dangerous" in certain network environments. Chain proxying solves this:
*   **Front-end Proxy:** A stable "airport" node or a high-speed VPS node is used as the entry point.
*   **Residential Exit:** The residential IP node is "pulled" or bridged through the front-end proxy.
*   **Regional Alignment:** It is recommended that the front-end proxy be located in the same geographic region as the residential IP for optimal performance.

### Passwall Rule Management
Using tools like Passwall, traffic is directed based on "Rule Management":
*   **Source IP Matching:** Rules are created to match either a network segment (Method 1) or a specific device IP (Method 2).
*   **Traffic Shunting:** A "Shunting" node is created where specific rules are mapped to specific residential nodes, ensuring that Traffic A always uses Residential IP A, while Traffic B uses Residential IP B.

---

## 4. Short-Answer Practice Questions

**Q1: Why is it preferable to run proxy tools on a router rather than on the mobile device itself?**
**A:** Running proxies on the router improves "camouflage" because the mobile device does not show active proxy software, which can be detected by some platforms. It also centralizes management, removing the need to configure every device individually.

**Q2: What is the maximum number of WiFi SSIDs supported by the hardware mentioned in the source (Redmi AX6000)?**
**A:** The device supports a total of 32 WiFi SSIDs (16 on the 2.4GHz band and 16 on the 5GHz band).

**Q3: In Method 1, why is it necessary to assign different internal IP segments (e.g., 192.168.11.x vs 192.168.12.x) to different WiFi SSIDs?**
**A:** Different segments allow the router to distinguish which WiFi a device is connected to, making it possible to apply specific proxy rules to all traffic coming from that specific segment.

**Q4: What should an iOS 18 user do regarding their "Private Wi-Fi Address" settings to ensure stable routing?**
**A:** They should disable "Rotating" for the private address and set it to "Fixed" or "Off" to prevent the MAC address from changing, which could lead to the device receiving a different IP and breaking the proxy rules.

**Q5: What is the primary function of a "Chain Proxy" (Front-end Proxy) in this context?**
**A:** It acts as a stable bridge to "pull" or accelerate the residential IP node, preventing the connection issues that arise from trying to connect directly to residential SOCKS5 or SS nodes.

---

## 5. Essay Prompts for Deeper Exploration

1.  **The Evolution of Anti-Association Techniques:** Analyze how the shift from device-side proxying to router-side network segmentation enhances the security of cross-border e-commerce operations. Discuss the technical trade-offs between WiFi-based isolation and IP-based isolation.
2.  **Network Architecture and Stealth:** Evaluate the role of "Chain Proxying" in maintaining account health. Why might a direct connection to a residential IP be flagged, and how does the use of a front-end node mitigate these risks?
3.  **Infrastructure Scaling for E-commerce:** Discuss the limitations of consumer-grade hardware (like the Redmi AX6000) in a professional multi-account environment. Consider factors such as CPU load, bandwidth distribution, and the maximum limit of 32 SSIDs.

---

## 6. Glossary of Key Terms

| Term | Definition |
| :--- | :--- |
| **Soft Router** | A computer or specialized hardware running a general-purpose operating system (like OpenWrt) configured to act as a router. |
| **OpenWrt** | An open-source project for embedded operating systems based on Linux, primarily used on routers to provide advanced networking features. |
| **Anti-association** | Techniques used to prevent online platforms from linking multiple accounts to a single user or entity. |
| **Residential IP** | An IP address assigned by an Internet Service Provider (ISP) to a homeowner, seen as more trustworthy by platforms than data center IPs. |
| **SSID** | Service Set Identifier; the public name of a wireless local area network (WiFi). |
| **Chain Proxy** | A configuration where traffic passes through a "front-end" node before reaching the final "exit" node (the residential IP). |
| **Passwall** | A popular proxy plugin for OpenWrt used to manage nodes, subscriptions, and complex routing rules. |
| **Static IP Binding** | A router configuration that ensures a specific hardware device (identified by its MAC address) always receives the same internal IP address. |
| **Dual ISP IP** | A type of residential IP that is identified by platforms as a standard home connection rather than a commercial or proxy service. |