#!/bin/bash
# ==============================================================
# tfsdump.sh — Coleta todos os arquivos Terraform do projeto
# Uso: bash tfsdump.sh
# Output: /tmp/tfsdump.txt
# ==============================================================

OUT="/tmp/tfsdump.txt"
SEP="=================================================================="

echo "tfsdump — $(date)" > $OUT
echo "" >> $OUT

# Busca todos os .tf e .json relevantes a partir do diretório atual
find . \( \
  -name "*.tf" \
  -o -name "*.tfvars" \
  -o -name "destroy_config.json" \
  -o -name "backend.tf" \
  -o -name "lambda_function.py" \
\) \
  ! -path "*/.terraform/*" \
  ! -path "*/node_modules/*" \
  | sort | while read FILE; do
    echo "$SEP"     >> $OUT
    echo "### $FILE" >> $OUT
    echo "$SEP"     >> $OUT
    cat "$FILE"     >> $OUT
    echo ""         >> $OUT
    echo ""         >> $OUT
done

echo "$SEP"                          >> $OUT
echo "### FIM DO DUMP — $(date)"    >> $OUT
echo "$SEP"                          >> $OUT

echo ""
echo "✅ Dump concluído: $OUT"
echo "Tamanho: $(wc -l < $OUT) linhas"
echo ""
echo "Para visualizar:"
echo "  cat $OUT"
