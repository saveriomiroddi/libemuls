// Ripped off from the SDL crate 😬
//
pub enum EventCode {
    Quit,

    KeyBackspace,
    KeyTab,
    KeyReturn,
    KeyEscape,
    KeySpace,
    KeyExclaim,
    KeyQuotedbl,
    KeyHash,
    KeyDollar,
    KeyPercent,
    KeyAmpersand,
    KeyQuote,
    KeyLeftParen,
    KeyRightParen,
    KeyAsterisk,
    KeyPlus,
    KeyComma,
    KeyMinus,
    KeyPeriod,
    KeySlash,
    KeyNum0,
    KeyNum1,
    KeyNum2,
    KeyNum3,
    KeyNum4,
    KeyNum5,
    KeyNum6,
    KeyNum7,
    KeyNum8,
    KeyNum9,
    KeyColon,
    KeySemicolon,
    KeyLess,
    KeyEquals,
    KeyGreater,
    KeyQuestion,
    KeyAt,
    KeyLeftBracket,
    KeyBackslash,
    KeyRightBracket,
    KeyCaret,
    KeyUnderscore,
    KeyBackquote,
    KeyA,
    KeyB,
    KeyC,
    KeyD,
    KeyE,
    KeyF,
    KeyG,
    KeyH,
    KeyI,
    KeyJ,
    KeyK,
    KeyL,
    KeyM,
    KeyN,
    KeyO,
    KeyP,
    KeyQ,
    KeyR,
    KeyS,
    KeyT,
    KeyU,
    KeyV,
    KeyW,
    KeyX,
    KeyY,
    KeyZ,
    KeyDelete,
    KeyCapsLock,
    KeyF1,
    KeyF2,
    KeyF3,
    KeyF4,
    KeyF5,
    KeyF6,
    KeyF7,
    KeyF8,
    KeyF9,
    KeyF10,
    KeyF11,
    KeyF12,
    KeyPrintScreen,
    KeyScrollLock,
    KeyPause,
    KeyInsert,
    KeyHome,
    KeyPageUp,
    KeyEnd,
    KeyPageDown,
    KeyRight,
    KeyLeft,
    KeyDown,
    KeyUp,
    KeyNumLockClear,
    KeyKpDivide,
    KeyKpMultiply,
    KeyKpMinus,
    KeyKpPlus,
    KeyKpEnter,
    KeyKp1,
    KeyKp2,
    KeyKp3,
    KeyKp4,
    KeyKp5,
    KeyKp6,
    KeyKp7,
    KeyKp8,
    KeyKp9,
    KeyKp0,
    KeyKpPeriod,
    KeyApplication,
    KeyPower,
    KeyKpEquals,
    KeyF13,
    KeyF14,
    KeyF15,
    KeyF16,
    KeyF17,
    KeyF18,
    KeyF19,
    KeyF20,
    KeyF21,
    KeyF22,
    KeyF23,
    KeyF24,
    KeyExecute,
    KeyHelp,
    KeyMenu,
    KeySelect,
    KeyStop,
    KeyAgain,
    KeyUndo,
    KeyCut,
    KeyCopy,
    KeyPaste,
    KeyFind,
    KeyMute,
    KeyVolumeUp,
    KeyVolumeDown,
    KeyKpComma,
    KeyKpEqualsAS400,
    KeyAltErase,
    KeySysreq,
    KeyCancel,
    KeyClear,
    KeyPrior,
    KeyReturn2,
    KeySeparator,
    KeyOut,
    KeyOper,
    KeyClearAgain,
    KeyCrSel,
    KeyExSel,
    KeyKp00,
    KeyKp000,
    KeyThousandsSeparator,
    KeyDecimalSeparator,
    KeyCurrencyUnit,
    KeyCurrencySubUnit,
    KeyKpLeftParen,
    KeyKpRightParen,
    KeyKpLeftBrace,
    KeyKpRightBrace,
    KeyKpTab,
    KeyKpBackspace,
    KeyKpA,
    KeyKpB,
    KeyKpC,
    KeyKpD,
    KeyKpE,
    KeyKpF,
    KeyKpXor,
    KeyKpPower,
    KeyKpPercent,
    KeyKpLess,
    KeyKpGreater,
    KeyKpAmpersand,
    KeyKpDblAmpersand,
    KeyKpVerticalBar,
    KeyKpDblVerticalBar,
    KeyKpColon,
    KeyKpHash,
    KeyKpSpace,
    KeyKpAt,
    KeyKpExclam,
    KeyKpMemStore,
    KeyKpMemRecall,
    KeyKpMemClear,
    KeyKpMemAdd,
    KeyKpMemSubtract,
    KeyKpMemMultiply,
    KeyKpMemDivide,
    KeyKpPlusMinus,
    KeyKpClear,
    KeyKpClearEntry,
    KeyKpBinary,
    KeyKpOctal,
    KeyKpDecimal,
    KeyKpHexadecimal,
    KeyLCtrl,
    KeyLShift,
    KeyLAlt,
    KeyLGui,
    KeyRCtrl,
    KeyRShift,
    KeyRAlt,
    KeyRGui,
    KeyMode,
    KeyAudioNext,
    KeyAudioPrev,
    KeyAudioStop,
    KeyAudioPlay,
    KeyAudioMute,
    KeyMediaSelect,
    KeyWww,
    KeyMail,
    KeyCalculator,
    KeyComputer,
    KeyAcSearch,
    KeyAcHome,
    KeyAcBack,
    KeyAcForward,
    KeyAcStop,
    KeyAcRefresh,
    KeyAcBookmarks,
    KeyBrightnessDown,
    KeyBrightnessUp,
    KeyDisplaySwitch,
    KeyKbdIllumToggle,
    KeyKbdIllumDown,
    KeyKbdIllumUp,
    KeyEject,
    KeySleep,
}
