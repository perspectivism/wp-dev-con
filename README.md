# Professional WordPress Development Containers

Develop modern WordPress websites, plugins, and themes while simultaneously debugging PHP, TypeScript, and ES6 using a single instance of VS Code all within a meticulously crafted Development Container.

## Table of Contents
* [Prerequisites](#prerequisites)
* [Configuration](#configuration)
* [Running the Code](#running-the-code)
* [Developing & Debugging Code](#developing--debugging-code)
* [Directory Structure](#directory-structure)
* [VS Code Extensions](#vs-code-extensions)
* [Containers](#containers)
* [Software Packages](#software-packages)

## Prerequisites
1. [Install: WSL (Windows Only)](https://learn.microsoft.com/en-us/windows/wsl/install)
2. [Install: Docker](https://www.docker.com)
3. [Install: VS Code](https://code.visualstudio.com)
4. [Install: Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
5. [Install: Google Chrome](https://www.google.com/chrome)

## Configuration
There are two `.env` files in this repo. Modify the [`.devcontainer/.env`](.devcontainer/.env) file to configure the website domain, MariaDB username/password, OpenLiteSpeed WebAdmin password, and WordPress-specific settings.

**Note:** The OpenLiteSpeed username defaults to **admin**

## Running the Code
Clone this repository:

```
git clone https://github.com/perspectivism/wp-dev-con.git
```

If running Windows, to [improve disk performance](https://code.visualstudio.com/remote/advancedcontainers/improve-performance) it's recommended to copy the repo into the WSL 2 filesystem. 

Next, open a terminal and `cd` into the root of the repo folder (which contains the `README.md` file), and run the below command to open the folder in VS Code:

```
code .
```

Use the **Dev Containers: Rebuild and Reopen in Container** command from the Command Palette (`F1, Ctrl+Shift+P`). If not present, start typing the phrase **Dev Containers: R** and it will appear.

This will build the container and reopen VS Code in the container. Once VS Code reopens it will take several minutes before the development container is ready for use as the operation involves fetching and building new images, pulling NPM packages, creating containers, and executing other necessary tasks.

When the containers are up and running the application can be accessed using the following default URLs (refer to [`docker-compose.yml`](.devcontainer/docker-compose.yml) to view all mapped ports):

|Application|URL|Description|
| :-------------: | :-------------: | :-------------: |
|WordPress|[http://localhost](http://localhost)|The WordPress website being developed
|phpMyAdmin|[http://localhost:8080](http://localhost:8080)|Used to administer MariaDB
|OLS WebAdmin|[https://localhost:7080](https://localhost:7080)|The OpenLiteSpeed WebAdmin console

**Note:** If this is the first time the containers are being started, there are background processes that continue installing software dependencies. Subsequent runs will be much faster. Refer to [Developing & Debugging Code](#developing--debugging-code) for more details. 

## Developing & Debugging Code
After the containers are created and running, it might still take a few more minutes before the application is ready and development & debugging may begin. This is because it is only after the containers are running that VS Code will begin installing the VS Code extensions (*see [here](#vs-code-extensions)*). In addition, the [`entrypoint.sh`](.devcontainer/entrypoint.sh) file will around this point begin installing WordPress. [Parcel](https://parceljs.org) will start watching and begin transpiling and bundling CSS, Sass, ES6, and TypeScript. To ensure that the code is ready to be developed & debugged, verify the following directories have been created inside the development container:

* Check WordPress core files exist:
    * `/var/www/vhosts/localhost/html`
* Check transpiled custom-plugin bundle exists:
    * `/var/www/vhosts/localhost/html/wp-content/plugins/custom-plugin/dist`
* Check transpiled custom-theme bundle exists:
    * `/var/www/vhosts/localhost/html/wp-content/themes/custom-theme/dist`

[ESLint](https://eslint.org), [Parcel](https://parceljs.org), [Prettier](https://prettier.io), [TailwindCSS](https://tailwindcss.com), and [VS Code](https://code.visualstudio.com) are fully configured in the project and are ready to use out of the box.

There are 3 debug configurations as seen in the [`launch.json`](.devcontainer/workspace-vscode/.vscode/launch.json) file:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003
    },
    {
      "name": "Launch Chrome",
      "request": "launch",
      "type": "chrome",
      "url": "http://${env:DOMAIN}",
      "webRoot": "${workspaceFolder}/${env:DOMAIN}/html"
    }
  ],
  "compounds": [
    {
      "name": "Debug PHP + JS",
      "configurations": ["Listen for Xdebug", "Launch Chrome"],
      "stopAll": true
    }
  ]
}
```
To start [debugging](https://code.visualstudio.com/docs/editor/debugging) the application, from the **Run and Debug** view select the `Debug PHP + JS` launch configuration to enable multi-target debugging and then click the play symbol. A Chrome browser window will open and the application is ready for debugging.

This project includes a WordPress [custom plugin](.devcontainer/workspace-wordpress/custom-plugin) and a WordPress [custom theme](.devcontainer/workspace-wordpress/custom-theme) as examples of how to integrate modern frontend frameworks and languages with WordPress. Set breakpoints within both frontend (*ex~* [`greet.ts`](.devcontainer/workspace-wordpress/custom-plugin/src/greet.ts)) and backend (*ex~* [`functions.php`](.devcontainer/workspace-wordpress/custom-theme/functions.php)) files and observe how the breakpoints are hit when code within these files are invoked.

Within this repository, three folders and their subfolders are bind mounted at various locations within the development container. The root of each of these three folders are: [`.devcontainer/workspace-ols`](.devcontainer/workspace-ols), [`.devcontainer/workspace-vscode`](.devcontainer/workspace-vscode), [`.devcontainer/workspace-wordpress`](.devcontainer/workspace-wordpress). The inclusion of these folders in the repository serves to group related locations effectively, while the utilization of bind mounts seamlessly maps their expected locations within the development container. Grouping the locations and then using bind mounts allows for organization and easy access to files that need to get checked into source control. For detailed information on the mount points, refer to the [`docker-compose.yml`](.devcontainer/docker-compose.yml) excerpt below:

```yaml
services:
  litespeed:
    volumes:
      - ./workspace-ols/acme:/root/.acme.sh
      - ./workspace-ols/logs:/usr/local/lsws/logs
      - ./workspace-ols/lsws/admin-conf:/usr/local/lsws/admin/conf      
      - ./workspace-ols/lsws/conf:/usr/local/lsws/conf
      - ./workspace-ols/sites/localhost/html:/var/www/vhosts/${DOMAIN}/html
      - ./workspace-ols/sites/localhost/logs:/var/www/vhosts/${DOMAIN}/logs
      - ./workspace-vscode:/var/www/vhosts
      - ./workspace-wordpress/custom-plugin:/var/www/vhosts/${DOMAIN}/html/wp-content/plugins/custom-plugin
      - ./workspace-wordpress/custom-theme:/var/www/vhosts/${DOMAIN}/html/wp-content/themes/custom-theme
  mysql:
    volumes:
      - ./workspace-ols/data/db:/var/lib/mysql:delegated
  redis:
    volumes:
      - ./workspace-ols/redis/data:/data
```

## Directory Structure
```text
.
├── .devcontainer
│   ├── .env
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   ├── entrypoint.sh
│   ├── wordpress-dev.Dockerfile
│   ├── wordpress-install.sh
│   ├── workspace-ols
│   │   └── .gitignore
│   ├── workspace-vscode
│   │   ├── .eslintignore
│   │   ├── .eslintrc.json
│   │   ├── .postcssrc
│   │   ├── .prettierignore
│   │   ├── .prettierrc
│   │   ├── .vscode
│   │   │   ├── launch.json
│   │   │   └── settings.json
│   │   ├── package-lock.json
│   │   ├── package.json
│   │   └── tailwind.config.js
│   └── workspace-wordpress
│       ├── custom-plugin
│       │   ├── custom-plugin.php
│       │   └── src
│       │       └── greet.ts
│       └── custom-theme
│           ├── functions.php
│           ├── index.php
│           ├── screenshot.png
│           ├── src
│           │   ├── index.css
│           │   └── index.js
│           └── style.css
├── .env
├── .gitattributes
├── .gitignore
├── LICENSE
├── NOTICE
└── README.md
```

## VS Code Extensions
The [`devcontainer.json`](.devcontainer/devcontainer.json) file lists the following VS Code extensions to install within the main development container:
|Extension|Description|
| :-------------: | :-------------: |
|[bmewburn.vscode-intelephense-client](https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client)|PHP code intelligence for Visual Studio Code
|[bradlc.vscode-tailwindcss](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)|Intelligent Tailwind CSS tooling for VS Code
|[esbenp.prettier-vscode](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)|Code formatter using prettier
|[dbaeumer.vscode-eslint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)|Integrates ESLint JavaScript into VS Code
|[xdebug.php-debug](https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug)|Debug support for PHP with Xdebug

## Containers
The [`docker-compose.yml`](.devcontainer/docker-compose.yml) contains configuration logic that runs four containers using the images:

|Image|Version|Description|
| :-------------: | :-------------: | :-------------: |
[OpenLiteSpeed](https://hub.docker.com/r/litespeedtech/openlitespeed)|1.7.x|The open source edition of LiteSpeed Web Server Enterprise
[MariaDB](https://hub.docker.com/_/mariadb)|10.5.x|A community-developed, commercially supported fork of MySQL
[phpMyAdmin](https://hub.docker.com/r/bitnami/phpmyadmin)|5.2.x|A free and open source administration tool for MySQL and MariaDB
[Redis](https://hub.docker.com/_/redis)|Latest|An open source, in-memory data structure store, used as a database, cache, and message broker

## Software Packages
The `OpenLiteSpeed` image is referenced in the [`wordpress-dev.Dockerfile`](.devcontainer/wordpress-dev.Dockerfile) which installs the following software in the main development container (Note: this list is not comprehensive, [WP CLI](https://wp-cli.org) for example has been excluded but is still installed):

|Software|Version|Description|
| :-------------: | :-------------: | :-------------: |
|[Ubuntu](https://hub.docker.com/_/ubuntu)|22.04|A Debian-derived Linux distribution known for its stability
|[LS PHP](http://rpms.litespeedtech.com/debian)|8.1|A PHP processing module tailored for compatibility with LiteSpeed Web Server
|[Xdebug](https://xdebug.org)|3.2.x|A PHP extension that provides a range of features to improve the PHP development experience
|[Node](https://nodejs.org)|Latest LTS|An open-source, cross-platform JavaScript runtime environment
|[WordPress](https://wordpress.com)|Latest|An open-source content management system (CMS) that enables the creation and management of websites and blogs with a user-friendly interface and extensive plugin ecosystem

To assist in development, the following Node packages as specified in the [`packages.json`](.devcontainer/workspace-vscode/package.json) file are installed:

|Package|Version|Description|
| :-------------: | :-------------: | :-------------: |
|[@prettier/plugin-php](https://www.npmjs.com/package/@prettier/plugin-php)|0.22.x|Adds support for the PHP language to Prettier
|[@typescript-eslint/eslint-plugin](https://www.npmjs.com/package/@typescript-eslint/eslint-plugin)|6.19.x|An ESLint plugin which provides lint rules for TypeScript codebases
|[@typescript-eslint/parser](https://www.npmjs.com/package/@typescript-eslint/parser)|6.19.x|An ESLint custom parser which leverages TypeScript ESTree
|[canvas-confetti](https://www.npmjs.com/package/canvas-confetti)|1.9.x|Component for drawing confetti on a canvas
|[eslint](https://www.npmjs.com/package/eslint)|8.56.x|A static code analysis tool for identifying problematic patterns found in JavaScript code
|[eslint-config-prettier](https://www.npmjs.com/package/eslint-config-prettier)|9.1.x|Turns off all rules that are unnecessary or might conflict with Prettier
|[parcel](https://www.npmjs.com/package/parcel)|2.11.x|A web application bundler, differentiated by its developer experience
|[postcss](https://www.npmjs.com/package/postcss)|8.4.x|A tool for transforming CSS with JavaScript
|[prettier](https://www.npmjs.com/package/prettier)|3.2.x|An opinionated code formatter
|[prettier-plugin-tailwindcss](https://www.npmjs.com/package/prettier-plugin-tailwindcss)|0.5.x|A Prettier plugin for sorting Tailwind CSS classes
|[tailwindcss](https://www.npmjs.com/package/tailwindcss)|3.4.x|A utility-first CSS framework
|[typescript](https://www.npmjs.com/package/typescript)|5.3.x|A statically-typed superset of JavaScript