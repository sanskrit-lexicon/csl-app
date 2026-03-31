class LsPattern {
  final List<String> prefixes;
  final String regex;
  final String urlTemplate;
  final List<String>? dicts;

  const LsPattern({
    required this.prefixes,
    required this.regex,
    required this.urlTemplate,
    this.dicts,
  });
}

class LsPatterns {
  static final List<LsPattern> pwg = [
    // Spr. 1st edition (pwg) - matches "Spr. 123" (without (II))
    LsPattern(
      prefixes: ['Spr.'],
      regex: r'^(Spr[.]) ([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/boesp1/app1/?\$2',
      dicts: ['pwg'],
    ),
    // Spr. 2nd edition (pw, pwkvn)
    LsPattern(
      prefixes: ['Spr.'],
      regex: r'^(Spr[.]) ([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/boesp2/web1/boesp.html?\$2',
      dicts: ['pw', 'pwkvn'],
    ),
    // Spr. (II) 2nd edition (pwg)
    LsPattern(
      prefixes: ['Spr. (II)'],
      regex: r'^(Spr[.]) \(II\) ([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/boesp2/web1/boesp.html?\$2',
      dicts: ['pwg'],
    ),
    // Spr. (I) 1st edition (pwg)
    LsPattern(
      prefixes: ['Spr. (I)'],
      regex: r'^(Spr[.] \(I\)) ([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/boesp1/app1/?\$2',
    ),
    // Spr. 2nd edition (pwg)
    LsPattern(
      prefixes: ['Spr. (II)'],
      regex: r'^(Spr[.]) \(II\) ([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/boesp2/web1/boesp.html?\$2',
    ),
    // Spr. 1st edition (pwg)
    LsPattern(
      prefixes: ['Spr.'],
      regex: r'^(Spr[.]) ([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/boesp1/app1/?\$2',
      dicts: ['pwg'],
    ),
    // MBH. Bombay edition - 3 parms
    LsPattern(
      prefixes: ['MBH.', 'MBH. ed. Bomb.'],
      regex: r'^(MBH[.] ed. Bomb.) *([0-9]+) *, *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/mbhbomb/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['MBH.'],
      regex: r'^(MBH[.]) *([0-9]+) *, *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/mbhbomb/app1?\$2,\$3,\$4',
    ),
    // MBH. Calcutta edition - 2 parms
    LsPattern(
      prefixes: ['MBH. ed. Calc.'],
      regex: r'^(MBH[.] ed. Calc.) *([0-9]+) *, *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/mbhcalc?\$2.\$3',
    ),
    LsPattern(
      prefixes: ['MBH.'],
      regex: r'^(MBH[.]) *([0-9]+) *, *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/mbhcalc?\$2.\$3',
    ),
    // Harivamsa
    LsPattern(
      prefixes: ['HARIV.'],
      regex: r'^(HARIV[.]) *([0-9]+)[.]?',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/hariv?\$2',
    ),
    // Verz. d. Oxf. H. - handle entries with letters like 19,a,19
    LsPattern(
      prefixes: ['Verz. d. Oxf. H.', 'Verz. der Oxf. H.'],
      regex: r'^(Verz\. der Oxf\. H\.) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/Oxf_Cat_Aufrecht/index.html?\$2',
    ),
    LsPattern(
      prefixes: ['Verz. d. Oxf. H.'],
      regex: r'^(Verz\. d\. Oxf\. H\.) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/Oxf_Cat_Aufrecht/index.html?\$2',
    ),
    // Kathasaritsagara
    LsPattern(
      prefixes: ['KATHĀS.'],
      regex: r'^(KATHĀS[.|,] *|KATHĀS\.?) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/kss/index.html?\$2,\$3',
    ),
    // Vajasaneyi Samhita
    LsPattern(
      prefixes: ['VS.'],
      regex: r'^(VS[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/vajasasa/app1?\$2,\$3',
    ),
    // Rajatar RĀJATARAṄGIṆĪ, Troyer
    LsPattern(
      prefixes: ['RĀJA-TAR.', 'RĀJAT.'],
      regex: r'^(RĀJA-TAR[.|]RĀJAT[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          '(\$2 == "7" || \$2 == "8") ? "https://sanskrit-lexicon-scans.github.io/rajatarcalc/app1?\$2,\$3" : "https://sanskrit-lexicon-scans.github.io/rajatar/app1?\$2,\$3"',
    ),
    // Rajatar Calcutta
    LsPattern(
      prefixes: ['RĀJA-TAR. ed. Calc.', 'RĀJAT. ed. Calc.'],
      regex:
          r'^(RĀJA-TAR\. ed\. Calc\.?|RĀJAT\. ed\. Calc\.?) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/rajatarcalc/app1?\$2,\$3',
    ),
    // Yajnavalkya
    LsPattern(
      prefixes: ['YĀJÑ.'],
      regex: r'^(YĀJÑ[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/yajnavalkya/app1?\$2,\$3',
    ),
    // Raghuvaṃśa (ST) - more specific pattern first
    LsPattern(
      prefixes: ['RAGH. ed. ST.'],
      regex: r'^(RAGH[.] ed[.] ST[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsa/app1?\$2,\$3',
    ),
    // Raghuvaṃśa Calcutta
    LsPattern(
      prefixes: ['RAGH. ed. Calc.', 'RAGH. (ed. Calc.)', 'RAGH. (Calc.)'],
      regex:
          r'^(RAGH[.] ed[.] Calc[.|]RAGH[.] \(ed[.] Calc\)[.|]RAGH[.] \(Calc\)[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?\$2,\$3',
    ),
    // Generic RAGH. (default to raghuvamsa, not Calcutta - matches PHP)
    LsPattern(
      prefixes: ['RAGH.'],
      regex: r'^(RAGH[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsa/app1?\$2,\$3',
    ),
    // Markandeya Purana
    LsPattern(
      prefixes: ['MĀRK. P.'],
      regex: r'^(MĀRK[.] P[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/markandeyapurana/app1?\$2,\$3',
    ),
    // Bhagavad Gita
    LsPattern(
      prefixes: ['BHAG.'],
      regex: r'^(BHAG[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?\$2,\$3',
    ),
    // Anekartha of Hemacandra - specific H. an. first
    LsPattern(
      prefixes: ['H. an.'],
      regex: r'^(H[.] an[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/anekarthasamgraha/app1?\$2,\$3',
    ),
    // Anekartha - just "an."
    LsPattern(
      prefixes: ['an.'],
      regex: r'^(an[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/anekarthasamgraha/app1?\$2,\$3',
    ),
    // Shakuntala (Bohtlingk)
    LsPattern(
      prefixes: ['ŚĀK.'],
      regex: r'^(ŚĀK[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shakuntala/app2?\$2,\$3,\$4',
    ),
    // Shakuntala - 2 params (page, line) - goes to app2
    LsPattern(
      prefixes: ['ŚĀK.'],
      regex: r'^(ŚĀK[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shakuntala/app2?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['ŚĀK.'],
      regex: r'^(ŚĀK[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shakuntala/app1?\$2',
    ),
    // Aitareya Brahmana
    LsPattern(
      prefixes: ['AIT. BR.'],
      regex: r'^(AIT[.] BR[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/aitbr_auf/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['AIT. BR.'],
      regex: r'^(AIT[.] BR[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/aitbr/app1?\$2,\$3',
    ),
    // Malavikagni
    LsPattern(
      prefixes: ['MĀLAV.'],
      regex: r'^(MĀLAV[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/malavikagni/app2?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['MĀLAV.'],
      regex: r'^(MĀLAV[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/malavikagni/app1?\$2',
    ),
    // Pancatantra Kosegarten - uppercase Roman numerals (with optional space)
    LsPattern(
      prefixes: ['PAÑCAT.'],
      regex: r'^(PAÑCAT[.]) *([IVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app1?\$2,\$3',
    ),
    // Pancatantra Kosegarten - MORE SPECIFIC first (Roman numerals)
    LsPattern(
      prefixes: ['PAÑCAT.'],
      regex: r'^(PAÑCAT[.]) ([VI]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app1?\$2_lc,\$3',
    ),
    // Pancatantra Kosegarten - Prastavana
    LsPattern(
      prefixes: ['PAÑCAT.'],
      regex: r'^(PAÑCAT[.]) *(Pr[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app1?0,\$3',
    ),
    // Pancatantra Kosegarten - numeric (page,line)
    LsPattern(
      prefixes: ['PAÑCAT.'],
      regex: r'^(PAÑCAT[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app2?\$2,\$3',
    ),
    // Pancatantra ed. orn. - Roman numerals
    LsPattern(
      prefixes: ['PAÑCAT. ed. orn.', 'ed. orn.'],
      regex: r'^(PAÑCAT\.? ed\.? orn\.?|ed\.? orn\.?) *([VI]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankoseorn/app2?\$2,\$3',
    ),
    // Pancatantra ed. orn. - numeric with optional period and extra text at end
    LsPattern(
      prefixes: ['PAÑCAT. ed. orn.', 'ed. orn.'],
      regex: r'^(PAÑCAT\.? ed\.? orn\.?|ed\.? orn\.?) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankoseorn/app1?\$2,\$3',
    ),
    // Hitopadesha - uppercase Roman numerals (with optional space)
    LsPattern(
      prefixes: ['HIT.'],
      regex: r'^(HIT[.]) *([IVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?\$2,\$3',
    ),
    // Hitopadesha - MORE SPECIFIC first (Roman numerals)
    LsPattern(
      prefixes: ['HIT.'],
      regex: r'^(HIT[.]) ([IV]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?\$2_lc,\$3',
    ),
    // Hitopadesha - Prastavana
    LsPattern(
      prefixes: ['HIT.'],
      regex: r'^(HIT[.]) *(Pr[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?0,\$3',
    ),
    // Hitopadesha - numeric (page,line)
    LsPattern(
      prefixes: ['HIT.'],
      regex: r'^(HIT[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/hitopadesha/app2?\$2,\$3',
    ),
    // Amarakosha deslongchamp
    LsPattern(
      prefixes: ['AK.'],
      regex: r'^(AK[.]) *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/amara_dlc/app1?\$2,\$3,\$4,\$5',
    ),
    LsPattern(
      prefixes: ['AK.'],
      regex: r'^(AK[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/amara_dlc/app1?\$2,\$3,\$4',
    ),
    // Amarakosha Colebrooke - 4 params
    LsPattern(
      prefixes: ['COL.', 'COLEBR.'],
      regex: r'^(COL|COLEBR)[.] *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/amara_col/app1?\$2,\$3,\$4,\$5',
    ),
    // Amarakosha Colebrooke - with "ed." prefix - 4 params
    LsPattern(
      prefixes: ['AK. ed. COLEBR.'],
      regex:
          r'^(AK[.] ed[.] COLEBR[.]?) *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/amara_col/app1?\$2,\$3,\$4,\$5',
    ),
    // Amarakosha Colebrooke - with "ed." prefix
    LsPattern(
      prefixes: ['AK. ed. COLEBR.'],
      regex: r'^(AK[.] ed[.] COLEBR[.]?) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/amara_col/app1?\$2,\$3,\$4',
    ),
    // Amarakosha Colebrooke - 3 params
    LsPattern(
      prefixes: ['COL.', 'COLEBR.'],
      regex: r'^(COL|COLEBR)[.] *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/amara_col/app1?\$2,\$3,\$4',
    ),
    // Gitagovinda
    LsPattern(
      prefixes: ['GĪT.'],
      regex: r'^(GĪT[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/gitagov/app1?\$2,\$3',
    ),
    // Nirukta
    LsPattern(
      prefixes: ['NIR.'],
      regex: r'^(NIR[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/nirukta/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['NIR.'],
      regex: r'^(NIR[.]) *([IVXL]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/nirukta/app0?\$2_lc',
    ),
    // Nighantuka (with or without period after NAIGH)
    LsPattern(
      prefixes: ['NAIGH.'],
      regex: r'^(NAIGH[.]?) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/nirukta/app2?\$2,\$3',
    ),
    // Mugdhabodha
    LsPattern(
      prefixes: ['VOP.'],
      regex: r'^(VOP[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/mugdhabodha/app1?\$2,\$3',
    ),
    // Bhattikavya
    LsPattern(
      prefixes: ['BHAṬṬ.'],
      regex: r'^(BHAṬṬ[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhattikavya/app1?\$2,\$3',
    ),
    // Kumara Sambhava
    LsPattern(
      prefixes: ['KUMĀRAS.'],
      regex: r'^(KUMĀRAS[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/kumaras/app1?\$2,\$3',
    ),
    // Satapatha Brahmana
    LsPattern(
      prefixes: ['ŚAT. BR.'],
      regex: r'^(ŚAT[.] BR[.]) *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shatapathabr/app1?\$2,\$3,\$4,\$5',
    ),
    // Taittiriya Samhita
    LsPattern(
      prefixes: ['TS.'],
      regex: r'^(TS[.]) *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/taittiriyas/app1?\$2,\$3,\$4,\$5',
    ),
    // Taittiriya Brahmana
    LsPattern(
      prefixes: ['TBR.'],
      regex: r'^(TBR[.]) *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/taittiriyabr/app1?\$2,\$3,\$4,\$5',
    ),
    // Katyayana Shrauta Sutra
    LsPattern(
      prefixes: ['KĀTY. ŚR.'],
      regex: r'^(KĀTY[.] ŚR[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/katyasr/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['KĀTY. ŚR.'],
      regex: r'^(KĀTY[.] ŚR[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/katyasr/app2?\$2,\$3',
    ),
    // Pancaratra
    LsPattern(
      prefixes: ['PAÑCAR.'],
      regex: r'^(PAÑCAR[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pancar/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['PAÑCAR.'],
      regex: r'^(PAÑCAR[.]) +S\. +([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/pancar/app0?\$2',
    ),
    // Vikramorvashiya - two params (VIKR. 1,2) - MORE SPECIFIC FIRST
    LsPattern(
      prefixes: ['VIKR.', 'VIKRAM.'],
      regex: r'^(VIKR[.]|VIKRAM[.]?) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/vikramor/app2?\$2,\$3',
    ),
    // Vikramorvashiya - single param (VIKR. 1)
    LsPattern(
      prefixes: ['VIKR.', 'VIKRAM.'],
      regex: r'^(VIKR[.]|VIKRAM[.]?) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/vikramor/app1?\$2',
    ),
    // Nalopakhyana
    LsPattern(
      prefixes: ['N.'],
      regex: r'^(N[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bchrest1/app1?\$2,\$3',
    ),
    // Dasharatha's death
    LsPattern(
      prefixes: ['DAŚ.'],
      regex: r'^(DAŚ[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bchrest1/app2?\$2,\$3',
    ),
    // Vidushaka
    LsPattern(
      prefixes: ['VID.'],
      regex: r'^(VID[.]) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/bchrest1/app3?\$2',
    ),
    // Caurapancashika
    LsPattern(
      prefixes: ['CAURAP.'],
      regex: r'^(CAURAP[.]?) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhartrhari/app1?\$2',
    ),
    // Vishvamitra's battle
    LsPattern(
      prefixes: ['VIŚV.'],
      regex: r'^(VIŚV[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bchrest1/app4?\$2,\$3',
    ),
    // Bhartrihari Shataka
    LsPattern(
      prefixes: ['BHARTṚ.'],
      regex: r'^(BHARTṚ[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhartrhari/app2?\$2,\$3',
    ),
    // Bhartrihari Shataka Suppl.
    LsPattern(
      prefixes: ['BHARTṚ. Suppl.'],
      regex: r'^(BHARTṚ[.] Suppl[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhartrhari/app3?\$2',
    ),
    // Meghaduta
    LsPattern(
      prefixes: ['MEGH.'],
      regex: r'^(MEGH[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/meghasrnga/app1?\$2',
    ),
    // Shringara Tilaka
    LsPattern(
      prefixes: ['ŚṚṄGĀRAT.'],
      regex: r'^(ŚṚṄGĀRAT[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/meghasrnga/app2?\$2',
    ),
    // Medinikosha
    LsPattern(
      prefixes: ['MED.'],
      regex: r'^(MED[.]) *([a-zA-Z]+)[.] *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/medini/app1?\$2,\$3',
    ),
    // MED. with diacritic letters (like ś, ḍh, ṭh)
    LsPattern(
      prefixes: ['MED.'],
      regex: r'^(MED[.]) *([a-zA-Zāīūēōṇṭḍṇñṅśṣḥḍhṭh]+)[.] *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/medini/app1?\$2,\$3',
    ),
    // Ramayana SCHL prefix - kanda 1,2 -> schlegel
    LsPattern(
      prefixes: ['R. SCHL.'],
      regex: r'^(R[.] SCHL[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          '(\$2 == "1" || \$2 == "2") ? "https://sanskrit-lexicon-scans.github.io/ramayanaschl/?\$2,\$3,\$4" : "https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4"',
    ),
    // Abhidhana Chintamani Parisishta - standalone ś
    LsPattern(
      prefixes: ['ś.'],
      regex: r'^(ś[.]) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/abch2/app2?\$2',
    ),
    // Trikandashesha
    LsPattern(
      prefixes: ['TRIK.'],
      regex: r'^(TRIK[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/medini/app2?\$2,\$3,\$4',
    ),
    // Haravali
    LsPattern(
      prefixes: ['HĀR.'],
      regex: r'^(HĀR[.]) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/medini/app3?\$2',
    ),
    // Abhidhana Chintamani Parisishta - with special ś character
    LsPattern(
      prefixes: ['H. ś.'],
      regex: r'^(H\. ś\.) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/abch2/app2?\$2',
    ),
    // Abhidhana Chintamani Parisishta
    LsPattern(
      prefixes: ['H. ś.', 'ś.'],
      regex: r'^(H[.] ś[.|]ś[.]) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/abch2/app2?\$2',
    ),
    // Abhidhana Chintamani
    LsPattern(
      prefixes: ['H.'],
      regex: r'^(H[.]) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/abch2/app1?\$2',
    ),
    // Halayudha
    LsPattern(
      prefixes: ['HALĀY.'],
      regex: r'^(HALĀY[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/armh2/app1?\$2,\$3',
    ),
    // Manu
    LsPattern(
      prefixes: ['M.'],
      regex: r'^(M[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/manu/index.html?\$2,\$3',
    ),
    // Varaha Brihat Samhita
    LsPattern(
      prefixes: ['VARĀH. BṚH. S.'],
      regex: r'^(VARĀH[.] BṚH[.] S[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/brihatsam/app1?\$2,\$3',
    ),
    // Sahitya Darpana
    LsPattern(
      prefixes: ['SĀH. D.'],
      regex: r'^(SĀH[.] D[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/sahityadarpana/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['SĀH. D.'],
      regex: r'^(SĀH[.] D[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/sahityadarpana/app1?\$2',
    ),
    // Chrestomathie
    LsPattern(
      prefixes: ['Chr.'],
      regex: r'^(Chr[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bchrest2/index.html?\$2',
      dicts: ['pw'],
    ),
    // Dhatupatha
    LsPattern(
      prefixes: ['DHĀTUP.'],
      regex: r'^(DHĀTUP[.]) *([0-9]+)(.*)$',
      urlTemplate:
          'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-westergaard/disp/index.php?section=\$2',
    ),
    // Bhagavata Purana
    LsPattern(
      prefixes: ['BHĀG. P.'],
      regex: r'^(BHĀG[.] P[.]) *([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$',
      urlTemplate:
          '(\$2 == "10" || \$2 == "11" || \$2 == "12") ? "https://sanskrit-lexicon-scans.github.io/bhagp_bom/app1/?\$2,\$3,\$4" : "https://sanskrit-lexicon-scans.github.io/bhagp_bur/app1/?\$2,\$3,\$4"',
    ),
    // Bhagavata Purana Bombay edition
    LsPattern(
      prefixes: ['BHĀG. P. ed. Bomb.'],
      regex:
          r'^(BHĀG[.] P[.] ed[.] Bomb[.]) *([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhagp_bom/app1/?\$2,\$3,\$4',
    ),
    // Ramayana with 4 params - only use first 3 for URL (kanda 5 uses gorresio, drops 4th param)
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R[.]) *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          '(\$2 == "7") ? "https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4,\$5" : (\$2 == "1" || \$2 == "2") ? "https://sanskrit-lexicon-scans.github.io/ramayanaschl/?\$2,\$3,\$4" : "https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4"',
    ),
    // Ramayana Schlegel (R. N,N,N) - kanda 1,2
    // Ramayana Gorresio (R. N,N,N) - kanda 3,4,5,6
    // Ramayana Bombay (R. N,N,N) - kanda 7
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          '(\$2 == "1" || \$2 == "2") ? "https://sanskrit-lexicon-scans.github.io/ramayanaschl/?\$2,\$3,\$4" : (\$2 == "7") ? "https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4" : "https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4"',
    ),
    // Ramayana Gorresio - uppercase GORR
    LsPattern(
      prefixes: ['R. GORR.'],
      regex: r'^(R[.] GORR[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4',
    ),
    // Ramayana Gorresio - uppercase GORR with 2 params
    LsPattern(
      prefixes: ['R. GORR.'],
      regex: r'^(R[.] GORR[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,1',
    ),
    // Ramayana ed. Gorresio - explicit "ed." prefix
    LsPattern(
      prefixes: ['R. ed. GORR.'],
      regex: r'^(R[.] ed[.] GORR[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4',
    ),
    // Ramayana Gorresio - standalone GORR prefix
    LsPattern(
      prefixes: ['GORR.'],
      regex: r'^(GORR[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4',
    ),
    // Ramayana Gorresio - standalone GORR prefix with 2 params
    LsPattern(
      prefixes: ['GORR.'],
      regex: r'^(GORR[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,1',
    ),
    // Ramayana Bombay - for PWG, use fallback method to handle variable params
    LsPattern(
      prefixes: ['R. ed. Bomb.', 'R. ed. Bombay'],
      regex: r'^(R[.] ed[.] Bomb[.]|R[.] ed[.] Bombay[.]) *(.*)$',
      urlTemplate: 'ramayanaBombayUrl',
    ),
    // Ramayana with 2 params (add default verse 1) - kanda 1,2 -> schlegel, kanda 7 -> bombay, else -> gorresio
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          '(\$2 == "1" || \$2 == "2") ? "https://sanskrit-lexicon-scans.github.io/ramayanaschl/?\$2,\$3,1" : (\$2 == "7") ? "https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,1" : "https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,1"',
      dicts: ['pwg'],
    ),
    // Ramayana with 2 params for PW - kanda 1,2 -> schlegel, else -> gorresio
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          '(\$2 == "1" || \$2 == "2") ? "https://sanskrit-lexicon-scans.github.io/ramayanaschl/?\$2,\$3,1" : "https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,1"',
      dicts: ['pw'],
    ),
    // Panini - Ashtadhyayi (P. N,N,N)
    LsPattern(
      prefixes: ['P.'],
      regex: r'^(P[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'https://ashtadhyayi.com/sutraani/\$2/\$3/\$4',
    ),
    // Rig Veda Pratisthana - MORE SPECIFIC first (before generic ṚV.)
    LsPattern(
      prefixes: ['ṚV. PRĀTIŚ.'],
      regex: r'^(ṚV[.] PRĀTIŚ[.]) *([0-9]+), *([0-9]+)',
      urlTemplate: 'rvAvHymnUrl2',
    ),
    // Rig Veda - 3 params (ṚV. N,N,N)
    LsPattern(
      prefixes: ['ṚV.'],
      regex: r'^(ṚV[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'rvAvHymnUrl',
    ),
    // Rig Veda - 2 params (ṚV. N,N)
    LsPattern(
      prefixes: ['ṚV.'],
      regex: r'^(ṚV[.]) *([0-9]+), *([0-9]+)',
      urlTemplate: 'rvAvHymnUrl2',
    ),
    // Atharva Veda - 3 params (AV. N,N,N)
    LsPattern(
      prefixes: ['AV.'],
      regex: r'^(AV[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'rvAvHymnUrl',
    ),
    // Atharva Veda - 2 params (AV. N,N)
    LsPattern(
      prefixes: ['AV.'],
      regex: r'^(AV[.]) *([0-9]+), *([0-9]+)',
      urlTemplate: 'rvAvHymnUrl2',
    ),
  ];

  static final List<LsPattern> mw = [
    // Manu - specific pattern first
    LsPattern(
      prefixes: ['Mn.'],
      regex: r'^(Mn[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/manu/index.html?\$2,\$3',
    ),
    // Bhagavata Purana
    LsPattern(
      prefixes: ['BhP.'],
      regex: r'^(BhP[.]) *(1[012]|x|xi|xii|X|XI|XII), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhagp_bom/app1/?\$2_r20,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['BhP.'],
      regex: r'^(BhP[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhagp_bur/app1/?\$2_r20,\$3,\$4',
    ),
    // Bhagavad Gita - specific
    LsPattern(
      prefixes: ['Bhag.'],
      regex: r'^(Bhag[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?\$2,\$3',
    ),
    // Raghuvamsa - 3 params (Ragh. ed. Calc.)
    LsPattern(
      prefixes: ['Ragh. ed. Calc.', 'Raghuv.', 'Ragh. (C)'],
      regex: r'^(Ragh[.] ed[.] Calc[.]|Ragh[.] \(C\)|Raghuv[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?\$2,\$3,\$4',
    ),
    // Raghuvamsa - 3 params (Ragh.)
    LsPattern(
      prefixes: ['Ragh.'],
      regex: r'^(Ragh[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsa/app1?\$2,\$3,\$4',
    ),
    // Raghuvamsa - more specific 3 params with Calc
    LsPattern(
      prefixes: ['Ragh. ed. Calc.', 'Ragh. (C)'],
      regex:
          r'^(Ragh[.] ed[.] Calc[.|]Ragh[.] \(C\)[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?\$2,\$3,\$4',
    ),
    // Raghuvamsa - 2 params (Raghuv.)
    LsPattern(
      prefixes: ['Raghuv.'],
      regex: r'^(Raghuv[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?\$2,\$3',
    ),
    // Raghuvamsa - 2 params (Ragh.)
    LsPattern(
      prefixes: ['Ragh.'],
      regex: r'^(Ragh[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsa/app1?\$2,\$3',
    ),
    // Meghaduta - specific
    LsPattern(
      prefixes: ['Megh.'],
      regex: r'^(Megh[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/meghaduta/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Megh.'],
      regex: r'^(Megh[.]) *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/meghasrnga/app1?\$2',
    ),
    // Kumarasambhava - specific
    LsPattern(
      prefixes: ['Kum.', 'Kumāras.'],
      regex: r'^(Kum[.]|Kumāras[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/kumaras/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['Kum.', 'Kumāras.'],
      regex: r'^(Kum[.]|Kumāras[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/kumaras/app1?\$2,\$3',
    ),
    // Pancatantra - specific (Kosegarten ed.)
    LsPattern(
      prefixes: ['Pañcat.'],
      regex: r'^(Pañcat[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app2?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Pañcat.'],
      regex: r'^(Pañcat[.]) *([ivxlIVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Pañcat.'],
      regex: r'^(Pañcat[.]) *(Introd\.) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/pantankose/app1?0,\$3',
    ),
    // Yajnavalkya
    LsPattern(
      prefixes: ['Yājñ.'],
      regex: r'^(Yājñ[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/yajnavalkya/app1?\$2,\$3',
    ),
    // Hitopadesha
    LsPattern(
      prefixes: ['Hit.'],
      regex: r'^(Hit[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/hitopadesha/app2?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Hit.'],
      regex: r'^(Hit[.]) *([ivxlIVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Hit.'],
      regex: r'^(Hit[.]) *(Introd\.) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?0,\$3',
    ),
    // RV, AV - more specific regex
    LsPattern(
      prefixes: ['RV.', 'AV.'],
      regex: r'^(RV[.|]AV[.]) *([ivxlIVXL]+|[0-9]+), *([0-9]+), *([0-9]+)[.]?',
      urlTemplate: 'rvAvHymnUrl',
    ),
    // RV, AV - 2 param version
    LsPattern(
      prefixes: ['RV.', 'AV.'],
      regex: r'^(RV[.|]AV[.]) *([ivxlIVXL]+|[0-9]+), *([0-9]+)[.]?',
      urlTemplate: 'rvAvHymnUrl2',
    ),
    // Panini - handles both lowercase and uppercase Roman numerals (i,ii,iii,I,II,III -> 1,2,3)
    LsPattern(
      prefixes: ['Pāṇ.'],
      regex: r'^(Pāṇ[.]) *([ivxlIVXL]+)[ ,]+([0-9]+)[ ,]+([0-9]+)',
      urlTemplate: 'https://ashtadhyayi.com/sutraani/\$2/\$3/\$4',
    ),
    // R. 7,N,N,N (Bombay)
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R[.]) *(vii), *([0-9]+), *([0-9]+), *([0-9]+)[^0-9,]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4,\$5',
    ),
    // R. 7,N,N (Bombay)
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R[.]) *(vii), *([0-9]+), *([0-9]+)[^0-9,]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4',
    ),
    // R. (B.) R,N,N (Bombay)
    LsPattern(
      prefixes: ['R. (B.)'],
      regex: r'^(R[.] \(B\.?\)) *(vii), *([0-9]+), *([0-9]+)[^0-9,]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4',
    ),
    // R. G. with lowercase Roman numerals - specific for Gorresio
    LsPattern(
      prefixes: ['R. G.', 'R. (G)', 'R. [G]'],
      regex:
          r'^(R[.] G[.]|R[.] \(G\)|R[.] \[G\]) *([ivxlIVXL]+)[ ,]+([0-9]+)[ ,]+([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4',
    ),
    // R. (B.) with lowercase Roman numerals - specific for Bombay
    LsPattern(
      prefixes: ['R.', 'R. (B.)', 'R. B.', 'R. [B.]', 'R. [B]'],
      regex: r'^(R\. \(B\.\)|R\. B\.|R\. \[B\.\]|R\. \[B\]) *([0-9ivxlcmIVXLCM]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4',
    ),
    // R. (ed. Gorr.) with lowercase Roman numerals - specific for Gorresio
    LsPattern(
      prefixes: ['R.', 'R. (ed. Gorr.)', 'R. ed. Gorresio'],
      regex:
          r'^(R\. \(ed\. Gorr\.\)|R\. ed\. Gorresio\.) *([0-9ivxlcmIVXLCM]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?\$2,\$3,\$4',
    ),
    // R. ed. Bombay with lowercase Roman numerals
    LsPattern(
      prefixes: ['R.', 'R. ed. Bomb.', 'R. ed. Bombay'],
      regex:
          r'^(R\. ed\. Bomb\.|R\. ed\. Bombay) *([0-9ivxlcmIVXLCM]+)[ ,]+([0-9]+)[ ,]+([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4',
    ),
    // R. (ed. Bomb.) with lowercase Roman numerals
    LsPattern(
      prefixes: ['R. (ed. Bomb.)'],
      regex:
          r'^(R\. \(ed\. Bomb\.\)) *([0-9ivxlcmIVXLCM]+)[ ,]+([0-9]+)[ ,]+([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?\$2,\$3,\$4',
    ),
    // Ramayana Gorresio/Schlegel - general fallback
    LsPattern(
      prefixes: [
        'R.',
        'R. G.',
        'R. (G)',
        'R. [G]',
      ],
      regex:
          r'^(R\.|R\. G\.|R\. \(G\)|R\. \[G\]) *([0-9ivxlcmIVXLCM]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$',
      urlTemplate: 'ramayanaUrl',
    ),
    // Ramayana Bombay - with numeric kanda (fallback)
    LsPattern(
      prefixes: ['R. ed. Bomb.', 'R. ed. Bombay'],
      regex: r'^(R\. ed\. Bomb\.|R\. ed\. Bombay) *(.*)$',
      urlTemplate: 'ramayanaBombayUrl',
    ),
    // Dhatus - specific
    LsPattern(
      prefixes: ['Dhātup.', 'Dhāt.'],
      regex: r'^>? *(Dhātup\.|Dhāt\.) *([0-9ivxlcmIVXLCM]+)([ ,]+([0-9]+))?.*',
      urlTemplate: 'dhatuUrl',
    ),
    // Kathas - specific
    LsPattern(
      prefixes: ['Kathās.'],
      regex: r'^(Kathās[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/kss/index.html?\$2,\$3',
    ),
    // Shringara
    LsPattern(
      prefixes: ['Śṛṅgār.'],
      regex: r'^(Śṛṅgār[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/meghasrnga/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Śṛṅgār.'],
      regex: r'^(Śṛṅgār[.]) *([0-9ivxlcmIVXLCM]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/meghasrnga/app2?\$2',
    ),
    // Manu
    LsPattern(
      prefixes: ['Mn.'],
      regex: r'^(Mn[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/manusmriti/app1?\$2,\$3',
    ),
    // Bhagavata Purana
    LsPattern(
      prefixes: ['BhP.'],
      regex: r'^(BhP[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhagavatapurana/app1?\$2,\$3,\$4',
    ),
    // Yajnavalkya
    LsPattern(
      prefixes: ['Yājñ.'],
      regex: r'^(Yājñ[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/yajnavalkya/app1?\$2,\$3',
    ),
    // Raghuvamsa
    LsPattern(
      prefixes: ['Ragh.', 'Ragh. ed. Calc.', 'Raghuv.', 'Ragh. (C)'],
      regex:
          r'^(Ragh\.|Ragh[.] ed[.] Calc\.|Raghuv\.|Ragh[.] \(C\)[.]?) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['Ragh.', 'Ragh. ed. Calc.', 'Raghuv.', 'Ragh. (C)'],
      regex:
          r'^(Ragh\.|Ragh[.] ed[.] Calc\.|Raghuv\.|Ragh[.] \(C\)[.]?) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?\$2,\$3',
    ),
    // Sahitya - MW specific (sahityadarpana) - Roman Numerals
    LsPattern(
      prefixes: ['Sāh.'],
      regex: r'^(Sāh[.]) *([ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/sahityadarpana_mw/app1?\$2,\$3',
      dicts: ['mw'],
    ),
    // Sahitya - MW specific (sahityadarpana) - Arabic Numerals
    LsPattern(
      prefixes: ['Sāh.'],
      regex: r'^(Sāh[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/sahityadarpana/app1?\$2,\$3',
      dicts: ['mw'],
    ),
    // Sahitya - default (sahitya)
    LsPattern(
      prefixes: ['Sāh.'],
      regex: r'^(Sāh[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/sahityadarpana_mw/app1?\$2,\$3',
    ),
    // Vopadeva - MW specific (mugdhabodha)
    LsPattern(
      prefixes: ['Vop.'],
      regex: r'^(Vop[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/mugdhabodha/app1?\$2,\$3',
      dicts: ['mw'],
    ),
    // Vopadeva - default (vopadeva)
    LsPattern(
      prefixes: ['Vop.'],
      regex: r'^(Vop[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/vopadeva/app1?\$2,\$3',
    ),
    // Halayudha
    LsPattern(
      prefixes: ['Halāy.'],
      regex: r'^(Halāy[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/halayudha/app1?\$2,\$3',
    ),
    // Varaha Brihat Samhita
    LsPattern(
      prefixes: ['VarBṛS.'],
      regex: r'^(VarBṛS[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/brihatsam/app1?\$2,\$3',
    ),
    // Markandeya Purana
    LsPattern(
      prefixes: ['MārkP.', 'Mārk P.'],
      regex: r'^(MārkP\.|Mārk P\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/markandeyapurana/app1?\$2,\$3',
    ),
    // H. an.
    LsPattern(
      prefixes: ['H. an.'],
      regex: r'^(H[.] an[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/anekarthasamgraha/app1?\$2,\$3',
    ),
    // Shakuntala
    LsPattern(
      prefixes: ['Śāk.', 'Śak.'],
      regex: r'^(Śāk\.|Śak\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shakuntala/app2?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Śāk.', 'Śak.'],
      regex: r'^(Śāk\.|Śak\.) *([0-9ivxlcmIVXLCM]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shakuntala/app1?\$2',
    ),
    // Satapatha Brahmana - with Roman numerals (all variations including x, xiv, etc.)
    LsPattern(
      prefixes: ['Śat. Br.', 'ŚBr.'],
      regex:
          r'^(Śat\. Br\.|ŚBr\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shatapathabr/app1?\$2,\$3,\$4,\$5',
    ),
    // Satapatha Brahmana - with numeric kanda (4 params)
    LsPattern(
      prefixes: ['Śat. Br.', 'ŚBr.'],
      regex:
          r'^(Śat\. Br\.|ŚBr\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/shatapathabr/app1?\$2,\$3,\$4,\$5',
    ),
    // Sahitya Darpana
    LsPattern(
      prefixes: ['Sāh. D.'],
      regex: r'^(Sāh[.] D[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/sahityadarpana_mw/app1?\$2,\$3',
    ),
    // Bhagavad Gita
    LsPattern(
      prefixes: ['Bhag.'],
      regex: r'^(Bhag[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?\$2,\$3',
    ),
    // Pancatantra
    LsPattern(
      prefixes: ['Pañcat.'],
      regex: r'^(Pañcat[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app2?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Pañcat.'],
      regex: r'^(Pañcat[.]) *([ivxlIVXLC]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pantankose/app1?\$2,\$3,\$4',
    ),
    // VS
    LsPattern(
      prefixes: ['VS.'],
      regex: r'^(VS[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/vajasasa/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['VS.'],
      regex: r'^(VS[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/vajasasa/app1?\$2,\$3',
    ),
    // TS
    LsPattern(
      prefixes: ['TS.'],
      regex: r'^(TS[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/taittiriyas/app1?\$2,\$3,\$4,\$5',
    ),
    LsPattern(
      prefixes: ['TS.'],
      regex: r'^(TS[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/taittiriyas/app1?\$2,\$3,\$4',
    ),
    // Rajatar
    LsPattern(
      prefixes: ['Rājat. (C)'],
      regex: r'^(Rājat[.] \(C\)) *([0-9]+|[ivxlIVXL]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/rajatarcalc/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Rājat.'],
      regex: r'^(Rājat[.]) *(7|8|vii|viii|VII|VIII), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/rajatarcalc/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Rājat.'],
      regex: r'^(Rājat[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/rajatar/app1?\$2,\$3',
    ),
    // Bhattikavya
    LsPattern(
      prefixes: ['Bhaṭṭ.'],
      regex: r'^(Bhaṭṭ[.]) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhattikavya/app1?\$2,\$3',
    ),
    // Harivamsa
    LsPattern(
      prefixes: ['Hariv.'],
      regex: r'^(Hariv[.]) *([0-9]+)[.]?',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/hariv?\$2',
    ),
    // TBr
    LsPattern(
      prefixes: ['TBr.'],
      regex: r'^(TBr[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/taittiriyabr/app1?\$2,\$3,\$4,\$5',
    ),
    LsPattern(
      prefixes: ['TBr.'],
      regex: r'^(TBr[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/taittiriyabr/app1?\$2,\$3,\$4',
    ),
    // Dhātup
    LsPattern(
      prefixes: ['Dhātup.'],
      regex: r'^(Dhātup[.]) *([ivxlIVXL]+|[0-9]+), *([^ .,]*)',
      urlTemplate:
          'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-westergaard/disp/index.php?section=\$2',
    ),
    // Sāh
    LsPattern(
      prefixes: ['Sāh.'],
      regex: r'^(Sāh[.]) *([0-9ivxlcmIVXLCM]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/sahityadarpana/app1?\$2',
    ),
    // Katyashrauta
    LsPattern(
      prefixes: ['KātyŚr.', 'Kāty. Śr.'],
      regex: r'^(KātyŚr\.|Kāty\. Śr\.) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/katyasr/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['KātyŚr.', 'Kāty. Śr.'],
      regex: r'^(KātyŚr\.|Kāty\. Śr\.) *([0-9]+|[ivxlIVXL]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/katyasr/app2?\$2,\$3',
    ),
    // Kumarasambhava
    LsPattern(
      prefixes: ['Kumāras.', 'Kum.'],
      regex: r'^(Kumāras[.|]Kum[.]) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/kumaras/app1?\$2,\$3,\$4',
    ),
    // Malavikagnimitra
    LsPattern(
      prefixes: ['Mālav.'],
      regex: r'^(Mālav\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/malavikagni/app3?\$2,\$3',
    ),
    // Shringara
    LsPattern(
      prefixes: ['Śṛṅgār.', 'Śṛṅgt.'],
      regex: r'^(Śṛṅgār[.|]Śṛṅgt[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/srngara/app1?\$2,\$3',
    ),
    // Meghaduta
    LsPattern(
      prefixes: ['Megh.'],
      regex: r'^(Megh[.]) *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/meghaduta/app1?\$2,\$3',
    ),
    // Caurapancashika
    LsPattern(
      prefixes: ['Caurap. (A.)', 'Caurap.'],
      regex: r'^(Caurap[.] \(A\.\)|Caurap\.) *([0-9ivxlcmIVXLCM]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhartrhari/app1?\$2',
    ),
    // Bhartrihari
    LsPattern(
      prefixes: ['Bhartṛ.'],
      regex: r'^(Bhartṛ\.) *([0-9]+|[ivxlIVXLC]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/bhartrhari/app2?\$2,\$3',
    ),
    // Subhashita (Spr.)
    LsPattern(
      prefixes: ['Spr.'],
      regex: r'^(Spr\.) *([0-9ivxlcmIVXLCM]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/bohtlingk_mw/app1?\$2',
    ),
    // Amara Kosha
    LsPattern(
      prefixes: ['AK.'],
      regex: r'^(AK\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/amarakosha/app1?\$2,\$3,\$4',
    ),
    // Hitopadesha
    LsPattern(
      prefixes: ['Hit.'],
      regex: r'^(Hit\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?\$2,\$3',
    ),
    // Gita
    LsPattern(
      prefixes: ['Gīt.'],
      regex: r'^(Gīt\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/gitagov/app1?\$2,\$3',
    ),
    // Pancaratra
    LsPattern(
      prefixes: ['Pañcar.'],
      regex: r'^(Pañcar[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/pancar/app1?\$2,\$3,\$4',
    ),
    // Vikramorvashiya
    LsPattern(
      prefixes: ['Vikr.', 'Vikram.'],
      regex: r'^(Vikr\.|Vikram\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/vikramor_mw/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Vikr.', 'Vikram.'],
      regex: r'^(Vikr\.|Vikram\.) *([0-9ivxlcmIVXLCM]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/vikramor/app1?\$2',
    ),
    // Aitareya Brahmana
    LsPattern(
      prefixes: ['Ait. Br.', 'AitBr.'],
      regex: r'^(Ait[.] Br[.]|AitBr[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/aitbr_auf/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['Ait. Br.', 'AitBr.'],
      regex: r'^(Ait[.] Br[.]|AitBr[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/aitbr/app1?\$2,\$3',
    ),
    // Nirukta
    LsPattern(
      prefixes: ['Nir.'],
      regex: r'^(Nir[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/nirukta/app1?\$2,\$3',
    ),
    // Nighantu
    LsPattern(
      prefixes: ['Naigh.', 'Nigh.'],
      regex: r'^(Naigh[.]|Nigh[.]) *([0-9]+|[ivxlIVXL]+), *([0-9]+)[.]?',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/nirukta/app2?\$2,\$3',
    ),
    // Mahabharata for MW
    LsPattern(
      prefixes: ['MBh.', 'MBH.'],
      regex: r'^(MBh\.|MBH\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          'https://sanskrit-lexicon-scans.github.io/mbhbomb/app1/?\$2_r20,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['MBh.', 'MBH.'],
      regex: r'^(MBh\.|MBH\.) *([^ ,]+) *, *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/mbhcalc?\$2_r20.\$3',
    ),
  ];

  static List<LsPattern> getPatternsForDict(String dict) {
    final d = dict.toLowerCase();
    switch (d) {
      case 'pwg':
      case 'pw':
      case 'pwkvn':
        return pwg;
      case 'mw':
      case 'gra':
      case 'ap90':
      case 'ben':
      case 'ap':
      case 'bhs':
        return mw;
      case 'sch':
        return sch;
      default:
        return mw;
    }
  }

  static final List<LsPattern> sch = [
    // Panini for SCH
    LsPattern(
      prefixes: ['P.'],
      regex: r'^(P\.) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'https://ashtadhyayi.com/sutraani/\$2/\$3/\$4',
    ),
    // Ramayana for SCH
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'ramayanaSchUrl',
    ),
    LsPattern(
      prefixes: ['R.'],
      regex: r'^(R\. ed\. Bomb\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1?\$2,\$3,\$4',
    ),
    // Mahabharata for SCH
    LsPattern(
      prefixes: ['MBh.', 'MBH.'],
      regex: r'^(MBh\.|MBH\.) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/mbhbomb/app1?\$2,\$3,\$4',
    ),
    LsPattern(
      prefixes: ['MBh.', 'MBH.'],
      regex: r'^(MBh\.|MBH\.) *([0-9]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/mbhcalc?\$2.\$3',
    ),
    // Subhashita for SCH
    LsPattern(
      prefixes: ['Spr.'],
      regex: r'^(Spr\.) *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/boesp2/web1/boesp.html?\$2',
    ),
    // Bhagavata Purana for SCH
    LsPattern(
      prefixes: ['Bhāg.', 'BhP.'],
      regex: r'^(Bhāg\. P\.|BhP\.) *([0-9]+), *([0-9]+), *([0-9]+)',
      urlTemplate:
          '(\$2 == "10" ? "https://sanskrit-lexicon-scans.github.io/bhagp_bom/app1/?\$2,\$3,\$4" : "https://sanskrit-lexicon-scans.github.io/bhagp_bur/app1/?\$2,\$3,\$4")',
    ),
    // Varaha Brihat Samhita for SCH
    LsPattern(
      prefixes: ['Varāh.', 'VarBṛS.'],
      regex: r'^(Varāh\. Bṛh\. S\.|VarBṛS\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/brihatsam/app1?\$2,\$3',
    ),
    // Markandeya Purana for SCH
    LsPattern(
      prefixes: ['Mārk.', 'MārkP.'],
      regex: r'^(Mārk\. P\.|MārkP\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/markandeyapurana/app1?\$2,\$3',
    ),
    // Mn. / M.
    LsPattern(
      prefixes: ['Mn.', 'M.'],
      regex: r'^(Mn\.|M\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/manu/index.html?\$2,\$3',
    ),
    // Sahitya Darpana
    LsPattern(
      prefixes: ['Sāh.'],
      regex: r'^(Sāh\. D\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/sahityadarpana/app1?\$2,\$3',
    ),
    LsPattern(
      prefixes: ['Sāh.'],
      regex: r'^(Sāh\. D\.) *([0-9ivxlcmIVXLCM]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/sahityadarpana/app1?\$2',
    ),
    // Malavikagnimitra
    LsPattern(
      prefixes: ['Mālav.'],
      regex: r'^(Mālav\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/malavikagni/app1?\$2,\$3',
    ),
    // Vopadeva
    LsPattern(
      prefixes: ['Vop.'],
      regex: r'^(Vop\.) *([0-9ivxlcmIVXLCM]+), *([0-9]+)',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/vopadeva/app1?\$2,\$3',
    ),
    // Harivansha
    LsPattern(
      prefixes: ['H.'],
      regex: r'^(H\.) *([0-9]+)[.]?',
      urlTemplate: 'https://sanskrit-lexicon-scans.github.io/harivamsa/app1?\$2',
    ),
    // Include others from mw that are shared but check prefixes
    ...mw.where((p) => !['R.', 'MBh.', 'MBH.', 'Spr.', 'P.', 'BhP.', 'Bhāg.', 'VarBṛS.', 'Varāh.', 'MārkP.', 'Mārk.', 'Mn.', 'M.', 'Sāh.', 'Mālav.', 'Vop.'].any((pre) => p.prefixes.contains(pre))),
  ];
}
