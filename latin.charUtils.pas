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

unit latin.charUtils;

interface

function isVowel(const aChar: char): boolean;
function romanCharToInt(const aChar: char): integer;

implementation

function isVowel(const aChar: char): boolean;
begin
  result := aChar in ['a', 'e', 'i', 'o', 'u', 'y', 'A', 'E', 'I', 'O', 'U', 'Y'];
end;

function romanCharToInt(const aChar: char): integer;
begin
  result := 0;
  case aChar of
    'i': result :=    1;
    'v': result :=    5;
    'x': result :=   10;
    'l': result :=   50;
    'c': result :=  100;
    'd': result :=  500;
    'm': result := 1000;
  end;
end;

end.
