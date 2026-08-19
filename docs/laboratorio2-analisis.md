# Laboratorio 2 — Branching, Pull Requests y Ejecución de CI

**Repositorio:** https://github.com/Lpv2002/ci-cd-labs
**Rama principal:** `main`
**Plataforma de CI:** GitHub Actions (`.github/workflows/pipeline.yml`)

---

## Parte 1. Análisis del repositorio

> **¿Qué evento provoca actualmente la ejecución del pipeline?**

En el Laboratorio 1 el pipeline estaba configurado con `on: push`, es decir, **cualquier
push a cualquier rama** del repositorio disparaba la ejecución. No existía relación entre la
ejecución y el proceso de revisión de código.

En el Laboratorio 2 el disparador evolucionó a:

```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
```

Ahora el pipeline se ejecuta en dos momentos: cuando se **abre o actualiza un Pull Request
hacia `main`** (validación previa a la integración) y cuando un cambio **ya integrado llega a
`main`** (validación de la rama principal).

---

## Parte 6. Análisis del flujo

```text
Developer → Feature Branch → Commit → Push → CI Pipeline
          → Pull Request → Review → Merge → main
```

### 1. ¿Por qué es conveniente trabajar en una rama independiente?

Porque **aísla el trabajo en progreso de la versión estable del proyecto**. La rama de
funcionalidad actúa como un espacio de trabajo propio donde se puede commitear código
incompleto, experimentar y equivocarse sin afectar a `main` ni al resto del equipo. Esto
permite además que varias personas trabajen en paralelo sobre distintas funcionalidades,
que el historial quede agrupado por unidad de cambio (facilitando revertir una funcionalidad
completa) y que `main` se mantenga siempre en un estado desplegable.

### 2. ¿Qué ventaja proporciona realizar el Pull Request antes del merge?

El Pull Request convierte la integración en un **punto de control explícito y auditable**. Sus
ventajas concretas son:

- Introduce **revisión humana** del cambio antes de que llegue a la rama principal.
- Ofrece un **espacio de discusión** ligado a líneas de código concretas.
- Ejecuta automáticamente las **validaciones de CI** sobre el resultado de la fusión, de modo
  que se conoce el efecto del cambio *antes* de aplicarlo.
- Deja **trazabilidad**: quién propuso el cambio, quién lo aprobó, qué validaciones pasaron y
  por qué se integró.
- Permite **bloquear la integración** cuando no se cumplen las reglas definidas por la
  organización (checks en verde, aprobaciones, etc.).

### 3. ¿En qué momento se ejecutó el pipeline?

Se ejecutó en tres momentos observables durante el laboratorio:

1. **Al hacer `git push` de la rama de funcionalidad** (evento `push`, configuración original
   del Laboratorio 1).
2. **Al abrir el Pull Request y en cada nuevo commit enviado a esa rama** (evento
   `pull_request`, tipos `opened` y `synchronize`). Es la ejecución que decide si el PR puede
   integrarse.
3. **Al completar el merge hacia `main`** (evento `push` sobre `main`), validando el estado
   final de la rama principal.

### 4. ¿Qué ocurriría si el pipeline fallara?

El job termina con un código de salida distinto de cero, GitHub marca la ejecución con un
check rojo y ese estado se refleja en el Pull Request. Con la protección de `main`
configurada (Parte 7), el botón *Merge* queda **deshabilitado**: el cambio no puede
integrarse hasta corregir el problema. El autor debe revisar los logs del job, identificar el
paso que falló, corregir el código y hacer un nuevo push; ese push vuelve a disparar el
pipeline y, si todas las validaciones pasan, el merge se habilita nuevamente. Sin protección
de rama, el fallo sería únicamente informativo y el merge podría hacerse igual, que es
justamente lo que las reglas buscan impedir.

### 5. ¿Qué diferencia existe entre revisar código manualmente y validarlo mediante CI?

| Aspecto | Revisión manual (code review) | Validación mediante CI |
|---|---|---|
| Ejecutor | Una persona del equipo | Un runner automatizado |
| Qué evalúa | Diseño, legibilidad, decisiones, reglas de negocio, seguridad conceptual | Criterios objetivos y repetibles: compilación, pruebas, formato, estructura, vulnerabilidades conocidas |
| Consistencia | Varía según la persona, el cansancio o el tiempo disponible | Idéntica en cada ejecución |
| Velocidad | Minutos u horas; depende de la disponibilidad | Segundos o minutos, automática |
| Escalabilidad | Limitada | Alta; se ejecuta en cada commit sin costo humano |
| Limitación | No detecta de forma fiable errores mecánicos ni regresiones | No entiende la intención ni juzga si la solución es la adecuada |

**No son alternativas, sino complementos.** La CI se encarga de lo que una máquina verifica
mejor (que el código compile, que las pruebas pasen, que la estructura sea válida) y libera al
revisor humano para concentrarse en lo que sólo una persona puede evaluar: si el cambio
resuelve el problema correcto y de la manera adecuada.

---

## Parte 7. Protección de la rama principal

Reglas configuradas sobre `main` en **Settings → Branches → Branch protection rules**:

| Regla | Estado |
|---|---|
| Require a pull request before merging | Activada |
| Require status checks to pass before merging | Activada (`Hello CI`, `Validacion del proyecto`) |
| Require branches to be up to date before merging | Activada |
| Bloquear push directo a `main` | Consecuencia de exigir Pull Request |

**Efecto observado:** un `git push` directo a `main` es rechazado por el servidor con el
mensaje `protected branch hook declined`, y un Pull Request con el pipeline en rojo muestra
el botón de merge bloqueado.

*(Adjuntar captura de la pantalla de reglas de protección y del push rechazado.)*

---

## Parte 8. Experimentación: fallo deliberado del pipeline

**Rama:** `feature/12347_fallo-intencional`

**Cambio que provoca el fallo:** el archivo `app/hello.txt` fue renombrado a
`app/saludo.txt`, simulando una reorganización de archivos hecha sin actualizar el resto del
proyecto. El job `Validacion del proyecto` ejecuta `scripts/validate.sh`, que exige la
presencia de los archivos requeridos.

**Resultado observado:**

- Job `Validacion del proyecto`: **fallido** (exit code 1).
- Mensaje de error en los logs:
  `ERROR    Falta el archivo requerido: app/hello.txt`
  `VALIDACION FALLIDA: 1 error(es) encontrado(s).`
- Estado del Pull Request: *"Some checks were not successful"*, botón **Merge bloqueado** por
  la regla de status checks obligatorios.

**Corrección:** se restauró el nombre original del archivo (`app/hello.txt`) y se envió un
nuevo commit a la misma rama. El evento `pull_request: synchronize` volvió a disparar el
pipeline, todos los checks quedaron en verde y el botón de merge se habilitó, permitiendo
integrar el cambio a `main`.

**Conclusión:** la protección de rama es lo que convierte al pipeline en un control real. Sin
ella, el resultado del pipeline es sólo información; con ella, es una condición obligatoria
para que el código entre a la rama principal.

*(Adjuntar captura de la ejecución fallida, del PR bloqueado y de la ejecución corregida.)*
