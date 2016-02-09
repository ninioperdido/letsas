# LeTSAS
Linux for Embedded Terminals / Servicio Andaluz de Salud

Heavily customized and extremely lightweight Linux, using [Funtoo](http://funtoo.org) as a builder.
Intended to run in machines with 128Mb of RAM and disk, and processors like the [Via C3 Samuel 2 (without cmov)](http://en.wikipedia.org/wiki/VIA_C3)
Arch and CFLAGs used for this hardware as a baseline for the distro.

## Main features
 * Auto-updates using several rsync as layers.
 * Limits the hardware you can connect to the terminals via USB id.
 * Uses ZRAM, KSM and BTRFS compression.
 * Much more ...

Every option at the kernel were choosen for our current client machines hardware. 
Software packages were patched when needed thanks to the machinery of Gentoo/Funtoo.
