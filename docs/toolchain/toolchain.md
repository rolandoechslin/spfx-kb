# Toolchain

## Overview

- https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/sharepoint-framework-toolchain

## Gulp

- https://www.eliostruyf.com/getting-up-to-speed-with-gulp/
- https://medium.com/@baranovskyyoleg/gulp-basic-usage-7afc460119f0

### Deployment

- https://github.com/estruyf/UploadToOffice365SPFx/blob/master/gulpfile.js
- https://github.com/estruyf/gulp-spsync-creds


## NPM

### Optimization packages

- https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/optimize-builds-for-production
- https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/optimize-builds-for-production
- https://rencore.com/sharepoint-framework/script-check/

### Update packages

- https://gist.github.com/iki/ec32bfdeeb23930efd15

```PS
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

```PS
npm list -g --depth 0
```

List detail global npm  package versions from one package

```PS
npm view @microsoft/generator-sharepoint
```

### Update SPFx Framework

- https://joelfmrodrigues.wordpress.com/2018/03/02/sharepoint-framework-checklist/

```PS
# go into solution folder
npm outdated
# search für "@micorosoft/sp-"
# update all
npm install package-name@version --save
# or
npm install package-name@latest --save
gulp clean
gulp build
```