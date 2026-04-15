{   Latinator
    Copyright (C) 2019-2099 Baz Cuda
    https://github.com/BazzaCuda/Latinator

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA
}

unit latin.consoleUtils;

interface

uses
  winAPI.windows,
  system.sysUtils,
  system.win.registry,
  vcl.Graphics,
  latin.types;

function consoleApplyUserColors(aOutputHandle: THandle): TVoid;
function consoleCenterWindow(aHWND: HWND): TVoid;
function consoleClear: TVoid;
function consoleDisableCloseButton: TVoid;
function consoleMapCommand(var aLine: string): TConsoleContext;
function consoleReadLine(var aLine: string): TVoid;
function consoleSetWidth(aWidth: integer): TVoid;
function consoleWriteBanner: TVoid;
function consoleWriteUnicode(const aString: string): TVoid;
function doClearConsole: TVoid;

implementation

uses
  latin.consts,
  _debugWindow;

function consoleApplyUserColors(aOutputHandle: THandle): TVoid;
var
  vInfo:      TConsoleScreenBufferInfoEx;
  vSize:      DWORD;
  vWritten:   DWORD;
  vCursor:    TCoord;
begin
  vInfo.cbSize := sizeOf(TConsoleScreenBufferInfoEx);

  case getConsoleScreenBufferInfoEx(aOutputHandle, vInfo) = TRUE of TRUE:  begin
                                                                      vInfo.wAttributes   := $17;
                                                                      vInfo.colorTable[1] := $562401;
                                                                      vInfo.colorTable[7] := $F2F2F2;

                                                                      setConsoleScreenBufferInfoEx(aOutputHandle, vInfo);

                                                                      vSize     := vInfo.dwSize.X * vInfo.dwSize.Y;
                                                                      vCursor.X := 0;
                                                                      vCursor.Y := 0;

                                                                      fillConsoleOutputAttribute(aOutputHandle, $17, vSize, vCursor, vWritten);
                                                                      fillConsoleOutputCharacter(aOutputHandle, ' ', vSize, vCursor, vWritten);
                                                                      setConsoleCursorPosition(aOutputHandle, vCursor);
  end;end;
end;

function consoleCenterWindow(aHWND: HWND): TVoid;
begin
  case aHWND = 0 of
    TRUE: begin
      exit;
    end;
  end;

  var vWindowRect: TRect;
  getWindowRect(aHWND, vWindowRect);

  var vWindowWidth := vWindowRect.right - vWindowRect.left;
  var vWindowHeight := vWindowRect.bottom - vWindowRect.top;

  var vScreenRect: TRect;
  systemParametersInfo(SPI_GETWORKAREA, 0, @vScreenRect, 0);

  var vScreenWidth := vScreenRect.right - vScreenRect.left;
  var vScreenHeight := vScreenRect.bottom - vScreenRect.top;

  var vX := vScreenRect.left + (vScreenWidth - vWindowWidth) div 2;
  var vY := vScreenRect.top + (vScreenHeight - vWindowHeight) div 2;

  setWindowPos(aHWND, 0, vX, vY, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
end;

function consoleClear: TVoid;
begin
  var vHandle := getStdHandle(STD_OUTPUT_HANDLE);
  var vConsoleScreenBufferInfo: TConsoleScreenBufferInfo;

  getConsoleScreenBufferInfo(vHandle, vConsoleScreenBufferInfo);

  var vLength := vConsoleScreenBufferInfo.dwSize.X * vConsoleScreenBufferInfo.dwSize.Y;

  var vTopLeft: TCoord;
  vTopLeft.X := 0;
  vTopLeft.Y := 0;

  var vWritten: DWORD;

  fillConsoleOutputCharacter(vHandle, ' ', vLength, vTopLeft, vWritten);
  fillConsoleOutputAttribute(vHandle, vConsoleScreenBufferInfo.wAttributes, vLength, vTopLeft, vWritten);
  setConsoleCursorPosition(vHandle, vTopLeft);
end;

function consoleDisableCloseButton: TVoid;
begin
  var vConsoleWindow := getConsoleWindow;

  case (vConsoleWindow <> 0) of  TRUE:  begin
                                          var vSystemMenu := getSystemMenu(vConsoleWindow, FALSE);
                                          case (vSystemMenu <> 0) of   TRUE:  begin
                                                                                deleteMenu  (vSystemMenu, SC_CLOSE, MF_BYCOMMAND);
                                                                                drawMenuBar (vConsoleWindow); end;end;end;end;
end;

function consoleMapCommand(var aLine: string): TConsoleContext;
begin
  result := default(TConsoleContext);

  var vConsoleLine := aLine.split([' '], TStringSplitOptions.ExcludeEmpty);
  case length(vConsoleLine) = 0 of TRUE: EXIT; end;

  for var vMapping in MAP_CONSOLE_COMMANDS do
    case vMapping.cmInput = vConsoleLine[0] of TRUE:  begin
                                                        result.ccCommand := vMapping.cmCommand;
                                                        BREAK; end;end;

  case result.ccCommand in [ccWW..ccClearLS] of TRUE: delete(aLine, 1, length(vConsoleLine[0]) + 1); end; // allow for the original space after the commnad

  result.ccWW := result.ccCommand in [ccNone, ccWW..ccConjugateVerb];
  result.ccLS := result.ccCommand in [ccNone, ccLS];
end;

function consoleReadLine(var aLine: string): TVoid;
begin
  var vHandle                 :  THANDLE := getStdHandle(STD_INPUT_HANDLE);
  var vRead                   :  DWORD;
  var vBuffer                 :  array [0..1023] of char;

  aLine := '';
  case readConsole(vHandle, @vBuffer, length(vBuffer), vRead, NIL) of FALSE: EXIT; end;

  setLength(aLine, vRead);
  case  (vRead > 0) of   TRUE:  begin
                                  move (vBuffer[0], aLine[1], vRead * sizeOf(char));
                                  case (vRead >= 2) and (aLine[vRead - 1] = #13) and (aLine[vRead] = #10) of  TRUE: begin setLength(aLine, vRead - 2); end;end;end;end;
end;

function consoleSetWidth(aWidth: integer): TVoid;
begin
  var vHandle := getStdHandle(STD_OUTPUT_HANDLE);
  case (vHandle = INVALID_HANDLE_VALUE) of TRUE: EXIT; end;

  var vBuffer: TCoord;
  vBuffer.X := aWidth;
  vBuffer.Y := 9000;
  case setConsoleScreenBufferSize(vHandle, vBuffer) of FALSE: EXIT; end;

  var vRect: TSmallRect;
  vRect.Left   := 0;
  vRect.Top    := 0;
  vRect.Right  := aWidth - 1;
  vRect.Bottom := 40;
  setConsoleWindowInfo(vHandle, TRUE, vRect);
end;

function consoleWriteBanner: TVoid;
begin
  // introductory messages from our sponsor
  consoleWriteUnicode(LATINATOR_BANNER);
  consoleWriteUnicode('');
end;

function consoleWriteUnicode(const aString: string): TVoid;
begin
  var vHandle := getStdHandle(STD_OUTPUT_HANDLE);
  case (vHandle = INVALID_HANDLE_VALUE) of TRUE: EXIT; end;

  var vOutput  := aString.replace('#', sLineBreak) + sLineBreak;

  var vWritten: DWORD := 0;
  writeConsoleW(vHandle, PWideChar(vOutput), vOutput.length, vWritten, NIL);
end;

function doClearConsole: TVoid;
begin
  consoleClear;
  consoleWriteBanner;
  consoleWriteUnicode('Press ENTER to exit');
end;


end.
