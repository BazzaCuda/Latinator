program Latinator;

uses
  Vcl.Forms,
  main in 'main.pas' {lblWord},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TlblWord, lblWord);
  Application.Run;
end.
