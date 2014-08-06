; ===============================================================================================================================
; Title .........: diff-anime_downloader
; AutoIt Version : 1.1
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
#include <Timers.au3>
#include <IE.au3>

$Form1 =  GUICreate("Diff-Anime Downloader 1.1 by S3LCSUM", 407, 594, -1, -1, -1, BitOR($WS_EX_OVERLAPPEDWINDOW, $WS_EX_TRANSPARENT, $WS_EX_WINDOWEDGE))
GUISetBkColor(0xf4f4f4)
$Label1 = GUICtrlCreateLabel("Diff-Anime", 80, 24, 364, 49)
GUICtrlSetFont(-1, 40)

$Label2 = GUICtrlCreateLabel("Link do strony:", 8, 99, 100, 17)
$Input1 = GUICtrlCreateInput("", 80, 96, 299, 21)
GUICtrlSetTip(-1, "Gdy będzie brakowało kóncówki '/odcinki'" & @CRLF & "zostanie ona dodana automatycznie" & @CRLF & @CRLF & "Gdy będzie brakowało początku 'htpp://'" & @CRLF & "zostanie on dodany automatycznie", "WYJAŚNIENIE")

$Label3 = GUICtrlCreateLabel("Nazwa pliku:", 14, 147, 100, 17)
$Input2 = GUICtrlCreateInput("", 81, 144, 299, 21)
GUICtrlSetTip(-1,"%i zastępuje numer odcinka", "WYJAŚNIENIE")

$Label4 = GUICtrlCreateLabel("Folder zapisu:", 10, 195, 100, 17)
$Input3 = GUICtrlCreateInput("", 80, 192, 219, 21)
GUICtrlSetTip(-1,"Wybrany katalog musi istnieć!", "WARUNEK")
$Button3 = GUICtrlCreateButton("Wybierz", 304, 190, 75, 25)

$Label5 = GUICtrlCreateLabel("Od:", 100, 243, 36, 17)
$Combo1 = GUICtrlCreateCombo("", 120, 240, 49, 25)
$Label6 = GUICtrlCreateLabel("Do:", 228, 243, 36, 17)
$Combo2 = GUICtrlCreateCombo("", 248, 240, 49, 25)

$Checkbox1 = GUICtrlCreateCheckbox("", 280, 288, 15, 38)
$Label4 = GUICtrlCreateLabel("Wyłącz komputer po zakończeniu pobierania.", 300, 288,90,38)
$Button1 = GUICtrlCreateButton("", 280, 352, 105, 105)
$Button2 = GUICtrlCreateButton("Wyjdź", 280, 480, 105, 105)
$Edit1 = GUICtrlCreateEdit("", 16, 282, 257, 303, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$ES_WANTRETURN,$WS_VSCROLL))
GUISetState(@SW_SHOW)

; deklaracja początkowych wartości dla tych zmiennych
$dev = 1 ; gdy ma wartość "1" error logi nie powodują wyjść z funkcji oraz zamknnięcia komputera
$metadane = 0
$zakoncz = 0
Dim $page_source, $string, $min, $max, $sTxt, $get ; tworzenie zmiennych bez deklaracji

_del_meta() ; punkt startowy programu

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button2
			IF $zakoncz = 1 Then
				_del_meta()
			ElseIf $zakoncz = 0 Then
				Exit
			EndIf
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
	$link = GUICtrlRead($Input1)
	If StringInStr($link, "http://") = 0 Then $link = "htpp://" & $link
	If StringInStr($link, "/odcinki") = 0 Then $link &= "/odcinki"
	GUICtrlSetData($Input1, $link)
	; pobieranie kodu źródłowego strony podanej w $Input1 oraz przeformatowanie go z ANSI na UNICODE
	$page_source = _INetGetSource($link)
	$page_source = _ANSI2UNICODE($page_source)
	If $page_source = "" Then  ; ERROR LOG
		_log("")
		_log("Bład podczas łączenia się ze stroną.")
		_log("ERROR:")
		_log("")
		_del_meta()
		If $dev = 0 Then Return
			; ^^^ NOTE: Return = zwrócenie wartości funkcji, w tym wypadku zatrzymanie jej dalszego wykonywania
	EndIf

	; wyciąganie tytułu serii z linku
	$title = $page_source
	$title = StringTrimLeft($title, StringInStr($title, "<h2>", 0) + 3)
	$title = StringLeft($title, StringInStr($title, "</h2>", 0) - 1)
	If $title = "" OR StringLen($title) > 150 Then ; ERROR LOG
		_log("")
		_log("Bład wyciągania metadanych z kodu strony")
		_log("ERROR:")
		_log("")
		_del_meta()
		If $dev = 0 Then Return
	EndIf

	GUICtrlSetData($Input2, "[DIFF-ANIME]" & $title & "_PL_%i")
	GUICtrlSetData($Input3, "Folder w którym bedą zapisane anime.")

	; wypisanie kolejnych danych dot. serii podanej w linku
	_log("####################")
	_log("# Tytuł: " & $title)
	_write_meta("Typ:")
	_write_meta("Wersja:")
	_write_meta("Odcinków:")
	; dodawanie zer do wypełnień $Combo1 oraz $Combo2
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
		GUICtrlSetData($Combo1, $id, $min) ; nadanie wartości $Combo1 z domyślną $min
		GUICtrlSetData($Combo2, $id, $id) ; nadanie wartości $Combo2 z domyślnie ostatnią dodaną wartością
	Next
	$max = $string
	_write_meta("Status:")
	_write_meta("Rok:")
	_write_meta("Sezon:")
	_log("####################")

	GUICtrlSetState($Input1, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_ENABLE)
	GUICtrlSetState($Input3, $GUI_ENABLE)
	GUICtrlSetState($Button3, $GUI_ENABLE)
	GUICtrlSetState($Combo1, $GUI_ENABLE)
	GUICtrlSetState($Combo2, $GUI_ENABLE)

	; zmiana funkcji $Button1
	$metadane = 1
	GUICtrlSetData($Button1, "Pobierz odcinki")
EndFunc   ;==>_down_meta

Func _write_meta($what)
	$string = $page_source
	$string = StringTrimLeft($string, StringInStr($string, $what, 0) + StringLen($what) + 7)
	$string = StringLeft($string, StringInStr($string, "</p>", 0) - 1)
	_log("# " & $what & " " & $string)
	Global $string
EndFunc   ;==>_write_meta

;###################################################################
; Funckja __down_epis($from, $to)
; W tej funkcji zostają pobrane kolejne episody licząc od $from, do $to
Func _down_epis($from = $min, $to = $max)
	; zablokowanie wprowadzania jakichkolwiek zmian w celu uniknięcia błędów
	GUICtrlSetData($Button2, "Zatrzymaj pobieranie")
	GUICtrlSetState($Input1, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_DISABLE)
	GUICtrlSetState($Input3, $GUI_DISABLE)
	GUICtrlSetState($Button1, $GUI_DISABLE)
	GUICtrlSetState($Button3, $GUI_DISABLE)
	GUICtrlSetState($Combo1, $GUI_DISABLE)
	GUICtrlSetState($Combo2, $GUI_DISABLE)
	GUICtrlSetState($Button2, $GUI_DISABLE)

	For $i = $from To $to

		; dodawanie zer do numerowania
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

		; ######################
		; ####### AD.FLY #######
		; ######################
		; wyciąganie z kodu źrodłowego strony linku ad.fly, dla odcinka odpowiadającego numerowi $i
		$source = $page_source
		$source = StringTrimLeft($source, StringInStr($source, ">#" & $i, 0))
		$link = $source
		$source = StringLeft($source, StringInStr($source, "</div><div class", 0) - 1)
		$link = StringTrimLeft($link, StringInStr($link, "con4", 0) + 14)
		$link = StringLeft($link, StringInStr($link, "target=", 0) - 13)

		; otwarcie przeglądarki w tle, z adresem ad.fly wyciągniętym powyzej
		$source = _IECreate($link, 0, 0, 1, 0) ; otwarta w tle, z oczekiwaniem na załadowanie strony
		If @error Then ; ERROR LOG
			_log("")
			_log("   jeśli nie to masz przejebane.")
			_log("   czy poprawnie działają strony ad.fly")
			_log(" - sprawdź poprzez przeglądarkę IE")
			_log("")
			_log("   Internet Explorer 8 lub wyzszy.")
			_log(" - do prawidłowego działania wymagany:")
			_log("Bład bilbioteki <IE.au3>")
			_log("ERROR:")
			_log("")
			_del_meta()
			If $dev = 0 Then Return
		EndIf
		$precent = 0
		$txt = GUICtrlRead($Edit1)

		; oczekiwanie na pojewienie się SKIP BUTTON
		Do
			$precent += 100
			GUICtrlSetData($Edit1, "# " & $i & " Przechodzenie Ad.fly..." & $precent & "%" & @CRLF & $txt)
			If $precent = 100 Then GUICtrlSetData($Edit1, "# " & $i & " Przeszedłem Ad.fly." & @CRLF & $txt)
			Sleep(1000)
		Until $precent >= 100

		; wyciaganie wszystkich linków dostępnych na stronie
		$oLinks = _IELinkGetCollection($source)
		For $oLink In $oLinks
			$link &= $oLink.href & @CRLF
		Next

		; wycinanie linku kończącego się na ".mp4"
		$link = StringLeft($link, StringInStr($link, ".mp4", 0) + 4)
		$link = StringTrimLeft($link, StringInStr($link, "http://", 0, -1) - 1)

		; zamykanie przeglądarki z Ad.fly
		_IEQuit($source)
		; ######################

		; odczytywanie nazwy pod jaką ma zostać zapisany pobrany plik
		$j = StringReplace(GUICtrlRead($Input2), "%i", $i) ; wyszukiwanie "%i" oraz podmiana go na numer obecnie pobieraniego odcinka
		$Size = InetGetSize($link)
		_log("# " & $i & " Waga pliku: " & Ceiling(($Size / 1024) / 1000) & " MB")
					; ^^^ NOTE: Celing - zmienna zwracająca najblizszą liczbę całkowitą
		$txt = GUICtrlRead($Edit1)
		$get = InetGet($link, GUICtrlRead($Input3) & "\" & $j & ".mp4", 1, 1)
					; ^^^ pobieranie pliku z adresu $link, do wybranej z sciezki z nazwą pliku $j, pobieraj w tle, nie czekaj na zakonczenie
		$timer = TimerInit() ; Uruchomienie stopera
		GUICtrlSetState($Button2, $GUI_ENABLE) ; Odblokuj przycisk umozliwiajacy zatrzymanie pobierania
		Do ; <== petla wykonujaca sie dopóki pobieranie z uchwytem $get jest aktywne
			$precent = Ceiling((InetGetInfo($get, 0) * 100 / $Size))
			GUICtrlSetData($Edit1, "# " & $i & " Pobieranie..." & $precent & "%" & @CRLF & $txt)
			Sleep(1000)
			If $precent = 100 Then
				$time_ms = Ceiling(TimerDiff($timer))
				$time_s = Ceiling($time_ms/1000)
				$time_min = Round($time_s / 60)
				If $time_min < 10 Then $time_min = "0" & $time_min
				If $time_s < 10 Then $time_s = "0" & $time_s
				GUICtrlSetData($Edit1, "# " & $i & " Pobrano odcinek w " & $time_min  & ":" & $time_s & @CRLF & $txt)
			EndIf
			; nasłuchiwanie przycisku zatrzymującego pobieranie
			If GUIGetMsg() = $Button2 Then
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
				ExitLoop ; wyjście z pętli czekającej na zakończenie pobierania
			EndIf
		Until InetGetInfo($get, 2)
		InetClose($get) ; zatrzymajnie uchwytu $get, (zwolnienie pamięci, oraz zatrzymanie w przypadku niedokończonego pobierania)
		_log("####################")
		If $zakoncz = 1 Then ExitLoop
	Next

	If $zakoncz = 0 Then ; gdy pobrano wszystkie odcinki i nie wciśnieto przycisku zatrzymania
		_log("# Pobrano wszystkie odcinki.")
		_log("####################")
		; Sprawdzenie czy $Checkbox1 jest zaznaczony
		If GuiCtrlRead($Checkbox1) = $GUI_CHECKED Then
			_log("")
			_log("")
			_log("")
			_log("# Wprowadzanie polecenia do systemu:")
			_log("# wyłącz komputer.")

			Run("C:\WINDOWS\system32\cmd.exe")
			WinWaitActive("C:\WINDOWS\system32\cmd.exe")
			If $dev = 0 Then send('shutdown -s -t 10' & "{ENTER}") ; Polecenie zamykania systemu za 10 sekund
				; NOTE: aby zatrzymać to polecenie wpisz w cmd: "shutdown -a"
			For $i = 10 To 0 Step -1
				_log("# zamknięcie za " & $i & "...")
				Sleep(1000)
			Next
		EndIf
	EndIf
	$zakoncz = 0

	; zmiana funkcji $Button1
	$metadane = 2
	GUICtrlSetData($Button1, "Usuń metadane")
EndFunc   ;==>_down_epis

;###################################################################
; Funkcja _del_meta()
; - przywraca przyciski stanu początkowego,
; - czyści wszystkie wykorzystane wcześniej zmienne,
; - czysci pola do wprowadzania danych,
Func _del_meta()
	GUICtrlSetData($Input1, "")
	GUICtrlSetData($Input2, "")
	GUICtrlSetData($Input3, "")
	GUICtrlSetData($Combo1, "")
	GUICtrlSetData($Combo2, "")
	$zakoncz = 0
	$id = Null
	$i = Null
	$source = Null
	$get = Null
	$precent = Null
	$j = Null
	$Size = Null
	$txt = Null
	$dir = Null
	$title = Null
	$to = Null
	$from = Null
	$link = Null
	$what = Null
	$min = Null
	$max = Null
	$page_source = Null
	GUICtrlSetState($Input1, $GUI_ENABLE)
	GUICtrlSetState($Input2, $GUI_DISABLE)
	GUICtrlSetState($Input3, $GUI_DISABLE)
	GUICtrlSetState($Button3, $GUI_DISABLE)
	GUICtrlSetState($Combo1, $GUI_DISABLE)
	GUICtrlSetState($Combo2, $GUI_DISABLE)

	; zmiana funkcji $Button1
	$metadane = 0
	GUICtrlSetData($Button1, "Pobierz metadane")
EndFunc   ;==>_del_meta

;###################################################################
; Funckja _ANSI2UNICODE
; (znaleziona gdzieś w sieci)
; Kod źródłowy pobrany dzięki funkcji _INetGetSource, jest kodowany w ANSI
; a więc brak w nim znaków diakrytycznych.
Func _ANSI2UNICODE($sString = "")
	Local Const $SF_ANSI = 1
	Local Const $SF_UTF8 = 4
	Return BinaryToString(StringToBinary($sString, $SF_ANSI), $SF_UTF8)
EndFunc   ;==>_ANSI2UNICODE

;###################################################################
; Funckja _log($log)
; wypisuje kolejne wiadomości w oknie $Edit1
Func _log($log)
	GUICtrlSetData($Edit1, $log & @CRLF & GUICtrlRead($Edit1))
EndFunc   ;==>_log
