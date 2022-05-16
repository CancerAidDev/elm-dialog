module Dialog exposing (Config, Model, Msg, error, httpError, info, loading, update)

import Browser.Navigation as Navigation
import Dialog.Internal as Internal
import Html
import Http
import Http.Detailed as HttpDetailed


type alias Model =
    Maybe Internal.Dialog


httpError : { title : String, message : String } -> HttpDetailed.Error String -> Internal.Dialog
httpError { title, message } err =
    Internal.DialogHttpError
        { title = title
        , message = message
        , httpError = err
        }


info : { title : String, message : String } -> Internal.Dialog
info =
    Internal.DialogInfo


error : { title : String, message : String } -> Internal.Dialog
error =
    Internal.DialogError


loading : Internal.Dialog
loading =
    Internal.Loading



-- CONFIG


type alias Config =
    { viewBadStatusError : Http.Metadata -> String -> Html.Html Msg
    , loadingSpinnerSrc : String
    }



-- MSG


type alias Msg =
    Internal.Msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Internal.Close ->
            ( Nothing, Cmd.none )

        Internal.Reload ->
            ( model, Navigation.reload )
