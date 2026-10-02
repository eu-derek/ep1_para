OUTPUT=mandelbrot
IMAGE=.ppm

CC=gcc
CC_OPT=-std=c11
CC_OMP=-fopenmp
CC_PTH=-pthread

.PHONY: all no_io clean

all: $(OUTPUT)_omp $(OUTPUT)_pth $(OUTPUT)_seq

no_io: CC_OPT += -DNO_IO
no_io: all

$(OUTPUT)_omp: $(OUTPUT)_omp.c
	$(CC) -o $(OUTPUT)_omp $(CC_OPT) $(CC_OMP) $(OUTPUT)_omp.c

$(OUTPUT)_pth: $(OUTPUT)_pth.c
	$(CC) -o $(OUTPUT)_pth $(CC_OPT) $(CC_PTH) $(OUTPUT)_pth.c

$(OUTPUT)_seq: $(OUTPUT)_seq.c
	$(CC) -o $(OUTPUT)_seq $(CC_OPT) $(OUTPUT)_seq.c

clean:
	rm -f $(OUTPUT)_omp $(OUTPUT)_pth $(OUTPUT)_seq *$(IMAGE)