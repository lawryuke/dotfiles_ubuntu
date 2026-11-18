# Neovim en Ubuntu GNOME/Wayland

Configuración migrada y comprobada el 6 de noviembre de 2026 con Neovim 0.12.6.
`~/.config/nvim` apunta a esta carpeta. El ejecutable actualizado está en
`~/.local/bin/nvim`; `/usr/bin/nvim` sigue siendo la versión 0.11.6 de Ubuntu.
Abre otra terminal o ejecuta `rehash` en Zsh si tu terminal recuerda la versión anterior.

## Qué incluye

- OneDark Vivid transparente, iconos, bufferline y pantalla de inicio.
- Neo-tree a la derecha, Telescope y búsqueda/reemplazo con Spectre.
- Autocompletado de LSP, snippets, rutas, buffers y línea de comandos con nvim-cmp.
- LSP con `vim.lsp.config` y Mason 2; sin el antiguo `require('lspconfig').setup`.
- Bash, Lua, CSS, C/C++, Python, JavaScript/TypeScript, HTML y JSON.
- Tree-sitter en la rama `main`, API nueva y resaltado nativo `vim.treesitter.start`.
- Formato con Conform: StyLua, Black, shfmt y Prettier. Sin formato automático al guardar.
- Comentarios nativos `gcc`/`gc`, sugerencias de atajos, multicursor y EasyMotion.
- Portapapeles Wayland con wl-clipboard.
- Notebooks Jupyter con ipynb.nvim y un entorno Python aislado para ejecutar celdas.

## Atajos principales

`leader` es Espacio. Se conservaron los movimientos y atajos personales del archivo original,
incluidos `f` para fin de línea y los borrados sin modificar el registro.

| Teclas | Acción |
|---|---|
| Espacio w / q | Guardar / cerrar ventana |
| Espacio b / e | Mostrar explorador / enfocarlo |
| Espacio nb | Explorador de buffers flotante |
| Espacio ff / fg / fr / fb | Archivos / texto / recientes / buffers |
| Tab / Shift+Tab (normal) | Buffer siguiente / anterior |
| Espacio x | Cerrar buffer |
| Espacio co, gcc o gc en selección | Comentar |
| Espacio gf | Formatear documento o selección |
| gd o Espacio gd / gD / gr | Definición / declaración / referencias |
| Espacio ca / rn | Acciones de código / renombrar símbolo |
| K | Documentación del símbolo |
| Espacio S / sw / sp | Spectre / palabra actual / archivo actual |
| Espacio ' | Alternar números relativos |
| F2 o Espacio 2 | Quitar resaltado de búsqueda |
| Espacio ? | Ver atajos |
| Ctrl+Espacio (insertar) | Abrir autocompletado |
| Tab / Shift+Tab (insertar) | Seleccionar sugerencia o recorrer snippet |
| Enter (insertar) | Aceptar sugerencia seleccionada |

Se cambió el antiguo Espacio f a Espacio e para evitar el conflicto con ff/fg/fr/fb.
Espacio gd usa LSP y dejó de tener dos definiciones distintas.

## Instalar o actualizar

En este equipo ya están instalados los plugins, ocho servidores, cuatro formateadores
y 18 parsers. Black se instala con `uv tool install black` porque el Python del sistema
no tiene ensurepip; el resto de herramientas se administra con Mason.

Dependencias: Neovim >=0.12, git, curl, tar, unzip, compilador C, tree-sitter-cli >=0.26.1,
Node.js/npm, Python, uv, ripgrep, fd y wl-clipboard. Aquí se instalaron en `~/.local/`
sin permisos de administrador. Para otra máquina Ubuntu, instala las dependencias con
su gestor de paquetes y comprueba las versiones mínimas de Neovim y tree-sitter.
No ejecutes `dotfiles/setup`: sigue siendo el instalador de Arch y también modifica servicios.

```sh
nvim --headless '+Lazy! restore' +qa
nvim --headless '+lua dofile(vim.fn.stdpath("config") .. "/scripts/install.lua")' +qa
nvim --headless '+lua dofile(vim.fn.stdpath("config") .. "/scripts/verify.lua")' +qa!
```

- `:Lazy`: plugins; `:Lazy restore`: versiones de `lazy-lock.json`.
- `:Lazy update`: actualizar plugins y guardar nuevas versiones en el lockfile.
- `:Mason`: instalar/actualizar servidores y formateadores.
- `:TSUpdate`: actualizar los parsers después de cambiar Tree-sitter.
- `:TSInstall nombre`: instalar otro parser. No se compila nada en cada arranque.
- `:ConformInfo`: comprobar formateadores.
- `:checkhealth`: diagnóstico. Avisos de Go/Rust/Ruby/Java, pip y proveedores remotos
  opcionales no impiden usar los lenguajes configurados. No se instalaron toolchains ajenos.

`lua/config/` contiene opciones, atajos y bootstrap; `lua/plugins/` agrupa editor,
autocompletado, LSP/formato y Tree-sitter. El lockfile fija los commits de los plugins.

## Eigen en C++

Eigen del repositorio local (5.0.1-dev+master, commit `ceacb22ee3fa469e92718d2cb15499677ddc5704`)
está instalado en `~/.local/include/eigen3`. La configuración de usuario
`~/.config/clangd/config.yaml` añade esa ruta a clangd, tanto para archivos sueltos
como para proyectos con `compile_commands.json`. Funciona con el LSP y el
autocompletado ya configurados en Neovim; no cambia las opciones de CUDA.

Usa `#include <Eigen/Dense>`. Para compilar desde la terminal:

```sh
g++ -std=c++14 -O2 -I"$HOME/.local/include/eigen3" main.cpp -o ejemplo
```

Para proyectos CMake, usa `find_package(Eigen3 REQUIRED NO_MODULE)` y
`target_link_libraries(tu_programa PRIVATE Eigen3::Eigen)`. Configura con
`cmake -S . -B build -DCMAKE_PREFIX_PATH="$HOME/.local" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`.
La configuración de clangd ayuda al editor; el compilador necesita su propia ruta
mediante `-I` o el target de CMake.

## MPI en C/C++

Open MPI está instalado en el sistema. `~/.config/clangd/config.yaml` añade
las rutas que muestra `mpicc --showme:compile` para que clangd encuentre `mpi.h`,
tanto en archivos sueltos como en proyectos con `compile_commands.json`.
Si cambias la instalación de MPI, actualiza esas rutas.

Para compilar y enlazar, usa `mpicc main.c -o ejemplo` o
`mpicxx main.cpp -o ejemplo`. En CMake, usa `find_package(MPI REQUIRED)` y
enlaza el target con `MPI::MPI_C` o `MPI::MPI_CXX`, según el lenguaje.

## Notebooks Jupyter

[ipynb.nvim](https://github.com/ajbucci/ipynb.nvim) se carga al iniciar Neovim para
interceptar la lectura y escritura de `.ipynb`. `scripts/install.lua` instala
`jupyter-client`, `ipykernel` y el parser `ipynb`. El entorno Python queda en
`~/.local/share/nvim/ipynb-venv`, separado del Python del sistema.

- Abre `nvim archivo.ipynb` o crea uno con `:NotebookCreate archivo.ipynb`.
- `i` o Enter: editar celda; Esc: volver al notebook; `]]` / `[[`: siguiente / anterior.
- Espacio ks: iniciar kernel; Espacio kx: ejecutar celda; Espacio ko: ver salida.
- Espacio kb / ka: añadir celda debajo / encima; Espacio km / ky: Markdown / código.
- `:w`: guardar; `:checkhealth ipynb`: comprobar la instalación.
- Para usar dependencias de un proyecto, instala `jupyter-client` e `ipykernel` en
  su entorno y ejecuta `:NotebookKernelStart /ruta/al/proyecto/.venv/bin/python`.

Las imágenes inline requieren la dependencia opcional snacks.nvim y un terminal
compatible con el protocolo gráfico de Kitty; esta configuración muestra las salidas de texto.

## Verificación

`scripts/verify.lua` crea un proyecto temporal y comprueba la conexión de los ocho LSP,
resaltado de Tree-sitter, formateadores, carga de autocompletado, Neo-tree y Telescope.
La prueba de integración pasó; los chequeos de los componentes configurados no mostraron
errores ni llamadas obsoletas. También se comprobó el arranque interactivo del dashboard.
No modifica proyectos del usuario. No comprueba todas las acciones interactivas del editor.

## Restaurar la configuración anterior

La copia original completa está en:
`~/.config/nvim-backups/20261106-161816/`.
Para restaurarla de forma completa, reemplaza el enlace `~/.config/nvim` por una copia de
esa carpeta y restaura su propio lockfile. Mantén una copia de la configuración nueva.

## Documentación consultada

- https://github.com/neovim/neovim/releases/tag/v0.12.6
- https://neovim.io/doc/user/lsp.html
- https://github.com/neovim/nvim-lspconfig#configuration
- https://github.com/nvim-treesitter/nvim-treesitter/tree/main#setup
- https://github.com/mason-org/mason-lspconfig.nvim
- https://github.com/stevearc/conform.nvim
