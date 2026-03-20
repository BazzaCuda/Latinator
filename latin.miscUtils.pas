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

unit latin.miscUtils;

interface

uses
  latin.types;

function expandArray(var aArray: TArray<string>;          const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TDictLineRec>;    const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TEsseRec>;        const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TInflectionsRec>; const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TParseResultRec>; const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TPrefixRec>;      const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TSuffixRec>;      const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TTackOnRec>;      const aIncrement: integer = 1): TVoid; overload;
function expandArray(var aArray: TArray<TUniquesRec>;     const aIncrement: integer = 1): TVoid; overload;

implementation

function expandArray(var aArray: TArray<string>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TDictLineRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TEsseRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TInflectionsRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TParseResultRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TPrefixRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TSuffixRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TTackOnRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

function expandArray(var aArray: TArray<TUniquesRec>; const aIncrement: integer = 1): TVoid; overload;
begin
  setLength(aArray, length(aArray) + aIncrement);
end;

end.
