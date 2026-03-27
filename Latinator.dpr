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
  writeUnicode('');
end;

function findDataPath(const aStartPath: string; aDepth: integer = 2): string;
begin
  result := aStartPath;

  for var i := 0 to aDepth do begin
    case directoryExists(format('%s%s', [result, 'wwData\'])) of  TRUE: begin
                                                                          result := format('%s%s', [result, 'wwData\']);
                                                                          EXIT; end;
                                                                 FALSE: result := extractFilePath(excludeTrailingPathDelimiter(result)); end;end;

  result := '';
end;

function loadWhitakersWords(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
  aLatin.setDataPath                (aDataPath);
  aLatin.loadDictionary             ('DICTLINE.LAT');
  aLatin.loadEsse                   ('ESSE.LAT');
  aLatin.loadInflections            ('INFLECTS.LAT');
  aLatin.loadUniques                ('UNIQUES.LAT');
  aLatin.loadPrefixes               ('ADDONS.LAT');
  aLatin.loadSuffixes               ('ADDONS.LAT');
  aLatin.loadTackOns                ('ADDONS.LAT');
end;

function loadLewisAndShort(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
  aLatin.LewisAndShort.setDataPath  (aDataPath);
  writeUnicode                      ('Loading Lewis & Short...');
  aLatin.loadLewisAndShort          ('lat.ls.perseus-eng2.xml');
  writeUnicode                      (format('%d Entries', [aLatin.LewisAndShort.entryCount]));
  writeUnicode                      ('');
end;

function exportLewisAndShort(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
  aLatin.LewisAndShort.setDataPath  (aDataPath);
  writeUnicode                      ('Exporting Lewis & Short...');
  aLatin.LewisAndShort.export       ('Lewis&Short.txt');
  writeUnicode                      ('');
end;

function importLewisAndShort(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
  aLatin.LewisAndShort.setDataPath  (aDataPath);
  writeUnicode                      ('Importing Lewis & Short...');
  aLatin.LewisAndShort.import       ('Lewis&Short.txt');
  writeUnicode                      (format('%d entries', [aLatin.LewisAndShort.entryCount]));
  writeUnicode                      ('');
end;

function clearLewisAndShort(const aLatin: ILatin): TVoid;
begin
  aLatin.LewisAndShort.clear;
  writeUnicode                      ('Cleared');
  writeUnicode                      ('');
end;

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

var
  gClose:     boolean = FALSE;
  gFinished:  boolean = FALSE;

function consoleLoop(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
    var vLine: string;

    try
      repeat
        write('> ');

        readLn(vLine);

        case gClose     of TRUE: BREAK; end;
        case vLine = '' of TRUE: BREAK; end;

        case vLine = 'las'    of   TRUE:  begin
                                            loadLewisAndShort   (aLatin, aDataPath);
                                            CONTINUE; end;end;

        case vLine = 'export' of   TRUE:  begin
                                            exportLewisAndShort (aLatin, aDataPath);
                                            CONTINUE; end;end;

        case vLine = 'import' of   TRUE:  begin
                                            importLewisAndShort (aLatin, aDataPath);
                                            CONTINUE; end;end;

        case vLine = 'clear'  of   TRUE:  begin
                                            clearLewisAndShort  (aLatin);
                                            CONTINUE; end;end;

        var vWhitakersWords := TRUE;                  // the default is to do both
        var vLewisAndShort  := TRUE;

        case (pos('ww ', vLine) = 1) of TRUE: begin   // the user can override the default
                                                delete(vLine, 1, 3);
                                                vLewisAndShort := FALSE; end;end;

        case (pos('ls ', vLine) = 1) of TRUE: begin
                                                delete(vLine, 1, 3);
                                                vWhitakersWords := FALSE; end;end;

       case vWhitakersWords of TRUE: for var vString in aLatin.parse(vLine) do writeUnicode(vString); end;
       case vLewisAndShort  of TRUE: writeEntry(aLatin.LewisAndShort.findEntry(vLine)); end;

      until vLine = '';

    finally
      aLatin.LewisAndShort.clear;
      aLatin.unload;
      gFinished := TRUE;
    end;
end;

function handleConsoleClose(aCtrlType: DWORD): BOOL; stdcall;
// do a proper clean-up if the user hits Ctrl-C
// The X window button is disabled
begin
  result := aCtrlType in [CTRL_C_EVENT, CTRL_CLOSE_EVENT];
  case result of   TRUE:  begin
                            gClose := TRUE;
                            freeConsole;  // kill the console loop
                            while gFinished = FALSE do sleep(100); end;end;
end;

function disableConsoleCloseButton: TVoid;
begin
  var vConsoleWindow := getConsoleWindow;

  case (vConsoleWindow <> 0) of  TRUE:  begin
                                          var vSystemMenu := getSystemMenu(vConsoleWindow, FALSE);
                                          case (vSystemMenu <> 0) of   TRUE:  begin
                                                                                deleteMenu(vSystemMenu, SC_CLOSE, MF_BYCOMMAND);
                                                                                drawMenuBar(vConsoleWindow); end;end;end;end;
end;

begin
  setupRunMode;

  var vLatin    := newLatin;
  var vDataPath := findDataPath(extractFilePath(paramStr(0)));

  loadWhitakersWords  (vLatin, vDataPath);

  vAsGUI := paramStr(1) = 'GUI';

  case vAsGUI of   TRUE: begin
    freeConsole;
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    TStyleManager.TrySetStyle ('Charcoal Dark Slate');

    Application.CreateForm    (TFormMain, FormMain);
    Application.Run;
  end;end;

  case vAsGUI of  FALSE: begin
    case attachConsole      (ATTACH_PARENT_PROCESS) of FALSE: allocConsole; end;
    disableConsoleCloseButton;
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

    importLewisAndShort (vLatin, vDataPath); // have to do this after the banner and console setup because it emits console messages

    writeUnicode('Press ENTER to exit');

    consoleLoop(vLatin, vDataPath);

    vLatin := NIL;
  end;end;
end.
