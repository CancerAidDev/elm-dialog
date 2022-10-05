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


type Dialog
    = Info
    | Error
    | OkCancel
    | Loading


type alias Model =
    { dialog : Maybe Dialog
    , approve : Bool
    , letterBox : Char
    }


init : ( Model, Cmd Msg )
init =
    ( { dialog = Nothing, approve = False, letterBox = '📭' }, Cmd.none )



-- UPDATE


type Msg
    = OpenInfoDialog
    | OpenErrorDialog
    | OpenOkCancelDialog
    | OpenLoadingDialog
    | CloseDialog
    | Ok
    | Cancel
    | SetApprove Bool
    | Reload


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenInfoDialog ->
            ( { model | dialog = Just Info }, Cmd.none )

        OpenErrorDialog ->
            ( { model | dialog = Just Error }, Cmd.none )

        OpenOkCancelDialog ->
            ( { model | dialog = Just OkCancel }, Cmd.none )

        OpenLoadingDialog ->
            ( { model | dialog = Just Loading }, Cmd.none )

        CloseDialog ->
            ( { model | dialog = Nothing }, Cmd.none )

        Ok ->
            ( { model | letterBox = '📬', dialog = Nothing }, Cmd.none )

        Cancel ->
            ( { model | letterBox = '📭', dialog = Nothing }, Cmd.none )

        SetApprove approve ->
            ( { model | approve = approve }, Cmd.none )

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
            [ Html.text (String.fromChar model.letterBox) ]
        , case model.dialog of
            Just Info ->
                viewInfo

            Just Error ->
                viewError

            Just OkCancel ->
                viewOkCancel model

            Just Loading ->
                Dialog.viewLoading

            Nothing ->
                Html.text ""
        ]


viewInfo : Html.Html Msg
viewInfo =
    Dialog.config CloseDialog
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
        |> Dialog.view


viewError : Html.Html Msg
viewError =
    Dialog.config CloseDialog
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
        |> Dialog.view


viewOkCancel : Model -> Html.Html Msg
viewOkCancel model =
    Dialog.config CloseDialog
        |> Dialog.primary
        |> Dialog.title "Hello"
        |> Dialog.body [ HtmlAttributes.class "content" ]
            [ Html.text "Terms and conditions"
            , Html.ul [] [ Html.li [] [ Html.text "Click ok to get letter" ] ]
            , Html.div []
                [ Html.label
                    [ HtmlAttributes.class "checkbox" ]
                    [ Html.input
                        [ HtmlAttributes.type_ "checkbox"
                        , HtmlAttributes.checked model.approve
                        , HtmlEvents.onCheck SetApprove
                        ]
                        []
                    , Html.text " I agree"
                    ]
                ]
            ]
        |> Dialog.footer [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
            [ Html.button
                [ HtmlAttributes.class "button mr-2"
                , HtmlEvents.onClick Cancel
                ]
                [ Html.text "Cancel" ]
            , Html.button
                [ HtmlAttributes.class "button is-primary"
                , HtmlAttributes.disabled (not model.approve)
                , HtmlEvents.onClick Ok
                ]
                [ Html.text "Ok" ]
            ]
        |> Dialog.view
