module Dialog exposing
    ( Config, config, closeOnBackgroundClick, showCloseIcon
    , dark, primary, link, info, success, warning, danger
    , title, body, footer
    , small, medium, large
    , view, viewLoading, viewCustomLoading
    )

{-| Simple Dialog.

We recommend checking out the [examples] to get a feel for how it works.

[examples]: https://github.com/canceraiddev/elm-dialog/tree/main/examples


# Configuration

@docs Config, config, closeOnBackgroundClick, showCloseIcon


## Colors

@docs dark, primary, link, info, success, warning, danger


## Content

@docs title, body, footer


## Sizes

@docs small, medium, large


# View

@docs view, viewLoading, viewCustomLoading

-}

import Accessibility.Aria as Aria
import Html
import Html.Attributes as HtmlAttributes
import Html.Attributes.Extra as HtmlAttributesExtra
import Html.Events as HtmlEvents
import Html.Extra as HtmlExtra


{-| Opaque type representing dialog config
-}
type Config msg
    = Config
        { closeMsg : msg
        , title : Maybe String
        , body : Maybe (Body msg)
        , footer : Maybe (Footer msg)
        , options : Options
        }


type alias Options =
    { size : Maybe Size
    , color : Maybe Color
    , showCloseIcon : Bool
    , closeOnBackgroundClick : Bool
    }


{-| Opaque type representing a dialog body
-}
type Body msg
    = Body (Node msg)


{-| Opaque type representing a dialog footer
-}
type Footer msg
    = Footer (Node msg)


type alias Node msg =
    { attributes : List (Html.Attribute msg)
    , children : List (Html.Html msg)
    }


type Size
    = Small
    | Medium
    | Large


type Color
    = Dark
    | Primary
    | Link
    | Info
    | Success
    | Warning
    | Danger


colorClass : Color -> Html.Attribute msg
colorClass color =
    HtmlAttributes.class <|
        case color of
            Dark ->
                "is-dark"

            Primary ->
                "is-primary"

            Link ->
                "is-link"

            Info ->
                "is-info"

            Success ->
                "is-success"

            Warning ->
                "is-warning"

            Danger ->
                "is-danger"


sizeClass : Size -> Html.Attribute msg
sizeClass size =
    HtmlAttributes.class <|
        case size of
            Small ->
                "is-small"

            Medium ->
                "is-medium"

            Large ->
                "is-large"


{-| Create an initial dialog config. You can specify the title, body, footer and other option functions.
-}
config : msg -> Config msg
config closeMsg =
    Config
        { closeMsg = closeMsg
        , title = Nothing
        , body = Nothing
        , footer = Nothing
        , options = defaultOptions
        }


defaultOptions : Options
defaultOptions =
    { size = Nothing
    , color = Nothing
    , showCloseIcon = True
    , closeOnBackgroundClick = True
    }


{-| -}
closeOnBackgroundClick : Bool -> Config msg -> Config msg
closeOnBackgroundClick hide (Config ({ options } as conf)) =
    Config { conf | options = { options | closeOnBackgroundClick = hide } }


{-| -}
showCloseIcon : Bool -> Config msg -> Config msg
showCloseIcon show (Config ({ options } as conf)) =
    Config { conf | options = { options | showCloseIcon = show } }


{-| Option to apply is-small to dialog
-}
small : Config msg -> Config msg
small (Config ({ options } as conf)) =
    Config { conf | options = { options | size = Just Small } }


{-| Option to apply is-medium to dialog
-}
medium : Config msg -> Config msg
medium (Config ({ options } as conf)) =
    Config { conf | options = { options | size = Just Medium } }


{-| Option to apply is-large to dialog
-}
large : Config msg -> Config msg
large (Config ({ options } as conf)) =
    Config { conf | options = { options | size = Just Large } }


{-| Option to apply is-dark color to dialog
-}
dark : Config msg -> Config msg
dark (Config ({ options } as conf)) =
    Config { conf | options = { options | color = Just Dark } }


{-| Option to apply is-primary color to dialog
-}
primary : Config msg -> Config msg
primary (Config ({ options } as conf)) =
    Config { conf | options = { options | color = Just Primary } }


{-| Option to apply is-link color to dialog
-}
link : Config msg -> Config msg
link (Config ({ options } as conf)) =
    Config { conf | options = { options | color = Just Link } }


{-| Option to apply is-info color to dialog
-}
info : Config msg -> Config msg
info (Config ({ options } as conf)) =
    Config { conf | options = { options | color = Just Info } }


{-| Option to apply is-success color to dialog
-}
success : Config msg -> Config msg
success (Config ({ options } as conf)) =
    Config { conf | options = { options | color = Just Success } }


{-| Option to apply is-warning color to dialog
-}
warning : Config msg -> Config msg
warning (Config ({ options } as conf)) =
    Config { conf | options = { options | color = Just Warning } }


{-| Option to apply is-danger color to dialog
-}
danger : Config msg -> Config msg
danger (Config ({ options } as conf)) =
    Config { conf | options = { options | color = Just Danger } }


{-| Option to set title string of dialog
-}
title : String -> Config msg -> Config msg
title str (Config conf) =
    Config { conf | title = Just str }


{-| Option to set body content of dialog
-}
body : List (Html.Attribute msg) -> List (Html.Html msg) -> Config msg -> Config msg
body attributes children (Config conf) =
    Config { conf | body = Just (Body { attributes = attributes, children = children }) }


{-| Option to set footer content of dialog
-}
footer : List (Html.Attribute msg) -> List (Html.Html msg) -> Config msg -> Config msg
footer attributes children (Config conf) =
    Config { conf | footer = Just (Footer { attributes = attributes, children = children }) }


viewModal : { closeMsg : Maybe msg } -> List (Html.Html msg) -> Html.Html msg
viewModal options children =
    Html.div [ HtmlAttributes.class "modal is-active is-clipped" ]
        [ Html.div
            [ HtmlAttributes.class "modal-background"
            , HtmlAttributesExtra.attributeMaybe HtmlEvents.onClick options.closeMsg
            ]
            []
        , Html.div [ HtmlAttributes.class "modal-content has-text-left" ]
            children
        ]


{-| View loading dialog. Styled using [bulma progress bar](https://bulma.io/documentation/elements/progress/#docsNav)
-}
viewLoading : Html.Html msg
viewLoading =
    viewCustomLoading [] [ defaultLoadingIndicator ]


{-| View loading dialog with custom element.
-}
viewCustomLoading : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
viewCustomLoading attributes children =
    viewModal
        { closeMsg = Nothing }
        [ Html.div
            (HtmlAttributes.class "is-flex is-justify-content-center" :: attributes)
            children
        ]


defaultLoadingIndicator : Html.Html msg
defaultLoadingIndicator =
    Html.progress
        [ HtmlAttributes.class "progress is-large is-info"
        , HtmlAttributes.max "100"
        ]
        []


viewHeader : Config msg -> Html.Html msg
viewHeader (Config conf) =
    Html.div [ HtmlAttributes.class "message-header" ]
        [ Html.p [] [ Html.text (Maybe.withDefault "" conf.title) ]
        , HtmlExtra.viewIf conf.options.showCloseIcon (closeIcon conf.closeMsg)
        ]


closeIcon : msg -> Html.Html msg
closeIcon closeMsg =
    Html.button
        [ HtmlAttributes.class "delete"
        , Aria.label "close"
        , HtmlEvents.onClick closeMsg
        ]
        []


{-| View dialog for specified config
-}
view : Config msg -> Html.Html msg
view (Config ({ closeMsg, options } as conf)) =
    viewModal
        { closeMsg =
            if options.closeOnBackgroundClick then
                Just closeMsg

            else
                Nothing
        }
        [ Html.article
            [ HtmlAttributes.class "message"
            , HtmlAttributesExtra.attributeMaybe colorClass options.color
            , HtmlAttributesExtra.attributeMaybe sizeClass options.size
            ]
            [ viewHeader (Config conf)
            , Html.div [ HtmlAttributes.class "message-body" ] <|
                List.filterMap identity
                    [ viewBody conf.body
                    , viewFooter conf.footer
                    ]
            ]
        ]


viewBody : Maybe (Body msg) -> Maybe (Html.Html msg)
viewBody =
    Maybe.map (\(Body { attributes, children }) -> Html.div attributes children)


viewFooter : Maybe (Footer msg) -> Maybe (Html.Html msg)
viewFooter =
    Maybe.map
        (\(Footer { attributes, children }) ->
            Html.div
                (HtmlAttributes.class "pt-4" :: attributes)
                children
        )
