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
unit view.formSplash;

interface

uses
  {$ifopt D+}
    {$define designTime} // comment out when not designing this form
  {$endif}
  {$define designTime} // temporary until we sort out the uses clause
  {$ifdef designTime}
  winApi.messages, winApi.windows,
  system.classes, system.sysUtils, system.variants,
  vcl.controls, vcl.dialogs, vcl.extCtrls, vcl.forms, vcl.graphics, vcl.stdCtrls;
  {$endif}

type
  ISplashScreen = interface
    procedure   formHide;
    procedure   formShow;

    procedure   setHeading(const aValue: string);
    procedure   setOwner(const aValue: HWND);
    procedure   setSubHeading(const aValue: string);

    property    heading:          string                                write setHeading;
    property    owner:            HWND                                  write setOwner;
    property    subHeading:       string                                write setSubHeading;
  end;

  TSplashForm = class(TForm, ISplashScreen)
    Panel1:     TPanel;
    FSubHeading: TLabel;
    FHeading:   TLabel;
    procedure   btnCancelClick(Sender: TObject);
    procedure   FormCreate(Sender: TObject);
  strict private
    FOnCancel:  TNotifyEvent;
  private
  protected
  public
    procedure   formHide;
    procedure   formShow;

    procedure   setHeading(const aValue: string);
    procedure   setOwner(const aValue: HWND);
    procedure   setSubHeading(const aValue: string);
  end;

function newSplashScreen: ISplashScreen;

implementation

const
  DARK_MODE_DARK   = $2B2B2B;
  DARK_MODE_LIGHT  = $232323;

{$R *.dfm}

function newSplashScreen: ISplashScreen;
begin
  result := TSplashForm.create(NIL);
end;

procedure TSplashForm.btnCancelClick(Sender: TObject);
begin
  case assigned(FOnCancel) of TRUE: FOnCancel(SELF); end;
end;

procedure TSplashForm.FormCreate(Sender: TObject);
begin
  setWindowLong(handle, GWL_STYLE, GetWindowLong(handle, GWL_STYLE) OR WS_CAPTION AND (NOT (WS_BORDER)));
  color := DARK_MODE_DARK;

//  styleElements     := []; // don't allow any theme alterations
  borderStyle       := bsNone;
  position          := poScreenCenter;

  FHeading.showAccelChar    := FALSE;
  FSubHeading.showAccelChar := FALSE;

  with panel1 do begin
    styleElements    := []; // don't allow any theme alterations
    align            := alClient;
    bevelInner       := bvNone;
    bevelOuter       := bvNone;
    borderStyle      := bsNone;
    margins.bottom   := 5;
    margins.left     := 5;
    margins.right    := 5;
    margins.top      := 5;
    alignWithMargins := TRUE;
    panel1.color     := DARK_MODE_LIGHT;
  end;
end;

procedure TSplashForm.formHide;
begin
  SELF.hide;
end;

procedure TSplashForm.formShow;
begin
  SELF.show;
end;

procedure TSplashForm.setHeading(const aValue: string);
begin
  FHeading.caption := aValue;
  application.processMessages;
end;

procedure TSplashForm.setOwner(const aValue: HWND);
begin
  setWindowLongPtr(SELF.HANDLE, GWLP_HWNDPARENT, aValue);
end;

procedure TSplashForm.setSubHeading(const aValue: string);
begin
  FSubHeading.caption := aValue;
  application.processMessages;
end;

end.
