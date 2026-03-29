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
  MAX_STEM_SIZE = 18;

  ENCLITIC_TACKONS: array[0..3] of string = ('que', 'ne', 've', 'est');

  PRONOMINAL_MAPS: array[0..5] of TPronominalMap = (
    (pmSearchString: 'aliqu'; pmPrefix: 'ali'; pmStemType: stQu),
    (pmSearchString: 'alicu'; pmPrefix: 'ali'; pmStemType: stCu),
    (pmSearchString: 'ecqu';  pmPrefix: 'ec';  pmStemType: stQu),
    (pmSearchString: 'eccu';  pmPrefix: 'ec';  pmStemType: stCu),
    (pmSearchString: 'qu';    pmPrefix: '';    pmStemType: stQu),
    (pmSearchString: 'cu';    pmPrefix: '';    pmStemType: stCu)
  );


implementation

end.
