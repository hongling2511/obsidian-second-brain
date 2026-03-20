# Node Speed Testing and Automated Management Software Study Guide

This study guide provides a comprehensive overview of the specialized node speed testing software based on the v2rayN architecture. It covers the software’s core functionality, supported protocols, testing logic, and operational procedures as described in the source material.

---

## 1. Software Overview and Core Purpose

The software is a secondary development based on **v2rayN**, specifically modified to enhance node speed testing capabilities. Unlike standard proxy clients, this version is dedicated exclusively to **speed testing** and does not include proxy (circumvention) functionality.

### Key Technical Foundations
*   **Base Architecture:** Developed from v2rayN.
*   **Testing Engine:** Utilizes the **Clash (clashn) kernel** for speed measurements.
*   **Kernel Choice Logic:** While v2rayN typically uses Xray or V2Ray kernels, those kernels do not support the ShadowsocsR (SSR) protocol. Because SSR nodes remain prevalent in public node pools, the Clash kernel was selected to ensure broader protocol compatibility.

---

## 2. Supported Protocols and Data Import

The software is designed to handle a wide variety of proxy protocols and import formats commonly found in the "node pool" ecosystem.

### Supported Protocols
The software supports the following protocols for speed testing:
*   Shadowsocks (SS)
*   ShadowsocksR (SSR)
*   Vmess
*   Trojan
*   Socks5
*   HTTP / HTTPS

### Import Methods
The software provides several ways to populate the node list:
| Import Method | Description |
| :--- | :--- |
| **URL Links** | Direct pasting of protocol links (e.g., vmess://, ss://). |
| **Base64 Subscription** | Copying and pasting standard Base64 encoded subscription strings. |
| **YAML Format** | Supports Clash-style YAML node lists, provided the text begins with a specific node indicator (`- name:` format). |
| **Node Pool URLs** | Users can add a subscription address directly into the "Node Pool" settings for automated updates. |

---

## 3. Automated Testing and Filtering Logic

The primary strength of the software is its "One-Click Speed Test" (一键测速) feature, which follows a specific logical sequence to identify high-quality nodes.

### Step-by-Step Testing Process
1.  **Deduplication:** The software automatically removes duplicate nodes upon import or at the start of a test.
2.  **Latency Testing (Ping):** The software first tests the latency of all nodes.
3.  **Latency Filtering:** Based on the "Latency Test Result Quantity" setting (e.g., 100), the software will continue testing until the number of valid nodes is reduced to the specified threshold. This removes unstable nodes before moving to the more time-consuming download test.
4.  **Download Speed Testing:** The software performs a 10-second download test on the remaining nodes to determine actual throughput.
5.  **Speed Filtering:** Nodes that fall below a user-defined speed threshold (e.g., 0.6 Mbps or 1.0 Mbps) are automatically or manually removed.

---

## 4. Operational Configuration and Management

### Critical Settings
*   **Timeout Interval:** Specifically applies to latency testing; determines how long the software waits for a response.
*   **Download Duration:** The default duration for testing download speed is 10 seconds.
*   **Save Configuration:** Unlike the original v2rayN, this version does **not** auto-save. Users must click "Save Configuration" (保存配置) before exiting to retain node lists and settings.
*   **Stopping Tests:** Because the software is multi-threaded, users should use the specific "Stop Speed Test" button to ensure all threads finish correctly and avoid errors.

### Advanced Maintenance
*   **System Compatibility:** The included Clash kernel is 64-bit. Users on 32-bit Windows systems must manually replace the kernel file with a 32-bit version.
*   **Node Scraping Tip:** Users can find new node pools by using the Google search operator `inurl:` followed by specific node pool URL patterns to identify publicly accessible node lists.

---

## 5. Short-Answer Practice Questions

**1. Why does the software use the Clash kernel instead of the Xray or V2Ray kernels?**
> **Answer:** The Clash kernel was chosen because it supports the SSR (ShadowsocksR) protocol, which is still widely shared in node pools. Xray and V2Ray kernels do not support SSR.

**2. What is the purpose of the "Latency Test Result Quantity" setting?**
> **Answer:** It limits the number of nodes that proceed to the download speed test. By filtering the list down to a smaller number (e.g., 100) based on the best latency, it saves time and removes unstable nodes before the lengthy download test begins.

**3. What must a user do to ensure their node list is not lost after closing the software?**
> **Answer:** The user must manually click the "Save Configuration" (保存配置) button, as the software does not support automatic saving.

**4. How can a user export the results of a speed test to another client?**
> **Answer:** Users can right-click to copy the nodes as standard links (C+C) or export them as a Base64 encoded subscription link.

**5. What is a known limitation regarding YAML/Clash configuration imports?**
> **Answer:** The software only parses the node list portion of a Clash configuration. It cannot import the full configuration file including rules and settings, and the first line must follow the node list formatting rules.

---

## 6. Essay Prompts for Deeper Exploration

**1. The Efficiency of Multi-Stage Filtering:**
Analyze the software’s logic of testing latency before download speeds. Discuss why this two-stage approach is more efficient for managing large "node pools" (containing thousands of nodes) compared to testing download speeds for every node immediately.

**2. Specialized vs. Multi-Purpose Software Design:**
The developer explicitly removed the proxy/circumvention features of v2rayN to focus on speed testing. Evaluate the benefits of creating a "testing-only" utility versus a full-featured client. Consider aspects such as system resources, user workflow, and technical stability.

---

## 7. Glossary of Important Terms

*   **Base64:** A group of binary-to-text encoding schemes used in this context to encode node subscription data into a string format.
*   **Clash Kernel:** The core engine used by the software to handle protocol communication and speed measurements.
*   **Inurl:** A Google search operator used to find pages where the specified text is part of the URL; used here to locate node pools.
*   **Latency (延时):** The time delay (usually in milliseconds) for data to travel from the user to the node server and back.
*   **Node Pool (节点池):** A collection or source of multiple proxy server nodes, often updated automatically.
*   **SSR (ShadowsocksR):** An extension of the Shadowsocks protocol that includes additional obfuscation and features.
*   **v2rayN:** The original open-source GUI client upon which this specific speed-testing software is built.
*   **YAML:** A human-readable data serialization language used for Clash configuration files.