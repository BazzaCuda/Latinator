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

unit latin.stringUtils;

interface

function cleanSentences     (const aString: string): string;
function extractSentences   (const aString: string): TArray<string>;
function removeMacrons      (const aString: string): string;
function romanNumerals      (const aString: string): boolean;
function romanNumeralsToInt (const aString: string): integer;

implementation

uses
  winApi.windows,
  system.regularExpressions,
  latin.charUtils;

function cleanSentences(const aString: string): string;
// [^ ... ]  negated set matching any character not listed
// a-zA-Z    permits all English Alphabet letters
// space     permits only a space and no other whitespace characters
// \.\!\?    permits a period, exclamation mark, and question mark as sentence terminators
// ' '       replaces all other characters with a space to preserve word boundaries
begin
  result := TRegEx.replace(aString, '[^a-zA-Z \.\!\?]', ' ');
end;

function extractSentences(const aString: string): TArray<string>;
// split using the only permitted sentence terminators in cleanSentences
begin
  result := TRegEx.split(aString, '[.\!\?]');
end;

function removeMacrons(const aString: string): string;
begin
  var vSize := normalizeString(normalizationD, pChar(aString), -1, NIL, 0);
  setLength(result, vSize);
  vSize := normalizeString(normalizationD, pChar(aString), -1, pChar(result), vSize);
  setLength(result, vSize - 1);
end;

function romanNumerals(const aString: string): boolean;
// ^          start of string
// [ivxlcdm]  allowed characters
// +          one or more times
// $          end of string

// ^                        start of string
// m*                       thousands, any number of times (restriction on this were a Renaissance thing)
// cm|cd|d?c{0,4}           hundreds from 100-900 whether as, e.g., CM or DCCC
// xc|xl|l?x{0,4}           tens from 10-90, with e.g. XL or an optional L followed by up to four XXXX = LXXXX
// ix|iv|v?i{0,4}           ones from 1-9, with e.g. IX or an optional V, followed by up to four IIII  = VIIII
// $                        end of string

// The first version was a useful first attempt for writing the fledgling Latin parsing architecture/approach.
// However, it doesn't fail for cases such as "vix" which is a valid Latin word but not a valid roman numeral.
// The second pattern ensures that numerals appear in descending category order of Thousands, Hundreds, Tens, Units.
// Because "v" belongs to the Units category and "x" belongs to the Tens category, the string "vix" fails because it violates this sequence.
begin
//  result := TRegEx.isMatch(aString, '^[ivxlcdm]+$');
  result := TRegEx.isMatch(aString, '^m*(cm|cd|d?c{0,4})(xc|xl|l?x{0,4})(ix|iv|v?i{0,4})$');
end;

function romanNumeralsToInt(const aString: string): integer;
begin
  result := 0;

  var vRightDigit:    integer := 0;
  var vCurrentDigit:  integer := 0;

  for var i := length(aString) downto 1 do
  begin
    vCurrentDigit := romanCharToInt(aString[i]);
    case (vCurrentDigit < vRightDigit) of
       TRUE: result := result - vCurrentDigit;
      FALSE: result := result + vCurrentDigit;
    end;
    vRightDigit := vCurrentDigit;
  end;
end;

end.
