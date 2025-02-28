


# UBNT Firmware Files


## Header


## Entries

### `FILE`

```c

typedef struct {
    const char magic[0x04]; // UBNT
    const char name[0x100];
    uint32_t crc;
    uint32_t pad_bytes;
} ubnt_firmware_header_t;

typedef enum {
    FILE = 
} ubnt_firmware_part_t;

// values of 0x02 in preloader an 0xc04 in atf seen, possible flags?
typedef enum {
  UBOOT = 0x01;
  PRELOADER = 0x02;
  ADDITIONAL_FIRMWARE  = 0x04;
  ROOT_FS = 0x07;
  LINUX_KERNEL = 0x0D;
} ubnt_file_type_t;

typedef enum {

} ubnt_file_protection_t;

typedef struct {
    const char magic[0x04]; // "FILE"
    const char name[0x20]; // The name of the file - some common are 'kernel' 'uboot' 'uboot-env' 'preloader' 'rootfs' and 'updater'
    uint32_t index; // network byte order
    uint32_t mtd_offset; // native endian - little for MIPS
    uint32_t pad_bytes; // often 0 - could be reserved??
    uint32_t file_size; // network order - the number of bytes following the header for the content
    uint32_t mtd_size; // Size of the MTD partition
    ubnt_file_type_t type;
    ubnt_file_protection_t protection;
    uint32_t crc; // Adlar 32 / crc??
} ubnt_file_t;

typedef struct {
    const char magic[0x04]; // ENDS
    const char rsa_sig[0x0100]; // Signature
    uint32_t reserved;
} ubnt_firmware_end_t;
```

5183DDCC 00000000 46494C45 61746600 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000002 00400000 00000000 00038770 00100000 40000014 70870300