# ci-cd-labs

Repositorio de laboratorios del **Módulo 4 — Integración y Entrega Continua**.

# Instrucciones para crear un nuevo branch

La rama debe crearse a partir de `main`.

Ejemplo:

```bash
git switch main
git pull
git switch -c feature/update-readme

# Usando git checkout
git checkout -b feature/12345_update_readme
git push -u origin feature/12345_update_readme

```

### Estructura del repositorio

```
ci-cd-labs/
│
├── .github/
│   └── workflows/
│       └── pipeline.yml
├── README.md
└── app/
    └── hello.txt
```

### Cómo ver la ejecución

Pestaña **Actions** del repositorio → workflow *Primer Pipeline CI*.
