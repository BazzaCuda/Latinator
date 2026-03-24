unit latin.LewisAndShortJSON;

interface

uses
  system.sysUtils,
  system.classes,
  system.json,
  system.ioUtils,
  system.generics.collections,
  latin.types;

type
  TLSense = class
  private
    FChildren: TObjectList<TLSense>;
    FValue: string;
  public
    property children:  TObjectList<TLSense>  read FChildren  write FChildren;
    property value:     string                read FValue     write FValue;
    constructor create;
    destructor destroy; override;
  end;

  TLSEntry = class
  private
    FAlternativeGenitive:       string;
    FAlternativeOrthography:    string;
    FDeclension:                string;
    FEntryType:                 string;
    FGender:                    string;
    FGreekWord:                 string;
    FKey:                       string;
    FMainNotes:                 string;
    FPartOfSpeech:              string;
    FSenses:                    TObjectList<TLSense>;
    FTitleGenitive:             string;
    FTitleOrthography:          string;
  public
    property alternativeGenitive:     string                read FAlternativeGenitive     write FAlternativeGenitive;
    property alternativeOrthography:  string                read FAlternativeOrthography  write FAlternativeOrthography;
    property declension:              string                read FDeclension              write FDeclension;
    property entryType:               string                read FEntryType               write FEntryType;
    property gender:                  string                read FGender                  write FGender;
    property greekWord:               string                read FGreekWord               write FGreekWord;
    property key:                     string                read FKey                     write FKey;
    property mainNotes:               string                read FMainNotes               write FMainNotes;
    property partOfSpeech:            string                read FPartOfSpeech            write FPartOfSpeech;
    property senses:                  TObjectList<TLSense>  read FSenses                  write FSenses;
    property titleGenitive:           string                read FTitleGenitive           write FTitleGenitive;
    property titleOrthography:        string                read FTitleOrthography        write FTitleOrthography;

    constructor create;
    destructor destroy; override;
  end;

  TLSDictionaryLoader = class
  private
    class function getString(const vObj: TJSONObject; const vKey: string): string;
    class function processSense(const vJsonValue: TJSONValue): TLSense;
  public
    class function loadFromFile(const vFilePath: string): TObjectList<TLSEntry>;
  end;

  TTraverser = class
  public
    class function displaySenses(const aSenses: TObjectList<TLSense>; const aIndent: integer = 2): TVoid;
  end;

implementation

uses
  latin.consoleUtils;

constructor TLSense.create;
begin
  FChildren := TObjectList<TLSense>.create(TRUE);
end;

destructor TLSense.destroy;
begin
  FChildren.free;
  inherited destroy;
end;

constructor TLSEntry.create;
begin
  FSenses := TObjectList<TLSense>.create(TRUE);
end;

destructor TLSEntry.destroy;
begin
  FSenses.free;
  inherited destroy;
end;

class function TLSDictionaryLoader.getString(const vObj: TJSONObject; const vKey: string): string;
begin
  var vValue := vObj.values[vKey];
  case (vValue <> NIL) of
    TRUE: result := vValue.value;
    FALSE: result := '';
  end;
end;

class function TLSDictionaryLoader.processSense(const vJsonValue: TJSONValue): TLSense;
begin
  var vSense := TLSense.create;
  case (vJsonValue is TJSONString) of
    TRUE: vSense.value := vJsonValue.value;
    FALSE:
      case (vJsonValue is TJSONArray) of
        TRUE:
          for var vItem in vJsonValue as TJSONArray do vSense.children.add(processSense(vItem)); end;end;
  result := vSense;
end;

class function TLSDictionaryLoader.loadFromFile(const vFilePath: string): TObjectList<TLSEntry>;
begin
  var vResult := TObjectList<TLSEntry>.create(TRUE);
  var vRawContent := TFile.readAllText(vFilePath, TEncoding.utf8);
  var vJsonValue := TJSONArray.parseJSONValue(vRawContent);
  try
    case (vJsonValue is TJSONArray) of
      TRUE:
        for var vItem in vJsonValue as TJSONArray do
          case (vItem is TJSONObject) of
            TRUE:
              begin
                var vObj := vItem as TJSONObject;
                var vEntry := TLSEntry.create;
                vResult.add(vEntry);
                vEntry.alternativeGenitive    := getString(vObj, 'alternative_genative');
                vEntry.alternativeOrthography := getString(vObj, 'alternative_orthography');
                vEntry.declension             := getString(vObj, 'declension');
                vEntry.entryType              := getString(vObj, 'entry_type');
                vEntry.gender                 := getString(vObj, 'gender');
                vEntry.greekWord              := getString(vObj, 'greek_word');
                vEntry.key                    := getString(vObj, 'key');
                vEntry.mainNotes              := getString(vObj, 'main_notes');
                vEntry.partOfSpeech           := getString(vObj, 'part_of_speech');
                vEntry.titleGenitive          := getString(vObj, 'title_genitive');
                vEntry.titleOrthography       := getString(vObj, 'title_orthography');

                var vSensesVal                := vObj.values['senses'];
                case (vSensesVal is TJSONArray) of
                  TRUE:
                    for var vItemSense in vSensesVal as TJSONArray do vEntry.senses.add(processSense(vItemSense));
                end;
              end;
          end;
    end;
  finally
    vJsonValue.free;
  end;
  result := vResult;
end;

class function TTraverser.displaySenses(const aSenses: TObjectList<TLSense>; const aIndent: integer): TVoid;
begin
  case (aSenses <> NIL) of   TRUE:  for var i := 0 to aSenses.count - 1 do  begin
                                                  var vSense  := aSenses[i];
                                                  var vPrefix := stringOfChar(' ', aIndent * 2) + '[' + intToStr(i) + '] ';
                                                  case (vSense.value <> '') of   TRUE: writeUnicode(vPrefix + vSense.value);
                                                                                FALSE: writeUnicode(vPrefix); end;
                                                  displaySenses(vSense.children, aIndent + 2); end;end;
end;

//  case (vSenses <> NIL) of TRUE:
//      for var vSense in vSenses do begin
//        case (vSense.value <> '') of TRUE: writeLn(stringOfChar(' ', vIndent * 2) + vSense.value); end;
//        displaySenses(vSense.children, vIndent + 1);
//      end;
//  end;
//end;

end.

//interface
//
//uses
//  System.SysUtils,
//  System.Classes,
//  System.JSON,
//  System.IOUtils,
//  System.Generics.Collections;
//
//type
//  TVoid = (void);
//
//  TLSEntry = class
//  private
//    FDeclension:        string;
//    FEntryType:         string;
//    FGender:            string;
//    FKey:               string;
//    FMainNotes:         string;
//    FPartOfSpeech:      string;
//    FSenses:            TArray<string>;
//    FTitleGenitive:     string;
//    FTitleOrthography:  string;
//  public
//    property declension:        string          read FDeclension        write FDeclension;
//    property entryType:         string          read FEntryType         write FEntryType;
//    property gender:            string          read FGender            write FGender;
//    property key:               string          read FKey               write FKey;
//    property mainNotes:         string          read FMainNotes         write FMainNotes;
//    property partOfSpeech:      string          read FPartOfSpeech      write FPartOfSpeech;
//    property senses:            TArray<string>  read FSenses            write FSenses;
//    property titleGenitive:     string          read FTitleGenitive     write FTitleGenitive;
//    property titleOrthography:  string          read FTitleOrthography  write FTitleOrthography;
//  end;
//
//  TLSDictionaryLoader = class
//  private
//    class function getString(const vObj: TJSONObject; const vKey: string): string;
//    class function extractSenses(const vJsonValue: TJSONValue; const vSensesList: TList<string>): TVoid; static;
//  public
//    class function loadFromFile(const vFilePath: string): TObjectList<TLSEntry>;
//  end;
//
//implementation
//
//class function TLSDictionaryLoader.getString(const vObj: TJSONObject; const vKey: string): string;
//begin
//  var vValue := vObj.Values[vKey];
//  case (vValue <> nil) of
//    True: Result := vValue.Value;
//    False: Result := '';
//  end;
//end;
//
//class function TLSDictionaryLoader.extractSenses(const vJsonValue: TJSONValue; const vSensesList: TList<string>): TVoid;
//begin
//  case (vJsonValue is TJSONArray) of
//    TRUE:
//      begin
//        var vArray := vJsonValue as TJSONArray;
//        for var vItem in vArray do extractSenses(vItem, vSensesList); end;
//    FALSE:
//      case (vJsonValue is TJSONString) of
//        TRUE: vSensesList.add(vJsonValue.value); end;
//  end;
//end;
//
//class function TLSDictionaryLoader.loadFromFile(const vFilePath: string): TObjectList<TLSEntry>;
//begin
//  var vResult     := TObjectList<TLSEntry>.Create(True);
//  var vRawContent := TFile.ReadAllText(vFilePath, TEncoding.UTF8);
//  var vJsonValue  := TJSONArray.ParseJSONValue(vRawContent);
//  try
//    case (vJsonValue is TJSONArray) of
//      True:
//        begin
//          var vJsonArray := vJsonValue as TJSONArray;
//          for var vItem in vJsonArray do
//          begin
//            case (vItem is TJSONObject) of   TRUE:  begin
//                  var vObj                := vItem as TJSONObject;
//                  var vEntry              := TLSEntry.Create;
//                  vResult.add(vEntry);
//                  vEntry.declension       := getString(vObj, 'declension');
//                  vEntry.entryType        := getString(vObj, 'entry_type');
//                  vEntry.gender           := getString(vObj, 'gender');
//                  vEntry.key              := getString(vObj, 'key');
//                  vEntry.mainNotes        := getString(vObj, 'main_notes');
//                  vEntry.partOfSpeech     := getString(vObj, 'part_of_speech');
//                  vEntry.titleGenitive    := getString(vObj, 'title_genitive');
//                  vEntry.titleOrthography := getString(vObj, 'title_orthography');
//                  var vSensesVal          := vObj.Values['senses'];
//
//                  case (vSensesVal is TJSONArray) of   TRUE:  begin
//                                                                var vSensesArr := vSensesVal as TJSONArray;
//                                                                setLength(vEntry.FSenses, vSensesArr.count);
//                                                                for var vIdx := 0 to vSensesArr.count - 1 do vEntry.FSenses[vIdx] := vSensesArr.Items[vIdx].Value; end;
//                                                      FALSE: setLength(vEntry.FSenses, 0); end;end;
//            end;
//          end;
//        end;
//    end;
//  finally
//    vJsonValue.Free;
//  end;
//  Result := vResult;
//end;
//
//end.
