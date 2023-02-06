unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids;

type
  TEntryType = (etNone, etNoun, etVerb);

  TlblWord = class(TForm)
    sg: TStringGrid;
    lblLatin: TLabel;
    lblEnglish: TLabel;
    lblWordType: TLabel;
    btnExit: TButton;
    btnEdit: TButton;
    btnNext: TButton;
    btnPrev: TButton;
    lblRecNo: TLabel;
    edtSearch: TEdit;
    Label1: TLabel;
    lblFound: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExitClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure edtSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    Ix:         integer;
    FIniFile:   TStringList;
    FStrings:   TStringList;
    FWordTypes: TStringList;
    FWordDescs: TStringList;
    FVerbTypes: TStringList;
    FVerbDescs: TStringList;
    procedure clearSG;
    procedure doEntry;
    procedure doNounHeaders;
    procedure doNoun(nounString: string);
    procedure doVerbHeaders;
    procedure doVerb(verbString: string);
    function  getEntryType(entryString: string): TEntryType;
    function  getVerbType(typeString: string): string;
    function  getWordType(typeString: string): string;
    procedure loadINIFile;
    procedure populateWordTypes;
    procedure populateWordDescs;
    procedure populateVerbTypes;
    procedure populateVerbDescs;
    procedure searchRecs;
    procedure updateRecLabel;
  public
    { Public declarations }
  end;

var
  lblWord: TlblWord;

implementation

uses FormEdit;

const
  DEFAULT_COL_WIDTH = 86;

{$R *.dfm}

procedure TlblWord.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  case FIniFile   <> NIL of TRUE: FIniFile.free; end;
  case FStrings   <> NIL of TRUE: FStrings.free; end;
  case FWordTypes <> NIL of TRUE: FWordTypes.free; end;
  case FWordDescs <> NIL of TRUE: FWordDescs.free; end;
  case FVerbTypes <> NIL of TRUE: FVerbTypes.free; end;
  case FVerbDescs <> NIL of TRUE: FVerbDescs.free; end;

  FStrings.Delimiter  := ',';
end;

procedure TlblWord.FormCreate(Sender: TObject);
begin
  FIniFile    := TStringList.create;
  FStrings    := TStringList.create;
  FWordTypes  := TStringList.create;
  FWordDescs  := TStringList.create;
  FVerbTypes  := TStringList.create;
  FVerbDescs  := TStringList.create;

  populateWordTypes;
  populateWordDescs;
  populateVerbTypes;
  populateVerbDescs;

  loadINIFile;

  lblFound.caption := '';

  ix := 0;
  DoEntry;
end;

function TlblWord.getEntryType(entryString: string): TEntryType;
begin
  result := etNone;
  case length(entryString) <> 2 of TRUE: EXIT; end;
  case entryString[2] = 'n'         of TRUE: result := etNoun; end;
  case entryString[2] in ['v', 'i'] of TRUE: result := etVerb; end;
end;

function TlblWord.getVerbType(typeString: string): string;
begin
  result := FVerbDescs[FVerbTypes.indexOf(typeString)];
end;

function TlblWord.getWordType(typeString: string): string;
begin
  result := FWordDescs[FWordTypes.indexOf(typeString)];
end;

procedure TlblWord.loadINIFile;
begin
  DICT_FILE := extractFilePath(paramStr(0)) + 'latinator.ini';
  FIniFile.sorted := TRUE;
  FIniFile.loadFromFile(DICT_FILE);
end;

procedure TlblWord.populateVerbDescs;
begin
  FVerbDescs.add('present indicative active');
  FVerbDescs.add('imperfect indicative active');
  FVerbDescs.add('future indicative active');
  FVerbDescs.add('perfect indicative active');
  FVerbDescs.add('pluperfect indicative active');
  FVerbDescs.add('future perfect indicative active');
  FVerbDescs.add('present indicative passive');
  FVerbDescs.add('imperfect indicative passive');
  FVerbDescs.add('future indicative passive');
  FVerbDescs.add('perfect indicative passive');
  FVerbDescs.add('pluperfect indicative passive');
  FVerbDescs.add('future perfect indicative passive');
end;

procedure TlblWord.populateVerbTypes;
begin
  FVerbTypes.add('pia');
  FVerbTypes.add('iia');
  FVerbTypes.add('fia');
  FVerbTypes.add('pia');
  FVerbTypes.add('ppia');
  FVerbTypes.add('fpia');
  FVerbTypes.add('pip');
  FVerbTypes.add('iip');
  FVerbTypes.add('fip');
  FVerbTypes.add('pfip');
  FVerbTypes.add('ppip');
  FVerbTypes.add('fpip');
end;

procedure TlblWord.populateWordDescs;
begin
  FWordDescs.add('1st declension noun');
  FWordDescs.add('2nd declension noun');
  FWordDescs.add('3rd declension noun');
  FWordDescs.add('4th declension noun');
  FWordDescs.add('5th declension noun');
  FWordDescs.add('1st conjugation verb');
  FWordDescs.add('2nd conjugation verb');
  FWordDescs.add('3rd conjugation verb');
  FWordDescs.add('3rd conjugation i-stem verb');
  FWordDescs.add('4th conjugation verb');
end;

procedure TlblWord.populateWordTypes;
begin
  FWordTypes.add('1n');
  FWordTypes.add('2n');
  FWordTypes.add('3n');
  FWordTypes.add('4n');
  FWordTypes.add('5n');
  FWordTypes.add('1v');
  FWordTypes.add('2v');
  FWordTypes.add('3v');
  FWordTypes.add('3i');
  FWordTypes.add('4v');
end;

procedure TlblWord.searchRecs;
begin
  case trim(edtSearch.text) = '' of TRUE: EXIT; end;
  lblFound.caption := 'Found!';
  for var i := 0 to FIniFile.count - 1 do
    case pos(edtSearch.text, FIniFile[i]) > 0 of TRUE:  begin
                                                          ix := i;
                                                          doEntry;
                                                          EXIT; end;end;
  lblFound.caption := 'Not Found';
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

procedure TlblWord.updateRecLabel;
begin
  lblRecNo.caption := format('%d of %d', [ix + 1, FIniFile.count]);
end;

procedure TlblWord.btnEditClick(Sender: TObject);
begin
  with TEditForm.create(NIL) do begin
    VerbTypes := FVerbTypes;
    WordTypes := FWordTypes;
    populateVerbDescs(FVerbDescs);
    populateWordDescs(FWordDescs);
    showModal;
    loadINIFile;
  end;
end;

procedure TlblWord.btnExitClick(Sender: TObject);
begin
  CLOSE;
end;

procedure TlblWord.btnNextClick(Sender: TObject);
begin
  lblFound.caption := '';
  case ix < FIniFile.count - 1 of TRUE: inc(ix); end;
  doEntry;
end;

procedure TlblWord.btnPrevClick(Sender: TObject);
begin
  lblFound.caption := '';
  case ix > 0 of TRUE: dec(ix); end;
  doEntry;
end;

procedure TlblWord.clearSG;
begin
  for var i := 0 to sg.ColCount - 1 do begin
    sg.cols[i].Clear;
    sg.colWidths[i] := DEFAULT_COL_WIDTH;
  end;
  sg.rowCount := 1;
end;

procedure TlblWord.doEntry;
begin
  FStrings.commaText := FIniFile[ix];

  case getEntryType(FStrings[0]) of
    etNone: ;
    etNoun: doNoun(FIniFile[ix]);
    etVerb: doVerb(FIniFile[ix]);
  end;

  updateRecLabel;
end;

procedure TlblWord.doNoun(nounString: string);
begin
  doNounHeaders;
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
      sg.cells[1, i] := ' ' + FStrings[i + 3]; // entries [4] to [9] go in the singular columm

    for var i := 1 to 6 do
      sg.cells[2, i] := ' ' + FStrings[i + 9]; // entries [10] to [15] go in the plural column
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
  doVerbHeaders;
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
      sg.cells[1, i] := ' ' + FStrings[i + 3]; // entries [4] to [6] go in the singular columm

    for var i := 1 to 3 do
      sg.cells[2, i] := ' ' + FStrings[i + 6]; // entries [7] to [9] go in the plural column
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

procedure TlblWord.edtSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case key = VK_RETURN of TRUE: searchRecs; end;
end;

end.
