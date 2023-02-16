unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Buttons;

type

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
    FSearchTerm: string;
    procedure clearSG;
    procedure doLatinRec;
    procedure doNounHeaders;
    procedure doNoun;
    procedure doPronoun;
    procedure doPronounHeaders;
    procedure doVerbHeaders;
    procedure doVerb;
    procedure findFirst;
    procedure updateRecLabel;
    procedure checkFindResult(found: boolean);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses FormEdit, latinGrammar, _debugWindow;

const
  DEFAULT_COL_WIDTH = 86;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // non-resizable
  constraints.maxHeight := 460;  // well, maybe just a tad
  constraints.maxWidth  := width;
  constraints.minHeight := height;
  constraints.minWidth  := width;

  latin.iniFilePath := extractFilePath(paramStr(0)) + 'latinator.ini';

  lblFound.caption  := '';
  lblInfo.caption   := '';

  doLatinRec;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  sg.height := lblInfo.top - sg.top;
end;

procedure TMainForm.checkFindResult(found: boolean);
begin
  case found of  TRUE:  begin
                          lblFound.caption := 'Found!';
                          lblFound.visible := TRUE;
                          btnFindNext.visible := TRUE;
                          btnFindNext.setFocus; end;
                FALSE:  begin
                          lblFound.caption := 'Not Found';
                          lblFound.visible := TRUE;
                          btnFindNext.visible := FALSE;
                          edtSearch.setFocus; end;end; // the VK_RETURN culprit! But this needs to be done for UX reasons.
  doLatinRec;
end;

procedure TMainForm.findFirst;
begin
  case edtSearch.text = FSearchTerm of TRUE: begin FSearchTerm := ''; EXIT; end;end; // again, VK_RETURN on btnFindNext triggers in edtSearch.OnKeyPress!
  FSearchTerm := trim(edtSearch.text);
  case FSearchTerm = '' of TRUE: EXIT; end;
  checkFindResult(latin.findFirst(FSearchTerm));
end;

procedure TMainForm.sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  separator: boolean;
  title: boolean;
  heading: boolean;
begin
  // defaults for the Latin part of the grid
  sg.canvas.font.color  := COLOR_SILVER;
  sg.canvas.font.style  := [];
  sg.canvas.font.size   := 12;
  sg.canvas.brush.color := COLOR_LIGHT;

  var text := stringReplace(sg.cells[aCol, aRow], '/', ' / ', [rfReplaceAll]); // looks less cluttered when alternatives are displayed like this

  case length(text) > 0 of  TRUE: begin
                                    heading   := text[1] = '+';
                                    title     := text[1] = '-';
                                    separator := text[1] = '_'; end;end;

  case title of TRUE: begin
                        sg.canvas.brush.color := COLOR_DARK;
                        sg.canvas.font.size   := 10;
                        sg.canvas.font.style := []; end;end;

  case heading of TRUE: begin
                          sg.canvas.brush.color := COLOR_DARK;
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
  lblRecNo.caption := latin.recNoText;
end;

procedure TMainForm.btnEditClick(Sender: TObject);
begin
  with TEditForm.create(NIL) do begin
    showModal;
    latin.loadINIFile;
    doLatinRec;
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
  checkFindResult(latin.findNext);
end;

procedure TMainForm.btnNextClick(Sender: TObject);
begin
  lblFound.caption := '';
  edtSearch.text   := '';
  latin.nextRec;
  doLatinRec;
end;

procedure TMainForm.btnPrevClick(Sender: TObject);
begin
  lblFound.caption := '';
  edtSearch.text   := '';
  latin.prevRec;
  doLatinRec;
end;

procedure TMainForm.clearSG;
begin
  for var i := 0 to sg.ColCount - 1 do begin
    sg.cols[i].Clear;
    sg.colWidths[i] := DEFAULT_COL_WIDTH;
  end;
  sg.rowCount := 1;
end;

procedure TMainForm.doLatinRec;
begin
  lblStar.visible     := FALSE;

  case latin.wordType of
    wtNoun:       doNoun;
    wtVerb:       doVerb;
    wtPronoun:    doPronoun;
    wtAdjective:  doNoun;
  end;

  updateRecLabel;
  lblStar.visible := latin.isAutoExpanded;
  lblInfo.caption := '    ' + latin.wordInfo;
end;

procedure TMainForm.doNoun;
begin
  doNounHeaders;
  lblLatin.caption    := '';
  lblWordType.caption := '';

  try
    lblWordType.caption := latin.wordDesc;
    lblLatin.caption := latin.latinDesc;

    sg.cells[1, 1] := ' ' + latin.nounNomSingular;
    sg.cells[1, 2] := ' ' + latin.nounVocSingular;
    sg.cells[1, 3] := ' ' + latin.nounAccSingular;
    sg.cells[1, 4] := ' ' + latin.nounGenSingular;
    sg.cells[1, 5] := ' ' + latin.nounDatSingular;
    sg.cells[1, 6] := ' ' + latin.nounAblSingular;

    sg.cells[2, 1] := ' ' + latin.nounNomPlural;
    sg.cells[2, 2] := ' ' + latin.nounVocPlural;
    sg.cells[2, 3] := ' ' + latin.nounAccPlural;
    sg.cells[2, 4] := ' ' + latin.nounGenPlural;
    sg.cells[2, 5] := ' ' + latin.nounDatPlural;
    sg.cells[2, 6] := ' ' + latin.nounAblPlural;

  except end; // not every record has every field, but that's ok
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

procedure TMainForm.doPronoun;
begin
  doPronounHeaders;
  lblLatin.caption    := '';
  lblWordType.caption := '';

  try
    lblWordType.caption := latin.wordDesc;
    lblLatin.caption    := latin.pronounDesc;

    sg.cells[1, 1]  := ' ' + latin.pronounMasculineNomSingular;
    sg.cells[1, 2]  := ' ' + latin.pronounMasculineAccSingular;
    sg.cells[1, 3]  := ' ' + latin.pronounMasculineGenSingular;
    sg.cells[1, 4]  := ' ' + latin.pronounMasculineDatSingular;
    sg.cells[1, 5]  := ' ' + latin.pronounMasculineAblSingular;

    sg.cells[1, 7]  := ' ' + latin.pronounMasculineNomPlural;
    sg.cells[1, 8]  := ' ' + latin.pronounMasculineAccPlural;
    sg.cells[1, 9]  := ' ' + latin.pronounMasculineGenPlural;
    sg.cells[1, 10] := ' ' + latin.pronounMasculineDatPlural;
    sg.cells[1, 11] := ' ' + latin.pronounMasculineAblPlural;

    sg.cells[2, 1]  := ' ' + latin.pronounFeminineNomSingular;
    sg.cells[2, 2]  := ' ' + latin.pronounFeminineAccSingular;
    sg.cells[2, 3]  := ' ' + latin.pronounFeminineGenSingular;
    sg.cells[2, 4]  := ' ' + latin.pronounFeminineDatSingular;
    sg.cells[2, 5]  := ' ' + latin.pronounFeminineAblSingular;

    sg.cells[2, 7]  := ' ' + latin.pronounFeminineNomPlural;
    sg.cells[2, 8]  := ' ' + latin.pronounFeminineAccPlural;
    sg.cells[2, 9]  := ' ' + latin.pronounFeminineGenPlural;
    sg.cells[2, 10] := ' ' + latin.pronounFeminineDatPlural;
    sg.cells[2, 11] := ' ' + latin.pronounFeminineAblPlural;

    sg.cells[3, 1]  := ' ' + latin.pronounNeuterNomSingular;
    sg.cells[3, 2]  := ' ' + latin.pronounNeuterAccSingular;
    sg.cells[3, 3]  := ' ' + latin.pronounNeuterGenSingular;
    sg.cells[3, 4]  := ' ' + latin.pronounNeuterDatSingular;
    sg.cells[3, 5]  := ' ' + latin.pronounNeuterAblSingular;

    sg.cells[3, 7]  := ' ' + latin.pronounNeuterNomPlural;
    sg.cells[3, 8]  := ' ' + latin.pronounNeuterAccPlural;
    sg.cells[3, 9]  := ' ' + latin.pronounNeuterGenPlural;
    sg.cells[3, 10] := ' ' + latin.pronounNeuterDatPlural;
    sg.cells[3, 11] := ' ' + latin.pronounNeuterAblPlural;
  except end; // not every record has every field, but that's ok
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

procedure TMainForm.doVerb;
begin
  doVerbHeaders;
  lblLatin.caption    := '';
  lblWordType.caption := '';

  try
    lblWordType.caption := latin.wordDesc + ' - ' + latin.verbType;
    lblLatin.caption    := latin.pronounDesc;

    sg.cells[1, 1] := ' ' + latin.verb1stPersonSingular;
    sg.cells[1, 2] := ' ' + latin.verb2ndPersonSingular;
    sg.cells[1, 3] := ' ' + latin.verb3rdPersonSingular;
    sg.cells[2, 1] := ' ' + latin.verb1stPersonPlural;
    sg.cells[3, 2] := ' ' + latin.verb2ndPersonPlural;
    sg.cells[4, 3] := ' ' + latin.verb3rdPersonPlural;

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
//  lblFound.caption    := '';
end;

procedure TMainForm.edtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  btnFindNext.visible := FALSE;
  case isShiftKeyDown         of  TRUE: key := latin.getMacronChar(key); end;
  case latin.validMacron(key) of  TRUE: EXIT; end;
  case key in VALID_KEYS      of FALSE: key := #0; end;
end;

procedure TMainForm.edtSearchKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  btnFindNext.visible := FALSE;
  case key = VK_RETURN of TRUE: findFirst; end;
end;

initialization
  debugClear;

end.
