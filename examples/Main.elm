module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Dialog
import Html as Html
import Html.Attributes as HtmlAttributes
import Html.Events as HtmlEvents


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
    { dialog : Maybe (Dialog.Config Msg)
    , loading : Bool
    , letterBox : String
    }


init : ( Model, Cmd Msg )
init =
    ( { dialog = Nothing, loading = False, letterBox = "📭" }, Cmd.none )



-- UPDATE


type Msg
    = OpenInfoDialog
    | OpenErrorDialog
    | OpenOkCancelDialog
    | OpenLoadingDialog
    | CloseDialog
    | Ok
    | Cancel
    | Reload


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenInfoDialog ->
            ( { model
                | dialog =
                    Just
                        (Dialog.config CloseDialog
                            |> Dialog.info
                            |> Dialog.title "Info"
                            |> Dialog.body [] [ Html.text "Hello from elm-dialog" ]
                            |> Dialog.footer [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                                [ Html.button
                                    [ HtmlAttributes.class "button"
                                    , HtmlEvents.onClick CloseDialog
                                    ]
                                    [ Html.text "Close" ]
                                ]
                        )
              }
            , Cmd.none
            )

        OpenErrorDialog ->
            ( { model
                | dialog =
                    Just
                        (Dialog.config CloseDialog
                            |> Dialog.danger
                            |> Dialog.title "Error"
                            |> Dialog.closeOnBackgroundClick False
                            |> Dialog.showCloseIcon False
                            |> Dialog.body [] [ Html.text "Something went wrong :(" ]
                            |> Dialog.footer [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                                [ Html.button
                                    [ HtmlAttributes.class "button is-danger mr-2"
                                    , HtmlEvents.onClick Reload
                                    ]
                                    [ Html.text "Reload" ]
                                , Html.button
                                    [ HtmlAttributes.class "button"
                                    , HtmlEvents.onClick CloseDialog
                                    ]
                                    [ Html.text "Close" ]
                                ]
                        )
              }
            , Cmd.none
            )

        OpenOkCancelDialog ->
            ( { model
                | dialog =
                    Just
                        (Dialog.config CloseDialog
                            |> Dialog.primary
                            |> Dialog.title "Hello"
                            |> Dialog.body [] [ Html.text "Click ok to get a letter." ]
                            |> Dialog.footer [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                                [ Html.button
                                    [ HtmlAttributes.class "button mr-2"
                                    , HtmlEvents.onClick Cancel
                                    ]
                                    [ Html.text "Cancel" ]
                                , Html.button
                                    [ HtmlAttributes.class "button is-primary"
                                    , HtmlEvents.onClick Ok
                                    ]
                                    [ Html.text "Ok" ]
                                ]
                        )
              }
            , Cmd.none
            )

        OpenLoadingDialog ->
            ( { model | loading = True }, Cmd.none )

        CloseDialog ->
            ( { model | dialog = Nothing }, Cmd.none )

        Ok ->
            ( { model | letterBox = "📬", dialog = Nothing }, Cmd.none )

        Cancel ->
            ( { model | letterBox = "📭", dialog = Nothing }, Cmd.none )

        Reload ->
            ( model, Navigation.reload )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div [ HtmlAttributes.class "p-4" ]
        [ Html.h1
            [ HtmlAttributes.class "title" ]
            [ Html.text "Elm Dialog Example" ]
        , Html.button
            [ HtmlAttributes.class "button"
            , HtmlEvents.onClick OpenInfoDialog
            ]
            [ Html.text "Open Info Dialog" ]
        , Html.button
            [ HtmlAttributes.class "button ml-3"
            , HtmlEvents.onClick OpenErrorDialog
            ]
            [ Html.text "Open Error Dialog" ]
        , Html.button
            [ HtmlAttributes.class "button ml-3"
            , HtmlEvents.onClick OpenOkCancelDialog
            ]
            [ Html.text "Open Ok Cancel Dialog" ]
        , Html.button
            [ HtmlAttributes.class "button ml-3"
            , HtmlEvents.onClick OpenLoadingDialog
            ]
            [ Html.text "Open Loading Dialog" ]
        , Html.div
            [ HtmlAttributes.class "mt-4" ]
            [ Html.text model.letterBox ]
        , case model.dialog of
            Just config ->
                Dialog.view config

            Nothing ->
                Html.text ""
        , if model.loading then
            Dialog.viewLoading

          else
            Html.text ""
        ]
