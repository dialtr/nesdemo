ASM=ca65
LD=ld65

.PHONY:
all: demo.nes

.PHONY:
clean:
	-rm -f demo.nes *.o

demo.nes: demo.o
	$(LD) -o demo.nes -C demo.cfg --dbgfile demo.dbg $^

run: demo.nes
	fceux demo.nes

.s.o:
	$(ASM) $<
