# elm-dialog

Elm dialog for showing modal information, errors, and loading status.

Customization for [Bulma](https://bulma.io) is provided in `Dialog.Bulma`.

Currently supports the following dialogs:

- Info
- Error
- HttpError
- Loading

## Examples

We recommend checking out the [examples] ([code]) to get a feel for how it works.

[examples]: https://canceraiddev.github.io/elm-dialog/
[code]: https://github.com/canceraiddev/elm-dialog/tree/main/examples

## Development

```
yarn install
```

### CI

```
yarn elm-format --validate src examples
yarn elm-review
yarn elm make
```
