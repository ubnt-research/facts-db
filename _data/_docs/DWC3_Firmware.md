# TI DWC3 - Super Speed USB Dual Mode - Firmware File Format

* Original File from `dcf8-ENVR-4.1.11-92cf39e2-1415-4382-aa13-09adc6afd89f.bin`
* `binwalk -M -e X.bin` extracts `dwc_usb31_phy_x1.fw`
* `cpu_rec` fails to identify most of the file, then `MMIX`
* Given Si manufacturers are cheep... the logical assumption is that the firmware file is to their royalty free Z80 instruction set.  (It helps to be old and know the history here - yes the Z80 from your TI 83 - same as the space shuttle)
* Opened in Binja with Z80 plugin, generally successful lift.
* Need to strip off the header
* There's also the matter of what the privledged ROM calls are to (`RST $XX` instructions - like `INT` in x86, `SVC` in arm, and `SysEnter` in x64)

## dwc_usb31_phy_x1.fw

```
typedef {
    const char[4] magic = "USBF", // FBSU
    uint32_t length,  // file length + 0x0C (sizeof(header)) bytes
    uint32_t part_count
} header;

typedef {
    const char[4] magic = "RUNH", // HNUR


} part;
```