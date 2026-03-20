# Study Guide: Converting Proxy Protocols to Local SOCKS Nodes for Multi-Port Applications

This study guide provides a comprehensive overview of the methods and tools required to convert airport or self-hosted proxy nodes (using protocols like SS or Vmess) into local SOCKS/HTTP nodes. This process is essential for software—such as fingerprint browsers—that only supports standard SOCKS or HTTP proxies and requires multiple unique IP addresses for different environments.

---

## I. Key Concepts and Technical Logic

### The Need for Protocol Conversion
Many advanced proxy protocols (Shadowsocks, Vmess, etc.) are encrypted and require specific client software to decode. However, many applications (including network crawlers and fingerprint browsers) only support standard, unencrypted **SOCKS5** or **HTTP** proxies. Converting these encrypted nodes to local SOCKS nodes allows these applications to utilize the proxy's IP.

### The Limitation of Standard Clients
Standard GUI clients like **v2rayN** typically provide a single local SOCKS port (usually `10808`). While this works for one active node at a time, it cannot support scenarios requiring multiple nodes simultaneously (e.g., Browser A using a UK node and Browser B using a US node).
*   **Single Entry/Single Exit:** One port (10808) connects to one selected node in the client.
*   **Multi-Entry/Multi-Exit:** A range of ports (e.g., 50000–50043) where each specific port is mapped to a specific node.

### Clash-Meta (Mihomo) Integration
While the original Clash core does not support multiple local inbounds, **Clash-Meta** (a branch of the original project) supports expanded protocols and the ability to map multiple ports to different outbounds. This is the key technical component that enables a "one port per node" setup.

---

## II. Operational Workflow

### 1. Generating the Configuration
To achieve multi-port mapping without manually writing complex configuration files, a conversion tool is used:
*   **Input:** A standard Clash subscription URL or a list of node sharing links (SS/Vmess).
*   **Parameters:** A starting port is defined (default is `50000`).
*   **Output:** A `.yaml` configuration file compatible with Clash-Meta where:
    *   Port 50000 = Node 1
    *   Port 50001 = Node 2
    *   Port 50002 = Node 3 (and so on).

### 2. Importing into v2rayN
Once the configuration is generated:
1.  Add a **Custom Configuration** server in v2rayN.
2.  Import the generated `.yaml` file.
3.  Set the "Core" to **Clash_Meta**.
4.  Ensure the v2rayN SOCKS port is set to a non-zero value (to avoid conflicts with the first node in the custom config).
5.  Set the custom configuration as the **Active Server**.

### 3. Merging Multiple Subscriptions
If a user has multiple "airports" or self-hosted nodes, they can be merged into a single configuration:
*   Use a local subscription conversion tool.
*   Paste the file paths or sharing links into the tool.
*   **Constraint:** Ensure file paths do not contain Chinese characters, as this will cause conversion failure.

---

## III. Short-Answer Practice Questions

**1. Why is a standard v2rayN setup insufficient for users running multiple fingerprint browser environments simultaneously?**
> A standard setup only provides one local entry port (10808) that corresponds to whichever single node is currently selected in the software. It cannot output different nodes to different ports at the same time.

**2. What is the primary advantage of using Clash-Meta over the original version of Clash for this specific task?**
> Clash-Meta supports multiple inbounds and outbounds, allowing for the creation of a configuration where every individual node is assigned its own unique local port.

**3. In the v2rayN custom configuration settings, why must the SOCKS port be set to a value other than zero?**
> Setting it to a non-zero value ensures that the first port in your generated configuration (e.g., 50000) remains functional and does not conflict with the software's internal port management.

**4. What is a critical requirement regarding file paths when using the local subscription conversion tool?**
> The file path must not contain any Chinese characters; otherwise, the tool will fail to convert the subscription.

**5. How are HTTP proxies handled in this setup?**
> The ports generated are generally universal for both SOCKS and HTTP protocols. This allows users to set an HTTP proxy in their device’s WiFi settings using the specific port to route traffic through a specific node.

---

## IV. Essay Questions for Deeper Exploration

**1. Analyze the relationship between local proxy protocols and external encrypted protocols.**
*   *Task:* Explain how data moves from a local application (like a fingerprint browser) to the internet using the methods described in the source. Discuss the transition from SOCKS5 to SS/Vmess and the privacy implications of this "tunnel."

**2. Evaluate the utility of multi-port mapping for cross-border e-commerce and web crawling.**
*   *Task:* Discuss why "one port per node" is a critical requirement for these industries. How does this setup prevent account flagging or IP contamination when managing multiple accounts?

---

## V. Glossary of Terms

| Term | Definition |
| :--- | :--- |
| **SOCKS5** | A standard internet protocol that routes network packets between a client and server through a proxy server. |
| **Fingerprint Browser** | A specialized browser that creates isolated environments with unique digital fingerprints to prevent websites from tracking or linking multiple accounts. |
| **v2rayN** | A popular Windows GUI client that acts as a manager for various proxy cores like V2Ray, Xray, and Clash. |
| **Clash-Meta** | Also known as Mihomo, it is a branch of the Clash core that supports more protocols and advanced features like multi-inbound/outbound mapping. |
| **SS / Vmess** | Encrypted proxy protocols (Shadowsocks and Vmess) commonly used to bypass network restrictions and secure data transmission. |
| **Node (节点)** | A specific proxy server location (e.g., a server in the UK, US, or Hong Kong) used to route traffic. |
| **Inbound / Outbound** | Inbound refers to the local entry point (the port on your PC), while Outbound refers to the proxy server the data is sent to. |
| **Local Subscription Conversion** | The process of taking raw node links or different subscription formats and merging them into a single, unified configuration file (usually .yaml). |