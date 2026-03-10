program Latinator;

uses
  Vcl.Forms,
  formMain in 'formMain.pas' {Form2},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
