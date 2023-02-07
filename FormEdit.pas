unit FormEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TEditForm = class(TForm)
    edtEntry: TEdit;
    lbLatin: TListBox;
    btnExit: TButton;
    cbWordDesc: TComboBox;
    cbMFN: TComboBox;
    cbVerbDesc: TComboBox;
    edtLatin: TEdit;
    edtEnglish: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnClear: TButton;
    Label4: TLabel;
    Label5: TLabel;
    lblPressEnter: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure edtEntryKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbLatinClick(Sender: TObject);
    procedure edtEnglishKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnExitClick(Sender: TObject);
    procedure edtLatinKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnClearClick(Sender: TObject);
    procedure cbWordDescEnter(Sender: TObject);
    procedure cbMFNEnter(Sender: TObject);
    procedure edtEnglishKeyPress(Sender: TObject; var Key: Char);
    procedure cbWordDescCloseUp(Sender: TObject);
    procedure cbVerbDescCloseUp(Sender: TObject);
    procedure edtEntryKeyPress(Sender: TObject; var Key: Char);
    procedure edtLatinKeyPress(Sender: TObject; var Key: Char);
    procedure cbMFNCloseUp(Sender: TObject);
    procedure edtEntryEnter(Sender: TObject);
    procedure edtEntryExit(Sender: TObject);
  private
    entreez:    TStringList;
    FVerbTypes: TStringList;
    FWordTypes: TStringList;
    FStrings:   TStringList;
    FEdit:      boolean;
    function  addEntry: boolean;
    function  getEntry: string;
    function  updEntry: boolean;
    function  replaceQuotes(aString: string): string;
    function  replaceTabs(aString: string): string;
    procedure saveLatin;
    procedure resetAllBoxes;
    procedure resetBoxes;
  public
    procedure populateVerbDescs(verbDescs: TStringList);
    procedure populateWordDescs(wordDescs: TStringList);
    property  VerbTypes: TStringList write FVerbTypes;
    property  WordTypes: TStringList write FWordTypes;
  end;

const
  TXT_EXT = '.txt';
  VALID_KEYS = ['a'..'z', #8, '/', ',', '+', ' ', #22]; // #8 = backspae, #22 = Ctrl-v

var
  DICT_FILE: string;

function getMacronChar(aChar: char): char;
function getMacronWord(key: WORD): WORD;
function isShiftKeyDown: boolean;
function validMacron(key: char): boolean;

implementation

function getMacronChar(aChar: char): char;
begin
  result := aChar;
  case aChar of
    'A', 'a': result := 'ā';
    'E', 'e': result := 'ē';
    'I', 'i': result := 'ī';
    'O', 'o': result := 'ō';
    'U', 'u': result := 'ū';
  end;
end;

function getMacronWord(key: WORD): WORD;
begin
  result := key;
  case key of
    65: result := 257;
    69: result := 275;
    73: result := 299;
    79: result := 333;
    85: result := 363;
  end;
end;

function isShiftKeyDown: boolean;
begin
  result := (GetKeyState(VK_SHIFT) AND $80) <> 0;
end;

function validMacron(key: char): boolean;
begin
  result := FALSE;
  case ord(key) of
    257, 275, 299, 333, 363: result := TRUE; // ā ē ī ō ū
//    257, 275, 299, 333, 363, 256, 274, 298, 332, 362: result := TRUE; // ā ē ī ō ū Ā Ē Ī Ō Ū
  end;
end;

{$R *.dfm}

function TEditForm.addEntry: boolean;
begin
  lbLatin.itemIndex := lbLatin.items.add(getEntry);
  lbLatin.topIndex  := lbLatin.itemIndex - 5;
  saveLatin;
  resetBoxes;
end;

procedure TEditForm.saveLatin;
begin
  lbLatin.items.saveToFile(DICT_FILE);
end;

procedure TEditForm.resetAllBoxes;
begin
  edtLatin.text         := '';
  edtEnglish.text       := '';
  cbWordDesc.itemIndex  := -1;
  cbMFN.itemIndex       := -1;
  cbVerbDesc.itemIndex  := -1;
  FEdit                 := FALSE;
  lblPressEnter.caption := 'press ENTER to ADD';
  edtEntry.text         := '';
  edtLatin.setfocus;
end;

procedure TEditForm.resetBoxes;
// for conveniece, this omits Latin, English and wordType, so that multiple entries (e.g. tenses of the same verb) can be made in succession
begin
  case pos('noun', cbWordDesc.text) > 0 of TRUE:  resetAllBoxes; end;
  case pos('verb', cbWordDesc.text) > 0 of TRUE:  begin
                                                    cbMFN.itemIndex       := -1;
                                                    cbVerbDesc.itemIndex  := -1;
                                                    FEdit                 := FALSE;
                                                    edtEntry.text         := '';
                                                    edtEntry.setFocus;
                                                  end;end;
end;

procedure TEditForm.btnClearClick(Sender: TObject);
begin
  resetAllBoxes;
end;

procedure TEditForm.btnExitClick(Sender: TObject);
begin
  modalResult := mrOK;
end;

procedure TEditForm.cbMFNCloseUp(Sender: TObject);
begin
  edtEntry.setFocus;
end;

procedure TEditForm.cbMFNEnter(Sender: TObject);
begin
  cbMFN.droppedDown := TRUE;
end;

procedure TEditForm.cbVerbDescCloseUp(Sender: TObject);
begin
  edtEntry.setFocus;
end;

procedure TEditForm.cbWordDescCloseUp(Sender: TObject);
begin
  case pos('noun', cbWordDesc.text) > 0 of TRUE:  begin
                                                    cbMFN.droppedDown := TRUE;
                                                    cbMFN.setFocus; end;end;
  case pos('verb', cbWordDesc.text) > 0 of TRUE:  begin
                                                    cbVerbDesc.droppedDown  := TRUE;
                                                    cbVerbDesc.setFocus; end;end;
end;

procedure TEditForm.cbWordDescEnter(Sender: TObject);
begin
  cbWordDesc.itemIndex := -1;
  cbWordDesc.droppedDown := TRUE;
end;

procedure TEditForm.edtEnglishKeyPress(Sender: TObject; var Key: Char);
begin
  case validMacron(key)   of  TRUE: EXIT; end;
  case key in VALID_KEYS  of FALSE: key := #0; end;
end;

procedure TEditForm.edtEnglishKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key = VK_RETURN of  TRUE:  begin cbWordDesc.setFocus; cbWordDesc.droppedDown := TRUE; end;end;
end;

procedure TEditForm.edtEntryEnter(Sender: TObject);
begin
  lblPressEnter.visible := TRUE;
end;

procedure TEditForm.edtEntryExit(Sender: TObject);
begin
  lblPressEnter.visible := FALSE;
end;

procedure TEditForm.edtEntryKeyPress(Sender: TObject; var Key: Char);
begin
  case isShiftKeyDown of TRUE: key := getMacronChar(key); end;
  case validMacron(key)   of  TRUE: EXIT; end;
  case key in VALID_KEYS  of FALSE: key := #0; end;
end;

procedure TEditForm.edtEntryKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
// if cbVerbDescCloseUp is trigged by VK_RETURN, edtEntry.setFocus fires without VK_RETURN being cleared
  case (Key = VK_RETURN) and (trim(edtEntry.text) <> '') of TRUE: case FEDIT of  TRUE: updEntry;
                                                                                FALSE: addEntry; end;end;
end;

procedure TEditForm.edtLatinKeyPress(Sender: TObject; var Key: Char);
begin
  case isShiftKeyDown of TRUE: key := getMacronChar(key); end;
  case validMacron(key)   of  TRUE: EXIT; end;
  case key in VALID_KEYS  of FALSE: key := #0; end;
end;

procedure TEditForm.edtLatinKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key = VK_RETURN of TRUE: edtEnglish.setFocus; end;
end;

procedure TEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  case entreez  <> NIL of TRUE: entreez.free; end;
  case FStrings <> NIL of TRUE: FStrings.free; end;
  action := caFree;
end;

procedure TEditForm.FormCreate(Sender: TObject);
var bakFile: string;
begin
  var i := 0;
  repeat
    inc(i);
    bakFile := format('%s_bak%.3d%s', [DICT_FILE, i, TXT_EXT]);
  until not fileExists(bakFile);

  case copyFile(PWideChar(DICT_FILE), PWideChar(bakFile), TRUE) of FALSE: EXIT; end;

  FStrings := TStringList.create;

  entreez := TStringList.create;
  entreez.loadFromFile(DICT_FILE);

  for i := 0 to entreez.count - 1 do entreez[i] := replaceTabs(entreez[i]);

  lbLatin.items.assign(entreez);
end;

function TEditForm.getEntry: string;
begin
  result := '';
  case cbWordDesc.itemIndex <> -1 of TRUE: result := FWordTypes[cbWordDesc.itemIndex]; end;
  case cbMFN.itemIndex      <> -1 of TRUE: result := result + ',' + cbMFN.items[cbMFN.itemIndex]; end;
  case cbVerbDesc.itemIndex <> -1 of TRUE: result := result + ',' + FVerbTypes[cbVerbDesc.itemIndex]; end;
  result := result + ',' + edtLatin.text + ',' + edtEnglish.text;
  var noTabs := replaceTabs(edtEntry.text);
  case pos(' ', noTabs) > 0 of TRUE: noTabs := '"' + noTabs + '"'; end; // double-quote anything with spaces in it.
  result := result + ',' + noTabs;
end;

procedure TEditForm.lbLatinClick(Sender: TObject);
begin
  resetAllBoxes;
  FStrings.commaText := lbLatin.items[lbLatin.itemIndex];
  case FWordTypes.indexOf(FStrings[0])  <> -1 of TRUE: cbWordDesc.itemIndex := FWordTypes.indexOf(FStrings[0]); end;
  case cbMFN.items.indexOf(FStrings[1]) <> -1 of TRUE: cbMFN.itemIndex      := cbMFN.items.indexOf(FStrings[1]); end;
  case FVerbTypes.indexOf(FStrings[1])  <> -1 of TRUE: cbVerbDesc.itemIndex := FVerbTypes.indexOf(FStrings[1]); end;
  edtLatin.text   := FStrings[2];
  edtEnglish.text := FStrings[3];
  var lenPrefix   := length(FStrings[0] + ',' + FStrings[1] + ',' + FStrings[2] + ',' + FStrings[3] + ',');
  edtEntry.text   := replaceQuotes(copy(FStrings.delimitedText, lenPrefix + 1, 255));
  FEdit := TRUE;
  lblPressEnter.caption := 'press ENTER to UPDATE';
end;

procedure TEditForm.populateVerbDescs(verbDescs: TStringList);
begin
  cbVerbDesc.items.assign(verbDescs);
end;

procedure TEditForm.populateWordDescs(wordDescs: TStringList);
begin
  cbWordDesc.items.assign(wordDescs);
end;

function TEditForm.replaceQuotes(aString: string): string;
begin
  result := stringReplace(aString, '"', '', [rfReplaceAll]);
end;

function TEditForm.replaceTabs(aString: string): string;
begin
  result := stringReplace(aString, #9, ',', [rfReplaceAll]);
end;

function TEditForm.updEntry: boolean;
begin
  lbLatin.items[lbLatin.itemIndex] := getEntry;
  saveLatin;
  resetAllBoxes;
  FEDIT := FALSE;
  lblPressEnter.caption := 'press ENTER to ADD';
  lblPressEnter.visible := FALSE;
end;

end.
