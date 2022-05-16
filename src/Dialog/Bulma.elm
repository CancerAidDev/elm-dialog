module Dialog.Bulma exposing (view)

import Dialog
import Dialog.Internal as Internal
import Html
import Html.Attributes as HtmlAttributes
import Html.Events as HtmlEvents
import Html.Extra as HtmlExtra
import Http.Detailed as HttpDetailed


view : Dialog.Config -> Maybe Dialog.Dialog -> Html.Html Dialog.Msg
view config maybeDialog =
    case maybeDialog of
        Just Dialog.Loading ->
            viewLoadingDialog

        Just (Dialog.DialogError error) ->
            viewErrorDialog error

        Just (Dialog.DialogHttpError error) ->
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


viewLoadingDialog : Html.Html Dialog.Msg
viewLoadingDialog =
    viewModal
        [ Html.div
            [ HtmlAttributes.class "is-flex is-justify-content-center" ]
            [ Html.figure
                [ HtmlAttributes.class "image" ]
                [ Html.figure [ HtmlAttributes.class "image" ]
                    [ Html.img
                        [ HtmlAttributes.class "p-5 is-rounded has-background-white"
                        , HtmlAttributes.src "/public/images/loading.gif"
                        ]
                        []
                    ]
                ]
            ]
        ]


viewErrorDialog : Dialog.Error -> Html.Html Dialog.Msg
viewErrorDialog { title, message } =
    viewModal
        [ Html.article
            [ HtmlAttributes.class "message is-danger" ]
            [ Html.div [ HtmlAttributes.class "message-header" ]
                [ Html.p [] [ Html.text title ]
                ]
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , Html.div [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                    [ Html.button [ HtmlAttributes.class "button is-danger mr-2", HtmlEvents.onClick Internal.Reload ] [ Html.text "Reload" ]
                    , Html.button [ HtmlAttributes.class "button", HtmlEvents.onClick Internal.Close ] [ Html.text "Close" ]
                    ]
                ]
            ]
        ]


viewHttpErrorDialog : Dialog.Config -> Dialog.HttpError -> Html.Html Dialog.Msg
viewHttpErrorDialog config { title, message, httpError } =
    viewModal
        [ Html.article
            [ HtmlAttributes.class "message is-danger" ]
            [ Html.div [ HtmlAttributes.class "message-header" ]
                [ Html.p [] [ Html.text title ]
                ]
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , Html.p [ HtmlAttributes.class "mb-5" ] [ viewHttpError config httpError ]
                , Html.div [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                    [ Html.button [ HtmlAttributes.class "button is-danger mr-2", HtmlEvents.onClick Internal.Reload ] [ Html.text "Reload" ]
                    , Html.button [ HtmlAttributes.class "button", HtmlEvents.onClick Internal.Close ] [ Html.text "Close" ]
                    ]
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
