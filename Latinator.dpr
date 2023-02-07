program Latinator;

uses
  Vcl.Forms,
  main in 'main.pas' {MainForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
