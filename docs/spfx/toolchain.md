# Toolchain

## Overview

- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/sharepoint-framework-toolchain>
- <https://github.com/SharePoint/sp-dev-docs/blob/master/docs/spfx/tools-and-libraries.md>

## Webpack

- [webpack-basics-part-1](https://medium.com/@baranovskyyoleg/webpack-basics-part-1-fcecae438ebe)
- [getting-up-to-speed-with-webpack](https://www.eliostruyf.com/getting-up-to-speed-with-webpack)

## Prepare

- [Preparing development machine for client-side SharePoint projects](https://www.linkedin.com/pulse/preparing-development-machine-client-side-sharepoint-mac-koltyakov)

## Gulp

- [Getting up to speed with Gulp](https://www.eliostruyf.com/getting-up-to-speed-with-gulp)
- [Gulp: Basics](https://medium.com/@baranovskyyoleg/gulp-basic-usage-7afc460119f0)
- [SPFx Automatically Generating Revision Numbers](https://thomasdaly.net/2018/08/12/spfx-automatically-generating-revision-numbers)
- [SPFx Automatically Generating Revision Numbers + Versioning](https://thomasdaly.net/2018/08/21/update-spfx-automatically-generating-revision-numbers-versioning)
- [One command to create a clean solution package](https://n8d.at/blog/gulp-dist-in-spfx-one-command-to-create-a-clean-solution-package/)

### gulp dist

- [One command to create a clean solution package](https://n8d.at/blog/gulp-dist-in-spfx-one-command-to-create-a-clean-solution-package)

install npm package

```powershell
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

```powershell
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

```powershell
npm list -g --depth 0
```

List detail global npm  package versions from one package

```powershell
npm view @microsoft/generator-sharepoint
```

## PNPM

- <https://www.voitanos.io/blog/npm-yarn-pnpm-which-package-manager-should-you-use-for-sharepoint-framework-projects>
- <https://github.com/pnpm/pnpm>

## Package.json

- [https://docs.npmjs.com/files/package.json](https://docs.npmjs.com/files/package.json)

## Security

- [have-you-ever-thought-about-checking-your-dependency-for-vulnerabilities](https://www.eliostruyf.com/have-you-ever-thought-about-checking-your-dependency-for-vulnerabilities/)

## Installation

- [getting-up-to-speed-with-node-js-and-npm](https://www.eliostruyf.com/getting-up-to-speed-with-node-js-and-npm)

## Update SPFx version

- go into solution folder
- search für "@micorosoft/sp-"
- update all package (latest or version)

```powershell
npm outdated
```

```powershell
npm install package-name@latest --save
```

```powershell
npm install package-name@version --save
```

```powershell
gulp clean
```

```powershell
gulp build
```

## Test

```powershell
gulp serve --nobrowser
```

## Tips

- <https://pdemro.com/improve-sharepoint-framework-build-times-by-hacking-gulp-and-webpack>
- <https://github.com/pdemro/spfx-gulpfile-hack>



## Depoyment

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
