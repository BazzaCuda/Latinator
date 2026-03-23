unit latin.LewisAndShortXML;

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
  TTEISense = class(TObject)
  private
    FId:          string;
    FN:           string;
    FLevel:       integer;
    FDefinition:  string;
    FSubSenses:   TObjectList<TTEISense>;
  public
    constructor create;
    destructor destroy; override;
    property id:          string                  read FId          write FId;
    property n:           string                  read FN           write FN;
    property level:       integer                 read FLevel       write FLevel;
    property definition:  string                  read FDefinition  write FDefinition;
    property subSenses:   TObjectList<TTEISense>  read FSubSenses;
  end;

  TTEIEntry = class(TObject)
  private
    FDefinition:    string;
    FEntryType:     string;
    FEtymology:     string;
    FGender:        string;
    FID:            string;
    FInflection:    string;
    FKey:           string;
    FLanguage:      string;
    FOrthography:   string;
    FOrthography2:  string;
    FSenses:        TObjectList<TTEISense>;
  public
    constructor create;
    destructor destroy; override;
    property definition:    string                  read FDefinition    write FDefinition;
    property entryType:     string                  read FEntryType     write FEntryType;
    property etymology:     string                  read FEtymology     write FEtymology;
    property gender:        string                  read FGender        write FGender;
    property ID:            string                  read FID            write FID;
    property inflection:    string                  read FInflection    write FInflection;
    property key:           string                  read FKey           write FKey;
    property language:      string                  read FLanguage      write FLanguage;
    property orthography:   string                  read FOrthography   write FOrthography;
    property orthography2:  string                  read FOrthography2  write FOrthography2;
    property senses:        TObjectList<TTEISense>  read FSenses;
  end;

  TLSDictionary = class(TObject)
  strict private
    FEntries: TObjectList<TTEIEntry>;
    FIndex:   TObjectDictionary<string, TTEIEntry>;
    function parseSenses(const aNode: IXMLDOMNode; const aList: TObjectList<TTEISense>): TVoid;
  public
    constructor create;
    destructor destroy; override;
    function findEntry(const aKey: string): TTEIEntry;
    function loadFromFile(const aFileName: string): TVoid;
    property entries: TObjectList<TTEIEntry> read FEntries;
  end;

  TTraverser = class
  public
    class function writeSenses(const aSenses: TObjectList<TTEISense>; const aIndent: integer = 2): TVoid;
  end;

implementation

constructor TTEISense.create;
begin
  inherited create;
  FSubSenses := TObjectList<TTEISense>.create;
end;

destructor TTEISense.destroy;
begin
  FSubSenses.free;
  inherited destroy;
end;

constructor TTEIEntry.create;
begin
  inherited create;
  FSenses := TObjectList<TTEISense>.create;
end;

destructor TTEIEntry.destroy;
begin
  FSenses.free;
  inherited destroy;
end;

constructor TLSDictionary.create;
begin
  inherited create;
  FEntries  := TObjectList<TTEIEntry>.create;
  FIndex    := TObjectDictionary<string, TTEIEntry>.create([doOwnsValues]);
end;

destructor TLSDictionary.destroy;
begin
  FEntries.free;
  inherited destroy;
end;

function TLSDictionary.findEntry(const aKey: string): TTEIEntry;
begin
  case FIndex.tryGetValue(aKey, result) of FALSE: result := NIL; end;
end;

function TLSDictionary.parseSenses(const aNode: IXMLDOMNode; const aList: TObjectList<TTEISense>): TVoid;
begin
  var vNodes: IXMLDOMNodeList := aNode.selectNodes('sense');


  case assigned(vNodes) of   TRUE: for var i := 0 to vNodes.length - 1 do  begin
                                                                              var vSNode: IXMLDOMNode := vNodes.item[i];
                                                                              var vSense: TTEISense   := TTEISense.create;
                                                                              aList.add(vSense);
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
                                                                              parseSenses(vSNode, vSense.subSenses);
                                                                            end;end;
end;

function TLSDictionary.loadFromFile(const aFileName: string): TVoid;
begin
  coInitialize(NIL);

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

                                            FEntries.add(vEntry);

                                            var vAttrs: IXMLDOMNamedNodeMap := vNode.attributes;

                                            case assigned(vAttrs) of   TRUE:  begin
                                                var vIdAttr: IXMLDOMNode := vAttrs.getNamedItem('id');
                                                case assigned(vIdAttr) of TRUE: vEntry.id := vIdAttr.text; end;

                                                var vKeyAttr: IXMLDOMNode := vAttrs.getNamedItem('key');
                                                case assigned(vKeyAttr) of TRUE: vEntry.key := vKeyAttr.text; end;end;end;

                                            var vTypeAttr: IXMLDOMNode := vAttrs.getNamedItem('type');
                                            case assigned(vTypeAttr) of TRUE: vEntry.entryType := vTypeAttr.text; end;

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

                                            vEntry.definition := vNode.text;
                                            parseSenses(vNode, vEntry.senses);

                                            case (vEntry.key <> '') of TRUE: case FIndex.containsKey(vEntry.key) of FALSE: FIndex.add(vEntry.key, vEntry); end;end;

                                          end;
      end;end;end;

  coUninitialize;
end;

class function TTraverser.writeSenses(const aSenses: TObjectList<TTEISense>; const aIndent: integer = 2): TVoid;
begin
  case assigned(aSenses) of  TRUE:  for var vI: integer := 0 to aSenses.count - 1 do  begin
                                                                                      var vSense: TTEISense := aSenses[vI];
                                                                                      var vPrefix: string   := stringOfChar(' ', aIndent * 2) + '[' + intToStr(vI) + '] ';
                                                                                      case (vSense.definition <> '') of  TRUE:  writeUnicode(vPrefix + vSense.definition);
                                                                                                                         FALSE: writeUnicode(vPrefix); end;
                                                                                      writeSenses(vSense.subSenses, aIndent + 2); end;end;
end;

end.
