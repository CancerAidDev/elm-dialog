module Dialog exposing
    ( Model, Dialog, error, httpError, info, loading, okCancel
    , Customizations
    , Msg, update
    )

{-| Simple Dialog.

We recommend checking out the [examples] to get a feel for how it works.

[examples]: https://github.com/canceraiddev/elm-dialog/tree/main/examples


# Model

@docs Model, Dialog, error, httpError, info, loading, okCancel


# Configuration

@docs Customizations


# Update

@docs Msg, update

-}

import Browser.Navigation as Navigation
import Dialog.Internal as Internal
import Http.Detailed as HttpDetailed


{-| Dialog Model data type.
-}
type alias Model body msg =
    Maybe (Internal.Dialog body msg)


{-| Dialog data type.
-}
type alias Dialog body msg =
    Internal.Dialog body msg


{-| Create a httpError dialog.
-}
httpError : { title : String, message : String } -> HttpDetailed.Error body -> Dialog body msg
httpError { title, message } err =
    Internal.DialogHttpError
        { title = title
        , message = message
        , httpError = err
        }


{-| Create an info dialog.
-}
info : { title : String, message : String } -> Dialog body msg
info =
    Internal.DialogInfo


{-| Create an error dialog.
-}
error : { title : String, message : String } -> Dialog body msg
error =
    Internal.DialogError


{-| Create a loading dialog.
-}
loading : Dialog body msg
loading =
    Internal.Loading


{-| Create an OK/Cancel dialog.
-}
okCancel : { title : String, message : Html.Html Msg.Msg, ok : msg, cancel : msg } -> Dialog body msg
okCancel { title, message, ok, cancel } =
    Internal.DialogOkCancel
        { title = title
        , message = message
        , ok = ok
        , cancel = cancel
        }



-- CONFIG


{-| Customizations for dialog.

Use `viewLoadingIndicator` to set a custom loading icon, e.g. a .gif or custom HTML element.

Use `viewHttpError` to render Http.Detailed.Error messages.

-}
type alias Customizations body msg =
    { viewLoadingIndicator : Html.Html msg
    , viewHttpError : HttpDetailed.Error body -> Html.Html msg
    , toMsg : Msg -> msg
    }



-- MSG


{-| Opaque type representing the messages of the Dialog.
-}
type alias Msg =
    Internal.Msg



-- UPDATE


{-| Update dialog.
-}
update : Msg -> Model body msg -> ( Model body msg, Cmd Msg )
update msg model =
    case msg of
        Internal.Close ->
            ( Nothing, Cmd.none )

        Internal.Reload ->
            ( model, Navigation.reload )
