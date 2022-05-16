module Dialog.Bulma exposing (view)

import Accessibility.Aria as Aria
import Dialog
import Dialog.Internal as Internal
import Html
import Html.Attributes as HtmlAttributes
import Html.Events as HtmlEvents
import Html.Extra as HtmlExtra
import Http.Detailed as HttpDetailed


view : Dialog.Config -> Dialog.Model -> Html.Html Dialog.Msg
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


viewLoadingDialog : Dialog.Config -> Html.Html Dialog.Msg
viewLoadingDialog { loadingSpinnerSrc } =
    viewModal
        [ Html.div
            [ HtmlAttributes.class "is-flex is-justify-content-center" ]
            [ Html.figure
                [ HtmlAttributes.class "image" ]
                [ Html.figure [ HtmlAttributes.class "image" ]
                    [ Html.img
                        [ HtmlAttributes.class "p-5 is-rounded has-background-white"
                        , HtmlAttributes.src loadingSpinnerSrc
                        ]
                        []
                    ]
                ]
            ]
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


viewHttpErrorDialog : Dialog.Config -> Internal.HttpErrorDialogContent -> Html.Html Dialog.Msg
viewHttpErrorDialog config { title, message, httpError } =
    viewModal
        [ Html.article
            [ HtmlAttributes.class "message is-danger" ]
            [ viewHeader title
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , Html.p [ HtmlAttributes.class "mb-5" ] [ viewHttpError config httpError ]
                , viewButtons
                ]
            ]
        ]


viewHttpError : Dialog.Config -> HttpDetailed.Error String -> Html.Html Dialog.Msg
viewHttpError config error =
    case error of
        HttpDetailed.BadUrl url ->
            Html.text <| url ++ " is an invalid URL"

        HttpDetailed.Timeout ->
            Html.text <| "The server cannot be reached, timeout occurred"

        HttpDetailed.NetworkError ->
            Html.text <| "Network connection error, the server cannot be reached"

        HttpDetailed.BadStatus metadata body ->
            config.viewBadStatusError metadata body

        HttpDetailed.BadBody _ _ err ->
            Html.text <| err
