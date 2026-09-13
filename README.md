# GravitLauncher Pterodactyl Egg

Pterodactyl Egg и Docker-образ для запуска
[GravitLauncher](https://github.com/GravitLauncher/Launcher) LaunchServer.

Проект использует официальные релизные файлы GravitLauncher и собственный
Docker-образ с полноценным JDK 25, адаптированный под Pterodactyl.

## Docker-образ

```text
ghcr.io/saythe0/gravitlauncher-pterodactyl:java25
```

Образ основан на:

```text
azul/zulu-openjdk-debian:25-latest
```

Внутри установлены:

- JDK 25
- OpenJFX 25 jmods
- `javac`
- `jlink`
- `jpackage`
- `osslsigncode`
- `rsync`
- `socat`
- `git`
- `curl`
- `wget`
- `unzip`
- пользователь `container`, совместимый с Pterodactyl
- рабочая директория `/home/container`
- стандартный Pterodactyl Java entrypoint

Сам GravitLauncher в Docker-образ не встроен.

Он скачивается отдельно через installation script внутри Egg.

## Pterodactyl Egg

Для импорта используется файл:

```text
egg-gravit-launchserver.json
```

Импортировать его нужно через:

```text
Admin Panel
→ Nests
→ Import Egg
```

Egg использует Docker-образ:

```text
ghcr.io/saythe0/gravitlauncher-pterodactyl:java25
```

и скачивает официальный релиз GravitLauncher с GitHub:

```text
https://github.com/GravitLauncher/Launcher/releases
```

## Версия GravitLauncher по умолчанию

```text
5.7.12
```

Версию можно изменить через переменную Pterodactyl:

```text
GRAVIT_VERSION
```

Версия указывается без префикса `v`.

Например:

```text
5.7.12
```

После изменения версии нужно выполнить переустановку сервера через Pterodactyl,
чтобы были загружены файлы новой версии LaunchServer.

Существующие конфигурационные файлы LaunchServer installation script специально не удаляет.

## Переменные Egg

### `GRAVIT_VERSION`

Версия GravitLauncher, которая будет установлена.

По умолчанию:

```text
5.7.12
```

### `ADDRESS`

Внешний адрес LaunchServer.

По умолчанию:

```text
https://launcher.example.com
```

Добавлять `/api` вручную не нужно.

При первой генерации `LaunchServer.json` LaunchServer сам формирует API и URL
загрузки на основе этого адреса.

### `PROJECTNAME`

Название проекта GravitLauncher.

По умолчанию:

```text
Example
```

Переменные `ADDRESS` и `PROJECTNAME` используются при первой генерации
`LaunchServer.json`.

Если `LaunchServer.json` уже существует, изменение этих переменных не
перезапишет его автоматически.

## Порт

Egg автоматически передаёт основной allocation Pterodactyl в LaunchServer:

```text
LISTEN_PORT={{SERVER_PORT}}
```

Стандартный порт GravitLauncher:

```text
9274
```

Для текущего проекта предполагается allocation:

```text
9274/tcp
```

## Команда запуска

```bash
LISTEN_PORT={{SERVER_PORT}} ./bin/launchserver
```

## Команда остановки

```text
stop
```

## Reverse proxy

Egg запускает только сам LaunchServer.

HTTPS, публичный домен и reverse proxy должны настраиваться отдельно через nginx
или другой reverse proxy.

Пример схемы:

```text
Интернет
   ↓
https://launcher.example.com
   ↓
nginx :443
   ↓
GravitLauncher LaunchServer :9274
```

Статические файлы лаунчера и обновлений также могут раздаваться через nginx
в зависимости от конфигурации GravitLauncher.

Для текущего проекта предполагается:

```text
https://launcher.example.com
```

## Локальная сборка Docker-образа

```bash
docker build \
  --platform linux/amd64 \
  -t gravitlauncher-pterodactyl:java25 .
```

Проверка Java:

```bash
docker run --rm \
  --entrypoint sh \
  gravitlauncher-pterodactyl:java25 \
  -c "java -version; javac -version; jlink --version; jpackage --version"
```

Проверка JavaFX:

```bash
docker run --rm \
  --entrypoint sh \
  gravitlauncher-pterodactyl:java25 \
  -c "test -f /usr/lib/jvm/zulu25/jmods/javafx.controls.jmod && echo JavaFX_OK"
```

## GHCR

GitHub Actions автоматически собирает и публикует Docker-образ:

```text
ghcr.io/saythe0/gravitlauncher-pterodactyl:java25
ghcr.io/saythe0/gravitlauncher-pterodactyl:latest
```

при каждом push в:

```text
main
```

## Структура проекта

```text
gravitlauncher-pterodactyl-egg/
├── .github/
│   └── workflows/
│       └── docker.yml
├── Dockerfile
├── egg-gravit-launchserver.json
└── README.md
```

## Обновление Docker-образа

После изменения `Dockerfile`:

```bash
git add Dockerfile
git commit -m "Update Docker image"
git push
```

GitHub Actions автоматически пересоберёт и отправит новую версию образа в GHCR.

На Pterodactyl Node после этого можно обновить образ командой:

```bash
docker pull ghcr.io/saythe0/gravitlauncher-pterodactyl:java25
```

## Обновление GravitLauncher

Для обновления GravitLauncher не требуется пересобирать Docker-образ.

Достаточно изменить:

```text
GRAVIT_VERSION
```

например:

```text
5.7.12
```

на новую стабильную версию и выполнить reinstall сервера через Pterodactyl.

Installation script скачает:

```text
https://github.com/GravitLauncher/Launcher/releases/download/v<VERSION>/LaunchServerBuild.zip
```

## Используемые проекты

GravitLauncher:

```text
https://github.com/GravitLauncher/Launcher
```

Документация GravitLauncher:

```text
https://gravitlauncher.com/
```

Pterodactyl:

```text
https://pterodactyl.io/
```

Pterodactyl Yolks:

```text
https://github.com/pterodactyl/yolks
```

## Лицензии

Этот репозиторий содержит только конфигурацию интеграции GravitLauncher с
Pterodactyl, Dockerfile и Egg.

GravitLauncher, Pterodactyl, Azul Zulu и остальные используемые компоненты
распространяются на условиях своих собственных лицензий.