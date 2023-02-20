program Latinator;

uses
  Vcl.Forms,
  main in 'main.pas' {MainForm},
  Vcl.Themes,
  Vcl.Styles,
  _debugWindow in '..\DebugWindow\_debugWindow.pas',
  latinGrammar in 'latinGrammar.pas',
  FormTranslate in 'FormTranslate.pas' {TranslateForm},
  myCoreWeb in 'myCoreWeb.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TTranslateForm, TranslateForm);
  Application.Run;
end.
