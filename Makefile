GCCPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = o/loader.o o/kernel.o

o/%.o: %.cpp
	gcc $(GCCPARAMS) -c -o $@ $<

o/%.o: %.s
	as $(ASPARAMS) -o $@ $<

mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)
	rm -rf o

install:
	mkdir -p o iso_source iso_source/boot/
	make mykernel.bin
	sudo mv mykernel.bin iso_source/boot/mykernel.bin

mykernel.iso: install
	mkdir -p iso_source/boot/grub iso
	echo 'set timeout=0' > iso_source/boot/grub/grub.cfg
	echo 'set default=0' >> iso_source/boot/grub/grub.cfg
	echo '' >> iso_source/boot/grub/grub.cfg
	echo 'menuentry "stoc OS" {' >> iso_source/boot/grub/grub.cfg
	echo '	multiboot /boot/mykernel.bin' >> iso_source/boot/grub/grub.cfg
	echo '	boot' >> iso_source/boot/grub/grub.cfg
	echo '}' >> iso_source/boot/grub/grub.cfg
	grub-mkrescue --output=iso/$@ iso_source
	rm -rf iso_source
