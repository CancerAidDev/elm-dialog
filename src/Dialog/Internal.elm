module Dialog.Internal exposing (..)

import Http.Detailed as HttpDetailed



--MSG


type Msg
    = Close
    | Reload



-- MODEL


type Dialog body
    = DialogInfo SimpleDialogContent
    | DialogError SimpleDialogContent
    | DialogHttpError (HttpErrorDialogContent body)
    | Loading


type alias DialogContent a =
    { a
        | title : String
        , message : String
    }


type alias SimpleDialogContent =
    DialogContent {}


type alias HttpErrorDialogContent body =
    DialogContent { httpError : HttpDetailed.Error body }
