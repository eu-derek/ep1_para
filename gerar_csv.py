import os
import re
import csv

# Nome do arquivo CSV final
output_csv = "medicoes.csv"

# Regex para extrair o tempo do output do comando `perf stat`
# Exemplo de linha do perf: "       0,142012 +- 0,001200 seconds time elapsed"
perf_pattern = re.compile(r'(\d+[,\.]\d+)\s+seconds time elapsed')

headers = ["algoritmo", "modo_io", "regiao", "tamanho_imagem", "threads", "tempo_medio_segundos"]

rows = []

# Varre a pasta results gerada pelo script shell
for root, dirs, files in os.walk("results"):
    for file in files:
        if file.endswith(".log"):
            path_parts = root.split(os.sep)
            
            # Exemplo de caminho: results/with_io/mandelbrot_pth/t4/seahorse_sz1024.log
            if len(path_parts) >= 3:
                modo_io = path_parts[1]        # with_io ou no_io
                algoritmo = path_parts[2]      # mandelbrot_seq, mandelbrot_pth, mandelbrot_omp
                
                # Extrai quantidade de threads
                threads = 1
                if len(path_parts) >= 4 and path_parts[3].startswith("t"):
                    threads = int(path_parts[3].replace("t", ""))
                
                # Extrai região e tamanho a partir do nome do arquivo (ex: seahorse_sz1024.log)
                match_file = re.match(r'([a-z_]+)_sz(\d+)\.log', file)
                if match_file:
                    regiao = match_file.group(1)
                    tamanho = int(match_file.group(2))
                    
                    # Lê o arquivo de log para pegar o tempo informado pelo perf
                    filepath = os.path.join(root, file)
                    with open(filepath, 'r') as f:
                        content = f.read()
                        match_time = perf_pattern.search(content)
                        if match_time:
                            # Converte vírgula para ponto se necessário
                            tempo = float(match_time.group(1).replace(',', '.'))
                            rows.append([algoritmo, modo_io, regiao, tamanho, threads, tempo])

# Grava os resultados no arquivo CSV
with open(output_csv, mode='w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    writer.writerows(rows)

print(f"Arquivo {output_csv} gerado com sucesso contendo {len(rows)} medições!")