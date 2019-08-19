use16

org OPT 1
org HEADS 4

Begin:
file "mbr_worm.bin", 512
file "honeypot_kernel.bin"
align 512
align HEADS + SPT + 256 + 256