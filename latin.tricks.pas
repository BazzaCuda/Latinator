unit latin.tricks;

interface

type
  TTrickMap = record
    tmFind:    string;
    tmReplace: string;
    tmNote:    string;
  end;

const
  INITIAL_FLIP_FLOPS: array[0..39] of TTrickMap = (
    (tmFind: 'abs';    tmReplace: 'aps';    tmNote: 'abs <-> aps'),
    (tmFind: 'acq';    tmReplace: 'adq';    tmNote: 'acq <-> adq'),
    (tmFind: 'adgn';   tmReplace: 'agn';    tmNote: 'adgn <-> agn'),
    (tmFind: 'adsc';   tmReplace: 'asc';    tmNote: 'adsc <-> asc'),
    (tmFind: 'adsp';   tmReplace: 'asp';    tmNote: 'adsp <-> asp'),
    (tmFind: 'ante';   tmReplace: 'anti';   tmNote: 'ante <-> anti'),
    (tmFind: 'arqui';  tmReplace: 'arci';   tmNote: 'arqui <-> arci'),
    (tmFind: 'arqu';   tmReplace: 'arcu';   tmNote: 'arqu <-> arcu'),
    (tmFind: 'auri';   tmReplace: 'aure';   tmNote: 'auri <-> aure'),
    (tmFind: 'auri';   tmReplace: 'auru';   tmNote: 'auri <-> auru'),
    (tmFind: 'con';    tmReplace: 'com';    tmNote: 'con <-> com'),
    (tmFind: 'conl';   tmReplace: 'coll';   tmNote: 'conl <-> coll'),
    (tmFind: 'dij';    tmReplace: 'disj';   tmNote: 'dij <-> disj'),
    (tmFind: 'dir';    tmReplace: 'disr';   tmNote: 'dir <-> disr'),
    (tmFind: 'dir';    tmReplace: 'der';    tmNote: 'dir <-> der'),
    (tmFind: 'del';    tmReplace: 'dil';    tmNote: 'del <-> dil'),
    (tmFind: 'ecf';    tmReplace: 'eff';    tmNote: 'ecf <-> eff'),
    (tmFind: 'ecs';    tmReplace: 'exs';    tmNote: 'ecs <-> exs'),
    (tmFind: 'es';     tmReplace: 'ess';    tmNote: 'es <-> ess'),
    (tmFind: 'ex';     tmReplace: 'exs';    tmNote: 'ex <-> exs'),
    (tmFind: 'faen';   tmReplace: 'fen';    tmNote: 'faen <-> fen'),
    (tmFind: 'faen';   tmReplace: 'foen';   tmNote: 'faen <-> foen'),
    (tmFind: 'fed';    tmReplace: 'foed';   tmNote: 'fed <-> foed'),
    (tmFind: 'fet';    tmReplace: 'foet';   tmNote: 'fet <-> foet'),
    (tmFind: 'inb';    tmReplace: 'imb';    tmNote: 'inb <-> imb'),
    (tmFind: 'inp';    tmReplace: 'imp';    tmNote: 'inp <-> imp'),
    (tmFind: 'lub';    tmReplace: 'lib';    tmNote: 'lub <-> lib'),
    (tmFind: 'mani';   tmReplace: 'manu';   tmNote: 'mani <-> manu'),
    (tmFind: 'nihil';  tmReplace: 'nil';    tmNote: 'nihil <-> nil'),
    (tmFind: 'obt';    tmReplace: 'opt';    tmNote: 'obt <-> opt'),
    (tmFind: 'obs';    tmReplace: 'ops';    tmNote: 'obs <-> ops'),
    (tmFind: 'pre';    tmReplace: 'prae';   tmNote: 'pre <-> prae'),
    (tmFind: 'quadri'; tmReplace: 'quadru'; tmNote: 'quadri <-> quadru'),
    (tmFind: 'subsc';  tmReplace: 'susc';   tmNote: 'subsc <-> susc'),
    (tmFind: 'subsp';  tmReplace: 'susp';   tmNote: 'subsp <-> susp'),
    (tmFind: 'subc';   tmReplace: 'susc';   tmNote: 'subc <-> susc'),
    (tmFind: 'succ';   tmReplace: 'susc';   tmNote: 'succ <-> susc'),
    (tmFind: 'subt';   tmReplace: 'supt';   tmNote: 'subt <-> supt'),
    (tmFind: 'subt';   tmReplace: 'sust';   tmNote: 'subt <-> sust'),
    (tmFind: 'transv'; tmReplace: 'trav';   tmNote: 'transv <-> trav')
  );

  INITIAL_FLIPS: array[0..32] of TTrickMap = (
    (tmFind: 'ae';     tmReplace: 'e';      tmNote: 'ae -> e'),
    (tmFind: 'al';     tmReplace: 'hal';    tmNote: 'al -> hal'),
    (tmFind: 'am';     tmReplace: 'ham';    tmNote: 'am -> ham'),
    (tmFind: 'ar';     tmReplace: 'har';    tmNote: 'ar -> har'),
    (tmFind: 'aur';    tmReplace: 'or';     tmNote: 'aur -> or'),
    (tmFind: 'circum'; tmReplace: 'circun'; tmNote: 'circum -> circun'),
    (tmFind: 'co';     tmReplace: 'com';    tmNote: 'co -> com'),
    (tmFind: 'co';     tmReplace: 'con';    tmNote: 'co -> con'),
    (tmFind: 'dampn';  tmReplace: 'damn';   tmNote: 'dampn -> damn'),
    (tmFind: 'eid';    tmReplace: 'id';     tmNote: 'eid -> id'),
    (tmFind: 'el';     tmReplace: 'hel';    tmNote: 'el -> hel'),
    (tmFind: 'e';      tmReplace: 'ae';     tmNote: 'e -> ae'),
    (tmFind: 'f';      tmReplace: 'ph';     tmNote: 'f -> ph'),
    (tmFind: 'gna';    tmReplace: 'na';     tmNote: 'gna -> na'),
    (tmFind: 'har';    tmReplace: 'ar';     tmNote: 'har -> ar'),
    (tmFind: 'hal';    tmReplace: 'al';     tmNote: 'hal -> al'),
    (tmFind: 'ham';    tmReplace: 'am';     tmNote: 'ham -> am'),
    (tmFind: 'hel';    tmReplace: 'el';     tmNote: 'hel -> el'),
    (tmFind: 'hol';    tmReplace: 'ol';     tmNote: 'hol -> ol'),
    (tmFind: 'hum';    tmReplace: 'um';     tmNote: 'hum -> um'),
    (tmFind: 'k';      tmReplace: 'c';      tmNote: 'k -> c'),
    (tmFind: 'c';      tmReplace: 'k';      tmNote: 'c -> k'),
    (tmFind: 'na';     tmReplace: 'gna';    tmNote: 'na -> gna'),
    (tmFind: 'nun';    tmReplace: 'non';    tmNote: 'nun -> non'),
    (tmFind: 'ol';     tmReplace: 'hol';    tmNote: 'ol -> hol'),
    (tmFind: 'opp';    tmReplace: 'op';     tmNote: 'opp -> op'),
    (tmFind: 'or';     tmReplace: 'aur';    tmNote: 'or -> aur'),
    (tmFind: 'ph';     tmReplace: 'f';      tmNote: 'ph -> f'),
    (tmFind: 'se';     tmReplace: 'ce';     tmNote: 'se -> ce'),
    (tmFind: 'ul';     tmReplace: 'hul';    tmNote: 'ul -> hul'),
    (tmFind: 'uol';    tmReplace: 'vul';    tmNote: 'uol -> vul'),
    (tmFind: 'y';      tmReplace: 'i';      tmNote: 'y -> i'),
    (tmFind: 'z';      tmReplace: 'di';     tmNote: 'z -> di')
  );

  INTERNAL_TRICKS: array[0..11] of TTrickMap = (
    (tmFind: 'ae';     tmReplace: 'e';      tmNote: 'ae -> e'),
    (tmFind: 'bul';    tmReplace: 'bol';    tmNote: 'bul -> bol'),
    (tmFind: 'bol';    tmReplace: 'bul';    tmNote: 'bol -> bul'),
    (tmFind: 'cl';     tmReplace: 'cul';    tmNote: 'cl -> cul'),
    (tmFind: 'cu';     tmReplace: 'quu';    tmNote: 'cu -> quu'),
    (tmFind: 'f';      tmReplace: 'ph';     tmNote: 'f -> ph'),
    (tmFind: 'ph';     tmReplace: 'f';      tmNote: 'ph -> f'),
    (tmFind: 'h';      tmReplace: '';       tmNote: 'h dropped'),
    (tmFind: 'oe';     tmReplace: 'e';      tmNote: 'oe -> e'),
    (tmFind: 'vul';    tmReplace: 'vol';    tmNote: 'vul -> vol'),
    (tmFind: 'vol';    tmReplace: 'vul';    tmNote: 'vol -> vul'),
    (tmFind: 'uol';    tmReplace: 'vul';    tmNote: 'uol -> vul')
  );

  MEDIEVAL_TRICKS: array[0..26] of TTrickMap = (
    (tmFind: 'col';    tmReplace: 'caul';   tmNote: 'Medieval col -> caul'),
    (tmFind: 'e';      tmReplace: 'ae';     tmNote: 'Medieval e -> ae'),
    (tmFind: 'o';      tmReplace: 'u';      tmNote: 'Medieval o -> u'),
    (tmFind: 'i';      tmReplace: 'y';      tmNote: 'Medieval i -> y'),
    (tmFind: 'ism';    tmReplace: 'sm';     tmNote: 'Medieval ism -> sm'),
    (tmFind: 'isp';    tmReplace: 'sp';     tmNote: 'Medieval isp -> sp'),
    (tmFind: 'ist';    tmReplace: 'st';     tmNote: 'Medieval ist -> st'),
    (tmFind: 'iz';     tmReplace: 'z';      tmNote: 'Medieval iz -> z'),
    (tmFind: 'esm';    tmReplace: 'sm';     tmNote: 'Medieval esm -> sm'),
    (tmFind: 'esp';    tmReplace: 'sp';     tmNote: 'Medieval esp -> sp'),
    (tmFind: 'est';    tmReplace: 'st';     tmNote: 'Medieval est -> st'),
    (tmFind: 'ez';     tmReplace: 'z';      tmNote: 'Medieval ez -> z'),
    (tmFind: 'di';     tmReplace: 'z';      tmNote: 'Medieval di -> z'),
    (tmFind: 'is';     tmReplace: 'ix';     tmNote: 'Medieval is -> ix'),
    (tmFind: 'b';      tmReplace: 'p';      tmNote: 'Medieval b -> p'),
    (tmFind: 'd';      tmReplace: 't';      tmNote: 'Medieval d -> t'),
    (tmFind: 'v';      tmReplace: 'b';      tmNote: 'Medieval v -> b'),
    (tmFind: 'v';      tmReplace: 'f';      tmNote: 'Medieval v -> f'),
    (tmFind: 's';      tmReplace: 'x';      tmNote: 'Medieval s -> x'),
    (tmFind: 'ci';     tmReplace: 'ti';     tmNote: 'Medieval ci -> ti'),
    (tmFind: 'nt';     tmReplace: 'nct';    tmNote: 'Medieval nt -> nct'),
    (tmFind: 's';      tmReplace: 'ns';     tmNote: 'Medieval s -> ns'),
    (tmFind: 'ch';     tmReplace: 'c';      tmNote: 'Medieval ch -> c'),
    (tmFind: 'c';      tmReplace: 'ch';     tmNote: 'Medieval c -> ch'),
    (tmFind: 'th';     tmReplace: 't';      tmNote: 'Medieval th -> t'),
    (tmFind: 't';      tmReplace: 'th';     tmNote: 'Medieval t -> th'),
    (tmFind: 'f';      tmReplace: 'ph';     tmNote: 'Medieval f -> ph')
  );

  SYNCOPE_TRICKS: array[0..10] of TTrickMap = (
    (tmFind: 'ii';     tmReplace: 'ivi';    tmNote: 'Syncope ii => ivi'),
    (tmFind: 'as';     tmReplace: 'avis';   tmNote: 'Syncope s => vis'),
    (tmFind: 'es';     tmReplace: 'evis';   tmNote: 'Syncope s => vis'),
    (tmFind: 'is';     tmReplace: 'ivis';   tmNote: 'Syncope s => vis'),
    (tmFind: 'os';     tmReplace: 'ovis';   tmNote: 'Syncope s => vis'),
    (tmFind: 'ar';     tmReplace: 'aver';   tmNote: 'Syncope r => v.r'),
    (tmFind: 'er';     tmReplace: 'ever';   tmNote: 'Syncope r => v.r'),
    (tmFind: 'or';     tmReplace: 'over';   tmNote: 'Syncope r => v.r'),
    (tmFind: 'ier';    tmReplace: 'iver';   tmNote: 'Syncope ier => iver'),
    (tmFind: 's';      tmReplace: 'sis';    tmNote: 'Syncope s/x => +is'),
    (tmFind: 'x';      tmReplace: 'xis';    tmNote: 'Syncope s/x => +is')
  );

implementation

end.
