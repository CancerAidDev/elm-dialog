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
import Http
import Http.Detailed as HttpDetailed


{-| Dialog Model data type.
-}
type alias Model =
    Maybe Internal.Dialog


{-| Create a httpError dialog.
-}
httpError : { title : String, message : String } -> HttpDetailed.Error String -> Internal.Dialog
httpError { title, message } err =
    Internal.DialogHttpError
        { title = title
        , message = message
        , httpError = err
        }


{-| Create an info dialog.
-}
info : { title : String, message : String } -> Internal.Dialog
info =
    Internal.DialogInfo


{-| Create an error dialog.
-}
error : { title : String, message : String } -> Internal.Dialog
error =
    Internal.DialogError


{-| Create a loading dialog.
-}
loading : Internal.Dialog
loading =
    Internal.Loading



-- CONFIG


{-| Customizations for dialog.

Use `viewBadStatusError` to render Http.Detailed.BadStatus error messages.

Use `viewLoadingIndicator` to set a custom loading icon, e.g. a .gif or custom HTML element.

-}
type alias Customizations =
    { viewBadStatusError : Http.Metadata -> String -> Html.Html Msg
    , viewLoadingIndicator : Html.Html Msg
    }



-- MSG


{-| Opaque type representing the messages of the Dialog.
-}
type alias Msg =
    Internal.Msg



-- UPDATE


{-| Update dialog.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Internal.Close ->
            ( Nothing, Cmd.none )

        Internal.Reload ->
            ( model, Navigation.reload )
