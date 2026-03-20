# The xhttp Transport Protocol: Evolution, Mechanisms, and Implementation

This study guide provides a comprehensive overview of the **xhttp transport protocol**, a significant advancement in proxy technology designed to bypass network interference (specifically the Great Firewall or GFW) while maintaining high transmission efficiency. It details the protocol's historical evolution, technical features, and practical deployment strategies.

---

## 1. The Evolution of Proxy Transport Protocols

The development of xhttp is the result of iterative improvements to how proxy data is encapsulated and transmitted to mimic normal web traffic.

### Comparison of Transmission Methods

| Protocol | Date Introduced | Mechanism (Upload/Download) | Efficiency | Primary Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **mik (mKCP)** | May 2023 | Packet Upload / Packet Download | Low | CDN-supported anti-censorship; backup solution. |
| **splithttp** | June 2024 | Packet Upload / Stream Download | Moderate | Improved speed over CDN compared to mik. |
| **xhttp** | Late 2024 | Stream Upload / Stream Download | High | High-performance proxying; full scenario support. |

### Key Historical Milestones
*   **mik (v2ray):** Introduced the ability to encapsulate proxy data within standard HTTP traffic. While it could pass through CDNs and was highly resistant to blocking, the overhead of constant packet reassembly made it too slow for primary use.
*   **splithttp (Xray):** Developed to address the efficiency issues of mik. By utilizing a "stream-based" downlink (using indefinite length chunked responses) while keeping packet-based uplink, it significantly boosted network speeds.
*   **xhttp:** An evolution of splithttp that achieved full "stream-based" transmission for both uplink and downlink. It includes modern features like byte padding, multiplexing, and uplink/downlink separation.

---

## 2. Core Technical Features of xhttp

The xhttp protocol is designed to be a "universal" solution that works across all scenarios, from direct connections to complex CDN-fronted setups.

*   **Stream-Based Transmission:** Unlike older protocols that break data into discrete packets (requiring constant requests from the client), xhttp treats data as a continuous byte stream, reducing overhead and latency.
*   **CDN Compatibility:** Because xhttp mimics standard HTTP traffic, it can be easily routed through Content Delivery Networks (CDNs) like Cloudflare, hiding the origin server's IP address.
*   **Uplink and Downlink Separation:** A unique feature allowing the proxy to use different domains, IP addresses, or connection methods for uploading data versus downloading data. This increases the complexity for firewalls attempting to analyze traffic patterns.
*   **Byte Padding & Multiplexing:** These features (documented by the protocol developers) allow for further obfuscation and the ability to handle multiple data streams over a single connection.

---

## 3. Implementation and Configuration

Deploying xhttp requires specific server-side setups and updated client tools.

### Server-Side Setup (3x-ui)
The most common method for rapid deployment involves using the **3x-ui** panel. Two primary configurations are supported:
1.  **xhttp + Reality:** Combines the obfuscation of xhttp with the "Reality" security protocol. This setup is generally used for direct connections without a CDN.
2.  **xhttp + TLS (via CDN):** Used for maximum concealment. The traffic is routed through a CDN (e.g., Cloudflare), and the protocol is set to xhttp with a specific path.

### Client-Side Requirements
Due to xhttp being a relatively new protocol, users must ensure their tools are updated to the latest versions:
*   **Windows:** v2rayN.
*   **Android/Mac:** v2rayN (Mac version requires manual kernel updates for Xray and Go).
*   **Kernel Update:** Users must manually or automatically update to the latest Xray core within their client application to support the xhttp protocol.

---

## 4. Advanced Scenario: Uplink/Downlink Separation

One of the most powerful applications of xhttp is separating the paths of incoming and outgoing traffic to enhance security and performance.

### Logic of Separation
In a standard proxy, the client establishes a single connection to a domain for both upload and download. In an xhttp separated setup:
*   **Uplink:** The client sends data to the server via **Domain A** (possibly via CDN for better obfuscation).
*   **Downlink:** The server sends data back to the client via **Domain B** (possibly a direct connection for higher speed).

### Hybrid CDN/Reality Configuration
A highly effective setup involves using a **CDN for the Uplink** and **Reality for the Downlink**:
1.  The client establishes an uplink through a CDN-protected domain.
2.  The downlink is established via a direct Reality connection to the VPS IP.
3.  **Fallback Mechanism:** If the Reality connection receives data it does not recognize (like xhttp data encapsulated in a specific way), it "falls back" to a secondary port (e.g., port 6666) where a raw xhttp service is running to process the data.

---

## 5. Glossary of Key Terms

*   **3x-ui:** A web-based management panel used to install and configure proxy protocols (Xray/v2ray) on a server.
*   **CDN (Content Delivery Network):** A system of distributed servers that deliver web content. In proxying, it is used to hide the true IP address of the node.
*   **GFW (Great Firewall):** The sophisticated network censorship system used to block or throttle specific internet traffic.
*   **Multiplexing:** The process of sending multiple signals or streams of information over a single communications link at the same time.
*   **Reality:** A security protocol that eliminates the need for traditional TLS certificates by mimicking the handshake of a real, popular website.
*   **Stream-based Downlink:** A method where the server sends data as a continuous stream (chunked response), preventing the client from needing to constantly request new packets.
*   **v2rayN:** A popular client-side GUI for Windows, Android, and Mac that supports various proxy protocols including Xray and xhttp.

---

## 6. Short-Answer Practice Quiz

1.  **What was the primary disadvantage of the older "mik" (mKCP) protocol?**
    *   *Answer:* It had low transmission efficiency and slow speeds because it used a packet-based system for both uploading and downloading.
2.  **How does splithttp improve upon the mik protocol?**
    *   *Answer:* It uses a packet-based system for uploading but introduces a stream-based system for downloading, which significantly increases speed.
3.  **What is the benefit of setting the Cloudflare TLS mode to "Flexible" when using xhttp?**
    *   *Answer:* It allows for TLS encryption between the browser/client and Cloudflare without requiring the user to manually configure certificates on their own VPS.
4.  **In a 3x-ui configuration, what is the purpose of the "Fallback" (fback) setting?**
    *   *Answer:* It redirects traffic that the primary protocol (like Reality) cannot recognize to a different port where another protocol (like a raw xhttp node) is waiting to process it.
5.  **Which client applications currently support the xhttp protocol?**
    *   *Answer:* v2rayN for Windows, Android, and Mac (provided the Xray core is updated).

---

## 7. Essay Prompts for Deeper Exploration

1.  **Analyze the trade-offs between a direct "xhttp + Reality" connection and an "xhttp + TLS + CDN" connection.** Discuss factors such as latency, speed, and the likelihood of the server's IP being blocked by the GFW.
2.  **Explain the technical logic and security advantages of "Uplink/Downlink Separation."** How does using different domains or connection methods for incoming and outgoing data complicate traffic analysis for censors?
3.  **Discuss the importance of "Fallback" mechanisms in modern proxy architecture.** Using the example of a Reality node falling back to a raw xhttp node on port 6666, explain how this hides the true nature of the server from unauthorized probes.