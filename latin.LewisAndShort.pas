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

  ITEISense = interface
    function getDefinition:     string;
    function getID:             string;
    function getN:              string;
    function getLevel:          integer;

    function iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;

    property definition:        string                  read getDefinition;
    property ID:                string                  read getID;
    property N:                 string                  read getN;
    property level:             integer                 read getLevel;
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
  end;

  ILewisAndShort = interface
    function entryCount: integer;
    function findEntry(const aKey: string): ILewisAndShortEntry;
    function loadLewisAndShort(const aFileName: string): TVoid;
  end;

//  TTraverser = class
//  public
//    class function writeSenses(const aSenses: TList<ITEISense>; const aIndent: integer = 2): TVoid;
//  end;

  function newLewisAndShort: ILewisAndShort;

implementation

uses
  _debugWindow;

type
  TTEISense = class(TinterfacedObject, ITEISense)
  private
    FId:          string;
    FN:           string;
    FLevel:       integer;
    FDefinition:  string;
    FSubSenses:   TList<ITEISense>;
    function getFN: string;
  public
    constructor Create;
    destructor Destroy; override;
    function getDefinition:     string;
    function getID:             string;
    function getN:              string;
    function getLevel:          integer;
    function getSubSenses:      TList<ITEISense>;

    function iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;

    property ID:          string                  read getID            write FID;
    property n:           string                  read getFN            write FN;
    property level:       integer                 read getLevel         write FLevel;
    property definition:  string                  read getDefinition    write FDefinition;
    property subSenses:   TList<ITEISense>        read getSubSenses;
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
  FSubSenses := TList<ITEISense>.Create;
end;

destructor TTEISense.Destroy;
begin
  FSubSenses.clear;
  FSubSenses.free;
  inherited Destroy;
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
  result := FLevel;
end;

function TTEISense.getN: string;
begin
  result := FN;
end;

function TTEISense.getSubSenses: TList<ITEISense>;
begin
  result := FSubSenses;
end;

function TTEISense.iterateSenses(const aFunc: TStringFunc; const aIndent: integer = 2): TVoid;
begin
var vPrefix := stringOfChar(' ', FLevel * aIndent) + '[' + FN + '] ';

  case (FDefinition <> '') of  TRUE: aFunc(vPrefix + FDefinition);
                              FALSE: aFunc(vPrefix); end;

  debugInteger('FSubSenses.count', FSubSenses.count);

  for var i: integer := 0 to FSubSenses.count - 1 do FSubSenses[i].iterateSenses(aFunc, aIndent);

//  var vPrefix := stringOfChar(' ', aIndent * 2) + '[' + FN + '] ';
//
//  case (FDefinition <> '') of  TRUE: aFunc(vPrefix + FDefinition);
//                              FALSE: aFunc(vPrefix); end;
//
//  for var i := 0 to FSubSenses.count - 1 do FSubSenses[i].iterateSenses(aFunc, aIndent + 2);
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
begin
  var vNodes: IXMLDOMNodeList := aNode.selectNodes('sense');


  case assigned(vNodes) of   TRUE: for var i := 0 to vNodes.length - 1 do  begin
                                                                              var vSNode: IXMLDOMNode := vNodes.item[i];
                                                                              var vSense: TTEISense   := TTEISense.create;
                                                                              var iSense: ITEISense   := vSense; // pin the reference count to 1
                                                                              aList.add(iSense);
                                                                              var vAttrs: IXMLDOMNamedNodeMap := vSNode.attributes;
                                                                              case Assigned(vAttrs) of   TRUE:  begin
                                                                                                                  var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
                                                                                                                  case Assigned(vIdAttr) of TRUE: vSense.id := vIdAttr.text; end;

                                                                                                                  var vNAttr: IXMLDOMNode := vAttrs.getNamedItem('n');
                                                                                                                  case Assigned(vNAttr) of TRUE: vSense.n := vNAttr.text; end;

                                                                                                                  var vLevelAttr: IXMLDOMNode := vAttrs.getNamedItem('level');
                                                                                                                  case Assigned(vLevelAttr) of TRUE: vSense.level := StrToIntDef(vLevelAttr.text, 0); end;
                                                                                                                end;end;
                                                                              vSense.definition := vSNode.text;
                                                                              parseSenses(vSNode, vSense.FSubSenses);
                                                                            end;end;
end;

function TLewisAndShort.loadLewisAndShort(const aFileName: string): TVoid;
begin
  var vXml: IXMLDOMDocument2 := CreateComObject(CLASS_DOMDocument60) as IXMLDOMDocument2;

  vXml.async              := FALSE;
  vXml.resolveExternals   := FALSE;
  vXml.validateOnParse    := FALSE;
  vXml.setProperty('ProhibitDTD', FALSE);
  vXml.setProperty('SelectionLanguage', 'XPath');

  case vXml.load(aFileName) of   TRUE:  begin
      var vEntries: IXMLDOMNodeList := vXml.selectNodes('//entryFree');

      case Assigned(vEntries) of   TRUE:  for var i := 0 to vEntries.length - 1 do  begin
                                            var vNode: IXMLDOMNode  := vEntries.item[i];
                                            var vEntry: TTEIEntry   := TTEIEntry.create;

                                            FEntries.add(vEntry as ILewisAndShortEntry);

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

initialization
  coInitialize(NIL);

finalization
  coUninitialize;

end.
