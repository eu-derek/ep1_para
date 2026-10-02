#!/bin/bash

MEASUREMENTS=10
THREADS_LIST=(1 2 4 8 16 32)
REGIONS=(
  "full -2.5 1.5 -2.0 2.0"
  "seahorse -0.8 -0.7 0.05 0.15"
  "elephant 0.175 0.375 -0.1 0.1"
  "triple_spiral -0.188 -0.012 0.554 0.754"
)

run_experiments() {
    local mode_dir=$1  # "with_io" ou "no_io"
    mkdir -p "results/$mode_dir"

    # 1. Sequencial
    echo "Executando Sequencial ($mode_dir)..."
    mkdir -p "results/$mode_dir/mandelbrot_seq"
    SIZE=16
    for ((i=1; i<=10; i++)); do # 2^4 ate 2^13
        for REGION_DATA in "${REGIONS[@]}"; do
            read -r REGION_NAME XMIN XMAX YMIN YMAX <<< "$REGION_DATA"
            perf stat -r $MEASUREMENTS ./mandelbrot_seq $XMIN $XMAX $YMIN $YMAX $SIZE >> "results/$mode_dir/mandelbrot_seq/${REGION_NAME}_sz${SIZE}.log" 2>&1
        done
        SIZE=$((SIZE * 2))
    done

    # 2. Pthreads e OpenMP com variação de threads
    for T in "${THREADS_LIST[@]}"; do
        export OMP_NUM_THREADS=$T
        echo "Executando com $T threads ($mode_dir)..."

        # Pthreads
        mkdir -p "results/$mode_dir/mandelbrot_pth/t$T"
        SIZE=16
        for ((i=1; i<=10; i++)); do
            for REGION_DATA in "${REGIONS[@]}"; do
                read -r REGION_NAME XMIN XMAX YMIN YMAX <<< "$REGION_DATA"
                perf stat -r $MEASUREMENTS ./mandelbrot_pth $XMIN $XMAX $YMIN $YMAX $SIZE $T >> "results/$mode_dir/mandelbrot_pth/t$T/${REGION_NAME}_sz${SIZE}.log" 2>&1
            done
            SIZE=$((SIZE * 2))
        done

        # OpenMP
        mkdir -p "results/$mode_dir/mandelbrot_omp/t$T"
        SIZE=16
        for ((i=1; i<=10; i++)); do
            for REGION_DATA in "${REGIONS[@]}"; do
                read -r REGION_NAME XMIN XMAX YMIN YMAX <<< "$REGION_DATA"
                perf stat -r $MEASUREMENTS ./mandelbrot_omp $XMIN $XMAX $YMIN $YMAX $SIZE >> "results/$mode_dir/mandelbrot_omp/t$T/${REGION_NAME}_sz${SIZE}.log" 2>&1
            done
            SIZE=$((SIZE * 2))
        done
    done
}

# --- Execução Principal ---
make clean && make
run_experiments "with_io"

make clean && make no_io
run_experiments "no_io"

rm -f *.ppm