# Errors and Cancellation

Failures are typed and cancellation is cooperative.

## Stable errors

All public errors are ``LexlightError`` values:

- `resourceMissing`
- `engineInitializationFailed`
- `runtimeUnavailable`
- `scriptEvaluationFailed`
- `decodingFailed`
- `serializationFailed`
- `invalidTheme`
- `cancelled`

```swift
do {
    let result = try await highlighter.tokenize(code, language: .swift)
    render(result)
} catch let error as LexlightError {
    report(error)
} catch {
    report(error)
}
```

## Cancel stale work

Wrap requests in a Swift `Task` and cancel it when the source or selected
language changes.

```swift
let task = Task {
    try await highlighter.tokenize(source, language: language)
}

// On the next edit:
task.cancel()
```

The actor checks cancellation before starting engine work and again before
returning a result, so cancelled work never becomes a stale render.
