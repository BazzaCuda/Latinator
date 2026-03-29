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

unit latin.main;

interface

uses
  system.math, system.sysUtils, system.classes, system.generics.collections {for TDictionary},
  latin.LewisAndShort, latin.types;

type
  ILatin = interface
    function  LewisAndShort:    ILewisAndShort;
    function  loadDictionary    (const aFileName: string): TVoid;
    function  loadEsse          (const aFileName: string): TVoid;
    function  loadInflections   (const aFileName: string): TVoid;
    function  loadLewisAndShort (const aFileName: string): TVoid;
    function  loadPrefixes      (const aFileName: string): TVoid;
    function  loadSuffixes      (const aFileName: string): TVoid;
    function  loadTackOns       (const aFileName: string): TVoid;
    function  loadUniques       (const aFileName: string): TVoid;
    function  parse             (const aLine:     string): TArray<string>;
    function  setDataPath       (const aPath:     string): TVoid;
    function  unload:                                      TVoid;
  end;

function newLatin: ILatin;

implementation

uses
  system.strUtils,
  latin.charUtils, latin.consts, latin.fileUtils, latin.miscUtils, latin.stringUtils,
  _debugWindow;

type
  TLatin = class(TInterfacedObject, ILatin)
  strict private
    FDataPath:      string;
    FDictLines:     TArray<TDictLineRec>;
    FDictIx:        TDictionary<string, TArray<integer>>;
    FEsse:          TArray<TEsseRec>;
    FInflections:   TArray<TInflectionsRec>;
    FLewisAndShort: ILewisAndShort;
    FPrefixes:      TArray<TPrefixRec>;
    FSuffixes:      TArray<TSuffixRec>;
    FTackOns:       TArray<TTackOnRec>;
    FUniques:       TArray<TUniquesRec>;
  private
    function  equalLatin              (const aChar1: char;  const aChar2: char):  boolean; overload;
    function  equalLatin              (const aStr1: string; const aStr2: string): boolean; overload;

    function  formatParseResults  (const aParseResults:   TArray<TParseResultRec>): TArray<string>;

    function  findDictStems               (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  findInflections             (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  findPrefixes                (const aWord: string; const aPrefixRec: TPrefixRec):                                      TArray<TParseResultRec>;
    function  findPronominalInflections   (const aCore: string; const aStemType: TStemType; const aContext: TPronominalContext):    TArray<TParseResultRec>;
    function  findPronominalPackon        (const aCore: string):                                                                    TTackOnRec;
    function  findPronominalStem          (const aWord: string; var aPrefix: string; var aStemType: TStemType; var aCore: string):  boolean;

    function  mapInflectionToResult       (const aInflection: TInflectionsRec; var aResult: TParseResultRec):                       TVoid;

    function  parseDictStems              (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  parseEnclitics              (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseInflections            (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parsePrefixes               (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  parsePronominals            (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseRomanNumerals          (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseSuffixes               (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  parseUniques                (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseWord                   (const aWord: string; const aNextWord: string; var bNextUsed: boolean):                   TArray<TParseResultRec>;

    function  removeDuplicateResults      (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  removePrefix                (const aStem: string; const aPrefixRec: TPrefixRec):                                      string;
  public
    constructor Create;
    destructor  Destroy; override;

    function  LewisAndShort:    ILewisAndShort;
    function  loadDictionary    (const aFileName: string): TVoid;
    function  loadEsse          (const aFileName: string): TVoid;
    function  loadInflections   (const aFileName: string): TVoid;
    function  loadLewisAndShort (const aFileName: string): TVoid;
    function  loadPrefixes      (const aFileName: string): TVoid;
    function  loadSuffixes      (const aFileName: string): TVoid;
    function  loadTackOns       (const aFileName: string): TVoid;
    function  loadUniques       (const aFileName: string): TVoid;

    function  parse             (const aLine:     string): TArray<string>;
    function  setDataPath       (const aPath:     string): TVoid;
    function  unload:                                      TVoid;
  end;

function newLatin: ILatin;
begin
  result := TLatin.Create;
end;

{ TLatin }

constructor TLatin.Create;
begin
  inherited create;
  FDictIx := TDictionary<string, TArray<integer>>.create(50000); // less than the [currently-known] 48759 so we get an accurate entry count
end;

destructor TLatin.Destroy;
begin
  FDictIx.free;
  inherited;
end;

function TLatin.removeDuplicateResults(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
// DO NOT SORT!!!
begin
  result := NIL;
  for var vParseResult in aParseResults do begin
    var vIsDuplicate := FALSE;
    for var vUnique in result do begin
      case (vParseResult.prWord = vUnique.prWord)
           and (vParseResult.prPartOfSpeech = vUnique.prPartOfSpeech)
           and (vParseResult.prStem = vUnique.prStem)
           and (vParseResult.prEnding = vUnique.prEnding)
           and (vParseResult.prClass = vUnique.prClass)
           and (vParseResult.prVariant = vUnique.prVariant)
           and (vParseResult.prCase = vUnique.prCase)
           and (vParseResult.prNumber1 = vUnique.prNumber1)
           and (vParseResult.prGender = vUnique.prGender)
           and (vParseResult.prStemID = vUnique.prStemID)
           and (vParseResult.prNounType = vUnique.prNounType)
           and (vParseResult.prDegree = vUnique.prDegree)
           and (vParseResult.prPronounType = vUnique.prPronounType)
           and (vParseResult.prTense = vUnique.prTense)
           and (vParseResult.prVoice = vUnique.prVoice)
           and (vParseResult.prMood = vUnique.prMood)
           and (vParseResult.prPerson = vUnique.prPerson)
           and (vParseResult.prNumber2 = vUnique.prNumber2)
           and (vParseResult.prVerbType = vUnique.prVerbType)
           and (vParseResult.prAge = vUnique.prAge)
           and (vParseResult.prArea = vUnique.prArea)
           and (vParseResult.prGeography = vUnique.prGeography)
           and (vParseResult.prFrequency = vUnique.prFrequency)
           and (vParseResult.prSource = vUnique.prSource)
           and (vParseResult.prNumKind = vUnique.prNumKind)
           and (vParseResult.prNumValue = vUnique.prNumValue)
           and (vParseResult.prExplanation = vUnique.prExplanation) of TRUE: begin
        vIsDuplicate := TRUE;
        BREAK;
      end;end;
    end;
    case vIsDuplicate of FALSE: result := result + [vParseResult]; end;
  end;
end;

function TLatin.formatParseResults(const aParseResults: TArray<TParseResultRec>): TArray<string>;
const
  C_POS = 5;
  C_END = 10;
  C_FLG = 1;
begin
  result := NIL;
  var vUniqueResults := removeDuplicateResults(aParseResults);

  for var vParseResult in vUniqueResults do begin
    var vIxDelta: integer;
    case (trim(vParseResult.prExplanation) = '') of
      TRUE:  vIxDelta := 1;
      FALSE: vIxDelta := 2;
    end;

    expandArray(result, vIxDelta);

    result[length(result) - vIxDelta] := format(
      '%-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s', [
      MAX_STEM_SIZE, vParseResult.prWord,
      C_POS,         vParseResult.prPartOfSpeech,
      MAX_STEM_SIZE, vParseResult.prStem,
      C_END,         vParseResult.prEnding,
      C_FLG,         vParseResult.prClass,
      C_FLG,         vParseResult.prVariant,
      C_FLG,         vParseResult.prCase,
      C_FLG,         vParseResult.prNumber1,
      C_FLG,         vParseResult.prGender,
      C_FLG,         vParseResult.prStemID,
      C_FLG,         vParseResult.prNounType,
      C_FLG,         vParseResult.prDegree,
      C_FLG,         vParseResult.prPronounType,
      C_FLG,         vParseResult.prTense,
      C_FLG,         vParseResult.prVoice,
      C_FLG,         vParseResult.prMood,
      C_FLG,         vParseResult.prPerson,
      C_FLG,         vParseResult.prNumber2,
      C_FLG,         vParseResult.prVerbType,
      C_FLG,         vParseResult.prAge,
      C_FLG,         vParseResult.prArea,
      C_FLG,         vParseResult.prGeography,
      C_FLG,         vParseResult.prFrequency,
      C_FLG,         vParseResult.prSource,
      C_FLG,         vParseResult.prNumKind,
      C_FLG,         vParseResult.prNumValue
    ]);

    case (vIxDelta = 2) of TRUE: result[length(result) - 1] := vParseResult.prExplanation; end;
  end;
end;

//function TLatin.formatParseResults(const aParseResults: TArray<TParseResultRec>): TArray<string>;
//begin
//  // otherwise the Delphi compiler optimises all the calls in the "for var vWord in vWords" loop in TLatin.parse
//  // to use the same array reference pointer, and the result array will get duplicated on each call here!
//  result := NIL;
//
//  for var vParseResult in aParseResults do  begin
//                                              var vIxDelta: integer;
//
//                                              case trim(vParseResult.prExplanation) = '' of  TRUE: vIxDelta := 1;
//                                                                                            FALSE: vIxDelta := 2; end;
//
//                                              expandArray(result, vIxDelta);
//
//                                              result[length(result) - vIxDelta] := format('%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s',  [
//                                                                                                                    vParseResult.prWord   + #9#9,
//                                                                                                                    vParseResult.prPartOfSpeech,
//                                                                                                                    vParseResult.prStem   + #9,
//                                                                                                                    vParseResult.prEnding + #9,
//                                                                                                                    vParseResult.prClass,
//                                                                                                                    vParseResult.prVariant,
//                                                                                                                    vParseResult.prCase,
//                                                                                                                    vParseResult.prNumber1,
//                                                                                                                    vParseResult.prGender,
//                                                                                                                    vParseResult.prNounType,
//                                                                                                                    vParseResult.prDegree,
//                                                                                                                    vParseResult.prPronounType,
//                                                                                                                    vParseResult.prTense,
//                                                                                                                    vParseResult.prVoice,
//                                                                                                                    vParseResult.prMood,
//                                                                                                                    vParseResult.prPerson,
//                                                                                                                    vParseResult.prNumber2,
//                                                                                                                    vParseResult.prVerbType,
//                                                                                                                    vParseResult.prNumKind,
//                                                                                                                    vParseResult.prNumValue,
//                                                                                                                    vParseResult.prAge,
//                                                                                                                    vParseResult.prArea,
//                                                                                                                    vParseResult.prGeography,
//                                                                                                                    vParseResult.prFrequency,
//                                                                                                                    vParseResult.prSource
//                                                                                                                  ]);
//                                              case vIxDelta = 2 of TRUE: result[length(result) - 1] := vParseResult.prExplanation; end;end;
//end;

function TLatin.LewisAndShort: ILewisAndShort;
begin
  case FLewisAndShort = NIL of TRUE: FLewisAndshort := newLewisAndShort; end;
  result := FLewisAndShort;
end;

function TLatin.loadDictionary(const aFileName: string): TVoid;
begin
  FDictLines := latin.fileUtils.loadDictionary(FDataPath + aFileName, FDictIx);

  {$if BazDebugWindow}
  debugInteger('FDictLines', length(FDictLines));
  debugInteger('FDictIx', FDictIx.count);
  {$endif}
end;

function TLatin.loadEsse(const aFileName: string): TVoid;
begin
  FEsse := latin.fileUtils.loadEsse(FDataPath + aFileName);

  {$if BazDebugWindow}
  debugInteger('FEsse', length(FEsse));
  {$endif}
end;

function TLatin.loadInflections(const aFileName: string): TVoid;
begin
  FInflections := latin.fileUtils.loadInflections(FDataPath + aFileName);

  {$if BazDebugWindow}
  debugInteger('FInflections', length(FInflections));
  {$endif}
end;

function TLatin.loadLewisAndShort(const aFileName: string): TVoid;
begin
  LewisAndshort.loadLewisAndShort(FDataPath + aFileName); // call the LewisAndShort function - don't use FLewisAndShort!
end;

function TLatin.loadPrefixes(const aFileName: string): TVoid;
begin
  FPrefixes := latin.fileUtils.loadPrefixes(FDataPath + aFileName);

  {$if BazDebugWindow}
  debugInteger('FPrefixes', length(FPrefixes));
  {$endif}
end;

function TLatin.loadSuffixes(const aFileName: string): TVoid;
begin
  FSuffixes := latin.fileUtils.loadSuffixes(FDataPath + aFileName);

  {$if BazDebugWindow}
  debugInteger('FSuffixes', length(FSuffixes));
  {$endif}
end;

function TLatin.loadTackOns(const aFileName: string): TVoid;
begin
  FTackOns := latin.fileUtils.loadTackOns(FDataPath + aFileName);

  {$if BazDebugWindow}
  debugInteger('FTackOns', length(FTackOns));
  {$endif}
end;

function TLatin.loadUniques(const aFileName: string): TVoid;
begin
  FUniques := latin.fileUtils.loadUniques(FDataPath + aFileName);

  {$if BazDebugWindow}
  debugInteger('FUniques', length(FUniques));
  {$endif}
end;

//===== PARSING =====

function TLatin.equalLatin(const aChar1: char; const aChar2: char): boolean;
begin
  result := aChar1 = aChar2;

  case aChar1 of
    'u', 'v': result := (aChar2 = 'u') or (aChar2 = 'v');
    'i', 'j': result := (aChar2 = 'i') or (aChar2 = 'j');
  end;
end;

function TLatin.equalLatin(const aStr1: string; const aStr2: string): boolean;
begin
  case aStr1.length <> aStr2.length of TRUE: EXIT(FALSE); end;

  result := TRUE;
  for var i := 1 to aStr1.length do case equalLatin(aStr1[i], aStr2[i]) of FALSE: EXIT(FALSE); end;
end;

function TLatin.findDictStems(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
begin
  result := NIL;

  for var vParseResult in aParseResults do begin
    var vTrimmedStem := lowerCase(vParseResult.prStem.trim);
    var vIndices: TArray<integer>;

    case FDictIx.tryGetValue(vTrimmedStem, vIndices) of TRUE: begin
      for var vIx in vIndices do begin
        var vDictLine := FDictLines[vIx];
        var vDictStem := '';

        var vDictPOS := string(vDictLine.dictPartOfSpeech).trim;
        var vTargetPOS := vParseResult.prPartOfSpeech.trim;

        case vParseResult.prStemID of
          '1': vDictStem := string(vDictLine.dictStem1).trim;
          '2': begin
                 vDictStem := string(vDictLine.dictStem2).trim;
                 case (vDictStem = '') and (vDictPOS = 'V') or (vDictPOS = 'N') or (vDictPOS = 'ADJ') or (vDictPOS = 'NUM') of TRUE: vDictStem := string(vDictLine.dictStem1).trim; end;
               end;
          '3': vDictStem := string(vDictLine.dictStem3).trim;
          '4': vDictStem := string(vDictLine.dictStem4).trim;
        end;

        case (vDictStem <> vTrimmedStem) of TRUE: CONTINUE; end;

        case (vTargetPOS = 'VPAR') or (vTargetPOS = 'SUPI') of TRUE: vTargetPOS := 'V';     end;
        case (vTargetPOS = 'PACK')                          of TRUE: vTargetPOS := 'PRON';  end;
        case (vTargetPOS = 'ADJ') and (vDictPOS = 'NUM')    of TRUE: vTargetPOS := 'NUM';   end;

        case (vDictPOS = vTargetPOS)
          and ((vDictLine.dictClass   = vParseResult.prClass)   or (vDictLine.dictClass   = '0')  or (vParseResult.prClass    = '0'))
          and ((vDictLine.dictVariant = vParseResult.prVariant) or (vDictLine.dictVariant = '0')  or (vParseResult.prVariant  = '0')) of TRUE: begin

              var vResult := vParseResult;

              vResult.prAge         := vDictLine.dictAge;
              vResult.prArea        := vDictLine.dictArea;
              vResult.prGeography   := vDictLine.dictGeography;
              vResult.prFrequency   := vDictLine.dictFrequency;
              vResult.prSource      := vDictLine.dictSource;

              case (vDictPOS = 'N') of TRUE: begin
                vResult.prGender    := vDictLine.dictVNARec.dictNounGender;
                vResult.prNounType  := vDictLine.dictVNARec.dictNounType;
              end;end;

              case (vDictPOS = 'V')     of TRUE:  vResult.prVerbType    := string(vDictLine.dictVNARec.dictCaseType); end;
              case (vDictPOS = 'ADJ')   of TRUE:  vResult.prDegree      := string(vDictLine.dictVNARec.dictDegree);   end;
              case (vDictPOS = 'PREP')  of TRUE:  vResult.prCase        := string(vDictLine.dictVNARec.dictCaseType); end;
              case (vDictPOS = 'ADV')   of TRUE:  vResult.prDegree      := string(vDictLine.dictVNARec.dictCaseType); end;
              case (vDictPOS = 'PRON')  of TRUE:  vResult.prPronounType := string(vDictLine.dictVNARec.dictCaseType); end;
              case (vDictPOS = 'NUM')   of TRUE:  begin
                                                    vResult.prNumKind   := string(vDictLine.dictVNARec.dictNumKind);
                                                    vResult.prNumValue  := string(vDictline.dictVNARec.dictNumValue); end;end;

              vResult.prExplanation := string(vDictLine.dictTranslation);
              result := result + [vResult];
        end;end;
      end;
    end;end;
  end;
end;

function TLatin.findInflections(const aWord: string): TArray<TParseResultRec>;
begin
  result := NIL;

  for var vInflection in FInflections do begin
    var vSuffix := string(vInflection.irSuffix).trim;
    var vStem   := '';

    case (vSuffix = '') of   TRUE:  vStem := aWord;
                            FALSE:  case aWord.endsWith(vSuffix) of TRUE: vStem := aWord.substring(0, aWord.length - vSuffix.length); end;end;

    case (vStem <> '') and (vStem.length <= MAX_STEM_SIZE) of TRUE: begin
      var vResult       := default(TParseResultRec);
      vResult.prWord    := aWord;
      vResult.prStem    := vStem;
      vResult.prEnding  := string(vInflection.irSuffix);
      vResult.prStemID  := vInflection.irStemID;

      if (vResult.prEnding.trim = 'it') then
        debugString('Suffix -it found with StemID', '[' + vResult.prStemID + ']');

      mapInflectionToResult(vInflection, vResult);

      result := result + [vResult];
    end; end;
  end;
end;

function TLatin.findPrefixes(const aWord: string; const aPrefixRec: TPrefixRec): TArray<TParseResultRec>;
begin
  result := NIL;
  var vCore := removePrefix(aWord, aPrefixRec);
  case (vCore = aWord) of TRUE: EXIT; end;

  var vResultRecs := findInflections(vCore);
  var vPrefixTargetPOS := string(aPrefixRec.prTargetPartOfSpeech).trim;

  for var vResultRec in vResultRecs do begin
    var vPrefixCandidate := vResultRec;
    case (vPrefixTargetPOS <> 'X') of TRUE: vPrefixCandidate.prPartOfSpeech := vPrefixTargetPOS; end;

    result := result + findDictStems([vPrefixCandidate]);
  end;
end;

function TLatin.findPronominalPackon(const aCore: string): TTackOnRec;
begin
  fillChar(result, sizeOf(result), 0);
  for var vTackOn in FTackOns do begin
    var vTargetPartOfSpeech := string(vTackOn.trTargetPartOfSpeech).trim;
    var vTackOnString := string(vTackOn.trTackOn).trim;

    case (vTargetPartOfSpeech = 'PACK') and aCore.endsWith(vTackOnString) of
      TRUE: EXIT(vTackOn);
    end;
  end;
end;

function TLatin.findPronominalInflections(const aCore: string; const aStemType: TStemType; const aContext: TPronominalContext): TArray<TParseResultRec>;
const
  PRON_POS       = 'PRON';
  PRON_CLASS     = '1';
  STEM_ID_QU     = '1';
  STEM_ID_CU     = '2';
  STEM_STRING_QU = 'qu';
  STEM_STRING_CU = 'cu';
begin
  result          := NIL;
  var vStemString := '';
  var vTargetID   := #0;

  case aStemType of
    stQu:   begin vStemString := STEM_STRING_QU; vTargetID := STEM_ID_QU; end;
    stCu:   begin vStemString := STEM_STRING_CU; vTargetID := STEM_ID_CU; end;
    stNone: EXIT;
  end;

  for var vInflection in FInflections do begin
    var vInflectionPartOfSpeech := string(vInflection.irPartOfSpeech).trim;
    case (vInflectionPartOfSpeech = PRON_POS) and (vInflection.irClass = PRON_CLASS) and (vInflection.irStemID = vTargetID) of TRUE: begin
      var vEnding := string(vInflection.irSuffix).trim;
      case aCore = (vStemString + vEnding) of TRUE: begin
        var vParseResult: TParseResultRec;
        vParseResult.prWord         := aContext.pcFullWord;
        vParseResult.prPartOfSpeech := string(vInflection.irPartOfSpeech);;
        vParseResult.prClass        := vInflection.irClass;
        vParseResult.prVariant      := vInflection.irVariant;
        vParseResult.prStem         := vStemString;
        vParseResult.prEnding       := string(vInflection.irSuffix);
        vParseResult.prCase         := string(vInflection.irCase);
        vParseResult.prNumber1      := vInflection.irNumber1;
        vParseResult.prGender       := vInflection.irGender;
        vParseResult.prAge          := vInflection.irAge;
        vParseResult.prFrequency    := vInflection.irFrequency;

        var vExplanation := 'Pronominal: ';
        case (aContext.pcPrefix <> '') of TRUE: vExplanation := vExplanation + '[' + aContext.pcPrefix + '-] + '; end;

        vExplanation := vExplanation + '[' + vParseResult.prStem + '] + [-' + vParseResult.prEnding + ']';

        case (aContext.pcTackOn <> '') of TRUE: vExplanation := vExplanation + ' + [-' + aContext.pcTackOn + '] (' + aContext.prSenses + ')'; end;

        vParseResult.prExplanation := vExplanation;
        result := result + [vParseResult];
      end; end; end; end; end;
end;

function TLatin.findPronominalStem(const aWord: string; var aPrefix: string; var aStemType: TStemType; var aCore: string): boolean;
begin
  result := FALSE;
  for var vMap in PRONOMINAL_MAPS do
  begin
    case aWord.startsWith(vMap.pmSearchString) of
      TRUE: begin
        aPrefix   := vMap.pmPrefix;
        aStemType := vMap.pmStemType;
        aCore     := aWord.substring(length(aPrefix));
        EXIT(TRUE);
      end;
    end;
  end;
end;

function TLatin.mapInflectionToResult(const aInflection: TInflectionsRec; var aResult: TParseResultRec): TVoid;
begin
  aResult.prPartOfSpeech  := string(aInflection.irPartOfSpeech);
  aResult.prClass         := aInflection.irClass;
  aResult.prVariant       := aInflection.irVariant;
  aResult.prCase          := string(aInflection.irCase);
  aResult.prNumber1       := aInflection.irNumber1;
  aResult.prGender        := aInflection.irGender;

  var vPOS := trim(aResult.prPartOfSpeech);

  aResult.prDegree  := '';
  aResult.prTense   := '';

  case (vPOS = 'ADJ') or (vPOS = 'ADV') or (vPOS = 'NUM') of TRUE: aResult.prDegree := string(aInflection.irDegreeTense); end;
  case (vPOS = 'V')   or (vPOS = 'VPAR')                  of TRUE: aResult.prTense  := string(aInflection.irDegreeTense); end;

  aResult.prVoice         := string(aInflection.irVoice);
  aResult.prMood          := string(aInflection.irMood);
  aResult.prPerson        := aInflection.irPerson;
  aResult.prNumber2       := aInflection.irNumber2;

  aResult.prAge           := aInflection.irAge;
  aResult.prFrequency     := aInflection.irFrequency;
end;

function TLatin.parse(const aLine: string): TArray<string>;
begin
//  var vLine       := lowerCase(aLine);
//      vLine       := removeMacrons(vLine);
//      vLine       := vLine.replace('v', 'u').replace('j', 'i');
  result          := NIL;
  var vLine       := cleanSentences   (aLine);
  var vSentences  := extractSentences (vLine);
  var i           := -1;
  var vNextUsed   := FALSE;

  for var vSentence in vSentences do  begin
                                        var vWords := vSentence.split([' '], TStringSplitOptions.ExcludeEmpty);

                                        for var vWord in vWords do  begin
                                                                      inc(i);

                                                                      case vNextUsed of TRUE: begin
                                                                                                vNextUsed := FALSE;
                                                                                                CONTINUE; end;end;

                                                                      var vNextWord := '';
                                                                      case i < length(vWords) of   TRUE: vNextWord := vWords[i]; end;

                                                                      result := result + formatParseResults(parseRomanNumerals(vWord));
                                                                      result := result + formatParseResults(parseWord(vWord, vNextWord, vNextUsed));

                                                                      expandArray(result);
                                                                      result[high(result)] := ''; end;end;
end;

function TLatin.parseDictStems(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
begin
  result := findDictStems(aParseResults);
end;

function TLatin.parsePrefixes(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;

  function matchConnector(const aWord: string; const aPrefix: string; const aConnector: char): boolean;
  begin
    result := FALSE;
    var vPrefixLength := aPrefix.length;
    case aWord.length > aPrefix.length of FALSE: EXIT(FALSE); end;

    case equalLatin(aWord.substring(0, vPrefixLength), aPrefix) of TRUE: result := (aConnector = ' ') or (aWord[vPrefixLength + 1] = aConnector); end;
  end;

begin
  result := NIL;

  for var vPrefixRec in FPrefixes do begin
    var vPrefix := string(vPrefixRec.prPrefix).trim;
    var vConnector := vPrefixRec.prConnector;

    for var vParseResult in aParseResults do begin
      case matchConnector(vParseResult.prStem.trim, vPrefix, vConnector) of FALSE: CONTINUE; end;

      var vResult := vParseResult;
      vResult.prStem := vParseResult.prStem.trim.substring(vPrefix.length).trim;

      var vTargetPOS := string(vPrefixRec.prTargetPartOfSpeech).trim;
      case (vTargetPOS <> 'X') of TRUE: vResult.prPartOfSpeech := vTargetPOS; end;

      var vDictResults := parseDictStems([vResult]);

      case length(vDictResults) > 0 of TRUE: begin
        var vPrefixResult := default(TParseResultRec);
        vPrefixResult.prWord := vParseResult.prWord;
        vPrefixResult.prStem := vPrefix;
        vPrefixResult.prExplanation := string(vPrefixRec.prSenses);

        result := [vPrefixResult] + vDictResults;
        EXIT;
      end;end;
    end;
  end;
end;

function TLatin.parsePronominals(const aWord: string): TArray<TParseResultRec>;

  function identifyPronominalStem(var vCore: string): TStemType;
  begin
    result := stNone;
    case vCore.startsWith('qu') of TRUE: result := stQu; end;
    case vCore.startsWith('cu') of TRUE: result := stCu; end;
  end;

  function restorePronominalM(const aStrippedCore: string; const aTackOn: string): string;
  begin
    result := aStrippedCore;
    case aTackOn.startsWith('dam') and (result[result.length] = 'n') of TRUE: result[result.length] := 'm'; end;
  end;

  function stripPronominalPackon(const aCore: string; const aTackOn: string): string;
  begin
    result := aCore.substring(0, aCore.length - aTackOn.length);
  end;

  function findPronominal(const aCore: string; const aPrefix: string; const aPrefixSenses: string): TArray<TParseResultRec>;
  begin
    result         := NIL;
    var vLocalCore := aCore;
    var vStemType  := identifyPronominalStem(vLocalCore);

    case (vStemType = stNone) of TRUE: EXIT; end;

    var vTackOnRec := findPronominalPackon(vLocalCore);
    var vTackOn    := string(vTackOnRec.trTackOn).trim;
    var vContext   :  TPronominalContext;

    vContext.pcFullWord := aWord;
    vContext.pcPrefix   := aPrefix;
    vContext.pcTackOn   := string(vTackOnRec.trTackOn);
    vContext.prSenses   := string(vTackOnRec.trSenses);

    var vInflections := findPronominalInflections(vLocalCore, vStemType, vContext);

    case (length(vInflections) = 0) and (vTackOn <> '') of TRUE: begin
      var vStripped := stripPronominalPackon(vLocalCore, vTackOn);
      vInflections  := findPronominalInflections(restorePronominalM(vStripped, vTackOn), vStemType, vContext);
    end; end;

    case (length(vInflections) > 0) of TRUE: begin
      case (aPrefix <> '') of TRUE: begin
        var vPrefixEntry : TParseResultRec;
        vPrefixEntry.prWord        := aWord;
        vPrefixEntry.prStem        := aPrefix;
        vPrefixEntry.prExplanation := aPrefixSenses;
        result                     := result + [vPrefixEntry];
      end; end;

      result := result + vInflections;

      case (vTackOn <> '') of TRUE: begin
        var vTackonEntry              :  TParseResultRec;
        vTackonEntry.prWord           := aWord;
        vTackonEntry.prStem           := string(vTackOnRec.trTackOn);
        vTackonEntry.prPartOfSpeech   := string(vTackOnRec.trTargetPartOfSpeech);
        vTackonEntry.prClass          := vTackOnRec.trTargetClass;
        vTackonEntry.prVariant        := vTackOnRec.trTargetVariant;
        vTackonEntry.prExplanation    := vContext.prSenses;
        result                        := result + [vTackonEntry];
      end; end;
    end; end;
  end;

begin
  result := NIL;

  for var vPrefixRec in FPrefixes do begin
    case (string(vPrefixRec.prSourcePartOfSpeech).trim = 'PACK') of TRUE: begin
      var vPrefix := string(vPrefixRec.prPrefix).trim;
      case aWord.startsWith(vPrefix) of TRUE: begin
        var vSenses := string(vPrefixRec.prSenses).trim;
        result := result + findPronominal(aWord.substring(vPrefix.length), vPrefix, vSenses);
        case (length(result) > 0) of TRUE: EXIT; end;
      end; end;
    end; end;
  end;

  case (length(result) = 0) of TRUE: result := findPronominal(aWord, '', ''); end;
end;
function TLatin.parseRomanNumerals(const aWord: string): TArray<TParseResultRec>;
begin
  result := NIL;
  // overkill (see comment in parseWord) but pre-empting any possible future bugs

  var vWord := lowercase(removeMacrons(aWord));
  case romanNumerals(vWord) of FALSE: EXIT; end;

  expandArray(result);

  result[0].prWord          := aWord;
  result[0].prPartOfSpeech  := 'NUM';
  result[0].prClass         := '2';
  result[0].prVariant       := '0';
  result[0].prCase          := 'X';
  result[0].prNumber1       := 'X';
  result[0].prGender        := 'X';
  result[0].prNumValue      := intToStr(romanNumeralsToInt(vWord));
  result[0].prNumKind       := 'CARD';
  result[0].prAge           := 'X';
  result[0].prFrequency     := 'A';
  result[0].prExplanation   := format('%s as a ROMAN NUMERAL;', [result[0].prNumValue]);
end;

function TLatin.parseSuffixes(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
begin
  result := NIL;
end;

function TLatin.parseWord(const aWord: string; const aNextWord: string; var bNextUsed: boolean): TArray<TParseResultRec>;
begin
  result := NIL;
  // otherwise the Delphi compiler optimises the following calls to
  // use the same array reference pointer as the result in the functions themselves(!)
  // and the result array here will keep getting duplicated each time!

  result := result + parseUniques(aWord);
  result := result + parsePronominals(aWord);

  var vInflectionRecs := parseInflections(aWord);
  debugInteger('vInflectionRecs', length(vInflectionRecs));
  result := result + parseDictStems(vInflectionRecs);

  case length(result) = 0 of TRUE: result := result + parsePrefixes(vInflectionRecs); end;
  case length(result) = 0 of TRUE: result := result + parseSuffixes(vInflectionRecs); end;

  case length(result) = 0 of TRUE: result := result + parseEnclitics(aWord); end;
end;

function TLatin.parseUniques(const aWord: string): TArray<TParseResultRec>;
begin
  result := NIL;
  // overkill (see comment in parseWord) but pre-empting any possible future bugs

  var vWord := lowerCase(removeMacrons(aWord));

  for var vUnique in FUniques do
    case trim(vUnique.urWord) = vWord of TRUE:  begin
                                                  expandArray(result);
                                                  result[0].prWord            := aWord;
                                                  result[0].prPartOfSpeech    := vUnique.urPartOfSpeech;
                                                  result[0].prClass           := vUnique.urClass;
                                                  result[0].prVariant         := vUnique.urVariant;
                                                  result[0].prCase            := vUnique.urCase;
                                                  result[0].prNumber1         := vUnique.urNumber1;
                                                  result[0].prGender          := vUnique.urNounGender;
                                                  result[0].prNounType        := vUnique.urNounType;
                                                  result[0].prDegree          := vUnique.urDegree;
                                                  result[0].prPronounType     := vUnique.urPronounType;
                                                  result[0].prTense           := vUnique.urTense;
                                                  result[0].prVoice           := vUnique.urVoice;
                                                  result[0].prMood            := vUnique.urMood;
                                                  result[0].prPerson          := vUnique.urPerson;
                                                  result[0].prNumber2         := vUnique.urNumber2;
                                                  result[0].prVerbType        := vUnique.urVerbType;
                                                  result[0].prAge             := vUnique.urAge;
                                                  result[0].prArea            := vUnique.urArea;
                                                  result[0].prGeography       := vUnique.urGeography;
                                                  result[0].prFrequency       := vUnique.urFrequency;
                                                  result[0].prSource          := vUnique.urSource;
                                                  result[0].prExplanation     := vUnique.urTranslation;
                                                  BREAK; end;end;
end;

function TLatin.removePrefix(const aStem: string; const aPrefixRec: TPrefixRec): string;
begin
  var vStem := aStem.trim;
  var vPrefix := string(aPrefixRec.prPrefix).trim;
  var vPrefixLen := vPrefix.length;

  result := vStem;

  case (vStem.length > vPrefixLen) and equalLatin(vStem.substring(0, vPrefixLen), vPrefix) of TRUE: begin
    var vConnector := aPrefixRec.prConnector;

    case (vConnector = ' ') or (vStem[vPrefixLen + 1] = vConnector) of TRUE: begin
      result := vStem.substring(vPrefixLen).trim;
    end;end;
  end;end;
end;

function TLatin.setDataPath(const aPath: string): TVoid;
begin
  FDataPath := aPath;
end;

function TLatin.unload: TVoid;
begin
  FLewisAndShort := NIL;
end;

function TLatin.parseEnclitics(const aWord: string): TArray<TParseResultRec>;
begin
  result := NIL;
//  var vWord := cleanVJJ(lowerCase(removeMacrons(aWord)));
  var vWord := lowerCase(removeMacrons(aWord));

  for var vTackOn in FTackOns do begin
//    var vEnding := cleanVJJ(string(vTackOn.trTackOn).trim);
    var vEnding := string(vTackOn.trTackOn).trim;

    var vEnclitic := FALSE;
    for var vEncliticString in ENCLITIC_TACKONS do
      case (vEncliticString = vEnding) of TRUE: begin vEnclitic := TRUE; BREAK; end;end;

    case vEnclitic of TRUE: begin
      case (vWord.length > vEnding.length) and (vWord.endsWith(vEnding)) of TRUE: begin
        var vStem := vWord.substring(0, vWord.length - vEnding.length);

        case (vEnding = 'que') and (vStem.length < 2) of TRUE: CONTINUE; end;

        var vNextUsed := FALSE;
        result := result + parseWord(vStem, '', vNextUsed);

        case (length(result) > 0) of TRUE: begin
          var vEncliticRec            := default(TParseResultRec);
          vEncliticRec.prWord         := string(vTackOn.trTackOn);
          vEncliticRec.prPartOfSpeech := string(vTackOn.trTargetPartOfSpeech);
          vEncliticRec.prClass        := vTackOn.trTargetClass;
          vEncliticRec.prVariant      := vTackOn.trTargetVariant;
          vEncliticRec.prDegree       := string(vTackOn.trDegree);
          vEncliticRec.prGender       := vTackOn.trNounGender;
          vEncliticRec.prNumber1      := vTackOn.trNounNumber;
          vEncliticRec.prExplanation  := vTackOn.trSenses;

          result := result + [vEncliticRec];
          EXIT;
        end;end;
      end;end;
    end;end;
  end;
end;

function TLatin.parseInflections(const aWord: string): TArray<TParseResultRec>;
begin
  result := findInflections(aWord);
end;

end.
