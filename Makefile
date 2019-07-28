all:

.PHONY: build test hex

build:
	iverilog -Winfloop -o build/test_cpu test/*.v cpu/*.v mock/*.v

test:
	vvp -n build/test_cpu
