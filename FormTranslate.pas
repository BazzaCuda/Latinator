unit FormTranslate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, WebView2,
  Winapi.ActiveX, Vcl.Edge;

type
  TWebsite = (wsGoogleTranslate, wsCactus);
  TTranslateForm = class(TForm)
    edge: TEdgeBrowser;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure edgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure FormCreate(Sender: TObject);
    procedure edgeNavigationCompleted(Sender: TCustomEdgeBrowser;
      IsSuccess: Boolean; WebErrorStatus: TOleEnum);
  private
    FURL: string;
  public
    constructor create(aWebSite: TWebsite = wsGoogleTranslate);
  end;

var
  TranslateForm: TTranslateForm;

implementation

uses myCoreWeb;

var
  vHeight: integer;
  vWidth: integer;

{$R *.dfm}

constructor TTranslateForm.create(aWebSite: TWebsite);
begin
  inherited create(NIL);

  case aWebSite of
    wsGoogleTranslate: FURL := 'https://translate.google.co.uk/?sl=la&tl=en&op=translate';
    wsCactus:          FURL := 'https://latin.cactus2000.de/search_en.php';
  end;
end;

procedure TTranslateForm.edgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
var
    Ctrl2     : ICoreWebView2Controller2;
    BackColor : TCOREWEBVIEW2_COLOR;
    HR        : HRESULT;
begin
    edge.CapturePreview('b:\downloads\preview.png');
    EXIT;
    Sender.ControllerInterface.QueryInterface(IID_ICoreWebView2Controller2, Ctrl2);
    if not Assigned(Ctrl2) then
        raise Exception.Create('ICoreWebView2Controller2 not found');
    // Select red background
    BackColor.A := 255;
    BackColor.R := 255;
    BackColor.G := 0;
    BackColor.B := 0;
    HR := Ctrl2.put_DefaultBackgroundColor(BackColor);
    if not SUCCEEDED(HR) then
        raise Exception.Create('put_DefaultBackgroundColor failed');
end;

procedure TTranslateForm.edgeNavigationCompleted(
  Sender: TCustomEdgeBrowser; IsSuccess: Boolean;
  WebErrorStatus: TOleEnum);
begin
    edge.CapturePreview('b:\downloads\preview.png');

end;

procedure TTranslateForm.FormActivate(Sender: TObject);
begin
  edge.navigate(FURL);
end;

procedure TTranslateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  vHeight := height;
  vWidth  := width;
  action  := caFree;
end;

procedure TTranslateForm.FormCreate(Sender: TObject);
begin
  case vHeight <> 0 of TRUE: height := vHeight; end;
  case vWidth  <> 0 of TRUE: width  := vWidth; end;
end;

initialization
  vHeight := 0;
  vWidth  := 0;

end.
