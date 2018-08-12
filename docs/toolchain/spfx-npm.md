# NPM

## PNPM

- https://www.voitanos.io/blog/npm-yarn-pnpm-which-package-manager-should-you-use-for-sharepoint-framework-projects

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

```
npm outdated
```

```
npm install package-name@latest --save
```

```
npm install package-name@version --save
```

```
gulp clean
```

```
gulp build
```

## Test

```bash
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