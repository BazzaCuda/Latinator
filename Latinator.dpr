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
  system.generics.collections,
  system.syncObjs,
  system.sysUtils,
  Vcl.Forms,
  vcl.dialogs,
  Vcl.Styles,
  Vcl.Themes,
  _debugWindow in '_debugWindow\_debugWindow.pas',
  view.formMain in 'view.formMain.pas',
  latin.main in 'latin.main.pas',
  latin.types in 'latin.types.pas',
  latin.fileUtils in 'latin.fileUtils.pas',
  latin.consoleUtils in 'latin.consoleUtils.pas',
  latin.stringUtils in 'latin.stringUtils.pas',
  latin.charUtils in 'latin.charUtils.pas',
  latin.miscUtils in 'latin.miscUtils.pas',
  latin.LewisAndShort in 'latin.LewisAndShort.pas',
  latin.consts in 'latin.consts.pas',
  latin.macronData in 'latin.macronData.pas',
  latin.tricks in 'latin.tricks.pas',
  latin.interfaces in 'latin.interfaces.pas',
  view.formSplash in 'view.formSplash.pas' {SplashForm};

var
  gSplashScreen:  ISplashScreen = NIL;
  gRunAsGUI:      boolean       = FALSE;

{$ifndef useMadExcept}
procedure shhh(const aExceptIntf: IMEException; var aHandled: boolean);
begin
  aHandled := True;
end;
{$endif}

procedure setupRunMode;
begin
  {$if BazDebugWindow} debugClear; {$endif}

  {$ifndef useMadExcept}
  reportMemoryLeaksOnShutdown := mmpEnvironmentVariable;
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

  {$ifndef useMadExcept}
  registerExceptionHandler(shhh, stDontSync);
  {$endif}

//  madExcept.HookThreads;
  {$endif}
end;

function informUser(const aString: string): TVoid;

  function checkProgress: TVoid;
  begin
    case gSplashScreen = NIL of FALSE: EXIT; end;
    gSplashScreen         := newSplashScreen;
    gSplashScreen.owner   := getDesktopWindow;
    gSplashScreen.heading := LATINATOR_BANNER;
    gSplashScreen.formShow;
  end;

begin
  case gRunAsGUI of  TRUE:  begin
                              checkProgress;
                              gSplashScreen.subHeading := aString;
                            end;
                    FALSE:  consoleWriteUnicode(aString); end;
end;

function writeLSEntry(const aEntry: ILewisAndShortEntry): TVoid;

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
  consoleWriteUnicode('orthography1: ' + aEntry.orthography);
  consoleWriteUnicode('orthography2: ' + aEntry.orthography2);
  consoleWriteUnicode('ID: '           + aEntry.id);
  consoleWriteUnicode('Key: '          + aEntry.key);
  consoleWriteUnicode('Case: '         + aEntry.caseCase);
  consoleWriteUnicode('Type: '         + aEntry.entryType);
  consoleWriteUnicode('Language: '     + aEntry.language);
  consoleWriteUnicode('PartOfSpeech: ' + aEntry.partOfSpeech);
  consoleWriteUnicode('Gender: '       + aEntry.gender);
  consoleWriteUnicode('Inflection: '   + aEntry.inflection);
  consoleWriteUnicode('Mood: '         + aEntry.mood);
  consoleWriteUnicode('Etymology: '    + aEntry.etymology);
  consoleWriteUnicode('Definition: '   + aEntry.definition); //    limitedDefinition);
  consoleWriteUnicode('');
  aEntry.senseAsStrings(consoleWriteUnicode);
  consoleWriteUnicode('');
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
  informUser('Loading Whitaker''''s Words data...');
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
  informUser                      ('Loading Lewis & Short...');
  aLatin.loadLewisAndShort          ('lat.ls.perseus-eng2.xml');
  informUser                      (format('%d entries loaded', [aLatin.LewisAndShort.entryCount]));
  informUser('');
end;

function exportLewisAndShort(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
  aLatin.LewisAndShort.setDataPath  (aDataPath);
  informUser                      ('Exporting Lewis & Short...');
  aLatin.LewisAndShort.export       ('Lewis&Short.txt');
  informUser                      ('');
end;

function importLewisAndShort(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
  aLatin.LewisAndShort.setDataPath  (aDataPath);
  informUser                      ('Importing Lewis & Short...');
  aLatin.LewisAndShort.import       ('Lewis&Short.txt');
  informUser                      (format('%d entries loaded', [aLatin.LewisAndShort.entryCount]));
  case gRunAsGUI of FALSE:  informUser(''); end;
end;

function clearLewisAndShort(const aLatin: ILatin): TVoid;
begin
  aLatin.LewisAndShort.clear;
  informUser                      ('Lewis & Short cleared');
  informUser                      ('');
end;

var
  gFinished : boolean = FALSE;

function handleConsoleClose(aCtrlType: DWORD): BOOL; stdcall;
// do a proper clean-up if the user hits Ctrl-C
// rather than allowing the OS to simply terminate the console process
// without us freeing-up all the memory used by TLatin and TLewisAndShort
begin
  result := aCtrlType in [CTRL_C_EVENT, CTRL_CLOSE_EVENT];
  case result of   TRUE:  begin
                            writeLn(#13#10'Bene Vale!');
                            sleep(500); // otherwise the above is never seen
                            freeConsole;  // kill the console loop
                            while gFinished = FALSE do sleep(100); end;end;
end;

function consoleLoop(const aLatin: ILatin; const aDataPath: string): TVoid;
begin
    var vLine: string;

    try
      repeat
        write('> ');

        // readLine (instead of readLn) is the only way to make this block of code possible
        setLastError(0);
        consoleReadLine(vLine);
        case (getLastError > 0) of TRUE: EXIT; end; // user probably hit Ctrl-C and handleConsoleClose called freeConsole
        case (getLastError = 0) and (vLine = '') of  TRUE:  begin
                                                              consoleWriteUnicode('Bene Vale!');
                                                              BREAK; end;end;

        var vConsoleContext := consoleMapCommand(vLine);

        case vConsoleContext.ccCommand of
          ccCLS:      doClearConsole;
          ccLoadLS:   begin loadLewisAndShort   (aLatin, aDataPath);  CONTINUE; end;
          ccExportLS: begin exportLewisAndShort (aLatin, aDataPath);  CONTINUE; end;
          ccImportLS: begin importLewisAndShort (aLatin, aDataPath);  CONTINUE; end;
          ccClearLS:  begin clearLewisAndShort  (aLatin);             CONTINUE; end;
        end;

        case vConsoleContext.ccWW of TRUE: for var vString in aLatin.parse(vConsoleContext.ccCommand, vLine) do consoleWriteUnicode(vString); end;
        case vConsoleContext.ccLS of TRUE: writeLSEntry(aLatin.LewisAndShort.findEntry(vLine.trim)); end;

      until vLine = '';

    finally
      aLatin.LewisAndShort.clear;
      aLatin.unload;
      gFinished := TRUE;
    end;
end;

begin
  setupRunMode;

  var vLatin    := newLatin;
  var vDataPath := findDataPath(extractFilePath(paramStr(0)));

  gRunAsGUI := paramStr(1).toUpper = 'GUI';

  case gRunAsGUI of  TRUE:  begin
    freeConsole;
    application.initialize;
    application.mainFormOnTaskbar := TRUE;
    TStyleManager.trySetStyle ('Charcoal Dark Slate');

    loadWhitakersWords  (vLatin, vDataPath);
    importLewisAndShort (vLatin, vDataPath);
    sleep(500);

    gSplashScreen.formHide;
    gSplashScreen := NIL;

    Application.CreateForm(TFormMain, FormMain);
  application.run;
  end;end;

  case gRunAsGUI of FALSE:  begin
    case attachConsole      (ATTACH_PARENT_PROCESS) of FALSE: allocConsole; end;
    //disableConsoleCloseButton;
    setConsoleCtrlHandler   (@handleConsoleClose, TRUE);

    consoleSetWidth         (150);
    setConsoleTitle         ('Latinator');
    consoleCenterWindow     (getConsoleWindow);
    showWindow              (getConsoleWindow, SW_SHOW); // only needed for the Delphi debugger
    consoleApplyUserColors  (getStdHandle(STD_OUTPUT_HANDLE));

    assignFile  (input, '');
    reset       (input);
    assignFile  (output, '');
    rewrite     (output);

    consoleWriteBanner;

    loadWhitakersWords  (vLatin, vDataPath);
    importLewisAndShort (vLatin, vDataPath); // have to do this after the banner and console setup because it emits console messages
    sleep(500);

    consoleClear;
    consoleWriteBanner;

    consoleLoop (vLatin, vDataPath);

    vLatin := NIL;
  end;end;
end.
