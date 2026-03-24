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

program Latinator;

//{$APPTYPE CONSOLE}

uses
  winApi.windows,
  Vcl.Forms,
  vcl.dialogs,
  view.formMain in 'view.formMain.pas' {,
  Vcl.Themes,
  Vcl.Styles,
  latin.main in 'latin.main.pas',
  latin.types in 'latin.types.pas',
  _debugWindow in '_debugWindow\_debugWindow.pas',
  latin.fileUtils in 'latin.fileUtils.pas',
  latin.consoleUtils in 'latin.consoleUtils.pas';

{$R *.res},
  Vcl.Themes,
  Vcl.Styles,
  latin.main in 'latin.main.pas',
  latin.types in 'latin.types.pas',
  _debugWindow in '_debugWindow\_debugWindow.pas',
  latin.fileUtils in 'latin.fileUtils.pas',
  latin.consoleUtils in 'latin.consoleUtils.pas',
  latin.stringUtils in 'latin.stringUtils.pas',
  latin.charUtils in 'latin.charUtils.pas',
  latin.miscUtils in 'latin.miscUtils.pas',
  system.generics.collections,
//  latin.LewisAndShortJSON in 'latin.LewisAndShortJSON.pas',
  latin.LewisAndShortXML in 'latin.LewisAndShortXML.pas';

{$R *.res}

var
  vAsGUI: boolean = FALSE;

//  function accessFirstEntry(const vFilePath: string): TVoid;
//  begin
//    var vDictionary := TLSDictionaryLoader.loadFromFile(vFilePath);
//    try
//      case (vDictionary.count > 0) of  TRUE: begin
//            var vEntry := vDictionary[18];
//            var vNotes := vEntry.titleOrthography;
//            writeUnicode(vNotes);
//            TTraverser.writeSenses(vEntry.senses);
//          end;
//      end;
//    finally
//      vDictionary.free;
//    end;
//  end;

  function writeEntry(const aEntry: TTEIEntry): TVoid;
  begin
    case aEntry = NIL of TRUE: EXIT; end;
    writeUnicode('orthography1: ' + aEntry.orthography);
    writeUnicode('orthography2: ' + aEntry.orthography2);
    writeUnicode('ID: '           + aEntry.id);
    writeUnicode('Key: '          + aEntry.key);
    writeUnicode('Case: '         + aEntry.caseCase);
    writeUnicode('Type: '         + aEntry.entryType);
    writeUnicode('Language: '     + aEntry.language);
    writeUnicode('PartOfSpeech: ' + aEntry.partOfSpeech);
    writeUnicode('Gender: '       + aEntry.gender);
    writeUnicode('Inflection: '   + aEntry.inflection);
    writeUnicode('Mood: '         + aEntry.mood);
    writeUnicode('Etymology: '    + aEntry.etymology);
    writeUnicode('Definition: '   + aEntry.definition);
    TTraverser.writeSenses(aEntry.senses);
  end;

  function loadXML(const aFilePath: string): TLSDictionary;
  begin
    writeUnicode('Loading Lewis & Short...');
    result := TLSDictionary.create;
    result.loadFromFile(aFilePath);
    debugInteger('xml count', result.entries.count);
  end;

begin
  debugClear;

  var vLatin: ILatin := newLatin;

  {$ifopt D+}
   vLatin.setDataPath('B:\Win64_Dev\Programs\Latinator\wwData\');
  {$else}
   vLatin.setDataPath(extractFilePath(paramStr(0));
  {$endif}

  vLatin.loadDictionary   ('DICTLINE.LAT');
  vLatin.loadEsse         ('ESSE.LAT');
  vLatin.loadInflections  ('INFLECTS.LAT');
  vLatin.loadUniques      ('UNIQUES.LAT');
  vLatin.loadPrefixes     ('ADDONS.LAT');
  vLatin.loadSuffixes     ('ADDONS.LAT');
  vLatin.loadTackOns      ('ADDONS.LAT');

  debug(cmdLine);
  debug(paramStr(0));

  vAsGUI := paramStr(1) = 'GUI';

  case vAsGUI of   TRUE: begin
    freeConsole;
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    TStyleManager.TrySetStyle('Charcoal Dark Slate');

    Application.CreateForm(TFormMain, FormMain);
  Application.Run;
  end;end;

  case vAsGUI of  FALSE: begin
    case attachConsole(ATTACH_PARENT_PROCESS) of FALSE: allocConsole; end;

    setConsoleTitle('Latinator');
    centerWindow(getConsoleWindow);

    applyUserConsoleColors(getStdHandle(STD_OUTPUT_HANDLE));

    assignFile(input, '');
    reset(input);
    assignFile(output, '');
    rewrite(output);

    writeLn('Latinator v2.0.0 - (c) 2019-2099 Baz Cuda (GPL v3.0)');
    writeLn('Press ENTER to exit.');

    // accessFirstEntry('B:\Downloads\Latin\lewis-short-JSON-master\ls_A.json');

    var vDictionary := loadXML('B:\Downloads\Latin\lat.ls.perseus-eng2.xml');

    var vLine: string;
    repeat
      write('> ');
      readLn(vLine);
      for var vString in vLatin.parse(vLine) do writeUnicode(vString);
      writeEntry(vDictionary.findEntry(vLine));
      // writeLn('');
    until vLine = '';

    vDictionary.free;
  end;end;

end.
