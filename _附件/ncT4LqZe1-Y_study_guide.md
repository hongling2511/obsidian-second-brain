# Remote Intranet Access via Proxy Protocols: A Comprehensive Study Guide

This study guide explores the methodologies for accessing a home local area network (LAN) from a public network using common proxy protocols such as Shadowsocks (SS), VMess, and SOCKS5. Unlike traditional VPNs, this approach utilizes split-tunneling and proxy rules to provide a more flexible and efficient connection to home-based services like NAS or router management interfaces.

---

### I. Core Concepts and Architecture

The fundamental logic of using proxy protocols for intranet access involves routing specific traffic through a dedicated "home node." When a user attempts to access an internal IP address (e.g., `192.168.2.110`) from a remote location, the proxy client identifies the request via split-tunneling rules and directs it to the home router. The router decrypts the request, accesses the internal service, and returns the data through the proxy tunnel.

#### Key Advantages over Traditional VPNs
*   **Flexibility:** Users can use a high-speed proxy for general internet access (circumvention) while simultaneously using the home node only for internal traffic.
*   **Bandwidth Efficiency:** General internet traffic does not have to be routed through the home’s limited upload bandwidth.
*   **Protocol Support:** It avoids issues like UDP Quality of Service (QoS) throttling often associated with standard VPN protocols.

---

### II. Server-Side Configuration (The Home Router)

Establishing a connection requires the home router to act as a proxy server. This involves three primary phases:

#### 1. Creating the Proxy Node
Depending on the firmware or plugin used (e.g., OpenWrt), the setup varies slightly:
*   **Home Proxy / PassWall:** Create a new node (SOCKS5 or SS), set a port (e.g., `7788`), password, and encryption method. Ensure "Accept LAN Access" is enabled.
*   **OpenClash:** Typically uses SOCKS5 for inbound connections. Users must disable the "Allow LAN Only" restriction in traffic control settings.

#### 2. Network Visibility (Firewall and Public IP)
The node must be reachable from the internet. This depends on the available IP type:
*   **Public IPv4:** Requires **Port Forwarding**. The external port (e.g., `7788`) must be mapped to the router’s internal IP and the node’s internal port.
*   **Public IPv6:** Does not require port forwarding but requires a **Traffic Rule** (Communication Rule) to allow incoming traffic on the specific port. The rule should be set to "Accept" and limited to the IPv6 protocol.

#### 3. Dynamic DNS (DDNS)
Since home IP addresses frequently change, DDNS is essential to map a domain name to the current public IP, ensuring the client can always locate the home node.

---

### III. Client-Side Configuration Logic

The source outlines a "Three-Step Methodology" applicable to almost all proxy clients (Shadowrocket, Clash, V2Ray, etc.):

1.  **Add the Home Node:** Input the DDNS domain, port, and credentials.
2.  **Add Split-Tunneling Rules:** Create an `IP-CIDR` rule for the home subnet (e.g., `192.168.2.0/24`) and point it to the "Home" node.
3.  **Modify Bypass/Skip Lists:** This is the most critical step. Most clients are hardcoded to skip the proxy for private IP ranges (192.168.x.x). Users must manually remove their home subnet from the "Bypass Proxy," "Skip Proxy," or "Exclusion" lists.

| Client Tool | Key Configuration Detail |
| :--- | :--- |
| **Shadowrocket** | Remove home subnet from "Skip Proxy" in Global Settings; add IP-CIDR rule. |
| **Clash for Windows** | Edit the Config YAML; add the node to `proxies` and the rule to `rules`. |
| **Quantumult X** | Edit configuration file to remove subnet from "Excluded Routes." |
| **Sing-box** | Insert SS/SOCKS5 template in `outbounds` and routing rules in `route`. |
| **V2RayN / V2RayNG** | Add node and move the home subnet rule to the top of the routing list. |
| **Surfboard** | Enable "Local Network Filter" and remove subnet from "Skip Proxy." |

---

### IV. Constraints and Requirements

*   **Subnet Conflict:** The local network (where the user is currently located) and the home network **must not** share the same subnet. If both use `192.168.2.x`, the client will prioritize the local network, making the home intranet inaccessible.
*   **IPv6 Support:** If using an IPv6-based node, the client device and the current network must also support IPv6.

---

### V. Short-Answer Practice Quiz

1.  **Why do most proxy tools fail to access home intranets even when a home node is correctly configured and active?**
2.  **What is the primary difference between configuring a firewall for IPv4 versus IPv6 in this context?**
3.  **Explain the role of the "IP-CIDR" rule in a proxy client's configuration.**
4.  **What happens if a user tries to access their home NAS (192.168.1.50) while their current office network also uses the 192.168.1.x subnet?**
5.  **In the context of OpenClash, what specific setting must be toggled to allow the router to accept proxy requests from the public internet?**

---

### VI. Essay Questions for Deeper Exploration

1.  **Analyze the technical trade-offs between using a standard VPN (like OpenVPN or WireGuard) and using proxy protocols (like Shadowsocks) for remote home access. Consider factors such as encryption, ease of use, and network performance.**
2.  **Discuss the importance of the "Three-Step Methodology" mentioned in the source. Why is the removal of the intranet IP from the "Bypass List" often the most overlooked step in network configuration?**
3.  **Evaluate the impact of IPv6 adoption on home hosting. How does the lack of NAT (Network Address Translation) in IPv6 simplify or complicate the process of exposing internal services to the public internet compared to IPv4 port forwarding?**

---

### VII. Glossary of Important Terms

*   **DDNS (Dynamic Domain Name System):** A service that automatically updates a domain name's IP address in real-time as the home router's public IP changes.
*   **IP-CIDR:** A method for allocating IP addresses and IP routing that specifies a range of IP addresses (e.g., `192.168.2.0/24` covers all addresses from `192.168.2.0` to `192.168.2.255`).
*   **NAS (Network Attached Storage):** A file-level computer data storage server connected to a computer network providing data access to a heterogeneous group of clients.
*   **Outbound:** A configuration setting in proxy clients (like Sing-box) that defines where the data is sent after it is processed by the rules.
*   **Port Forwarding:** A configuration in a router that directs external traffic from a specific port to an internal IP address and port.
*   **QoS (Quality of Service):** Network mechanisms that prioritize certain types of data traffic; often used by ISPs to throttle UDP traffic.
*   **Split-Tunneling (Rule-Based Proxy):** A network configuration that allows a user to access different networks (e.g., a public website and a private home server) through different network connections or nodes simultaneously.
*   **Subnet:** A logical subdivision of an IP network, defined by a range of IP addresses that can communicate directly with each other.