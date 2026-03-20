# Comprehensive Study Guide: Architecture and Operation of Proxy Services (Airports)

This study guide explores the technical framework, operational logic, and business considerations of "Airports"—multi-user proxy service providers. It synthesizes the technical requirements for deployment, the relationship between front-end management and back-end execution, and the privacy implications for end-users.

---

## 1. Core Concepts and Architecture

### The Definition of an "Airport"
In the context of network circumvention, an "Airport" is a commercialized multi-user proxy service. Unlike a single-user setup (like X-UI), an Airport includes integrated systems for user registration, subscription management, and automated payment processing.

### Structural Components
The operation of an Airport relies on the separation of the management interface and the traffic-handling core:
*   **Frontend Panels:** Web-based interfaces (e.g., V2Board, SS Panel, Xboard) used by administrators to manage users, plans, and nodes, and by users to purchase subscriptions.
*   **Backend Cores:** The engine that performs the actual proxying work (e.g., Xray-core).
*   **Modified Backends:** Tools like **XrayR** are modified versions of the standard core designed to interface with Airport panel APIs. They synchronize user data, traffic statistics, and connection limits in real-time.

### Deployment Infrastructure
*   **VPS (Virtual Private Server):** The physical or virtual hardware where the software resides.
*   **Docker:** Often used for "brainless" or simplified deployment of the frontend and backend environments.
*   **DNS and TLS:** Essential for domain mapping and securing the web interface. Services like Cloudflare are used to manage A records and implement "Flexible" encryption or port-rewriting rules (e.g., redirecting domain traffic to specific ports like 7001).

---

## 2. Operational Workflow

### Frontend Configuration
1.  **Permission Groups:** Categorizing users into different tiers (e.g., VIP 1, VIP 2) to control access to specific nodes.
2.  **Subscription Plans:** Defining the rights of each tier, including monthly traffic quotas, speed limits, and device connection limits.
3.  **Payment Integration:** Connecting the panel to payment gateways. Options include direct Alipay "Face-to-Face" payments, cryptocurrency, or third-party payment aggregators (which typically charge a ~10% fee).
4.  **Communication Security:** Establishing a "Communication Key" (API Key) that allows the backend to securely fetch user data from the frontend.

### Backend Synchronization
The backend (XrayR) does not store user data locally. Instead, it uses the API Host and Communication Key to query the frontend. It identifies nodes via a "Node ID" and retrieves:
*   User passwords and encryption methods.
*   Traffic remaining for individual users.
*   Specific protocol configurations (Shadowsocks, Vmess, Trojan, etc.).

### Advanced Routing and Relays
*   **Direct Connection:** The user connects directly to the proxy VPS.
*   **Transit/Relay (Middleman):** Traffic is forwarded from an entry node (often a high-quality line like an IPLC) to the actual exit (landing) node to improve stability and speed.
*   **Node Multiplexing:** A single VPS can host an unlimited number of virtual nodes by assigning different ports to different geographic "identities" in the configuration files.

---

## 3. Business and Security Analysis

### Cost-Benefit Analysis
Operating an Airport involves significant overhead:
*   **Fixed Costs:** VPS hosting, middleware/transit services, and DNS unlocking services (for streaming media).
*   **Variable Costs:** Marketing/Affiliate commissions (often 20% or higher) and payment processor fees (approx. 10%).
*   **Profit Margins:** Estimated at roughly 30% after expenses, excluding the "cost" of technical support and mitigating DDoS attacks or legal risks.

### Privacy Risks
Airport owners have visibility into significant user data through backend logs, including:
*   The timestamp of the connection.
*   The user's original IP address.
*   The specific destination websites or IP addresses the user is visiting.

### The "Parasitic" (Secondary Proxy) Method
A low-cost method for starting an Airport involves "leeching" off existing providers. The operator purchases a subscription from a large Airport and configures their own XrayR backend to route data through the larger provider's nodes. This allows a single VPS to appear as though it has nodes across the globe without the operator owning those servers.

---

## 4. Short-Answer Practice Questions

1.  **What is the primary difference between an X-UI setup and an Airport?**
    *   *Answer:* X-UI is designed for single-user, single-node scenarios. An Airport is a multi-user system featuring registration, automated subscriptions, and payment integrations.

2.  **Why is the "Communication Key" (API Key) critical for Airport security?**
    *   *Answer:* It is the credential used by the backend to access the frontend API. If leaked, unauthorized parties can access all user information, including passwords and subscription details.

3.  **In the context of XrayR, what is the function of the "Node ID"?**
    *   *Answer:* The Node ID matches the specific node configuration in the frontend panel with the backend process, ensuring the backend handles traffic according to the correct settings (protocol, port, etc.).

4.  **How can a single VPS provide nodes for multiple different countries?**
    *   *Answer:* By configuring the backend to listen on different ports for different Node IDs and using routing rules (or secondary proxies) to change the exit IP or simply label them differently in the subscription.

5.  **What are the common payment methods for Airports, and why are third-party platforms used?**
    *   *Answer:* Methods include Alipay, WeChat, and cryptocurrency. Third-party platforms are used for privacy and convenience, as they handle the transaction processing in exchange for a percentage fee (usually around 10%).

---

## 5. Essay Prompts for Deeper Exploration

1.  **Technical vs. Operational Barriers:** The source suggests that the technical barrier to building an Airport is low ("brainless operation"), yet many small Airports fail. Analyze the non-technical challenges (economic, support-based, and legal) that influence the sustainability of these services.
2.  **The Privacy Trade-off:** Discuss the implications of the "Airport" model on user privacy. Given that owners can see source IPs and destination logs, compare the security of using a commercial Airport versus self-hosting a single-user node.
3.  **Ethics of the "Parasitic" Business Model:** Evaluate the technical and ethical implications of "Secondary Proxying" (re-selling another Airport's nodes). How does this affect the reliability of the service and the relationship between different providers in the ecosystem?

---

## 6. Glossary of Important Terms

| Term | Definition |
| :--- | :--- |
| **XrayR** | An open-source backend core modified to support multi-user Airport panels via API synchronization. |
| **V2Board / Xboard** | Popular open-source frontend panels used for managing Airport users and subscriptions. |
| **IPLC** | International Private Leased Circuit; used in "Transit" nodes to provide low-latency, stable connections across borders. |
| **Landing IP** | The final IP address seen by the destination website; the "exit" point of the proxy tunnel. |
| **Node Rate (倍率)** | A multiplier applied to traffic consumption (e.g., a 2x rate means 1GB of use consumes 2GB of the user's quota). |
| **SMTP Server** | Simple Mail Transfer Protocol; required by Airport panels to send registration and verification emails to users. |
| **Docker** | A platform for delivering software in packages called containers, used here to simplify the installation of complex frontend systems. |
| **Outbound / Inbound** | Configuration terms in Xray; "Inbound" defines how the server receives data from the user, and "Outbound" defines where that data is sent next. |
| **Shadowsocks (SS)** | A lightweight tunnel proxy protocol commonly supported by Airport backends for its simplicity. |