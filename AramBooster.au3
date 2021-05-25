#cs
	[CWAutCompFileInfo]
	Company=KLH
	Copyright= 0x4b697a
	Description=Aram boost
	Version=1.1.1.1
	ProductVersion=1.1.1.1
#ce
#RequireAdmin
#include <Constants.au3>
#include <String.au3>
#include "_HttpRequest.au3"
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <_Json.au3>

Opt("TrayMenuMode", 1)
$ARAM = GUICreate("A.R.A.M - KLH", 440, 250, 192, 124)
$Label1 = GUICtrlCreateLabel("A.R.A.M Skin boost", 16, 8, 259, 43)
GUICtrlSetFont(-1, 24, 800, 0, "Calibri")
GUICtrlSetColor(-1, 0xFF0000)
$btnBoost = GUICtrlCreateButton("Boost", -24, 168, 467, 49)
$LabelName = GUICtrlCreateLabel("Player", 16, 64, 180, 60)
GUICtrlSetFont(-1, 15, 400, 0)
$Checkbox1 = GUICtrlCreateCheckbox("Auto ready", 296, 136, 121, 17)
GUICtrlSetFont(-1, 14, 400, 0)
$Labelstt = GUICtrlCreateLabel("Game not running !!", 8, 224, 97, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetState($Labelstt,32)
GUICtrlSetState($Checkbox1,32)
TraySetIcon("", -1)
TraySetClick("1")
$tray = TrayCreateItem("Exit")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

const $sHost = 'https://127.0.0.1'
const $sProc = 'LeagueClientUx.exe'
$iPID = ''
Global $sPort
checkGame()


While 1
	$nMsg = GUIGetMsg()
	If GUICtrlRead($LabelName)="Player" Then
		checkGame()
		Sleep(70)
	EndIf
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btnBoost
			skinBoost()
	EndSwitch
	if TrayGetMsg() = $tray Then
			Exit
		EndIf

WEnd

;Thanks to Nomi
func getAPI($n)
	local $apiString = 'method=call&args=["","teambuilder-draft","activateBattleBoostV1",""]'
	static $aAPIs[] = [ _
        "/lol-chat/v1/me",    _
        "/lol-matchmaking/v1/ready-check",              _
        "/lol-matchmaking/v1/ready-check/accept",       _
        "/lol-login/v1/session/invoke?destination=lcdsServiceProxy&" & $apiString,                 _
        "/lol-champ-select/v1/session/actions"          _
    ];
    return ($sHost & ':' & $sPort & $aAPIs[$n])
endFunc

;Lấy tên ingame
Func getName() 
	local $tmp = _HttpRequest(2, getAPI(0));
	local $json = Json_Decode($tmp);
	return Json_Get($json, '["name"]');
EndFunc


Func skinBoost()
	local $tmp = _HttpRequest(2, getAPI(0));
	local $json = Json_Decode($tmp);
	If Json_Get($json, '["lol"].gameStatus') <> "championSelect" Then
		MsgBox(16,"A.R.A.M","Chỉ sử dụng khi ở màn hình chọn tướng",5)
	Else
		$sRes = _HttpRequest(2, getAPI(3), '', '', '', '', 'POST')
		if StringInStr($sRes, '{"body"') <> 0 Then
			TrayTip("A.R.A.M - KLH","Boosted ! Enjoy your game : ) ",5)
		else
			TrayTip("A.R.A.M - KLH","Fail to boost  :(" ,5)
		endIf
	endIf
EndFunc

Func checkGame()
	if ProcessExists("LeagueClient.exe") then
	GUICtrlSetState($Labelstt,32)
	Global $iPID = ProcessExists($sProc);
	Sleep(1200)
		If WinActive("League of Legends") Then
			startT()
		EndIf
	Else
		GUICtrlSetState($Labelstt,16)
	EndIf
EndFunc

Func startT()
	Global $sDir = StringTrimRight(_WinAPI_GetProcessFileName($iPID), StringLen($sProc));
	; Read the lockfile and get port + password
	Global $sLockfile = FileReadLine($sDir & 'lockfile');
	Global $sTokens = StringSplit($sLockfile, ':', 2);
	Global $sPort = $sTokens[2];
	Global $sPass = $sTokens[3];
	_HttpRequest_SetAuthorization("riot", $sPass);
	GUICtrlSetData($LabelName, GUICtrlRead($LabelName)& " : "&getName())
EndFunc
