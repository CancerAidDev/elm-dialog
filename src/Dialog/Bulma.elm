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
import Html.Attributes.Extra as HtmlAttributesExtra
import Html.Events as HtmlEvents
import Html.Extra as HtmlExtra
import Http.Detailed as HttpDetailed


{-| Default `Dialog` customizations for Bulma.
-}
defaultCustomizations : (Dialog.Msg -> msg) -> Dialog.Customizations String msg
defaultCustomizations toMsg =
    { viewLoadingIndicator = defaultLoadingIndicator
    , viewHttpError = defaultViewHttpError
    , toMsg = toMsg
    }


{-| View Dialog using Bulma css classes. Built using [modal] and [message] components.

[modal]: https://bulma.io/documentation/components/modal/
[message]: https://bulma.io/documentation/components/message/

-}
view : Dialog.Customizations body msg -> Dialog.Model body msg -> Html.Html msg
view config maybeDialog =
    case maybeDialog of
        Just Internal.Loading ->
            viewLoadingDialog config

        Just (Internal.DialogInfo info) ->
            viewInfoDialog config info

        Just (Internal.DialogError error) ->
            viewErrorDialog config error

        Just (Internal.DialogHttpError error) ->
            viewHttpErrorDialog config error

        Just (Internal.DialogOkCancel okCancel) ->
            viewOkCancelDialog config okCancel

        Nothing ->
            HtmlExtra.nothing


viewModal : Dialog.Customizations body msg -> { closeOnBackgroundClick : Bool } -> List (Html.Html msg) -> Html.Html msg
viewModal { toMsg } { closeOnBackgroundClick } children =
    Html.div [ HtmlAttributes.class "modal is-active is-clipped" ]
        [ Html.div
            [ HtmlAttributes.class "modal-background"
            , HtmlAttributesExtra.attributeIf closeOnBackgroundClick <| HtmlEvents.onClick (toMsg Internal.Close)
            ]
            []
        , Html.div [ HtmlAttributes.class "modal-content has-text-left" ]
            children
        ]


viewLoadingDialog : Dialog.Customizations body msg -> Html.Html msg
viewLoadingDialog ({ viewLoadingIndicator } as config) =
    viewModal config
        { closeOnBackgroundClick = False }
        [ Html.div
            [ HtmlAttributes.class "is-flex is-justify-content-center" ]
            [ viewLoadingIndicator ]
        ]


viewHeader : Dialog.Customizations body msg -> { title : String, showCloseButton : Bool } -> Html.Html msg
viewHeader { toMsg } { title, showCloseButton } =
    Html.div [ HtmlAttributes.class "message-header" ]
        [ Html.p [] [ Html.text title ]
        , HtmlExtra.viewIf showCloseButton <|
            Html.button
                [ HtmlAttributes.class "delete"
                , Aria.label "close"
                , HtmlEvents.onClick (toMsg Internal.Close)
                ]
                []
        ]


viewButtons : Dialog.Customizations body msg -> Html.Html msg
viewButtons { toMsg } =
    Html.div [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
        [ Html.button
            [ HtmlAttributes.class "button mr-2"
            , HtmlEvents.onClick (toMsg Internal.Reload)
            ]
            [ Html.text "Reload" ]
        , Html.button
            [ HtmlAttributes.class "button"
            , HtmlEvents.onClick (toMsg Internal.Close)
            ]
            [ Html.text "Close" ]
        ]


viewInfoDialog : Dialog.Customizations body msg -> Internal.SimpleDialogContent -> Html.Html msg
viewInfoDialog ({ toMsg } as config) { title, message } =
    viewModal config
        { closeOnBackgroundClick = True }
        [ Html.article
            [ HtmlAttributes.class "message is-info" ]
            [ viewHeader config { title = title, showCloseButton = True }
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , Html.div [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                    [ Html.button
                        [ HtmlAttributes.class "button"
                        , HtmlEvents.onClick (toMsg Internal.Close)
                        ]
                        [ Html.text "Close" ]
                    ]
                ]
            ]
        ]


viewErrorDialog : Dialog.Customizations body msg -> Internal.SimpleDialogContent -> Html.Html msg
viewErrorDialog config { title, message } =
    viewModal config
        { closeOnBackgroundClick = True }
        [ Html.article
            [ HtmlAttributes.class "message is-danger" ]
            [ viewHeader config { title = title, showCloseButton = True }
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , viewButtons config
                ]
            ]
        ]


viewHttpErrorDialog : Dialog.Customizations body msg -> Internal.HttpErrorDialogContent body -> Html.Html msg
viewHttpErrorDialog config { title, message, httpError } =
    viewModal config
        { closeOnBackgroundClick = True }
        [ Html.article
            [ HtmlAttributes.class "message is-danger" ]
            [ viewHeader config { title = title, showCloseButton = True }
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , Html.p [ HtmlAttributes.class "mb-5" ] [ config.viewHttpError httpError ]
                , viewButtons config
                ]
            ]
        ]


viewOkCancelDialog : Dialog.Customizations body msg -> Internal.OkCancelDialogContent msg -> Html.Html msg
viewOkCancelDialog config { title, message, ok, cancel } =
    viewModal config
        { closeOnBackgroundClick = False }
        [ Html.article
            [ HtmlAttributes.class "message is-info" ]
            [ viewHeader config { title = title, showCloseButton = False }
            , Html.div [ HtmlAttributes.class "message-body" ]
                [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                , Html.div [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                    [ Html.button
                        [ HtmlAttributes.class "button mr-2"
                        , HtmlEvents.onClick cancel
                        ]
                        [ Html.text "Cancel" ]
                    , Html.button
                        [ HtmlAttributes.class "button"
                        , HtmlEvents.onClick ok
                        ]
                        [ Html.text "Ok" ]
                    ]
                ]
            ]
        ]


defaultLoadingIndicator : Html.Html msg
defaultLoadingIndicator =
    Html.progress
        [ HtmlAttributes.class "progress is-large is-info"
        , HtmlAttributes.max "100"
        ]
        []


defaultViewHttpError : HttpDetailed.Error String -> Html.Html msg
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
