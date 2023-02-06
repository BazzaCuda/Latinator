unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids;

type
  TlblWord = class(TForm)
    sg: TStringGrid;
    lblLatin: TLabel;
    lblEnglish: TLabel;
    lblWordType: TLabel;
    btnExit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExitClick(Sender: TObject);
  private
    FIniFile: TStringList;
    FStrings: TStringList;
    procedure clearSG;
    procedure doNounHeaders;
    procedure doNoun(nounString: string);
    procedure doVerbHeaders;
    procedure doVerb(verbString: string);
    function  getVerbType(typeString: string): string;
    function  getWordType(typeString: string): string;
  public
    { Public declarations }
  end;

var
  lblWord: TlblWord;

implementation

{$R *.dfm}

procedure TlblWord.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  case FIniFile <> NIL of TRUE: FIniFile.free; end;
  case FStrings <> NIL of TRUE: FStrings.free; end;
  FStrings.Delimiter  := ',';
end;

procedure TlblWord.FormCreate(Sender: TObject);
begin
  FIniFile := TStringList.create;
  FStrings := TStringList.create;
  FIniFile.loadFromFile(extractFilePath(paramStr(0)) + 'latinator.ini');

  doNounHeaders;
  doNoun(FIniFile[FIniFile.count - 1]);
//  doVerbHeaders;
//  doVerb(FIniFile[FIniFile.count - 1]);
end;

function TlblWord.getVerbType(typeString: string): string;
begin
  case typeString = 'pa' of TRUE: result  := 'present active indicative'; end;
  case typeString = 'ia' of TRUE: result  := 'imperfect active indicative'; end;
  case typeString = 'fa' of TRUE: result  := 'future active indicative'; end;
  case typeString = 'pfa' of TRUE: result := 'perfect active indicative'; end;
  case typeString = 'ppa' of TRUE: result := 'pluperfect active indicative'; end;
  case typeString = 'fpa' of TRUE: result := 'future perfect active indicative'; end;
  case typeString = 'pp' of TRUE: result := 'present passive indicative'; end;
  case typeString = 'ip' of TRUE: result := 'imperfect passive indicative'; end;
  case typeString = 'fp' of TRUE: result := 'future passive indicative'; end;
  case typeString = 'pfp' of TRUE: result := 'perfect passive indicative'; end;
  case typeString = 'ppp' of TRUE: result := 'pluperfect passive indicative'; end;
  case typeString = 'fpp' of TRUE: result := 'future perfect passive indicative'; end;
end;

function TlblWord.getWordType(typeString: string): string;
begin
  case typeString = '1n' of TRUE: result := '1st declension noun'; end;
  case typeString = '2n' of TRUE: result := '2nd declension noun'; end;
  case typeString = '3n' of TRUE: result := '3rd declension noun'; end;
  case typeString = '4n' of TRUE: result := '4th declension noun'; end;
  case typeString = '5n' of TRUE: result := '5th declension noun'; end;
  case typeString = '1v' of TRUE: result := '1st conjugation verb'; end;
  case typeString = '2v' of TRUE: result := '2nd conjugation verb'; end;
  case typeString = '3v' of TRUE: result := '3rd conjugation verb'; end;
  case typeString = '3i' of TRUE: result := '3rd conjugation i-stem verb'; end;
  case typeString = '4v' of TRUE: result := '4th conjugation verb'; end;
end;

procedure TlblWord.sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  // default colors
  // $232323;  // black-ish background
  // $3E3E3E;  // greenish background
  sg.canvas.font.color  := $C0C0C0;  // silver
  sg.canvas.font.style  := [];
  sg.canvas.font.size   := 10;
  sg.canvas.brush.color := $3E3E3E;

  case (aCol = 0) of TRUE: sg.canvas.brush.color := $232323; end;
  case (aRow = 0) of TRUE: sg.canvas.brush.color := $232323; end;

  case ((aCol = 0) and (aRow <> 0)) of TRUE: sg.canvas.font.style := [fsBold]; end; // omit [0, 0]
  case ((aRow = 0) and (aCol <> 0)) of TRUE: sg.canvas.font.style := [fsBold]; end; // omit [0, 0]

  case (aCol > 0) and (aRow > 0) of TRUE: sg.canvas.font.size := 12; end;

  var text := sg.cells[aCol, aRow];
  text := stringReplace(text, '/', ' / ', [rfReplaceAll]);

  var vTextWidth := sg.canvas.textWidth(text);
  case vTextWidth > sg.colWidths[aCol] of TRUE: sg.colWidths[aCol] := vTextWidth + 6; end;

  sg.canvas.fillRect(rect);

  sg.canvas.textRect(rect, rect.left, rect.top, text);
end;

procedure TlblWord.btnExitClick(Sender: TObject);
begin
  CLOSE;
end;

procedure TlblWord.clearSG;
begin
  for var i := 0 to sg.ColCount - 1 do
    sg.cols[i].Clear;
  sg.rowCount := 1;
end;

procedure TlblWord.doNoun(nounString: string);
begin
  lblLatin.caption    := '';
  lblEnglish.caption  := '';
  lblWordType.caption := '';
  case trim(nounString) = '' of TRUE: EXIT; end;

  FStrings.commaText  := nounString;

  try
    lblWordType.caption := getWordType(FStrings[0]);
    lblLatin.caption    := Fstrings[1] + '. ' + FStrings[2];
    lblEnglish.caption  := FStrings[3];

    for var i := 1 to 6 do
      sg.cells[1, i] := ' ' + FStrings[i + 3];

    for var i := 1 to 6 do
      sg.cells[2, i] := ' ' + FStrings[i + 9];
  except end;
end;

procedure TlblWord.doNounHeaders;
begin
  clearSG;
  sg.colCount := 3;
  sg.rowCount := 7;
  sg.cells[0, 0] := '';
  sg.cells[1, 0] := ' singular';
  sg.cells[2, 0] := ' plural';
  sg.cells[0, 1] := ' nominative';
  sg.cells[0, 2] := ' vocative';
  sg.cells[0, 3] := ' accusative';
  sg.cells[0, 4] := ' genitive';
  sg.cells[0, 5] := ' dative';
  sg.cells[0, 6] := ' ablative';
end;

procedure TlblWord.doVerb(verbString: string);
begin
  lblLatin.caption    := '';
  lblEnglish.caption  := '';
  lblWordType.caption := '';
  case trim(verbString) = '' of TRUE: EXIT; end;

  FStrings.commaText := verbString;

  try
    lblWordType.caption := getWordType(FStrings[0]) + ' - ' + getVerbType(FStrings[1]);
    lblLatin.caption    := FStrings[2];
    lblEnglish.caption  := FStrings[3];

    for var i := 1 to 3 do
      sg.cells[1, i] := ' ' + FStrings[i + 3];

    for var i := 1 to 3 do
      sg.cells[2, i] := ' ' + FStrings[i + 6];
  except; end;
end;

procedure TlblWord.doVerbHeaders;
begin
  clearSG;
  sg.colCount := 3;
  sg.rowCount := 4;
  sg.cells[0, 0] := '';
  sg.cells[1, 0] := ' singular';
  sg.cells[2, 0] := ' plural';
  sg.cells[0, 1] := ' 1st person';
  sg.cells[0, 2] := ' 2nd person';
  sg.cells[0, 3] := ' 3rd person';
end;

end.
