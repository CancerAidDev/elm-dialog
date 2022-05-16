module Dialog.Bulma exposing
    ( defaultCustomizations
    , view
    )

{-| [Bulma](https://bulma.io) specific customizations and view for `Dialog`.

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

We recommend checking out the [examples] to get a feel for how it works.

[examples]: https://github.com/canceraiddev/elm-dialog/tree/main/examples


# Configuration

@docs defaultCustomizations


# View

@docs view

-}

import Accessibility.Aria as Aria
import Dialog
import Dialog.Internal as Internal
import Html
import Html.Attributes as HtmlAttributes
import Html.Events as HtmlEvents
import Html.Extra as HtmlExtra
import Http.Detailed as HttpDetailed


{-| Default `Dialog` customizations for Bulma.
-}
defaultCustomizations : Dialog.Customizations String
defaultCustomizations =
    { viewLoadingIndicator = defaultLoadingIndicator
    , viewHttpError = defaultViewHttpError
    }


{-| View Dialog using Bulma css classes. Built using [modal] and [message] components.

[modal]: https://bulma.io/documentation/components/modal/
[message]: https://bulma.io/documentation/components/message/

-}
view : Dialog.Customizations body -> Dialog.Model body -> Html.Html Dialog.Msg
view config maybeDialog =
    case maybeDialog of
        Just Internal.Loading ->
            viewLoadingDialog config

        Just (Internal.DialogInfo info) ->
            viewInfoDialog info

        Just (Internal.DialogError error) ->
            viewErrorDialog error

        Just (Internal.DialogHttpError error) ->
            viewHttpErrorDialog config error

        Nothing ->
            HtmlExtra.nothing


viewModal : List (Html.Html Dialog.Msg) -> Html.Html Dialog.Msg
viewModal children =
    Html.div [ HtmlAttributes.class "modal is-active is-clipped" ]
        [ Html.div [ HtmlAttributes.class "modal-background", HtmlEvents.onClick Internal.Close ] []
        , Html.div [ HtmlAttributes.class "modal-content has-text-left" ]
            children
        ]


viewLoadingDialog : Dialog.Customizations body -> Html.Html Dialog.Msg
viewLoadingDialog { viewLoadingIndicator } =
    viewModal
        [ Html.div
            [ HtmlAttributes.class "is-flex is-justify-content-center" ]
            [ viewLoadingIndicator ]
        ]


viewHeader : String -> Html.Html Dialog.Msg
viewHeader title =
    Html.div [ HtmlAttributes.class "message-header" ]
        [ Html.p [] [ Html.text title ]
        , Html.button
            [ HtmlAttributes.class "delete"
            , Aria.label "close"
            , HtmlEvents.onClick Internal.Close
            ]
            []
        ]


viewButtons : Html.Html Dialog.Msg
viewButtons =
    Html.div [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
        [ Html.button [ HtmlAttributes.class "button mr-2", HtmlEvents.onClick Internal.Reload ] [ Html.text "Reload" ]
        , Html.button [ HtmlAttributes.class "button", HtmlEvents.onClick Internal.Close ] [ Html.text "Close" ]
        ]


viewInfoDialog : Internal.SimpleDialogContent -> Html.Html Dialog.Msg
viewInfoDialog { title, message } =
    viewModal
        [ Html.article
            [ HtmlAttributes.class "message is-info" ]
            [ viewHeader title
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , viewButtons
                ]
            ]
        ]


viewErrorDialog : Internal.SimpleDialogContent -> Html.Html Dialog.Msg
viewErrorDialog { title, message } =
    viewModal
        [ Html.article
            [ HtmlAttributes.class "message is-danger" ]
            [ viewHeader title
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , viewButtons
                ]
            ]
        ]


viewHttpErrorDialog : Dialog.Customizations body -> Internal.HttpErrorDialogContent body -> Html.Html Dialog.Msg
viewHttpErrorDialog config { title, message, httpError } =
    viewModal
        [ Html.article
            [ HtmlAttributes.class "message is-danger" ]
            [ viewHeader title
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , Html.p [ HtmlAttributes.class "mb-5" ] [ config.viewHttpError httpError ]
                , viewButtons
                ]
            ]
        ]


defaultLoadingIndicator : Html.Html Dialog.Msg
defaultLoadingIndicator =
    Html.progress
        [ HtmlAttributes.class "progress is-large is-info"
        , HtmlAttributes.max "100"
        ]
        []


defaultViewHttpError : HttpDetailed.Error String -> Html.Html Dialog.Msg
defaultViewHttpError error =
    case error of
        HttpDetailed.BadUrl url ->
            Html.text <| url ++ " is an invalid URL"

        HttpDetailed.Timeout ->
            Html.text <| "The server cannot be reached, timeout occurred"

        HttpDetailed.NetworkError ->
            Html.text <| "Network connection error, the server cannot be reached"

        HttpDetailed.BadStatus { statusCode, statusText } body ->
            Html.div []
                [ Html.p [] [ Html.text <| String.fromInt statusCode ++ " Error" ]
                , Html.p [] [ Html.text statusText ]
                , Html.p [] [ Html.text body ]
                ]

        HttpDetailed.BadBody _ _ err ->
            Html.text <| err
