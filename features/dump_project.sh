#!/bin/bash
# ==============================================================
# dump_project.sh — Gera snapshot completo do projeto em 1 arquivo
# Uso: bash dump_project.sh [diretório] [arquivo_saida]
# Padrão: bash dump_project.sh . project_dump.txt
# ==============================================================

ROOT_DIR="${1:-.}"
OUTPUT="${2:-project_dump.txt}"
EXTENSIONS=("tf" "yaml" "yml" "json" "txt" "md" "sh" "py" "properties")
SPECIAL_FILES=("Dockerfile" "Makefile" ".env.example")

# Arquivos/dirs a ignorar
IGNORE_DIRS=(".git" ".terraform" "node_modules" "__pycache__" ".github/workflows")
IGNORE_FILES=(".terraform.lock.hcl" "*.tfstate" "*.tfstate.backup" "*.plan" "prd.plan")

> "$OUTPUT"  # Limpa o arquivo de saída

echo "=================================================================" >> "$OUTPUT"
echo "  PROJECT DUMP — $(date)" >> "$OUTPUT"
echo "  Diretório: $(realpath $ROOT_DIR)" >> "$OUTPUT"
echo "=================================================================" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# --------------------------------------------------------------
# Seção 1: Tree completo
# --------------------------------------------------------------
echo "## ESTRUTURA DO PROJETO (tree)" >> "$OUTPUT"
echo '```' >> "$OUTPUT"
if command -v tree &> /dev/null; then
    tree "$ROOT_DIR" \
        --noreport \
        -I '.git|.terraform|node_modules|__pycache__|*.tfstate*|*.plan|prints' \
        >> "$OUTPUT"
else
    find "$ROOT_DIR" \
        -not -path '*/.git/*' \
        -not -path '*/.terraform/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/prints/*' \
        | sort | sed "s|$ROOT_DIR/||" >> "$OUTPUT"
fi
echo '```' >> "$OUTPUT"
echo "" >> "$OUTPUT"

# --------------------------------------------------------------
# Seção 2: Conteúdo dos arquivos
# --------------------------------------------------------------
echo "## CONTEÚDO DOS ARQUIVOS" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Monta o padrão de find para extensões
FIND_EXTS=()
for ext in "${EXTENSIONS[@]}"; do
    FIND_EXTS+=(-o -name "*.$ext")
done

# Monta ignore de diretórios
PRUNE_EXPR=()
for dir in "${IGNORE_DIRS[@]}"; do
    PRUNE_EXPR+=(-path "*/$dir" -prune -o)
done

# Monta ignore de arquivos
should_ignore() {
    local file="$1"
    local basename=$(basename "$file")
    # Ignora prints/imagens
    [[ "$file" == */prints/* ]] && return 0
    [[ "$file" == */.terraform/* ]] && return 0
    [[ "$file" == */.git/* ]] && return 0
    [[ "$basename" == "*.tfstate" ]] && return 0
    [[ "$basename" == "*.tfstate.backup" ]] && return 0
    [[ "$basename" == "prd.plan" ]] && return 0
    [[ "$basename" == ".terraform.lock.hcl" ]] && return 0
    [[ "$basename" == "dump_project.sh" ]] && return 0
    [[ "$OUTPUT" == *"$basename"* ]] && return 0
    return 1
}

# Processa arquivos por extensão + especiais
find "$ROOT_DIR" \
    -not -path '*/.git/*' \
    -not -path '*/.terraform/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/prints/*' \
    \( \
        -name "*.tf" -o \
        -name "*.yaml" -o \
        -name "*.yml" -o \
        -name "*.json" -o \
        -name "*.txt" -o \
        -name "*.md" -o \
        -name "*.sh" -o \
        -name "*.py" -o \
        -name "*.properties" -o \
        -name "Dockerfile" -o \
        -name "Makefile" \
    \) \
    -type f | sort | while read -r FILE; do

    should_ignore "$FILE" && continue

    # Caminho relativo
    REL_PATH="${FILE#$ROOT_DIR/}"

    # Detecta linguagem para syntax highlight no markdown
    EXT="${FILE##*.}"
    BASENAME=$(basename "$FILE")
    LANG=""
    case "$EXT" in
        tf)         LANG="hcl" ;;
        yaml|yml)   LANG="yaml" ;;
        json)       LANG="json" ;;
        sh)         LANG="bash" ;;
        py)         LANG="python" ;;
        md)         LANG="markdown" ;;
        properties) LANG="properties" ;;
        txt)        LANG="text" ;;
        *)
            case "$BASENAME" in
                Dockerfile) LANG="dockerfile" ;;
                Makefile)   LANG="makefile" ;;
                *)          LANG="text" ;;
            esac
        ;;
    esac

    echo "---" >> "$OUTPUT"
    echo "### $REL_PATH" >> "$OUTPUT"
    echo '```'"$LANG" >> "$OUTPUT"
    cat "$FILE" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    echo '```' >> "$OUTPUT"
    echo "" >> "$OUTPUT"

done

# --------------------------------------------------------------
# Rodapé
# --------------------------------------------------------------
TOTAL=$(grep -c "^### " "$OUTPUT" 2>/dev/null || echo "0")
echo "=================================================================" >> "$OUTPUT"
echo "  FIM DO DUMP — $TOTAL arquivos capturados" >> "$OUTPUT"
echo "=================================================================" >> "$OUTPUT"

echo "✅ Dump gerado: $OUTPUT"
echo "📁 Arquivos capturados: $TOTAL"
echo "📏 Tamanho: $(du -sh "$OUTPUT" | cut -f1)"

