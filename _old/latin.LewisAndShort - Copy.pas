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
  public
    constructor Create;
    destructor Destroy; override;
    function entryCount: integer;
    function findEntry(const aKey: string): ILewisAndShortEntry;
    function loadLewisAndShort(const aFileName: string): TVoid;
    property entries: TList<ILewisAndShortEntry> read FEntries;
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

    aFunc({vCitationIndent + }vCitationText);
  end;
end;

procedure TTEISense.setLevel(const aValue: string);
begin
  FLevel := aValue;
end;

//function TTEISense.iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;
//begin
//  var vPrefix := stringOfChar(' ', FLevel * aIndent) + '[' + FN + '] ';
//
//  case (FDefinition <> '') of TRUE: aFunc(vPrefix + FDefinition);
//                              FALSE: aFunc(vPrefix); end;
//
//  for var i := 0 to FCitations.count - 1 do begin
//    var vCit       := FCitations[i];
//    var vCitPrefix := stringOfChar(' ', (FLevel + 1) * aIndent) + '- ';
//    var vCitText   := '';
//
//    case (vCit.author <> '') of TRUE: vCitText := vCit.author + ': ' + vCit.bibliography;
//                                FALSE: vCitText := vCit.bibliography; end;
//
//    case (vCit.n <> '')     of TRUE: vCitText := vCitText + ' (' + vCit.n + ')'; end;
//    case (vCit.quote <> '') of TRUE: vCitText := '"' + vCit.quote + '" ' + vCitText; end;
//
//    aFunc(vCitPrefix + vCitText);
//  end;
//end;

//function TTEISense.iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;
//begin
//  var vPrefix := stringOfChar(' ', FLevel * aIndent) + '[' + FN + '] ';
//
//  case (FDefinition <> '') of  TRUE: aFunc(vPrefix + FDefinition);
//                              FALSE: aFunc(vPrefix); end;
//
//for var i := 0 to FCitations.count - 1 do begin
//    var vCit       := FCitations[i];
//    var vCitPrefix := stringOfChar(' ', (FLevel + 1) * aIndent) + '- ';
//    var vCitText   := '';
//
//    case (vCit.author <> '') of TRUE: vCitText := vCit.author + ': ' + vCit.bibliography;
//                                FALSE: vCitText := vCit.bibliography; end;
//
//    case (vCit.n <> '')     of TRUE: vCitText := vCitText + ' (' + vCit.n + ')'; end;
//    case (vCit.quote <> '') of TRUE: vCitText := vCitText + ' "' + vCit.quote + '"'; end;
//
//    aFunc(vCitPrefix + vCitText);
//  end;

  // debugInteger('FSubSenses.count', FSubSenses.count);

  // for var i: integer := 0 to FSubSenses.count - 1 do FSubSenses[i].iterateSenses(aFunc, aIndent);

//  var vPrefix := stringOfChar(' ', aIndent * 2) + '[' + FN + '] ';
//
//  case (FDefinition <> '') of  TRUE: aFunc(vPrefix + FDefinition);
//                              FALSE: aFunc(vPrefix); end;
//
//  for var i := 0 to FSubSenses.count - 1 do FSubSenses[i].iterateSenses(aFunc, aIndent + 2);
//end;

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

// good but now has redundant code as we're not checking if author and bibliography is duplicated in vDefinition
//function TLewisAndShort.parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
//var vAuthorName : string;
//var vBiblText   : string;
//var vNText      : string;
//var vQuoteText  : string;
//var vMarker     : string;
//var vDefinition : string;
//var vSense      : TTEISense;
//
//  function addCitation: TVoid;
//  begin
//    var vCitation := TCitation.Create;
//    vCitation.author := vAuthorName;
//    vCitation.bibl   := vBiblText;
//    vCitation.N      := vNText;
//    vCitation.quote  := vQuoteText;
//    vSense.addCitation(vCitation);
//  end;
//
//  function limitText(var aText: string): TVoid;
//  begin
//    case vMarker = '' of TRUE: EXIT; end;
//    var vMarkerHead := copy(vMarker, 1, 10);
//    var vPos        := pos(vMarkerHead, aText);
//    case vPos > 1 of   TRUE: delete(aText, vPos - 1, length(aText)); end;
//  end;
//
//begin
//  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');
//
//  case assigned(vSenseNodes) of TRUE:
//    for var i := 0 to vSenseNodes.length - 1 do begin
//      var vSenseNode: IXMLDOMNode := vSenseNodes.item[i];
//          vSense                  := TTEISense.create;
//      var iSense: ITEISense       := vSense;
//      aList.add(iSense);
//
//      var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
//      case assigned(vAttrs) of   TRUE:  begin
//        var vLevelAttr: IXMLDOMNode := vAttrs.getNamedItem('level');
//        case assigned(vLevelAttr) of TRUE: vSense.setLevel(vLevelAttr.text); end;
//
//        var vNAttr: IXMLDOMNode := vAttrs.getNamedItem('n');
//        case assigned(vNAttr) of TRUE: vSense.n := vNAttr.text; end;
//
//        var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
//        case assigned(vIdAttr) of TRUE: vSense.id := vIdAttr.text; end;end;end;
//
//      vDefinition       := vSenseNode.text;
//
//      var vCitations: IXMLDOMNodeList := vSenseNode.selectNodes('.//cit | .//bibl');
//      case assigned(vCitations) of TRUE: begin
//        for var j := 0 to vCitations.length - 1 do begin
//          var vCurrentNode: IXMLDOMNode := vCitations.item[j];
//
//          // bibl nodes can be children of cit or sense
//          // don't process a bibl node twice because of the OR-ed selectNodes above
//          case (vCurrentNode.nodeName = 'bibl') and assigned(vCurrentNode.parentNode) and (vCurrentNode.parentNode.nodeName = 'cit') of TRUE: CONTINUE; end;
//
//          var vQuote:     IXMLDOMNode := NIL;
//          var vBibl:      IXMLDOMNode := NIL;
//          vQuoteText  := '';
//          vMarker     := '';
//
//          case vCurrentNode.nodeName = 'cit' of
//             TRUE:  begin
//                      vQuote := vCurrentNode.selectSingleNode('quote');
//                      vBibl  := vCurrentNode.selectSingleNode('bibl');
//                      case assigned(vQuote) of TRUE: begin
//                        vQuoteText := vQuote.text;
//                        vMarker    := vQuoteText;
//                      end; end;
//
//                      case (vMarker = '') and assigned(vBibl) of TRUE: begin
//                        var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
//                        //case assigned(vAuthor) of  TRUE: vMarker := vAuthor.text;
//                        //                          FALSE: vMarker := vBibl.text; end;
//                      end; end;
//                    end;
//            FALSE:  begin
//                      vBibl := vCurrentNode;
//                      var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
//                      //case assigned(vAuthor) of  TRUE: vMarker := vAuthor.text;
//                      //                          FALSE: vMarker := vBibl.text; end;
//                    end;
//          end;
//
//          case (j = 0) of TRUE: limitText(vDefinition); end;
//
//          vAuthorName := '';
//          vBiblText   := '';
//          vNText      := '';
//
//          case assigned(vBibl) of TRUE: begin
//            var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
//            var vNAttr:  IXMLDOMNode := vBibl.attributes.getNamedItem('n');
//            case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;
//
//            vBiblText := vBibl.text;
//            var vPos := pos(vAuthorName, vBiblText);
//            case vPos = 1 of TRUE: vBiblText := copy(vBiblText, length(vAuthorName) + 1, length(vBiblText)); end;
//
//            case assigned(vNAttr)  of TRUE: vNText := vNAttr.text; end;end;end;
//
//          addCitation; end;end;end;
//
//      vSense.definition := vDefinition;
//  end;end;
//end;


// good but needs optimizing
//function TLewisAndShort.parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
//var vAuthorName : string;
//var vBiblText   : string;
//var vNText      : string;
//var vQuoteText  : string;
//var vMarker     : string;
//
//  function limitedDefinition(const aDefinition: string; const aMarker: string): string;
//  begin
//    case aMarker = '' of TRUE: begin result := aDefinition; EXIT; end; end;
//    var vMarkerHead := copy(aMarker, 1, 10);
//    var vPos         := pos(vMarkerHead, aDefinition);
//    case vPos > 1 of   TRUE: result := copy(aDefinition, 1, vPos - 1);
//                      FALSE: result := aDefinition; end;
//  end;
//
//begin
//  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');
//
//  case assigned(vSenseNodes) of TRUE: for var i := 0 to vSenseNodes.length - 1 do  begin
//    var vSenseNode: IXMLDOMNode := vSenseNodes.item[i];
//    var vSense: TTEISense       := TTEISense.create;
//    var iSense: ITEISense       := vSense;
//    aList.add(iSense);
//
//    var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
//    case assigned(vAttrs) of   TRUE:  begin
//      var vLevelAttr: IXMLDOMNode := vAttrs.getNamedItem('level');
//      case assigned(vLevelAttr) of TRUE: vSense.setLevel(vLevelAttr.text); end;
//
//      var vNAttr: IXMLDOMNode := vAttrs.getNamedItem('n');
//      case assigned(vNAttr) of TRUE: vSense.n := vNAttr.text; end;
//
//      var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
//      case assigned(vIdAttr) of TRUE: vSense.id := vIdAttr.text; end;
//    end;end;
//
//    vSense.definition := vSenseNode.text;
//
//    var vCits: IXMLDOMNodeList := vSenseNode.selectNodes('.//cit | .//bibl');
//    case assigned(vCits) of TRUE: begin
//      for var j := 0 to vCits.length - 1 do begin
//        var vCurrentNode: IXMLDOMNode := vCits.item[j];
//
//        case (vCurrentNode.nodeName = 'bibl') and assigned(vCurrentNode.parentNode) and (vCurrentNode.parentNode.nodeName = 'cit') of
//          TRUE: CONTINUE; end;
//
//        var vQuote:     IXMLDOMNode := NIL;
//        var vBibl:      IXMLDOMNode := NIL;
//        vQuoteText  := '';
//        vMarker     := '';
//
//        case vCurrentNode.nodeName = 'cit' of
//          TRUE: begin
//            vQuote := vCurrentNode.selectSingleNode('quote');
//            vBibl  := vCurrentNode.selectSingleNode('bibl');
//            case assigned(vQuote) of TRUE: begin
//              vQuoteText := vQuote.text;
////              vMarker    := vQuoteText;
//            end; end;
//
//            case (vMarker = '') and assigned(vBibl) of TRUE: begin
//              var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
////              case assigned(vAuthor) of TRUE: vMarker := vAuthor.text;
////                                       FALSE: vMarker := vBibl.text; end;
//            end; end;
//          end;
//          FALSE: begin
//            vBibl := vCurrentNode;
//            var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
////            case assigned(vAuthor) of TRUE: vMarker := vAuthor.text;
////                                     FALSE: vMarker := vBibl.text; end;
//          end;
//        end;
//
////        case (j = 0) of TRUE: vSense.definition := limitedDefinition(vSense.definition, vMarker); end;
//        case (j = 0) of TRUE: vSense.definition := limitedDefinition(vSense.definition, vQuote.text); end;
//
//        vAuthorName := '';
//        vBiblText   := '';
//        vNText      := '';
//
//        case assigned(vBibl) of TRUE: begin
//          var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
//          var vNAttr:  IXMLDOMNode := vBibl.attributes.getNamedItem('n');
//          case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;
//          vBiblText := vBibl.text;
//          var vPos := pos(vAuthorName, vBiblText);
//          case vPos = 1 of TRUE: vBiblText := copy(vBiblText, length(vAuthorName) + 1, length(vBiblText)); end;
//          case assigned(vNAttr)  of TRUE: vNText := vNAttr.text; end;
//        end; end;
//
//        // vSense.addCitation(vAuthorName, vBiblText, vNText, vQuoteText);
//        vSense.addCitation(vAuthorName, vBiblText, vNText, vQuoteText);
//      end;
//    end; end;
//  end;end;
//end;

// this seems ok but it doesn't limit Definition properly if there's no quote in the citation
//function TLewisAndShort.parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
//
//  function limitedDefinition(const aDefinition: string; aQuote: string): string;
//  begin
//    case aQuote = '' of TRUE: begin result := aDefinition; EXIT; end; end;
//    var vQuoteStart := copy(aQuote, 1, 10);
//    var vPos        := pos(vQuoteStart, aDefinition);
//    case vPos > 1 of   TRUE: result := copy(aDefinition, 1, vPos - 1);
//                       FALSE: result := aDefinition; end;
//  end;
//
//begin
//  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');
//
//  case assigned(vSenseNodes) of TRUE: for var i := 0 to vSenseNodes.length - 1 do  begin
//    var vSenseNode: IXMLDOMNode := vSenseNodes.item[i];
//    var vSense: TTEISense       := TTEISense.create;
//    var iSense: ITEISense       := vSense;
//    aList.add(iSense);
//
//    var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
//    case assigned(vAttrs) of   TRUE:  begin
//      var vLevelAttr: IXMLDOMNode := vAttrs.getNamedItem('level');
//      case assigned(vLevelAttr) of TRUE: vSense.level := StrToIntDef(vLevelAttr.text, 0); end;
//
//      var vNAttr: IXMLDOMNode := vAttrs.getNamedItem('n');
//      case assigned(vNAttr) of TRUE: vSense.n := vNAttr.text; end;
//
//      var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
//      case assigned(vIdAttr) of TRUE: vSense.id := vIdAttr.text; end;
//    end;end;
//
//    vSense.definition := vSenseNode.text;
//
//    var vCits: IXMLDOMNodeList := vSenseNode.selectNodes('.//cit | .//bibl');
//    case assigned(vCits) of TRUE: begin
//      for var j := 0 to vCits.length - 1 do begin
//        var vCurrentNode: IXMLDOMNode := vCits.item[j];
//
//        case (vCurrentNode.nodeName = 'bibl') and assigned(vCurrentNode.parentNode) and (vCurrentNode.parentNode.nodeName = 'cit') of
//          TRUE: CONTINUE; end;
//
//        var vQuote:     IXMLDOMNode := nil;
//        var vBibl:      IXMLDOMNode := nil;
//        var vQuoteText  := '';
//
//        case vCurrentNode.nodeName = 'cit' of
//          TRUE: begin
//            vQuote := vCurrentNode.selectSingleNode('quote');
//            vBibl  := vCurrentNode.selectSingleNode('bibl');
//            case assigned(vQuote) of TRUE: vQuoteText := vQuote.text; end;
//            vSense.definition := limitedDefinition(vSense.definition, vQuoteText);
//          end;
//          FALSE: vBibl := vCurrentNode;
//        end;
//
//        var vAuthorName := '';
//        var vBiblText   := '';
//        var vNText      := '';
//
//        case assigned(vBibl) of TRUE: begin
//          var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
//          var vNAttr:  IXMLDOMNode := vBibl.attributes.getNamedItem('n');
//          case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;
//          vBiblText := trim(vBibl.text);
//          var vPos := pos(vAuthorName, vBiblText);
//          case vPos = 1 of TRUE: vBiblText := trim(copy(vBiblText, length(vAuthorName) + 1, length(vBiblText))); end;
//          case assigned(vNAttr)  of TRUE: vNText      := vNAttr.text; end;
//        end; end;
//
//        vSense.addCitation(vAuthorName, vBiblText, vNText, vQuoteText);
//      end;
//    end; end;
//  end;end;
//end;

// this is fine but it doesn't allow for the non-citation bibl/author nodes
//function TLewisAndShort.parseSenses(const aNode: IXMLDOMNode; const aList: TList<ITEISense>): TVoid;
//
//  function limitedDefinition(const aDefinition: string; aQuote: string): string;
//  begin
//    var vQuoteStart := copy(aQuote, 1, 10); // use an arbitrary 10 characters for now
//    var vPos        := pos(vQuoteStart, aDefinition);
//    case vPos > 1 of   TRUE: result := copy(aDefinition, 1, vPos - 1);
//                      FALSE: result := aDefinition; end;
//  end;
//
//begin
//  var vSenseNodes: IXMLDOMNodeList := aNode.selectNodes('sense');
//
//  case assigned(vSenseNodes) of TRUE: for var i := 0 to vSenseNodes.length - 1 do  begin
//                                                                              var vSenseNode: IXMLDOMNode := vSenseNodes.item[i];
//                                                                              var vSense: TTEISense       := TTEISense.create;
//                                                                              var iSense: ITEISense       := vSense; // pin the reference count to 1
//                                                                              aList.add(iSense);
//
//                                                                              var vAttrs: IXMLDOMNamedNodeMap := vSenseNode.attributes;
//                                                                              case assigned(vAttrs) of   TRUE:  begin
//                                                                                                                  var vLevelAttr: IXMLDOMNode := vAttrs.getNamedItem('level');
//                                                                                                                  case assigned(vLevelAttr) of TRUE: vSense.level := StrToIntDef(vLevelAttr.text, 0); end;
//
//                                                                                                                  var vNAttr: IXMLDOMNode := vAttrs.getNamedItem('n');
//                                                                                                                  case assigned(vNAttr) of TRUE: vSense.n := vNAttr.text; end;
//
//                                                                                                                  var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
//                                                                                                                  case assigned(vIdAttr) of TRUE: vSense.id := vIdAttr.text; end;
//                                                                                                                end;end;
//
//                                                                              vSense.definition := vSenseNode.text;
//                                                                              //debugString('vSenseNode.text', vSenseNode.text);
//
//                                                                              var vCits: IXMLDOMNodeList := vSenseNode.selectNodes('.//cit');
//                                                                              case assigned(vCits) of TRUE: begin
//                                                                                for var j := 0 to vCits.length - 1 do begin
//                                                                                  var vCitNode: IXMLDOMNode := vCits.item[j];
//                                                                                  var vQuote:   IXMLDOMNode := vCitNode.selectSingleNode('quote');
//                                                                                  var vBibl:    IXMLDOMNode := vCitNode.selectSingleNode('bibl');
//
//                                                                                  var vAuthorName := '';
//                                                                                  var vQuoteText  := '';
//                                                                                  var vBiblText   := '';
//                                                                                  var vNText      := '';
//
//                                                                                  case assigned(vQuote) of TRUE: vQuoteText := vQuote.text; end;
//                                                                                  //debugString('vQuoteText', vQuoteText);
//                                                                                  vSense.definition := limitedDefinition(vSense.definition, vQuoteText);
//                                                                                  //debugString('new', vSense.definition);
//                                                                                  //EXIT;
//                                                                                  case assigned(vBibl)  of TRUE: begin
//                                                                                    var vAuthor: IXMLDOMNode := vBibl.selectSingleNode('author');
//                                                                                    var vNAttr:  IXMLDOMNode := vBibl.attributes.getNamedItem('n');
//                                                                                    case assigned(vAuthor) of TRUE: vAuthorName := vAuthor.text; end;
//                                                                                    vBiblText := trim(vBibl.text);
//                                                                                    var vPos := pos(vAuthorName, vBiblText);
//                                                                                    case vPos = 1 of TRUE: vBiblText := trim(copy(vBiblText, length(vAuthorName) + 1, length(vBiblText))); end;
//                                                                                    case assigned(vNAttr)  of TRUE: vNText      := vNAttr.text; end;
//                                                                                  end; end;
//
//                                                                                  vSense.addCitation(vAuthorName, vBiblText, vNText, vQuoteText);
//                                                                                end;
//                                                                              end; end;
//
//
////                                                                              var vBibls: IXMLDOMNodeList := vSenseNode.selectNodes('.//bibl');
////                                                                              case assigned(vBibls) of TRUE:  begin
////                                                                                                                for var j := 0 to vBibls.length - 1 do begin
////                                                                                                                  var vBibl:    IXMLDOMNode := vBibls.item[j];
////                                                                                                                  var vAuthor:  IXMLDOMNode := vBibl.selectSingleNode('author');
////                                                                                                                  var vQuote: IXMLDOMNode  := vBibl.selectSingleNode('quote');
////                                                                                                                  var vNAttr: IXMLDOMNode  := vBibl.attributes.getNamedItem('n');
////
////                                                                                                                  var vAuthorName := '';
////                                                                                                                  var vQuoteText  := '';
////                                                                                                                  var vNText      := '';
////
////                                                                                                                  case assigned(vAuthor)  of TRUE: vAuthorName  := vAuthor.text; end;
////                                                                                                                  case assigned(vQuote)   of TRUE: vQuoteText   := vQuote.text; end;
////                                                                                                                  case assigned(vNAttr)   of TRUE: vNText       := vNAttr.text; end;
////                                                                                                                  vSense.addCitation(vAuthorName, vBibl.text, vNText, vQuoteText);
////                                                                                                                end;end;end;
//                                                                            end;end;
//end;

function TLewisAndShort.loadLewisAndShort(const aFileName: string): TVoid;
begin
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

//class function TTraverser.writeSenses(const aSenses: TList<ITEISense>; const aIndent: integer = 2): TVoid;
//begin
//  case assigned(aSenses) of  TRUE:  for var i: integer := 0 to aSenses.count - 1 do begin
//                                                                                      var vSense: ITEISense := aSenses[i];
//                                                                                      var vPrefix: string   := stringOfChar(' ', aIndent * 2) + '[' + intToStr(i) + '] ';
//                                                                                      case (vSense.definition <> '') of  TRUE:  writeUnicode(vPrefix + vSense.definition);
//                                                                                                                         FALSE: writeUnicode(vPrefix); end;
//                                                                                      writeSenses(vSense.subSenses, aIndent + 2); end;end;
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
