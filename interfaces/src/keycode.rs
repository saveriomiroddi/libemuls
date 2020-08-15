// Ripped off from the SDL crate 😬
//
// True/false for key pressed/released.
//
pub enum Keycode {
    Backspace(bool),
    Tab(bool),
    Return(bool),
    Escape(bool),
    Space(bool),
    Exclaim(bool),
    Quotedbl(bool),
    Hash(bool),
    Dollar(bool),
    Percent(bool),
    Ampersand(bool),
    Quote(bool),
    LeftParen(bool),
    RightParen(bool),
    Asterisk(bool),
    Plus(bool),
    Comma(bool),
    Minus(bool),
    Period(bool),
    Slash(bool),
    Num0(bool),
    Num1(bool),
    Num2(bool),
    Num3(bool),
    Num4(bool),
    Num5(bool),
    Num6(bool),
    Num7(bool),
    Num8(bool),
    Num9(bool),
    Colon(bool),
    Semicolon(bool),
    Less(bool),
    Equals(bool),
    Greater(bool),
    Question(bool),
    At(bool),
    LeftBracket(bool),
    Backslash(bool),
    RightBracket(bool),
    Caret(bool),
    Underscore(bool),
    Backquote(bool),
    A(bool),
    B(bool),
    C(bool),
    D(bool),
    E(bool),
    F(bool),
    G(bool),
    H(bool),
    I(bool),
    J(bool),
    K(bool),
    L(bool),
    M(bool),
    N(bool),
    O(bool),
    P(bool),
    Q(bool),
    R(bool),
    S(bool),
    T(bool),
    U(bool),
    V(bool),
    W(bool),
    X(bool),
    Y(bool),
    Z(bool),
    Delete(bool),
    CapsLock(bool),
    F1(bool),
    F2(bool),
    F3(bool),
    F4(bool),
    F5(bool),
    F6(bool),
    F7(bool),
    F8(bool),
    F9(bool),
    F10(bool),
    F11(bool),
    F12(bool),
    PrintScreen(bool),
    ScrollLock(bool),
    Pause(bool),
    Insert(bool),
    Home(bool),
    PageUp(bool),
    End(bool),
    PageDown(bool),
    Right(bool),
    Left(bool),
    Down(bool),
    Up(bool),
    NumLockClear(bool),
    KpDivide(bool),
    KpMultiply(bool),
    KpMinus(bool),
    KpPlus(bool),
    KpEnter(bool),
    Kp1(bool),
    Kp2(bool),
    Kp3(bool),
    Kp4(bool),
    Kp5(bool),
    Kp6(bool),
    Kp7(bool),
    Kp8(bool),
    Kp9(bool),
    Kp0(bool),
    KpPeriod(bool),
    Application(bool),
    Power(bool),
    KpEquals(bool),
    F13(bool),
    F14(bool),
    F15(bool),
    F16(bool),
    F17(bool),
    F18(bool),
    F19(bool),
    F20(bool),
    F21(bool),
    F22(bool),
    F23(bool),
    F24(bool),
    Execute(bool),
    Help(bool),
    Menu(bool),
    Select(bool),
    Stop(bool),
    Again(bool),
    Undo(bool),
    Cut(bool),
    Copy(bool),
    Paste(bool),
    Find(bool),
    Mute(bool),
    VolumeUp(bool),
    VolumeDown(bool),
    KpComma(bool),
    KpEqualsAS400(bool),
    AltErase(bool),
    Sysreq(bool),
    Cancel(bool),
    Clear(bool),
    Prior(bool),
    Return2(bool),
    Separator(bool),
    Out(bool),
    Oper(bool),
    ClearAgain(bool),
    CrSel(bool),
    ExSel(bool),
    Kp00(bool),
    Kp000(bool),
    ThousandsSeparator(bool),
    DecimalSeparator(bool),
    CurrencyUnit(bool),
    CurrencySubUnit(bool),
    KpLeftParen(bool),
    KpRightParen(bool),
    KpLeftBrace(bool),
    KpRightBrace(bool),
    KpTab(bool),
    KpBackspace(bool),
    KpA(bool),
    KpB(bool),
    KpC(bool),
    KpD(bool),
    KpE(bool),
    KpF(bool),
    KpXor(bool),
    KpPower(bool),
    KpPercent(bool),
    KpLess(bool),
    KpGreater(bool),
    KpAmpersand(bool),
    KpDblAmpersand(bool),
    KpVerticalBar(bool),
    KpDblVerticalBar(bool),
    KpColon(bool),
    KpHash(bool),
    KpSpace(bool),
    KpAt(bool),
    KpExclam(bool),
    KpMemStore(bool),
    KpMemRecall(bool),
    KpMemClear(bool),
    KpMemAdd(bool),
    KpMemSubtract(bool),
    KpMemMultiply(bool),
    KpMemDivide(bool),
    KpPlusMinus(bool),
    KpClear(bool),
    KpClearEntry(bool),
    KpBinary(bool),
    KpOctal(bool),
    KpDecimal(bool),
    KpHexadecimal(bool),
    LCtrl(bool),
    LShift(bool),
    LAlt(bool),
    LGui(bool),
    RCtrl(bool),
    RShift(bool),
    RAlt(bool),
    RGui(bool),
    Mode(bool),
    AudioNext(bool),
    AudioPrev(bool),
    AudioStop(bool),
    AudioPlay(bool),
    AudioMute(bool),
    MediaSelect(bool),
    Www(bool),
    Mail(bool),
    Calculator(bool),
    Computer(bool),
    AcSearch(bool),
    AcHome(bool),
    AcBack(bool),
    AcForward(bool),
    AcStop(bool),
    AcRefresh(bool),
    AcBookmarks(bool),
    BrightnessDown(bool),
    BrightnessUp(bool),
    DisplaySwitch(bool),
    KbdIllumToggle(bool),
    KbdIllumDown(bool),
    KbdIllumUp(bool),
    Eject(bool),
    Sleep(bool),
}