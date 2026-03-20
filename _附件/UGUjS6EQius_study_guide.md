# Comprehensive Study Guide: Streaming Media Access via SNI Reverse Proxy and DNS Redirection

This study guide examines the technical methods for accessing geo-restricted streaming services, such as Netflix and Disney+, without the use of traditional proxy tools. It focuses on the application of SNI reverse proxies and DNS server tools to bypass regional restrictions while maintaining direct connection speeds.

---

## I. Core Concepts and Principles

### 1. Geo-Blocking vs. Firewall Blocking
The document distinguishes between two types of access restrictions encountered in Mainland China:
*   **Regional Restriction (Geo-blocking):** Services like Netflix and Disney+ are not blocked by the Great Firewall (GFW); rather, the services themselves detect the user's location and refuse to provide content to IP addresses originating from Mainland China.
*   **GFW Blocking:** Websites like YouTube and Google are actively blocked by the national firewall. These cannot be accessed via simple SNI reverse proxies because the SNI (Server Name Indication) is transmitted in plaintext, leading to immediate SNI reset/interference by the GFW.

### 2. SNI Reverse Proxy (SNI 反向代理)
An SNI reverse proxy acts as an intermediary. It performs port forwarding based on the SNI provided in the TLS handshake.
*   **Function:** It receives a request and forwards it to the actual streaming service (e.g., Netflix).
*   **Data Handling:** The proxy does not process or modify the data; it simply forwards it between the user and the destination server.
*   **Unlocking Mechanism:** By routing traffic through a proxy located in a supported region (e.g., Hong Kong or Taiwan), the streaming service sees the proxy's IP address instead of the user's Mainland China IP, thus "unlocking" the content.

### 3. DNS Hijacking/Redirection via Acrylic
To route traffic through an SNI proxy without a system-wide VPN, users must redirect specific domain requests. This is achieved using **Acrylic**, a DNS proxy tool for Windows.
*   **Role:** It allows a Windows machine to act as a local DNS server.
*   **Mechanism:** By modifying the Acrylic `hosts` file, users can map specific domains (like `netflix.com`) to the IP address of a chosen SNI reverse proxy.

---

## II. Implementation Workflow

The process of setting up a local DNS-based unlock involves the following steps:

| Step | Action | Key Configuration |
| :--- | :--- | :--- |
| **1** | **Install Acrylic** | Install and start the Acrylic service on a Windows machine. |
| **2** | **Configure DNS** | Edit the configuration file to set the upstream DNS to the local router IP (via `ipconfig` gateway). |
| **3** | **Enable Sharing** | Add the command to allow other devices to use the local machine's DNS service. |
| **4** | **Identify SNI Proxy** | Find a functional SNI reverse proxy IP (e.g., through search results/templates). |
| **5** | **Modify Hosts** | Replace template IPs in the Acrylic `hosts` file with the functional SNI proxy IP. |
| **6** | **Local DNS Setup** | Set the local network adapter's DNS to `127.0.0.1` (or the machine's LAN IP for other devices). |
| **7** | **Clear Cache** | Flush the DNS cache and use incognito mode to bypass browser caching. |

---

## III. Technical Limitations and Advanced Usage

### 1. Browser vs. App Compatibility
*   **Success Rate:** This method is highly effective for web browsers.
*   **App Limitations:** Mobile apps or specialized clients often fail because they have hardcoded DNS settings (e.g., Google DNS) that bypass local system DNS configurations.

### 2. Integration with X-UI
Users with private VPS nodes that do not natively unlock Netflix can use SNI proxies to achieve unlocking. By modifying the X-ray template in the X-UI panel, specific traffic can be routed to the SNI proxy IP, allowing the node to bypass geo-restrictions.

### 3. The Reality Protocol
The document mentions the **Reality protocol** as a successor/evolution related to SNI proxies:
*   **Advantages:** It does not require a domain name or certificate and maintains a real TLS connection.
*   **Challenges:** It is difficult for beginners because it requires finding a suitable "target" website (like a Microsoft site) that is large enough to handle frequent requests without triggering security defenses (CC attack protection).

---

## IV. Short-Answer Practice Questions

1.  **Why does the SNI reverse proxy method fail for YouTube but work for Netflix?**
    *   *Answer:* Netflix is only geo-restricted, whereas YouTube is blocked by the GFW. Since SNI is transmitted in plaintext, the GFW detects the forbidden domain in the SNI field and blocks the connection.

2.  **What is the primary function of the Acrylic tool in this setup?**
    *   *Answer:* Acrylic provides a local DNS service for Windows, allowing the user to redirect specific domain requests to a chosen SNI reverse proxy IP via a custom `hosts` file.

3.  **How do you verify if an SNI reverse proxy IP is likely to work?**
    *   *Answer:* Accessing the IP via HTTPS; if the page returns an "unsupported protocol" error or a specific proxy landing page, there is a high probability (90-95%) it is functional.

4.  **Why is it recommended to use incognito mode when testing the setup?**
    *   *Answer:* To avoid issues caused by browser cache, which might prevent the new DNS settings from taking effect immediately.

5.  **What is a major risk of self-hosting an SNI reverse proxy without IP restrictions?**
    *   *Answer:* It can become a public proxy, leading to high traffic consumption and a high risk of the IP being detected and blocked by the GFW.

---

## V. Essay Prompts for Deeper Exploration

1.  **Analyze the trade-offs between using a dedicated "airport" (commercial VPN) and the SNI reverse proxy method described.** Consider factors such as traffic consumption, speed, cost, and ease of use.
2.  **Evaluate the security implications of routing traffic through a third-party SNI reverse proxy found online.** While the document states these proxies don't "process" data, discuss potential risks regarding metadata and connection stability.
3.  **Explain the technical evolution from SNI reverse proxies to the Reality protocol.** Discuss why the Reality protocol seeks to eliminate the need for domains and certificates and the specific difficulties in selecting an appropriate target website for simulation.

---

## VI. Glossary of Important Terms

*   **Acrylic:** A specialized DNS proxy software for Windows that allows users to manage and override DNS resolutions locally.
*   **GFW (Great Firewall):** The legislative and technological mechanism used to regulate the internet in Mainland China.
*   **Hosts File:** A local plain-text file that maps hostnames to IP addresses, used by the operating system to redirect web traffic.
*   **Reality Protocol:** A newer proxy protocol (pre-release) that aims to provide a real TLS connection without requiring the user to own a domain or certificate.
*   **SNI (Server Name Indication):** An extension of the TLS protocol that indicates which hostname the client is attempting to connect to at the start of the handshaking process.
*   **SNI Reset/Interference:** A tactic used by firewalls to interrupt a connection upon detecting a forbidden hostname in the plaintext SNI field.
*   **X-UI:** A web-based management panel used to configure and manage proxy protocols like X-ray.