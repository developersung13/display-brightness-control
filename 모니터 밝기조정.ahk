#Persistent
#SingleInstance Force
#NoEnv
;SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Gui Add, GroupBox, x11 y10 w255 h137, % " 조작 "
Gui Font, cNavy
Gui Add, Text, x31 y41 w39 h23 +0x200, 밝기:
Gui Font, cDefault
Gui Add, Text, vbrightness x80 y41 w43 h23 +0x200, 128
Gui Add, Slider, vsl_brightness gsl_brightness x24 y68 w230 h32 Range0-255 AltSubmit, 128
Gui Font, c0xFF2D00
Gui Add, CheckBox, vcb_autoTime gcb_autoTime x32 y106 w123 h24, 시간별 자동조정
Gui Add, Button, vbt_reset gbt_reset x168 y105 w80 h25, Reset
Gui Add, Button, vbt_passive gbt_passive x10 y154 w256 h25 +Disabled, 시간대 수동 지정
Gui Show, w281 h189 x1620 y15, 모니터 밝기조정

Gui, 2: Font, cRed
Gui, 2: Add, GroupBox, x8 y10 w233 h63, % " 밝기 상승 시간 "
Gui, 2: Font, cDefault
Gui, 2: Add, ComboBox, vcb_hour1 x15 y44 w40 Choose7, 00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23
Gui, 2: Add, ComboBox, vcb_min1 x90 y44 w40 Choose1, 00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59
Gui, 2: Add, ComboBox, vcb_sec1 x165 y44 w40 Choose1, 00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59
Gui, 2: Add, Text, x58 y44 w15 h23 +0x200, 시
Gui, 2: Add, Text, x133 y44 w15 h23 +0x200, 분
Gui, 2: Add, Text, x208 y44 w14 h23 +0x200, 초
Gui, 2: Font, cBlue
Gui, 2: Add, GroupBox, x8 y87 w233 h63, % " 밝기 하강 시간 "
Gui, 2: Font, cDefault
Gui, 2: Add, ComboBox, vcb_hour2 x15 y119 w40 Choose19, 00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23
Gui, 2: Add, ComboBox, vcb_min2 x90 y120 w40 Choose31, 00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59
Gui, 2: Add, ComboBox, vcb_sec2 x165 y120 w40 Choose1, 00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59
Gui, 2: Add, Text, x58 y118 w15 h23 +0x200, 시
Gui, 2: Add, Text, x133 y120 w15 h23 +0x200, 분
Gui, 2: Add, Text, x208 y120 w14 h23 +0x200, 초
Gui, 2: Add, Button, vbt_setting gbt_setting x161 y157 w80 h23, Set
Gui, 2: Add, Button, vbt_reset2 gbt_reset2 x77 y157 w80 h23, Reset
    
; ============Thread===============

Loop {
    run_time = %A_Hour%:%A_Min%:%A_Sec%
    if(run_time = setTimeUp)
    {
        Loop, 45 {
            AdjustBrightness(1)
            value := DisplayGetBrightness() + 1
            GuiControl,, sl_brightness, %value%
            GuiControl,, brightness, %value%
            Sleep, 50
        }
    } else if(run_time = setTimeDown) {
        Loop, 46 {
            AdjustBrightness(-1)
            value := DisplayGetBrightness() - 1
            GuiControl,, sl_brightness, %value%
            GuiControl,, brightness, %value%
            Sleep, 50
        }  
    }
}

; ================================  Function  ============================

AdjustBrightness(V) {
    SB := (SB := DisplayGetBrightness() + V) > 255 ? 255 : SB < 0 ? 0 : SB
    DisplaySetBrightness(SB)
}

DisplaySetBrightness(SB := 128) {
    loop % VarSetCapacity(GB, 1536) / 6
        NumPut((N := (SB + 128) * (A_Index - 1)) > 65535 ? 65535 : N, GB, 2 * (A_Index - 1), "UShort")
    DllCall("RtlMoveMemory", "Ptr", &GB +  512, "Ptr", &GB, "UPtr", 512, "Ptr")
    , DllCall("RtlMoveMemory", "Ptr", &GB + 1024, "Ptr", &GB, "UPtr", 512, "Ptr")
    return DllCall("gdi32.dll\SetDeviceGammaRamp", "Ptr", hDC := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "Ptr", &GB), DllCall("user32.dll\ReleaseDC", "Ptr", 0, "Ptr", hDC)
}

DisplayGetBrightness(ByRef GB := "") {
    VarSetCapacity(GB, 1536, 0)
    , DllCall("gdi32.dll\GetDeviceGammaRamp", "Ptr", hDC := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "Ptr", &GB)
    return NumGet(GB, 2, "UShort") - 128, DllCall("user32.dll\ReleaseDC", "Ptr", 0, "Ptr", hDC)
}

; 모니터 밝기를 평균으로 설정하는 함수
DisplaySetBrightnessAverage() { 
    DisplaySetBrightness(128)
    GuiControl,,  sl_brightness, 128
    GuiControl,, brightness, 128   
}

; ===========-Short Cut=============

#WheelUp::
    AdjustBrightness(10)
    value := DisplayGetBrightness() + 10
    if(value > 255)
        value = 255
    GuiControl,, sl_brightness, %value%
    GuiControl,, brightness, %value%
Return

#WheelDown::
    AdjustBrightness(-10)
    value := DisplayGetBrightness() - 10
    if(value < 0)
        value = 0
    GuiControl,, sl_brightness, %value%
    GuiControl,, brightness, %value%
Return

#n::
    DisplaySetBrightnessAverage() 
Return

; ==============Event================

sl_brightness:
    DisplaySetBrightness(sl_brightness)
    GuiControl,, brightness, %sl_brightness%
Return

cb_autoTime:
    Gui, Submit, Nohide
    if(cb_autoTime = 1)
    {
        Gui, 2: Submit, Nohide
        setTimeUp := cb_hour1 . ":" . cb_min1 . ":" . cb_sec1
        setTimeDown := cb_hour2 . ":" . cb_min2 . ":" . cb_sec2
        GuiControl, Disable, sl_brightness
        GuiControl, Enable, bt_passive
        DisplaySetBrightnessAverage()
    } else if(cb_autoTime = 0) {
        setTimeUp := "?"
        setTimeDown := "?"
        Gui, 2: Hide
        GuiControl, Enable, sl_brightness
        GuiControl, Disable, bt_passive
    }
Return

bt_reset:
    setTimeUp := "?"
    setTimeDown := "?"
    Gui, 2: Hide
    DisplaySetBrightnessAverage()
    GuiControl,, cb_autoTime, 0
    GuiControl, Enable, sl_brightness
    GuiControl, Disable, bt_passive
Return

bt_passive:
    Gui, 2: Show, w254 h189 x1360 y15, 시간대 수동조정
Return
    
bt_reset2:
    GuiControl, Choose, cb_hour1, 7
    GuiControl, Choose, cb_min1, 1
    GuiControl, Choose, cb_sec1, 1
    GuiControl, Choose, cb_hour2, 19
    GuiControl, Choose, cb_min2, 31
    GuiControl, Choose, cb_sec2, 1
Return

bt_setting:
    MsgBox, 64, 완료, 설정완료, 1
    Gui, 2: Submit, Nohide
    setTimeUp := cb_hour1 . ":" . cb_min1 . ":" . cb_sec1
    setTimeDown := cb_hour2 . ":" . cb_min2 . ":" . cb_sec2
Return

GuiEscape:
GuiClose:
    ExitApp