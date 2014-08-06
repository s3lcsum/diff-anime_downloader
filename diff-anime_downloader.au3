; ===============================================================================================================================
; Title .........: diff-anime_downloader
; AutoIt Version : 1.0
; Language ......: Polski
; Author(s) .....: siewniczek
; ===============================================================================================================================

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <INet.au3>
#include <IE.au3>

$metadane = 0
Dim $page_source, $string, $min, $max, $sTxt, $get

$Form1 = GUICreate("Diff-Anime Downloader 1.0", 403, 540, 731, 222, -1, BitOR($WS_EX_OVERLAPPEDWINDOW, $WS_EX_TRANSPARENT, $WS_EX_WINDOWEDGE))
$Label1 = GUICtrlCreateLabel("Diff-Anime", 80, 24, 364, 49)
GUICtrlSetFont(-1, 40)

$Label2 = GUICtrlCreateLabel("Link do strony:", 8, 99, 100, 17)
$Input1 = GUICtrlCreateInput("", 80, 96, 299, 21)

$Label3 = GUICtrlCreateLabel("Nazwa pliku:", 14, 147, 100, 17)
$Input2 = GUICtrlCreateInput("", 81, 144, 299, 21)

$Label4 = GUICtrlCreateLabel("Folder zapisu:", 10, 195, 100, 17)
$Input3 = GUICtrlCreateInput("", 80, 192, 219, 21)
$Button3 = GUICtrlCreateButton("Wybierz", 304, 190, 75, 25)

$Label5 = GUICtrlCreateLabel("Od:", 100, 243, 36, 17)
$Combo1 = GUICtrlCreateCombo("", 120, 240, 49, 25)
$Label6 = GUICtrlCreateLabel("Do:", 228, 243, 36, 17)
$Combo2 = GUICtrlCreateCombo("", 248, 240, 49, 25)

$Button1 = GUICtrlCreateButton("Pobierz metadane", 280, 288, 105, 105)
$Button2 = GUICtrlCreateButton("Wyjdź", 280, 416, 105, 105)
$Edit1 = GUICtrlCreateEdit("", 16, 288, 257, 233, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
GUISetState(@SW_SHOW)

_del_meta()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button2
			Exit
		Case $Button1
			If $metadane = 0 Then
				_down_meta()
			ElseIf $metadane = 1 Then
				_down_epis(GUICtrlRead($Combo1), GUICtrlRead($Combo2))
			ElseIf $metadane = 2 Then
				_del_meta()
			EndIf
		Case $Button3
			$dir = FileSelectFolder("Wybierz folder w którym mają znajdować się pobrane pliki.", "")
			GUICtrlSetData($Input3, $dir)
	EndSwitch
WEnd

Func _down_meta()
	$page_source = _INetGetSource(GUICtrlRead($Input1))
	$page_source = _ANSI2UNICODE($page_source)

	$title = $page_source
	$title = StringTrimLeft($title, StringInStr($title, "<h2>", 0) + 3)
	$title = StringLeft($title, StringInStr($title, "</h2>", 0) - 1)
	GUICtrlSetData($Input2, "[DIFF-ANIME]" & $title & "_PL_%i")
	GUICtrlSetData($Input3, "Folder w którym bedą zapisane anime.")

	_log("####################")
	_log("# Tytuł: " & $title)
	_write_meta("Typ:")
	_write_meta("Wersja:")
	_write_meta("Odcinków:")
	For $i = 1 To $string
		$id = $i
		$min = "1"
		If StringLen($string) = 2 Then
			$min = "01"
			If StringLen($i) = 1 Then
				$id = "0" & $id
			EndIf
		ElseIf StringLen($string) = 3 Then
			$min = "001"
			If StringLen($i) = 1 Then
				$id = "00" & $id
			ElseIf StringLen($i) = 2 Then
				$id = "0" & $id
			EndIf
		ElseIf StringLen($string) = 4 Then
			$min = "0001"
			If StringLen($i) = 1 Then
				$id = "000" & $id
			ElseIf StringLen($i) = 2 Then
				$id = "00" & $id
			ElseIf StringLen($i) = 3 Then
				$id = "0" & $id
			EndIf
		EndIf
		GUICtrlSetData($Combo1, $id, $min)
		GUICtrlSetData($Combo2, $id, $id)
	Next
	$max = $string
	_write_meta("Status:")
	_write_meta("Rok:")
	_write_meta("Sezon:")
	_log("####################")

	$metadane = 1
	GUICtrlSetData($Button1, "Pobierz odcinki")
	GUICtrlSetState($Input2, $GUI_ENABLE)
	GUICtrlSetState($Input3, $GUI_ENABLE)
	GUICtrlSetState($Button3, $GUI_ENABLE)
	GUICtrlSetState($Combo1, $GUI_ENABLE)
	GUICtrlSetState($Combo2, $GUI_ENABLE)
EndFunc   ;==>_down_meta

Func _write_meta($what)
	$string = $page_source
	$string = StringTrimLeft($string, StringInStr($string, $what, 0) + StringLen($what) + 7)
	$string = StringLeft($string, StringInStr($string, "</p>", 0) - 1)
	_log("# " & $what & " " & $string)
	Global $string
EndFunc   ;==>_write_meta

Func _down_epis($from = $min, $to = $max)
	GUICtrlSetData($Button2, "Zatrzymaj pobieranie")
	GUICtrlSetState($Input1, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_DISABLE)
	GUICtrlSetState($Input3, $GUI_DISABLE)
	GUICtrlSetState($Button1, $GUI_DISABLE)
	GUICtrlSetState($Button3, $GUI_DISABLE)
	GUICtrlSetState($Combo1, $GUI_DISABLE)
	GUICtrlSetState($Combo2, $GUI_DISABLE)

	For $i = $from To $to
		GUICtrlSetState($Button2, $GUI_DISABLE)
		If StringLen($from) = 2 Then
			If $i < 10 Then
				$i = "0" & $i
			EndIf
		ElseIf StringLen($from) = 3 Then
			If $i < 10 Then
				$i = "00" & $i
			ElseIf $i < 100 And $i > 9 Then
				$i = "0" & $i
			EndIf
		ElseIf StringLen($from) = 4 Then
			If $i < 10 Then
				$i = "000" & $i
			ElseIf $i < 100 And $i > 9 Then
				$i = "00" & $i
			ElseIf $i < 1000 And $i > 99 Then
				$i = "0" & $i
			EndIf
		EndIf
		$source = $page_source
		$source = StringTrimLeft($source, StringInStr($source, ">#" & $i, 0))
		$link = $source
		$source = StringLeft($source, StringInStr($source, "</div><div class", 0) - 1)
		$link = StringTrimLeft($link, StringInStr($link, "con4", 0) + 14)
		$link = StringLeft($link, StringInStr($link, "target=", 0) - 13)
		_log("# " & $i & " Przechodzenie przez ad.fly")
		$source = _IECreate($link, 0, 0, 1, 0)
		Sleep(10000)
		$oLinks = _IELinkGetCollection($source)
		For $oLink In $oLinks
			$link &= $oLink.href & @CRLF
		Next
		$link = StringLeft($link, StringInStr($link, ".mp4", 0) + 4)
		$link = StringTrimLeft($link, StringInStr($link, "http://", 0, -1) - 1)
		_IEQuit($source)
		$j = StringReplace(GUICtrlRead($Input2), "%i", $i)
		$Size = InetGetSize($link)
		_log("# " & $i & " Waga pliku: " & Ceiling(($Size / 1024)/1000) & " MB")
		$txt = GUICtrlRead($Edit1)
		$get = InetGet($link, GUICtrlRead($Input3) & "\" & $j & ".mp4", 1, 1)

		GUICtrlSetState($Button2, $GUI_ENABLE)
		Do
			GUICtrlSetData($Edit1, "# " & $i & " Pobieranie..." & Ceiling((InetGetInfo($get, 0) * 100 / $Size)) & "%" & @CRLF & $txt)
			$nMsg = GUIGetMsg()
			If $nMsg = $Button2 Then
				InetClose($get)
				GUICtrlSetData($Button2, "Wyjdź")
				_log("# ZATRZYMANO POBIERANIE ! ! ! ")
				GUICtrlSetState($Input1, $GUI_ENABLE)
				GUICtrlSetState($Input2, $GUI_ENABLE)
				GUICtrlSetState($Input3, $GUI_ENABLE)
				GUICtrlSetState($Button1, $GUI_ENABLE)
				GUICtrlSetState($Button3, $GUI_ENABLE)
				GUICtrlSetState($Combo1, $GUI_ENABLE)
				GUICtrlSetState($Combo2, $GUI_ENABLE)
				$zakoncz = 1
				ExitLoop
			EndIf
		Until InetGetInfo($get, 2)
		InetClose($get)
		If $zakoncz = 1 Then ExitLoop
	Next
	$zakoncz = 0
	$metadane = 2
	GUICtrlSetData($Button1, "Usuń metadane")
EndFunc   ;==>_down_epis

Func _del_meta()

	$metadane = 0
	GUICtrlSetData($Button1, "Pobierz metadane")
	GUICtrlSetState($Input2, $GUI_DISABLE)
	GUICtrlSetState($Input3, $GUI_DISABLE)
	GUICtrlSetState($Button3, $GUI_DISABLE)
	GUICtrlSetState($Combo1, $GUI_DISABLE)
	GUICtrlSetState($Combo2, $GUI_DISABLE)
EndFunc   ;==>_del_meta

Func _ANSI2UNICODE($sString = "")
	Local Const $SF_ANSI = 1
	Local Const $SF_UTF8 = 4
	Return BinaryToString(StringToBinary($sString, $SF_ANSI), $SF_UTF8)
EndFunc   ;==>_ANSI2UNICODE

Func _log($log)
	GUICtrlSetData($Edit1, $log & @CRLF & GUICtrlRead($Edit1))
EndFunc   ;==>_log
