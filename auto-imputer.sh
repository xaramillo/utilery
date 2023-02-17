#!/usr/bin/env bash
#
# Xaramillo - MIT License
#
#
# Parse Parameters #
#
display_help(){
  echo -e "\n# Imputation Auto Script - Version 0.6.0 (2023/01/18)\n"
  echo -e "## Método de uso:\n"
  echo -e "\t $ $0 --input <FinalReport>\n"
  echo -e "\t\t Este uso es para procesamiento de archivos individuales\n"
  echo -e "\t $ $0 --batch <Folder>\n"
  echo -e "\t\t Esta opcion procesa todos los finalreport de una carpeta\n"
  echo "## Opciones disponibles:"
  echo -e "\t -i | --input <FinalReport> \t Calcula el genotipo del finalreport"
  echo -e "\t -b | --batch <Folder> \t\t Procesa una carpeta con finalreports"
  echo -e "\t -h | --help \t\t\t Despliega la ayuda\n"
  echo -e "## Descripción:"
  echo -e "\t Genera imputacipnes desde el finalreport v2.1\n"
  exit
}
# WorkLoad #
workload(){
  BEAGLE5="/opt/repo/luis/beagle5.jar" # Descarga el binario desde la página de beagle
  FILE=$(basename "$PRAEFIX" | cut -d. -f1)
  echo "Archivo $PRAEFIX reconocido, haciendo backup."
  cp "$PRAEFIX" "$FILE.bak"
  echo "Descartando SNPs conflictivos ..."
  for h in $(cat $DISEASE_RISK_PATH/data/loci/ignore_snp.txt); do
	     echo "... Removiendo $h"
	     grep -v "\b$h\b" "$FILE.txt" > "$FILE.tmp"
	     mv -f "$FILE.tmp" "$FILE.txt"
  done
  echo "Convirtiendo el FinalReport a VCF"
  finalreport-vcf-parser.R "$FILE.txt"

  echo "Preparando Archivos VCF"
  for i in {1..22}; do

    REF_HAP="/opt/db/imputation-panels/beagle/chr${i}.bref3"

    echo "Imputando chr $i (beagle5)"

    java -jar $BEAGLE5 gt="$FILE.vcf" chrom="$i" ref="$REF_HAP" out="$FILE.$i"

    echo "Imputación Terminada, recuperando marcadores ($ vcftools --positions)"
    vcftools --gzvcf "$FILE.$i.vcf.gz" --positions "/opt/data/loci/rsID_imputed_positions.txt" --out "$FILE.$i.imputed" --recode --recode-INFO-all

    echo "Imputación del Cromosoma $i Terminado"
  done
  vcf-concat $(ls $FILE*vcf) > "$FILE.added.vcf"
}

# Header #
echo -e "Imputation Auto Script V0.6.0\n"
# Variables #
#
# Main #
#
if [ $# -eq 0 ]
  then
    display_help
  else
    while [ "$1" != "" ]; do
      case $1 in
        -i|--input)
        if [ -n "$2" ]; then
          PRAEFIX="$2"
          workload "$PRAEFIX"
          shift 2
        else
          echo "Error: se requiere nombre del panel"
          exit 1
        fi
        ;;
        -b|--batch)
        if [ -n "$2" ]; then
          if [[ -d "$2" ]]; then
            LASTWD=$(pwd)
            cd "$2"
            NUM_FR=$(ls *.txt | wc -l)
            NUM=0
            cp $GAR_AUTH_FILE .
	    echo -e "Final reports encontrados: $NUM_FR"
            for i in $(ls *.txt); do
              NUM=$(($NUM+1))
              echo "Archivo Procesado: $NUM de $NUM_FR"
              PRAEFIX="$i"
              workload "$PRAEFIX"
              echo -e "Procesamiento en Lote finalizado"
            done
		  rm mrbase.oauth
	          cd "$LASTWD"
          else
            echo "Error: $2 No existe la ubicación"
            exit 1
          fi
          shift 2
        fi
        ;;
        -h|-\?|--help)
        display_help
        ;;
        *)               # Default case: If no more options then break out of the loop.
        echo "Opcion desconocida: $1"
        echo "Uso: $0 --input <panel>"
        exit
      esac
    done
fi
