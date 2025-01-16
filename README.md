# HLDS Docker Image
An Ubuntu-based Docker image with a pre-installed Half-Life Dedicated Server (HLDS) designed to host a
<br>`Counter-Strike 1.6` server.
<br>This image can be used as a standalone Counter-Strike 1.6 server or as a base image for other custom Docker images.

## Usage

### Clone the Repository
```bash
git clone https://github.com/hun1er/ubuntu-hlds.git
cd ubuntu-hlds
```

### Build the Docker Image
The image can be built using the provided `build.sh` script, either by specifying command-line arguments or using the interactive mode.

#### Command-Line Options
```bash
./build.sh [options]
```

| Option             | Description                                   | Default Value         |
|--------------------|-----------------------------------------------|-----------------------|
| `-t`, `--tag`      | Specify the custom tag for the Docker image.  | `hun1er/ubuntu-hlds`  |
| `-b`, `--build`    | Specify the HLDS build version.               | `8684`                |
| `-z`, `--timezone` | Specify the timezone for the server.          | `Europe/Kiev`         |
| `-h`, `--help`     | Show the help message and exit.               |                       |

#### Example Usage
1. Build the image with custom parameters:
   ```bash
   ./build.sh -t my-hlds-image -b 10211 -z Europe/Moscow
   ```
2. Use interactive mode:
   ```bash
   ./build.sh
   ```

### Available HLDS Builds
The following build versions are currently available:
- `8684`
- `10211`

## Environment Variables
The following environment variables are available during the build process:

| Variable      | Description                            | Default Value   |
|---------------|----------------------------------------|-----------------|
| `TZ`          | Timezone configuration for the server. | `Europe/Kiev`   |
| `LANG`        | System language and locale.            | `en_US.UTF-8`   |
| `HLDS_DIR`    | Directory where HLDS is installed.     | `/hlds`         |
| `HLDS_BUILD`  | HLDS build version to install.         | `8684`          |

### Run the Docker Container
After building the image, you can run it with the following command:

```bash
docker run --name hlds-server -d -p 27015:27015 -p 27015:27015/udp my-hlds-image
```

You can customize the parameters passed to `hlds_run` by appending them to the docker run command.
<br>For example:

```bash
docker run --name hlds-server -d -p 27015:27015 -p 27015:27015/udp my-hlds-image -game cstrike -maxplayers 16 +map cs_assault
```

Replace `my-hlds-image` with the tag used during the build process.
