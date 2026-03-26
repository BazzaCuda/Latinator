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
  system.sysUtils, system.classes, system.generics.collections {for TDictionary},
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
  end;

function newLatin: ILatin;

implementation

uses
  latin.charUtils, latin.fileUtils, latin.miscUtils, latin.stringUtils,
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

    function  parseEnclitics      (const aWord: string):  TArray<TParseResultRec>;
    function  parseRomanNumerals  (const aWord: string):  TArray<TParseResultRec>;
    function  parseUniques        (const aWord: string):  TArray<TParseResultRec>;
    function  parseWord           (const aWord: string):  TArray<TParseResultRec>;
//    function  stripEnclitic(var aWord: string): TArray<string>;
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
  end;

function newLatin: ILatin;
begin
  result := TLatin.Create;
end;

{ TLatin }

constructor TLatin.Create;
begin
  inherited create;
  FDictIx := TDictionary<string, integer>.create(48759);
end;

destructor TLatin.Destroy;
begin
  FDictIx.free;
  inherited;
end;

function TLatin.formatParseResults(const aParseResults: TArray<TParseResultRec>): TArray<string>;
begin
  // otherwise the Delphi compiler optimises all the calls in the "for var vWord in vWords" loop in TLatin.parse
  // to use the same array reference pointer and the result array will get duplicated on each call here!
  result := NIL;

  for var vParseResult in aParseResults do  begin
                                              var vIxDelta: integer;

                                              case trim(vParseResult.prExplanation) = '' of  TRUE: vIxDelta := 1;
                                                                                            FALSE: vIxDelta := 2; end;

                                              expandArray(result, vIxDelta);

                                              result[length(result) - vIxDelta] := format('%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s',  [
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

function TLatin.parse(const aLine: string): TArray<string>;
begin
//  var vLine       := lowerCase(aLine);
//      vLine       := removeMacrons(vLine);
//      vLine       := vLine.replace('v', 'u').replace('j', 'i');
  var vLine       := cleanSentences   (aLine);
  var vSentences  := extractSentences (vLine);

  for var vSentence in vSentences do  begin
                                        var vWords := vSentence.split([' '], TStringSplitOptions.ExcludeEmpty);

                                        for var vWord in vWords do  begin
                                                                      result := result + formatParseResults(parseWord(vWord));
                                                                      expandArray(result);
                                                                      result[length(result) - 1] := ''; end;end;
end;

function TLatin.parseEnclitics(const aWord: string): TArray<TParseResultRec>;
begin
  result := NIL;
  // overkill (see comment in parseWord) but pre-empting any possible future bugs

  var vWord := cleanVJJ(aWord);




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

function TLatin.parseWord(const aWord: string): TArray<TParseResultRec>;
begin
  result := NIL;
  // otherwise the Delphi compiler optimises the following calls to
  // use the same array reference pointer as the result in the functions themselves(!)
  // and the result array here will keep getting duplicated each time!

  result := result + parseRomanNumerals(aWord);
  result := result + parseUniques(aWord);
  result := result + parseEnclitics(aWord);
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

//function TLatin.stripEnclitic(var aWord: string): TArray<string>;
//
//  function isMatch(const aWord: string; const aEnclitic: string): boolean;
//  begin
//    var vWordLen := length(aWord);
//    var vEncLen := length(aEnclitic);
//
//    result := (vWordLen > vEncLen) and (copy(aWord, vWordLen - vEncLen + 1, vEncLen) = aEnclitic);
//  end;
//
//begin
//  for var vTackOn in FTackOns do
//  begin
//    var vTackOnStr := trim(vTackOn.trTackOn);
//
//    while isMatch(aWord, vTackOnStr) do
//    begin
//      var vBaseLen := length(result);
//      setLength(result, vBaseLen + 2);
//      result[vBaseLen] := trim(vTackOn.trTargetPartOfSpeech) + '      TACKON';
//      result[vBaseLen + 1] := '-' + vTackOnStr + ' = ' + vTackOn.trSenses;
//
//      delete(aWord, length(aWord) - length(vTackOnStr) + 1, length(vTackOnStr));
//
//      result := result + stripEnclitic(aWord);
//
//      BREAK;
//    end;
//  end;
//end;

end.
