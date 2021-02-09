# Toolchain

## Overview

- [SharePoint Framework toolchain](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/sharepoint-framework-toolchain)
- [SharePoint Framework development tools and libraries](https://github.com/SharePoint/sp-dev-docs/blob/master/docs/spfx/tools-and-libraries.md)

## From classic to nodern

- [Conquer your dev toolchain in 'Classic' SharePoint – Part 1](https://julieturner.net/2018/01/conquer-your-dev-toolchain-in-classic-sharepoint-part-1/)
- [Conquer your dev toolchain in 'Classic' SharePoint – Part 2](https://julieturner.net/2018/01/conquer-your-dev-toolchain-in-classic-sharepoint-part-2/)
- [Conquer your dev toolchain in 'Classic' SharePoint – Part 3](https://julieturner.net/2018/01/conquer-your-dev-toolchain-in-classic-sharepoint-part-3/)
- [Conquer your dev toolchain in 'Classic' SharePoint – Part 4](https://julieturner.net/2018/01/conquer-your-dev-toolchain-in-classic-sharepoint-part-4/)

## Webpack

- [webpack-basics-part-1](https://medium.com/@baranovskyyoleg/webpack-basics-part-1-fcecae438ebe)
- [getting-up-to-speed-with-webpack](https://www.eliostruyf.com/getting-up-to-speed-with-webpack)
- ([Update the Webpack Config](https://www.andrewconnell.com/blog/leverage-webpack-define-plugin-spfx/)

## Prepare

- [Preparing development machine for client-side SharePoint projects](https://www.linkedin.com/pulse/preparing-development-machine-client-side-sharepoint-mac-koltyakov)

## Commands

- [SPFx Commands Cheat Sheet](https://www.c-sharpcorner.com/article/spfx-commands-cheat-sheet/)

## Gulp

- [Getting up to speed with Gulp](https://www.eliostruyf.com/getting-up-to-speed-with-gulp)
- [Gulp: Basics](https://medium.com/@baranovskyyoleg/gulp-basic-usage-7afc460119f0)
- [SPFx Automatically Generating Revision Numbers](https://thomasdaly.net/2018/08/12/spfx-automatically-generating-revision-numbers)
- [SPFx Automatically Generating Revision Numbers + Versioning](https://thomasdaly.net/2018/08/21/update-spfx-automatically-generating-revision-numbers-versioning)
- [One command to create a clean solution package](https://n8d.at/blog/gulp-dist-in-spfx-one-command-to-create-a-clean-solution-package/)

### gulp dist

- [One command to create a clean solution package](https://n8d.at/blog/gulp-dist-in-spfx-one-command-to-create-a-clean-solution-package)

install npm package

```bash
npm install gulp-sequence --save-dev
```

add to gulpfile.js

```ts
if (process.argv.indexOf('dist') !== -1){
  process.argv.push('--ship');
}

const gulpSequence = require('gulp-sequence');

gulp.task('dist', gulpSequence('clean', 'bundle', 'package-solution'));
```

### Deployment

- <https://github.com/estruyf/UploadToOffice365SPFx/blob/master/gulpfile.js>
- <https://github.com/estruyf/gulp-spsync-creds>
- <https://n8d.at/blog/how-to-version-new-sharepoint-framework-projects/?platform=hootsuite>

## NPM

### package-lock.json

- <https://medium.com/coinmonks/everything-you-wanted-to-know-about-package-lock-json-b81911aa8ab8>

### Optimization packages

- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/optimize-builds-for-production>
- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/optimize-builds-for-production>
- https://rencore.com/sharepoint-framework/script-check/
- <https://www.techmikael.com/2018/08/an-adventure-into-optimizing-sharepoint.html>

### Update packages

- https://gist.github.com/iki/ec32bfdeeb23930efd15

```bash
# check
npm outdated -g

# install
npm -g i npm-check

# interactive update of global packages
npm-check -u -g

# interactive update for a project you are working on
npm-check -u

# unistall package
npm uninstall -g <module>
```

### Check package version

- https://github.com/dylang/npm-check

List global npm  packages versions

```bash
npm list -g --depth 0
```

List detail global npm  package versions from one package

```bash
npm view @microsoft/generator-sharepoint
```

## PNPM

- <https://www.voitanos.io/blog/npm-yarn-pnpm-which-package-manager-should-you-use-for-sharepoint-framework-projects>
- <https://github.com/pnpm/pnpm>

## Package.json

- [https://docs.npmjs.com/files/package.json](https://docs.npmjs.com/files/package.json)

## Security

- [have-you-ever-thought-about-checking-your-dependency-for-vulnerabilities](https://www.eliostruyf.com/have-you-ever-thought-about-checking-your-dependency-for-vulnerabilities/)
- [5 ways to manage and monitor your digital workplace](https://www.valointranet.com/blog/5-ways-to-manage-and-monitor-your-digital-workplace/)

## Installation

- [getting-up-to-speed-with-node-js-and-npm](https://www.eliostruyf.com/getting-up-to-speed-with-node-js-and-npm)

## Update SPFx version

- go into solution folder
- search für "@micorosoft/sp-"
- update all package (latest or version)

```bash
npm outdated
```

```bash
npm install package-name@latest --save
```

```bash
npm install package-name@version --save
```

```bash
gulp clean
```

```bash
gulp build
```

## Test

```bash
gulp serve --nobrowser
```

## Tips

- <https://pdemro.com/improve-sharepoint-framework-build-times-by-hacking-gulp-and-webpack>
- <https://github.com/pdemro/spfx-gulpfile-hack>

## Deployment

```bash
npm i
gulp clean
gulp build
gulp --ship
gulp package-solution --ship
```

## Dependencies

- <https://docs.npmjs.com/cli/install>

```bash
npm install saves any specified packages into dependencies by default. Additionally, you can control where and how they get saved with some additional flags:

-P, --save-prod: Package will appear in your dependencies. This is the default unless -D or -O are present.

-D, --save-dev: Package will appear in your devDependencies.

-O, --save-optional: Package will appear in your optionalDependencies.
```

## Version Manger (nvm, npx)

- [How to install Node.js on Windows](https://channel9.msdn.com/Series/Beginners-Series-to-NodeJS/How-to-install-Nodejs-on-Windows-3-of-26)
- [Node Version Manager (nvm) for Windows](https://github.com/coreybutler/nvm-windows)
- [Use SPFx and NVM in an easy way with PowerShell](https://jonasbjerke.wordpress.com/2019/01/09/use-spfx-and-nvm-in-an-easy-way-with-powershell/)
- [How to use specific NodeJS version with your SPFx project](https://n8d.at/blog/how-to-use-specific-nodejs-version-with-your-spfx-project)
- [Better Node.js Install Management with Node Version Manager](https://www.andrewconnell.com/blog/better-node-js-install-management-with-node-version-manager)

```bash
nvm install 10.22.1
nvm install 8.17.0
nvm list

nvm use 10.22.1

# for spfx deployment

npm i -g gulp
npm i -g yo
npm i -g @microsoft/generator-sharepoint
gulp trust-dev-cert

# for spfx advanced
npm i -g @pnp/office365-cli
npm i -g spfx-fast-serve
npm i -g @pnp/generator-spfx
npm i -g npm-check
```
