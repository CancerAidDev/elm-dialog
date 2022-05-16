module Dialog exposing (Dialog(..), Model, Msg, defaultHttpError, update, view)

import Browser.Navigation as Navigation
import Html
import Html.Attributes as HtmlAttributes
import Html.Events as HtmlEvents
import Html.Extra as HtmlExtra
import Http
import Http.Detailed as HttpDetailed
import Json.Decode as Decode



-- MODEL


type Dialog
    = DialogError Error
    | Loading


type alias Error =
    { title : String
    , message : String
    , httpError : Maybe (HttpDetailed.Error String)
    }


defaultHttpError : String -> HttpDetailed.Error String -> Dialog
defaultHttpError message error =
    DialogError
        { title = "Oops! Something went wrong"
        , message = message
        , httpError = Just error
        }


type alias Model =
    Maybe Dialog



-- CONFIG


type alias Config err =
    { decoderErrorResponse : Decode.Decoder err
    , viewBadStatusError : Http.Metadata -> String -> Html.Html Msg
    }



-- MSG


type Msg
    = Close
    | Reload



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( Nothing, Cmd.none )

        Reload ->
            ( model, Navigation.reload )



-- VIEW


view : Config err -> Maybe Dialog -> Html.Html Msg
view config maybeDialog =
    case maybeDialog of
        Just Loading ->
            viewLoadingDialog

        Just (DialogError error) ->
            viewErrorDialog config error

        Nothing ->
            HtmlExtra.nothing


viewLoadingDialog : Html.Html Msg
viewLoadingDialog =
    Html.div [ HtmlAttributes.class "modal is-active is-clipped" ]
        [ Html.div [ HtmlAttributes.class "modal-background-custom" ] []
        , Html.div [ HtmlAttributes.class "modal-content has-text-left" ]
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
        ]


viewErrorDialog : Config err -> Error -> Html.Html Msg
viewErrorDialog config { title, message, httpError } =
    Html.div [ HtmlAttributes.class "modal is-active is-clipped" ]
        [ Html.div [ HtmlAttributes.class "modal-background-custom", HtmlEvents.onClick Close ] []
        , Html.div [ HtmlAttributes.class "modal-content has-text-left" ]
            [ Html.article
                [ HtmlAttributes.class "message is-danger" ]
                [ Html.div [ HtmlAttributes.class "message-header" ]
                    [ Html.p [] [ Html.text title ]
                    ]
                , Html.div [ HtmlAttributes.class "message-body" ]
                    [ Html.p [ HtmlAttributes.class "mb-4" ] [ Html.text message ]
                    , HtmlExtra.viewMaybe
                        (\error -> Html.p [ HtmlAttributes.class "mb-5" ] [ viewHttpError config error ])
                        httpError
                    , Html.div [ HtmlAttributes.class "is-flex is-justify-content-flex-end" ]
                        [ Html.button [ HtmlAttributes.class "button is-danger mr-2", HtmlEvents.onClick Reload ] [ Html.text "Reload" ]
                        , Html.button [ HtmlAttributes.class "button", HtmlEvents.onClick Close ] [ Html.text "Close" ]
                        ]
                    ]
                ]
            ]
        ]


viewHttpError : Config err -> HttpDetailed.Error String -> Html.Html Msg
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
