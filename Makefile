all: dsdt.dsl dsdt.aml

acpidump.txt:
	sudo acpidump >acpidump.txt

tmpxtract/dsdt.dat tmpxtract/facp.dat: acpidump.txt
	mkdir tmpxtract
	(cd tmpxtract; acpixtract -a ../acpidump.txt)

dsdt.dat: tmpxtract/dsdt.dat
	cp $^ $@

facp.dat: tmpxtract/facp.dat
	cp $^ $@

dsdt.dsl: dsdt.dat
	iasl -e tmpxtract/ssdt*.dat -d $^

dsdt.aml: dsdt.dsl
	patch -p0 <patches/01-change-touchpad-pnpid-to-200f.patch
	iasl -oa dsdt.dsl

install: dsdt.aml facp.dat
	sudo mkdir -p /boot/acpi/
	sudo cp facp.dat /boot/acpi/
	sudo cp dsdt.aml /boot/acpi/
	sudo cp 01_acpi_dsdt_facp /etc/grub.d/
	sudo update-grub

clean:
	rm -rf ssdt*.dat dsdt.dat dsdt.dsl facp.dat dsdt.aml acpidump.txt tmpxtract

.PHONY: all install clean
