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

unit latin.fileUtils;

interface

uses
  system.sysUtils, system.classes, system.generics.collections,
  latin.types;

function loadDictionary   (const aFilePath: string; var aDictIx: TDictionary<string, integer>): TArray<TDictLineRec>;
function loadEsse         (const aFilePath: string): TArray<TEsseRec>;
function loadInflections  (const aFilePath: string): TArray<TInflectionsRec>;
function loadPrefixes     (const aFilePath: string): TArray<TPrefixRec>;
function loadSuffixes     (const aFilePath: string): TArray<TSuffixRec>;
function loadTackOns      (const aFilePath: string): TArray<TTackOnRec>;
function loadUniques      (const aFilePath: string): TArray<TUniquesRec>;

implementation

uses
  latin.miscUtils,
  _debugWindow;

function loadDictionary(const aFilePath: string; var aDictIx: TDictionary<string, integer>): TArray<TDictLineRec>;

  function addIndexEntry(const aStem: array of char; aIndex: integer): TVoid;
  var
    vStemKey: string;
  begin
    vStemKey := trim(aStem);
    case (vStemKey <> '') and (vStemKey <> 'zzz') of TRUE: aDictIx.addOrSetValue(vStemKey, aIndex); end;
  end;

begin
  var vFixedDataSize := (pByte(@TDictLineRec(nil^).dictTranslation) - pByte(nil)) div sizeOf(char);
  var vLineCount := 0;
  aDictIx.clear;
  var vReader := TStreamReader.create(aFilePath, TEncoding.UTF8);
  try
    while not vReader.endOfStream do
    begin
      var vLine := vReader.readLine;
      case (vLine = '') of TRUE: CONTINUE; end;

      inc(vLineCount);
      expandArray(result);

      //case length(vLine) < vFixedDataSize of TRUE: CONTINUE; end;

      move(vLine[1], result[vLineCount - 1], vFixedDataSize * sizeOf(char));
      result[vLineCount - 1].dictTranslation := copy(vLine, vFixedDataSize + 1, length(vLine));

//      case vLineCount = 796 of TRUE: begin
//                                      debugString('stem1',        string(result[vLineCount - 1].dictStem1));
//                                      debugString('stem2',        string(result[vLineCount - 1].dictStem2));
//                                      debugString('stem3',        string(result[vLineCount - 1].dictStem3));
//                                      debugString('stem4',        string(result[vLineCount - 1].dictStem4));
//                                      debugString('partOfSpeech', string(result[vLineCount - 1].dictPartOfSpeech));
//                                      debugString('class',        string(result[vLineCount - 1].dictClass));
//                                      debugString('variant',      string(result[vLineCount - 1].dictVariant));
//                                      debugString('case/type',    string(result[vLineCount - 1].dictVNARec.dictCaseType));
//                                      debugString('nounGender',   string(result[vLineCount - 1].dictVNARec.dictNounGender));
//                                      debugString('nounType',     string(result[vLineCount - 1].dictVNARec.dictNounType));
//                                      debugString('Degree',       string(result[vLineCount - 1].dictVNARec.dictDegree));
//                                      debugString('age',          string(result[vLineCount - 1].dictAge));
//                                      debugString('area',         string(result[vLineCount - 1].dictArea));
//                                      debugString('geography',    string(result[vLineCount - 1].dictGeography));
//                                      debugString('frequency',    string(result[vLineCount - 1].dictFrequency));
//                                      debugString('source',       string(result[vLineCount - 1].dictSource));
//                                      debugString('translation',  string(result[vLineCount - 1].dictTranslation));
//                                    end;end;

      addIndexEntry(result[vLineCount - 1].dictStem1, vLineCount - 1);
      addIndexEntry(result[vLineCount - 1].dictStem2, vLineCount - 1);
      addIndexEntry(result[vLineCount - 1].dictStem3, vLineCount - 1);
      addIndexEntry(result[vLineCount - 1].dictStem4, vLineCount - 1);
    end;
  finally
    vReader.free;
  end;
end;

function loadEsse(const aFilePath: string): TArray<TEsseRec>;
begin
  var vFixedDataSize := sizeOf(TEsseRec) div sizeOf(char);
  var vLineCount := 0;
  var vReader := TStreamReader.create(aFilePath, TEncoding.UTF8);
  try
    while not vReader.endOfStream do
    begin
      var vLine := vReader.readLine;
      case (vLine = '') or (vLine[1] = '-') of TRUE: CONTINUE; end;

      inc(vLineCount);
      expandArray(result);

      //case length(vLine) < vFixedDataSize of TRUE: CONTINUE; end;

      move(vLine[1], result[vLineCount - 1], vFixedDataSize * sizeOf(char));

//      case vLineCount = 12 of TRUE: begin
//                                      debugString('word',         string(result[vLineCount - 1].erWord));
//                                      debugString('partOfSpeech', string(result[vLineCount - 1].erPartOfSpeech));
//                                      debugString('tense',        string(result[vLineCount - 1].erTense));
//                                      debugString('voice',        string(result[vLineCount - 1].erVoice));
//                                      debugString('mood',         string(result[vLineCount - 1].erMood));
//                                      debugString('person',       string(result[vLineCount - 1].erPerson));
//                                      debugString('number',       string(result[vLineCount - 1].erNumber));
//                                    end;end;
    end;
  finally
    vReader.free;
  end;
end;

function loadInflections(const aFilePath: string): TArray<TInflectionsRec>;
begin
  var vFixedDataSize := (pByte(@TInflectionsRec(nil^).irComment) - pByte(nil)) div sizeOf(char);
  var vLineCount := 0;
  var vReader := TStreamReader.create(aFilePath, TEncoding.UTF8);
  try
    while not vReader.endOfStream do
    begin
      var vLine := vReader.readLine;
      case (vLine = '') or (vLine[1] = '-') of TRUE: CONTINUE; end;

      inc(vLineCount);
      expandArray(result);

      //case length(vLine) < vFixedDataSize of TRUE: CONTINUE; end;

      move(vLine[1], result[vLineCount - 1], vFixedDataSize * sizeOf(char));
      case length(vLine) > vFixedDataSize of TRUE: result[vLineCount - 1].irComment := copy(vLine, vFixedDataSize + 1, length(vLine)); end;

//      case vLineCount < 44 of TRUE: begin
//                                      debugString('partOfSpeech', string(FInflections[vLineCount - 1].irPartOfSpeech));
//                                      debugString('class',        string(FInflections[vLineCount - 1].irClass));
//                                      debugString('variant',      string(FInflections[vLineCount - 1].irVariant));
//                                      debugString('case',         string(FInflections[vLineCount - 1].irCase));
//                                      debugString('number',       string(FInflections[vLineCount - 1].irNumber1));
//                                      debugString('gender',       string(FInflections[vLineCount - 1].irGender));
//                                      debugString('degree/tense', string(FInflections[vLineCount - 1].irDegreeTense));
//                                      debugString('voice',        string(FInflections[vLineCount - 1].irVoice));
//                                      debugString('mood',         string(FInflections[vLineCount - 1].irMood));
//                                      debugString('person',       string(FInflections[vLineCount - 1].irPerson));
//                                      debugString('number2',      string(FInflections[vLineCount - 1].irNumber2));
//                                      debugString('stemID',       string(FInflections[vLineCount - 1].irStemID));
//                                      debugString('suffix len',   string(FInflections[vLineCount - 1].irSuffixLength));
//                                      debugString('suffix',       string(FInflections[vLineCount - 1].irSuffix));
//                                      debugString('age',          string(FInflections[vLineCount - 1].irAge));
//                                      debugString('frequency',    string(FInflections[vLineCount - 1].irFrequency));
//                                      debugString('comment',      string(FInflections[vLineCount - 1].irComment));
//                                    end;end;
    end;
  finally
    vReader.free;
  end;
end;

function loadPrefixes(const aFilePath: string): TArray<TPrefixRec>;
begin
  var vFixedDataSize := (pByte(@TPrefixRec(nil^).prSenses) - pByte(nil)) div sizeOf(char);
  var vLineCount := 0;
  var vReader := TStreamReader.create(aFilePath, TEncoding.UTF8);
  try
    while not vReader.endOfStream do
    begin
      var vLine := vReader.readLine;
      case (vLine = '') or (vLine[1] = '-') of   TRUE: CONTINUE; end;
      case                 (vLine[1] = 'P') of  FALSE: CONTINUE; end;

      inc(vLineCount);
      expandArray(result);

      move(vLine[1], result[vLineCount - 1], vFixedDataSize * sizeOf(char));
      case length(vLine) > vFixedDataSize of TRUE: result[vLineCount - 1].prSenses := copy(vLine, vFixedDataSize + 1, length(vLine)); end;

//      case vLineCount = 85 of TRUE: begin
//                                      debugString('recType',         string(result[vLineCount - 1].prRecType));
//                                      debugString('prefix',          string(result[vLineCount - 1].prPrefix));
//                                      debugString('connector',       string(result[vLineCount - 1].prConnector));
//                                      debugString('sourcePOS',       string(result[vLineCount - 1].prSourcePartOfSpeech));
//                                      debugString('targetPOS',       string(result[vLineCount - 1].prTargetPartOfSpeech));
//                                      debugString('senses',          string(result[vLineCount - 1].prSenses));
//                                    end;end;
    end;
  finally
    vReader.free;
  end;
end;

function loadSuffixes(const aFilePath: string): TArray<TSuffixRec>;
begin
  var vFixedDataSize := (pByte(@TSuffixRec(nil^).srSenses) - pByte(nil)) div sizeOf(char);
  var vLineCount := 0;
  var vReader := TStreamReader.create(aFilePath, TEncoding.UTF8);
  try
    while not vReader.endOfStream do
    begin
      var vLine := vReader.readLine;
      case (vLine = '') or (vLine[1] = '-') of   TRUE: CONTINUE; end;
      case                 (vLine[1] = 'S') of  FALSE: CONTINUE; end;

      inc(vLineCount);
      expandArray(result);

      move(vLine[1], result[vLineCount - 1], vFixedDataSize * sizeOf(char));
      case length(vLine) > vFixedDataSize of TRUE: result[vLineCount - 1].srSenses := copy(vLine, vFixedDataSize + 1, length(vLine)); end;

//      case vLineCount = 93 of TRUE: begin
//                                      debugString('recType',         string(result[vLineCount - 1].srRecType));
//                                      debugString('suffix',          string(result[vLineCount - 1].srSuffix));
//                                      debugString('connector',       string(result[vLineCount - 1].srConnector));
//                                      debugString('sourcePOS',       string(result[vLineCount - 1].srSourcePartOfSpeech));
//                                      debugString('sourceStemID',    string(result[vLineCount - 1].srSourceStemID));
//                                      debugString('targetPOS',       string(result[vLineCount - 1].srTargetPartOfSpeech));
//                                      debugString('targetClass',     string(result[vLineCount - 1].srTargetClass));
//                                      debugString('targetVariant',   string(result[vLineCount - 1].srTargetVariant));
//                                      debugString('adjDegree',       string(result[vLineCount - 1].srDegree));
//                                      debugString('verbType',        string(result[vLineCount - 1].srVerbType));
//                                      debugString('numValue',        string(result[vLineCount - 1].srNumValue));
//                                      debugString('nounGender',      string(result[vLineCount - 1].srNounGender));
//                                      debugString('nounNumber',      string(result[vLineCount - 1].srNounNumber));
//                                      debugString('targetStemID',    string(result[vLineCount - 1].srTargetStemID));
//                                      debugString('senses',          string(result[vLineCount - 1].srSenses));
//                                    end;end;
    end;
  finally
    vReader.free;
  end;
end;

function loadTackOns(const aFilePath: string): TArray<TTackOnRec>;
begin
  var vFixedDataSize := (pByte(@TTackOnRec(nil^).trSenses) - pByte(nil)) div sizeOf(char);
  var vLineCount := 0;
  var vReader := TStreamReader.create(aFilePath, TEncoding.UTF8);
  try
    while not vReader.endOfStream do
    begin
      var vLine := vReader.readLine;
      case (vLine = '') or (vLine[1] = '-') of   TRUE: CONTINUE; end;
      case                 (vLine[1] = 'T') of  FALSE: CONTINUE; end;

      inc(vLineCount);
      expandArray(result);

      move(vLine[1], result[vLineCount - 1], vFixedDataSize * sizeOf(char));
      case length(vLine) > vFixedDataSize of TRUE: result[vLineCount - 1].trSenses := copy(vLine, vFixedDataSize + 1, length(vLine)); end;

//      case vLineCount = 17 of TRUE: begin
//                                      debugString('recType',         string(result[vLineCount - 1].trRecType));
//                                      debugString('tackon',          string(result[vLineCount - 1].trTackOn));
//                                      debugString('targetPOS',       string(result[vLineCount - 1].trTargetPartOfSpeech));
//                                      debugString('targetClass',     string(result[vLineCount - 1].trTargetClass));
//                                      debugString('targetVariant',   string(result[vLineCount - 1].trTargetVariant));
//                                      debugString('degree',          string(result[vLineCount - 1].trDegree));
//                                      debugString('nounGender',      string(result[vLineCount - 1].trNounGender));
//                                      debugString('nounNumber',      string(result[vLineCount - 1].trNounNumber));
//                                      debugString('senses',          string(result[vLineCount - 1].trSenses));
//                                    end;end;
    end;
  finally
    vReader.free;
  end;
end;

function loadUniques(const aFilePath: string): TArray<TUniquesRec>;
begin
  var vFixedDataSize := (pByte(@TUniquesRec(nil^).urTranslation) - pByte(nil)) div sizeOf(char);
  var vLineCount := 0;
  var vReader := TStreamReader.create(aFilePath, TEncoding.UTF8);
  try
    while not vReader.endOfStream do
    begin
      var vLine := vReader.readLine;
      case (vLine = '') of TRUE: CONTINUE; end;

      inc(vLineCount);
      expandArray(result);

      move(vLine[1], result[vLineCount - 1], vFixedDataSize * sizeOf(char));
      case length(vLine) > vFixedDataSize of TRUE: result[vLineCount - 1].urTranslation := copy(vLine, vFixedDataSize + 1, length(vLine)); end;

      case vLineCount = 17 of TRUE: begin
                                      debugString('word',         string(result[vLineCount - 1].urWord));
                                      debugString('partOfSpeech', string(result[vLineCount - 1].urPartOfSpeech));
                                      debugString('class',        string(result[vLineCount - 1].urClass));
                                      debugString('variant',      string(result[vLineCount - 1].urVariant));
                                      debugString('case',         string(result[vLineCount - 1].urCase));
                                      debugString('number1',      string(result[vLineCount - 1].urNumber1));
                                      debugString('nounGender',   string(result[vLineCount - 1].urNounGender));
                                      debugString('nounType',     string(result[vLineCount - 1].urNounType));
                                      debugString('Degree',       string(result[vLineCount - 1].urDegree));
                                      debugString('pronounType',  string(result[vLineCount - 1].urPronounType));
                                      debugString('tense',        string(result[vLineCount - 1].urTense));
                                      debugString('voice',        string(result[vLineCount - 1].urVoice));
                                      debugString('mood',         string(result[vLineCount - 1].urMood));
                                      debugString('person',       string(result[vLineCount - 1].urPerson));
                                      debugString('number2',      string(result[vLineCount - 1].urNumber2));
                                      debugString('verbType',     string(result[vLineCount - 1].urVerbType));
                                      debugString('age',          string(result[vLineCount - 1].urAge));
                                      debugString('area',         string(result[vLineCount - 1].urArea));
                                      debugString('geography',    string(result[vLineCount - 1].urGeography));
                                      debugString('frequency',    string(result[vLineCount - 1].urFrequency));
                                      debugString('source',       string(result[vLineCount - 1].urSource));
                                      debugString('translation',  string(result[vLineCount - 1].urTranslation));
                                    end;end;
    end;
  finally
    vReader.free;
  end;
end;

end.
