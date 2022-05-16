module Dialog.Bulma exposing
    ( defaultCustomizations
    , view
    )

{-| [Bulma](https://bulma.io) specific customizations and view for `Dialog`.

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
defaultCustomizations : Dialog.Customizations
defaultCustomizations =
    { viewBadStatusError =
        \{ statusCode, statusText } _ ->
            Html.text <| String.fromInt statusCode ++ " Error (" ++ statusText ++ ")"
    , viewLoadingIndicator =
        Html.progress
            [ HtmlAttributes.class "progress is-large is-info"
            , HtmlAttributes.max "100"
            ]
            []
    }


{-| View Dialog using Bulma css classes. Built using [modal] and [message] components.

[modal]: https://bulma.io/documentation/components/modal/
[message]: https://bulma.io/documentation/components/message/

-}
view : Dialog.Customizations -> Dialog.Model -> Html.Html Dialog.Msg
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


viewLoadingDialog : Dialog.Customizations -> Html.Html Dialog.Msg
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


viewHttpErrorDialog : Dialog.Customizations -> Internal.HttpErrorDialogContent -> Html.Html Dialog.Msg
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


viewHttpError : Dialog.Customizations -> HttpDetailed.Error String -> Html.Html Dialog.Msg
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
