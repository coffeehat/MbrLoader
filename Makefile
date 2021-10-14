NASM_VERSION=$(shell nasm -v)

default:
	make loader
	make image

loader: loader.s
	@echo ${NASM_VERSION}
	nasm -f bin -o loader -l loader.lst loader.s
	nasm -f bin -o app    -l app.lst    app1.s

image: loader
	dd if=loader of=../hd60M.img count=1 bs=512 conv=notrunc
	dd if=app    of=../hd60M.img seek=100 bs=512 conv=notrunc