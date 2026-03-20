# Advanced Node Acquisition and Management Study Guide

This study guide provides a comprehensive overview of identifying, filtering, and utilizing free internet proxy nodes sourced from public node pools. It explores the methodologies used by content creators to aggregate these resources and the technical processes required to integrate them into various clients.

---

## 1. Key Concepts and Principles

### The Origin of Free Nodes
Free nodes shared by online creators typically originate from **Node Pools** (節點池). These are specialized websites or databases maintained by site administrators that automatically scrape node information from public sources, including:
*   Telegram (TG) channels.
*   Subscription addresses.
*   Public internet directories.

### Node Pool Characteristics
*   **Aggregation:** Some pools aggregate data from dozens of sources, resulting in thousands of available nodes.
*   **Automation:** They constantly crawl the web for new node information.
*   **Server-Side Testing:** Many node pools feature built-in speed tests. However, these results represent the speed from the pool's server to the node, not the user's local connection. Therefore, server-side speed data should only be used as a general reference.

---

## 2. Filtering and Customizing Node Lists

To manage the high volume of nodes (which can exceed 4,000 in a single pool), users can apply specific URL parameters to the node pool’s connection address to filter for quality and compatibility.

### URL Filtering Parameters
| Parameter | Description | Examples |
| :--- | :--- | :--- |
| **Country (`C=`)** | Filters nodes by geographic region. | `HK` (Hong Kong), `MO` (Macau), `TW` (Taiwan), `KR` (Korea), `SG` (Singapore), `JP` (Japan). |
| **Protocol (`p=`)** | Filters by specific proxy protocols. | `SS` (Shadowsocks), `VMess` (often referred to as 'v' or 'w' protocols). |
| **Speed (`speed=`)** | Filters nodes based on the pool’s recorded speed (in Mbps). | `30` (above 30 Mbps) or `15,30` (between 15 and 30 Mbps). |

### Syntax Example
A filtered link is constructed by adding a question mark followed by the parameters:  
`[Base URL]?C=HK,TW,SG&p=SS,VMess&speed=30`

---

## 3. Subscription Conversion and Integration

Because raw node lists from pools may not be directly compatible with all clients, a **Subscription Conversion** (訂閱地址轉換) tool is used.

### The Conversion Process
1.  **Input:** Paste the filtered URL from the node pool into the conversion website.
2.  **Client Selection:** Select the target client (e.g., V2Ray, Clash, Surge, Shadowrocket).
3.  **Generation:** The tool generates a subscription link or a Base64-encoded string.
4.  **Base64 Encoding:** This is a common method for representing node data in a format that clients can easily parse.

### Importing into Clients
*   **Direct Import:** Users can copy the generated string and paste it directly into clients like V2RayN.
*   **Subscription:** Users can add the generated URL as a "Subscription" in the client, allowing for easy updates.

---

## 4. Verification and Speed Testing

Once nodes are imported, local verification is essential to determine which nodes are actually functional for the user.

### Testing Methods in V2RayN
1.  **Ping/Connection Test:** Tests the latency between the local machine and the server. This has limited value for determining actual browsing speed.
2.  **Simulation Test (Google Speed):** Simulates a connection to a specific website (like Google) to see if the node is working.
3.  **True Speed Test:** The client downloads a specific file (e.g., a 10MB test file) to measure the actual download speed in Mbps.

---

## 5. Glossary of Important Terms

*   **Base64:** A group of binary-to-text encoding schemes used to transport node configuration data.
*   **Clash:** A cross-platform rule-based proxy client.
*   **Node (節點):** A remote server used as a proxy to route internet traffic.
*   **Node Pool (節點池):** A website that aggregates and hosts lists of public proxy nodes.
*   **SSR (ShadowsocksR):** An older proxy protocol. Note that some modern V2Ray clients may not support SSR without specific configurations.
*   **Subscription Address (訂閱地址):** A URL that a proxy client uses to download and update a list of servers automatically.
*   **VMess:** A protocol used by V2Ray for encrypted communication.

---

## 6. Short-Answer Practice Questions

1.  **Why is the speed test displayed on a node pool website considered "reference only" for a local user?**
2.  **What is the primary function of a subscription conversion website?**
3.  **Which geographic regions are generally recommended for users in mainland China seeking faster connection speeds?**
4.  **If a user wants to filter for nodes with speeds higher than 30 Mbps, what parameter should they add to the URL?**
5.  **How can a user import multiple nodes into V2RayN without manually adding them one by one?**

---

## 7. Essay Prompts for Deeper Exploration

1.  **The Lifecycle of a Free Node:** Trace the path of a node from its initial discovery by a node pool administrator to its final use by an end-user. Discuss the role of automation and aggregation in this ecosystem.
2.  **Protocol Compatibility and Evolution:** Analyze why certain protocols like SSR are becoming less common in standard V2Ray setups, and explain the importance of using conversion tools to bridge the gap between different proxy protocols and clients.
3.  **Efficiency in Node Management:** Evaluate the advantages of using filtered subscription links versus importing thousands of raw nodes. How does filtering by protocol and geography improve the user experience and client performance?