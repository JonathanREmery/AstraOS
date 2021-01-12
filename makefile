bootloader:bootloader.asm print.asm disk.asm
	nasm -f bin bootloader.asm -o bootloader.bin

extended_bootloader:extended_bootloader.asm print.asm
	nasm -f bin extended_bootloader.asm -o extended_bootloader.bin

AstraOS:bootloader extended_bootloader
	cat bootloader.bin extended_bootloader.bin > AstraOS.bin

run:
	sudo qemu-system-x86_64 -enable-kvm -cpu host -fda AstraOS.bin

clean:
	rm bootloader.bin
	rm extended_bootloader.bin
