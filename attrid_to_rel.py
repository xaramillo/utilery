# xaramillo!

# ----
# Reemplaza "input.tsv" con la ruta a tu archivo TSV de entrada y "output.tsv" con la ruta deseada para el archivo de salida. 
# Este script leerá cada línea del archivo de entrada, extraerá los valores que siguen a los prefijos "ID=" y "Name=" si ambos prefijos están presentes en la línea,
# y luego escribirá los valores extraídos en el archivo de salida en un formato separado por tabuladores.
# Asegúra de tener un archivo TSV de entrada que tenga la columna 9 de un archivo gff en el mismo directorio que el script o proporcione la ruta correcta. 
# Además, asegúrese de que su archivo TSV de entrada tenga líneas que comiencen con "ID=" y contengan "\tName=" para que la extracción funcione según lo previsto.



def extract_id_and_name(line):
    id_index = line.find("ID=")
    name_index = line.find("Name=")
    
    if id_index != -1 and name_index != -1:
        id_value = line[id_index + 3 : line.find("\t", id_index)]
        name_value = line[name_index + 5 : line.find("\t", name_index)]
        return id_value, name_value
    else:
        return None, None

def main():
    input_file_path = "input.tsv"  # Change this to your input file path
    output_file_path = "output.tsv"  # Change this to your output file path

    with open(input_file_path, "r") as input_file, open(output_file_path, "w") as output_file:
        for line in input_file:
            if line.startswith("ID=") and line.find("\tName=") != -1:
                id_value, name_value = extract_id_and_name(line)
                if id_value and name_value:
                    output_file.write(f"{id_value}\t{name_value}\n")

if __name__ == "__main__":
    main()
