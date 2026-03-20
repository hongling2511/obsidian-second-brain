# Comprehensive Study Guide: Mastering Soft Routers and Network Proxying

This study guide provides an exhaustive overview of soft routers, their advantages over traditional hardware, installation procedures, and their role in creating a unified home network environment for scientific internet access.

---

## I. Core Concepts and Fundamentals

### 1. Defining the Soft Router
A **soft router** is not a specific commercial product but rather a general-purpose computing device (such as a mini PC, an industrial control host, an old laptop, or a development board) running a routing operating system. 
*   **Soft Router vs. Hard Router:** Hard routers (common consumer routers) have functions "hardened" by the manufacturer and cannot easily support new features. Soft routers allow the installation of various plugins and software, offering high flexibility.
*   **Hybrid Transformation:** If a hard router’s original system is replaced (flashed) with a third-party routing system, it effectively becomes a soft router.

### 2. The Primary Use Case: Unified Proxying
The central "pain point" addressed by soft routers is the limitation of device-specific proxy tools (e.g., v2ray, Clash, Shadowrocket). 
*   **Individual Device Limits:** Many devices, such as TV boxes, VR headsets, and game consoles, do not support proxy software directly.
*   **The Soft Router Solution:** By running proxy plugins directly on the router (the gateway of the local area network), all data sent from any connected device is encrypted and proxied before reaching the internet. This provides "scientific internet access" for every device in the home without individual configuration.

### 3. Hardware Requirements
For optimal performance, soft router hardware should generally feature:
*   **Multiple Network Ports:** A minimum of two ports is required (one for WAN, one for LAN). Single-port devices have significant limitations.
*   **Architecture Varieties:**
    *   **ARM (e.g., NanoPi R2S):** Low cost, low power consumption (under 2W), but limited software compatibility compared to x86.
    *   **x86 (e.g., Intel N100, J1900):** High performance, broad software support, and high extensibility, though usually more expensive.

---

## II. Operating Systems and Firmware

### 1. Popular Routing Systems
*   **OpenWrt:** An open-source, free system and the most popular choice for soft routers due to its vast plugin ecosystem.
*   **Others:** pfSense, RouterOS (ROS), iKuai, and Merlin.

### 2. Firmware Sourcing Strategies
| Source Type | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Pre-compiled** | Created by third-party authors with built-in plugins. | Extremely convenient; ready to use. | Potential security risks (backdoors); often bloated with unneeded features. |
| **Self-compiled** | User-built from source code. | Highly customized; clean. | Extremely complex and time-consuming for beginners. |
| **Official/Branch** | Clean systems like Official OpenWrt or **ImmortalWrt**. | Secure, pure, and stable. | Very few built-in plugins; requires manual installation of tools. |

**ImmortalWrt** is recommended for its balance of a clean system and a rich, accessible software repository with CDN acceleration for easy plugin management.

---

## III. Installation and Deployment

### 1. The "Writing Disk" Process
Installing the OS involves "writing" a system image (`.img`) to a storage medium (SD card or USB drive).
*   **Tools:** Rufus (Windows, small and portable) or BalenaEtcher (cross-platform).
*   **x86 Specifics:** After writing to a USB, the user must often enter the BIOS (typically via the `Delete` key) to change the **Boot Option Priority** to ensure the USB device boots first.

### 2. Network Configuration Modes
*   **Main Router Mode:** The soft router connects to the fiber modem (Optical Network Unit - ONU). It handles **PPPoE dialing** and acts as the primary DHCP server and gateway for the home.
*   **Wireless AP Mode:** Since most soft routers lack built-in WiFi, a traditional hard router is repurposed as an **Access Point (AP)**. This is done by:
    1.  Connecting the soft router's LAN port to the hard router's WAN or LAN port.
    2.  Disabling the hard router's DHCP service.
    3.  Setting the hard router to "Wired Relay" or "Bridge" mode.

### 3. Resolving IP Conflicts
If the soft router and the modem share the same IP segment (e.g., both use `192.168.1.1`), a conflict occurs. The soft router's LAN IP must be modified (e.g., to `192.168.2.1`) to ensure proper routing.

---

## IV. Scientific Internet Access Plugins

The document identifies three major plugins within the OpenWrt/ImmortalWrt ecosystem:

1.  **PassWall:** A popular choice for its straightforward node management and support for both manual node entry and subscription links.
2.  **Home Proxy:** A newer plugin utilizing the **sing-box** kernel, known for efficiency.
3.  **OpenClash:** Based on the **Clash** kernel. It is powerful and offers a detailed Web UI for switching nodes, though it requires manual kernel downloads (often via CDN) during the first setup.

---

## V. Short-Answer Practice Questions

1.  **Why is it discouraged for beginners to flash a "hard router" with OpenWrt?**
    *   *Answer:* Hard routers store their systems in soldered Flash memory. Errors during flashing can "brick" the device (making it unrecoverable). Additionally, limited Flash capacity restricts the number of plugins that can be installed.
2.  **What is the difference between `squashfs` and `ext4` firmware formats?**
    *   *Answer:* `squashfs` supports "Factory Reset" by wiping the overlay partition without overwriting the original ROM. `ext4` does not have this mechanism and cannot be easily reset to defaults.
3.  **In an OpenWrt environment, what do `eth0` and `eth1` typically represent?**
    *   *Answer:* They represent physical network ports. In many default configurations, `eth0` is defined as the LAN port and `eth1` is defined as the WAN port.
4.  **What is the "double NAT" problem?**
    *   *Answer:* This occurs when both the fiber modem and the router are performing Network Address Translation. It can lead to performance loss. It is solved by setting the modem to "Bridge Mode" and letting the router handle PPPoE dialing.
5.  **How can you install plugins on a "pure" ImmortalWrt system?**
    *   *Answer:* Through the **Software Packages** section in the LuCI web interface. Users must first update the package list and then search for specific plugins (e.g., `luci-app-openclash`).

---

## VI. Essay Prompts for Deeper Exploration

1.  **The Evolution of Home Networking:** Discuss how the shift from hardware-centric to software-defined networking (soft routers) changes the way users manage security, privacy, and device interoperability in a modern smart home.
2.  **Architecture Trade-offs:** Compare ARM and x86 architectures in the context of network routing. Analyze factors such as power efficiency, instruction set compatibility, and long-term scalability for a household with 50+ connected devices.
3.  **The Security Implications of Third-Party Firmware:** Evaluate the risks associated with using "community-compiled" router firmware. What are the potential dangers of "hidden scripts," and how does using an official branch like ImmortalWrt mitigate these risks while maintaining usability?

---

## VII. Glossary of Important Terms

*   **AP (Access Point):** A device that provides wireless WiFi signals to a network but does not necessarily handle routing or DHCP.
*   **Bridge Mode:** A modem setting where the modem only converts signals (optical to electrical) and leaves the task of dialing and routing to a connected router.
*   **DHCP (Dynamic Host Configuration Protocol):** A service that automatically assigns IP addresses to devices on a local network.
*   **Firmware:** The operating system stored on the router's hardware.
*   **Gateway:** The "exit" point of a local network; in most homes, this is the router’s internal IP address.
*   **ImmortalWrt:** A popular fork of OpenWrt optimized with better software repositories and third-party plugin support.
*   **LuCI:** The web-based graphical user interface (GUI) used to configure OpenWrt routers without using the command line.
*   **NAT (Network Address Translation):** A method of remapping one IP address space into another, allowing multiple devices to share a single public IP.
*   **PPPoE:** The protocol used by routers to "dial-in" to an Internet Service Provider (ISP) to obtain a public IP address.
*   **Writing/Flashing the Disk:** The process of installing an operating system onto an SD card or hard drive, making it a bootable system.