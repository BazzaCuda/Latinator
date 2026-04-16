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
unit latin.dataExtractor;

interface

uses
  latin.types;

type
  IDataExtractor = interface
    function checkData:   boolean;
    function extractData: boolean;
    function setDataPath(const aDataPath: string): TVoid;
  end;

function newDataExtractor: IDataExtractor;

implementation

uses
  system.sysUtils,
  RAR,
  _debugWindow;

const
  DATA_FILES: array[1..18] of string =  ( 'DICTLINE.LAT',
                                          'ESSE.LAT',
                                          'INFLECTS.LAT',
                                          'UNIQUES.LAT',
                                          'ADDONS.LAT',
                                          'lat.ls.perseus-eng2.xml',
                                          'Lewis&Short.txt',
                                          'macronAdjectives.txt',
                                          'macronAdverbs1.txt',
                                          'macronAdverbs2.txt',
                                          'macronConjunctions.txt',
                                          'macronIndeclinables.txt',
                                          'macronNouns.txt',
                                          'macronNumbers.txt',
                                          'macronParticiples.txt',
                                          'macronPlaces.txt',
                                          'macronPronominals.txt',
                                          'macronVerbs.txt'
                                        );

type

  TDataExtractor = class(TInterfacedObject, IDataExtractor)
  strict private
    FDataPath: string;
  public
    function checkData:   boolean;
    function extractData: boolean;
    function setDataPath(const aDataPath: string): TVoid;
  end;

function newDataExtractor: IDataExtractor;
begin
  result := TDataExtractor.create;
end;

{ TDataExtractor }

function TDataExtractor.checkData: boolean;
// any missing file will trigger an extraction
begin
  result := TRUE;
  for var i := low(DATA_FILES) to high(DATA_FILES) do
    case fileExists(FDataPath + DATA_FILES[i]) of FALSE: EXIT(FALSE); end;
end;

function TDataExtractor.extractData: boolean;
begin
  result := FALSE;

  var vDatFile := FDataPath + 'wwData.dat';
  case fileExists(vDatFile) of FALSE: EXIT(FALSE); end;

  var vRAR := TRAR.create(NIL);
  try
    vRAR.extractArchive(vDatFile, FDataPath);
  finally
    vRAR.free;
  end;

  result := checkData;
end;

function TDataExtractor.setDataPath(const aDataPath: string): TVoid;
begin
  FDataPath := aDataPath;
end;

end.
