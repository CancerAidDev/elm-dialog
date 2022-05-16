module Dialog.Internal exposing (..)

import Http.Detailed as HttpDetailed



--MSG


type Msg
    = Close
    | Reload



-- MODEL


type Dialog
    = DialogInfo SimpleDialogContent
    | DialogError SimpleDialogContent
    | DialogHttpError HttpErrorDialogContent
    | Loading


type alias DialogContent a =
    { a
        | title : String
        , message : String
    }


type alias SimpleDialogContent =
    DialogContent {}


type alias HttpErrorDialogContent =
    DialogContent { httpError : HttpDetailed.Error String }
