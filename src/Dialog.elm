module Dialog exposing
    ( Model, error, httpError, info, loading
    , Customizations
    , Msg, update
    )

{-| Simple Dialog.

We recommend checking out the [examples] to get a feel for how it works.

[examples]: https://github.com/canceraiddev/elm-dialog/tree/main/examples


# Model

@docs Model, error, httpError, info, loading


# Configuration

@docs Customizations


# Update

@docs Msg, update

-}

import Browser.Navigation as Navigation
import Dialog.Internal as Internal
import Html
import Http.Detailed as HttpDetailed


{-| Dialog Model data type.
-}
type alias Model body =
    Maybe (Internal.Dialog body)


{-| Dialog data type.
-}
type alias Dialog body =
    Internal.Dialog body


{-| Create a httpError dialog.
-}
httpError : { title : String, message : String } -> HttpDetailed.Error body -> Dialog body
httpError { title, message } err =
    Internal.DialogHttpError
        { title = title
        , message = message
        , httpError = err
        }


{-| Create an info dialog.
-}
info : { title : String, message : String } -> Dialog body
info =
    Internal.DialogInfo


{-| Create an error dialog.
-}
error : { title : String, message : String } -> Dialog body
error =
    Internal.DialogError


{-| Create a loading dialog.
-}
loading : Dialog body
loading =
    Internal.Loading



-- CONFIG


{-| Customizations for dialog.

Use `viewLoadingIndicator` to set a custom loading icon, e.g. a .gif or custom HTML element.

Use `viewHttpError` to render Http.Detailed.Error messages.

-}
type alias Customizations body =
    { viewLoadingIndicator : Html.Html Msg
    , viewHttpError : HttpDetailed.Error body -> Html.Html Msg
    }



-- MSG


{-| Opaque type representing the messages of the Dialog.
-}
type alias Msg =
    Internal.Msg



-- UPDATE


{-| Update dialog.
-}
update : Msg -> Model body -> ( Model body, Cmd Msg )
update msg model =
    case msg of
        Internal.Close ->
            ( Nothing, Cmd.none )

        Internal.Reload ->
            ( model, Navigation.reload )
