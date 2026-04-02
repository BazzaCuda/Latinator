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

unit latin.types;

interface

type
  TVoid = record end;

  TConsoleCommand = (ccNone, ccWW, ccDeclineNoun, ccDeclineAdjective, ccConjugateVerb, ccLS, ccLoadLS, ccExportLS, ccImportLS, ccClearLS);
  TConsoleContext = record
    ccCommand: TConsoleCommand;
    ccWW:      boolean;
    ccLS:      boolean;
  end;

  TConsoleCommandMapping = record
    cmInput:    string;
    cmCommand:  TConsoleCommand;
  end;

{ Whitaker's Words Data }

  TVerbNounAdjAdvRec = packed record
    case integer of
      0: (dictVNA:        array[1..12] of char;); // the variable fields at columns
      1: (dictCaseType:   array[1..12] of char;);
      2: (
          dictNounGender: char;
            filler2:  char;
          dictNounType:   char;
         );
      3: (dictDegree:     array[1..8] of char;);
      4: (dictNumKind:    array[1..4] of char;
          dictNumValue:   array[1..8] of char;);
  end;

  { Primary Part-of-Speech record mapping the DictLine.Lat file structure }
  TDictLineRec = packed record
    dictStem1:          array[1..18] of char;
      filler1:  char;
    dictStem2:          array[1..18] of char;
      filler2:  char;
    dictStem3:          array[1..18] of char;
      filler3:  char;
    dictStem4:          array[1..18] of char;
      filler4:  char;
    dictPartOfSpeech:   array[1..6] of char;
      filler5:  char;
    dictClass:          char;
      filler6:  char;
    dictVariant:        char;
      filler7:  char;
    dictVNARec:         TVerbNounAdjAdvRec; // variant columns 88-99
      filler8:  char;
    dictAge:            char;
      filler9:  char;
    dictArea:           char;
      filler10: char;
    dictGeography:      char;
      filler11: char;
    dictFrequency:      char;
      filler12: char;
    dictSource:         char;
      filler13: char;
    dictTranslation:    string;
  end;

  TEsseRec = packed record
    erWord:             array[1..10] of char;
      filler1:  char;
    erPartOfSpeech:     array[1..5] of char;
      filler2:  char;
    erTense:            array[1..5] of char;
      filler3:  char;
    erVoice:            array[1..7] of char;
      filler4:  char;
    erMood:             array[1..3] of char;
      filler5:  char;
    erPerson:           char;
      filler6:  char;
    erNumber:           char;
  end;

  TInflectionsRec = packed record
    irPartOfSpeech:     array[1..5] of char;
    irClass:            char;
      filler2:  char;
    irVariant:          char;
      filler3:  char;
    irCase:             array[1..3] of char;
      filler4:  char;
    irNumber1:          char;
      filler5:  char;
    irGender:           char;
      filler6:  char;
    irDegreeTense:      array[1..5] of char;
      filler7:  char;
    irVoice:            array[1..7] of char;
      filler8:  char;
    irMood:             array[1..3] of char;
      filler9:  char;
    irPerson:           char;
      filler10: char;
    irNumber2:          char;
      filler11: char;
    irStemID:           char;
      filler12: char;
    irSuffixLength:     char;
      filler13: char;
    irSuffix:           array[1..11] of char;
      filler14: char;
    irAge:              char;
      filler15: char;
    irFrequency:        char;
      filler16: char;
    irComment:          string;
  end;

  TParseResultRec = record
    prWord:         string;
    prPartOfSpeech: string;
    prStem:         string;
    prStem1:        string;
    prStem2:        string;
    prStem3:        string;
    prStem4:        string;
    prEnding:       string;
    prClass:        char;
    prVariant:      char;
    prCase:         string;
    prNumber1:      char;
    prGender:       char;
    prStemID:       char;
    prNounType:     char;
    prDegree:       string;
    prPronounType:  string;
    prTense:        string;
    prVoice:        string;
    prMood:         string;
    prPerson:       char;
    prNumber2:      char;
    prVerbType:     string;
    prAge:          char;
    prArea:         char;
    prGeography:    char;
    prFrequency:    char;
    prSource:       char;
    prNumKind:      string;
    prNumValue:     string;
    prExplanation:  string;
  end;

  TPrefixRec = packed record
    prRecType:            array[1..6] of char;
      filler1:  char;
    prPrefix:             array[1..15] of char;
      filler2:  char;
    prConnector:          char;
      filler3:  array[1..7] of char;
    prSourcePartOfSpeech: array[1..5] of char;
      filler4:  char;
    prTargetPartOfSpeech: array[1..5] of char;
      filler5:  char;
    prSenses:             string;
  end;

  TSuffixRec = packed record
    srRecType:            array[1..6] of char;
      filler1:  char;
    srSuffix:             array[1..10] of char;
      filler2:  char;
    srConnector:          char;
      filler3:  char;
    srSourcePartOfSpeech: array[1..5] of char;
      filler4:  char;
    srSourceStemID:       char;
      filler5:  char;
    srTargetPartOfSpeech: array[1..5] of char;
      filler6:  char;
    srTargetClass:        char;
      filler7:  char;
    srTargetVariant:      char;
      filler8:  char;
    srDegree:             array[1..8] of char;
      filler9:  char;
    srVerbType:           char;
    srNumValue:           char;
      filler10: char;
    srNounGender:         char;
      filler11: char;
    srNounNumber:         char;
      filler12: char;
    srTargetStemID:       char;
      filler13: char;
    srSenses:             string;
  end;

  TTackOnRec = packed record
    trRecType:            array[1..6] of char;
      filler1:  char;
    trTackOn:             array[1..10] of char;
      filler2:  array[1..11] of char;
    trTargetPartOfSpeech: array[1..5] of char;
      filler3:  char;
    trTargetClass:        char;
      filler4:  char;
    trTargetVariant:      char;
      filler5:  char;
    trDegree:             array[1..8] of char;
      filler6:  char;
    trNounGender:         char;
      filler7:  char;
    trNounNumber:         char;
      filler8:  array[1..3] of char;
    trSenses:             string;
  end;

  TUniquesRec = packed record
    urWord:             array[1..22] of char;
      filler1:  char;
    urPartOfSpeech:     array[1..5] of char;
      filler2:  char;
    urClass:            char;
      filler3:  char;
    urVariant:          char;
      filler4:  char;
    urCase:             array[1..3] of char;
      filler5:  char;
    urNumber1:          char;
      filler6:  char;
    urNounGender:       char;
      filler7:  char;
    urNounType:         char;
      filler8:  char;
    urDegree:           array[1..8] of char;
      filler9:  char;
    urPronounType:      array[1..6] of char;
      filler10: char;
    urTense:            array[1..5] of char;
      filler11: char;
    urVoice:            array[1..7] of char;
      filler12: char;
    urMood:             array[1..3] of char;
      filler13: char;
    urPerson:           char;
      filler14: char;
    urNumber2:          char;
      filler15: char;
    urVerbType:         array[1..8] of char;
      filler16: char;
    urAge:              char;
      filler17: char;
    urArea:             char;
      filler18: char;
    urGeography:        char;
      filler19: char;
    urFrequency:        char;
      filler20: char;
    urSource:           char;
      filler21: char;
    urTranslation:      string;
  end;

{ Lewis & Short }

  TWRecord = packed record
    wrRecType:   char;
    wrFiller:    char;
    wrKey:       array[0..63] of char;
    wrID:        array[0..47] of char;
    wrEntryType: array[0..23] of char;
    wrLanguage:  array[0..23] of char;
  end;

  TMRecord = packed record
    mrRecType:      char;
    mrFiller:       char;
    mrGender:       array[0..11] of char;
    mrInflection:   array[0..31] of char;
    mrPartOfSpeech: array[0..23] of char;
    mrMood:         array[0..23] of char;
    mrCase:         array[0..23] of char;
  end;

  TORecord = packed record
    orRecType:      char;
    orFiller:       char;
    orOrthography:  array[0..63] of char;
    orOrthography2: array[0..63] of char;
  end;

  TSRecord = packed record
    srRecType: char;
    srFiller1: char;
    srLevel:   char;
    srFiller2: char;
    srN:       array[0..15] of char;
    srID:      array[0..47] of char;
  end;

{ Latin-English Parsing }

  TStemType = (stNone, stQu, stCu);

  TPronominalMap = record
    pmSearchString: string;
    pmPrefix:       string;
    pmStemType:     TStemType;
  end;

  TPronominalContext = record
    pcFullWord: string;
    pcPrefix:   string;
    pcTackOn:   string;
    prSenses:   string;
  end;

  TParseContext = record
    pcConsoleCommand: TConsoleCommand;
    pcNextWord: string;
    pcNextUsed: boolean;
    pcTricks:   boolean;
  end;

{ Verb Conjugations and Noun/Adjective/etc Declensions }

  // Person, Number, Tense, Mood, Voice: amo = first person singular, present indicative active
  TVerbPerson = (vpNone, vpFirst, vpSecond, vpThird);
  TVerbNumber = (vnNone, vnSingular, vnPlural);
  TVerbTense  = (vtNone, vtPluperfect, vtPerfect, vtImperfect, vtPresent, vtFuturePerfect, vtFuture);
  TVerbMood   = (vmNone, vmIndicative, vmSubjunctive, vmImperative, vmInfinitive);
  TVerbVoice  = (vvNone, vvActive, vvPassive);

  // Case, Number, Gender: amicum = accusative singular masculine
  TNounCase   = (ncNone, ncNominative, ncVocative, ncAccusative, ncGenitive, ncDative, ncAblative, ncLocative);
  TNounNumber = (nnNone, nnSingular, nnPlural);
  TNounGender = (ngNone, ngMasculine, ngFeminine, ngNeuter, ngCommon, ngAll);

  TVerbalSubstantive = (vsParticiple, vsGerund, vsGerundive, vsSupine);

  TAdjectiveDegrees = (adPositive, adComparative, adSuperlative);

  TClassClass    = ({cccNone,} cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8, cc9); // BAZ EXPERIMENTAL
  TClassVariant  = ({cvNone,} cv1, cv2, cv3, cv4, cv5, cv6, cv7, cv8, cv9);  // BAZ EXPERIMENTAL

  // Person, Number, Tense, Mood, Voice: amo = first person singular, present indicative active
  TVerbContext = record
    vcPerson:   TVerbPerson;
    vcNumber:   TVerbNumber;
    vcTense:    TVerbTense;
    vcMood:     TVerbMood;
    vcVoice:    TVerbVoice;
    vcClass:    TClassClass;
    vcVariant:  TClassVariant;
    vcStem1:    string;
    vcStem2:    string;
    vcStem3:    string;
    vcStem4:    string;
  end;

  TVerbConjugation = record
    vcStemID:     char;
    vcSuffix:     string;
    vcAge:        char;
    vcFrequency:  char;
  end;

  TVerbData = array[TVerbTense, TVerbVoice, TVerbMood, TVerbPerson, TVerbNumber] of TArray<TVerbConjugation>;

  // Case, Number, Gender: amicum = accusative singular masculine
  TNounContext = record
    ncCase:     TNounCase;
    ncNumber:   TNounNumber;
    ncGender:   TNounGender;
    ncClass:    TClassClass;
    ncVariant:  TClassVariant;
    ncStem1:    string;
    ncStem2:    string;
    ncStem3:    string;
    ncStem4:    string;
  end;

  TNounTable = array[ncNominative..ncLocative, nnSingular..nnPlural, ngMasculine..ngNeuter] of string;
  TVerbTable = array[vpFirst..vpThird, vnSingular..vnPlural] of string;

  // e.g.
  // function nounDeclension(const aContext: TNounContext): TNounTable;
  // function verbConjugation(const aContext: TVerbContext): TVerbTable;
  // var vNounTable := nounDeclension(myContext);
  // ... vNounTable[ncNominative, nnSingular, ngMasculine]

  TNounInflection = record
    niStemID:    char;
    niSuffix:    string;
    niGender:    char;
    niAge:       char;
    niFrequency: char;
  end;

  TNounData = array[TClassClass, TClassVariant, ncNominative..ncLocative, nnSingular..nnPlural, ngMasculine..ngNeuter] of TArray<TNounInflection>;

  // For a noun: Case, Singular, Plural, N/A
  // For an adjective: Case, Masculine, Feminine, Neuter
  TNounRow = array[0..3] of string;

  // The first row[ncNone] contains the column headers
  TGrammarTable = array[ncNone..ncLocative] of TNounRow;

  TNounCaseOrder = (ncoNomAcc, ncoNomGen);

implementation

end.

Don't use LaTeX formatting.
