# DNS Leakage and Prevention: Comprehensive Study Guide

This study guide provides an in-depth analysis of Domain Name System (DNS) leakage within proxy environments, exploring its causes, detection methods, and technical solutions for various platforms.

---

## 1. Understanding DNS Fundamentals

### The Role of DNS
DNS is a protocol designed to resolve human-readable domain names (e.g., `google.com`) into machine-readable IP addresses. Because the internet relies on IP addresses for routing, every request begins with a DNS lookup unless the IP is already cached.

### The Standard Resolution Process
1.  **Browser Cache:** The browser checks its internal list for a matching IP.
2.  **System Cache:** If not found, the operating system checks its own cache (including the `hosts` file).
3.  **Router/Gateway:** The request is sent to the local gateway (typically a home router at `192.168.0.1`).
4.  **ISP DNS:** The router queries the DNS servers provided by the Internet Service Provider (ISP).
5.  **Upstream/Authoritative Servers:** If the ISP server lacks the record, it queries upstream servers until it reaches the **Authoritative DNS Server** for that specific domain.

### Time to Live (TTL)
TTL refers to the duration a DNS record is stored in a cache. Once the TTL expires, the record is deleted, and a new DNS request must be initiated.

---

## 2. DNS Leakage: Definition and Risks

### What is a DNS Leak?
A DNS leak occurs only when using a proxy or VPN. It happens when a computer sends a **plaintext DNS request** directly to the internet instead of routing that request through the encrypted proxy tunnel. Even if the proxy is active, the local system might still resolve the domain name through the ISP's DNS servers.

### Risks Associated with Leakage
*   **Privacy Exposure:** ISPs and network firewalls can monitor plaintext DNS requests (Port 53/UDP). They will know exactly which websites (e.g., Google, Facebook, YouTube) are being accessed, even if the subsequent data traffic is encrypted.
*   **Service Restriction (Geo-fencing):** Services like Netflix are sensitive to geographic locations. If a DNS leak reveals a DNS server location that differs from the proxy server's IP location, the service may flag the user as using a VPN and block access.
*   **Node Blocking:** Frequent plaintext DNS requests followed by encrypted data bursts can serve as a "traffic feature" for firewalls to identify and block proxy nodes.

---

## 3. The Mechanism of DNS Leak Detection

Detection websites (e.g., those checking for "DNS Leak") use the following method to identify leaks:
1.  **Random Domain Generation:** The site forces the browser to request unique, randomly generated subdomains. This ensures that no DNS cache (browser, system, or ISP) contains the record.
2.  **Tracking Authoritative Queries:** Because the domain is unique, the request must travel to the website's own authoritative DNS server.
3.  **IP Mapping:** The website records the IP address of the DNS server that requested the information. If that IP belongs to a local ISP rather than the proxy provider’s infrastructure, a leak is confirmed.

---

## 4. Technical Solutions and Software Configuration

The primary way to prevent DNS leaks is to ensure the local system does not initiate DNS lookups for proxied traffic. Instead, the domain name should be sent directly to the remote proxy node to be resolved there.

### Platform-Specific Configurations

| Client | Configuration Steps |
| :--- | :--- |
| **v2rayN** | Use "Bypass Mainland" (绕过大陆) routing. In Route Settings, ensure the Domain Strategy is set to **Sniffing (S)**. |
| **Clash (Windows)** | Use **Subscription Conversion** to apply a remote configuration designed for leak prevention. For **TUN Mode**, use `fake-ip` and disable "Smart Multi-Homed Name Resolution" in Windows Group Policy. |
| **v2rayNG (Android)** | Enable "Local DNS" and "Virtual DNS" (fake-ip). Set Domain Strategy to **S**. Configure rules to "Bypass LAN and Mainland." |
| **Shadowrocket (iOS)** | Use a comprehensive configuration file (provided via URL) and set Global Routing to **Config** mode. |

### Windows "Smart Multi-Homed Name Resolution"
In TUN mode, Windows may send DNS requests to all available network adapters (including physical ones) simultaneously. To stop this:
1.  Open **Group Policy Editor**.
2.  Navigate to: `Administrative Templates` > `Network` > `DNS Client`.
3.  Enable **"Turn off smart multi-homed name resolution."**

---

## 5. WebRTC Leaks
Even with DNS leaks fixed, **WebRTC (Web Real-Time Communication)** can bypass proxies to reveal a user's true local IP address.
*   **Detection:** Specific IP-check websites can identify if the local IP is leaking via WebRTC.
*   **Solution:** Install a browser extension specifically designed to disable or limit WebRTC functionality.

---

## 6. Short-Answer Practice Questions

1.  **Why does a unique, random subdomain bypass DNS caching?**
    *   *Answer:* Because the subdomain has never been visited before, there is no existing record in the browser, OS, or ISP caches, forcing a fresh lookup to the authoritative server.
2.  **What is the default port and protocol for standard DNS traffic?**
    *   *Answer:* Port 53 using the UDP protocol.
3.  **How does "Fake-IP" mode help prevent DNS leaks in Clash?**
    *   *Answer:* It provides the system with a "fake" internal IP immediately, preventing the system from needing to resolve the real IP locally and allowing the proxy client to handle the actual resolution remotely.
4.  **What is the primary indicator of a DNS leak when using a detection website?**
    *   *Answer:* Seeing DNS servers belonging to your local ISP or country in the results while you are supposed to be using a proxy for another region.
5.  **Why is using "Global Mode" not always a guarantee against DNS leaks?**
    *   *Answer:* Some clients or OS configurations (like Windows Smart DNS) may still send resolution requests through the physical network adapter even when the proxy is set to global.

---

## 7. Essay Prompts for Deeper Exploration

1.  **The Conflict Between Latency and Privacy:** Analyze the trade-offs between local DNS resolution (which can be faster due to proximity) and remote DNS resolution. How does "leak prevention" impact user experience in terms of speed and accessibility?
2.  **DNS as a Fingerprinting Tool:** Discuss how streaming services and firewalls use DNS behavior to identify "proxy features." Why is the geographic alignment between the DNS server and the Proxy IP critical for bypassing modern geo-restrictions?
3.  **The Evolution of Proxy Protocols:** Compare the DNS handling of "System Proxy" mode versus "TUN/TAP" mode. Why does the latter require more complex configurations (like disabling Windows Smart DNS) to achieve the same level of privacy?

---

## 8. Glossary of Important Terms

*   **Authoritative DNS:** The final source in the DNS hierarchy that holds the actual IP records for a domain.
*   **DNS Pollution:** A technique where incorrect IP addresses are returned for a domain to prevent access to specific websites.
*   **Fake-IP:** A method where a proxy client returns a placeholder IP to the OS to intercept traffic without an initial real DNS lookup.
*   **PPPoE (Point-to-Point Protocol over Ethernet):** The method routers often use to connect to an ISP and receive a public IP and DNS assignments.
*   **Sniffing (S):** A strategy where the proxy client "sniffs" the domain name from the traffic to make routing decisions rather than relying on pre-resolved IPs.
*   **TTL (Time to Live):** A value in a DNS record that determines how many seconds the record should be cached before being refreshed.
*   **WebRTC Leak:** A browser-based vulnerability where the real local IP is exposed to websites despite the use of a proxy or VPN.