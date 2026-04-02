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
    function  parse             (const aConsoleCommand: TConsoleCommand; const aLine: string): TArray<string>;
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
    FNounData:      TNounData;
    FVerbData:      TVerbData;
    FPrefixes:      TArray<TPrefixRec>;
    FSuffixes:      TArray<TSuffixRec>;
    FTackOns:       TArray<TTackOnRec>;
    FUniques:       TArray<TUniquesRec>;
  private
    function  conjugateVerb               (const aWord: string; var aDictionaryEntry: string):                                      TGrammarTable;
    function  declineNoun                 (const aWord: string; var aDictionaryEntry: string):                                      TGrammarTable;

    function  equalLatin                  (const aChar1: char;  const aChar2: char):  boolean; overload;
    function  equalLatin                  (const aStr1: string; const aStr2: string): boolean; overload;

    function  formatParseResults          (const aParseResults: TArray<TParseResultRec>):                                           TArray<string>;
    function  formatGrammarResults        (const aGrammarResult: TGrammarTable):                                                    TArray<string>;

    function  removeDuplicateResults      (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  trimParseResults            (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;

    function  findDictStems               (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  findInflections             (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  findPrefixes                (const aWord: string; const aPrefixRec: TPrefixRec):                                      TArray<TParseResultRec>;
    function  findPronominalInflections   (const aCore: string; const aStemType: TStemType; const aContext: TPronominalContext):    TArray<TParseResultRec>;
    function  findPronominalPackon        (const aCore: string):                                                                    TTackOnRec;
    function  findPronominalStem          (const aWord: string; var aPrefix: string; var aStemType: TStemType; var aCore: string):  boolean;

    function  getParseContext             (const aPC: TParseContext):                                                               TParseContext;

    function  mapInflectionToResult       (const aInflection: TInflectionsRec; var aResult: TParseResultRec):                       TVoid;

    function  parseCompounds              (const aParseResults: TArray<TParseResultRec>; var aParseContext: TParseContext):         TArray<TParseResultRec>;
    function  parseDictStems              (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  parseEsse                   (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseInflections            (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parsePrefixes               (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  parsePronominals            (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseRomanNumerals          (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseSuffixes               (const aParseResults: TArray<TParseResultRec>):                                           TArray<TParseResultRec>;
    function  parseTackOns                (const aWord: string; var aPC: TParseContext):                                            TArray<TParseResultRec>;
    function  parseTricks                 (const aWord: string; var aPC: TParseContext):                                            TArray<TParseResultRec>;
    function  parseUniques                (const aWord: string):                                                                    TArray<TParseResultRec>;
    function  parseWord                   (const aWord: string; var aPC: TParseContext; const bTricks: boolean = FALSE):            TArray<TParseResultRec>;

    function  removePrefix                (const aStem: string; const aPrefix: string; const aConnector: char):                     string;
    function  restoreStemM                (const aCore: string; const aTackOn: string):                                             string;

    function  siphonNounData:                                                                                                       TNounData;
    function  siphonVerbData:                                                                                                       TVerbData;

    function  tryTrick                    (const aWord: string; const aModified: string; const aNote: string; var aPC: TParseContext):
                                                                                                                                    TArray<TParseResultRec>;
    function mapCaseToCase                (const aCase:     string):                                                                TNounCase;
    function mapClassToClass              (const aClass:    char):                                                                  TClassClass;
    function mapGenderToGender            (const aGender:   char):                                                                  TNounGender;
    function mapMoodToMood                (const aMood:     string):                                                                TVerbMood;
    function mapNumberToNumber            (const aNumber:   char):                                                                  TVerbNumber;
    function mapPersonToPerson            (const aPerson:   char):                                                                  TVerbPerson;
    function mapTenseToTense              (const aTense:    string):                                                                TVerbTense;
    function mapVariantToVariant          (const aVariant:  char):                                                                  TClassVariant;
    function mapVoiceToVoice              (const aVoice:    string):                                                                TVerbVoice;

    function nounDeclension               (const aContext:  TNounContext; var aDictionaryEntry: string):                            TGrammarTable;
    function verbConjugation              (const aContext:  TVerbContext; var aDictionaryEntry: string):                            TGrammarTable;
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

    function  parse             (const aConsoleCommand: TConsoleCommand; const aLine: string):                                      TArray<string>;
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

function TLatin.getParseContext(const aPC: TParseContext): TParseContext;
begin
  result.pcConsoleCommand := aPC.pcConsoleCommand;
  result.pcNextWord       := aPC.pcNextWord;
  result.pcNextUsed       := aPC.pcNextUsed;
  result.pcTricks         := USER_TRICKS;
end;

//===== FORMATTING THE OUTPUT ====

function TLatin.removeDuplicateResults(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
// DO NOT SORT!!!
// This function must remain dumb and oblivious of what it is doing and why
begin
  result := NIL;
  for var vParseResult in aParseResults do begin
    var vDuplicate := FALSE;
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
        vDuplicate := TRUE;
        BREAK;
      end;end;
    end;
    case vDuplicate of FALSE: result := result + [vParseResult]; end;
  end;
end;

function TLatin.formatGrammarResults(const aGrammarResult: TGrammarTable): TArray<string>;
const
  WIDTH_LABEL = 10;
  WIDTH_CELL  = 16;
  COL_FIRST   =  1;
  COL_LAST    =  3;
begin
  result := NIL;

  for var vRow := ncNone to ncLocative do begin
    case (aGrammarResult[vRow][0] = '') of TRUE: CONTINUE; end;

    var vLine := '| ' + format('%-*s', [WIDTH_LABEL, aGrammarResult[vRow][0]]);
    for var vCol := COL_FIRST to COL_LAST do begin
      case (aGrammarResult[ncNone][vCol] = '') of TRUE: BREAK; end;
      vLine := vLine + ' | ' + format('%-*s', [WIDTH_CELL, aGrammarResult[vRow][vCol]]);
    end;

    vLine := vLine + ' |';
    result := result + [vLine];

    case (vRow = ncNone) of TRUE: result := result + [stringOfChar('-', vLine.length)]; end;
  end;
  result := result + [''];
end;

function TLatin.formatParseResults(const aParseResults: TArray<TParseResultRec>): TArray<string>;
const
  WIDTH_POS       =  6;  // Matches dictPartOfSpeech: array[1..6]
  WIDTH_ENDING    = 11;  // Matches irSuffix:         array[1..11]
  WIDTH_FLAG      =  1;  // Matches char fields
  WIDTH_CASE      =  3;  // Matches irCase:           array[1..3]
  WIDTH_DEGREE    =  8;  // Matches dictDegree:       array[1..8]
  WIDTH_PRON      =  6;  // Matches urPronounType:    array[1..6]
  WIDTH_TENSE     =  5;  // Matches irDegreeTense:    array[1..5]
  WIDTH_VOICE     =  7;  // Matches irVoice:          array[1..7]
  WIDTH_MOOD      =  3;  // Matches irMood:           array[1..3]
  WIDTH_VTYPE     =  8;  // Matches urVerbType:       array[1..8]
  WIDTH_NUMKIND   =  4;  // Matches dictNumKind:      array[1..4]
  WIDTH_NUMVAL    =  8;  // Matches dictNumValue:     array[1..8]
begin
  result := NIL;
  var vUniqueResults := removeDuplicateResults(trimParseResults(aParseResults));

  for var vParseResult in vUniqueResults do begin
    var vIxDelta: integer;
    case (trim(vParseResult.prExplanation) = '') of
      TRUE:  vIxDelta := 1;
      FALSE: vIxDelta := 2;
    end;

    expandArray(result, vIxDelta);

    result[length(result) - vIxDelta] := format(
      '%-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s %-*s', [
      MAX_STEM,       vParseResult.prWord,
      WIDTH_POS,      vParseResult.prPartOfSpeech,
      MAX_STEM,       vParseResult.prStem,
      WIDTH_ENDING,   vParseResult.prEnding,
      WIDTH_FLAG,     vParseResult.prClass,
      WIDTH_FLAG,     vParseResult.prVariant,
      WIDTH_CASE,     vParseResult.prCase,
      WIDTH_FLAG,     vParseResult.prNumber1,
      WIDTH_FLAG,     vParseResult.prGender,
      WIDTH_FLAG,     vParseResult.prStemID,
      WIDTH_FLAG,     vParseResult.prNounType,
      WIDTH_DEGREE,   vParseResult.prDegree,
      WIDTH_PRON,     vParseResult.prPronounType,
      WIDTH_TENSE,    vParseResult.prTense,
      WIDTH_VOICE,    vParseResult.prVoice,
      WIDTH_MOOD,     vParseResult.prMood,
      WIDTH_FLAG,     vParseResult.prPerson,
      WIDTH_FLAG,     vParseResult.prNumber2,
      WIDTH_VTYPE,    vParseResult.prVerbType,
      WIDTH_FLAG,     vParseResult.prAge,
      WIDTH_FLAG,     vParseResult.prArea,
      WIDTH_FLAG,     vParseResult.prGeography,
      WIDTH_FLAG,     vParseResult.prFrequency,
      WIDTH_FLAG,     vParseResult.prSource,
      WIDTH_NUMKIND,  vParseResult.prNumKind,
      WIDTH_NUMVAL,   vParseResult.prNumValue
    ]);

    case (vIxDelta = 2) of TRUE: result[length(result) - 1] := vParseResult.prExplanation; end;

    expandArray(result);
    result[high(result)] := format('stem1: %s, stem2: %s, stem3: %s, stem4: %s', [trim(vParseResult.prStem1), trim(vParseResult.prStem2), trim(vParseResult.prStem3), trim(vParseResult.prStem4)]);
  end;
end;

function TLatin.trimParseResults(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
begin
  result := aParseResults;
  for var i := 0 to high(result) do begin
    result[i].prWord          := result[i].prWord.trim;
    result[i].prPartOfSpeech  := result[i].prPartOfSpeech.trim;
    result[i].prStem          := result[i].prStem.trim;
    result[i].prEnding        := result[i].prEnding.trim;
    result[i].prCase          := result[i].prCase.trim;
    result[i].prDegree        := result[i].prDegree.trim;
    result[i].prPronounType   := result[i].prPronounType.trim;
    result[i].prTense         := result[i].prTense.trim;
    result[i].prVoice         := result[i].prVoice.trim;
    result[i].prMood          := result[i].prMood.trim;
    result[i].prVerbType      := result[i].prVerbType.trim;
    result[i].prNumKind       := result[i].prNumKind.trim;
    result[i].prNumValue      := result[i].prNumValue.trim;
    result[i].prExplanation   := result[i].prExplanation.trim;
  end;
end;

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
  FInflections  := latin.fileUtils.loadInflections(FDataPath + aFileName);
  FNounData     := siphonNounData;
  FVerbData     := siphonVerbData;
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

//===== PARSING ETC =====


function TLatin.conjugateVerb(const aWord: string; var aDictionaryEntry: string): TGrammarTable;
  function filterResults(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
  begin
    result := NIL;
    for var vParseResult in aParseResults do begin
      case (trim(vParseResult.prPartOfSpeech) <> 'V') of TRUE: CONTINUE; end;

      var vUnique := TRUE;
      for var vResult in result do begin
        vUnique := (vParseResult.prStem1   <> vResult.prStem1)
                or (vParseResult.prStem2   <> vResult.prStem2)
                or (vParseResult.prStem3   <> vResult.prStem3)
                or (vParseResult.prStem4   <> vResult.prStem4)
                or (vParseResult.prClass   <> vResult.prClass)
                or (vParseResult.prVariant <> vResult.prVariant);
        case vUnique of FALSE: BREAK; end;
      end;

      case vUnique of TRUE: result := result + [vParseResult]; end;
    end;
  end;

  function findCandidates(const aWord: string): TArray<TParseResultRec>;
  begin
    result := NIL;
    result := result + parseUniques(aWord);
    result := result + parseEsse(aWord);

    var vInflectionRecs := parseInflections(aWord);
    result := result + parseDictStems(vInflectionRecs);
  end;
begin
  var vVerbResults := filterResults(findCandidates(aWord));
  case length(vVerbResults) = 0 of TRUE: EXIT; end;

  var vResult  := vVerbResults[0];
  var vContext := default(TVerbContext);

  vContext.vcClass   := mapClassToClass(vResult.prClass);
  vContext.vcVariant := mapVariantToVariant(vResult.prVariant);
  vContext.vcStem1   := vResult.prStem1;
  vContext.vcStem2   := vResult.prStem2;
  vContext.vcStem3   := vResult.prStem3;
  vContext.vcStem4   := vResult.prStem4;

  vContext.vcTense   := mapTenseToTense(trim(vResult.prTense));
  vContext.vcVoice   := mapVoiceToVoice(trim(vResult.prVoice));
  vContext.vcMood    := mapMoodToMood(trim(vResult.prMood));

  result := verbConjugation(vContext, aDictionaryEntry);
end;


function TLatin.declineNoun(const aWord: string; var aDictionaryEntry: string): TGrammarTable;
  function filterResults(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
  begin
    result := NIL;
    for var vParseResult in aParseResults do begin
      case (trim(vParseResult.prPartOfSpeech) <> 'N') of TRUE: CONTINUE; end;

      var vUnique := TRUE;
      for var vResult in result do  begin
                                      vUnique := (vParseResult.prStem1   <> vResult.prStem1)
                                              or (vParseResult.prStem2   <> vResult.prStem2)
                                              or (vParseResult.prClass   <> vResult.prClass)
                                              or (vParseResult.prVariant <> vResult.prVariant);
        case vUnique of FALSE: BREAK; end;
      end;

      case vUnique of TRUE: result := result + [vParseResult]; end;
    end;
  end;

  function findCandidates(const aWord: string): TArray<TParseResultRec>;
  begin
    result := NIL;

    result := result + parseUniques(aWord);
    result := result + parsePronominals(aWord);

    var vInflectionRecs := parseInflections(aWord);
    result := result + parseDictStems(vInflectionRecs);
  end;
begin

  var FNounResults := filterResults(findCandidates(aWord));
  case length(FNounResults) = 0 of TRUE: EXIT; end;

  var vResult  := FNounResults[0];
  for var vCandidate in FNounResults do
    case (vCandidate.prCase = 'NOM') and (vCandidate.prNumber1 = 'S') of
      TRUE: begin vResult := vCandidate; BREAK; end;
    end;

  var vContext := default(TNounContext);
  vContext.ncClass   := mapClassToClass(vResult.prClass);
  vContext.ncVariant := mapVariantToVariant(vResult.prVariant);
  vContext.ncStem1   := vResult.prStem1;
  vContext.ncStem2   := vResult.prStem2;
  vContext.ncStem3   := vResult.prStem3;
  vContext.ncStem4   := vResult.prStem4;
  vContext.ncGender  := mapGenderToGender(vResult.prGender);

  result := nounDeclension(vContext, aDictionaryEntry);
end;

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
    var vStem := lowerCase(vParseResult.prStem.trim);
    var vIndexes: TArray<integer>;

    // find vStem in the index which gives us a list of matching DictLine.lat records
    case FDictIx.tryGetValue(vStem, vIndexes) of TRUE: begin

      // each value of vIndex gives us an original DictLine.lat record number
      // for which at least one of the four stems will match vStem
      for var vIndex in vIndexes do begin
        var vDictLine := FDictLines[vIndex];
        var vDictPOS  := string(vDictLine.dictPartOfSpeech).trim;

        var vStaticPOS := (vDictPOS = 'CONJ') or (vDictPOS = 'PREP') or (vDictPOS = 'INTERJ') or (vDictPOS = 'ADV');
        case vStaticPOS and (vParseResult.prEnding.trim <> '') of TRUE: CONTINUE; end;

        for var vStemID := 1 to 4 do begin
          var vStemIDAsChar := char(vStemID + 48);
          // Only check this particular 1-4 stemID if it either matches the parseResult stemID or the parseResult stemID is a wildcard 0
          case (vParseResult.prStemID = vStemIDAsChar) or (vParseResult.prStemID = '0')  of FALSE: CONTINUE; end;

          var vDictStem: string;
          // we have an FDictIx which matches the stem we're looking for
          // and we have the original DictLine.lat record which was indexed
          // trim each of the four DictLine stems that were originally indexed for comparison below with vStem
          // to see which of the [up to] four original DictLine stems matches vStem
          case vStemID of
            1: vDictStem := lowerCase(vDictLine.dictStem1).trim;
            2: begin
                 vDictStem := lowerCase(vDictLine.dictStem2).trim;
                 case (vDictStem = '') and ((vDictPOS = 'V') or (vDictPOS = 'N') or (vDictPOS = 'ADJ') or (vDictPOS = 'NUM')) of
                   TRUE: vDictStem := lowerCase(vDictLine.dictStem1).trim; // we can use dictStem1 instead
                 end;
               end;
            3: vDictStem := lowerCase(vDictLine.dictStem3).trim;
            4: vDictStem := lowerCase(vDictLine.dictStem4).trim;
          end;

          // is this the original un-indexed record which matches everything we're looking for?
          case (vDictStem <> vStem) of TRUE: CONTINUE; end;

          var vResult             := vParseResult;
          vResult.prStem          := vDictStem; // tautology
          vResult.prStem1         := string(vDictLine.dictStem1).trim; // currently for declineNoun only
          vResult.prStem2         := string(vDictLine.dictStem2).trim;
          vResult.prStem3         := string(vDictLine.dictStem3).trim;
          vResult.prStem4         := string(vDictLine.dictStem4).trim;
          vResult.prAge           := vDictLine.dictAge;
          vResult.prArea          := vDictLine.dictArea;
          vResult.prGeography     := vDictLine.dictGeography;
          vResult.prFrequency     := vDictLine.dictFrequency;
          vResult.prSource        := vDictLine.dictSource;
          vResult.prStemID        := vStemIDAsChar;
          vResult.prPartOfSpeech  := vDictLine.dictPartOfSpeech;
          vResult.prClass         := vDictLine.dictClass;      // Ensure result carries Dictionary Class
          vResult.prVariant       := vDictLine.dictVariant;    // Ensure result carries Dictionary Variant

          case (vDictPOS = 'N') of TRUE: begin
            vResult.prGender      := vDictLine.dictVNARec.dictNounGender;
            vResult.prNounType    := vDictLine.dictVNARec.dictNounType;
          end;end;

          vResult.prExplanation := vDictLine.dictTranslation;
          result := result + [vResult];

          // CRITICAL: Once this entry matches for the requested StemID,
          // do not look for further stem matches within the SAME dictionary entry.
          // BREAK;
        end;
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

    case (vStem <> '') and (vStem.length <= MAX_STEM) of TRUE: begin
      var vResult       := default(TParseResultRec);
      vResult.prWord    := aWord;
      vResult.prStem    := vStem;
      vResult.prEnding  := vInflection.irSuffix;
      vResult.prStemID  := vInflection.irStemID;

      mapInflectionToResult(vInflection, vResult);

      result := result + [vResult];
    end; end;
  end;
end;

function TLatin.findPrefixes(const aWord: string; const aPrefixRec: TPrefixRec): TArray<TParseResultRec>;
begin
  result    := NIL;
  var vCore := removePrefix(aWord, aPrefixRec.prPrefix, aPrefixRec.prConnector);
  case (vCore = aWord) of TRUE: EXIT; end;

  var vInflections := findInflections(vCore);
  var vTargetPOS   := string(aPrefixRec.prTargetPartOfSpeech).trim;

  for var vInflection in vInflections do begin
    var vCandidate := vInflection;
    case (vTargetPOS <> 'X') of TRUE: vCandidate.prPartOfSpeech := aPrefixRec.prTargetPartOfSpeech; end;

    result := result + findDictStems([vCandidate]);
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
        vParseResult.prPartOfSpeech := vInflection.irPartOfSpeech;
        vParseResult.prClass        := vInflection.irClass;
        vParseResult.prVariant      := vInflection.irVariant;
        vParseResult.prStem         := vStemString;
        vParseResult.prEnding       := vInflection.irSuffix;
        vParseResult.prCase         := vInflection.irCase;
        vParseResult.prNumber1      := vInflection.irNumber1;
        vParseResult.prGender       := vInflection.irGender;
        vParseResult.prAge          := vInflection.irAge;
        vParseResult.prFrequency    := vInflection.irFrequency;

        var vExplanation := 'Pronominal: ';
        case (aContext.pcPrefix <> '') of TRUE: vExplanation := vExplanation + '[' + aContext.pcPrefix.trim + '-] + '; end;

        vExplanation := vExplanation + '[' + vParseResult.prStem.trim + '] + [-' + vParseResult.prEnding.trim + ']';

        case (aContext.pcTackOn <> '') of TRUE: vExplanation := vExplanation + ' + [-' + aContext.pcTackOn.trim + '] (' + aContext.prSenses.trim + ')'; end;

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

function TLatin.mapCaseToCase(const aCase: string): TNounCase;
begin
  result := ncNone;
  for var vCase := ncNominative to ncLocative do case (MAP_NOUN_CASES[vCase] = aCase) of TRUE: EXIT(vCase); end;
end;

function TLatin.mapClassToClass(const aClass: char): TClassClass;
begin
  result := cc1;
//  result := cccNone; // BAZ EXPERIMENTAL
  for var vClass := cc1 to cc9 do case (MAP_CLASS_CLASSES[vClass] = aClass) of TRUE: EXIT(vClass); end;
end;

function TLatin.mapGenderToGender(const aGender: char): TNounGender;
begin
  result := ngNone;
  for var vGender := ngMasculine to ngAll do case (MAP_NOUN_GENDERS[vGender] = aGender) of TRUE: EXIT(vGender); end;
end;

function TLatin.mapInflectionToResult(const aInflection: TInflectionsRec; var aResult: TParseResultRec): TVoid;
begin
  aResult.prPartOfSpeech  := aInflection.irPartOfSpeech;
  aResult.prClass         := aInflection.irClass;
  aResult.prVariant       := aInflection.irVariant;
  aResult.prCase          := aInflection.irCase;
  aResult.prNumber1       := aInflection.irNumber1;
  aResult.prGender        := aInflection.irGender;

  var vPOS := trim(aResult.prPartOfSpeech);

  aResult.prDegree  := '';
  aResult.prTense   := '';

  case (vPOS = 'ADJ') or (vPOS = 'ADV') or (vPOS = 'NUM') of TRUE: aResult.prDegree := aInflection.irDegreeTense; end;
  case (vPOS = 'V')   or (vPOS = 'VPAR')                  of TRUE: aResult.prTense  := aInflection.irDegreeTense; end;

  aResult.prVoice         := aInflection.irVoice;
  aResult.prMood          := aInflection.irMood;
  aResult.prPerson        := aInflection.irPerson;
  aResult.prNumber2       := aInflection.irNumber2;

  aResult.prAge           := aInflection.irAge;
  aResult.prFrequency     := aInflection.irFrequency;
end;

function TLatin.mapMoodToMood(const aMood: string): TVerbMood;
begin
  result := vmNone;
  for var vMood := vmIndicative to vmInfinitive do case (MAP_VERB_MOODS[vMood] = aMood) of TRUE: EXIT(vMood); end;
end;

function TLatin.mapNumberToNumber(const aNumber: char): TVerbNumber;
begin
  result := vnNone;
  for var vNumber := vnSingular to vnPlural do case (MAP_VERB_NUMBERS[vNumber] = aNumber) of TRUE: EXIT(vNumber); end;
end;

function TLatin.mapPersonToPerson(const aPerson: char): TVerbPerson;
begin
  result := vpNone;
  for var vPerson := vpFirst to vpThird do case (MAP_VERB_PERSONS[vPerson] = aPerson) of TRUE: EXIT(vPerson); end;
end;

function TLatin.mapTenseToTense(const aTense: string): TVerbTense;
begin
  result := vtNone;
  for var vTense := vtPluperfect to vtSupine do case (MAP_VERB_TENSES[vTense] = aTense) of TRUE: EXIT(vTense); end;
end;

function TLatin.mapVariantToVariant(const aVariant: char): TClassVariant;
begin
  result := cv1;
//  result := cvNone; // BAZ EXPERIMENTAL
  for var vVariant := cv1 to cv9 do case (MAP_CLASS_VARIANTS[vVariant] = aVariant) of TRUE: EXIT(vVariant); end;
end;

function TLatin.mapVoiceToVoice(const aVoice: string): TVerbVoice;
begin
  result := vvNone;
  for var vVoice := vvActive to vvPassive do case (MAP_VERB_VOICES[vVoice] = aVoice) of TRUE: EXIT(vVoice); end;
end;

function TLatin.nounDeclension(const aContext: TNounContext; var aDictionaryEntry: string): TGrammarTable;
const COL_CASE = 0;

  function getDictionaryEntry(const aTable: TGrammarTable): string;
  begin
    var vNominative := aTable[ncNominative][ord(nnSingular)];
    var vGenitive   := aTable[ncGenitive][ord(nnSingular)];
    var vGender     := MAP_NOUN_GENDER_LABELS[aContext.ncGender];

    result := format('%s, %s, %s', [vNominative, vGenitive, vGender]);
  end;

begin
  var vTargetGenders: TArray<TNounGender> := NIL;

  case aContext.ncGender of
    ngMasculine: vTargetGenders := [ngMasculine];
    ngFeminine:  vTargetGenders := [ngFeminine];
    ngNeuter:    vTargetGenders := [ngNeuter];
    ngCommon:    vTargetGenders := [ngMasculine, ngFeminine];
    ngAll:       vTargetGenders := [ngMasculine, ngFeminine, ngNeuter];
  else
    vTargetGenders := NIL;
  end;

  result[ncNone][COL_CASE]        := 'Case';
  result[ncNone][ord(nnSingular)] := 'Singular';
  result[ncNone][ord(nnPlural)]   := 'Plural';

  for var vCase := ncNominative to ncLocative do begin
    result[vCase][COL_CASE] := MAP_NOUN_CASES[vCase];

    for var vNumber := nnSingular to nnPlural do begin
      var vCellList := TStringList.create;
      vCellList.sorted     := TRUE;
      vCellList.duplicates := dupIgnore;

      try
        for var vGender in vTargetGenders do begin
          var vSlotChar := ' ';

          case vGender of
            ngMasculine: vSlotChar := 'M';
            ngFeminine:  vSlotChar := 'F';
            ngNeuter:    vSlotChar := 'N';
          end;

          for var vInflection in FNounData[aContext.ncClass, aContext.ncVariant, vCase, vNumber, vGender] do begin

            case NOT (vInflection.niAge in ['X', 'C']) of TRUE: CONTINUE; end;
            case (aContext.ncGender in [ngMasculine, ngFeminine, ngNeuter])
              and NOT (vInflection.niGender in ['X', 'C', vSlotChar]) of TRUE: CONTINUE; end;

            var vStem := '';
            case vInflection.niStemID of
              '1': vStem := aContext.ncStem1;
              '2': vStem := aContext.ncStem2;
              '3': vStem := aContext.ncStem3;
              '4': vStem := aContext.ncStem4;
            end;

            // Plan A: Skip inflections that require a stem index not provided by this dictionary entry
            // case (vStem = '') and (vInflection.niStemID <> '0') of TRUE: CONTINUE; end;
            // Plan B: Whitaker Fallback: if the required stem is missing, use the primary stem
            case (vStem = '') of TRUE: vStem := aContext.ncStem1; end;

            var vFullWord      := vStem + vInflection.niSuffix;
            var vDisplaySuffix := ' -' + vInflection.niSuffix;

            case USER_NOUN_DEBUG of TRUE: begin              var vDebugTag  := ' [' + vSlotChar + vInflection.niGender + vInflection.niAge + vInflection.niFrequency + vInflection.niStemID + ']';
              vFullWord      := vFullWord      + vDebugTag;
              vDisplaySuffix := vDisplaySuffix + vDebugTag;
            end;end;

            vCellList.add(vFullWord + '|' + vDisplaySuffix);
          end;end;

          case (vCellList.count > 0) of TRUE: begin
            result[vCase][ord(vNumber)] := vCellList[0].split(['|'])[0];
            for var vIdx := 1 to vCellList.count - 1 do begin
              result[vCase][ord(vNumber)] := result[vCase][ord(vNumber)] + ' /' + vCellList[vIdx].split(['|'])[1];
          end;end;

          FALSE: result[vCase][ord(vNumber)] := '---';
        end;

      finally
        vCellList.free;
      end;end;end;

  aDictionaryEntry := getDictionaryEntry(result);
end;

function TLatin.parse(const aConsoleCommand: TConsoleCommand; const aLine: string): TArray<string>;
begin
//  var vLine       := lowerCase(aLine);
//      vLine       := removeMacrons(vLine);
  result          := NIL;
  var vLine       := cleanSentences   (aLine);
  var vSentences  := extractSentences (vLine);

  for var vSentence in vSentences do  begin
                                        var vWords := vSentence.split([' '], TStringSplitOptions.ExcludeEmpty);

                                        var i                     := -1; // pseudo "for i := 0 ... " loop variable
                                        var vPC                   := default(TParseContext);
                                            vPC.pcConsoleCommand  := aConsoleCommand;

                                        for var vWord in vWords do  begin
                                                                      inc(i);

                                                                      case vPC.pcNextUsed of TRUE:  begin
                                                                                                      vPC.pcNextUsed := FALSE;
                                                                                                      CONTINUE; end;end;
                                                                      vPC := getParseContext(vPC);

                                                                      case i < length(vWords) - 1 of   TRUE: vPC.pcNextWord := vWords[i + 1];
                                                                                                      FALSE: vPC.pcNextWord := '' end;

                                                                      case aConsoleCommand in [ccDeclineNoun, ccDeclineAdjective, ccConjugateVerb] of TRUE: begin
                                                                        var vDictionaryEntry: string;
                                                                        case aConsoleCommand of
                                                                          ccDeclineNoun:    result := result + formatGrammarResults(declineNoun   (vWord, vDictionaryEntry)) + [vDictionaryEntry];
                                                                          ccConjugateVerb:  result := result + formatGrammarResults(conjugateVerb (vWord, vDictionaryEntry)) + [vDictionaryEntry];
                                                                        end;

                                                                        CONTINUE;
                                                                      end;end;

                                                                      result := result + formatParseResults(parseRomanNumerals(vWord));
                                                                      result := result + formatParseResults(parseWord(vWord, vPC));

                                                                      expandArray(result);
                                                                      result[high(result)] := ''; end;end;
end;

function TLatin.parseCompounds(const aParseResults: TArray<TParseResultRec>; var aParseContext: TParseContext): TArray<TParseResultRec>;
begin
  result := NIL;
  case (aParseContext.pcNextWord = '') of TRUE: EXIT; end;

  var vNextWord     := lowerCase(removeMacrons(aParseContext.pcNextWord));
  var vEsseResults  := parseEsse(vNextWord);
  var vIri          := (vNextWord = 'iri');
  var vEsse         := (vNextWord = 'esse');
  var vFuisse       := (vNextWord = 'fuisse');
  var vNextAux      := (length(vEsseResults) > 0) or vIri or vEsse or vFuisse;

  case (NOT vNextAux) of TRUE: EXIT; end;

  for var vResult in aParseResults do begin
    var vCompoundResult: TParseResultRec := default(TParseResultRec);
    var vMatch := FALSE;

    case (vResult.prMood.trim = 'PPL') of TRUE: begin
      for var vAuxResult in vEsseResults do begin
        case (vResult.prNumber1 = vAuxResult.prNumber2) and (vResult.prCase.trim = 'NOM') of TRUE: begin
          vCompoundResult := vResult;
          vCompoundResult.prWord := vResult.prWord + ' ' + aParseContext.pcNextWord;
          vCompoundResult.prPartOfSpeech := 'V';
          vCompoundResult.prPerson := vAuxResult.prPerson;
          vCompoundResult.prNumber2 := vAuxResult.prNumber2;
          vCompoundResult.prMood := vAuxResult.prMood;
          vCompoundResult.prVoice := 'PASSIVE';

          case (vResult.prTense.trim = 'PERF') of TRUE: begin
            case (vAuxResult.prTense.trim = 'PRES') or (vAuxResult.prTense.trim = 'PERF') of TRUE: vCompoundResult.prTense := 'PERF'; end;
            case (vAuxResult.prTense.trim = 'IMPF') or (vAuxResult.prTense.trim = 'PLUP') of TRUE: vCompoundResult.prTense := 'PLUP'; end;
            case (vAuxResult.prTense.trim = 'FUT') or (vAuxResult.prTense.trim = 'FUTP') of TRUE: vCompoundResult.prTense := 'FUTP'; end;
            vCompoundResult.prExplanation := 'passive perfect system compound';
            vMatch := TRUE;
          end;end;

          case (vResult.prTense.trim = 'FUT') of TRUE: begin
            vCompoundResult.prTense := vAuxResult.prTense;
            vCompoundResult.prVoice := vResult.prVoice;
            vCompoundResult.prExplanation := 'periphrastic compound';
            vMatch := TRUE;
          end;end;
        end;end;
      end;

      case (vEsse or vFuisse) of TRUE: begin
        vCompoundResult := vResult;
        vCompoundResult.prWord := vResult.prWord + ' ' + aParseContext.pcNextWord;
        vCompoundResult.prPartOfSpeech := 'V';
        vCompoundResult.prMood := 'INF';
        vCompoundResult.prVoice := vResult.prVoice;

        case vEsse of TRUE: vCompoundResult.prTense := vResult.prTense; end;
        case vFuisse of TRUE: vCompoundResult.prTense := 'PERF'; end;

        vCompoundResult.prExplanation := 'compound infinitive';
        vMatch := TRUE;
      end;end;
    end;end;

    case (vResult.prMood.trim = 'SUPI') and (vResult.prCase.trim = 'ACC') and vIri of TRUE: begin
      vCompoundResult := vResult;
      vCompoundResult.prWord := vResult.prWord + ' ' + aParseContext.pcNextWord;
      vCompoundResult.prPartOfSpeech := 'V';
      vCompoundResult.prTense := 'FUT';
      vCompoundResult.prVoice := 'PASSIVE';
      vCompoundResult.prMood := 'INF';
      vCompoundResult.prExplanation := 'future passive infinitive';
      vMatch := TRUE;
    end;end;

    case vMatch of TRUE: begin
      result := result + [vCompoundResult];
      aParseContext.pcNextUsed := TRUE;
    end;end;
  end;
end;

function TLatin.parseDictStems(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
begin
  result := NIL;
  for var vResult in aParseResults do begin
    var vRawHits := findDictStems([vResult]);
    var vTargetPOS := vResult.prPartOfSpeech.trim;

    for var vCandidate in vRawHits do begin
      var vDictPOS := vCandidate.prPartOfSpeech.trim;
      var vMappedTarget := vTargetPOS;

      case (vMappedTarget = 'VPAR') or (vMappedTarget = 'SUPI') of TRUE: vMappedTarget := 'V'; end;
      case (vMappedTarget = 'PACK') of TRUE: vMappedTarget := 'PRON'; end;
      case (vMappedTarget = 'ADJ') and (vDictPOS = 'NUM') of TRUE: vMappedTarget := 'NUM'; end;

      // Filtering logic: Added StemID verification to ensure dictionary hits match the inflection's required Stem Index
      var vClassMatch  := (vCandidate.prClass = vResult.prClass) or (vCandidate.prClass = '0') or (vResult.prClass = '0');
      var vVarMatch    := (vCandidate.prVariant = vResult.prVariant) or (vCandidate.prVariant = '0') or (vResult.prVariant = '0');
      var vStemIDMatch := (vResult.prStemID = '0') or (vCandidate.prStemID = vResult.prStemID);

      var vGenderMatch := TRUE;
      case (vDictPOS = 'N') of TRUE:
        vGenderMatch := (vCandidate.prGender = vResult.prGender)
          or (vCandidate.prGender = 'X') or (vResult.prGender = 'X')
          or ((vCandidate.prGender = 'C') and (vResult.prGender in ['M', 'F']))
          or ((vResult.prGender = 'C') and (vCandidate.prGender in ['M', 'F'])); end;

      case (vDictPOS = vMappedTarget) and vClassMatch and vVarMatch and vStemIDMatch and vGenderMatch of TRUE: begin
          var vFinal := vCandidate;
          // Carry over the specific morphological tags from the inflection engine
          // (The dict entry provides the 'definition' and 'class', the requirement provides the 'case/person/tense')
          case (vResult.prPartOfSpeech.trim = 'VPAR') or (vResult.prPartOfSpeech.trim = 'SUPI') of
            TRUE: vFinal.prPartOfSpeech := vResult.prPartOfSpeech; end;
          vFinal.prCase     := vResult.prCase;
          vFinal.prNumber1  := vResult.prNumber1;
          case (vDictPOS <> 'N') of TRUE: vFinal.prGender := vResult.prGender; end; // don't obliterate the DictLine gender (Adjectives and Pronouns are fine though)
          vFinal.prTense    := vResult.prTense;
          vFinal.prVoice    := vResult.prVoice;
          vFinal.prMood     := vResult.prMood;
          vFinal.prPerson   := vResult.prPerson;
          vFinal.prNumber2  := vResult.prNumber2;
          vFinal.prDegree   := vResult.prDegree;

          result := result + [vFinal];
        end;
      end;
    end;
  end;
end;

function TLatin.parseEsse(const aWord: string): TArray<TParseResultRec>;
begin
  result := NIL;
  var vWord := lowerCase(removeMacrons(aWord));

  for var vEsse in FEsse do begin
    case (string(vEsse.erWord).trim = vWord) of TRUE: begin
      var vResult: TParseResultRec  := default(TParseResultRec);
      vResult.prWord                := aWord;
      vResult.prPartOfSpeech        := 'V';
      vResult.prStem                := 'sum';
      vResult.prTense               := vEsse.erTense;
      vResult.prVoice               := vEsse.erVoice;
      vResult.prMood                := vEsse.erMood;
      vResult.prPerson              := vEsse.erPerson;
      vResult.prNumber2             := vEsse.erNumber;
      vResult.prClass               := '5';
      vResult.prVariant             := '1';
      vResult.prAge                 := 'X';
      vResult.prFrequency           := 'A';
      vResult.prExplanation         := 'irregular form of sum, esse';

      result := result + [vResult];
    end;end;
  end;
end;

function TLatin.parseInflections(const aWord: string): TArray<TParseResultRec>;
begin
  result := findInflections(aWord);
end;

function TLatin.parsePrefixes(const aParseResults: TArray<TParseResultRec>): TArray<TParseResultRec>;
begin
  result := NIL;
  for var vPrefixRec in FPrefixes do begin
    var vPrefix := string(vPrefixRec.prPrefix).trim;
    case (vPrefix = '') of TRUE: CONTINUE; end;

    for var vParseResult in aParseResults do begin
      var vInflectPOS := vParseResult.prPartOfSpeech.trim;
      var vTargetPOS  := string(vPrefixRec.prTargetPartOfSpeech).trim;

     // Amendment to allow recursive calls with wildcard 'X' to pass the filter
      case (vTargetPOS <> 'X') and (vTargetPOS <> '') and (vInflectPOS <> 'X') and (vInflectPOS <> vTargetPOS) of TRUE: CONTINUE; end;

      var vStem := vParseResult.prStem.trim;
      var vPrefixLen := vPrefix.length;
      case (vStem.length > vPrefixLen) and equalLatin(vStem.substring(0, vPrefixLen), vPrefix) of FALSE: CONTINUE; end;

      case (vPrefixRec.prConnector <> ' ') of TRUE: begin
        case (vStem[vPrefixLen + 1] <> vPrefixRec.prConnector) of TRUE: CONTINUE; end;
      end;end;

      var vStrippedRec := vParseResult;
      vStrippedRec.prStem := vStem.substring(vPrefixLen);
      vStrippedRec.prStemID := '0';
      vStrippedRec.prPartOfSpeech := vPrefixRec.prSourcePartOfSpeech;

      var vCandidates := findDictStems([vStrippedRec]);

      case (length(vCandidates) > 0) of TRUE: begin
        var vValidated: TArray<TParseResultRec> := NIL;
        var vSourcePOS := string(vPrefixRec.prSourcePartOfSpeech).trim;

        for var vCandidate in vCandidates do begin
          var vCPOS := vCandidate.prPartOfSpeech.trim;

          var vStaticPOS := (vCPOS = 'CONJ') or (vCPOS = 'PREP') or (vCPOS = 'INTERJ') or (vCPOS = 'ADV');
          case vStaticPOS of TRUE: CONTINUE; end;

          case (vCPOS = 'N') and (vCandidate.prClass = '9') and (vCandidate.prVariant = '8') of TRUE: CONTINUE; end;
          case (vCPOS = 'ADJ') and (vCandidate.prClass = '9') and (vCandidate.prVariant = '8') of TRUE: CONTINUE; end;

          var vMatch  := (vCPOS = vSourcePOS)
                       or ((vCPOS = 'PACK') and (vSourcePOS = 'PRON'))
                       or (vSourcePOS = 'X');

          case vMatch of TRUE: begin
            var vTrans := vCandidate;
            case (vTargetPOS <> 'X') and (vTargetPOS <> '') of
              TRUE: vTrans.prPartOfSpeech := vPrefixRec.prTargetPartOfSpeech;
            end;
            vValidated := vValidated + [vTrans];
          end;end;
        end;

        case (length(vValidated) > 0) of TRUE: begin
          var vPrefixResult             := default(TParseResultRec);
          vPrefixResult.prWord          := vParseResult.prWord;
          vPrefixResult.prPartOfSpeech  := 'PREFIX';
          vPrefixResult.prStem          := string(vPrefixRec.prPrefix);
          vPrefixResult.prExplanation   := vPrefixRec.prSenses;
          result                        := result + [vPrefixResult] + vValidated;
          // EXIT; // removed to allow multiple grammatical interpretations
        end;end;
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

  function stripPronominalPackon(const aCore: string; const aTackOn: string): string;
  begin
    result := aCore.substring(0, aCore.length - aTackOn.length);
  end;

  function findPronominal(const aCore: string; const aPrefix: string; const aPrefixSenses: string): TArray<TParseResultRec>;
  begin
    result          := NIL;
    var vCore       := aCore;
    var vStemType   := identifyPronominalStem(vCore);

    case (vStemType = stNone) of TRUE: EXIT; end;

    var vTackOnRec := findPronominalPackon(vCore);
    var vTackOn    := trim(vTackOnRec.trTackOn);
    var vContext   :  TPronominalContext;

    vContext.pcFullWord := aWord;
    vContext.pcPrefix   := aPrefix;
    vContext.pcTackOn   := vTackOn;
    vContext.prSenses   := trim(vTackOnRec.trSenses);

    var vInflections := findPronominalInflections(vCore, vStemType, vContext);

    case (length(vInflections) = 0) and (vTackOn <> '') of TRUE: begin
      vCore := stripPronominalPackon(vCore, vTackOn);
      vInflections := findPronominalInflections(restoreStemM(vCore, vTackOn), vStemType, vContext);
    end; end;

    case (length(vInflections) > 0) of TRUE: begin
      case (aPrefix <> '') of TRUE: begin
        var vPrefixEntry            :=  default(TParseResultRec);
        vPrefixEntry.prWord         :=  aWord;
        vPrefixEntry.prPartOfSpeech := 'PREFIX';
        vPrefixEntry.prStem         :=  aPrefix;
        vPrefixEntry.prExplanation  :=  aPrefixSenses.trim;
        result                      :=  result + [vPrefixEntry];
      end; end;

      result := result + vInflections;

      case (vTackOn <> '') of TRUE: begin
        var vTackonEntry              :  TParseResultRec;
        vTackonEntry.prWord           := aWord;
        vTackonEntry.prStem           := vTackOnRec.trTackOn;
        vTackonEntry.prPartOfSpeech   := vTackOnRec.trTargetPartOfSpeech;
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
  for var vSuffixRec in FSuffixes do begin
    var vSuffix := string(vSuffixRec.srSuffix).trim;
    case (vSuffix = '') of TRUE: CONTINUE; end;

     for var vParseResult in aParseResults do begin
      var vInflectPOS := vParseResult.prPartOfSpeech.trim;
      var vTargetPOS  := string(vSuffixRec.srTargetPartOfSpeech).trim;

      // Allow recursive calls where POS is 'X' to pass through the target filter
      case (vTargetPOS <> 'X') and (vInflectPOS <> 'X') and (vInflectPOS <> vTargetPOS) of TRUE: CONTINUE; end;

      // Filter by the Suffix's target classification (Class and Variant)
      case (vSuffixRec.srTargetClass <> '0') and (vParseResult.prClass <> vSuffixRec.srTargetClass) of TRUE: CONTINUE; end;
      case (vSuffixRec.srTargetVariant <> '0') and (vParseResult.prVariant <> vSuffixRec.srTargetVariant) of TRUE: CONTINUE; end;
      var vStem := vParseResult.prStem.trim;
      case (vStem.length > vSuffix.length) and vStem.endsWith(vSuffix) of FALSE: CONTINUE; end;

      case (vSuffixRec.srConnector <> ' ') of TRUE: begin
        case (vStem[vStem.length - vSuffix.length] <> vSuffixRec.srConnector) of TRUE: CONTINUE; end;
      end;end;

      var vStrippedRec := vParseResult;
      vStrippedRec.prStem := vStem.substring(0, vStem.length - vSuffix.length);
      vStrippedRec.prStemID := '0';
      vStrippedRec.prPartOfSpeech := vSuffixRec.srSourcePartOfSpeech;

      var vCandidates := findDictStems([vStrippedRec]);
      var vPrefixActive := FALSE;

      case (length(vCandidates) = 0) of TRUE: begin
        vCandidates := parsePrefixes([vStrippedRec]);
        vPrefixActive := length(vCandidates) > 0;
      end;end;

      case (length(vCandidates) > 0) of TRUE: begin
        var vValidated: TArray<TParseResultRec> := NIL;
        var vSourcePOS := string(vSuffixRec.srSourcePartOfSpeech).trim;

        for var vCandidate in vCandidates do begin
          var vCPOS := vCandidate.prPartOfSpeech.trim;

          var vStaticPOS := (vCPOS = 'CONJ') or (vCPOS = 'PREP') or (vCPOS = 'INTERJ') or (vCPOS = 'ADV');
          case vStaticPOS of TRUE: CONTINUE; end;

          case (vCPOS = 'PREFIX') or (vCPOS = 'SUFFIX') of TRUE: begin
            vValidated := vValidated + [vCandidate];
            CONTINUE;
          end;end;

          case (vCPOS = 'N') and (vCandidate.prClass = '9') and (vCandidate.prVariant = '8') of TRUE: CONTINUE; end;
          case (vCPOS = 'ADJ') and (vCandidate.prClass = '9') and (vCandidate.prVariant = '8') of TRUE: CONTINUE; end;

          var vMatch  := (vCPOS = vSourcePOS)
                       or ((vCPOS = 'PACK') and (vSourcePOS = 'PRON'))
                       or (vSourcePOS = 'X');

          case vMatch of TRUE: begin
            var vStemMatch := (vSuffixRec.srSourceStemID = '0') or (vCandidate.prStemID = vSuffixRec.srSourceStemID)
                  or ((vCandidate.prStemID = '0') and ((vCPOS = 'N') or (vCPOS = 'ADJ') or (vCPOS = 'V'))
                  and ((vSuffixRec.srSourceStemID = '1') or (vSuffixRec.srSourceStemID = '2')));

            case vStemMatch of TRUE: begin
              var vTrans := vCandidate;
              case (string(vSuffixRec.srTargetPartOfSpeech).trim <> 'X') and (string(vSuffixRec.srTargetPartOfSpeech).trim <> '') of
                TRUE: vTrans.prPartOfSpeech := vSuffixRec.srTargetPartOfSpeech;
              end;
              vTrans.prClass    := vSuffixRec.srTargetClass;
              vTrans.prVariant  := vSuffixRec.srTargetVariant;
              vTrans.prStemID   := vSuffixRec.srTargetStemID;
              vTrans.prDegree   := vSuffixRec.srDegree;
              vTrans.prVerbType := vSuffixRec.srVerbType;
              vTrans.prNumValue := vSuffixRec.srNumValue;

              // Only overwrite Gender/Number if the suffix record contains an explicit value (not ' ' or 'X')
              case (vSuffixRec.srNounGender <> ' ') and (vSuffixRec.srNounGender <> 'X') of TRUE: vTrans.prGender   := vSuffixRec.srNounGender; end;
              case (vSuffixRec.srNounNumber <> ' ') and (vSuffixRec.srNounNumber <> 'X') of TRUE: vTrans.prNumber1  := vSuffixRec.srNounNumber; end;

              vValidated := vValidated + [vTrans];
            end;end;
          end;end;
        end;

        case (length(vValidated) > 0) of TRUE: begin
          var vSuffixInfo := default(TParseResultRec);
          vSuffixInfo.prWord := vParseResult.prWord;
          vSuffixInfo.prPartOfSpeech := 'SUFFIX';
          vSuffixInfo.prStem := string(vSuffixRec.srSuffix);
          vSuffixInfo.prExplanation := vSuffixRec.srSenses;
          result := result + [vSuffixInfo] + vValidated;
          // EXIT; // removed to allow multiple grammatical interpretations
        end;end;
      end;end;
    end;
  end;
end;

function TLatin.parseTackOns(const aWord: string; var aPC: TParseContext): TArray<TParseResultRec>;
begin
  result    := NIL;
  var vWord := lowerCase(removeMacrons(aWord));

for var vTackOn in FTackOns do begin
    var vTackOnStr := string(vTackOn.trTackOn).trim;
    var vRecType   := string(vTackOn.trRecType).trim;

    // CRITICAL FIX: If ending is empty, matching it will never shorten the string.
    case (vTackOnStr = '') of TRUE: CONTINUE; end;

    case (vRecType = 'TACKO4') or (vRecType = 'TACKON') of TRUE: begin
      case (vWord.length > vTackOnStr.length) and (vWord.endsWith(vTackOnStr)) of TRUE: begin
        var vStem                                 := restoreStemM(vWord.substring(0, vWord.length - vTackOnStr.length), vTackOnStr);
        var vResultRecs: TArray<TParseResultRec>  := NIL;
        var vNextUsed                             := FALSE;

        case (vRecType = 'TACKO4') of TRUE: begin
          // Standard Whittaker rule: -que requires at least 2 chars remaining
          case (vTackOnStr = 'que') and (vStem.length < 2) of TRUE: CONTINUE; end;

          // Recursion depth is naturally limited because vStem is strictly shorter than vWord
          vResultRecs := parseWord(vStem, aPC, TRUE);
        end;end;

        case (vRecType = 'TACKON') of TRUE: begin
          vResultRecs                             := parseWord(vStem, aPC, TRUE);
          var vFiltered: TArray<TParseResultRec>  := NIL;
          var vTargPOS                            := string(vTackOn.trTargetPartOfSpeech).trim;

          for var vRec in vResultRecs do begin
            var vPM := (vTargPOS = 'X') or (vTargPOS = '') or (string(vRec.prPartOfSpeech).trim = vTargPOS);
            var vCM := (vTackOn.trTargetClass = '0') or (vRec.prClass = vTackOn.trTargetClass);
            var vVM := (vTackOn.trTargetVariant = '0') or (vRec.prVariant = vTackOn.trTargetVariant);

            case vPM and vCM and vVM of TRUE: vFiltered := vFiltered + [vRec]; end;
          end;
          vResultRecs := vFiltered;
        end;end;

        case (length(vResultRecs) > 0) of TRUE: begin
          var vTackOnRec            := default(TParseResultRec);
          vTackOnRec.prWord         := aWord;
          vTackOnRec.prPartOfSpeech := 'TACKON';
          vTackOnRec.prStem         := vTackOnStr;
          vTackOnRec.prExplanation  := vTackOn.trSenses;
          result                    := vResultRecs + [vTackOnRec];
          EXIT;
        end;end;      end;end;
      end;end;
  end;
end;

function TLatin.parseTricks(const aWord: string; var aPC: TParseContext): TArray<TParseResultRec>;
begin
  result := NIL;

  result  := tryTrick(aWord, aWord.replace('e', 'ae'), 'ae for e', aPC);
  case (length(result) > 0) of TRUE: EXIT; end;

  result  := tryTrick(aWord, aWord.replace('y', 'i'), 'i for y', aPC);
  case (length(result) > 0) of TRUE: EXIT; end;

  result  := tryTrick(aWord, aWord.replace('f', 'ph'), 'ph for f', aPC);
  case (length(result) > 0) of TRUE: EXIT; end;

  result  := tryTrick(aWord, aWord.replace('t', 'th'), 'th for t', aPC);
  case (length(result) > 0) of TRUE: EXIT; end;

  result  := tryTrick(aWord, aWord.replace('c', 'ch'), 'ch for c', aPC);
  case (length(result) > 0) of TRUE: EXIT; end;

end;

function TLatin.parseWord(const aWord: string; var aPC: TParseContext; const bTricks: boolean = FALSE): TArray<TParseResultRec>;
begin
  result := NIL;
  // otherwise the Delphi compiler optimises the following calls to
  // use the same array reference pointer as the result in the functions themselves(!)
  // and the result array here will keep getting duplicated each time!

  result := result + parseUniques(aWord);
  result := result + parsePronominals(aWord);
  result := result + parseEsse(aWord);

  var vInflectionRecs := parseInflections(aWord);
  result := result + parseDictStems(vInflectionRecs);

  case  (length(result) > 0)                                      of TRUE:  begin
                                                                              result := result + parseCompounds(result, aPC);
                                                                              EXIT; end;end;

  case  (length(result) = 0)  or aPC.pcTricks                     of TRUE: result := result + parsePrefixes (vInflectionRecs); end;
  case  (length(result) = 0)  or aPC.pcTricks                     of TRUE: result := result + parseSuffixes (vInflectionRecs); end;
  case  (length(result) = 0)  or aPC.pcTricks                     of TRUE: result := result + parseTackons  (aWord, aPC);      end;
  case ((length(result) = 0)  or aPC.pcTricks) and (NOT bTricks)  of TRUE: result := result + parseTricks   (aWord, aPC);      end;
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

function TLatin.removePrefix(const aStem: string; const aPrefix: string; const aConnector: char): string;
begin
  var vStem       := aStem.trim;
  var vPrefix     := aPrefix.trim;
  var vPrefixLen  := vPrefix.length;

  result := vStem;

  case (vStem.length > vPrefixLen) and equalLatin(vStem.substring(0, vPrefixLen), vPrefix) of TRUE: begin
    case (aConnector = ' ') or (vStem[vPrefixLen + 1] = aConnector) of TRUE: begin result := vStem.substring(vPrefixLen).trim; end;end;
  end;end;
end;

function TLatin.restoreStemM(const aCore: string; const aTackOn: string): string;
begin
  result := aCore;
  case aTackOn.startsWith('dam') and (result[result.length] = 'n') of TRUE: result[result.length] := 'm'; end;
end;

function TLatin.setDataPath(const aPath: string): TVoid;
begin
  FDataPath := aPath;
end;

function TLatin.siphonNounData: TNounData;
begin
  result := default(TNounData);

  for var vInflection in FInflections do begin
    case (trim(vInflection.irPartOfSpeech) <> 'N') of TRUE: CONTINUE; end;

    var vCase := mapCaseToCase(string(vInflection.irCase).trim);
    case (vCase = ncNone) of TRUE: CONTINUE; end;

    var vNumber: TNounNumber;
    case vInflection.irNumber1 of
      'S': vNumber := nnSingular;
      'P': vNumber := nnPlural;
    else
      CONTINUE;
    end;

    var vInflectionRec: TNounInflection;
    vInflectionRec.niStemID     := vInflection.irStemID;
    vInflectionRec.niSuffix     := string(vInflection.irSuffix).trim;
    vInflectionRec.niGender     := vInflection.irGender;
    vInflectionRec.niAge        := vInflection.irAge;
    vInflectionRec.niFrequency  := vInflection.irFrequency;

    for var vClass := cc1 to cc9 do
      case (vInflection.irClass = '0') or (vInflection.irClass = MAP_CLASS_CLASSES[vClass]) of TRUE:
        for var vVariant := cv1 to cv9 do
          case (vInflection.irVariant = '0') or (vInflection.irVariant = MAP_CLASS_VARIANTS[vVariant]) of TRUE:
            case vInflection.irGender of
              'M': result[vClass, vVariant, vCase, vNumber, ngMasculine] := result[vClass, vVariant, vCase, vNumber, ngMasculine] + [vInflectionRec];
              'F': result[vClass, vVariant, vCase, vNumber, ngFeminine]  := result[vClass, vVariant, vCase, vNumber, ngFeminine]  + [vInflectionRec];
              'N': result[vClass, vVariant, vCase, vNumber, ngNeuter]    := result[vClass, vVariant, vCase, vNumber, ngNeuter]    + [vInflectionRec];
              'C': begin
                     result[vClass, vVariant, vCase, vNumber, ngMasculine] := result[vClass, vVariant, vCase, vNumber, ngMasculine] + [vInflectionRec];
                     result[vClass, vVariant, vCase, vNumber, ngFeminine]  := result[vClass, vVariant, vCase, vNumber, ngFeminine]  + [vInflectionRec];
                   end;
              'X': begin
                     result[vClass, vVariant, vCase, vNumber, ngMasculine] := result[vClass, vVariant, vCase, vNumber, ngMasculine] + [vInflectionRec];
                     result[vClass, vVariant, vCase, vNumber, ngFeminine]  := result[vClass, vVariant, vCase, vNumber, ngFeminine]  + [vInflectionRec];
                     result[vClass, vVariant, vCase, vNumber, ngNeuter]    := result[vClass, vVariant, vCase, vNumber, ngNeuter]    + [vInflectionRec];
                   end;
            end;
          end;
      end;
  end;
end;

function TLatin.siphonVerbData: TVerbData;
begin
  result := default(TVerbData);
  for var vInflection in FInflections do
    case (trim(vInflection.irPartOfSpeech) = 'V') of TRUE: begin

      var vTense  := mapTenseToTense(trim(vInflection.irDegreeTense));
      var vVoice  := mapVoiceToVoice(trim(vInflection.irVoice));
      var vMood   := mapMoodToMood(trim(vInflection.irMood));
      var vPerson := mapPersonToPerson(vInflection.irPerson);
      var vNumber := mapNumberToNumber(vInflection.irNumber2);

      var vConjugation          :  TVerbConjugation;
      vConjugation.vcStemID     := vInflection.irStemID;
      vConjugation.vcSuffix     := trim(vInflection.irSuffix);
      vConjugation.vcAge        := vInflection.irAge;
      vConjugation.vcFrequency  := vInflection.irFrequency;

      for var vClass := cc1 to cc9 do
        case (vInflection.irClass = '0') or (vInflection.irClass = MAP_CLASS_CLASSES[vClass]) of TRUE:
          for var vVariant := cv1 to cv9 do
            case (vInflection.irVariant = '0') or (vInflection.irVariant = MAP_CLASS_VARIANTS[vVariant]) of TRUE:
              result[vClass, vVariant, vTense, vVoice, vMood, vPerson, vNumber] :=
                result[vClass, vVariant, vTense, vVoice, vMood, vPerson, vNumber] + [vConjugation];
            end;
        end;
    end;end;
end;

function TLatin.tryTrick(const aWord: string; const aModified: string; const aNote: string; var aPC: TParseContext): TArray<TParseResultRec>;
begin
  result    := NIL;
  case (aWord = aModified) of TRUE: EXIT; end;

  var vNextUsed:    boolean                   := FALSE;
  var vResultRecs:  TArray<TParseResultRec>   := parseWord(aModified, aPC, TRUE);

  case (length(vResultRecs) > 0) of TRUE: begin
    var vTrickRec: TParseResultRec  := default(TParseResultRec);
    vTrickRec.prWord                := aWord;
    vTrickRec.prPartOfSpeech        := 'TRICK';
    vTrickRec.prStem                := aModified;
    vTrickRec.prEnding              := aNote;
    result                          := [default(TParseResultRec), vTrickRec] + vResultRecs;
  end;end;
end;

function TLatin.unload: TVoid;
begin
  FLewisAndShort := NIL;
  FNounData := default(TNounData);
end;

function TLatin.verbConjugation(const aContext: TVerbContext; var aDictionaryEntry: string): TGrammarTable;
const COL_LABEL = 0;

  function getDictionaryEntry: string;

    function getForm(const aTense: TVerbTense; const aVoice: TVerbVoice; const aMood: TVerbMood; const aPerson: TVerbPerson; const aNumber: TVerbNumber): string;
    begin
      result := '';
      var vList := FVerbData[aContext.vcClass, aContext.vcVariant, aTense, aVoice, aMood, aPerson, aNumber];
      case (length(vList) > 0) of TRUE: begin
        var vStem := '';
        case vList[0].vcStemID of
          '1': vStem := aContext.vcStem1;
          '2': vStem := aContext.vcStem2;
          '3': vStem := aContext.vcStem3;
          '4': vStem := aContext.vcStem4;
        end;
        result := vStem + vList[0].vcSuffix;
      end;end;
    end;

  begin
    var vPres1S := getForm(vtPresent, vvActive, vmIndicative, vpFirst, vnSingular);
    var vInf    := getForm(vtPresent, vvActive, vmInfinitive, vpNone,  vnNone);
    var vPerf1S := getForm(vtPerfect, vvActive, vmIndicative, vpFirst, vnSingular);
    var vSupine := getForm(vtSupine,  vvActive, vmNone,       vpNone,  vnSingular);
    result      := format('%s, %s, %s, %s', [vPres1S, vInf, vPerf1S, vSupine]);
  end;

begin
  result := default(TGrammarTable);
  result[ncNone][COL_LABEL]       := 'Person';
  result[ncNone][ord(nnSingular)] := 'Singular';
  result[ncNone][ord(nnPlural)]   := 'Plural';

  for var vPerson := vpFirst to vpThird do begin
    var vRow := TNounCase(ord(vPerson));
    result[vRow][COL_LABEL] := MAP_VERB_PERSON_LABELS[vPerson];

    for var vNumber := vnSingular to vnPlural do begin
      var vCellList := TStringList.create;
      vCellList.sorted     := TRUE;
      vCellList.duplicates := dupIgnore;
      try
        for var vConjugation in FVerbData[aContext.vcClass, aContext.vcVariant, aContext.vcTense, aContext.vcVoice, aContext.vcMood, vPerson, vNumber] do begin
          case NOT (vConjugation.vcAge in ['X', 'C']) of TRUE: CONTINUE; end;

          var vStem := '';
          case vConjugation.vcStemID of
            '1': vStem := aContext.vcStem1;
            '2': vStem := aContext.vcStem2;
            '3': vStem := aContext.vcStem3;
            '4': vStem := aContext.vcStem4;
          end;

          case (vStem = '') and (vConjugation.vcStemID <> '0') of TRUE: CONTINUE; end;
          vCellList.add(vStem + vConjugation.vcSuffix);
        end;

        case (vCellList.count > 0) of
          TRUE: begin
            result[vRow][ord(vNumber)] := vCellList[0];
            for var vIdx := 1 to vCellList.count - 1 do
              result[vRow][ord(vNumber)] := result[vRow][ord(vNumber)] + ' / ' + vCellList[vIdx];
          end;
          FALSE: result[vRow][ord(vNumber)] := '---';
        end;
      finally
        vCellList.free;
      end;
    end;
  end;

  aDictionaryEntry := getDictionaryEntry;
end;

end.
