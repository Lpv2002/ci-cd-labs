# ci-cd-labs

Repositorio de laboratorios del **Módulo 4 — Integración y Entrega Continua**.

## Laboratorio 1 — Primer Pipeline de Integración Continua

Pipeline básico de CI construido con **GitHub Actions** mediante *Pipeline as Code*.

El pipeline se ejecuta automáticamente después de cada `push` y realiza lo siguiente:

- Muestra un mensaje de bienvenida.
- Muestra la fecha y hora de ejecución.
- Muestra la versión de Git instalada en el runner.
- Finaliza correctamente.

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
