# Comprehensive Study Guide: Mastering sing-box Network Proxy

This study guide provides an in-depth exploration of **sing-box**, a highly versatile network proxy tool described as a "Swiss Army Knife" for network traffic management. This document covers fundamental concepts, advanced configurations (specifically the transition from FakeIP to RealIP), and practical implementation strategies for various platforms.

---

## I. Core Concepts and Themes

### 1. Overview of sing-box
Sing-box is a powerful network proxy tool known for its comprehensive protocol support (exceeding the v2ray series) and rich client configuration options (surpassing the Clash series). Its primary advantages include:
*   **High Update Frequency:** It is often the first to support new proxy protocols.
*   **Cross-Platform Support:** Official graphical clients exist for Android, iOS, macOS, tvOS, and Windows (via third-party tools like v2rayN).
*   **Clash API Compatibility:** It supports Clash API, allowing users to use WebUI dashboards to switch nodes and manage traffic easily.

### 2. The Configuration Architecture
A functional sing-box configuration consists of four primary modules:
*   **DNS Module:** Manages how domain names are resolved into IP addresses. It includes servers (e.g., Google DoH) and specific resolution rules.
*   **Inbounds (Inbound Module):** Defines how traffic enters the proxy tool (e.g., via a specific port or tun interface).
*   **Outbounds (Outbound Module):** Defines where traffic goes after processing, such as direct connection, a proxy node, or a "block" action.
*   **Route (Routing Module):** The "brain" that matches incoming traffic to specific outbounds based on rules (IP, domain, or protocol).

### 3. RealIP vs. FakeIP
While sing-box supports FakeIP, the source context emphasizes the use of **RealIP** for a more natural network environment.
*   **RealIP:** The client receives the actual IP address of the destination. This avoids issues with games or specific applications that fail when encountering FakeIPs.
*   **ECS (Edns-Client-Subnet):** A critical feature in sing-box 1.9+ that allows users to send a "nearby" IP hint (e.g., a domestic IP) to a remote DNS server (like Google DoH). This ensures the DNS server returns the optimized IP for the user's actual location, solving "DNS leakage" and improving domestic site access speed.

### 4. Advanced Traffic Handling
*   **Sniffing (Traffic Sniffing):** sing-box can inspect encrypted traffic (like HTTPS) to identify the target domain name. This is essential for routing rules based on domain names even when the initial request is IP-based.
*   **Destination Address Overriding:** This involves replacing the destination IP with the "sniffed" domain name. This is vital for services like **Netflix**, where the proxy node needs the domain name to perform its own DNS unlocking.
*   **Binary Rulesets (.srs):** Unlike text-based JSON rules, binary SRS files are smaller and more efficient, saving space on devices with limited storage (like soft routers).

---

## II. Short-Answer Practice Questions

**1. Why is sing-box often preferred over other proxy tools like the v2ray or Clash series?**
*Answer:* Sing-box offers more comprehensive server-side protocol support than v2ray and more flexible client configurations than Clash. It also boasts a higher update frequency and supports the Clash API for easier node management.

**2. What is the significance of the "ECS" configuration in the DNS module?**
*Answer:* ECS (Edns-Client-Subnet) allows the user to provide a geographic IP hint to a DNS server. This ensures that even when using a foreign DNS server (like Google), the server returns the IP address of the CDN node closest to the user’s actual location, preventing slow connections to domestic websites.

**3. How does "Sniffing" assist in Netflix unlocking?**
*Answer:* Netflix unlocking often relies on DNS hijacking by the proxy provider. Sniffing identifies the domain `netflix.com` from the traffic. When "Override Destination" is enabled, sing-box sends the domain name rather than the IP to the proxy node, allowing the node to resolve the domain using its own unlocking DNS.

**4. What are the benefits of using binary (.srs) rulesets instead of JSON (.json) rulesets?**
*Answer:* Binary SRS files are significantly smaller (e.g., 32KB vs. 200KB for a China IP list). This makes them much more efficient for devices with limited memory or flash storage, such as soft routers.

**5. Why might a user choose to disable "Override Destination" for certain networks?**
*Answer:* Overriding can cause issues with specific networks, such as Tor or smart home devices. In the case of Tor, domains are often random/fake, and if sing-box overrides the IP with a fake domain, the proxy node will fail to resolve it.

**6. What is the "dead-loop" risk in DNS configuration, and how is it avoided?**
*Answer:* A dead-loop (the "chicken and egg" problem) occurs when a proxy needs to resolve its own server address but the DNS request itself is set to go through the proxy. This is avoided by creating a specific rule that directs the DNS queries for proxy server domains to a default/direct DNS server.

---

## III. Essay Prompts for Deeper Exploration

1.  **The Evolution of DNS Strategies:** Compare and contrast the mechanics, advantages, and drawbacks of **FakeIP** and **RealIP with ECS**. Discuss why a user might choose one over the other based on their specific needs (e.g., gaming, privacy, or network compatibility).
2.  **Privacy vs. Performance in DNS:** Analyze the use of **DNS-over-HTTPS (DoH)** within the sing-box environment. Discuss the trade-offs between the privacy provided by encrypted, long-connection DoH and the potential latency issues compared to traditional UDP DNS.
3.  **The Anatomy of a Proxy Request:** Trace the journey of a data packet from a local computer through a soft router running sing-box. Detail the interaction between the Inbound, Route, DNS, and Outbound modules for both a domestic website (e.g., Baidu) and an international website (e.g., Google).
4.  **Optimization for Low-Resource Hardware:** Using the context of the **HomeProxy** plugin on OpenWrt, discuss the strategies employed to make sing-box run efficiently on soft routers, including the use of binary rulesets and firewall rules to bypass domestic traffic.

---

## IV. Glossary of Important Terms

*   **sing-box:** A modern, universal proxy core and client supporting a vast array of protocols and advanced routing.
*   **HomeProxy:** A plugin for OpenWrt (soft routers) that utilizes the sing-box core for transparent proxying.
*   **RealIP:** A DNS strategy where the client receives and uses the actual destination IP address rather than a placeholder.
*   **FakeIP:** A strategy where the proxy tool provides a temporary, fake IP address to the client to capture and route traffic before the actual DNS resolution occurs.
*   **ECS (Edns-Client-Subnet):** A DNS extension that passes a portion of the client's IP address to the DNS server to facilitate more accurate, location-based results.
*   **DoH (DNS-over-HTTPS):** A protocol for performing remote DNS resolution via the HTTPS protocol to increase privacy and prevent tampering.
*   **Sniffing:** The process by which the proxy tool identifies the protocol and target domain name of an encrypted connection.
*   **SRS (Sing-box Rule Set):** A binary file format used by sing-box to store large lists of IPs or domains efficiently.
*   **Inbound/Outbound:** Inbound refers to where traffic comes from (the entrance); Outbound refers to where the traffic is sent (the exit), such as a proxy node or a direct connection.
*   **QUIC (HTTP/3):** A UDP-based protocol that can sometimes bypass domain sniffing/overriding; users may need to block it to ensure proper routing for services like ChatGPT.