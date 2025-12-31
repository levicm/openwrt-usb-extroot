
# OpenWRT USB Extroot & Swap Scripts

This project contains two scripts to make it easy to expand your OpenWRT router's storage using a USB drive: one to configure extroot (expanding the main filesystem) and another to enable and configure swap (virtual memory).

**Reference:**
This project was based on the official OpenWRT documentation:
https://openwrt.org/docs/guide-user/additional-software/extroot_configuration


## Scripts

### 1. extroot.sh
Configures the `/dev/sda1` partition (formatted as ext4) of your USB drive as the new overlay (extroot) for OpenWRT. The script:
- Installs the required packages for USB and ext4 support.
- Checks if the device is present.
- Gets the partition UUID and configures fstab via UCI to mount as `/overlay`.
- Copies the current overlay data to the new disk.
- Configures access to the original overlay partition as `/rwm`.
- Reboots the router at the end of the process.

### 2. swap-to-sda2.sh
Enables and configures the `/dev/sda2` partition (formatted as linux-swap) of your USB drive as swap space. The script:
- Checks if the partition exists and is properly formatted.
- Activates swap.
- Configures fstab via UCI to enable swap automatically on every boot.
- Shows the swap status at the end.

## Requirements

1. **Prepared USB drive**: The first USB drive connected to the router (sda) must be previously partitioned and formatted:
   - For extroot: the first partition (`/dev/sda1`) must be formatted as ext4.
   - For swap: the second partition (`/dev/sda2`) must be formatted as linux-swap.
   - The scripts do not partition or format the drive, as this would require installing packages like `parted`, which may not fit in the router's internal memory.

2. **Router connected to the Internet** (to install packages):
   - **Via WAN**: Connect the Internet cable to the WAN port.
   - **Via LAN**:
     - Change the router's IP address (e.g., 192.168.1.3).
     - (Optional) Change the device name.
     - Set the gateway and DNS to the main router on the network (e.g., 192.168.1.1).
     - Connect an Internet cable to the LAN port.

3. **Date and time updated**: Make sure the router has the correct date and time to avoid issues when downloading packages from the repositories. If the router is already connected to the Internet, date and time can be updated automatically by setting the UTC for your city.

## Usage Steps

1. Access the router via SSH as root:
   ```sh
   ssh root@192.168.1.1
   ```
2. Copy the script commands and paste them into the terminal, or download and run directly:
   ```sh
   wget https://raw.githubusercontent.com/levicm/openwrt-usb-extroot/main/extroot.sh && chmod 777 extroot.sh && sh extroot.sh
   ```
3. Done!
4. To check the new available space, access the router's web interface or connect via SSH and run:
   ```sh
   df
   ```

---

**Powered by Levi Mota**
