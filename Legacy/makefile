bootloader.bin:bootloader.asm
	nasm bootloader.asm -f elf64 -o bootloader.o

#kernel_entry.o:kernel_entry.asm
	#nasm kernel_entry.asm -f elf64 -o kernel_entry.o

kernel.o:kernel.c
	x86_64-elf-gcc -ffreestanding -c kernel.c -o kernel.o

#kernel.bin:kernel_entry.o kernel.o
	#x86_64-elf-ld -o kernel.bin -Ttext 0x5000 kernel_entry.o kernel.o --oformat binary

AstraOS.bin:bootloader.o kernel.o
	x86_64-elf-gcc -T linker.ld -o AstraOS.bin -shared -ffreestanding -O2 -nostdlib bootloader.o kernel.o
	#cat bootloader.bin kernel.bin > AstraOS.bin

all:bootloader.o kernel.o AstraOS.bin #bootloader.bin kernel_entry.o kernel.o kernel.bin AstraOS.bin

clean:
	rm bootloader.bin
	rm kernel_entry.o
	rm kernel.o
	rm kernel.bin

run:
	qemu-system-x86_64 -fda AstraOS.bin
