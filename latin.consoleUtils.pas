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

function centerWindow(aHWND: HWND): TVoid;
function applyUserConsoleColors(aOutputHandle: THandle): TVoid;

implementation

uses
  _debugWindow;

function applyUserConsoleColors(aOutputHandle: THandle): TVoid;
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

function centerWindow(aHWND: HWND): TVoid;
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

end.
