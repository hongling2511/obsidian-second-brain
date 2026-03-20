# Study Guide: Optimizing VPS Nodes with AWS CloudFront (CFT)

This study guide provides a comprehensive overview of using Amazon Web Services (AWS) CloudFront—referred to here as **CFT**—as a high-performance Content Delivery Network (CDN) to accelerate Virtual Private Server (VPS) nodes. It covers the technical setup, IP optimization strategies, and methods for managing the AWS Free Tier to avoid unexpected costs.

---

## 1. Core Concepts and Context

### The Transition from Cloudflare (CF) to CloudFront (CFT)
While Cloudflare is a popular choice for rescuing blocked VPS IPs and accelerating poor network routes, its extreme popularity and free-of-charge model have led to heavy monitoring and interference by the Great Firewall (GFW). Optimized Cloudflare IPs are often quickly blocked. In contrast, AWS CloudFront (CFT) offers a robust alternative with a higher barrier to entry (requiring a credit card), which reduces mass abuse and maintains better performance.

### AWS Free Tier Specifications
AWS provides a permanent free tier for CloudFront, which includes the following monthly allowances:
*   **Data Transfer:** 1 TB of outbound traffic.
*   **Requests:** 10 million HTTP and HTTPS requests.
*   **Functions:** 2 million CloudFront Function calls (though these are less critical for basic node acceleration).
*   **Note:** Unused traffic does not roll over to the next month.

### Technical Requirements and Constraints
*   **Authentication:** Registration requires a valid credit card.
*   **Protocol Support:** For node acceleration via CFT, the transmission protocol must be set to **WebSocket (WS)**. This applies to VMess, VLESS, Trojan, and other protocols modified to use WS.
*   **Port Selection:** Port 80 is recommended for HTTP-based setups, while port 443 is used for TLS-based setups.

---

## 2. Technical Implementation Workflow

### Step 1: VPS and Node Preparation
1.  **Install x-ui:** Deploy the x-ui panel on the VPS to manage nodes.
2.  **Domain Binding:** Bind the VPS IP address to a domain name via a DNS provider (e.g., Cloudflare DNS). Ensure the "Proxy Status" is turned **off** (DNS Only) during the initial setup.
3.  **Create a WS Node:** Establish a node using the WebSocket transmission protocol. It is recommended to set the path (e.g., `/Ray`) and use port 80.

### Step 2: Creating a Speed Test Distribution
To optimize IPs without exhausting public resources or your own 1TB limit prematurely, create a dedicated distribution for speed testing:
*   **Origin Domain:** Use a domain that hosts a downloadable test file (e.g., a 100MB file).
*   **Protocol Policy:** Match the "Viewer" (browser) protocol.
*   **Caching:** Disable "Automatic Compression" and set the Cache Policy to "CachingDisabled" or a similar secondary option to ensure real-time speed results.

### Step 3: IP Optimization (优选 IP)
1.  **Acquire Tools:** Use an IP optimization program (originally designed for Cloudflare but compatible with CFT).
2.  **IP Ranges:** Replace the default Cloudflare IP list with AWS/CFT IP ranges.
    *   *Note:* Exclude mainland China IP ranges from the list, as using them for CDN services requires a specialized ICP filing.
3.  **Execute Test:** Run the optimizer using your custom CloudFront speed test URL. This identifies the fastest AWS edge nodes for your specific network environment.

### Step 4: Applying CFT to the Node
1.  **Create Distribution:** Set the "Origin Domain" to the domain you bound to your VPS in Step 1.
2.  **Origin Protocol:** If the node does not have an SSL certificate, select HTTP only.
3.  **Client Configuration:**
    *   **Address:** Use one of the optimized IPs discovered in Step 3.
    *   **Host/Pseudo-domain:** Use the random domain assigned by AWS (e.g., `xxxx.cloudfront.net`).
    *   **Port:** Set to 80 (or 443 if using TLS).

---

## 3. Short-Answer Practice Quiz

**Q1: Why is a credit card required for AWS CloudFront, and what impact does this have on the service?**
**A:** A credit card is required for AWS registration to create a barrier to entry. This prevents the "mass abuse" seen with Cloudflare, which only requires an email, ultimately leading to more stable IP addresses and less GFW interference.

**Q2: What is the primary transmission protocol required for a node to work with CFT?**
**A:** The node must use the WebSocket (WS) transmission protocol.

**Q3: How can a user verify if their CloudFront distribution and WebSocket path are configured correctly?**
**A:** By accessing the CloudFront-assigned domain followed by the WS path in a browser (e.g., `xxxx.cloudfront.net/path`). If configured correctly, the page should return a "Bad Request" message.

**Q4: What are the two steps required to completely delete a CloudFront distribution?**
**A:** First, the distribution must be "Disabled." Once the status reflects that it is disabled, it can then be "Deleted."

**Q5: Where can a user monitor their actual data usage to ensure they stay within the free tier?**
**A:** Usage can be monitored in the AWS Billing Dashboard under the "Bills" section, where specific regional data transfer and request counts are listed.

---

## 4. Essay Questions for Deeper Exploration

1.  **The Ethics and Logistics of "Anti-Exploitation" (反薅):** Analyze why the author emphasizes creating a personal speed test distribution rather than sharing one. Discuss how individual traffic management contributes to the longevity of free services provided by large corporations like AWS.
2.  **Comparison of CDN Architectures:** Evaluate the flexibility of AWS CloudFront's port mapping and protocol matching compared to Cloudflare. How does the ability to define custom origin ports (HTTP/HTTPS) provide a technical advantage for users hosting nodes on non-standard VPS configurations?

---

## 5. Glossary of Important Terms

| Term | Definition |
| :--- | :--- |
| **CFT** | An abbreviation used to distinguish AWS **CloudFront** from Cloudflare (CF). |
| **Origin (原域)** | The source server (your VPS) from which the CDN retrieves content to cache or relay. |
| **Viewer (查看器)** | In AWS terminology, this refers to the client's browser or the end-user's connection to the CDN. |
| **IP Optimization (优选 IP)** | The process of testing various CDN edge node IPs to find the one with the lowest latency and highest download speed for a specific local network. |
| **Pseudo-domain (伪装域名)** | The `xxxx.cloudfront.net` domain assigned by AWS, used in the SNI or Host header of a node configuration to route traffic through the CDN. |
| **WS Path** | A specific URL path (e.g., `/Ray`) defined in the WebSocket protocol settings to differentiate node traffic from standard web traffic. |
| **ICP Filing (備案)** | A required registration for domains using CDN nodes located within mainland China; CFT nodes outside China do not require this. |