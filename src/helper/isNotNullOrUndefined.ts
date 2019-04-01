export function isNotNullOrUndefined<T>(a: null | undefined | T): a is T {
    return a != null;
}