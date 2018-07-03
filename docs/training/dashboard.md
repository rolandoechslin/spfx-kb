# Roles Dashboard

## Create new Project

- https://github.com/Microsoft/TypeScript-React-Starter

```
create-react-app role-office-ui-layout --scripts-version=react-scripts-ts
```

Of note:

- tsconfig.json contains TypeScript-specific options for our project.
- tslint.json stores the settings that our linter, TSLint, will use.
- package.json contains our dependencies, as well as some shortcuts for commands we'd like to run for testing, previewing, and deploying our app.
- public contains static assets like the HTML page we're planning to deploy to, or images. You can delete any file in this folder apart from index.html.
  src contains our TypeScript and CSS code. index.tsx is the entry-point for our file, and is mandatory.

## Start

yarn start
Starts the development server.

yarn build
Bundles the app into static files for production.

yarn test
Starts the test runner.

yarn eject
Removes this tool and copies build dependencies, configuration files
and scripts into the app directory. If you do this, you can’t go back!

## Install office-ui-fabric

- https://github.com/OfficeDev/office-ui-fabric-react
- https://github.com/OfficeDev/office-ui-fabric-react/blob/master/ghdocs/README.md
- https://developer.microsoft.com/en-us/fabric#/get-started

```
npm i office-ui-fabric-react --save
```
