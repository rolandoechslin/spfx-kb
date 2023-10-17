# Typescript

## Reference

- [TypeScript Cheatsheet](https://github.com/rmolinamir/typescript-cheatsheet)
- [Learn X in Y minutes](https://learnxinyminutes.com/docs/typescript/)
- [TypeScript Handbook](http://www.typescriptlang.org/docs/handbook/basic-types.html)
- [Why TypeScript](https://basarat.gitbooks.io/typescript/content/docs/why-typescript.html)
- [pluralsight typescript course](https://app.pluralsight.com/player?course=typescript&author=dan-wahlin&name=typescript-m1&clip=4&mode=live)
- https://github.com/Microsoft/TypeScript/wiki
- https://github.com/basarat/typescript-book
- https://basarat.gitbooks.io/typescript/content/docs/getting-started.html
- https://www.gitbook.com/book/basarat/typescript/details
- https://codewich.com/
- https://github.com/lakshaydulani/typescript-summary
- https://github.com/netdur/typescript-design-patterns
- [clean-code-typescript](https://github.com/labs42io/clean-code-typescript)

## Typescript Version for SPFx

- [Use Different Versions of TypeScript in SPFx projects](https://www.voitanos.io/blog/use-different-typescript-versions-in-sharepoint-framework-projects/)

## Tutorial

- http://dotnetdetail.com/learn-typescript-from-basic/
- http://dotnetdetail.com/learn-typescript-step-by-step-with-suitable-example/

## Library

- https://github.com/alexjoverm/typescript-library-starter

## Typings

- https://github.com/cashfarm/autotypes

## Code Snippets

### isEmptyString

```ts
/**
    * Check if the value is null, undefined or empty
    *
    * @param value
    */
private _isEmptyString(value: string): boolean {
    return value === null || typeof value === "undefined" || !value.length;
}

```

### _isNull

```ts
/**
    * Check if the value is null or undefined
    *
    * @param value
    */
private _isNull(value: any): boolean {
    return value === null || typeof value === "undefined";
}
```


