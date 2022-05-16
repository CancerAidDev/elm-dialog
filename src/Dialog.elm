module Dialog exposing (Config, Dialog(..), Error, HttpError, Model, Msg, update)

import Browser.Navigation as Navigation
import Dialog.Internal as Internal
import Html
import Http
import Http.Detailed as HttpDetailed



-- MODEL


type Dialog
    = DialogError Error
    | DialogHttpError HttpError
    | Loading


type alias Error =
    { title : String
    , message : String
    }


type alias HttpError =
    { title : String
    , message : String
    , httpError : HttpDetailed.Error String
    }


type alias Model =
    Maybe Dialog



-- CONFIG


type alias Config =
    { viewBadStatusError : Http.Metadata -> String -> Html.Html Msg
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
