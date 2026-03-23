//unit latin.lewisAndShortXml;
//
//interface
//
//uses
//  system.sysUtils,
//  system.classes,
//  system.generics.collections,
//  system.strUtils,
//  xml.xmlDoc,
//  xml.xmlIntf;
//
//type
//  TVoid = (vNone);
//
//  TTEISense = class(TObject)
//  private
//    FId: string;
//    FN: string;
//    FLevel: integer;
//    FDefinition: string;
//    FSenses: TObjectList<TTEISense>;
//  public
//    constructor create;
//    destructor destroy; override;
//    property id: string read FId write FId;
//    property n: string read FN write FN;
//    property level: integer read FLevel write FLevel;
//    property definition: string read FDefinition write FDefinition;
//    property senses: TObjectList<TTEISense> read FSenses;
//  end;
//
//  TTEIEntry = class(TObject)
//  private
//    FId: string;
//    FKey: string;
//    FOrthography: string;
//    FInflection: string;
//    FEtymology: string;
//    FDefinition: string;
//    FSenses: TObjectList<TTEISense>;
//  public
//    constructor create;
//    destructor destroy; override;
//    property id: string read FId write FId;
//    property key: string read FKey write FKey;
//    property orthography: string read FOrthography write FOrthography;
//    property inflection: string read FInflection write FInflection;
//    property etymology: string read FEtymology write FEtymology;
//    property definition: string read FDefinition write FDefinition;
//    property senses: TObjectList<TTEISense> read FSenses;
//  end;
//
//  TLSDictionary = class(TObject)
//  private
//    FEntries: TObjectList<TTEIEntry>;
//    function scanNodes(const aNode: IXMLNode): TVoid;
//    function parseSenses(const aNode: IXMLNode; const aList: TObjectList<TTEISense>): TVoid;
//    function processEntry(const aNode: IXMLNode): TVoid;
//  public
//    constructor create;
//    destructor destroy; override;
//    function loadFromFile(const aFileName: string): TVoid;
//    property entries: TObjectList<TTEIEntry> read FEntries;
//  end;
//
//implementation
//
//constructor TTEISense.create;
//begin
//  inherited create;
//  FSenses := TObjectList<TTEISense>.create;
//end;
//
//destructor TTEISense.destroy;
//begin
//  FSenses.free;
//  inherited destroy;
//end;
//
//constructor TTEIEntry.create;
//begin
//  inherited create;
//  FSenses := TObjectList<TTEISense>.create;
//end;
//
//destructor TTEIEntry.destroy;
//begin
//  FSenses.free;
//  inherited destroy;
//end;
//
//constructor TLSDictionary.create;
//begin
//  inherited create;
//  FEntries := TObjectList<TTEIEntry>.create;
//end;
//
//destructor TLSDictionary.destroy;
//begin
//  FEntries.free;
//  inherited destroy;
//end;
//
//function TLSDictionary.parseSenses(const aNode: IXMLNode; const aList: TObjectList<TTEISense>): TVoid;
//begin
//  var vSense: TTEISense := TTEISense.create;
//  aList.add(vSense);
//  case aNode.hasAttribute('id') of True: vSense.id := aNode.attributes['id']; end;
//  case aNode.hasAttribute('n') of True: vSense.n := aNode.attributes['n']; end;
//  case aNode.hasAttribute('level') of True: vSense.level := strToIntDef(aNode.attributes['level'], 0); end;
//  for var vI: integer := 0 to aNode.childNodes.count - 1 do
//  begin
//    var vChild: IXMLNode := aNode.childNodes[vI];
//    case sameText(vChild.nodeName, 'sense') of
//      True: parseSenses(vChild, vSense.senses);
//      False: vSense.definition := vSense.definition + vChild.xml;
//    end;
//  end;
//  Result := TVoid.vNone;
//end;
//
//function TLSDictionary.processEntry(const aNode: IXMLNode): TVoid;
//begin
//  var vEntry: TTEIEntry := TTEIEntry.create;
//  FEntries.add(vEntry);
//  case aNode.hasAttribute('id') of True: vEntry.id := aNode.attributes['id']; end;
//  case aNode.hasAttribute('key') of True: vEntry.key := aNode.attributes['key']; end;
//  for var vI: integer := 0 to aNode.childNodes.count - 1 do
//  begin
//    var vChild: IXMLNode := aNode.childNodes[vI];
//    var vName: string := vChild.nodeName;
//    case sameText(vName, 'orth') of True: vEntry.orthography := vEntry.orthography + vChild.xml; end;
//    case sameText(vName, 'itype') of True: vEntry.inflection := vEntry.inflection + vChild.xml; end;
//    case sameText(vName, 'etym') of True: vEntry.etymology := vEntry.etymology + vChild.xml; end;
//    case sameText(vName, 'sense') of
//      True: parseSenses(vChild, vEntry.senses);
//      False:
//      begin
//        case (not sameText(vName, 'orth')) and (not sameText(vName, 'itype')) and (not sameText(vName, 'etym')) of
//          True: vEntry.definition := vEntry.definition + vChild.xml;
//        end;
//      end;
//    end;
//  end;
//  Result := TVoid.vNone;
//end;
//
//function TLSDictionary.scanNodes(const aNode: IXMLNode): TVoid;
//begin
//  case sameText(aNode.nodeName, 'entryFree') of
//    True: processEntry(aNode);
//    False:
//    begin
//      for var vI: integer := 0 to aNode.childNodes.count - 1 do
//      begin
//        scanNodes(aNode.childNodes[vI]);
//      end;
//    end;
//  end;
//  Result := TVoid.vNone;
//end;
//
//function TLSDictionary.loadFromFile(const aFileName: string): TVoid;
//begin
//  var vRaw: TStringList := TStringList.create;
//  try
//    vRaw.loadFromFile(aFileName, TEncoding.UTF8);
//    for var vI: integer := 0 to vRaw.count - 1 do
//    begin
//      case containsText(vRaw[vI], '<!DOCTYPE') of
//        True:
//        begin
//          vRaw[vI] := '';
//          break;
//        end;
//      end;
//    end;
//    var vXml: IXMLDocument := loadXMLData(vRaw.text);
//    scanNodes(vXml.documentElement);
//  finally
//    vRaw.free;
//  end;
//  Result := TVoid.vNone;
//end;
//
//end.








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
    FId:            string;
    FKey:           string;
    FOrthography:   string;
    FInflection:    string;
    FEtymology:     string;
    FDefinition:    string;
    FSenses:        TObjectList<TTEISense>;
  public
    constructor create;
    destructor destroy; override;
    property id:            string                  read FId          write FId;
    property key:           string                  read FKey         write FKey;
    property orthography:   string                  read FOrthography write FOrthography;
    property inflection:    string                  read FInflection  write FInflection;
    property etymology:     string                  read FEtymology   write FEtymology;
    property definition:    string                  read FDefinition  write FDefinition;
    property senses:        TObjectList<TTEISense>  read FSenses;
  end;

  TLSDictionary = class(TObject)
  private
    FEntries: TObjectList<TTEIEntry>;
    function parseSenses(const aNode: IXMLDOMNode; const aList: TObjectList<TTEISense>): TVoid;
  public
    constructor create;
    destructor destroy; override;
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
  FEntries := TObjectList<TTEIEntry>.create;
end;

destructor TLSDictionary.destroy;
begin
  FEntries.free;
  inherited destroy;
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

                                            var vOrth: IXMLDOMNode := vNode.selectSingleNode('orth');
                                            case assigned(vOrth) of True: vEntry.orthography := vOrth.text; end;

                                            var vIType: IXMLDOMNode := vNode.selectSingleNode('itype');
                                            case assigned(vIType) of True: vEntry.inflection := vIType.text; end;

                                            var vEtym: IXMLDOMNode := vNode.selectSingleNode('etym');
                                            case assigned(vEtym) of True: vEntry.etymology := vEtym.text; end;

                                            vEntry.definition := vNode.text;
                                            parseSenses(vNode, vEntry.senses);
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
