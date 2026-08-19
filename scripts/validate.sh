#!/usr/bin/env bash
# Validacion basica de la estructura del proyecto.
# Si alguna verificacion falla, el script termina con codigo distinto de 0
# y el pipeline de CI se marca como fallido.

set -u

errores=0

requeridos=(
  "README.md"
  "app/hello.txt"
  ".github/workflows/pipeline.yml"
)

echo "== Verificando archivos requeridos =="
for archivo in "${requeridos[@]}"; do
  if [ -f "$archivo" ]; then
    echo "  OK       $archivo"
  else
    echo "  ERROR    Falta el archivo requerido: $archivo"
    errores=$((errores + 1))
  fi
done

echo "== Verificando contenido =="
if [ -s "app/hello.txt" ]; then
  echo "  OK       app/hello.txt no esta vacio"
else
  echo "  ERROR    app/hello.txt no existe o esta vacio"
  errores=$((errores + 1))
fi

if grep -q "# ci-cd-labs" README.md 2>/dev/null; then
  echo "  OK       README.md tiene el titulo del proyecto"
else
  echo "  ERROR    README.md no contiene el titulo '# ci-cd-labs'"
  errores=$((errores + 1))
fi

echo "================================================"
if [ "$errores" -gt 0 ]; then
  echo "VALIDACION FALLIDA: $errores error(es) encontrado(s)."
  exit 1
fi

echo "VALIDACION EXITOSA: la estructura del proyecto es correcta."
