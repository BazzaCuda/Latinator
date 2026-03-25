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
    function getAuthor:   string;
    function getBibl:     string;
    function getN:        string;
    function getQuote:    string;

    property author:        string read getAuthor;
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
    function findEntry(const aKey: string): ILewisAndShortEntry;
    function loadLewisAndShort(const aFileName: string): TVoid;

    function export(const aFileName: string): TVoid;
    function import(const aFileName: string): TVoid;
  end;

  function newLewisAndShort: ILewisAndShort;

implementation

uses
  system.strUtils,
  _debugWindow;

type
  TCitation = class(TInterfacedObject, ICitation)
  strict private
    FAuthor:  string;
    FBibl:    string;
    FN:       string;
    FQuote:   string;
  private
    function getN: string;
    function getQuote: string;
    function getAuthor: string;
    function getBibl: string;
  public
    constructor Create;
    property author:    string read getAuthor write FAuthor;
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
//    property subSenses:   TList<ITEISense>        read getSubSenses;
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
    function parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
  private
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

  public
    constructor Create;
    destructor Destroy; override;
    function entryCount: integer;
    function findEntry(const aKey: string): ILewisAndShortEntry;
    function loadLewisAndShort(const aFileName: string): TVoid;
    function loadLewisAndShort2(const aFileName: string): TVoid;
    function parseSenses2(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
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
  var vCit := TCitation.Create;
  vCit.author := aAuthor;
  vCit.bibl   := aBibl;
  vCit.N      := aN;
  vCit.quote  := aQuote;
  FCitations.add(vCit);
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
  var vPrefix := stringOfChar(' ', getLevel * aIndent) + '[' + FN + '] ';

  case (FDefinition <> '') of  TRUE: aFunc(vPrefix + FDefinition);
                              FALSE: aFunc(vPrefix); end;

  for var i := 0 to FCitations.count - 1 do begin
    var vCitation       := FCitations[i];
    var vCitationIndent := stringOfChar(' ', (getLevel + 1) * aIndent); // + '> ';
    var vCitationText   := '';

    case vCitation.quote         <> '' of TRUE: vCitationText := vCitationText + vCitationIndent + ' Q: "'  + trim(vCitation.quote)         + '"' + #13#10; end;
    case vCitation.author        <> '' of TRUE: vCitationText := vCitationText + vCitationIndent + ' A: '   + trim(vCitation.author)        + #13#10;       end;
    case vCitation.bibliography  <> '' of TRUE: vCitationText := vCitationText + vCitationIndent + ' B: '   + trim(vCitation.bibliography);                 end;

    case vCitation.n             <> '' of TRUE: vCitationText := vCitationText +              ' (' + vCitation.n + ')'; end;

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

constructor TLewisAndShort.Create;
begin
  inherited create;
  FEntries  := TList<ILewisAndShortEntry>.create;
  FIndex    := TDictionary<string, ILewisAndShortEntry>.Create;
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

function TLewisAndShort.findEntry(const aKey: string): ILewisAndShortEntry;
begin
  case FIndex.tryGetValue(aKey, result) of FALSE: result := NIL; end;
end;

function TLewisAndShort.parseSenses2(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
var vAuthorName : string;
var vBiblText   : string;
var vNText      : string;
var vQuoteText  : string;
var vDefinition : string;
var vSense      : TTEISense;

  function getImmediateText(const aTarget: IXMLDOMNode): string;
  begin
    result := '';
    var vChildren := aTarget.childNodes;
    case assigned(vChildren) of TRUE:
      for var i := 0 to vChildren.length - 1 do begin
        var vChild := vChildren.item[i];
        case (vChild.nodeType = 3) of TRUE: result := result + vChild.text; end;end;end;end;

  function addCitation: TVoid;
  begin
    var vCitation    := TCitation.create;
    vCitation.author := vAuthorName;
    vCitation.bibl   := vBiblText;
    vCitation.N      := vNText;
    vCitation.quote  := vQuoteText;
    vSense.addCitation(vCitation);end;

begin
  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');

  case assigned(vSenseNodes) of TRUE:
    for var i := 0 to vSenseNodes.length - 1 do begin
      var vSenseNode : IXMLDOMNode := vSenseNodes.item[i];
          vSense                   := TTEISense.create;
      var iSense     : ITEISense   := vSense;
      aList.add(iSense);

      var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
      case assigned(vAttrs) of TRUE: begin
        var vLevelAttr := vAttrs.getNamedItem('level');
        case assigned(vLevelAttr) of TRUE: vSense.setLevel(vLevelAttr.text); end;
        var vNAttr     := vAttrs.getNamedItem('n');
        case assigned(vNAttr)     of TRUE: vSense.n := vNAttr.text; end;
        var vIdAttr    := vAttrs.getNamedItem('id');
        case assigned(vIdAttr)    of TRUE: vSense.id := vIdAttr.text; end;end;end;

      vDefinition := getImmediateText(vSenseNode);

      var vCitations := vSenseNode.selectNodes('.//cit | .//bibl');
      case assigned(vCitations) of TRUE: begin
        for var j := 0 to vCitations.length - 1 do begin
          var vCurrentNode     := vCitations.item[j];
          var vCurrentNodeName := vCurrentNode.nodeName;

          case (vCurrentNodeName = 'bibl') and assigned(vCurrentNode.parentNode) and (vCurrentNode.parentNode.nodeName = 'cit') of TRUE: CONTINUE; end;

          var vQuote : IXMLDOMNode := NIL;
          var vBibl  : IXMLDOMNode := NIL;
          vQuoteText := '';

          case (vCurrentNodeName = 'cit') of
             TRUE:  begin
                      vQuote := vCurrentNode.selectSingleNode('quote');
                      vBibl  := vCurrentNode.selectSingleNode('bibl');
                      case assigned(vQuote) of TRUE: vQuoteText := vQuote.text; end;end;
            FALSE:  vBibl := vCurrentNode;end;

          vAuthorName := '';
          vBiblText   := '';
          vNText      := '';

          case assigned(vBibl) of TRUE: begin
            var vAuthor := vBibl.selectSingleNode('author');
            var vNA     := vBibl.attributes.getNamedItem('n');
            case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;

            vBiblText := getImmediateText(vBibl);
            case assigned(vNA) of TRUE: vNText := vNA.text; end;end;end;

          addCitation; end;end;end;

      vSense.definition := vDefinition;end;end;
end;

function TLewisAndShort.loadLewisAndShort2(const aFileName: string): TVoid;
  function getDefinition(const aTarget: IXMLDOMNode): string;
  begin
    result := '';
    var vChildren       := aTarget.childNodes;
    var vFirstOrthFound := FALSE;
    case assigned(vChildren) of TRUE:
      for var i := 0 to vChildren.length - 1 do begin
        var vChild := vChildren.item[i];
        var vName  := vChild.nodeName;
        case (vName = 'sense') of TRUE: BREAK; end;
        case (vName = 'orth') and (not vFirstOrthFound) of
          TRUE:  vFirstOrthFound := TRUE;
          FALSE: result := result + vChild.text; end;end;end;end;
begin
  var vXML: IXMLDOMDocument2 := createComObject(CLASS_DOMDocument60) as IXMLDOMDocument2;

  vXML.async              := FALSE;
  vXML.resolveExternals   := FALSE;
  vXML.validateOnParse    := FALSE;
  vXML.setProperty('SelectionLanguage', 'XPath');
  vXML.preserveWhiteSpace := TRUE;

  case vXML.load(aFileName) of TRUE: begin
    var vEntries := vXML.selectNodes('/body/div0/entryFree');

    case assigned(vEntries) of TRUE:
      for var i := 0 to vEntries.length - 1 do begin
        var vNode  : IXMLDOMNode         := vEntries.item[i];
        var vEntry : TTEIEntry           := TTEIEntry.create;
        var iEntry : ILewisAndShortEntry := vEntry;

        FEntries.add(iEntry);
        vEntry.definition := getDefinition(vNode);

        var vAttrs := vNode.attributes;
        case assigned(vAttrs) of TRUE: begin
          var vIdAttr   := vAttrs.getNamedItem('id');
          case assigned(vIdAttr)   of TRUE: vEntry.id := vIdAttr.text; end;
          var vKeyAttr  := vAttrs.getNamedItem('key');
          case assigned(vKeyAttr)  of TRUE: vEntry.key := vKeyAttr.text; end;
          var vTypeAttr := vAttrs.getNamedItem('type');
          case assigned(vTypeAttr) of TRUE: vEntry.entryType := vTypeAttr.text; end;end;end;

        var vOrthNodes := vNode.selectNodes('orth');
        case (vOrthNodes.length > 0) of TRUE: begin
          var vFirstOrth     := vOrthNodes.item[0];
          vEntry.orthography := vFirstOrth.text;
          var vOAttrs        := vFirstOrth.attributes;
          case assigned(vOAttrs) of TRUE: begin
            var vLangAttr := vOAttrs.getNamedItem('lang');
            case assigned(vLangAttr) of TRUE: vEntry.language := vLangAttr.text; end;end;end;
          case (vOrthNodes.length > 1) of TRUE: vEntry.orthography2 := vOrthNodes.item[1].text; end;end;end;

        var vGen   := vNode.selectSingleNode('gen');
        case assigned(vGen)   of TRUE: vEntry.gender := vGen.text; end;
        var vIType := vNode.selectSingleNode('itype');
        case assigned(vIType) of TRUE: vEntry.inflection := vIType.text; end;
        var vEtym  := vNode.selectSingleNode('etym');
        case assigned(vEtym)  of TRUE: vEntry.etymology := vEtym.text; end;
        var vPos   := vNode.selectSingleNode('pos');
        case assigned(vPos)   of TRUE: vEntry.partOfSpeech := vPos.text; end;
        var vMood  := vNode.selectSingleNode('mood');
        case assigned(vMood)  of TRUE: vEntry.mood := vMood.text; end;
        var vCase  := vNode.selectSingleNode('case');
        case assigned(vCase)  of TRUE: vEntry.caseCase := vCase.text; end;

        parseSenses2(vNode, vEntry.senses);

        case (vEntry.key <> '') of TRUE:
          case FIndex.containsKey(vEntry.key) of FALSE: FIndex.add(vEntry.key, vEntry); end;end;

        vAttrs := NIL;end;end;end;end;
end;

// excellent!
//function TLewisAndShort.parseSenses2(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
//var vAuthorName : string;
//var vBiblText   : string;
//var vNText      : string;
//var vQuoteText  : string;
//var vDefinition : string;
//var vSense      : TTEISense;
//
//  function getDefinition(const aTarget: IXMLDOMNode): string;
//  begin
//    result := '';
//    var vChildren := aTarget.childNodes;
//    case assigned(vChildren) of TRUE:
//      for var i := 0 to vChildren.length - 1 do begin
//        var vChild := vChildren.item[i];
//        var vName  := vChild.nodeName;
//        case (vName = 'sense') or (vName = 'cit') or (vName = 'bibl') of TRUE: BREAK; end;
//        result := result + vChild.text; end;end;end;
//
//  function addCitation: TVoid;
//  begin
//    var vCitation    := TCitation.create;
//    vCitation.author := vAuthorName;
//    vCitation.bibl   := vBiblText;
//    vCitation.N      := vNText;
//    vCitation.quote  := vQuoteText;
//    vSense.addCitation(vCitation);end;
//
//  function limitText: TVoid;
//  begin
//    case (vQuoteText = '') of TRUE: EXIT; end;
//    var vMarkerHead := copy(vQuoteText, 1, 10);
//    var vPos        := pos(vMarkerHead, vDefinition);
//    case (vPos > 0) of TRUE: delete(vDefinition, vPos, MaxInt); end;end;
//
//begin
//  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');
//
//  case assigned(vSenseNodes) of TRUE:
//    for var i := 0 to vSenseNodes.length - 1 do begin
//      var vSenseNode : IXMLDOMNode := vSenseNodes.item[i];
//          vSense                   := TTEISense.create;
//      var iSense     : ITEISense   := vSense;
//      aList.add(iSense);
//
//      var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
//      case assigned(vAttrs) of TRUE: begin
//        var vLevelAttr := vAttrs.getNamedItem('level');
//        case assigned(vLevelAttr) of TRUE: vSense.setLevel(vLevelAttr.text); end;
//        var vNAttr     := vAttrs.getNamedItem('n');
//        case assigned(vNAttr)     of TRUE: vSense.n := vNAttr.text; end;
//        var vIdAttr    := vAttrs.getNamedItem('id');
//        case assigned(vIdAttr)    of TRUE: vSense.id := vIdAttr.text; end;end;end;
//
//      vDefinition := getDefinition(vSenseNode);
//
//      var vCitations := vSenseNode.selectNodes('.//cit | .//bibl');
//      case assigned(vCitations) of TRUE: begin
//        for var j := 0 to vCitations.length - 1 do begin
//          var vCurrentNode     := vCitations.item[j];
//          var vCurrentNodeName := vCurrentNode.nodeName;
//
//          case (vCurrentNodeName = 'bibl') and assigned(vCurrentNode.parentNode) and (vCurrentNode.parentNode.nodeName = 'cit') of TRUE: CONTINUE; end;
//
//          var vQuote : IXMLDOMNode := NIL;
//          var vBibl  : IXMLDOMNode := NIL;
//          vQuoteText := '';
//
//          case (vCurrentNodeName = 'cit') of
//             TRUE:  begin
//                      vQuote := vCurrentNode.selectSingleNode('quote');
//                      vBibl  := vCurrentNode.selectSingleNode('bibl');
//                      case assigned(vQuote) of TRUE: vQuoteText := vQuote.text; end;end;
//            FALSE:  vBibl := vCurrentNode;end;
//
//          //case (j = 0) of TRUE: limitText; end;
//
//          vAuthorName := '';
//          vBiblText   := '';
//          vNText      := '';
//
//          case assigned(vBibl) of TRUE: begin
//            var vAuthor := vBibl.selectSingleNode('author');
//            var vNA     := vBibl.attributes.getNamedItem('n');
//            case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;
//
//            vBiblText := vBibl.text;
//            var vP    := pos(vAuthorName, vBiblText);
//            case (vP = 1)       of TRUE: vBiblText := copy(vBiblText, length(vAuthorName) + 1, MaxInt); end;
//            case assigned(vNA) of TRUE: vNText := vNA.text; end;end;end;
//
//          addCitation; end;end;end;
//
//      vSense.definition := vDefinition;end;end;
//end;
//
//function TLewisAndShort.loadLewisAndShort2(const aFileName: string): TVoid;
//  function getDefinition(const aTarget: IXMLDOMNode): string;
//  begin
//    result := '';
//    var vChildren       := aTarget.childNodes;
//    var vFirstOrthFound := FALSE;
//    case assigned(vChildren) of TRUE:
//      for var i := 0 to vChildren.length - 1 do begin
//        var vChild := vChildren.item[i];
//        var vName  := vChild.nodeName;
//        case (vName = 'sense') of TRUE: BREAK; end;
//        case (vName = 'orth') and (not vFirstOrthFound) of
//          TRUE:  vFirstOrthFound := TRUE;
//          FALSE: result := result + vChild.text; end;end;end;end;
//begin
//  var vXML: IXMLDOMDocument2 := createComObject(CLASS_DOMDocument60) as IXMLDOMDocument2;
//
//  vXML.async              := FALSE;
//  vXML.resolveExternals   := FALSE;
//  vXML.validateOnParse    := FALSE;
//  vXML.setProperty('SelectionLanguage', 'XPath');
//  vXML.preserveWhiteSpace := TRUE;
//
//  case vXml.load(aFileName) of TRUE: begin
//    var vEntries := vXML.selectNodes('/body/div0/entryFree');
//
//    case assigned(vEntries) of TRUE:
//      for var i := 0 to vEntries.length - 1 do begin
//        var vNode  : IXMLDOMNode         := vEntries.item[i];
//        var vEntry : TTEIEntry           := TTEIEntry.create;
//        var iEntry : ILewisAndShortEntry := vEntry;
//
//        FEntries.add(iEntry);
//        vEntry.definition := getDefinition(vNode);
//
//        var vAttrs := vNode.attributes;
//        case assigned(vAttrs) of TRUE: begin
//          var vIdAttr   := vAttrs.getNamedItem('id');
//          case assigned(vIdAttr)   of TRUE: vEntry.id := vIdAttr.text; end;
//          var vKeyAttr  := vAttrs.getNamedItem('key');
//          case assigned(vKeyAttr)  of TRUE: vEntry.key := vKeyAttr.text; end;
//          var vTypeAttr := vAttrs.getNamedItem('type');
//          case assigned(vTypeAttr) of TRUE: vEntry.entryType := vTypeAttr.text; end;end;end;
//
//        var vOrthNodes := vNode.selectNodes('orth');
//        case (vOrthNodes.length > 0) of TRUE: begin
//          var vFirstOrth     := vOrthNodes.item[0];
//          vEntry.orthography := vFirstOrth.text;
//          var vOAttrs        := vFirstOrth.attributes;
//          case assigned(vOAttrs) of TRUE: begin
//            var vLangAttr := vOAttrs.getNamedItem('lang');
//            case assigned(vLangAttr) of TRUE: vEntry.language := vLangAttr.text; end;end;end;
//          case (vOrthNodes.length > 1) of TRUE: vEntry.orthography2 := vOrthNodes.item[1].text; end;end;end;
//
//        var vGen   := vNode.selectSingleNode('gen');
//        case assigned(vGen)   of TRUE: vEntry.gender := vGen.text; end;
//        var vIType := vNode.selectSingleNode('itype');
//        case assigned(vIType) of TRUE: vEntry.inflection := vIType.text; end;
//        var vEtym  := vNode.selectSingleNode('etym');
//        case assigned(vEtym)  of TRUE: vEntry.etymology := vEtym.text; end;
//        var vPos   := vNode.selectSingleNode('pos');
//        case assigned(vPos)   of TRUE: vEntry.partOfSpeech := vPos.text; end;
//        var vMood  := vNode.selectSingleNode('mood');
//        case assigned(vMood)  of TRUE: vEntry.mood := vMood.text; end;
//        var vCase  := vNode.selectSingleNode('case');
//        case assigned(vCase)  of TRUE: vEntry.caseCase := vCase.text; end;
//
//        parseSenses2(vNode, vEntry.senses);
//
//        case (vEntry.key <> '') of TRUE:
//          case FIndex.containsKey(vEntry.key) of FALSE: FIndex.add(vEntry.key, vEntry); end;end;
//
//        vAttrs := NIL;end;end;end;
//end;end;


//function TLewisAndShort.parseSenses2(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
//var vAuthorName : string;
//var vBiblText   : string;
//var vNText      : string;
//var vQuoteText  : string;
//var vDefinition : string;
//var vSense      : TTEISense;
//
//  function getImmediateText(const aTarget: IXMLDOMNode): string;
//  begin
//    result := '';
//    var vChildren := aTarget.childNodes;
//    case assigned(vChildren) of TRUE:
//      for var i := 0 to vChildren.length - 1 do begin
//        var vChild := vChildren.item[i];
//        case (vChild.nodeType = 3) of TRUE: result := result + vChild.text; end;end;end;end;
//
//  function addCitation: TVoid;
//  begin
//    var vCitation    := TCitation.create;
//    vCitation.author := vAuthorName;
//    vCitation.bibl   := vBiblText;
//    vCitation.N      := vNText;
//    vCitation.quote  := vQuoteText;
//    vSense.addCitation(vCitation);end;
//
//  function limitText: TVoid;
//  begin
//    case (vQuoteText = '') of TRUE: EXIT; end;
//    var vMarkerHead := copy(vQuoteText, 1, 10);
//    var vPos        := pos(vMarkerHead, vDefinition);
//    case (vPos > 0) of TRUE: delete(vDefinition, vPos, MaxInt); end;end;
//
//begin
//  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');
//
//  case assigned(vSenseNodes) of TRUE:
//    for var i := 0 to vSenseNodes.length - 1 do begin
//      var vSenseNode : IXMLDOMNode := vSenseNodes.item[i];
//          vSense                   := TTEISense.create;
//      var iSense     : ITEISense   := vSense;
//      aList.add(iSense);
//
//      var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
//      case assigned(vAttrs) of TRUE: begin
//        var vLevelAttr := vAttrs.getNamedItem('level');
//        case assigned(vLevelAttr) of TRUE: vSense.setLevel(vLevelAttr.text); end;
//        var vNAttr     := vAttrs.getNamedItem('n');
//        case assigned(vNAttr)     of TRUE: vSense.n := vNAttr.text; end;
//        var vIdAttr    := vAttrs.getNamedItem('id');
//        case assigned(vIdAttr)    of TRUE: vSense.id := vIdAttr.text; end;end;end;
//
//      vDefinition := getImmediateText(vSenseNode);
//
//      var vCitations := vSenseNode.selectNodes('.//cit | .//bibl');
//      case assigned(vCitations) of TRUE: begin
//        for var j := 0 to vCitations.length - 1 do begin
//          var vCurrentNode     := vCitations.item[j];
//          var vCurrentNodeName := vCurrentNode.nodeName;
//
//          case (vCurrentNodeName = 'bibl') and assigned(vCurrentNode.parentNode) and (vCurrentNode.parentNode.nodeName = 'cit') of TRUE: CONTINUE; end;
//
//          var vQuote : IXMLDOMNode := NIL;
//          var vBibl  : IXMLDOMNode := NIL;
//          vQuoteText := '';
//
//          case (vCurrentNodeName = 'cit') of
//             TRUE:  begin
//                      vQuote := vCurrentNode.selectSingleNode('quote');
//                      vBibl  := vCurrentNode.selectSingleNode('bibl');
//                      case assigned(vQuote) of TRUE: vQuoteText := vQuote.text; end;end;
//            FALSE:  vBibl := vCurrentNode;end;
//
//          case (j = 0) of TRUE: limitText; end;
//
//          vAuthorName := '';
//          vBiblText   := '';
//          vNText      := '';
//
//          case assigned(vBibl) of TRUE: begin
//            var vAuthor := vBibl.selectSingleNode('author');
//            var vNA     := vBibl.attributes.getNamedItem('n');
//            case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;
//
//            vBiblText := vBibl.text;
//            var vP    := pos(vAuthorName, vBiblText);
//            case (vP = 1)       of TRUE: vBiblText := copy(vBiblText, length(vAuthorName) + 1, MaxInt); end;
//            case assigned(vNA) of TRUE: vNText := vNA.text; end;end;end;
//
//          addCitation; end;end;end;
//
//      vSense.definition := vDefinition;end;end;
//end;
//
//function TLewisAndShort.loadLewisAndShort2(const aFileName: string): TVoid;
//  function getImmediateText(const aTarget: IXMLDOMNode): string;
//  begin
//    result := '';
//    var vChildren := aTarget.childNodes;
//    case assigned(vChildren) of TRUE:
//      for var i := 0 to vChildren.length - 1 do begin
//        var vChild := vChildren.item[i];
//        case (vChild.nodeType = 3) of TRUE: result := result + vChild.text; end;end;end;end;
//begin
//  var vXML: IXMLDOMDocument2 := createComObject(CLASS_DOMDocument60) as IXMLDOMDocument2;
//
//  vXML.async              := FALSE;
//  vXML.resolveExternals   := FALSE;
//  vXML.validateOnParse    := FALSE;
//  vXML.setProperty('SelectionLanguage', 'XPath');
//  vXML.preserveWhiteSpace := TRUE;
//
//  case vXml.load(aFileName) of TRUE: begin
//    var vEntries := vXML.selectNodes('/body/div0/entryFree');
//
//    case assigned(vEntries) of TRUE:
//      for var i := 0 to vEntries.length - 1 do begin
//        var vNode  : IXMLDOMNode         := vEntries.item[i];
//        var vEntry : TTEIEntry           := TTEIEntry.create;
//        var iEntry : ILewisAndShortEntry := vEntry;
//
//        FEntries.add(iEntry);
//        vEntry.definition := getImmediateText(vNode);
//
//        var vAttrs := vNode.attributes;
//        case assigned(vAttrs) of TRUE: begin
//          var vIdAttr   := vAttrs.getNamedItem('id');
//          case assigned(vIdAttr)   of TRUE: vEntry.id := vIdAttr.text; end;
//          var vKeyAttr  := vAttrs.getNamedItem('key');
//          case assigned(vKeyAttr)  of TRUE: vEntry.key := vKeyAttr.text; end;
//          var vTypeAttr := vAttrs.getNamedItem('type');
//          case assigned(vTypeAttr) of TRUE: vEntry.entryType := vTypeAttr.text; end;end;end;
//
//        var vOrthNodes := vNode.selectNodes('orth');
//        case (vOrthNodes.length > 0) of TRUE: begin
//          var vFirstOrth     := vOrthNodes.item[0];
//          vEntry.orthography := vFirstOrth.text;
//          var vOAttrs        := vFirstOrth.attributes;
//          case assigned(vOAttrs) of TRUE: begin
//            var vLangAttr := vOAttrs.getNamedItem('lang');
//            case assigned(vLangAttr) of TRUE: vEntry.language := vLangAttr.text; end;end;end;
//          case (vOrthNodes.length > 1) of TRUE: vEntry.orthography2 := vOrthNodes.item[1].text; end;end;end;
//
//        var vGen   := vNode.selectSingleNode('gen');
//        case assigned(vGen)   of TRUE: vEntry.gender := vGen.text; end;
//        var vIType := vNode.selectSingleNode('itype');
//        case assigned(vIType) of TRUE: vEntry.inflection := vIType.text; end;
//        var vEtym  := vNode.selectSingleNode('etym');
//        case assigned(vEtym)  of TRUE: vEntry.etymology := vEtym.text; end;
//        var vPos   := vNode.selectSingleNode('pos');
//        case assigned(vPos)   of TRUE: vEntry.partOfSpeech := vPos.text; end;
//        var vMood  := vNode.selectSingleNode('mood');
//        case assigned(vMood)  of TRUE: vEntry.mood := vMood.text; end;
//        var vCase  := vNode.selectSingleNode('case');
//        case assigned(vCase)  of TRUE: vEntry.caseCase := vCase.text; end;
//
//        parseSenses2(vNode, vEntry.senses);
//
//        case (vEntry.key <> '') of TRUE:
//          case FIndex.containsKey(vEntry.key) of FALSE: FIndex.add(vEntry.key, vEntry); end;end;
//
//        vAttrs := NIL;end;end;end;
//end;end;

function TLewisAndShort.parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
var vAuthorName : string;
var vBiblText   : string;
var vNText      : string;
var vQuoteText  : string;
var vDefinition : string;
var vSense      : TTEISense;

  function addCitation: TVoid;
  begin
    var vCitation := TCitation.Create;
    vCitation.author := vAuthorName;
    vCitation.bibl   := vBiblText;
    vCitation.N      := vNText;
    vCitation.quote  := vQuoteText;
    vSense.addCitation(vCitation);
  end;

  function limitText: TVoid;
  begin
    case vQuoteText = '' of TRUE: EXIT; end;
    var vMarkerHead := copy(vQuoteText, 1, 10);
    var vPos        := pos(vMarkerHead, vDefinition);
    case vPos > 0 of TRUE: delete(vDefinition, vPos, MaxInt); end;
  end;

begin
  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');

  case assigned(vSenseNodes) of TRUE:
    for var i := 0 to vSenseNodes.length - 1 do begin
      var vSenseNode: IXMLDOMNode := vSenseNodes.item[i];
          vSense                  := TTEISense.create;
      var iSense: ITEISense       := vSense;
      aList.add(iSense);

      var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
      case assigned(vAttrs) of   TRUE:  begin
        var vLevelAttr: IXMLDOMNode := vAttrs.getNamedItem('level');
        case assigned(vLevelAttr) of TRUE: vSense.setLevel(vLevelAttr.text); end;

        var vNAttr: IXMLDOMNode := vAttrs.getNamedItem('n');
        case assigned(vNAttr) of TRUE: vSense.n := vNAttr.text; end;

        var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
        case assigned(vIdAttr) of TRUE: vSense.id := vIdAttr.text; end;end;end;

      vDefinition       := vSenseNode.text;

      var vCitations: IXMLDOMNodeList := vSenseNode.selectNodes('.//cit | .//bibl');
      case assigned(vCitations) of TRUE: begin
        for var j := 0 to vCitations.length - 1 do begin
          var vCurrentNode: IXMLDOMNode := vCitations.item[j];
          var vCurrentNodeName          := vCurrentNode.nodeName;

          // bibl nodes can be children of cit or sense
          // don't process a bibl node twice because of the OR-ed selectNodes above
          case (vCurrentNodeName = 'bibl') and assigned(vCurrentNode.parentNode) and (vCurrentNode.parentNode.nodeName = 'cit') of TRUE: CONTINUE; end;

          var vQuote:     IXMLDOMNode := NIL;
          var vBibl:      IXMLDOMNode := NIL;
          vQuoteText  := '';

          case vCurrentNodeName = 'cit' of
             TRUE:  begin
                      vQuote := vCurrentNode.selectSingleNode('quote');
                      vBibl  := vCurrentNode.selectSingleNode('bibl');
                      case assigned(vQuote) of TRUE: vQuoteText := vQuote.text; end;end;
            FALSE:  vBibl := vCurrentNode;
          end;

          case (j = 0) of TRUE: limitText; end;

          vAuthorName := '';
          vBiblText   := '';
          vNText      := '';

          case assigned(vBibl) of TRUE: begin
            var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
            var vNAttr:  IXMLDOMNode := vBibl.attributes.getNamedItem('n');
            case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;

            vBiblText := vBibl.text;
            var vPos := pos(vAuthorName, vBiblText);
            case vPos = 1 of TRUE: vBiblText := copy(vBiblText, length(vAuthorName) + 1, MaxInt); end;

            case assigned(vNAttr)  of TRUE: vNText := vNAttr.text; end;end;end;

          addCitation; end;end;end;

      vSense.definition := vDefinition;
  end;end;
end;

function TLewisAndShort.loadLewisAndShort(const aFileName: string): TVoid;
begin
  loadLewisAndShort2(aFileName);
  EXIT;

  var vXML: IXMLDOMDocument2 := CreateComObject(CLASS_DOMDocument60) as IXMLDOMDocument2;

  vXML.async              := FALSE;
  vXML.resolveExternals   := FALSE;
  vXML.validateOnParse    := FALSE;
//  vXML.setProperty('ProhibitDTD', FALSE);
  vXML.setProperty('SelectionLanguage', 'XPath');
  vXML.preserveWhiteSpace := TRUE;

  case vXml.load(aFileName) of   TRUE:  begin
      var vEntries: IXMLDOMNodeList := vXML.selectNodes('/body/div0/entryFree');

      case assigned(vEntries) of   TRUE:  for var i := 0 to vEntries.length - 1 do  begin
                                            var vNode: IXMLDOMNode          := vEntries.item[i];
                                            var vEntry: TTEIEntry           := TTEIEntry.create;
                                            var iEntry: ILewisAndShortEntry := vEntry;

                                            FEntries.add(iEntry);

                                            vEntry.definition := vNode.text;

                                            var vAttrs: IXMLDOMNamedNodeMap := vNode.attributes;

                                            case assigned(vAttrs) of   TRUE:  begin
                                                var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
                                                case assigned(vIdAttr) of TRUE: vEntry.id := vIdAttr.text; end;

                                                var vKeyAttr: IXMLDOMNode := vAttrs.getNamedItem('key');
                                                case assigned(vKeyAttr) of TRUE: vEntry.key := vKeyAttr.text; end;

                                                var vTypeAttr: IXMLDOMNode := vAttrs.getNamedItem('type');
                                                case assigned(vTypeAttr) of TRUE: vEntry.entryType := vTypeAttr.text; end;
                                            end;end;

                                            var vOrthNodes: IXMLDOMNodeList := vNode.selectNodes('orth');
                                            case (vOrthNodes.length > 0) of  TRUE:  begin
                                                                                      var vFirstOrth: IXMLDOMNode := vOrthNodes.item[0];
                                                                                      vEntry.orthography := vFirstOrth.text;

                                                                                      var vOAttrs: IXMLDOMNamedNodeMap := vFirstOrth.attributes;
                                                                                      case assigned(vOAttrs) of  TRUE:  begin
                                                                                                                          var vLangAttr: IXMLDOMNode := vOAttrs.getNamedItem('lang');
                                                                                                                          case assigned(vLangAttr) of TRUE: vEntry.language := vLangAttr.text; end;end;end;
                                                                                      case (vOrthNodes.length > 1) of TRUE: vEntry.orthography2 := vOrthNodes.item[1].text; end;end;end;

                                            var vGen: IXMLDOMNode := vNode.selectSingleNode('gen');
                                            case assigned(vGen) of TRUE: vEntry.gender := vGen.text; end;

                                            var vIType: IXMLDOMNode := vNode.selectSingleNode('itype');
                                            case assigned(vIType) of True: vEntry.inflection := vIType.text; end;

                                            var vEtym: IXMLDOMNode := vNode.selectSingleNode('etym');
                                            case assigned(vEtym) of True: vEntry.etymology := vEtym.text; end;

                                            var vPos: IXMLDOMNode := vNode.selectSingleNode('pos');
                                            case assigned(vPos) of TRUE: vEntry.partOfSpeech := vPos.text; end;

                                            var vMood: IXMLDOMNode := vNode.selectSingleNode('mood');
                                            case assigned(vMood) of TRUE: vEntry.mood := vMood.text; end;

                                            var vCase: IXMLDOMNode := vNode.selectSingleNode('case');
                                            case assigned(vCase) of TRUE: vEntry.caseCase := vCase.text; end;

                                            vEntry.definition := vNode.text;
                                            parseSenses(vNode, vEntry.senses);

                                            case (vEntry.key <> '') of TRUE: case FIndex.containsKey(vEntry.key) of FALSE: FIndex.add(vEntry.key, vEntry); end;end;

                                            vAttrs := NIL;
                                          end;
      end;end;end;
end;

{ Export / Import }

function TLewisAndShort.exportWRecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): tVoid;
  function copyToBuffer(const aSource: string; var aDest: array of char): tVoid;
  begin
    var vLimit := length(aDest);
    var vCount := length(aSource);
    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
begin
  var vByteLength := sizeOf(TWRecord);
  var vLineLength := vByteLength div sizeOf(char);
  var vPadding    := stringOfChar(' ', vLineLength);
  var vRecord     : TWRecord;

  move(pointer(vPadding)^, vRecord, vByteLength);

  vRecord.wrRecType := 'W';
  vRecord.wrFiller  := ' ';

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
  function copyToBuffer(const aSource: string; var aDest: array of char): tVoid;
  begin
    var vLimit := length(aDest);
    var vCount := length(aSource);
    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
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
  function copyToBuffer(const aSource: string; var aDest: array of char): tVoid;
  begin
    var vLimit := length(aDest);
    var vCount := length(aSource);
    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
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
  function copyToBuffer(const aSource: string; var aDest: array of char): TVoid;
  begin
    var vLimit := length(aDest);
    var vCount := length(aSource);
    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end;end;
begin
  var vByteLength := sizeOf(TSRecord);
  var vLineLength := vByteLength div sizeOf(char);
  var vPadding    := stringOfChar(' ', vLineLength);
  var vRecord     : TSRecord;

  // Initialize the record buffer with spaces
  move(pointer(vPadding)^, vRecord, vByteLength);

  vRecord.srRecType := 'S';
  vRecord.srFiller  := ' ';

  // Set the level character at the new index 3
  case (aSense.n <> '') of TRUE: vRecord.srLevel := aSense.n[1]; end;

  copyToBuffer(aSense.id, vRecord.srID);
  copyToBuffer(aSense.n,  vRecord.srN);

  var vOutLine: string;
  setLength(vOutLine, vLineLength);
  move(vRecord, pointer(vOutLine)^, vByteLength);
  aWriter.writeLine(vOutLine);
end;

function TLewisAndShort.exportCRecord(const aWriter: TStreamWriter; const aCitation: ICitation): TVoid;
begin
  var vRecord: TCRecord;
  vRecord.crRecType := 'C';
  vRecord.crFiller  := ' ';

  var vOutLine: string;
  setLength(vOutLine, 2);
  move(vRecord, pointer(vOutLine)^, 2 * sizeOf(char));
  aWriter.writeLine(vOutLine);

  case (aCitation.n <> '')               of TRUE: aWriter.writeLine('N ' + aCitation.n); end;
  case (aCitation.author <> '')          of TRUE: aWriter.writeLine('A ' + aCitation.author); end;
  case (TCitation(aCitation).bibl <> '') of TRUE: aWriter.writeLine('B ' + TCitation(aCitation).bibl); end;
  case (aCitation.quote <> '')           of TRUE: aWriter.writeLine('Q ' + aCitation.quote); end;
end;

function TLewisAndShort.export(const aFileName: string): TVoid;
begin
  var vStream := TFileStream.create(aFileName, fmCreate);
  var vWriter := TStreamWriter.create(vStream, TEncoding.UTF8);

  for var i := 0 to FEntries.count - 1 do begin
    var vEntry := FEntries[i];

    exportWRecord(vWriter, vEntry);
    exportMRecord(vWriter, vEntry);
    exportORecord(vWriter, vEntry);

    case (vEntry.etymology <> '') of TRUE: vWriter.writeLine('E ' + vEntry.etymology); end;

    case (vEntry.definition <> '') of TRUE: vWriter.writeLine('D ' + vEntry.definition); end;

    for var j := 0 to vEntry.senseCount - 1 do begin
      var vSense := vEntry.sense[j];
      exportSRecord(vWriter, vSense);
      case (vSense.definition <> '') of TRUE: vWriter.writeLine('X ' + vSense.definition); end;

      for var k := 0 to vSense.citationCount - 1 do exportCRecord(vWriter, vSense.citations[k]); end;end;

  vWriter.free;
  vStream.free;
end;

function TLewisAndShort.importWRecord(const aLine: string): TTEIEntry;
  function bufferToString(const aBuffer: array of char): string;
  begin
    setLength(result, length(aBuffer));
    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
    result := trim(result); end;
begin
  var vRecord: TWRecord;
  move(pointer(aLine)^, vRecord, sizeOf(TWRecord));

  result := TTEIEntry.Create;
  var iEntry: ILewisAndShortEntry := result;

  result.key       := bufferToString(vRecord.wrKey);
  result.id        := bufferToString(vRecord.wrID);
  result.entryType := bufferToString(vRecord.wrEntryType);
  result.language  := bufferToString(vRecord.wrLanguage);

  fEntries.add(iEntry);

  case (result.key <> '') of TRUE:
    case fIndex.containsKey(result.key) of FALSE: fIndex.add(result.key, iEntry); end; end; end;

function TLewisAndShort.importMRecord(const aLine: string; const aEntry: TTEIEntry): tVoid;
  function bufferToString(const aBuffer: array of char): string;
  begin
    setLength(result, length(aBuffer));
    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
    result := trim(result); end;
begin
  var vRecord: TMRecord;
  move(pointer(aLine)^, vRecord, sizeOf(TMRecord));

  aEntry.gender       := bufferToString(vRecord.mrGender);
  aEntry.inflection   := bufferToString(vRecord.mrInflection);
  aEntry.partOfSpeech := bufferToString(vRecord.mrPartOfSpeech);
  aEntry.mood         := bufferToString(vRecord.mrMood);
  aEntry.caseCase     := bufferToString(vRecord.mrCase); end;

function TLewisAndShort.importORecord(const aLine: string; const aEntry: TTEIEntry): tVoid;
  function bufferToString(const aBuffer: array of char): string;
  begin
    setLength(result, length(aBuffer));
    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
    result := trim(result); end;
begin
  var vRecord: TORecord;
  move(pointer(aLine)^, vRecord, sizeOf(TORecord));

  aEntry.orthography  := bufferToString(vRecord.orOrthography);
  aEntry.orthography2 := bufferToString(vRecord.orOrthography2); end;

function TLewisAndShort.importSRecord(const aLine: string; const aEntry: TTEIEntry): TTEISense;
  function bufferToString(const aBuffer: array of char): string;
  begin
    setLength(result, length(aBuffer));
    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
    result := trim(result); end;
begin
  var vRecord: TSRecord;
  // Map the line directly into the new record structure
  move(pointer(aLine)^, vRecord, sizeOf(TSRecord));

  result := TTEISense.create;
  result.id := bufferToString(vRecord.srID);
  result.n  := bufferToString(vRecord.srN);

  // Extract level from the 3rd position in the string
  result.setLevel(vRecord.srLevel);

  aEntry.senses.add(result);
end;

function TLewisAndShort.importCRecord(const aLine: string; const aSense: ITEISense): TCitation;
begin
  result := TCitation.create;
  TTEISense(aSense).addCitation(result);
end;

function TLewisAndShort.import(const aFileName: string): TVoid;
begin
  case not fileExists(aFileName) of TRUE: EXIT; end;

  var vStream            := TFileStream.create(aFileName, fmOpenRead or fmShareDenyWrite);
  var vReader            := TStreamReader.create(vStream, TEncoding.UTF8);
  var vCurrentEntry      : TTEIEntry := NIL;
  var vCurrentSense      : ITEISense := NIL;
  var vCurrentCitation   : TCitation := NIL;

  while not vReader.endOfStream do begin
    var vLine := vReader.readLine;
    case vLine[1] of
      'W': begin
             vCurrentEntry    := importWRecord(vLine);
             vCurrentSense    := NIL;
             vCurrentCitation := NIL; end;
      'M': importMRecord(vLine, vCurrentEntry);
      'O': importORecord(vLine, vCurrentEntry);
      'E': vCurrentEntry.etymology := copy(vLine, 3, MaxInt);
      'D': vCurrentEntry.definition := copy(vLine, 3, MaxInt);
      'S': begin
             vCurrentSense    := importSRecord(vLine, vCurrentEntry);
             vCurrentCitation := NIL; end;
      'X': TTEISense(vCurrentSense).definition := copy(vLine, 3, MaxInt);
      'C': vCurrentCitation := importCRecord(vLine, vCurrentSense);
      'N': vCurrentCitation.n := copy(vLine, 3, MaxInt);
      'A': vCurrentCitation.author := copy(vLine, 3, MaxInt);
      'B': vCurrentCitation.bibl := copy(vLine, 3, MaxInt);
      'Q': vCurrentCitation.quote := copy(vLine, 3, MaxInt); end;end;

  vReader.free;
  vStream.free;
end;


//function TLewisAndShort.exportWRecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): TVoid;
//  procedure copyToBuffer(const aSource: string; var aDest: array of char);
//  begin
//    var vLimit := length(aDest);
//    var vCount := length(aSource);
//    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
//    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
//begin
//  var vByteLength := sizeOf(TWRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  var vPadding    := stringOfChar(' ', vLineLength);
//  var vRecord: TWRecord;
//
//  move(pointer(vPadding)^, vRecord, vByteLength);
//
//  vRecord.wrRecType := 'W';
//  vRecord.wrFiller  := ' ';
//
//  copyToBuffer(aEntry.key,       vRecord.wrKey);
//  copyToBuffer(aEntry.id,        vRecord.wrID);
//  copyToBuffer(aEntry.entryType, vRecord.wrEntryType);
//  copyToBuffer(aEntry.language,  vRecord.wrLanguage);
//
//  var vOutLine: string;
//  setLength(vOutLine, vLineLength);
//  move(vRecord, pointer(vOutLine)^, vByteLength);
//  aWriter.writeLine(vOutLine);
//end;
//
//function TLewisAndShort.exportMRecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): TVoid;
//  procedure copyToBuffer(const aSource: string; var aDest: array of char);
//  begin
//    var vLimit := length(aDest);
//    var vCount := length(aSource);
//    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
//    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
//begin
//  var vByteLength := sizeOf(TMRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  var vPadding    := stringOfChar(' ', vLineLength);
//  var vRecord: TMRecord;
//
//  move(pointer(vPadding)^, vRecord, vByteLength);
//
//  vRecord.mrRecType := 'M';
//  vRecord.mrFiller  := ' ';
//
//  copyToBuffer(aEntry.gender,       vRecord.mrGender);
//  copyToBuffer(aEntry.inflection,   vRecord.mrInflection);
//  copyToBuffer(aEntry.partOfSpeech, vRecord.mrPartOfSpeech);
//  copyToBuffer(aEntry.mood,         vRecord.mrMood);
//  copyToBuffer(aEntry.caseCase,     vRecord.mrCase);
//
//  var vOutLine: string;
//  setLength(vOutLine, vLineLength);
//  move(vRecord, pointer(vOutLine)^, vByteLength);
//  aWriter.writeLine(vOutLine);
//end;
//
//function TLewisAndShort.exportORecord(const aWriter: TStreamWriter; const aEntry: ILewisAndShortEntry): TVoid;
//  procedure copyToBuffer(const aSource: string; var aDest: array of char);
//  begin
//    var vLimit := length(aDest);
//    var vCount := length(aSource);
//    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
//    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
//begin
//  var vByteLength := sizeOf(TORecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  var vPadding    := stringOfChar(' ', vLineLength);
//  var vRecord: TORecord;
//
//  move(pointer(vPadding)^, vRecord, vByteLength);
//
//  vRecord.orRecType := 'O';
//  vRecord.orFiller  := ' ';
//
//  copyToBuffer(aEntry.orthography,  vRecord.orOrthography);
//  copyToBuffer(aEntry.orthography2, vRecord.orOrthography2);
//
//  var vOutLine: string;
//  setLength(vOutLine, vLineLength);
//  move(vRecord, pointer(vOutLine)^, vByteLength);
//  aWriter.writeLine(vOutLine);
//end;
//
//function TLewisAndShort.exportSRecord(const aWriter: TStreamWriter; const aSense: ITEISense): TVoid;
//  procedure copyToBuffer(const aSource: string; var aDest: array of char);
//  begin
//    var vLimit := length(aDest);
//    var vCount := length(aSource);
//    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
//    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
//begin
//  var vByteLength := sizeOf(TSRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  var vPadding    := stringOfChar(' ', vLineLength);
//  var vRecord: TSRecord;
//
//  move(pointer(vPadding)^, vRecord, vByteLength);
//
//  vRecord.srRecType := 'S';
//  vRecord.srFiller  := ' ';
//
//  copyToBuffer(aSense.id, vRecord.srID);
//  copyToBuffer(aSense.n,  vRecord.srN);
//
//  case (TTEISense(aSense).n <> '') of TRUE: vRecord.srLevel := TTEISense(aSense).n[1]; end;
//
//  var vOutLine: string;
//  setLength(vOutLine, vLineLength);
//  move(vRecord, pointer(vOutLine)^, vByteLength);
//  aWriter.writeLine(vOutLine);
//end;
//
//function TLewisAndShort.exportCRecord(const aWriter: TStreamWriter; const aCitation: ICitation): TVoid;
//  procedure copyToBuffer(const aSource: string; var aDest: array of char);
//  begin
//    var vLimit := length(aDest);
//    var vCount := length(aSource);
//    case (vCount > vLimit) of TRUE: vCount := vLimit; end;
//    case (vCount > 0)      of TRUE: move(pointer(aSource)^, aDest[0], vCount * sizeOf(char)); end; end;
//begin
//  var vByteLength := sizeOf(TCRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  var vPadding    := stringOfChar(' ', vLineLength);
//  var vRecord: TCRecord;
//
//  move(pointer(vPadding)^, vRecord, vByteLength);
//
//  vRecord.crRecType := 'C';
//  vRecord.crFiller  := ' ';
//
//  copyToBuffer(aCitation.author,       vRecord.crAuthor);
//  copyToBuffer(TCitation(aCitation).bibl, vRecord.crBibl);
//  copyToBuffer(aCitation.n,            vRecord.crN);
//
//  var vOutLine: string;
//  setLength(vOutLine, vLineLength);
//  move(vRecord, pointer(vOutLine)^, vByteLength);
//  aWriter.writeLine(vOutLine);
//end;
//
//function TLewisAndShort.export(const aFileName: string): TVoid;
//begin
//  var vStream := TFileStream.Create(aFileName, fmCreate);
//  var vWriter := TStreamWriter.Create(vStream, TEncoding.UTF8);
//
//  for var i := 0 to fEntries.count - 1 do begin
//    var vEntry := fEntries[i];
//
//    exportWRecord(vWriter, vEntry);
//    exportMRecord(vWriter, vEntry);
//    exportORecord(vWriter, vEntry);
//
//    case (vEntry.etymology <> '')  of TRUE: vWriter.writeLine('E ' + vEntry.etymology); end;
//    case (vEntry.definition <> '') of TRUE: vWriter.writeLine('D ' + vEntry.definition); end;
//
//    for var j := 0 to vEntry.senseCount - 1 do begin
//      var vSense := vEntry.sense[j];
//      exportSRecord(vWriter, vSense);
//      case (vSense.definition <> '') of TRUE: vWriter.writeLine('X ' + vSense.definition); end;
//
//      for var k := 0 to vSense.citationCount - 1 do begin
//        var vCitation := vSense.citation[k];
//        exportCRecord(vWriter, vCitation);
//        case (vCitation.quote <> '') of TRUE: vWriter.writeLine('Q ' + vCitation.quote); end; end; end; end;
//
//  vWriter.free;
//  vStream.free;
//end;
//
//function TLewisAndShort.importWRecord(const aLine: string): TTEIEntry;
//  function bufferToString(const aBuffer: array of char): string;
//  begin
//    setLength(result, length(aBuffer));
//    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
//    result := trim(result); end;
//begin
//  var vByteLength := sizeOf(TWRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  case (length(aLine) < vLineLength) of TRUE: EXIT(NIL); end;
//
//  var vRecord: TWRecord;
//  move(pointer(aLine)^, vRecord, vByteLength);
//
//  result := TTEIEntry.Create;
//  var iEntry: ILewisAndShortEntry := result;
//
//  result.key       := bufferToString(vRecord.wrKey);
//  result.id        := bufferToString(vRecord.wrID);
//  result.entryType := bufferToString(vRecord.wrEntryType);
//  result.language  := bufferToString(vRecord.wrLanguage);
//
//  fEntries.add(iEntry);
//
//  case (result.key <> '') of TRUE:
//    case fIndex.containsKey(result.key) of FALSE: fIndex.add(result.key, iEntry); end; end; end;
//
//function TLewisAndShort.importMRecord(const aLine: string; const aEntry: TTEIEntry): TVoid;
//  function bufferToString(const aBuffer: array of char): string;
//  begin
//    setLength(result, length(aBuffer));
//    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
//    result := trim(result); end;
//begin
//  var vByteLength := sizeOf(TMRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  case (length(aLine) < vLineLength) of TRUE: EXIT; end;
//
//  var vRecord: TMRecord;
//  move(pointer(aLine)^, vRecord, vByteLength);
//
//  aEntry.gender       := bufferToString(vRecord.mrGender);
//  aEntry.inflection   := bufferToString(vRecord.mrInflection);
//  aEntry.partOfSpeech := bufferToString(vRecord.mrPartOfSpeech);
//  aEntry.mood         := bufferToString(vRecord.mrMood);
//  aEntry.caseCase     := bufferToString(vRecord.mrCase);
//end;
//
//function TLewisAndShort.importORecord(const aLine: string; const aEntry: TTEIEntry): TVoid;
//  function bufferToString(const aBuffer: array of char): string;
//  begin
//    setLength(result, length(aBuffer));
//    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
//    result := trim(result); end;
//begin
//  var vByteLength := sizeOf(TORecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  case (length(aLine) < vLineLength) of TRUE: EXIT; end;
//
//  var vRecord: TORecord;
//  move(pointer(aLine)^, vRecord, vByteLength);
//
//  aEntry.orthography  := bufferToString(vRecord.orOrthography);
//  aEntry.orthography2 := bufferToString(vRecord.orOrthography2);
//end;
//
//function TLewisAndShort.importSRecord(const aLine: string; const aEntry: TTEIEntry): TTEISense;
//  function bufferToString(const aBuffer: array of char): string;
//  begin
//    setLength(result, length(aBuffer));
//    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
//    result := trim(result); end;
//begin
//  var vByteLength := sizeOf(TSRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  case (length(aLine) < vLineLength) of TRUE: EXIT(NIL); end;
//
//  var vRecord: TSRecord;
//  move(pointer(aLine)^, vRecord, vByteLength);
//
//  var vSense := TTEISense.Create;
//  result     := vSense;
//
//  vSense.id := bufferToString(vRecord.srID);
//  vSense.n  := bufferToString(vRecord.srN);
//  vSense.setLevel(vRecord.srLevel);
//
//  aEntry.senses.add(result);
//end;
//
//function TLewisAndShort.importCRecord(const aLine: string; const aSense: ITEISense): TCitation;
//  function bufferToString(const aBuffer: array of char): string;
//  begin
//    setLength(result, length(aBuffer));
//    move(aBuffer[0], pointer(result)^, length(aBuffer) * sizeOf(char));
//    result := trim(result); end;
//begin
//  var vByteLength := sizeOf(TCRecord);
//  var vLineLength := vByteLength div sizeOf(char);
//  case (length(aLine) < vLineLength) of TRUE: EXIT(NIL); end;
//
//  var vRecord: TCRecord;
//  move(pointer(aLine)^, vRecord, vByteLength);
//
//  result := TCitation.Create;
//
//  result.author := bufferToString(vRecord.crAuthor);
//  result.bibl   := bufferToString(vRecord.crBibl);
//  result.n      := bufferToString(vRecord.crN);
//
//  TTEISense(aSense).addCitation(result);
//end;
//
//function TLewisAndShort.import(const aFileName: string): TVoid;
//begin
//  case not fileExists(aFileName) of TRUE: EXIT; end;
//
//  var vStream       := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
//  var vReader       := TStreamReader.Create(vStream, TEncoding.UTF8);
//  var vCurrentEntry : TTEIEntry    := NIL;
//  var vCurrentSense : ITEISense    := NIL;
//  var vCurrentCite  : TCitation    := NIL;
//
//  while not vReader.endOfStream do begin
//    var vLine := vReader.readLine;
//    case (vLine = '') of TRUE: CONTINUE; end;
//
//    case vLine[1] of
//      'W': begin
//             vCurrentEntry := importWRecord(vLine);
//             vCurrentSense := NIL;
//             vCurrentCite  := NIL; end;
//      'M': case assigned(vCurrentEntry) of TRUE: importMRecord(vLine, vCurrentEntry); end;
//      'O': case assigned(vCurrentEntry) of TRUE: importORecord(vLine, vCurrentEntry); end;
//      'E': case assigned(vCurrentEntry) of TRUE: vCurrentEntry.etymology  := copy(vLine, 3, maxInt); end;
//      'D': case assigned(vCurrentEntry) of TRUE: vCurrentEntry.definition := copy(vLine, 3, maxInt); end;
//      'S': begin
//             vCurrentSense := importSRecord(vLine, vCurrentEntry);
//             vCurrentCite  := NIL; end;
//      'X': case assigned(vCurrentSense) of TRUE: TTEISense(vCurrentSense).definition := copy(vLine, 3, maxInt); end;
//      'C': case assigned(vCurrentSense) of TRUE: vCurrentCite := importCRecord(vLine, vCurrentSense); end;
//      'Q': case assigned(vCurrentCite)  of TRUE: vCurrentCite.quote := copy(vLine, 3, maxInt); end; end; end;
//
//  vReader.free;
//  vStream.free;
//end;

{ TCitation }

constructor TCitation.Create;
begin
  inherited Create;
end;

function TCitation.getAuthor: string;
begin
  result := FAuthor;
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
