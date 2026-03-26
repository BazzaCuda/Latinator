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

// check if madExcept has left debugging options set in the Release configuration
{$if defined(RELEASE)}
  {$ifopt D+} {$MESSAGE ERROR 'Release Build: Debug Information     (D+) enabled' } {$endif}
  {$ifopt C+} {$MESSAGE ERROR 'Release Build: Assertions            (C+) enabled' } {$endif}
  {$ifopt L+} {$MESSAGE ERROR 'Release Build: Local Symbols         (L+) enabled' } {$endif}
  {$ifopt W+} {$MESSAGE ERROR 'Release Build: Stack Frames          (W+) enabled' } {$endif}
  {$ifopt Y+} {$MESSAGE ERROR 'Release Build: Symbol Reference Info (Y+) enabled' } {$endif}
  {$ifopt O-} {$MESSAGE ERROR 'Release Build: Optimization          (O-) disabled'} {$endif}
{$endif}

{$ifopt D+}
  {$define useMadExcept}
{$endif}

{$R *.res}

uses
  {$ifdef useMadExcept}
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  {$endif }
  winApi.windows,
  system.classes,
  system.sysUtils,
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
  latin.LewisAndShort in 'latin.LewisAndShort.pas';

var
  vAsGUI: boolean = FALSE;

procedure setupRunMode;
begin
  {$if BazDebugWindow} debugClear; {$endif}

  {$ifndef useMadExcept}
  reportMemoryLeaksOnShutdown := mmpEnvironmentVariable; // done already in mmpStackTrace initialization section - unless that unit has been commented out
  {$if BazDebugWindow} debugBoolean('reportMemoryLeaksOnShutdown', reportMemoryLeaksOnShutdown); {$endif}
  {$endif}

  {$ifdef useMadExcept}
//  madExcept.SetLeakReportFile(extractFilePath(paramStr(0)) + 'madExcept.log'); // this suppresses the dialog
  madExcept.reportLeaks := TRUE;
  madExcept.showNoLeaksWindow(TRUE);
  madExcept.dontHookThreads;

  var vThreadList := madExcept.getThreadList;

  for var i := low(vThreadList) to high(vThreadList) do
    madExcept.thisIsNoLeak(vThreadList[i]);

//  madExcept.HookThreads;
  {$endif}
end;

function writeEntry(const aEntry: ILewisAndShortEntry): TVoid;

  function limitedDefinition: string;
  begin
    case aEntry.senseCount = 0 of  TRUE: result := aEntry.definition;
                                  FALSE: begin
                                            var vSenseStart := copy(aEntry.sense[0].definition, 1, 10); // use an arbitrary 10 characters for now
                                            var vPos        := pos(vSenseStart, aEntry.definition);
                                            case vPos > 0 of   TRUE: result := copy(aEntry.definition, 1, vPos - 1);
                                                              FALSE: result := aEntry.definition; end;end;end;
  end;

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
  writeUnicode('Definition: '   + aEntry.definition); //    limitedDefinition);
  writeUnicode('');
  aEntry.senseAsStrings(writeUnicode);

  //TTraverser.writeSenses(aEntry.senses);
end;

var
  gClose:     boolean = FALSE;
  gFinished:  boolean = FALSE;
  vLatin:     ILatin;

function delay(const dwMilliseconds: cardinal): TVoid;
// Used to delay an operation; "sleep()" would suspend the thread, which is not what is required
var
  iStart, iStop: cardinal;
begin
  iStart  := getTickCount;
  repeat
    iStop := getTickCount;
  until ((iStop  -  iStart) >= dwMilliseconds);
end;

function handleConsoleClose(aCtrlType: DWORD): BOOL; stdcall;
begin
  result := aCtrlType in [CTRL_C_EVENT, CTRL_CLOSE_EVENT];
  case result of   TRUE:  begin
                            gClose := TRUE;
                            vLatin.LewisAndShort.clear;
                            vLatin.unload;
                            vLatin := NIL;
                            freeConsole;
                            while gFinished = FALSE do delay(10); end;end;
end;

function loadLewisAndShort(const aLatin: ILatin): TVoid;
begin
  writeUnicode                ('Loading Lewis & Short...');
  aLatin.loadLewisAndShort    ('lat.ls.perseus-eng2.xml');
  writeUnicode                (format('%d Entries', [vLatin.LewisAndShort.entryCount]));
  writeUnicode                ('');
end;

function exportLewisAndShort(const aLatin: ILatin): TVoid;
begin
  writeUnicode                ('Exporting Lewis & Short...');
  aLatin.LewisAndShort.export ('B:\Win64_Dev\Programs\Latinator\wwData\wRecords.txt');
  writeUnicode                ('');
end;

function importLewisAndShort(const aLatin: ILatin): TVoid;
begin
  writeUnicode                ('Importing Lewis & Short...');
  aLatin.LewisAndShort.import ('B:\Win64_Dev\Programs\Latinator\wwData\wRecords.txt');
  writeUnicode                (format('%d Entries', [vLatin.LewisAndShort.entryCount]));
  writeUnicode                ('');
end;

function clearLewisAndShort(const aLatin: ILatin): TVoid;
begin
  aLatin.LewisAndShort.clear;
  writeUnicode                ('Cleared');
  writeUnicode                ('');
end;

function consoleLoop(const aLatin: ILatin): TVoid;
begin
    var vLine: string;

    try
    repeat
      write('> ');

      readLn(vLine);

      case gClose of TRUE: BREAK; end;

      case vLine = 'las'    of   TRUE:  begin
                                          loadLewisAndShort(vLatin);
                                          CONTINUE; end;end;

      case vLine = 'export' of   TRUE:  begin
                                          exportLewisAndShort(vLatin);
                                          CONTINUE; end;end;

      case vLine = 'import' of   TRUE:  begin
                                          importLewisAndShort(vLatin);
                                          CONTINUE; end;end;

      case vLine = 'clear'  of   TRUE:  begin
                                          clearLewisAndShort(vLatin);
                                          CONTINUE; end;end;

      case vLine <> ''      of   TRUE:  begin
                                          for var vString in vLatin.parse(vLine) do writeUnicode(vString);
                                          writeEntry(vLatin.LewisAndShort.findEntry(vLine)); end;end;
    until vLine = '';

    finally
      gFinished := TRUE;
    end;
end;

begin
  setupRunMode;

  vLatin := newLatin;

  {$ifopt D+}
   vLatin.setDataPath('B:\Win64_Dev\Programs\Latinator\wwData\');
  {$else}
   vLatin.setDataPath(extractFilePath(paramStr(0));
  {$endif}

  // Whitaker's Words
  vLatin.loadDictionary   ('DICTLINE.LAT');
  vLatin.loadEsse         ('ESSE.LAT');
  vLatin.loadInflections  ('INFLECTS.LAT');
  vLatin.loadUniques      ('UNIQUES.LAT');
  vLatin.loadPrefixes     ('ADDONS.LAT');
  vLatin.loadSuffixes     ('ADDONS.LAT');
  vLatin.loadTackOns      ('ADDONS.LAT');

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
    case attachConsole      (ATTACH_PARENT_PROCESS) of FALSE: allocConsole; end;
    setConsoleCtrlHandler   (@handleConsoleClose, TRUE);

    setConsoleTitle         ('Latinator');
    centerWindow            (getConsoleWindow);
    applyUserConsoleColors  (getStdHandle(STD_OUTPUT_HANDLE));

    assignFile  (input, '');
    reset       (input);
    assignFile  (output, '');
    rewrite     (output);

    // introductory messages from our sponsor
    writeUnicode('Latinator v2.0.0 - (c) 2019-2099 Baz Cuda (GPL v3.0)');

    importLewisAndShort(vLatin);

    writeUnicode('Press ENTER to exit.');

    consoleLoop(vLatin);

  end;end;

end.
