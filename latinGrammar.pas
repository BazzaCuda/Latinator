unit latinGrammar;

interface

uses
  System.Classes, System.SysUtils;

type
  TWordType       = (wtNone, wtNoun, wtVerb, wtAdjective, wtPronoun);
  TNounGender     = (ngNone, ngMasculine, ngFeminine, ngNeuter);
  TNounCase       = (nominative, vocative, accusative, genitive, dative, ablative);
  TVerbCase       = (firstPerson, secondPerson, thirdPerson);
  TMFN            = (masculine, feminine, neuter);
  TSingularPlural = (singular, plural);

  TLatin = class
  strict private
    ix:             integer;
    FIniFilePath:   string;
    FIniFile:       TStringList;
    FStrings:       TStringList;
    FWordTypes:     TStringList;
    FWordDescs:     TStringList;
    FWordTypeInfo:  TStringList;
    FVerbTypes:     TStringList;
    FVerbDescs:     TStringList;

    FAutoExpanded:  boolean;
    FSearchTerm:    string;

    procedure populateLists;

  private
    constructor create;
    destructor  destroy; override;
    procedure doLatinRec;
    procedure SetIniFilePath(const Value: string);
    procedure doExpandNoun;
    procedure doNextRec;
    procedure doNoun;
    procedure doPrevRec;
    procedure doPronoun;
    procedure doVerb;
    function  findNextRec(fromIx: integer = 0): boolean;
    function  getRecNom: string;
    function  getRecStem: string;
    function  getRecGenEnd: string;
    function  getRecLatinDesc: string;
    function  getRecNounGender: TNounGender;
    function  getRecPronounDesc: string;
    function  getVerb1stPersonSingular: string;
    function  getRecVerbType: string;
    function  getRecWordDesc: string;
    function  getRecWordType: TWordType;
    function  getRecWordTypeInfo: string;
    function  isERNoun: boolean;
    function  isExpandNounRec: boolean;
    function  isUSNoun: boolean;
    function  getVerb2ndPersonSingular: string;
    function  getVerb3rdPersonSingular: string;
    function  getVerb1stPersonPlural: string;
    function  getVerb2ndPersonPlural: string;
    function  getVerb3rdPersonPlural: string;
    function  getNounAblSingular: string;
    function  getNounAccSingular: string;
    function  getNounDatSingular: string;
    function  getNounGenSingular: string;
    function  getNounNomSingular: string;
    function  getNounVocSingular: string;
    function  getNounAblPlural: string;
    function  getNounAccPlural: string;
    function  getNounDatPlural: string;
    function  getNounGenPlural: string;
    function  getNounNomPlural: string;
    function  getNounVocPlural: string;

    function  getNounCase(nounCase: TNounCase; sp: TSingularPlural): string;
    function  getPronounCase(mfn: TMFN; nounCase: TNounCase; sp: TSingularPlural): string;
    function  getVerbCase(verbCase: TVerbCase; sp: TSingularPlural): string;

    function  getPronounFeminineAblPlural: string;
    function  getPronounFeminineAblSingular: string;
    function  getPronounFeminineAccPlural: string;
    function  getPronounFeminineAccSingular: string;
    function  getPronounFeminineDatPlural: string;
    function  getPronounFeminineDatSingular: string;
    function  getPronounFeminineGenPlural: string;
    function  getPronounFeminineGenSingular: string;
    function  getPronounFeminineNomPlural: string;
    function  getPronounFeminineNomSingular: string;
    function  getPronounMasculineAblPlural: string;
    function  getPronounMasculineAblSingular: string;
    function  getPronounMasculineAccPlural: string;
    function  getPronounMasculineAccSingular: string;
    function  getPronounMasculineDatPlural: string;
    function  getPronounMasculineDatSingular: string;
    function  getPronounMasculineGenPlural: string;
    function  getPronounMasculineGenSingular: string;
    function  getPronounMasculineNomPlural: string;
    function  getPronounMasculineNomSingular: string;
    function  getPronounNeuterAblPlural: string;
    function  getPronounNeuterAblSingular: string;
    function  getPronounNeuterAccPlural: string;
    function  getPronounNeuterAccSingular: string;
    function  getPronounNeuterDatPlural: string;
    function  getPronounNeuterDatSingular: string;
    function  getPronounNeuterGenPlural: string;
    function  getPronounNeuterGenSingular: string;
    function  getPronounNeuterNomPlural: string;
    function  getPronounNeuterNomSingular: string;
  protected
  public
    function  getMacronChar(aChar: char): char;
//    function getMacronWord(key: WORD): WORD;
    function  validMacron(key: char): boolean;
    procedure getWordDescs(wordDescs: TStrings);
    procedure getWordTypes(wordTypes: TStrings);
    procedure getVerbDescs(verbDescs: TStrings);
    procedure getVerbTypes(verbTypes: TStrings);
    procedure loadIniFile;
    procedure nextRec;
    procedure prevRec;
    function  findFirst(aSearchTerm: string): boolean;
    function  findNext:       boolean;
    function  isAutoExpanded: boolean;
    function  recNoText:      string;
    property  iniFilePath:    string read FIniFilePath write SetIniFilePath;
    property  latinDesc:      string read getRecLatinDesc;

    property  nounNomPlural:    string read getNounNomPlural;
    property  nounVocPlural:    string read getNounVocPlural;
    property  nounAccPlural:    string read getNounAccPlural;
    property  nounGenPlural:    string read getNounGenPlural;
    property  nounDatPlural:    string read getNounDatPlural;
    property  nounAblPlural:    string read getNounAblPlural;
    property  nounNomSingular:  string read getNounNomSingular;
    property  nounVocSingular:  string read getNounVocSingular;
    property  nounAccSingular:  string read getNounAccSingular;
    property  nounGenSingular:  string read getNounGenSingular;
    property  nounDatSingular:  string read getNounDatSingular;
    property  nounAblSingular:  string read getNounAblSingular;
    property  pronounDesc:      string read getRecPronounDesc;

    property  pronounMasculineNomSingular:  string read getPronounMasculineNomSingular;
    property  pronounMasculineAccSingular:  string read getPronounMasculineAccSingular;
    property  pronounMasculineGenSingular:  string read getPronounMasculineGenSingular;
    property  pronounMasculineDatSingular:  string read getPronounMasculineDatSingular;
    property  pronounMasculineAblSingular:  string read getPronounMasculineAblSingular;
    property  pronounMasculineNomPlural:    string read getPronounMasculineNomPlural;
    property  pronounMasculineAccPlural:    string read getPronounMasculineAccPlural;
    property  pronounMasculineGenPlural:    string read getPronounMasculineGenPlural;
    property  pronounMasculineDatPlural:    string read getPronounMasculineDatPlural;
    property  pronounMasculineAblPlural:    string read getPronounMasculineAblPlural;
    property  pronounFeminineNomSingular:   string read getPronounFeminineNomSingular;
    property  pronounFeminineAccSingular:   string read getPronounFeminineAccSingular;
    property  pronounFeminineGenSingular:   string read getPronounFeminineGenSingular;
    property  pronounFeminineDatSingular:   string read getPronounFeminineDatSingular;
    property  pronounFeminineAblSingular:   string read getPronounFeminineAblSingular;
    property  pronounFeminineNomPlural:     string read getPronounFeminineNomPlural;
    property  pronounFeminineAccPlural:     string read getPronounFeminineAccPlural;
    property  pronounFeminineGenPlural:     string read getPronounFeminineGenPlural;
    property  pronounFeminineDatPlural:     string read getPronounFeminineDatPlural;
    property  pronounFeminineAblPlural:     string read getPronounFeminineAblPlural;
    property  pronounNeuterNomSingular:     string read getPronounNeuterNomSingular;
    property  pronounNeuterAccSingular:     string read getPronounNeuterAccSingular;
    property  pronounNeuterGenSingular:     string read getPronounNeuterGenSingular;
    property  pronounNeuterDatSingular:     string read getPronounNeuterDatSingular;
    property  pronounNeuterAblSingular:     string read getPronounNeuterAblSingular;
    property  pronounNeuterNomPlural:       string read getPronounNeuterNomPlural;
    property  pronounNeuterAccPlural:       string read getPronounNeuterAccPlural;
    property  pronounNeuterGenPlural:       string read getPronounNeuterGenPlural;
    property  pronounNeuterDatPlural:       string read getPronounNeuterDatPlural;
    property  pronounNeuterAblPlural:       string read getPronounNeuterAblPlural;

    property  verb1stPersonPlural:    string read getVerb1stPersonPlural;
    property  verb2ndPersonPlural:    string read getVerb2ndPersonPlural;
    property  verb3rdPersonPlural:    string read getVerb3rdPersonPlural;
    property  verb1stPersonSingular:  string read getVerb1stPersonSingular;
    property  verb2ndPersonSingular:  string read getVerb2ndPersonSingular;
    property  verb3rdPersonSingular:  string read getVerb3rdPersonSingular;

    property  verbType: string read getRecVerbType;
    property  wordDesc: string read getRecWordDesc;
    property  wordType: TWordType read getRecWordType;
    property  wordInfo: string read getRecWordTypeInfo;
  end;

const
  COLOR_DARK    = $232323;  // blackish background
  COLOR_LIGHT   = $3E3E3E;  // greenish background
  COLOR_SILVER  = $C0C0C0;  // silver text

  VALID_KEYS = ['a'..'z', '1'..'5', #8, '/', ',', '+', '-', ' ', #22]; // #8 = backspace, #22 = Ctrl-v


function latin: TLatin;

implementation

const
  verbTypes: array of string = ['pia', 'iia', 'fia', 'pfia', 'ppia', 'fpia', 'pip', 'iip', 'fip', 'pfip', 'ppip', 'fpip'];
  verbDescs: array of string = [
    'present indicative active',
    'imperfect indicative active',
    'future indicative active',
    'perfect indicative active',
    'pluperfect indicative active',
    'future perfect indicative active',
    'present indicative passive',
    'imperfect indicative passive',
    'future indicative passive',
    'perfect indicative passive',
    'pluperfect indicative passive',
    'future perfect indicative passive'];

  wordTypes: array of string = ['1dn', '2dn', '3dn', '3in', '3nn', '4dn', '5dn', '1cv', '2cv', '3cv', '3iv', '4cv', 'irv', '1da', '3da', '1dc', '3dc', '1ds', '3ds', 'ppn'];
  wordDescs: array of string = [
    '1st declension noun',
    '2nd declension noun',
    '3rd declension noun',
    '3rd declension i-stem noun',
    '3rd declension irregular noun',
    '4th declension noun',
    '5th declension noun',
    '1st conjugation verb',
    '2nd conjugation verb',
    '3rd conjugation verb',
    '3rd conjugation i-stem verb',
    '4th conjugation verb',
    'irregular verb',
    '1st & 2nd declension adjective',
    '3rd declension adjective',
    '1st & 2nd declension comparitive',
    '3rd declension comparative',
    '1st & 2nd declension superlative',
    '3rd declension superlative',
    'personal pronoun'];

  wordTypeInfo: array of string = [
    '1D: mostly f. characterised by the vowel -a. Nom: -a, Gen: -ae',
    '2D: mostly m. n. characterised by the vowels -o/-u. NomM: -us -ius -er NomN: -um Gen: -i',
    '3D: m. f. n. Nom: various Gen: -is',
    '3D: m. f. n. Nom: various Gen: -is',
    '3D: m. f. n. Nom: various Gen: -is',
    '4D: mostly m. some f. n. NomMF: -us NomN: -u Gen: -us',
    '5D: all f. except diēs/day (m or f) Nom: -es Gen: ēī',
    '1c: have stems ending in -ā',
    '2c: have stems ending in -ē',
    '3c: stem ending in consonant 3rd person singular ending in -it'];

var
  vLatin: TLatin;

function latin: TLatin;
begin
  case vLatin = NIL of TRUE: vLatin := TLatin.create; end;
  result := vLatin;
end;

 { TLatin }

constructor TLatin.create;
begin
  inherited;

  FIniFile      := TStringList.create;
  FStrings      := TStringList.create;
  FWordTypes    := TStringList.create;
  FWordDescs    := TStringList.create;
  FWordTypeInfo := TStringList.create;
  FVerbTypes    := TStringList.create;
  FVerbDescs    := TStringList.create;

  populateLists;
end;

destructor TLatin.destroy;
begin
  case FIniFile       <> NIL of TRUE: FIniFile.free; end;
  case FStrings       <> NIL of TRUE: FStrings.free; end;
  case FWordTypes     <> NIL of TRUE: FWordTypes.free; end;
  case FWordDescs     <> NIL of TRUE: FWordDescs.free; end;
  case FWordTypeInfo  <> NIL of TRUE: FWordTypeInfo.free; end;
  case FVerbTypes     <> NIL of TRUE: FVerbTypes.free; end;
  case FVerbDescs     <> NIL of TRUE: FVerbDescs.free; end;

  inherited;
end;

function TLatin.getMacronChar(aChar: char): char;
// convert uppercase A E I O U or lowercase a e i o u to ā ē ī ō ū
begin
  result := aChar;
  case aChar of
    'A', 'a': result := 'ā';
    'E', 'e': result := 'ē';
    'I', 'i': result := 'ī';
    'O', 'o': result := 'ō';
    'U', 'u': result := 'ū';
  end;
end;

//function TLatin.getMacronWord(key: WORD): WORD;
//// convert uppercase A E I O U to ā ē ī ō ū
//begin
//  result := key;
//  case key of
//    65: result := 257;
//    69: result := 275;
//    73: result := 299;
//    79: result := 333;
//    85: result := 363;
//  end;
//end;

function TLatin.validMacron(key: char): boolean;
begin
  result := FALSE;
  case ord(key) of
    257, 275, 299, 333, 363: result := TRUE; // ā ē ī ō ū
//    257, 275, 299, 333, 363, 256, 274, 298, 332, 362: result := TRUE; // ā ē ī ō ū Ā Ē Ī Ō Ū
  end;
end;

procedure TLatin.doExpandNoun;
  procedure addEndings(stem: string; nom: string; endings: array of string);
  // if a new nominitive is provided, it replaces elements 4 (nom) and 5 (voc) of FStrings
  // and therefore the first two endings in the array should be [blank and] ignored
  begin
    FStrings.delete(4); // it has served its purpose

    var vStart := low(endings);

    case nom <> '' of TRUE: FStrings.add(nom); end; // manually add the replacement nominitive, e.g. ager, where the stem will be agr-

    case nom <> '' of TRUE: FStrings.add(nom); end; // manually add the vocative, e.g. ager where the stem will be agr-

    case nom <> '' of TRUE: vStart := vStart + 2; end;

    for var i := vStart to high(endings) do
      FStrings.add(stem + endings[i]);
  end;
begin

  case (getRecNounGender in [ngFeminine, ngMasculine]) and (getRecGenEnd = 'ae') of TRUE: // 1D e.g. silva, agricola
                                addEndings(getRecStem, '', ['a', 'a', 'am', 'ae', 'ae', 'ā', 'ae', 'ae', 'ās', 'ārum', 'īs', 'īs']); end;

  case (getRecNounGender = ngMasculine) and (getRecGenEnd = 'ī') and isUSNoun of TRUE: begin // 2D -us nouns, e.g. dominus, domin-e
                                var vocative := '';
                                case getRecStem[length(getRecStem)] = 'i' of FALSE: vocative := 'e'; end; // e.g. voc of fīliī = fili not filie
                                addEndings(getRecStem, '', ['us', vocative, 'um' , 'ī', 'ō', 'ō', 'ī', 'ī', 'ōs', 'ōrum', 'īs', 'īs']); end;end;

  case (getRecNounGender = ngMasculine) and (getRecGenEnd = 'ī') and isERNoun of TRUE: // 2D  -er nouns, e.g. puer, puer-ī
                                addEndings(getRecStem, '', ['', '', 'um', 'ī', 'ō', 'ō', 'ī', 'ī', 'ōs', 'ōrum', 'īs', 'īs']); end;

  case (getRecNounGender = ngNeuter) and (getRecGenEnd = 'ī') of TRUE: // 2D  neuter nouns, e.g. dōnum, dōn-ī
                                addEndings(getRecStem, '', ['', '', 'um', 'ī', 'ō', 'ō', 'a', 'a', 'a', 'ōrum', 'īs', 'īs']); end;

  case (getRecNounGender = ngMasculine) and (getRecGenEnd = 'rī') and isERNoun of TRUE: // 2D  -er nouns, e.g. ager, agr-ī with stem = agr-
                                addEndings(getRecStem + 'r', getRecNom, ['', '', 'um', 'ī', 'ō', 'ō', 'ī', 'ī', 'ōs', 'ōrum', 'īs', 'īs']); end;

  case getRecGenEnd = 'is' of  TRUE: // 3D
                                addEndings(getRecStem, '', ['īs', 'īs', 'īm', 'īs', 'ī', 'ī', 'ī', 'ī', 'ī', 'ōrum', 'īs', 'īs']); end;

  case getRecGenEnd = 'ūs' of  TRUE: // 4D
                                addEndings(getRecStem, '', ['us', 'us', 'um', 'ūs', 'uī', 'ū', 'ūs', 'ūs', 'ūs', 'uum', 'ibus', 'ibus']); end;

  case (getRecGenEnd = 'eī') or (getRecGenEnd = 'ēī') of TRUE: // 5D
                                addEndings(getRecStem, '', ['ēs', 'ēs', 'em', 'eī', 'eī', 'ē', 'ēs', 'ēs', 'ēs', 'ērum', 'ēbus', 'ēbus']); end;

  FAutoExpanded := TRUE;
end;

procedure TLatin.doLatinRec;
begin
  FAutoExpanded       := FALSE;
  FStrings.commaText  := FIniFile[ix];

  case getRecWordType of
    wtNone: ;
    wtNoun:       doNoun;
    wtVerb:       doVerb;
    wtAdjective:  doNoun;
    wtPronoun:    doProNoun;
  end;

end;

procedure TLatin.doNextRec;
begin
  case ix < FIniFile.count - 1 of TRUE: inc(ix); end;
  doLatinRec;
end;

procedure TLatin.doNoun;
begin
  case isExpandNounRec of TRUE: doExpandNoun; end;
end;

procedure TLatin.doPrevRec;
begin
  case ix > 0 of TRUE: dec(ix); end;
  doLatinRec;
end;

procedure TLatin.doPronoun;
begin

end;

procedure TLatin.doVerb;
begin

end;

function TLatin.findFirst(aSearchTerm: string): boolean;
begin
  FSearchTerm := aSearchTerm;
  result := findNextRec;
end;

function TLatin.findNext: boolean;
begin
  result := findNextRec(ix + 1);
end;

function TLatin.findNextRec(fromIx: integer = 0): boolean;
begin
  result := FALSE;
  for var i := fromIx to FIniFile.count - 1 do begin
    result := pos(FSearchTerm, FIniFile[i]) > 0;
    case result of TRUE:  begin
                            ix := i;
                            doLatinRec;
                            BREAK;
                          end;end;end;
end;

function TLatin.getVerb1stPersonPlural: string;
begin
  result := getVerbCase(firstPerson, plural);
end;

function TLatin.getVerb1stPersonSingular: string;
begin
  result := getVerbCase(firstPerson, singular);
end;

function TLatin.getVerb2ndPersonPlural: string;
begin
  result := getVerbCase(secondPerson, plural);
end;

function TLatin.getVerb2ndPersonSingular: string;
begin
  result := getVerbCase(secondPerson, singular);
end;

function TLatin.getVerb3rdPersonPlural: string;
begin
  result := getVerbCase(thirdPerson, plural);
end;

function TLatin.getVerb3rdPersonSingular: string;
begin
  result := getVerbCase(thirdPerson, singular);
end;

function TLatin.getVerbCase(verbCase: TVerbCase; sp: TSingularPlural): string;
// verb cases are in elements 4-6 and 7-9 (singular and plural)
begin
  result := '';
  var ix := 4 + ord(verbCase);
  case sp of plural: ix := ix + 3; end;
  case ix < FStrings.count of TRUE: result := FStrings[ix]; end;
end;

procedure TLatin.getVerbDescs(verbDescs: TStrings);
begin
  verbDescs.assign(FVerbDescs);
end;

procedure TLatin.getVerbTypes(verbTypes: TStrings);
begin
  verbTypes.assign(FVerbTypes);
end;

procedure TLatin.getWordDescs(wordDescs: TStrings);
begin
  wordDescs.assign(FWordDescs);
end;

procedure TLatin.getWordTypes(wordTypes: TStrings);
begin
  wordTypes.assign(FWordTypes);
end;

function TLatin.getRecGenEnd: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  var posHyphen := pos('-', FStrings[4]);
  result        := copy(FStrings[4], posHyphen + 1, 255);
end;

function TLatin.getRecLatinDesc: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  result := FStrings[1] + '. ' + FStrings[2] + ' = ' + FStrings[3];
end;

function TLatin.getRecNom: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  result := FStrings[2];
end;

function TLatin.getNounAblPlural: string;
begin
  result := getNounCase(ablative, plural);
end;

function TLatin.getNounAblSingular: string;
begin
  result := getNounCase(ablative, singular);
end;

function TLatin.getNounAccPlural: string;
begin
  result := getNounCase(accusative, plural);
end;

function TLatin.getNounAccSingular: string;
begin
  result := getNounCase(accusative, singular);
end;

function TLatin.getNounCase(nounCase: TNounCase; sp: TSingularPlural): string;
// noun cases are in elements 4-9 and 10-15 (singular and plural)
var ix: integer;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  ix := 4 + ord(nounCase);
  case sp of plural: ix := ix + 6; end;
  case ix < FStrings.count of TRUE: result := FStrings[ix]; end;
end;

function TLatin.getNounDatPlural: string;
begin
  result := getNounCase(dative, plural);
end;

function TLatin.getNounDatSingular: string;
begin
  result := getNounCase(dative, singular);
end;

function TLatin.getRecNounGender: TNounGender;
begin
  case FStrings.count = 0 of TRUE: EXIT; end;
  result := TNounGender(pos(FStrings[1], 'mfn'));
end;

function TLatin.getNounGenPlural: string;
begin
  result := getNounCase(genitive, plural);
end;

function TLatin.getNounGenSingular: string;
begin
  result := getNounCase(genitive, singular);
end;

function TLatin.getNounNomPlural: string;
begin
  result := getNounCase(nominative, plural);
end;

function TLatin.getNounNomSingular: string;
begin
  result := getNounCase(nominative, singular);
end;

function TLatin.getNounVocPlural: string;
begin
  result := getNounCase(vocative, plural);
end;

function TLatin.getNounVocSingular: string;
begin
  result := getNounCase(vocative, singular);
end;

function TLatin.getPronounCase(mfn: TMFN; nounCase: TNounCase; sp: TSingularPlural): string;
// pronoun cases are in elements 4-13, 14-23, 24-33 (sing/plural masculine, sing/plural feminine and sing/plural neuter)
begin
  result := '';
  var ix := 4 + ord(nounCase);
  case ord(nounCase) > 0 of TRUE: ix := ix - 1; end; // there's no Vocative for pronouns
  case sp of plural:    ix := ix + 5; end;
  case mfn of feminine: ix := ix + 10; end;
  case mfn of neuter:   ix := ix + 20; end;
  case ix < FStrings.count of TRUE: result := FStrings[ix]; end;
end;

function TLatin.getRecPronounDesc: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  result := FStrings[2] + ' = ' + FStrings[3];
end;

function TLatin.getPronounFeminineAblPlural: string;
begin
  result := getPronounCase(feminine, ablative, plural);
end;

function TLatin.getPronounFeminineAblSingular: string;
begin
  result := getPronounCase(feminine, ablative, singular);
end;

function TLatin.getPronounFeminineAccPlural: string;
begin
  result := getPronounCase(feminine, accusative, plural);
end;

function TLatin.getPronounFeminineAccSingular: string;
begin
  result := getPronounCase(feminine, accusative, singular);
end;

function TLatin.getPronounFeminineDatPlural: string;
begin
  result := getPronounCase(feminine, dative, plural);
end;

function TLatin.getPronounFeminineDatSingular: string;
begin
  result := getPronounCase(feminine, dative, singular);
end;

function TLatin.getPronounFeminineGenPlural: string;
begin
  result := getPronounCase(feminine, genitive, plural);
end;

function TLatin.getPronounFeminineGenSingular: string;
begin
  result := getPronounCase(feminine, genitive, singular);
end;

function TLatin.getPronounFeminineNomPlural: string;
begin
  result := getPronounCase(feminine, nominative, plural);
end;

function TLatin.getPronounFeminineNomSingular: string;
begin
  result := getPronounCase(feminine, nominative, singular);
end;

function TLatin.getPronounMasculineAblPlural: string;
begin
  result := getPronounCase(masculine, ablative, plural);
end;

function TLatin.getPronounMasculineAblSingular: string;
begin
  result := getPronounCase(masculine, ablative, singular);
end;

function TLatin.getPronounMasculineAccPlural: string;
begin
  result := getPronounCase(masculine, accusative, plural);
end;

function TLatin.getPronounMasculineAccSingular: string;
begin
  result := getPronounCase(masculine, accusative, singular);
end;

function TLatin.getPronounMasculineDatPlural: string;
begin
  result := getPronounCase(masculine, dative, plural);
end;

function TLatin.getPronounMasculineDatSingular: string;
begin
  result := getPronounCase(masculine, dative, singular);
end;

function TLatin.getPronounMasculineGenPlural: string;
begin
  result := getPronounCase(masculine, genitive, plural);
end;

function TLatin.getPronounMasculineGenSingular: string;
begin
  result := getPronounCase(masculine, genitive, singular);
end;

function TLatin.getPronounMasculineNomPlural: string;
begin
  result := getPronounCase(masculine, nominative, plural);
end;

function TLatin.getPronounMasculineNomSingular: string;
begin
  result := getPronounCase(masculine, nominative, singular);
end;

function TLatin.getPronounNeuterAblPlural: string;
begin
  result := getPronounCase(neuter, ablative, plural);
end;

function TLatin.getPronounNeuterAblSingular: string;
begin
  result := getPronounCase(neuter, ablative, singular);
end;

function TLatin.getPronounNeuterAccPlural: string;
begin
  result := getPronounCase(neuter, accusative, plural);
end;

function TLatin.getPronounNeuterAccSingular: string;
begin
  result := getPronounCase(neuter, accusative, singular);
end;

function TLatin.getPronounNeuterDatPlural: string;
begin
  result := getPronounCase(neuter, dative, plural);
end;

function TLatin.getPronounNeuterDatSingular: string;
begin
  result := getPronounCase(neuter, dative, singular);
end;

function TLatin.getPronounNeuterGenPlural: string;
begin
  result := getPronounCase(neuter, genitive, plural);
end;

function TLatin.getPronounNeuterGenSingular: string;
begin
  result := getPronounCase(neuter, genitive, singular);
end;

function TLatin.getPronounNeuterNomPlural: string;
begin
  result := getPronounCase(neuter, nominative, plural);
end;

function TLatin.getPronounNeuterNomSingular: string;
begin
  result := getPronounCase(neuter, nominative, singular);
end;

function TLatin.getRecStem: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  var posHyphen := pos('-', FStrings[4]);
  result        := copy(FStrings[4], 1, posHyphen - 1);
end;

function TLatin.getRecVerbType: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  result := FVerbDescs[FVerbTypes.indexOf(FStrings[1])];
end;

function TLatin.getRecWordDesc: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  result := FWordDescs[FWordTypes.indexOf(FStrings[0])];
end;

function TLatin.getRecWordType: TWordType;
begin
  case FStrings.count = 0 of TRUE: EXIT; end;
  var aWordType := FStrings[0];
  result := wtNone;
  case length(aWordType) <> 3           of TRUE: EXIT; end;
  case aWordType[3] in ['n']            of TRUE: result := wtNoun;      end;
  case aWordType[3] in ['v']            of TRUE: result := wtVerb;      end;
  case aWordType[3] in ['a', 'c', 's']  of TRUE: result := wtAdjective; end; // adjectives, comparatives, superlatives
  case aWordType = 'ppn'                of TRUE: result := wtPronoun;   end;
end;

function TLatin.getRecWordTypeInfo: string;
begin
  result := '';
  case FStrings.count = 0 of TRUE: EXIT; end;
  var aWordType := FStrings[0];
  var ix := FWordTypes.indexOf(aWordType);
  case (ix <> -1) and (ix < FWordTypeInfo.count) of TRUE: result := FWordTypeInfo[ix]; end;
end;

function TLatin.isAutoExpanded: boolean;
begin
  result := FAutoExpanded;
end;

function TLatin.isERNoun: boolean;
begin
  result := (length(getRecNom) >= 2) and (getRecNom[length(getRecNom) - 1] = 'e') and (getRecNom[length(getRecNom)] = 'r');
end;

function TLatin.isExpandNounRec: boolean;
begin
  case FStrings.count = 0 of TRUE: EXIT; end;
  result := (FStrings.count > 4) and (pos('-', FStrings[4]) > 0);
end;

function TLatin.isUSNoun: boolean;
begin
  result := (length(getRecNom) >= 2) and (getRecNom[length(getRecNom) - 1] = 'u') and (getRecNom[length(getRecNom)] = 's');
end;


procedure TLatin.loadIniFile;
begin
  FIniFile.clear;
  FIniFile.sorted := TRUE;
  FIniFile.loadFromFile(FIniFilePath);
  ix := 0;
  doLatinRec;
end;

procedure TLatin.nextRec;
begin
  doNextRec;
end;

procedure TLatin.populateLists;
var i: integer;
begin
  for i := low(verbTypes) to high(verbTypes) do
    FVerbTypes.add(verbTypes[i]);
  for i := low(verbDescs) to high(verbDescs) do
    FVerbDescs.add(verbDescs[i]);
  for i := low(wordTypes) to high(wordTypes) do
    FWordTypes.add(wordTypes[i]);
  for i := low(wordDescs) to high(wordDescs) do
    FWordDescs.add(wordDescs[i]);
  for i := low(wordTypeInfo) to high(wordTypeInfo) do
    FWordTypeInfo.add(wordTypeInfo[i]);
end;

procedure TLatin.prevRec;
begin
  doPrevRec;
end;

function TLatin.recNoText: string;
begin
  result := format('%d of %d', [ix + 1, FIniFile.count]);
end;

procedure TLatin.SetIniFilePath(const Value: string);
begin
  FiniFilePath := Value;
  case fileExists(FIniFilePath) of TRUE: loadIniFile; end;
end;

initialization
  vLatin := NIL;

finalization
  case vLatin <> NIL of TRUE: vLatin.free; end;

end.
