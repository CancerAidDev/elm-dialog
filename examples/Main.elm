module Main exposing (main)

import Browser
import Dialog
import Dialog.Bulma as DialogBulma
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http.Detailed as HttpDetailed


main : Program {} Model Msg
main =
    Browser.element
        { init = always init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    Dialog.Model String


init : ( Model, Cmd Msg )
init =
    ( Nothing, Cmd.none )



-- UPDATE


type Msg
    = DialogMsg Dialog.Msg
    | OpenInfoDialog
    | OpenErrorDialog
    | OpenHttpErrorDialog
    | OpenLoadingDialog


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DialogMsg subMsg ->
            Dialog.update subMsg model
                |> Tuple.mapSecond (Cmd.map DialogMsg)

        OpenInfoDialog ->
            ( Just <|
                Dialog.info
                    { title = "Info"
                    , message = "Hello from elm-dialog"
                    }
            , Cmd.none
            )

        OpenErrorDialog ->
            ( Just <|
                Dialog.error
                    { title = "Error"
                    , message = "Something went wrong :("
                    }
            , Cmd.none
            )

        OpenHttpErrorDialog ->
            ( Just <|
                Dialog.httpError
                    { title = "Error"
                    , message = "Something went wrong :("
                    }
                    HttpDetailed.Timeout
            , Cmd.none
            )

        OpenLoadingDialog ->
            ( Just <| Dialog.loading
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "p-4" ]
        [ h1 [ class "title" ] [ text "Elm Dialog Example" ]
        , button [ class "button", onClick OpenInfoDialog ] [ text "Open Info Dialog" ]
        , button [ class "button ml-3", onClick OpenErrorDialog ] [ text "Open Error Dialog" ]
        , button [ class "button ml-3", onClick OpenHttpErrorDialog ] [ text "Open Http Error Dialog" ]
        , button [ class "button ml-3", onClick OpenLoadingDialog ] [ text "Open Loading Dialog" ]
        , Html.map DialogMsg <| DialogBulma.view DialogBulma.defaultCustomizations model
        ]
