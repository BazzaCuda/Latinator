unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Buttons;

type
  TEntryType = (etNone, etNoun, etVerb, etAdjective, etPronoun);
  TNounGender = (ngNone, ngMasculine, ngFeminine, ngNeuter);

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
    lblStar: TLabel;
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
    procedure FormResize(Sender: TObject);
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
    procedure doExpandNoun(aGender: TNounGender; aNom: string; aGen: string);
    procedure doNounHeaders;
    procedure doNoun(nounString: string);
    procedure doPronoun(pronounString: string);
    procedure doPronounHeaders;
    procedure doVerbHeaders;
    procedure doVerb(verbString: string);
    function  getEntryType(entryString: string): TEntryType;
    function  getInfo(typeString: string): string;
    function  getNounGender(genderString: string): TNounGender;
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

uses FormEdit, _debugWindow;

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
  // non-resizable
  constraints.maxHeight := 460;  // well, maybe just a tad
  constraints.maxWidth  := width;
  constraints.minHeight := height;
  constraints.minWidth  := width;

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

procedure TMainForm.FormResize(Sender: TObject);
begin
  sg.height := lblInfo.top - sg.top;
end;

function TMainForm.getEntryType(entryString: string): TEntryType;
begin
  result := etNone;
  case length(entryString) <> 3           of TRUE: EXIT; end;
  case entryString[3] in ['n']            of TRUE: result := etNoun;      end;
  case entryString[3] in ['v']            of TRUE: result := etVerb;      end;
  case entryString[3] in ['a', 'c', 's']  of TRUE: result := etAdjective; end; // adjectives, comparatives, superlatives
  case entryString = 'ppn'                of TRUE: result := etPronoun;   end;
end;

function TMainForm.getInfo(typeString: string): string;
begin
  result := '';
  case typeString = '1dn' of TRUE: result := '1D: mostly f. characterised by the vowel -a. Nom: -a, Gen: -ae'; end;
  case typeString = '2dn' of TRUE: result := '2D: mostly m. n. characterised by the vowels -o/-u. NomM: -us -ius -er NomN: -um Gen: -i'; end;
  case (typeString = '3dn') or (typeString = '3in') or (typeString = '3nn') of TRUE:
                                  result := '3D: m. f. n. Nom: various Gen: -is'; end;
  case typeString = '4dn' of TRUE: result := '4D: mostly m. some f. n. NomMF: -us NomN: -u Gen: -us'; end;
  case typeString = '5dn' of TRUE: result := '5D: all f. except diēs/day (m or f) Nom: -es Gen: ēī'; end;

  case typeString = '1cv' of TRUE: result := '1c: have stems ending in -ā'; end;
  case typeString = '2cv' of TRUE: result := '2c: have stems ending in -ē'; end;
  case typeString = '3cv' of TRUE: result := '3c: stem ending in consonant; 3rd person singular ending in -it'; end;
  case typeString = '3iv' of TRUE: result := ''; end;
  case typeString = '4cv' of TRUE: result := ''; end;
  case typeString = 'irv' of TRUE: result := ''; end;

  case typeString = '1da' of TRUE: result := ''; end;
  case typeString = '3da' of TRUE: result := ''; end;
  case typeString = '1dc' of TRUE: result := ''; end;
  case typeString = '3dc' of TRUE: result := ''; end;
  case typeString = '1ds' of TRUE: result := ''; end;
  case typeString = '3ds' of TRUE: result := ''; end;
end;

function TMainForm.getNounGender(genderString: string): TNounGender;
begin
  result := TNounGender(pos(genderString, 'mfn'));
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
  FWordDescs.add('3rd declension comparative');
  FWordDescs.add('1st & 2nd declension superlative');
  FWordDescs.add('3rd declension superlative');
  FWordDescs.add('personal pronoun');
end;

procedure TMainForm.populateWordTypes;
begin
  FWordTypes.add('1dn');
  FWordTypes.add('2dn');
  FWordTypes.add('3dn');
  FWordTypes.add('3in');
  FWordTypes.add('3nn');
  FWordTypes.add('4dn');
  FWordTypes.add('5dn');
  FWordTypes.add('1cv');
  FWordTypes.add('2cv');
  FWordTypes.add('3cv');
  FWordTypes.add('3iv');
  FWordTypes.add('4cv');
  FWordTypes.add('irv');
  FWordTypes.add('1ca');
  FWordTypes.add('3ca');
  FWordTypes.add('1dc');
  FWordTypes.add('3dc');
  FWordTypes.add('1ds');
  FWordTypes.add('3ds');
  FWordTypes.add('ppn');
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
var
  separator: boolean;
  title: boolean;
  heading: boolean;
begin
  // default colors
  // $232323;  // black-ish background
  // $3E3E3E;  // greenish background

  // defaults for the Latin part of the grid
  sg.canvas.font.color  := $C0C0C0;  // silver
  sg.canvas.font.style  := [];
  sg.canvas.font.size   := 12;
  sg.canvas.brush.color := $3E3E3E;

  var text := stringReplace(sg.cells[aCol, aRow], '/', ' / ', [rfReplaceAll]); // looks less cluttered when alternatives are displayed like this

  case length(text) > 0 of  TRUE: begin
                                    heading   := text[1] = '+';
                                    title     := text[1] = '-';
                                    separator := text[1] = '_'; end;end;

  case title of TRUE: begin
                        sg.canvas.brush.color := $232323;
                        sg.canvas.font.size   := 10;
                        sg.canvas.font.style := []; end;end;

  case heading of TRUE: begin
                          sg.canvas.brush.color := $232323;
                          sg.canvas.font.size   := 10;
                          sg.canvas.font.style  := [fsBold]; end;end;

  case length(text) > 0 of TRUE: text[1] := ' '; end; // remove any formatting character

  var vTextWidth := sg.canvas.textWidth(text);
  case vTextWidth > sg.colWidths[aCol] of TRUE: sg.colWidths[aCol] := vTextWidth + 6; end; // also add a margin before the main part of the grid

  sg.canvas.fillRect(rect);

  case title    of TRUE: rect.left  := rect.left  + 14; end;  // these can only be done after fillRect
  case title or heading  of TRUE: rect.top   := rect.top   + 2;  end;

  sg.canvas.textRect(rect, rect.left, rect.top, text);

  case separator of TRUE: begin
                            sg.Canvas.pen.Color := clGray;
                            sg.Canvas.MoveTo(Rect.Left + 0, Rect.Bottom - 3);
                            sg.Canvas.LineTo(Rect.Right - 0, Rect.Bottom - 3); end;end;
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
    edtSearch.clear;
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
  edtSearch.text   := '';
  case ix < FIniFile.count - 1 of TRUE: inc(ix); end;
  doEntry;
end;

procedure TMainForm.btnPrevClick(Sender: TObject);
begin
  lblFound.caption := '';
  edtSearch.text   := '';
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
  lblStar.visible     := FALSE;
  FStrings.commaText  := FIniFile[ix];

  case getEntryType(FStrings[0]) of
    etNone: ;
    etNoun:       doNoun(FIniFile[ix]);
    etVerb:       doVerb(FIniFile[ix]);
    etAdjective:  doNoun(FIniFile[ix]);
    etPronoun:    doProNoun(FIniFile[ix]);
  end;

  updateRecLabel;
end;

procedure TMainForm.doExpandNoun(aGender: TNounGender; aNom: string; aGen: string);
// the genitive is in the form <stem>-<genEnd>, e.g. puer-ī
  function getStem: string;
  begin
    var posHyphen := pos('-', aGen);
    result        := copy(aGen, 1, posHyphen - 1);
  end;
  function getGenEnd: string;
  begin
    var posHyphen := pos('-', aGen);
    result        := copy(aGen, posHyphen + 1, 255);
  end;
  function isER: boolean;
  begin
    result := (length(aNom) >= 2) and (aNom[length(aNom) - 1] = 'e') and (aNom[length(aNom)] = 'r');
  end;
  function isUS: boolean;
  begin
    result := (length(aNom) >= 2) and (aNom[length(aNom) - 1] = 'u') and (aNom[length(aNom)] = 's');
  end;
begin
  lblStar.visible := TRUE;
  var stem        := getStem;
  var genEnd      := getGenEnd;
  debugString('Nom', aNom);
  debugString('Gen', aGen);
  debugString('stem', stem);
  debugString('genEnd', genEnd);
  debugBoolean('isER', isER);

  case (aGender in [ngFeminine, ngMasculine]) and (genEnd = 'ae') of TRUE: begin // 1D
                                FStrings[4] := stem + 'a';
                                FStrings.add(stem + 'a');
                                FStrings.add(stem + 'am');
                                FStrings.add(stem + 'ae');
                                FStrings.add(stem + 'ae');
                                FStrings.add(stem + 'ā');
                                FStrings.add(stem + 'ae');
                                FStrings.add(stem + 'ae');
                                FStrings.add(stem + 'ās');
                                FStrings.add(stem + 'ārum');
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'īs');
                              end;end;

  case (aGender = ngMasculine) and (genEnd = 'ī') and isUS of TRUE: begin // 2D -us nouns, e.g. dominus, domin-e
                                FStrings[4] := stem + 'us';
                                case stem[length(stem)] = 'i' of  TRUE: FStrings.add(stem + ' ');
                                                                 FALSE: FStrings.add(stem + 'e'); end;
                                FStrings.add(stem + 'um');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ōs');
                                FStrings.add(stem + 'ōrum');
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'īs');
                              end;end;

  case (aGender = ngMasculine) and (genEnd = 'ī') and isER of TRUE: begin // 2D  -er nouns, e.g. puer, puer-ī
                                FStrings[4] := stem;
                                FStrings.add(stem);
                                FStrings.add(stem + 'um');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ōrum');
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'īs');
                              end;end;

  case (aGender = ngNeuter) and (genEnd = 'ī') of TRUE: begin // 2D  neuter nouns, e.g. dōnum, dōn-ī
                                FStrings[4] := aNom;
                                FStrings.add(aNom);
                                FStrings.add(stem + 'um');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'a');
                                FStrings.add(stem + 'a');
                                FStrings.add(stem + 'a');
                                FStrings.add(stem + 'ōrum');
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'īs');
                              end;end;

  case (aGender = ngMasculine) and (genEnd = 'rī') and isER of TRUE: begin // 2D  -er nouns, e.g. ager, ag-rī
                                stem := stem + 'r';
                                FStrings[4] := aNom;
                                FStrings.add(aNom);
                                FStrings.add(stem + 'um');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'ō');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ōs');
                                FStrings.add(stem + 'ōrum');
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'īs');
                              end;end;

  case genEnd = 'is' of TRUE: begin // 3D
                                FStrings[4] := stem + 'īs';
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'īm');
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ī');
                                FStrings.add(stem + 'ōrum');
                                FStrings.add(stem + 'īs');
                                FStrings.add(stem + 'īs');
                              end;end;

  case genEnd = 'ūs' of TRUE: begin // 4D
                                FStrings[4] := stem + 'us';
                                FStrings.add(stem + 'us');
                                FStrings.add(stem + 'um');
                                FStrings.add(stem + 'ūs');
                                FStrings.add(stem + 'uī');
                                FStrings.add(stem + 'ū');
                                FStrings.add(stem + 'ūs');
                                FStrings.add(stem + 'ūs');
                                FStrings.add(stem + 'ūs');
                                FStrings.add(stem + 'uum');
                                FStrings.add(stem + 'ibus');
                                FStrings.add(stem + 'ibus');
                              end;end;

  case (genEnd = 'eī') or (genEnd = 'ēī') of TRUE: begin // 5D
                                FStrings[4] := stem + 'ēs';
                                FStrings.add(stem + 'ēs');
                                FStrings.add(stem + 'em');
                                FStrings.add(stem + 'eī');
                                FStrings.add(stem + 'eī');
                                FStrings.add(stem + 'ē');
                                FStrings.add(stem + 'ēs');
                                FStrings.add(stem + 'ēs');
                                FStrings.add(stem + 'ēs');
                                FStrings.add(stem + 'ērum');
                                FStrings.add(stem + 'ēbus');
                                FStrings.add(stem + 'ēbus');
                              end;end;
end;

procedure TMainForm.doNoun(nounString: string);
begin
  doNounHeaders;
  lblLatin.caption    := '';
  lblWordType.caption := '';
  case trim(nounString) = '' of TRUE: EXIT; end;

  FStrings.commaText  := nounString;

  case pos('-', FStrings[4]) > 0 of TRUE: doExpandNoun(getNounGender(FStrings[1]), FStrings[2], FStrings[4]); end;

  try
    lblWordType.caption := getWordType(FStrings[0]);
    lblLatin.caption := FStrings[1] + '. ' + FStrings[2] + ' = ' + FStrings[3];

    for var i := 1 to 6 do
      sg.cells[1, i] := ' ' + FStrings[i + 3]; // entries [4] to [9] go in the singular columm

    for var i := 1 to 6 do
      sg.cells[2, i] := ' ' + FStrings[i + 9]; // entries [10] to [15] go in the plural column
  except end; // not every record has every field, but that's ok

  lblInfo.caption := '    ' + getInfo(FStrings[0]);
end;

procedure TMainForm.doNounHeaders;
begin
  clearSG;
  sg.colCount := 3;
  sg.rowCount := 7;
  sg.cells[0, 0] := '+';
  sg.cells[1, 0] := '+singular';
  sg.cells[2, 0] := '+plural';
  sg.cells[0, 1] := '+nominative';
  sg.cells[0, 2] := '+vocative';
  sg.cells[0, 3] := '+accusative';
  sg.cells[0, 4] := '+genitive';
  sg.cells[0, 5] := '+dative';
  sg.cells[0, 6] := '+ablative';
end;

procedure TMainForm.doPronoun(pronounString: string);
var j: integer;
begin
  doPronounHeaders;
  lblLatin.caption    := '';
  lblWordType.caption := '';
  case trim(pronounString) = '' of TRUE: EXIT; end;

  FStrings.commaText  := pronounString;

  try
    lblWordType.caption := getWordType(FStrings[0]);
    lblLatin.caption    := FStrings[2] + ' = ' + FStrings[3];

    for var i := 1 to 10 do begin
      j := i;
      case i > 5 of TRUE: inc(j); end; // create a blank line to separate singular and plural lines
      sg.cells[1, j] := ' ' + FStrings[i + 3]; // entries [4] to [13] go in the singular columm
    end;

    for var i := 1 to 10 do begin
      j := i;
      case i > 5 of TRUE: inc(j); end; // create a blank line to separate singular and plural lines
      sg.cells[2, j] := ' ' + FStrings[i + 13]; // entries [14] to [23] go in the plural column
    end;

    for var i := 1 to 10 do begin
      j := i;
      case i > 5 of TRUE: inc(j); end; // create a blank line to separate singular and plural lines
      sg.cells[3, j] := ' ' + FStrings[i + 23]; // entries [24] to [33] go in the plural column
    end;
  except end; // not every record has every field, but that's ok

  lblInfo.caption := getInfo(FStrings[0]);
end;

procedure TMainForm.doPronounHeaders;
begin
  clearSG;
  sg.colCount := 4;
  sg.rowCount := 12;
  sg.cells[0, 0] := '-singular';
  sg.cells[1, 0] := '+masculine';
  sg.cells[2, 0] := '+feminine';
  sg.cells[3, 0] := '+neuter';
  sg.cells[0, 1] := '+nominative';
  sg.cells[0, 2] := '+accusative';
  sg.cells[0, 3] := '+genitive';
  sg.cells[0, 4] := '+dative';
  sg.cells[0, 5] := '+ablative';
  sg.cells[0, 6] := '-plural';
  sg.cells[1, 6] := '+masculine';
  sg.cells[2, 6] := '+feminine';
  sg.cells[3, 6] := '+neuter';
  sg.cells[0, 7] := '+nominative';
  sg.cells[0, 8] := '+accusative';
  sg.cells[0, 9] := '+genitive';
  sg.cells[0, 10] := '+dative';
  sg.cells[0, 11] := '+ablative';
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
  sg.cells[0, 0] := '+';
  sg.cells[1, 0] := '+singular';
  sg.cells[2, 0] := '+plural';
  sg.cells[0, 1] := '+1st person';
  sg.cells[0, 2] := '+2nd person';
  sg.cells[0, 3] := '+3rd person';
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

initialization
  debugClear;

end.
