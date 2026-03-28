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
    FDictIx:        TDictionary<string, integer>;
    FEsse:          TArray<TEsseRec>;
    FInflections:   TArray<TInflectionsRec>;
    FLewisAndShort: ILewisAndShort;
    FPrefixes:      TArray<TPrefixRec>;
    FSuffixes:      TArray<TSuffixRec>;
    FTackOns:       TArray<TTackOnRec>;
    FUniques:       TArray<TUniquesRec>;
  private
    function  formatParseResults  (const aParseResults:   TArray<TParseResultRec>): TArray<string>;

    function  parseEnclitics      (const aWord: string):                                                    TArray<TParseResultRec>;
    function  parsePronominals    (const aWord: string):                                                    TArray<TParseResultRec>;
    function  parseRomanNumerals  (const aWord: string):                                                    TArray<TParseResultRec>;
    function  parseUniques        (const aWord: string):                                                    TArray<TParseResultRec>;
    function  parseWord           (const aWord: string; const aNextWord: string; var bNextUsed: boolean):   TArray<TParseResultRec>;
    function  findPronominalPackon(const aCore: string): TTackOnRec;
    function  findPronominalStem(const aWord: string; var aPrefix: string; var aStemType: TStemType; var aCore: string): boolean;
    function  matchPronominalInflections(const aCore: string; const aStemType: TStemType): TArray<TParseResultRec>;
    function  enrichPronominalResults(const aResults: TArray<TParseResultRec>; const aFullWord, aPrefix: string; const aPackon: TTackOnRec): TArray<TParseResultRec>;
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
  FDictIx := TDictionary<string, integer>.create(48750); // less than the [currently-known] 48759 so we get an accurate entry count
end;

destructor TLatin.Destroy;
begin
  FDictIx.free;
  inherited;
end;

function TLatin.formatParseResults(const aParseResults: TArray<TParseResultRec>): TArray<string>;
begin
  // otherwise the Delphi compiler optimises all the calls in the "for var vWord in vWords" loop in TLatin.parse
  // to use the same array reference pointer, and the result array will get duplicated on each call here!
  result := NIL;

  for var vParseResult in aParseResults do  begin
                                              var vIxDelta: integer;

                                              case trim(vParseResult.prExplanation) = '' of  TRUE: vIxDelta := 1;
                                                                                            FALSE: vIxDelta := 2; end;

                                              expandArray(result, vIxDelta);

                                              result[length(result) - vIxDelta] := format(dupeString('%s ', 24),  [
                                                                                                                    vParseResult.prWord   + #9#9,
                                                                                                                    vParseResult.prPartOfSpeech,
                                                                                                                    vParseResult.prStem   + #9,
                                                                                                                    vParseResult.prEnding + #9,
                                                                                                                    vParseResult.prClass,
                                                                                                                    vParseResult.prVariant,
                                                                                                                    vParseResult.prCase,
                                                                                                                    vParseResult.prNumber1,
                                                                                                                    vParseResult.prGender,
                                                                                                                    vParseResult.prNounType,
                                                                                                                    vParseResult.prDegree,
                                                                                                                    vParseResult.prPronounType,
                                                                                                                    vParseResult.prTense,
                                                                                                                    vParseResult.prVoice,
                                                                                                                    vParseResult.prMood,
                                                                                                                    vParseResult.prPerson,
                                                                                                                    vParseResult.prNumber2,
                                                                                                                    vParseResult.prVerbType,
                                                                                                                    vParseResult.prAge,
                                                                                                                    vParseResult.prArea,
                                                                                                                    vParseResult.prGeography,
                                                                                                                    vParseResult.prFrequency,
                                                                                                                    vParseResult.prSource,
                                                                                                                    vParseResult.prNumKind
                                                                                                                  ]);
                                              case vIxDelta = 2 of TRUE: result[length(result) - 1] := vParseResult.prExplanation; end;end;
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

function TLatin.enrichPronominalResults(const aResults: TArray<TParseResultRec>; const aFullWord, aPrefix: string; const aPackon: TTackOnRec): TArray<TParseResultRec>;
begin
  result := aResults;
  var vIndex := -1;
  for var vMatch in aResults do begin
    inc(vIndex);
    result[vIndex].prWord := aFullWord;

    var vExplanation := 'Pronominal: ';
    case aPrefix <> '' of TRUE: vExplanation := vExplanation + '[' + aPrefix + '-] + '; end;

    vExplanation := vExplanation + '[' + vMatch.prStem + '] + [-' + vMatch.prEnding + ']';

    case string(aPackon.trTackOn).trim <> '' of
      TRUE: begin
        var vTackOn := string(aPackon.trTackOn).trim;
        vExplanation := vExplanation + ' + [-' + vTackOn + '] (' + string(aPackon.trSenses).trim + ')';
      end;
    end;

    result[vIndex].prExplanation := vExplanation;
  end;
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

function TLatin.matchPronominalInflections(const aCore: string; const aStemType: TStemType): TArray<TParseResultRec>;
const
  PRON_POS         = 'PRON';
  PRON_CLASS       = '1';
  STEM_ID_QU       = '1';
  STEM_ID_CU       = '2';
  STEM_STRING_QU   = 'qu';
  STEM_STRING_CU   = 'cu';
begin
  result := NIL;
  var vStemString := '';
  var vTargetID   := #0;

  case aStemType of
    stQu: begin vStemString := STEM_STRING_QU; vTargetID := STEM_ID_QU; end;
    stCu: begin vStemString := STEM_STRING_CU; vTargetID := STEM_ID_CU; end;
    else  EXIT;
  end;

  for var vInflection in FInflections do begin
    var vInflectionPartOfSpeech := string(vInflection.irPartOfSpeech).trim;
    case (vInflectionPartOfSpeech = PRON_POS) and (vInflection.irClass = PRON_CLASS) and (vInflection.irStemID = vTargetID) of
      TRUE: begin
        var vEnding := string(vInflection.irSuffix).trim;
        case aCore = (vStemString + vEnding) of
          TRUE: begin
            var vParseResult: TParseResultRec;
            vParseResult.prPartOfSpeech := PRON_POS;
            vParseResult.prClass        := vInflection.irClass;
            vParseResult.prVariant      := vInflection.irVariant;
            vParseResult.prStem         := vStemString;
            vParseResult.prEnding       := vEnding;
            vParseResult.prCase         := string(vInflection.irCase).trim;
            vParseResult.prNumber1      := vInflection.irNumber1;
            vParseResult.prGender       := vInflection.irGender;
            vParseResult.prAge          := vInflection.irAge;
            vParseResult.prFrequency    := vInflection.irFrequency;
            result := result + [vParseResult];
          end; end; end; end; end;
end;

function TLatin.parse(const aLine: string): TArray<string>;
begin
//  var vLine       := lowerCase(aLine);
//      vLine       := removeMacrons(vLine);
//      vLine       := vLine.replace('v', 'u').replace('j', 'i');
  var vLine       := cleanSentences   (aLine);
  var vSentences  := extractSentences (vLine);
  var i           := -1;
  var vNextUsed   :  boolean;

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

function TLatin.parsePronominals(const aWord: string): TArray<TParseResultRec>;

  function stripPronominalPackon(const aCore: string; const aPackon: TTackOnRec): string;
  begin
    var vTackOnLength := string(aPackon.trTackOn).trim.length;
    result := aCore.substring(0, aCore.length - vTackOnLength);
  end;

begin
  result := NIL;
  var vPrefix := '';
  var vStemType := stNone;
  var vCore := '';

  case findPronominalStem(aWord, vPrefix, vStemType, vCore) of FALSE: EXIT; end;

  var vMatches := matchPronominalInflections(vCore, vStemType);
  var vPackon  := findPronominalPackon(vCore);

  case (length(vMatches) = 0) and (string(vPackon.trTackOn).trim <> '') of
    TRUE: vMatches := matchPronominalInflections(stripPronominalPackon(vCore, vPackon), vStemType);
  end;

  case length(vMatches) > 0 of
    TRUE: result := enrichPronominalResults(vMatches, aWord, vPrefix, vPackon);
  end;
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

function TLatin.parseWord(const aWord: string; const aNextWord: string; var bNextUsed: boolean): TArray<TParseResultRec>;
begin
  result := NIL;
  // otherwise the Delphi compiler optimises the following calls to
  // use the same array reference pointer as the result in the functions themselves(!)
  // and the result array here will keep getting duplicated each time!

  result := result + parseUniques(aWord);
  result := result + parsePronominals(aWord);
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
  var vWord := cleanVJJ(lowerCase(removeMacrons(aWord)));

  for var i := 0 to min(3, high(FTackOns)) do begin
    var vTackOn := FTackOns[i];
    var vEnding := cleanVJJ(trim(vTackOn.trTackOn));

    case (length(vWord) > length(vEnding)) and (vWord.endsWith(vEnding)) of   TRUE: begin
      var vStem := copy(vWord, 1, length(vWord) - length(vEnding));

      case (vEnding = 'que') and (length(vStem) < 2) of   TRUE: CONTINUE; end;

      result := result + parseUniques(vStem);

      var vEnclitic := default(TParseResultRec);
      vEnclitic.prWord         := trim(vTackOn.trTackOn);
      vEnclitic.prPartOfSpeech := trim(vTackOn.trTargetPartOfSpeech);
      vEnclitic.prClass        := vTackOn.trTargetClass;
      vEnclitic.prVariant      := vTackOn.trTargetVariant;
      vEnclitic.prDegree       := trim(vTackOn.trDegree);
      vEnclitic.prGender       := vTackOn.trNounGender;
      vEnclitic.prNumber1      := vTackOn.trNounNumber;
      vEnclitic.prExplanation  := trim(vTackOn.trSenses);

      result := result + [vEnclitic]; end;end;end;
end;

end.
