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

unit latin.consts;

interface

uses
  latin.types;

const
  MAX_STEM      = 18;
  SIZE_OF_CHAR  =  2;

  ENCLITIC_TACKONS: array[0..3] of string = ('que', 'ne', 've', 'est');

  PRONOMINAL_MAPS: array[0..5] of TPronominalMap = (
    (pmSearchString: 'aliqu'; pmPrefix: 'ali'; pmStemType: stQu),
    (pmSearchString: 'alicu'; pmPrefix: 'ali'; pmStemType: stCu),
    (pmSearchString: 'ecqu';  pmPrefix: 'ec';  pmStemType: stQu),
    (pmSearchString: 'eccu';  pmPrefix: 'ec';  pmStemType: stCu),
    (pmSearchString: 'qu';    pmPrefix: '';    pmStemType: stQu),
    (pmSearchString: 'cu';    pmPrefix: '';    pmStemType: stCu)
  );

  USER_TRICKS           = TRUE;
  USER_NOUN_CASE_ORDER  = ncoNomAcc;
  USER_NOUN_DEBUG       = FALSE;

  NOUN_CASE_MAX = 6; // 0-based
  NOUN_CASE_ORDER_STD: array[0..6] of TNounCase = (ncNominative, ncVocative, ncAccusative, ncGenitive, ncDative, ncAblative, ncLocative);

  // my condolences: Wheelock was a buffoon! :P :D
  NOUN_CASE_ORDER_US:  array[0..6] of TNounCase = (ncNominative, ncGenitive, ncDative, ncAccusative, ncVocative, ncAblative, ncLocative);

  MAP_CONSOLE_COMMANDS: array[0..9] of TConsoleCommandMapping = (
    (cmInput: 'cls';     cmCommand: ccCLS),
    (cmInput: 'nn';      cmCommand: ccDeclineNoun),
    (cmInput: 'aa';      cmCommand: ccDeclineAdjective),
    (cmInput: 'vv';      cmCommand: ccConjugateVerb),
    (cmInput: 'ww';      cmCommand: ccWW),
    (cmInput: 'ls';      cmCommand: ccLS),
    (cmInput: 'las';     cmCommand: ccLoadLS),
    (cmInput: 'export';  cmCommand: ccExportLS),
    (cmInput: 'import';  cmCommand: ccImportLS),
    (cmInput: 'clear';   cmCommand: ccClearLS)
  );

  MAP_CLASS_CLASSES:          array[cc1..cc9]                   of char   = ('1', '2', '3', '4', '5', '6', '7', '8', '9');
  MAP_CLASS_LABELS:           array[cc1..cc9]                   of string = ('1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th');
  MAP_CLASS_VARIANTS:         array[cv1..cv9]                   of char   = ('1', '2', '3', '4', '5', '6', '7', '8', '9');
  MAP_NOUN_CASES:             array[ncNominative..ncLocative]   of string = ('NOM', 'VOC', 'ACC', 'GEN', 'DAT', 'ABL', 'LOC');
  MAP_NOUN_DECLENSION_LABELS: array[cc1..cc9]                   of string = ('1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th');
  MAP_NOUN_GENDERS:           array[ngMasculine..ngAll]         of char   = ('M', 'F', 'N', 'C', 'X');
  MAP_NOUN_GENDER_LABELS:     array[ngMasculine..ngAll]         of string = ('masculine', 'feminine', 'neuter', 'masculine/feminine', 'all');
  MAP_VERB_TENSES:            array[vtPluperfect..vtSupine]     of string = ('PLUP', 'PERF', 'IMPF', 'PRES', 'FPERF', 'FUT', 'SUPI');
  MAP_VERB_TENSE_LABELS:      array[vtPluperfect..vtSupine]     of string = ('Pluperfect', 'Perfect', 'Imperfect', 'Present', 'Future Perfect', 'Future', 'Supine');
  MAP_VERB_MOODS:             array[vmIndicative..vmInfinitive] of string = ('IND', 'SUB', 'IMP', 'INF');
  MAP_VERB_MOOD_LABELS:       array[vmIndicative..vmInfinitive] of string = ('Indicative', 'Subjunctive', 'Imperative', 'Infinitive');
  MAP_VERB_NUMBERS:           array[vnSingular..vnPlural]       of char   = ('S', 'P');
  MAP_VERB_PERSONS:           array[vpFirst..vpThird]           of char   = ('1', '2', '3');
  MAP_VERB_PERSON_LABELS:     array[vpFirst..vpThird]           of string = ('1st', '2nd', '3rd');
  MAP_VERB_VOICES:            array[vvActive..vvPassive]        of string = ('ACTIVE', 'PASSIVE');
  MAP_VERB_VOICE_LABELS:      array[vvActive..vvPassive]        of string = ('Active', 'Passive');

implementation

end.
