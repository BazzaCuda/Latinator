{   Latinator
    Copyright (C) 2019-2099 Baz Cuda
    https://github.com/BazzaCuda/Latinator

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA
}

unit latin.LewisAndShort;

interface

uses
  system.generics.collections,
  system.classes,
  system.sysUtils,
  system.win.comObj,
  winApi.activeX,
  winApi.msxml,
  latin.consoleUtils, latin.types;

type

  TStringFunc = reference to function(const aValue: string): TVoid;

  ICitation = interface
    function getAuthor(const aIndex: integer): string;
    function getAuthorCount: integer;
    function getBibl:      string;
    function getN:         string;
    function getQuote:    string;

    property author[const aIndex: integer]: string read getAuthor;
    property authorCount:  integer read getAuthorCount;
    property bibliography:  string read getBibl;
    property N:             string read getN;
    property quote:         string read getQuote;
  end;

  ITEISense = interface
    function getDefinition:     string;
    function getID:             string;
    function getN:              string;
    function getLevel:          integer;

    function getCitation(const aIndex: integer): ICitation;
    function getCitationCount: integer;
    function iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;

    property citation[const aIndex: integer]: ICitation read getCitation;
    property citations[const aIndex: integer]: ICitation    read getCitation;
    property citationCount:     integer                     read getCitationCount;
    property definition:        string                      read getDefinition;
    property ID:                string                      read getID;
    property N:                 string                      read getN;
    property level:             integer                     read getLevel;

  end;

  ILewisAndShortEntry = interface
    function getCase:           string;
    function getDefinition:     string;
    function getEntryType:      string;
    function getEtymology:      string;
    function getGender:         string;
    function getID:             string;
    function getInflection:     string;
    function getKey:            string;
    function getLanguage:       string;
    function getMood:           string;
    function getOrthography:    string;
    function getOrthography2:   string;
    function getPartOfSpeech:   string;
    function getSense(const aIndex: integer): ITEISense;
    function getSenseCount:     integer;

    function senseAsStrings(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;

    property caseCase:      string                  read getCase;
    property definition:    string                  read getDefinition;
    property entryType:     string                  read getEntryType;
    property etymology:     string                  read getEtymology;
    property gender:        string                  read getGender;
    property ID:            string                  read getID;
    property inflection:    string                  read getInflection;
    property key:           string                  read getKey;
    property language:      string                  read getLanguage;
    property mood:          string                  read getMood;
    property orthography:   string                  read getOrthography;
    property orthography2:  string                  read getOrthography2;
    property partOfSpeech:  string                  read getPartOfSpeech;
    property sense[const aIndex: integer]: ITEISense read getSense;
    property senseCount:    integer                 read getSenseCount;
  end;

  ILewisAndShort = interface
    function entryCount: integer;
    function findEntry(aKey: string): ILewisAndShortEntry;
    function loadLewisAndShort(const aFileName: string): TVoid;

    function export(const aFileName: string): TVoid;
    function import(const aFileName: string): TVoid;
  end;

  function newLewisAndShort: ILewisAndShort;

implementation

uses
  system.math,
  system.regularExpressions,
  system.strUtils,
  _debugWindow;

type
  TCitation = class(TInterfacedObject, ICitation)
  strict private
    FAuthors: TList<string>;
    FBibl:    string;
    FN:       string;
    FQuote:   string;
  private
    function getN: string;
    function getQuote: string;
    function getAuthor(const aIndex: integer): string;
    function getAuthorCount: integer;
    function getBibl: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure addAuthor(const aValue: string);
    property bibl:      string read getBibl   write FBibl;
    property N:         string read getN      write FN;
    property quote:     string read getQuote  write FQuote;
  end;

  TTEISense = class(TinterfacedObject, ITEISense)
  strict private
    FID:          string;
    FN:           string;
    FLevel:       string;
    FDefinition:  string;
    FCitations:   TList<ICitation>;
  private
    function getFN: string;
    function addCitation(const aCitation: TCitation): TVoid; overload;
    function addCitation(const aAuthor: string; const aBibl: string; const aN: string; const aQuote: string): TVoid; overload;
  public
    constructor Create;
    destructor Destroy; override;
    function getDefinition:     string;
    function getID:             string;
    function getN:              string;
    function getLevel:          integer;
    procedure setLevel(const aValue: string);

    function getCitation(const aIndex: integer): ICitation;
    function getCitationCount: integer;
    function iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;

    property citation[const aIndex: integer]: ICitation read getCitation;
    property ID:          string                  read getID            write FID;
    property N:           string                  read getFN            write FN;
    property level:       integer                 read getLevel;
    property definition:  string                  read getDefinition    write FDefinition;
  end;

  TTEIEntry = class(TinterfacedObject, ILewisAndShortEntry)
  strict private
    FCase:          string;
    FDefinition:    string;
    FEntryType:     string;
    FEtymology:     string;
    FGender:        string;
    FID:            string;
    FInflection:    string;
    FKey:           string;
    FLanguage:      string;
    FMood:          string;
    FOrthography:   string;
    FOrthography2:  string;
    FPartOfSpeech:  string;
    FSenses:        TList<ITEISense>;

  private
    function getCase:           string;
    function getDefinition:     string;
    function getEntryType:      string;
    function getEtymology:      string;
    function getGender:         string;
    function getID:             string;
    function getInflection:     string;
    function getKey:            string;
    function getLanguage:       string;
    function getMood:           string;
    function getOrthography:    string;
    function getOrthography2:   string;
    function getPartOfSpeech:   string;
    function getSenses:         TList<ITEISense>;
    function getSense(const aIndex: integer): ITEISense;
    function getSenseCount:     integer;

    function senseAsStrings(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;

  public
    constructor Create;
    destructor Destroy; override;
    property caseCase:      string                  read getCase          write FCase;
    property definition:    string                  read getDefinition    write FDefinition;
    property entryType:     string                  read getEntryType     write FEntryType;
    property etymology:     string                  read getEtymology     write FEtymology;
    property gender:        string                  read getGender        write FGender;
    property ID:            string                  read getID            write FID;
    property inflection:    string                  read getInflection    write FInflection;
    property key:           string                  read getKey           write FKey;
    property language:      string                  read getLanguage      write FLanguage;
    property mood:          string                  read getMood          write FMood;
    property orthography:   string                  read getOrthography   write FOrthography;
    property orthography2:  string                  read getOrthography2  write FOrthography2;
    property partOfSpeech:  string                  read getPartOfSpeech  write FPartOfSpeech;
    property senses:        TList<ITEISense>        read FSenses;
  end;

  TLewisAndShort = class(TInterfacedObject, ILewisAndShort)
  strict private
    FEntries: TList<ILewisAndShortEntry>;
    FIndex:   TDictionary<string, ILewisAndShortEntry>;

    FRegexEllipsisMask:       TRegEx;
    FRegexFloatingPunc:       TRegEx;
    FRegexConsecutivePunc:    TRegEx;
    FRegexMultiSpace:         TRegEx;
    FRegexEllipsisUnmask:     TRegEx;
    FRegexLeadingPunc:        TRegEx;

  private
    function cleanCrapData(const aInput: string): string;
    function getEntryPreamble(const aTarget: IXMLDOMNode): string;
    function exportCRecord(const aWriter: TStreamWriter; const aCitation: ICitation): TVoid;
    function exportMRecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): TVoid;
    function exportORecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): TVoid;
    function exportSRecord(const aWriter: TStreamWriter; const aSense: ITEISense): TVoid;
    function exportWRecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): TVoid;
    function importCRecord(const aLine: string; const aSense: ITEISense): TCitation;
    function importMRecord(const aLine: string; const aEntry: TTEIEntry): TVoid;
    function importORecord(const aLine: string; const aEntry: TTEIEntry): TVoid;
    function importSRecord(const aLine: string; const aEntry: TTEIEntry): TTEISense;
    function importWRecord(const aLine: string): TTEIEntry;
    function parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
  public
    constructor Create;
    destructor Destroy; override;
    function entryCount: integer;
    function findEntry(aKey: string): ILewisAndShortEntry;
    function loadLewisAndShort(const aFilePath: string): TVoid;
    property entries: TList<ILewisAndShortEntry> read FEntries;

    function export(const aFileName: string): TVoid;
    function import(const aFileName: string): TVoid;
  end;

function newLewisAndShort: ILewisAndShort;
begin
  result := TLewisAndShort.Create;
end;

constructor TTEISense.Create;
begin
  inherited Create;
  FCitations := TList<ICitation>.Create;
end;

destructor TTEISense.Destroy;
begin
  FCitations.clear;
  FCitations.free;
  inherited Destroy;
end;

function TTEISense.addCitation(const aCitation: TCitation): TVoid;
begin
  FCitations.add(aCitation);
end;

function TTEISense.addCitation(const aAuthor: string; const aBibl: string; const aN: string; const aQuote: string): TVoid;
begin
  var vCitation := TCitation.Create;
  vCitation.addAuthor(aAuthor);
  vCitation.bibl  := aBibl;
  vCitation.N     := aN;
  vCitation.quote := aQuote;
  FCitations.add(vCitation);
end;

function TTEISense.getCitation(const aIndex: integer): ICitation;
begin
  result := FCitations[aIndex];
end;

function TTEISense.getCitationCount: integer;
begin
  result := FCitations.count;
end;

function TTEISense.getDefinition: string;
begin
  result := FDefinition;
end;

function TTEISense.getFN: string;
begin
  result := FN;
end;

function TTEISense.getID: string;
begin
  result := FID;
end;

function TTEISense.getLevel: integer;
begin
  result := strToIntDef(FLevel, 0);
end;

function TTEISense.getN: string;
begin
  result := FN;
end;

function TTEISense.iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;
begin
  var vPrefix := stringOfChar(' ', getLevel * aIndent) + '[' + trim(FN) + '] ';

  case (FDefinition <> '') of
    TRUE:  aFunc(vPrefix + FDefinition);
    FALSE: aFunc(vPrefix);
  end;

  for var i := 0 to FCitations.count - 1 do
  begin
    var vCitation       := FCitations[i];
    var vCitationIndent := stringOfChar(' ', (getLevel + 1) * aIndent);
    var vCitationText   := '';

    case vCitation.quote <> '' of TRUE: vCitationText := vCitationText + vCitationIndent + ' Q: "' + trim(vCitation.quote) + '"' + #13#10; end;

    for var k := 0 to vCitation.authorCount - 1 do
    begin
      case vCitation.author[k] <> '' of
        TRUE: vCitationText := vCitationText + vCitationIndent + ' A: ' + trim(vCitation.author[k]) + #13#10;
      end;
    end;

    case vCitation.bibliography <> '' of TRUE: vCitationText := vCitationText + vCitationIndent + ' B: ' + trim(vCitation.bibliography); end;

    case trim(vCitation.n) <> '' of TRUE: vCitationText := vCitationText + ' (' + trim(vCitation.n) + ')'; end;

    aFunc(vCitationText);
  end;
end;

procedure TTEISense.setLevel(const aValue: string);
begin
  FLevel := aValue;
end;

constructor TTEIEntry.Create;
begin
  inherited create;
  FSenses := TList<ITEISense>.Create;
end;

destructor TTEIEntry.Destroy;
begin
  FSenses.clear;
  FSenses.free;
  inherited Destroy;
end;

function TTEIEntry.getCase: string;
begin
  result := FCase;
end;

function TTEIEntry.getDefinition: string;
begin
  result := FDefinition;
end;

function TTEIEntry.getEntryType: string;
begin
  result := FEntryType;
end;

function TTEIEntry.getEtymology: string;
begin
  result := FEtymology;
end;

function TTEIEntry.getGender: string;
begin
  result := FGender;
end;

function TTEIEntry.getID: string;
begin
  result := FID;
end;

function TTEIEntry.getInflection: string;
begin
  result := FInflection;
end;

function TTEIEntry.getKey: string;
begin
  result := FKey;
end;

function TTEIEntry.getLanguage: string;
begin
  result := FLanguage;
end;

function TTEIEntry.getMood: string;
begin
  result := FMood;
end;

function TTEIEntry.getOrthography: string;
begin
  result := FOrthography;
end;

function TTEIEntry.getOrthography2: string;
begin
  result := FOrthography2;
end;

function TTEIEntry.getPartOfSpeech: string;
begin
  result := FPartOfSpeech;
end;

function TTEIEntry.getSense(const aIndex: integer): ITEISense;
begin
  case aIndex > FSenses.count - 1 of   TRUE: result := NIL;
                                      FALSE: result := FSenses[aIndex]; end;
end;

function TTEIEntry.getSenseCount: integer;
begin
  result := FSenses.count;
end;

function TTEIEntry.getSenses: TList<ITEISense>;
begin
  result := FSenses;
end;

function TTEIEntry.senseAsStrings(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;
begin
  for var i := 0 to FSenses.count - 1 do FSenses[i].iterateSenses(aFunc, aIndent);
end;

function TLewisAndShort.cleanCrapData(const aInput: string): string;
const
  MASK = '[[ELLIP]]';
begin
  result := aInput;
  case result = '' of TRUE: EXIT; end;

  result := FRegexEllipsisMask.replace(result, MASK);
  result := FRegexLeadingPunc.replace(result, '');

  while FRegexFloatingPunc.IsMatch(result) do result := FRegexFloatingPunc.Replace(result, '');

  result := FRegexConsecutivePunc.replace(result, '$1');
  result := FRegexMultiSpace.replace(result, ' ');
  result := FRegexEllipsisUnmask.replace(result, '... ');

  result := trim(result);
end;

constructor TLewisAndShort.Create;
begin
  inherited create;
  FEntries          := TList<ILewisAndShortEntry>.create;
  FEntries.capacity := 50000;
  FIndex            := TDictionary<string, ILewisAndShortEntry>.Create(50000);

  FRegexEllipsisMask    := TRegEx.Create('\.\.\.\s?',           [roCompiled]);
  FRegexLeadingPunc     := TRegEx.Create('^\s*[.,;:?!]\s+',     [roCompiled]);
  FRegexFloatingPunc    := TRegEx.Create('\s+[.,;:?!](?=\s+)',  [roCompiled]);
  FRegexConsecutivePunc := TRegEx.Create('([.,;:?!])\s*\1+',    [roCompiled]);
  FRegexMultiSpace      := TRegEx.Create('\s{2,}',              [roCompiled]);
  FRegexEllipsisUnmask  := TRegEx.Create('\[\[ELLIP\]\]',       [roCompiled]);
end;

destructor TLewisAndShort.Destroy;
begin
  debug('destroy');
  FEntries.clear;
  FIndex.clear;
  FEntries.free;
  FIndex.free;
  inherited Destroy;
end;

function TLewisAndShort.entryCount: integer;
begin
  result := FEntries.count;
end;

function TLewisAndShort.findEntry(aKey: string): ILewisAndShortEntry;
begin
  var vKey1 := aKey[1];

  repeat

    var vKey := aKey;
    var i    := 0;

    repeat

      FIndex.tryGetValue(vKey, result);
      inc(i);
      vKey := format('%s%d', [aKey, i]);

    until (result <> NIL) or (i > 9);

    case result = NIL of TRUE: aKey[1] := char(ord(aKey[1]) xor 32); end; // toggle upperCase/lowerCase

  until (result <> NIL) or (aKey[1] = vKey1);
end;

function TLewisAndShort.getEntryPreamble(const aTarget: IXMLDOMNode): string;
begin
  result := '';
  var vChildren := aTarget.childNodes;
  case not assigned(vChildren) of TRUE: EXIT; end;

  var vFirstOrthFound := FALSE;
  for var i := 0 to vChildren.length - 1 do
  begin
    var vChild := vChildren.item[i];
    var vName  := vChild.nodeName;

    case sameText(vName, 'sense') of TRUE: BREAK; end;
    case sameText(vName, 'orth') and (not vFirstOrthFound) of TRUE: begin vFirstOrthFound := TRUE; CONTINUE; end; end;
    case sameText(vName, 'etym') of TRUE: CONTINUE; end;

    result := result + vChild.text;
  end;
  result := cleanCrapData(result);
end;

function TLewisAndShort.parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
var
  vQuoteText  : string;
  vDefinition : string;
  vSense      : TTEISense;

  function getFilteredText(const aTarget: IXMLDOMNode; const aExcludeTags: array of string): string;
  begin
    result := '';
    var vChildren := aTarget.childNodes;
    case not assigned(vChildren) of TRUE: EXIT; end;

    for var i := 0 to vChildren.length - 1 do
    begin
      var vChild := vChildren.item[i];
      var vSkip  := FALSE;
      case (vChild.nodeType = 1) of
        TRUE:
          for var vTag in aExcludeTags do
            case sameText(vChild.nodeName, vTag) of TRUE: begin vSkip := TRUE; BREAK; end; end;
      end;
      case vSkip of FALSE: result := result + vChild.text; end;
    end;
  end;

begin
  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');
  case assigned(vSenseNodes) of
    TRUE:
      for var i := 0 to vSenseNodes.length - 1 do
      begin
        var vSenseNode : IXMLDOMNode := vSenseNodes.item[i];
        vSense := TTEISense.create;
        var iSense : ITEISense := vSense;
        aList.add(iSense);

        var vAttrs := vSenseNode.attributes;
        case assigned(vAttrs) of
          TRUE:
            begin
              var vLevelAttr := vAttrs.getNamedItem('level');
              case assigned(vLevelAttr) of TRUE: vSense.setLevel(vLevelAttr.text); end;
              var vNAttr := vAttrs.getNamedItem('n');
              case assigned(vNAttr) of TRUE: vSense.n := vNAttr.text; end;
              var vIdAttr := vAttrs.getNamedItem('id');
              case assigned(vIdAttr) of TRUE: vSense.id := vIdAttr.text; end;
            end;
        end;

        vDefinition := cleanCrapData(getFilteredText(vSenseNode, ['sense']));

        var vCitations := vSenseNode.selectNodes('.//cit | .//bibl');
        case assigned(vCitations) of
          TRUE:
            for var j := 0 to vCitations.length - 1 do
            begin
              var vCurrentNode     := vCitations.item[j];
              var vCurrentNodeName := vCurrentNode.nodeName;
              case sameText(vCurrentNodeName, 'bibl') and assigned(vCurrentNode.parentNode) and sameText(vCurrentNode.parentNode.nodeName, 'cit') of TRUE: CONTINUE; end;

              var vQuote : IXMLDOMNode := NIL;
              var vBibl  : IXMLDOMNode := NIL;
              vQuoteText := '';

              case sameText(vCurrentNodeName, 'cit') of
                TRUE:
                  begin
                    vQuote := vCurrentNode.selectSingleNode('quote');
                    vBibl  := vCurrentNode.selectSingleNode('bibl');
                    case assigned(vQuote) of TRUE: vQuoteText := vQuote.text; end;
                  end;
                FALSE: vBibl := vCurrentNode;
              end;

              case assigned(vBibl) of
                TRUE:
                  begin
                    var vCitation   := TCitation.create;
                    vCitation.quote := vQuoteText;
                    vCitation.bibl  := cleanCrapData(getFilteredText(vBibl, ['author']));
                    var vNAttr      := vBibl.attributes.getNamedItem('n');
                    case assigned(vNAttr) of TRUE: vCitation.N := vNAttr.text; end;
                    var vAuthors := vBibl.selectNodes('author');
                    case assigned(vAuthors) of TRUE: for var k := 0 to vAuthors.length - 1 do vCitation.addAuthor(vAuthors.item[k].text); end;
                    vSense.addCitation(vCitation);
                  end;
              end;
            end;
        end;
        vSense.definition := vDefinition;
      end;
  end;
end;

function TLewisAndShort.loadLewisAndShort(const aFilePath: string): TVoid;
begin
  case fileExists(aFilePath) of FALSE: EXIT; end;

  FEntries.clear;
  FIndex.clear;

  var vXML: IXMLDOMDocument2 := createComObject(CLASS_DOMDocument60) as IXMLDOMDocument2;
  vXML.async := FALSE;
  vXML.resolveExternals := FALSE;
  vXML.validateOnParse := FALSE;
  vXML.setProperty('SelectionLanguage', 'XPath');
  vXML.preserveWhiteSpace := TRUE;

  case vXML.load(aFilePath) of
    TRUE:
      begin
        var vEntries := vXML.selectNodes('/body/div0/entryFree');
        case assigned(vEntries) of
          TRUE:
            for var i := 0 to vEntries.length - 1 do
            begin
              var vNode  : IXMLDOMNode         := vEntries.item[i];
              var vEntry : TTEIEntry           := TTEIEntry.create;
              var iEntry : ILewisAndShortEntry := vEntry;

              FEntries.add(iEntry);
              vEntry.definition := getEntryPreamble(vNode);

              var vAttrs := vNode.attributes;
              case assigned(vAttrs) of
                TRUE:
                  begin
                    var vIdAttr := vAttrs.getNamedItem('id');
                    case assigned(vIdAttr) of TRUE: vEntry.id := vIdAttr.text; end;
                    var vKeyAttr := vAttrs.getNamedItem('key');
                    case assigned(vKeyAttr) of TRUE: vEntry.key := vKeyAttr.text; end;
                    var vTypeAttr := vAttrs.getNamedItem('type');
                    case assigned(vTypeAttr) of TRUE: vEntry.entryType := vTypeAttr.text; end;
                  end;
              end;

              var vOrthNodes := vNode.selectNodes('orth');
              case (vOrthNodes.length > 0) of
                TRUE:
                  begin
                    var vFirstOrth     := vOrthNodes.item[0];
                    vEntry.orthography := vFirstOrth.text;
                    var vOAttrs        := vFirstOrth.attributes;
                    case assigned(vOAttrs) of
                      TRUE:
                        begin
                          var vLangAttr := vOAttrs.getNamedItem('lang');
                          case assigned(vLangAttr) of TRUE: vEntry.language := vLangAttr.text; end;
                        end;
                    end;
                    case (vOrthNodes.length > 1) of TRUE: vEntry.orthography2 := vOrthNodes.item[1].text; end;
                  end;
              end;

              var vGen := vNode.selectSingleNode('gen');
              case assigned(vGen) of TRUE: vEntry.gender := vGen.text; end;

              var vIType := vNode.selectSingleNode('itype');
              case assigned(vIType) of TRUE: vEntry.inflection := vIType.text; end;

              var vEtym := vNode.selectSingleNode('etym');
              case assigned(vEtym) of TRUE: vEntry.etymology := cleanCrapData(vEtym.text); end;

              parseSenses(vNode, vEntry.senses);

              case (vEntry.key <> '') of TRUE: FIndex.tryAdd(vEntry.key, vEntry); end;
            end;
        end;
      end;
  end;
end;

{ Export / Import }

function copyToBuffer(const aSource: string; var aDest: array of char): TVoid;
begin
  var vCount := min(length(aSource), length(aDest));
  case (vCount > 0) of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end;
end;

function TLewisAndShort.exportWRecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): tVoid;
begin
  var vByteLength := sizeOf(TWRecord);
  var vLineLength := vByteLength div sizeOf(char);
  var vPadding    := stringOfChar(' ', vLineLength);
  var vRecord     : TWRecord;

  move(pointer(vPadding)^, vRecord, vByteLength);

  vRecord.wrRecType := 'W';
  vRecord.wrFiller  := ' ';

  // case aEntry.key.indexOfAny(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) <> -1 of TRUE: debugString('key', aEntry.key); end;

  copyToBuffer(aEntry.key,       vRecord.wrKey);
  copyToBuffer(aEntry.id,        vRecord.wrID);
  copyToBuffer(aEntry.entryType, vRecord.wrEntryType);
  copyToBuffer(aEntry.language,  vRecord.wrLanguage);

  var vOutLine: string;
  setLength(vOutLine, vLineLength);
  move(vRecord, pointer(vOutLine)^, vByteLength);
  aWriter.writeLine(vOutLine);
end;

function TLewisAndShort.exportMRecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): tVoid;
begin
  var vByteLength := sizeOf(TMRecord);
  var vLineLength := vByteLength div sizeOf(char);
  var vPadding    := stringOfChar(' ', vLineLength);
  var vRecord     : TMRecord;

  move(pointer(vPadding)^, vRecord, vByteLength);

  vRecord.mrRecType := 'M';
  vRecord.mrFiller  := ' ';

  copyToBuffer(aEntry.gender,       vRecord.mrGender);
  copyToBuffer(aEntry.inflection,   vRecord.mrInflection);
  copyToBuffer(aEntry.partOfSpeech, vRecord.mrPartOfSpeech);
  copyToBuffer(aEntry.mood,         vRecord.mrMood);
  copyToBuffer(aEntry.caseCase,     vRecord.mrCase);

  var vOutLine: string;
  setLength(vOutLine, vLineLength);
  move(vRecord, pointer(vOutLine)^, vByteLength);
  aWriter.writeLine(vOutLine);
end;

function TLewisAndShort.exportORecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): tVoid;
begin
  var vByteLength := sizeOf(TORecord);
  var vLineLength := vByteLength div sizeOf(char);
  var vPadding    := stringOfChar(' ', vLineLength);
  var vRecord     : TORecord;

  move(pointer(vPadding)^, vRecord, vByteLength);

  vRecord.orRecType := 'O';
  vRecord.orFiller  := ' ';

  copyToBuffer(aEntry.orthography,  vRecord.orOrthography);
  copyToBuffer(aEntry.orthography2, vRecord.orOrthography2);

  var vOutLine: string;
  setLength(vOutLine, vLineLength);
  move(vRecord, pointer(vOutLine)^, vByteLength);
  aWriter.writeLine(vOutLine);
end;

function TLewisAndShort.exportSRecord(const aWriter: TStreamWriter; const aSense: ITEISense): TVoid;
begin
  var vByteLength := sizeOf(TSRecord);
  var vLineLength := vByteLength div sizeOf(char);
  var vPadding    := stringOfChar(' ', vLineLength);
  var vRecord     : TSRecord;

  move(pointer(vPadding)^, vRecord, vByteLength);

  vRecord.srRecType := 'S';
  vRecord.srFiller1 := ' ';
  vRecord.srLevel   := intToStr(aSense.level)[1];
  vRecord.srFiller2 := ' ';

  copyToBuffer(aSense.n,  vRecord.srN);
  copyToBuffer(aSense.id, vRecord.srID);

  var vOutLine: string;
  setLength(vOutLine, vLineLength);
  move(vRecord, pointer(vOutLine)^, vByteLength);
  aWriter.writeLine(vOutLine);

  case (aSense.definition <> '') of TRUE: aWriter.writeLine('X ' + aSense.definition); end;
end;

function TLewisAndShort.exportCRecord(const aWriter: TStreamWriter; const aCitation: ICitation): TVoid;
begin
  aWriter.writeLine('C ' + aCitation.N);
  for var i := 0 to aCitation.authorCount - 1 do aWriter.writeLine('A ' + aCitation.author[i]);
  case (aCitation.bibliography <> '') of TRUE: aWriter.writeLine('B ' + aCitation.bibliography); end;
  case (aCitation.quote <> '')        of TRUE: aWriter.writeLine('Q ' + aCitation.quote); end;
end;

function TLewisAndShort.export(const aFileName: string): TVoid;
begin
  var vStream := TFileStream.create(aFileName, fmCreate);
  var vWriter := TStreamWriter.create(vStream, TEncoding.UTF8);

  for var i := 0 to FEntries.count - 1 do
  begin
    var vEntry := FEntries[i];

    exportWRecord(vWriter, vEntry);
    exportMRecord(vWriter, vEntry);
    exportORecord(vWriter, vEntry);

    case (vEntry.etymology <> '') of TRUE: vWriter.writeLine('E ' + vEntry.etymology); end;
    case (vEntry.definition <> '') of TRUE: vWriter.writeLine('D ' + vEntry.definition); end;

    for var j := 0 to vEntry.senseCount - 1 do
    begin
      var vSense := vEntry.sense[j];
      exportSRecord(vWriter, vSense);
      for var k := 0 to vSense.citationCount - 1 do exportCRecord(vWriter, vSense.citations[k]);
    end;
  end;

  vWriter.free;
  vStream.free;
end;

function TLewisAndShort.importWRecord(const aLine: string): TTEIEntry;
begin
  var vRecord: TWRecord;
  move(pointer(aLine)^, vRecord, sizeOf(TWRecord));

  result := TTEIEntry.Create;
  var iEntry: ILewisAndShortEntry := result;

  result.key       := trim(string(vRecord.wrKey));
  result.id        := string(vRecord.wrID);
  result.entryType := string(vRecord.wrEntryType);
  result.language  := string(vRecord.wrLanguage);

  FEntries.add(iEntry);

  case (result.key <> '') of TRUE: FIndex.tryAdd(result.key, iEntry); end;
end;

function TLewisAndShort.importMRecord(const aLine: string; const aEntry: TTEIEntry): tVoid;
begin
  var vRecord: TMRecord;
  move(pointer(aLine)^, vRecord, sizeOf(TMRecord));

  aEntry.gender       := string(vRecord.mrGender);
  aEntry.inflection   := string(vRecord.mrInflection);
  aEntry.partOfSpeech := string(vRecord.mrPartOfSpeech);
  aEntry.mood         := string(vRecord.mrMood);
  aEntry.caseCase     := string(vRecord.mrCase); end;

function TLewisAndShort.importORecord(const aLine: string; const aEntry: TTEIEntry): tVoid;
begin
  var vRecord: TORecord;
  move(pointer(aLine)^, vRecord, sizeOf(TORecord));

  aEntry.orthography  := string(vRecord.orOrthography);
  aEntry.orthography2 := string(vRecord.orOrthography2); end;

function TLewisAndShort.importSRecord(const aLine: string; const aEntry: TTEIEntry): TTEISense;
var
  vRecord: TSRecord;
begin
  move(pointer(aLine)^, vRecord, sizeOf(vRecord));
  var vSense := TTEISense.create;
  result := vSense;

  vSense.setLevel(vRecord.srLevel);
  vSense.n  := vRecord.srN;
  vSense.id := vRecord.srID;

  aEntry.senses.add(vSense);
end;

function TLewisAndShort.importCRecord(const aLine: string; const aSense: ITEISense): TCitation;
begin
  result    := TCitation.create;
  result.N  := copy(aLine, 3, MaxInt);
  TTEISense(aSense).addCitation(result);
end;

function TLewisAndShort.import(const aFileName: string): TVoid;
begin
  case not fileExists(aFileName) of TRUE: EXIT; end;

  FEntries.clear;
  FIndex.clear;

  var vStream                       := TFileStream.create(aFileName, fmOpenRead or fmShareDenyWrite);
  var vReader                       := TStreamReader.create(vStream, TEncoding.UTF8, FALSE, 131072); // 128K
  var vCurrentEntry    : TTEIEntry  := NIL;
  var vCurrentSense    : ITEISense  := NIL;
  var vCurrentCitation : TCitation  := NIL;

  while not vReader.endOfStream do
  begin
    var vLine := vReader.readLine;
    case vLine[1] of
      'W':
        begin
          vCurrentEntry    := importWRecord(vLine);
          vCurrentSense    := NIL;
          vCurrentCitation := NIL;
        end;
      'M': importMRecord(vLine, vCurrentEntry);
      'O': importORecord(vLine, vCurrentEntry);
      'E': vCurrentEntry.etymology  := copy(vLine, 3, MaxInt);
      'D': vCurrentEntry.definition := copy(vLine, 3, MaxInt);
      'S':  begin
              vCurrentSense    := importSRecord(vLine, vCurrentEntry);
              vCurrentCitation := NIL;
            end;
      'X': TTEISense(vCurrentSense).definition  := copy(vLine, 3, MaxInt);
      'C': vCurrentCitation                     := importCRecord(vLine, vCurrentSense);
      'A': vCurrentCitation.addAuthor(copy(vLine, 3, MaxInt));
      'B': vCurrentCitation.bibl := copy(vLine, 3, MaxInt);
      'Q': vCurrentCitation.quote := copy(vLine, 3, MaxInt);
    end;
  end;

  vReader.free;
  vStream.free;
end;

{ TCitation }

constructor TCitation.Create;
begin
  inherited Create;
  FAuthors := TList<string>.Create;
end;

destructor TCitation.Destroy;
begin
  FAuthors.free;
  inherited Destroy;
end;

procedure TCitation.addAuthor(const aValue: string);
begin
  FAuthors.add(aValue);
end;

function TCitation.getAuthor(const aIndex: integer): string;
begin
  result := FAuthors[aIndex];
end;

function TCitation.getAuthorCount: integer;
begin
  result := FAuthors.count;
end;

function TCitation.getBibl: string;
begin
  result := FBibl;
end;

function TCitation.getN: string;
begin
  result := FN;
end;

function TCitation.getQuote: string;
begin
  result := FQuote;
end;
initialization
  coInitialize(NIL);

finalization
  coUninitialize;

end.
