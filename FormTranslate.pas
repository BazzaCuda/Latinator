unit FormTranslate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, WebView2,
  Winapi.ActiveX, Vcl.Edge;

type
  TTranslateForm = class(TForm)
    edge: TEdgeBrowser;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure edgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TranslateForm: TTranslateForm;

implementation

uses myCoreWeb;

{$R *.dfm}

procedure TTranslateForm.edgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
var
    Ctrl2     : ICoreWebView2Controller2;
    BackColor : TCOREWEBVIEW2_COLOR;
    HR        : HRESULT;
begin
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

procedure TTranslateForm.FormActivate(Sender: TObject);
begin
  edge.navigate('https://translate.google.co.uk/?sl=la&tl=en&op=translate');
end;

procedure TTranslateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

end.
