module Dialog.Internal exposing (..)

import Http.Detailed as HttpDetailed



--MSG


type Msg
    = Close
    | Reload



-- MODEL


type Dialog body msg
    = DialogInfo SimpleDialogContent
    | DialogError SimpleDialogContent
    | DialogHttpError (HttpErrorDialogContent body)
    | DialogOkCancel (OkCancelDialogContent msg)
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


type alias OkCancelDialogContent msg =
    DialogContent { ok : msg, cancel : msg }
