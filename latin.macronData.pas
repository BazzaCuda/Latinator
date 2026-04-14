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
unit latin.macronData;

interface

const
  MAX_LEN_DEGREE        =   2;
  MAX_LEN_ENGLISH       = 180;
  MAX_LEN_GENITIVE      =  60;
  MAX_LEN_LATIN         =  40;
  MAX_LEN_MOOD          =   3;
  MAX_LEN_NOUN_CASE     =   3;
  MAX_LEN_NUMBER        =  40;
  MAX_LEN_POS           =   4;
  MAX_LEN_ROMAN_DIGITS  =  20;
  MAX_LEN_TENSE         =   3;
  MAX_LEN_WORD          =  20;
  MAX_LEN_VARIANT       =  50;
  MAX_INDECLINABLES     = 11;

type
  TAdjectiveRec = packed record
    fillerVoice:   char;                                  mrFiller1: char; // A/ctive P/assive
    fillerMood:    array[1..MAX_LEN_MOOD]       of char;  mrFiller2: char; // IND SUB INF IPV PAR
    fillerTense:   array[1..MAX_LEN_TENSE]      of char;  mrFiller3: char; // PRS IMP FUT PRF PLU FPF + GDV GND SUP
    fillerPerson:  char;                                  mrFiller4: char; // 1/st 2/nd 3/rd (Blank for Participles/Infinitives)
//
    mrGender:      char;                                  mrFiller5: char; // M/asculine, F/eminine, N/euter
    mrNumber:      char;                                  mrFiller6: char; // S/ingular P/lural
    mrCase:        array[1..MAX_LEN_NOUN_CASE]  of char;  mrFiller7: char; // NOM VOC ACC GEN DAT ABL
    mrDegree:      array[1..MAX_LEN_DEGREE]     of char;  mrFiller8: char; // P/ositive, C/omparative, S/uperlative
  end;

type
  TIndeclinableRec = packed record
    case integer of
      0: (mrIndeclinables:  array[1..MAX_INDECLINABLES] of char);
      1: (mrMovement:       char; // M
          mrSpatial:        char; // S
          mrTemporal:       char; // T
          mrCausal:         char; // C
          mrQuestion:       char; // Q
          mrQuantity:       char; // V (e.g. Volume)
          mrNumeric:        char; // N
          mrOther:          char; // O
          mrAccusative:     char; // A
          mrAblative:       char; // B
          mrGenitive:       char; // G
         )
  end;

  TNounRec = packed record
    fillerVoice:   char;                                  mrFiller1: char; // A/ctive P/assive
    fillerMood:    array[1..MAX_LEN_MOOD]       of char;  mrFiller2: char; // IND SUB INF IPV PAR
    fillerTense:   array[1..MAX_LEN_TENSE]      of char;  mrFiller3: char; // PRS IMP FUT PRF PLU FPF + GDV GND SUP
    fillerPerson:  char;                                  mrFiller4: char; // 1/st 2/nd 3/rd (Blank for Participles/Infinitives)
//
    mrGender:      char;                                  mrFiller5: char; // M/asculine, F/eminine, N/euter, C/ommon
    mrNumber:      char;                                  mrFiller6: char; // S/ingular P/lural
    mrCase:        array[1..MAX_LEN_NOUN_CASE]  of char;  mrFiller7: char; // NOM VOC ACC GEN DAT ABL
  end;

  TNumberRec = packed record
    mrNumberDigits: array[1..05]                    of char; mrFiller1: char;
    mrRomanDigits:  array[1..MAX_LEN_ROMAN_DIGITS]  of char; mrFiller2: char;
    mrCardinal:     array[1..MAX_LEN_NUMBER * 2]    of char; mrFiller3: char;
    mrOrdinal:      array[1..MAX_LEN_NUMBER * 2]    of char; mrFiller4: char;
    mrAdverb:       array[1..MAX_LEN_NUMBER]        of char; mrFiller5: char;
    mrTimes:        array[1..MAX_LEN_NUMBER * 2]    of char; mrFiller6: char;
    mrDistributive: array[1..MAX_LEN_NUMBER]        of char; mrFiller7: char;
    mrEach:         array[1..MAX_LEN_NUMBER * 2]    of char; mrFiller8: char;
  end;

  TVerbRec = packed record
    mrVoice:       char;                                  mrFiller1: char; // A/ctive P/assive
    mrMood:        array[1..MAX_LEN_MOOD]   of char;      mrFiller2: char; // IND SUB INF IPV PAR
    mrTense:       array[1..MAX_LEN_TENSE]  of char;      mrFiller3: char; // PRS IMP FUT PRF PLU FPF + GDV GND SUP
    mrPerson:      char;                                  mrFiller4: char; // 1/st 2/nd 3/rd (Blank for Participles/Infinitives)
    mrGender:      char;                                  mrFiller5: char; // M/F/N (For Participles only, blank for finite verbs)
    mrNumber:      char;                                  mrFiller6: char; // S/ingular P/lural (Blank for Infinitives)
    mrCase:        array[1..MAX_LEN_NOUN_CASE] of char;   mrFiller7: char; // NOM...ABL (For Participles/Gerunds/Supines only)
  end;

  TVariantRec = packed record
    case integer of
      0: (noun: TNounRec);
      1: (verb: TVerbRec);
      2: (adjective: TAdjectiveRec);
      3: (indeclinable: TIndeclinableRec);

      4: (raw:  array[1..MAX_LEN_VARIANT] of char); // Ensures all variants pad out to the exact same fixed width in the text file
  end;

  TMacronRec = packed record
    // --- COMMON LEXEME DATA ---
    mrPOS:         array[1..MAX_LEN_POS]        of char;  mrFiller1: char; // NOUN, VERB, ADJ, PART
    mrHeadWord:    array[1..MAX_LEN_WORD]       of char;  mrFiller2: char; // puella
    mrGenitive:    array[1..MAX_LEN_GENITIVE]   of char;  mrFiller3: char; // puellae (or 2nd principal part for verbs)
    mrClass:       char;                                  mrFiller4: char; // 1-5 (Declension) or 1-4 (Conjugation)

    // --- MORPHOLOGY (Reads differently based on POS) ---
    variant:       TVariantRec;

    // --- RESULT ---
    mrInflected:   array[1..MAX_LEN_LATIN]      of char;  mrFiller5: char;
    mrEnglish:     array[1..MAX_LEN_ENGLISH]    of char;
  end;

implementation

end.
