all:

.PHONY: build test hex

build:
	iverilog -Winfloop -o build/test_cpu test/*.v cpu/*.v mock/*.v

test:
	vvp -n build/test_cpu

hex:
	xxd -p -c 1 program/monitor.bin > program/monitor.hex