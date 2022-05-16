module Main exposing (main)

import Browser
import Dialog
import Dialog.Bulma as DialogBulma
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


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
    Dialog.Model


init : ( Model, Cmd Msg )
init =
    ( Nothing, Cmd.none )



-- UPDATE


type Msg
    = DialogMsg Dialog.Msg
    | OpenInfoDialog
    | OpenErrorDialog
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
                    { title = "Hello"
                    , message = "from elm-dialog"
                    }
            , Cmd.none
            )

        OpenErrorDialog ->
            ( Just <|
                Dialog.error
                    { title = "Hello"
                    , message = "from elm-dialog"
                    }
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
        [ h1 [ class "title" ] [ text "Example" ]
        , button [ class "button", onClick OpenInfoDialog ] [ text "Open Info Dialog" ]
        , button [ class "button ml-3", onClick OpenErrorDialog ] [ text "Open Error Dialog" ]
        , button [ class "button ml-3", onClick OpenLoadingDialog ] [ text "Open Loading Dialog" ]
        , Html.map DialogMsg <| DialogBulma.view DialogBulma.defaultConfig model
        ]
