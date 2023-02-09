unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Buttons;

type
  TEntryType = (etNone, etNoun, etVerb, etAdjective);

  TMainForm = class(TForm)
    sg: TStringGrid;
    lblLatin: TLabel;
    lblWordType: TLabel;
    btnExit: TButton;
    btnEdit: TButton;
    btnNext: TButton;
    btnPrev: TButton;
    lblRecNo: TLabel;
    edtSearch: TEdit;
    Label1: TLabel;
    lblFound: TLabel;
    btnFindNext: TButton;
    Label2: TLabel;
    lblInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExitClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure edtSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFindNextClick(Sender: TObject);
    procedure edtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure edtSearchEnter(Sender: TObject);
  private
    Ix:         integer;
    FIniFile:   TStringList;
    FStrings:   TStringList;
    FWordTypes: TStringList;
    FWordDescs: TStringList;
    FVerbTypes: TStringList;
    FVerbDescs: TStringList;
    FStop:      boolean;
    FSearchTerm: string;
    procedure clearSG;
    procedure doEntry;
    procedure doNounHeaders;
    procedure doNoun(nounString: string);
    procedure doVerbHeaders;
    procedure doVerb(verbString: string);
    function  getEntryType(entryString: string): TEntryType;
    function  getInfo(typeString: string): string;
    function  getVerbType(typeString: string): string;
    function  getWordType(typeString: string): string;
    procedure loadINIFile;
    procedure populateWordTypes;
    procedure populateWordDescs;
    procedure populateVerbTypes;
    procedure populateVerbDescs;
    procedure searchRecs(fromIx: integer = 0);
    procedure updateRecLabel;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses FormEdit;

const
  DEFAULT_COL_WIDTH = 86;

{$R *.dfm}

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  case FIniFile   <> NIL of TRUE: FIniFile.free; end;
  case FStrings   <> NIL of TRUE: FStrings.free; end;
  case FWordTypes <> NIL of TRUE: FWordTypes.free; end;
  case FWordDescs <> NIL of TRUE: FWordDescs.free; end;
  case FVerbTypes <> NIL of TRUE: FVerbTypes.free; end;
  case FVerbDescs <> NIL of TRUE: FVerbDescs.free; end;

  FStrings.Delimiter  := ',';
end;

procedure TMainForm.FormCreate(Sender: TObject);
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

  lblFound.caption  := '';
  lblInfo.caption   := '';

  DoEntry; // ix := 0 is set in loadINIFile
end;

function TMainForm.getEntryType(entryString: string): TEntryType;
begin
  result := etNone;
  case length(entryString) <> 2           of TRUE: EXIT; end;
  case entryString[2] in ['n']            of TRUE: result := etNoun;      end;
  case entryString[2] in ['v', 'i']       of TRUE: result := etVerb;      end;
  case entryString[2] in ['a', 'c', 's']  of TRUE: result := etAdjective; end;
end;

function TMainForm.getInfo(typeString: string): string;
begin
  result := '';
  case typeString = '1n' of TRUE: result := '1D: mostly f. characterised by the vowel -a. Nom: -a, Gen: -ae'; end;
  case typeString = '2n' of TRUE: result := '2D: mostly m. n. characterised by the vowels -o/-u. NomM: -us -ius -er NomN: -um Gen: -i'; end;
  case (typeString = '3n') or (typeString = 'in') or (typeString = 'nn') of TRUE:
                                  result := '3D: m. f. n. Nom: various Gen: -is'; end;
  case typeString = '4n' of TRUE: result := '4D: mostly m. some f. n. NomMF: -us NomN: -u Gen: -us'; end;
  case typeString = '5n' of TRUE: result := '5D: all f. except diēs/day (m or f) Nom: -es Gen: ēī'; end;

  case typeString = '1v' of TRUE: result := ''; end;
  case typeString = '2v' of TRUE: result := ''; end;
  case typeString = '3v' of TRUE: result := ''; end;
  case typeString = '3i' of TRUE: result := ''; end;
  case typeString = '4v' of TRUE: result := ''; end;
  case typeString = 'iv' of TRUE: result := ''; end;

  case typeString = '1a' of TRUE: result := ''; end;
  case typeString = '3a' of TRUE: result := ''; end;
  case typeString = '1c' of TRUE: result := ''; end;
  case typeString = '3c' of TRUE: result := ''; end;
  case typeString = '1s' of TRUE: result := ''; end;
  case typeString = '3s' of TRUE: result := ''; end;


end;

function TMainForm.getVerbType(typeString: string): string;
begin
  result := FVerbDescs[FVerbTypes.indexOf(typeString)];
end;

function TMainForm.getWordType(typeString: string): string;
begin
  result := FWordDescs[FWordTypes.indexOf(typeString)];
end;

procedure TMainForm.loadINIFile;
begin
  DICT_FILE := extractFilePath(paramStr(0)) + 'latinator.ini';
  FIniFile.sorted := TRUE;
  FIniFile.loadFromFile(DICT_FILE);
  ix := 0;
end;

procedure TMainForm.populateVerbDescs;
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

procedure TMainForm.populateVerbTypes;
begin
  FVerbTypes.add('pia');
  FVerbTypes.add('iia');
  FVerbTypes.add('fia');
  FVerbTypes.add('pfia');
  FVerbTypes.add('ppia');
  FVerbTypes.add('fpia');
  FVerbTypes.add('pip');
  FVerbTypes.add('iip');
  FVerbTypes.add('fip');
  FVerbTypes.add('pfip');
  FVerbTypes.add('ppip');
  FVerbTypes.add('fpip');
end;

procedure TMainForm.populateWordDescs;
begin
  FWordDescs.add('1st declension noun');
  FWordDescs.add('2nd declension noun');
  FWordDescs.add('3rd declension noun');
  FWordDescs.add('3rd declension i-stem noun');
  FWordDescs.add('3rd declension irregular noun');
  FWordDescs.add('4th declension noun');
  FWordDescs.add('5th declension noun');
  FWordDescs.add('1st conjugation verb');
  FWordDescs.add('2nd conjugation verb');
  FWordDescs.add('3rd conjugation verb');
  FWordDescs.add('3rd conjugation i-stem verb');
  FWordDescs.add('4th conjugation verb');
  FWordDescs.add('irregular verb');
  FWordDescs.add('1st & 2nd declension adjective');
  FWordDescs.add('3rd declension adjective');
  FWordDescs.add('1st & 2nd declension comparitive');
  FWordDescs.add('3rd declension comparitive');
  FWordDescs.add('1st & 2nd declension superlative');
  FWordDescs.add('3rd declension superlative');
end;

procedure TMainForm.populateWordTypes;
begin
  FWordTypes.add('1n');
  FWordTypes.add('2n');
  FWordTypes.add('3n');
  FWordTypes.add('in');
  FWordTypes.add('nn');
  FWordTypes.add('4n');
  FWordTypes.add('5n');
  FWordTypes.add('1v');
  FWordTypes.add('2v');
  FWordTypes.add('3v');
  FWordTypes.add('3i');
  FWordTypes.add('4v');
  FWordTypes.add('iv');
  FWordTypes.add('1a');
  FWordTypes.add('3a');
  FWordTypes.add('1c');
  FWordTypes.add('3c');
  FWordTypes.add('1s');
  FWordTypes.add('3s');
end;

procedure TMainForm.searchRecs(fromIx: integer = 0);
begin
  case (fromIx = 0) and (edtSearch.text = FSearchTerm) of TRUE: begin FSearchTerm := ''; EXIT; end;end; // again, VK_RETURN on btnFindNext triggers in edtSearch.OnKeyPress!
  FSearchTerm := edtSearch.text;
  case trim(edtSearch.text) = '' of TRUE: EXIT; end;
  lblFound.caption := 'Found!';
  for var i := fromIx to FIniFile.count - 1 do
    case pos(edtSearch.text, FIniFile[i]) > 0 of TRUE:  begin
                                                          ix := i;
                                                          doEntry;
                                                          btnFindNext.visible := TRUE;
                                                          btnFindNext.setFocus;
                                                          EXIT; end;end;
  btnFindNext.visible := FALSE;
  lblFound.caption := 'Not Found';
  edtSearch.setFocus; // the VK_RETURN culprit! But this needs to be done for UX reasons.
end;

procedure TMainForm.sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
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

procedure TMainForm.updateRecLabel;
begin
  lblRecNo.caption := format('%d of %d', [ix + 1, FIniFile.count]);
end;

procedure TMainForm.btnEditClick(Sender: TObject);
begin
  with TEditForm.create(NIL) do begin
    VerbTypes := FVerbTypes;
    WordTypes := FWordTypes;
    populateVerbDescs(FVerbDescs);
    populateWordDescs(FWordDescs);
    showModal;
    loadINIFile;
    doEntry;
    edtSearch.setFocus;
  end;
end;

procedure TMainForm.btnExitClick(Sender: TObject);
begin
  CLOSE;
end;

procedure TMainForm.btnFindNextClick(Sender: TObject);
begin
  searchRecs(ix + 1);
end;

procedure TMainForm.btnNextClick(Sender: TObject);
begin
  lblFound.caption := '';
  case ix < FIniFile.count - 1 of TRUE: inc(ix); end;
  doEntry;
end;

procedure TMainForm.btnPrevClick(Sender: TObject);
begin
  lblFound.caption := '';
  case ix > 0 of TRUE: dec(ix); end;
  doEntry;
end;

procedure TMainForm.clearSG;
begin
  for var i := 0 to sg.ColCount - 1 do begin
    sg.cols[i].Clear;
    sg.colWidths[i] := DEFAULT_COL_WIDTH;
  end;
  sg.rowCount := 1;
end;

procedure TMainForm.doEntry;
begin
  FStrings.commaText := FIniFile[ix];

  case getEntryType(FStrings[0]) of
    etNone: ;
    etNoun:       doNoun(FIniFile[ix]);
    etVerb:       doVerb(FIniFile[ix]);
    etAdjective:  doNoun(FIniFile[ix]);
  end;

  updateRecLabel;
end;

procedure TMainForm.doNoun(nounString: string);
begin
  doNounHeaders;
  lblLatin.caption    := '';
  lblWordType.caption := '';
  case trim(nounString) = '' of TRUE: EXIT; end;

  FStrings.commaText  := nounString;

  try
    lblWordType.caption := getWordType(FStrings[0]);
    lblLatin.caption    := Fstrings[1] + '. ' + FStrings[2] + ' = ' + FStrings[3];

    for var i := 1 to 6 do
      sg.cells[1, i] := ' ' + FStrings[i + 3]; // entries [4] to [9] go in the singular columm

    for var i := 1 to 6 do
      sg.cells[2, i] := ' ' + FStrings[i + 9]; // entries [10] to [15] go in the plural column
  except end; // not every record has every field, but that's ok

  lblInfo.caption := getInfo(FStrings[0]);
end;

procedure TMainForm.doNounHeaders;
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

procedure TMainForm.doVerb(verbString: string);
begin
  doVerbHeaders;
  lblLatin.caption    := '';
  lblWordType.caption := '';
  case trim(verbString) = '' of TRUE: EXIT; end;

  FStrings.commaText := verbString;

  try
    lblWordType.caption := getWordType(FStrings[0]) + ' - ' + getVerbType(FStrings[1]);
    lblLatin.caption    := FStrings[2] + ' = ' + FStrings[3];

    for var i := 1 to 3 do
      sg.cells[1, i] := ' ' + FStrings[i + 3]; // entries [4] to [6] go in the singular columm

    for var i := 1 to 3 do
      sg.cells[2, i] := ' ' + FStrings[i + 6]; // entries [7] to [9] go in the plural column
  except; end; // not every record has every field, but that's ok
end;

procedure TMainForm.doVerbHeaders;
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

procedure TMainForm.edtSearchEnter(Sender: TObject);
begin
  btnFindNext.visible := FALSE;
  lblFound.caption    := '';
end;

procedure TMainForm.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  btnFindNext.visible := FALSE;
  case isShiftKeyDown     of  TRUE: key := getMacronChar(key); end;
  case validMacron(key)   of  TRUE: EXIT; end;
  case key in VALID_KEYS  of FALSE: key := #0; end;
end;

procedure TMainForm.edtSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  btnFindNext.visible := FALSE;
  case key = VK_RETURN of TRUE: searchRecs; end;
end;

end.
