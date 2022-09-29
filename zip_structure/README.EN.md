#
#
#
#
#
#

XDA - https://forum.xda-developers.com/t/a-b-script-universal-disable-force-encryption-for-a-b-dynamic-partitions-virtual-a-b-devices-neo-beta-0-9-0.4454017/


Donate me : 
monthly donations: PayPal, visa, MasterCard
https://www.donationalerts.com/r/leegarchat
https://boosty.to/leegar/about
Crypto: Bitcoin, litecoin, Ethereum
https://telegra.ph/Donation-list-crypto-05-29


Telgram https://t.me/PocoF3DFE , https://t.me/mfpupdate

How to use DFE-NEO or how to simplify the install/update ROM process
Let's start with the arguments and how to edit them. Open the DFE-NEO archive through the archiver program and run arguments.txt
https://t.me/PocoF3DFE/57039
Here we can see in the screenshot the parameters of the DFE operation
Spoiler: Operating modes of these parameters:
These parameters have two modes: 
• true (yes),
• false (no)
Exceptions for specific parameters:
• DFE method (DFE installation method, some roms work only with DFE-NEO)
=neo (new method)
=legacy (old method)
• Flash slot
=both (patching boot_a and boot_b partitions, also applies to installing magisk, twrp)
=in-current (patching the boot_x partition, where x is the current slot, also applies to installing magisk, twrp)
=un-current (patching the boot_x partition, where x is the opposite slot)
• Reboot after installing (Reboot after installation)
=none (no, that is, there will be no reboot)
=system(restart to system, simple reboot)
=bootloader (reboot to fastboot mode)
=recovery (reboot to recovery mode)
So we have sorted out the modes of operation of all parameters. Now, what does each of them mean.
Spoiler: The values of these parameters
Here the functions of the parameters are described in true mode, for exceptions depending on the mode of operation of the parameter
• DFE method - DFE installing method
• Flash slot - patching the boot partition
• Reboot after installing - reboot after installation
• DISABLE DINAMIC REFRESH - disable dynamic screen stamping, ONLY FOR MIUI
• Flash DFE - DFE install
• Hide not encrypted - The ROM will think that encryption is enabled
• Skip warning - at the end, a mini guide on the correct use of dfe after firmware will be shown
• Reflash recovery for ota - flashing recovery after ota updates, according to the Flash slot parameter mode=
• Reflash current Recovery for Recovery - flash the current recovery, according to the Flash slot parameter mode=
• Wipe DATA - deleting the contents of the /data section without formatting the internal memory (where the Android, Downloads, Music, etc. folders are located) If you flash DFE for the first time, then you must format data
• Remove PIN - remove password/lockscreen
• Disable AVB - system integrity check is disabled (or whatever you call it, you can set false if you flash magisk)
• Disable QUOTA - (to be honest, I didn't understand what it was, but you can leave it true)
• Flash Magisk - installing Magisk, according to the Flash slot parameter mode=
Spoiler alert: how to use DFE-NEO correctly
1. If you delete magisk through the manager or uninstall.zip, then DFE will stop working. In that case you should flash DFE again
2. If DFE was installed with Magisk, then you can upgrade and downgrade the Magisk version without flashing DFE
3. If DFE was installed without Magisk, then you can flash Magisk later, and follow the rules 1,2.
4. If you installed TWRP or another custom recovery, then DFE will stop working, you will need to flash dfe again
5. If you install/update the rom, then
you need to flash the DFE again, by analogy with the magisk
Spoiler: And you can also customize your temporary arguments.txt
In DFE-NEO, in addition to using arguments.txt in .zip archive, you can still set up your temporary one. After installing the rom, run the dfe-neo archive and select Configure Arguments now (volume + >> volume -) 
Where we can adjust the parameters.
Volume + indicates change
Volume - indicates select
Here you can see how it works - https://youtu.be/jHTE1dzkoHc
Spoiler alert: What should I choose DFE method= neo or legacy?
• Neo method - patches the boot partition, we leave neo if the system partitions are read-only(like in erofs ROMs), also suitable if the system partitions are editable
• Legacy method - patches fstab.qcom in the /vendor/etc/ section, this method cannot be used if the system partitions are read-only(like in erofs based ROMs)