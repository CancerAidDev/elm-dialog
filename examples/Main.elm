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
    { dialog : Dialog.Model String Msg
    , letterBox : String
    }


init : ( Model, Cmd Msg )
init =
    ( { dialog = Nothing, letterBox = "📭" }, Cmd.none )



-- UPDATE


type Msg
    = DialogMsg Dialog.Msg
    | OpenInfoDialog
    | OpenErrorDialog
    | OpenHttpErrorDialog
    | OpenOkCancelDialog
    | OpenOkCancelAlertDialog 
    | OpenLoadingDialog
    | Ok
    | Cancel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DialogMsg subMsg ->
            Dialog.update subMsg model.dialog
                |> (\( updatedDialog, cmd ) -> ( { model | dialog = updatedDialog }, Cmd.map DialogMsg cmd ))

        OpenInfoDialog ->
            ( { model
                | dialog =
                    Just <|
                        Dialog.info
                            { title = "Info"
                            , message = "Hello from elm-dialog"
                            }
              }
            , Cmd.none
            )

        OpenErrorDialog ->
            ( { model
                | dialog =
                    Just <|
                        Dialog.error
                            { title = "Error"
                            , message = "Something went wrong :("
                            }
              }
            , Cmd.none
            )

        OpenHttpErrorDialog ->
            ( { model
                | dialog =
                    Just <|
                        Dialog.httpError
                            { title = "Error"
                            , message = "Something went wrong :("
                            }
                            HttpDetailed.Timeout
              }
            , Cmd.none
            )

        OpenOkCancelDialog ->
            ( { model
                | dialog =
                    Just <|
                        Dialog.okCancel
                            { title = "Hello"
                            , message = "Click ok to get a letter."
                            , ok = Ok
                            , cancel = Cancel
                            }
              }
            , Cmd.none
            )

        OpenOkCancelAlertDialog ->
            ( { model
                | dialog =
                    Just <|
                        Dialog.okCancelHtml 
                            { title = "Hello"
                            , message = Html.div[][Html.li [][Html.text "1"], Html.li [][Html.text "2"] ]
                            , ok = Ok
                            , cancel = Cancel
                            } False
              }
            , Cmd.none
            )

        OpenLoadingDialog ->
            ( { model
                | dialog = Just <| Dialog.loading
              }
            , Cmd.none
            )

        Ok ->
            ( { model | letterBox = "📬", dialog = Nothing }, Cmd.none )

        Cancel ->
            ( { model | letterBox = "📭", dialog = Nothing }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "p-4" ]
        [ h1 [ class "title" ] [ text "Elm Dialog Example" ]
        , button [ class "button", onClick OpenInfoDialog ] [ text "Open Info Dialog" ]
        , button [ class "button ml-3", onClick OpenErrorDialog ] [ text "Open Error Dialog" ]
        , button [ class "button ml-3", onClick OpenHttpErrorDialog ] [ text "Open Http Error Dialog" ]
        , button [ class "button ml-3", onClick OpenLoadingDialog ] [ text "Open Loading Dialog" ]
        , button [ class "button ml-3", onClick OpenOkCancelDialog ] [ text "Open Ok Cancel Dialog" ]
        , button [ class "button ml-3", onClick OpenOkCancelAlertDialog ] [ text "Open Ok Cancel Alert Dialog" ]
        , Html.div [ class "mt-4" ] [ Html.text model.letterBox ]
        , DialogBulma.view (DialogBulma.defaultCustomizations DialogMsg) model.dialog
        ]
