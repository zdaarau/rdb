# TODOs

## Rebranding

-   Once we finished rebranding, we should add a Wikipedia article (DE and EN) and point the acronym "fork" articles [RDB
    (de)](https://de.wikipedia.org/wiki/RDB) and [RDB (en)](https://en.wikipedia.org/wiki/RDB) to it.

## To be discussed (-\> convert to GitLab issues (adding an additional `to be discussed` label)!)

-   There is at least one "Landsgemeinde" referendum (`id = 5bbc004292a21351232e52e7`) with no result (`NA`) where the result should actually be `"no"`
    (Landsgemeinde rejected proposal) if I'm not mistaken. Do we handle "Landsgemeinde" votes specially or why is that?

-   Should we also try to collect "surrounding conditions" information besides the formal institutional stuff? For example, international law recognizes a [set
    of conditions that must be met for a secession referendum to be considered
    legal](https://specials.dekoder.org/faq-schein-referendum-donezk-luhansk-cherson-saporishshja#q2).

-   Add additional database fields:

    -   `description`, holding a short prosa description of the referendum.
    -   `tags` (maybe we'll find a better name, e.g. `keywords`?), holding a list of freely definable tags, so we can create ad-hoc collections of referendums
        that share some common characteristic
    -   `status` to capture the recognition status of a voting

    Any more?

-   According to Uwe, we only capture "official"/"authorized" votings, but there are already inofficial ones present in the database like [this
    one](https://c2d.ch/referendum/HU/5bbbfee992a21351232e4f37) for which sudd.ch [reports](https://sudd.ch/event.php?id=hu042008):

    > Diese Abstimmung ist nicht offiziell und wird von niemandem anerkannt.

    Instead of not capturing such votings, it would be superior to introduce another variable indicating the status of a voting (official, inofficial, ...);
    currently we only have an *institutional* variable `legal_basis_type` (formerly `official_status`) which measures a completely different thing. Maybe name
    this new variable simply `status`?

-   Völkerrechtlich umstrittene Gebiete: Es gibt bislang keine explizite RDB-Policy dazu, wir müssten daher etwas definieren.

    Bspw. werden

    -   alle Abstimmungen, die die [Republik Kosovo](https://de.wikipedia.org/wiki/Kosovo) betreffen, unter dem `country_name` *Serbia* geführt...
    -   für die Abstimmungen in Taiwan uneinheitliche `country_name`'s verwendet, für die Abstimmungen am 2018-11-24 *Taiwan, Province of China*, für die
        anderen einfach *Taiwan*...

    Pragmatisch wäre, einfach die Handhabung der offiziellen/diplomatischen Schweiz zu übernehmen.

-   There is obviously not much consistency in how the referendum titles in the three languages are captured. According to the guidelines to add Swiss votings
    (`~/Arbeit/ZDA/Lokal/RDB/Materialen von Mayowa/CH_Vorgehen_Abstimmungseingabe.docx`), the `title_de` (and `title_fr` if one exists) are the official titles
    by the authorities and `title_en` is a translation of the German one. But

    -   the Swiss authorities (sometimes) also translate the title to English themselves
        ([example](https://www.admin.ch/gov/en/start/documentation/votes/20181125/horned-cow-initiative.html)).
    -   the guidelines to add international votings (`~/Arbeit/ZDA/Lokal/RDB/Materialen von Mayowa/Intl_Vorgehen_Abstimmungseingabe.docx`) don't say anything
        about the titles; but sometimes there's a German title for countries where almost certainly no official German version exists (e.g. Venezuela).

    Therefore, we should define a better/stricter policy how titles are captured (and identify existing entries violating this policy, so they can be
    corrected).

-   Topics-Hierarchie anpassen:

    -   den `topic_tier_3` "homosexuals" wohl etwas breiter fassen, bspw. "sexual orientation / gender identity".
    -   den `topic_tier_3` "compensation for loss of earnings for persons on military service or civil protection duty" kürzen!

    Sonstige Vorschläge?

## Ideas (-\> convert to GitLab issues (adding an additional `ideas` label)!)

-   We should ensure minimum quality of attachments (e.g. correct orientation, page ordering, OCR). Bad example:
    <https://services.c2d.ch/s3_objects/referendum_5bbbf59192a21351232e2e65_0001.pdf>

    I could probably write some validation fn in pkg rdb that checks all PDFs for text content to determine if they're OCR'ed, but maybe there's already more
    sophisticated software available for this.

    Ideally, NocoDB should ensure the minimum quality requirements upon upload and display an informative warning in case of violation (with an opt-in override
    to upload nevertheless).

## rdb R package

-   Prefix all Plotly fns with `plotly_` instead of `plot_` to avoid misconceptions.

-   Consider explicitly starting the Neon rw/ compute instance [via a REST API call](https://api-docs.neon.tech/reference/startprojectendpoint) to avoid
    connection timeouts due to startup delay when instance was suspended before (not necessary for public access since R/O instance doesn't suspend)

-   Add support to read sensitive pkg config vals from system keystore via [keyring](https://keyring.r-lib.org/) pkg (add support for this in
    `pal::*pkg_config_val*()` fns via an additional param `sensitive` (default `FALSE`) which makes them first try the system keystore before the other srcs)

-   Check out the [GeoNames](https://www.geonames.org/about.html) database and figure out whether it'd be worth to incorporate a suitable subset of it into our
    `countries`, `subnational_entites` and `municipalities` tables. Note that there's a dedicated R package [geonames](https://docs.ropensci.org/geonames/).

-   Automated vote entry creation by feeding scraped sudd.ch data to `rdb::add_rfrnds()`.

-   Implement `add_wikidata_id()` if possible: search Wikidata for proper type at ballot date in jurisdiction (country, subnational entity, municipality)

-   For meaningful cross-time analyses, we need additional information about countries ("jurisdictions"):

    -   Information about *territorial* changes. This is (at least for the most essential part) covered by our current ISO 3166-based country classification.

        TODO: Investigate whether additional information could be sourced from the [Correlates of War](https://en.wikipedia.org/wiki/Correlates_of_War)
        project's [Territorial Change](https://correlatesofwar.org/data-sets/territorial-change/) dataset.

    -   Information about *political/jurisdictional* changes. Currently we don't cover this beyond ISO 3166. [ISO 3166-1
        *numeric*](https://en.wikipedia.org/wiki/ISO_3166-1_numeric) does indirectly cover those political changes which are also accompanied by territorial
        changes, but no intra-territorial changes.

        Consider for example the country *Lybia* (`LY`) which already experienced 4 major political systems which are not reflected in ISO 3166:

        -   [(United) Kingdom of Libya (1951--1969)](https://en.wikipedia.org/wiki/Kingdom_of_Libya)
        -   [Libyan Arab Republic (1969--1977)](https://en.wikipedia.org/wiki/History_of_Libya_under_Muammar_Gaddafi#Libyan_Arab_Republic_(1969%E2%80%931977))
        -   [Great Socialist People's Libyan Arab Jamahiriya
            (1977--2011)](https://en.wikipedia.org/wiki/History_of_Libya_under_Muammar_Gaddafi#Great_Socialist_People's_Libyan_Arab_Jamahiriya_(1977%E2%80%932011))
        -   [National Transitional Council of Libya (2011--2012) / Libya (2012--)](https://en.wikipedia.org/wiki/National_Transitional_Council)

        Viable sources for political/jurisdictional changes of countries include:

        -   Wikidata

    -   Information about *(in)dependency* status of geographical entities on the *national* level (i.e. "countries"). Currently, we treat *external* [dependent
        territories](https://en.wikipedia.org/wiki/Dependent_territory) like [Norfolk Island](https://en.wikipedia.org/wiki/Norfolk_Island) (an external
        territory of Australia) the same as fully independent countries like Switzerland.

        Ideally, we'd augment our data with an additional variable from a suitable external source that holds information about a country's (in)dependency
        status. See [this Wikipedia article](https://en.wikipedia.org/wiki/Dependent_territory) for an overview. Maybe we could source the information from
        Wikidata?

## Other

-   Add terminology reference complementing other structure information like the RDB codebook. E.g. we often use the term "voting" to refer to a referendum
    instance but we don't have a formal lookup reference for these kind of things.

-   Are `id_sudd`s stable over time? Maybe contact the creator [Beat Müller](mailto:beat@sudd.ch) and ask?

-   Genauer abklären, inwieweit man Angaben von Swissvotes integrieren oder linken könnte. Evtl. Techniker hinter Swissvotes kontaktieren, um herauszufinden,
    mit welchen Weiterentwicklungen zu rechnen ist (Stichwort: API!); ein Blick in den Quellcode des [swissdd](https://politanch.github.io/swissdd/)-R-Pakets
    könnte womöglich ganz aufschlussreich sein!

## Internal (at least for now)

### Content

#### An Mayowa delegiert

-   Bei verschiedenen Abstimmungen meldet sudd.ch

    > "id=..." ist gelöscht , weil keine Volksabstimmung stattgefunden hat.

    Betroffen sind die folgenden Abstimmungen:

    -   [Ägypten 1976-06-10](https://sudd.ch/event.php?id=eg011976); bei uns:
        [5bbbe82f92a21351232e0381](https://admin.c2d.ch/referendum/5bbbe82f92a21351232e0381)
    -   [New Zealand 1931-12-02](https://sudd.ch/event.php?id=nz011931); bei uns 3 Einträge, jeweils einer pro Option:
        [5bbbe29792a21351232de3c9](https://admin.c2d.ch/referendum/5bbbe29792a21351232de3c9),
        [5bbbe29792a21351232de3c7](https://admin.c2d.ch/referendum/5bbbe29792a21351232de3c7),
        [5bbbe29792a21351232de3c7](https://admin.c2d.ch/referendum/5bbbe29792a21351232de3c7)
    -   [Puerto Rico 1952-11-04 (3. Abstimmungsvorlage "Abolition of certain social rights")](https://sudd.ch/event.php?lang=de&id=pr041952), bei uns:
        [5bbbe2ba92a21351232ded1f](https://admin.c2d.ch/referendum/5bbbe2ba92a21351232ded1f)

    Falls in diesen Fällen tatsächlich keine Abstimmungen stattfanden, sollten die Einträge aus der RDB entfernt werden!

-   Bei der [Abstimmung Norfolk Island 1980-07-10](https://admin.c2d.ch/referendum/5bbbeaee92a21351232e0ca5) meint sudd.ch, sie habe stattdessen [1979-07-10
    stattgefunden](https://sudd.ch/event.php?lang=de&id=nf011979). Falls sudd.ch Recht hat, sollte das korrigiert werden.

-   [Silagadze & Gherghina (2019)](https://link.springer.com/content/pdf/10.1057/s41304-019-00230-4.pdf) (S. 467) detected some referendums that are missing in
    the database -\> systematically check/add these!

    They include Italy ~~1929~~ and 1934, ~~Andorra 1933~~, ~~Austria 1938~~, Romania 2009, ~~Slovenia 2015~~, ~~Bulgaria 2016~~, ~~Netherlands 2016~~, ~~UK
    2016~~.

#### Other

-   A total of 858 referendums don't have a `type` set though it's a mandatory field (at least in the C2D admin interface) -\> the missing `type`s should be
    traced and added ASAP!

-   For the following referendums, the `votes_*` and `electorate_*` numbers have to be double-checked and possibly corrected since
    `electorate_total < sum(votes_*)`, which should by definition be impossible:

    ``` r
    rdb::rfrnds() %>%
      rdb::add_turnout(excl_dubious = FALSE) %>%
      dplyr::filter(turnout > 1.0) %>%
      dplyr::select(id, electorate_total, matches("^votes_(yes|no|empty|invalid)"), turnout)
    ```

    We should probably also double-check improbably high turnout numbers, e.g. those \> 0.9:

    ``` r
    rdb::rfrnds() %>%
      rdb::add_turnout(excl_dubious = FALSE) %>%
      dplyr::filter(dplyr::between(turnout, 0.9, 1.0)) %>%
      dplyr::select(id, electorate_total, matches("^votes_(yes|no|empty|invalid)"), turnout)
    ```

-   Complete and add [Aargau cantonal referendums 1888--1971](https://docs.google.com/spreadsheets/d/108CXVcVISDb8Z9R_fn7S82brXOE8dfIY0VKp3QTc0uU/) once [issue
    #29](https://github.com/ccmdesign/c2d-app/issues/29) is resolved.

    Also add the referendums from the [similar Excel sheets for the remaining 25 cantons we
    got](https://drive.google.com/drive/folders/1tZVg-ZQ8bi6KeSyofzngV2Qq3LNfE6Rc). See the [HLS R project](~/Arbeit/ZDA/Lokal/Projekte/HLS/hls_r_project) for
    some partial data cleansing/tidying.

-   Voting with `id == "5bbbfee992a21351232e4f37"` (Romania 2008-02-01) was limited to the region
    [Szeklerland](https://en.wikipedia.org/wiki/Sz%C3%A9kely_Land), therefore `subnational_entity` should be set to `Székely Land`

-   Sobald via Admin-Interface [nach Draft-Status gefiltert werden kann](https://github.com/ccmdesign/c2d-app/issues/27), sollten die existierenden Drafts
    geprüft werden -\> entweder vervollständigen und freischalten oder löschen!

-   Clean `id_official`; there are likely erroneous entries or ones that don't designate an `id_official` but another kind of ID; entries to double-check:

    ``` r
    rdb::rfrnds() %>% dplyr::filter(stringr::str_detect(string = id_official, pattern = "\\D") | !(country_code == "CH" & level == "national") & !is.na(id_official))
    ```

    Plus: Nobody knows what `id_official = "0"` means, so it should be replaced with `NA` (if no proper `id_official` can be determined).

-   **`municipality`** scheint inkonsistent zugewiesen; enthält Werte, die klar eine Gemeinde bezeichnen (bspw. `"London"`), aber auch solche wie
    [`"Republic of Serbian Krajina until 1991"`](https://de.wikipedia.org/wiki/Republik_Serbische_Krajina) oder
    [`Republic of Serbian People (1963-1992)`](https://de.wikipedia.org/wiki/Sozialistische_F%C3%B6derative_Republik_Jugoslawien#Sozialistische_F%C3%B6derative_Republik_Jugoslawien_(1963%E2%80%931992))...
    bei letzteren sollte

    -   der passende [`country_code_historical` für "Yugoslavia"](https://en.wikipedia.org/wiki/ISO_3166-3#Current_codes) gesetzt werden
    -   der `country_code = "CS"` für den Folgestaat "Serbia and Montenegro" gesetzt werden (oder besser leer lassen? TBD!)
    -   `is_past_jurisdiction = TRUE` gesetzt werden
    -   den gegenwärtigen Wert in `municipality` stattdessen in `subnational_entity_name` eintragen

-   Die Abstimmungen *Netherlands 2005-04-08* und *2014-12-17* fanden genau genommen auf [Sint Eustatius](https://de.wikipedia.org/wiki/Sint_Eustatius) statt,
    siehe sudd.ch-Einträge ([1](https://sudd.ch/event.php?id=an022005), [2](https://sudd.ch/event.php?id=bq012014)); Sint Eustatius ist zwar eine [Besondere
    Gemeinde der Niederlande](https://de.wikipedia.org/wiki/Karibische_Niederlande), besitzt aber einen eigenen ISO-Ländercode (BQ-SE) etc.

    Sollte daher als `country_name` nicht besser *Sint Eustatius* eingetragen werden? Andernfalls sollte `subnational_entity` auf `"Sint Eustatius"` gesetzt
    werden, da ja nicht die gesamte Niederlande abstimmen konnte!

-   Die Abstimmungen *France 2006-02-23* und *2006-09-06* beziehen sich auf Referenden in [Sark](https://de.wikipedia.org/wiki/Sark), `country_name` sollte
    daher auf `"United Kingdom"` oder (besser?) [`"Guernsey"`](https://de.wikipedia.org/wiki/Sark#Gesetzgebung_und_Autonomie) gesetzt werden und
    `subnational_entity = "Sark"`!

-   Regarding data about subnational referendums in the US, we currently know of two up-to-date compilations:

    -   [Ballotpedia](https://secure.wikimedia.org/wikipedia/en/w/index.php?title=Special:Search&search=Ballotpedia) maintains a [List of veto referendum ballot
        measures](https://ballotpedia.org/List_of_veto_referendum_ballot_measures), seems to be very rich in information.

    -   The *National Conference of State Legislatures (NCSL)* maintains a [Statewide Ballot Measures
        Database](https://www.ncsl.org/research/elections-and-campaigns/ballot-measures-database.aspx) that "includes all statewide ballot measures in the 50
        states and the District of Columbia, starting over a century ago". It's unclear (to me) what data this database exactly includes, but it might also be a
        viable avenue for automated additions to our database.

    The NCSL also provides information about the *institutional* conditions regarding direct democracy in the US states, e.g.
    [here](https://www.ncsl.org/research/elections-and-campaigns/chart-of-the-initiative-states.aspx). Also very rich is the information that Wikipedia provides
    in the article [*Initiatives and referendums in the United States*](https://en.wikipedia.org/wiki/Initiatives_and_referendums_in_the_United_States)

### Validation

-   Systematically inspect/handle all `applicability_constraint` violations (see `validate_rfrnds(check_applicability_constraint = TRUE)`).

-   Systematically check if variables that are "completely dependent" on other variables (like `inst_trigger_actor` on `inst_trigger_type`) are correctly
    filled.

    E.g. is `inst_trigger_type` missing for referendums with IDs `5cb82f07cb48652399618eb1` and `6080ef7d4132d76d38bfe9e0` although `inst_trigger_actor` is
    present!

    If the "completely dependent" property of these variables really holds, we should auto-fill them in the back-end and avoid the possibility of manual
    changes.

-   Systematically check if all votes in the `sudd.ch` database are included in the RDB -\> parse `https://sudd.ch/list.php?mode=allrefs` (the `id_sudd` is part
    of the link in the last column)

    A challenge is to identify the bogus referendums included on sudd.ch like [this one](https://sudd.ch/event.php?id=mb011902) (totally fabricated by [Gregor
    von Rezzori](https://de.wikipedia.org/wiki/Maghrebinische_Geschichten))

-   According to the guidelines in `~/Arbeit/ZDA/Lokal/RDB/Materialen von Mayowa/CH_Vorgehen_Abstimmungseingabe.docx`, the PDF `files` of `country_code == "CH"`
    entries must be named consistently `Voting_brochure_CH/Kantonskürzel_Jahr_Monat_Tag` ("Abstimmungsbroschüre"") and `Results_CH/Kantonskürzel_Jahr_Monat_Tag`
    (results) -\> check if this is actually always the case!

-   check `country_code` for obsolete codes, i.e. check if

    ``` r
    ISOcodes::ISO_3166_3$Alpha_4 %>%
      # exclude simple renamings where `country_code` didn't change
      magrittr::extract(stringr::str_sub(string = ., start = 3L) != "AA") %>%
      # extract former `country_code`
      stringr::str_sub(end = 2L) %>%
      # check
      magrittr::is_in(data2$country_code) %>%
      any()
    ```

    and if so, assign `country_code_historical`, set `is_past_jurisdiction = TRUE` and assign proper new `country_code`
    (`ISOcodes::ISO_3166_3$Alpha_4 %>% stringr::str_sub(start = 3L)`; if it's `"HH"`, a "manual" decision about which successor country we shall assign has to
    be hard-coded)\`

-   check `electorate_abroad` for obvious errors (e.g. `id == "5f99b6c8d1291cc3961f1c2c"` is one)

### Miscellaneous

-   Harvard Dataverse näher anschauen (Uwe meint, die RDB dort "aufzunehmen", könnte passen) und vergleichen mit [Zenodo](https://zenodo.org/) (siehe
    FA-Notizen) und [Datahub](https://datahub.io/).

    Abklären:

    -   *Lizenzanforderungen?* Default für Uploads ist CC0, aber es kann eine abweichende Lizenz definiert werden (es finden sich Beispiele mit ODbL 1.0!);
        darüber hinaus gelten nicht-rechtlich-bindende [*community norms*](https://dataverse.org/best-practices/dataverse-community-norms) (viel besserer Ansatz
        als in FORSbase!)

    -   Datensätze tatsächlich hinterlegt oder nur Referenzen?

-   Der C2D-Link auf der [ZDA-Webseite](https://www.zdaarau.ch/en/applications) sollte auf HTTP**S** geändert werden!

-   IT-Firmen, die als Nachfolge für CCM Design möglicherweise in Frage kommen:

    -   [Furqan Software](https://furqansoftware.com/); founder [Mahmud Ridwan](https://github.com/hjr265) developed two notable Goldmark extensions,
        [goldmark-d2](https://github.com/FurqanSoftware/goldmark-d2) and [goldmark-katex](https://github.com/FurqanSoftware/goldmark-katex), which [i.a. other
        notable activity](https://hjr265.me/open-source/) proves he deeply understands how open source is best organized and engineered!
    -   [PM TechHub](https://techhub.p-m.si/), Slowenien: Für den Neubau der `rdb.vote`-Hauptseite. Sie sind JAMStack-Profis und [Maintainer des Git-basierten
        CMS *Decap*](https://techhub.p-m.si/insights/introducing-decap-cms/).
    -   [Brudi](https://www.brudi.com/), Zürich
    -   [Cloud68](https://cloud68.co/), Estland
    -   [Liip](https://www.liip.ch/), Zürich (und weitere CH-Städte)
    -   [Ops One](https://opsone.ch/), Zürich

### Open questions / suggestions

#### Mit Irina besprechen

-   Kann mir jemand die genaue Bedeutung von `inst_object_revision_extent` sowie den `*precondition*`-Variablen erklären (insb. aus `inst_precondition_decision`
    werde ich nicht schlau...)?

-   Stimmen die Definitionen im Codebook so? Insb.:

    -   `committee_name`
    -   `type` und alle `inst_*`-Variablen

-   `inst_quorum_turnout` sollte standardisiert werden -\> was wäre eine geeignete, abschliessende Menge an Werten?

-   `inst_object_legal_level` sollte m. E. in Relation zu `level` stehen, tut es aber nicht. Dementsprechend kann `inst_object_legal_level` mehrdeutig sein
    (Beispiel: Ist `inst_object_legal_level = "law"` lokales, kantonales oder nationales Recht bei Referendum auf CH-Gemeindeebene?)

    Wir sollten das daher ändern (sprich auf *eindeutige* Weise erfassen. Vorschläge?

    Würde dieses Problem behoben, könnte `inst_object_legal_level` vermutlich auch als `ordinal_ascending` klassifiziert werden.

-   Ist `position_government` (ehemals `recommendation`) immer die Empfehlung der Regierung? Oder immer des Parlamentes? Oder manchmal dies, manchmal jenes?

    Zudem: Die Variable kennt gegenwärtig eig. 3 Ausprägungen, ich behandle den Wert `"None"` allerdings als `NA`, weil das gegenwärtige
    [Admin-Portal](https://admin.c2d.ch/) keine `NA`s zulässt, sprich die Coder bei Unbekanntheit des Wertes gezwungen sind, `"None"` anzugeben. Wie siehst du
    das?

-   Currently, `inst_trigger_threshold` is a free text field which is really bad for analysis since no coding consistency at all is enforced. Instead, we should
    define, in what way the same information could be captured in a more systematic way (splitting it into two vars `inst_trigger_threshold_relative` and
    `inst_trigger_threshold_absolute` might make sense), introduce the new variable and then convert the old values to the new format.

    Was meint Irina?

## Obsolete (referring to old CCM-Design infrastructure which is to be replaced)

-   Introduce `subnational_entity_code`; [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) codes seem perfectly suitable

    open points:

    -   we need to establish a policy on which `country_code` to assign to [subnational entitites that have both an ISO 3166-1 country code as well as an
        ISO-3166-2 subdivision code](https://en.wikipedia.org/wiki/ISO_3166-2#Subdivisions_included_in_ISO_3166-1) (recommended: avoid using the own ISO 3166-1
        country code but assign the one from the subdivision's "parent" country)

    -   how to deal with subnational entity changes? ISO 3166-2 is regularly updated but there doesn't seem to exist an equivalent to ISO-3166-3 codes on the
        subnational level...

    -   how to deal with "inofficial" / non-authorized subnational entities that don't have an ISO-3166-2 code?

    -   (I think introducing dedicated variables to capture the administrative division hierarchy below the national level in a more fine-grained way makes
        little sense since [administrative division levels vary widely across the globe](https://en.wikipedia.org/wiki/Administrative_division).)

    -\> see [issue #29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Introduce `is_past_jurisdiction` signifying if the relevant [jurisdiction](https://en.wikipedia.org/wiki/Jurisdiction_(area)) where the referendum took
    place still exists (`FALSE`) or not (`TRUE`) -\> see [issue #29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Introduce `country_code_historical` that holds the [ISO 3166-3](https://en.wikipedia.org/wiki/ISO_3166-3) code for referendums in countries that don't exist
    anymore (see also [this site by Statistics Canada](https://www.statcan.gc.ca/eng/subjects/standard/sccai/2011/scountry-desc); also informative:
    <https://en.wikipedia.org/wiki/United_Nations_list_of_Non-Self-Governing_Territories>); ISO 3166-3 seems to only assign codes for countries that ceased to
    exist since 1974 -\> is there any classification for older historical entities? -\> see [issue #29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Introduce `question` holding the referendum question 1:1 as it was asked and `question_en` containing an English translation; open question: what to do when
    the question was officially asked in multiple languages like in CH? -\> see [issue #29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Outsource institutional variables into separate database/MongoDB collection and adapt everything. -\> see [issue
    #42](https://github.com/ccmdesign/c2d-app/issues/42)

-   Extend the set of variables, so the `remarks` field isn't overloaded anymore. Possible extensions (taken from Louis' `remarks` structure (cf.
    `~/Arbeit/ZDA/Lokal/RDB/Materialen von Mayowa/Intl_Vorgehen_Abstimmungseingabe.docx`)):

    -   [ ] Background information on the vote (most important actors and events (sudd.ch, Wikipedia, NZZ etc.), content/main points)
    -   [x] Voting question; original language
    -   [x] Voting question; English (translation if necessary)
    -   [ ] Legal basis
    -   [ ] Name of the institution in original language
    -   [ ] Specialities of the institution (e.g. special quorum or 2 collecting periods)
    -   [ ] Specialities of the result (e.g. contradictory numbers)

-   `topics`: Adapt back-end to apply the same 3-tier topics logic that the R package does:

    -   Parent topics should be implicit, i.e. it should be impossible to select a parent topic and one of its respective childs topics at the same time
        (selecting a child topic should always result in implicit selection of its parent (e.g. in a different (e.g. faded) color)).
    -   The upper limit of 3 topics should refer to *main* topics (i.e. excluding any implicit parent topics).
    -   Based on the user's selection of *main* topics, parent topics should automatically be derived from child topics based on the [hierarchical topic
        structure](https://github.com/ccmdesign/c2d-app/blob/master/ch.c2d.admin/web/themes.json) and all the topics should be assigned to the 3 variables
        `topics_tier_1`, `topics_tier_2`, `topics_tier_3`.

    -\> see [issue #41](https://github.com/ccmdesign/c2d-app/issues/41)

-   Standardize `subnational_entity_name`; [ISO 3166-2 country subdivision names](https://www.iso.org/obp/ui/#iso:std:iso:3166:-2:ed-4:v1:en) (definition in
    chap. 3.29) seem suitable (mapping codes \<-\> names in R via `ISOcodes::ISO_3166_2`; note that for some subdivisions, different names exist for multiple
    languages, e.g. some [Swiss cantons](https://www.iso.org/obp/ui/#iso:code:3166:CH); `ISOcodes::ISO_3166_2` only tracks one name (the most "native" one per
    subdivision, I guess))

    -\> see [issue #44](https://github.com/ccmdesign/c2d-app/issues/44)

-   Rethink standardization of `country_name`. Current problem: standardization happens only when creating/editing entries. Thus, it's not consistent, e.g. for
    `country_code == "GB"` there are entries from before the relaunch with `country_name = "United Kingdom"`, and there are newer entries with the auto-deduced
    `country_name = "United Kingdom of Great Britain and Northern Ireland"`.

    See [`countrycode::codelist`](https://vincentarelbundock.github.io/countrycode/reference/codelist.html) for possible standards; [ISO 3166 English short
    country names](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) (`countrycode::codelist$iso.name.en`) seem most promising.

    Ideally, this would be done in the API back-end so `country_name` is determined at request time if possible.

    -\> see [issue #43](https://github.com/ccmdesign/c2d-app/issues/43) for a closed (and partially invalid) first problem report and
    [#51](https://github.com/ccmdesign/c2d-app/issues/51) for a follow-up requesting an improved UX.

-   Deduplicate file attachments! Currently, file attachments like voting brochures which apply to multiple proposals on the same ballot date are attached to
    each individual proposal, thus resulting in file duplications. Example: subnational ballot date in ZH, CH \@ 2022-05-15 has 4 proposals and the file
    `voting_brochure_zh_2022_05_15_de.pdf` is uploaded 4 different times to our Amazon S3 bucket:

    -   `62d6760ca52c3995043a8a1e`: <https://services.c2d.ch/s3_objects/referendum_62d6760ca52c3995043a8a1e_0001.pdf>
    -   `62d67203a52c3995043a8a16`: <https://services.c2d.ch/s3_objects/referendum_62d67203a52c3995043a8a16_0001.pdf>
    -   `62d66e97a52c3995043a8a0f`: <https://services.c2d.ch/s3_objects/referendum_62d66e97a52c3995043a8a0f_0001.pdf>
    -   `62d66ce0a52c3995043a8a08`: <https://services.c2d.ch/s3_objects/referendum_62d66ce0a52c3995043a8a08_0002.pdf>

    Ideally, we'd have two different attachment types:

    1.  Attachments that belong to an individual proposal.
    2.  Attachments that belong to a whole ballot date in a jurisdiction, i.e. all proposals at that ballot.

    That way uploading *and* assigning e.g. a voting brochure to referendums would be a *single action*.

    Rough outline of the procedure for introducing the second attachment type:

    1.  Create new ballot-date-level database with primary key `country_code_historical`/`country_code` + `subnational_entity_code` + `municipality` +
        **`date`**, plus a field for attachment metadata (to be discussed what exactly is sensible here).

    2.  Create necessary API endpoints and front-end logic for type 2 attachments.

    3.  Treat all existing attachments as belonging to individual proposals (type 1).

    4.  Programmatically identify the attachments that belong to ballot dates (type 2) instead by comparing file hashes (open question: are file hashes already
        available from S3 some way or do we have to download all attachments and calculate them ourselves?) and convert them to type 2.

-   C2D admin front-end: Louis' Dokument `~/Arbeit/ZDA/Lokal/RDB/Materialen von Mayowa/Intl_Louis/3_Test_Datenbank.docx`

-   C2D website: Möglichkeit zum Report falscher/fehlender Daten schaffen! Bevor CCM Design damit beauftragt wird, sollten wir definieren, wie ungefähr das
    aussehen soll. Bspw. einfach via HTML-Formular mit geeigneten Feldern (je nach Seite, von dem es aufgerufen wird, bereits vorbefüllt (`country_code`,
    `level`, `id` etc.))?

-   C2D website: The about text should be overhauled.

-   C2D website: The listing of referendums should be overhauled. It currently lacks important information, e.g. `level`.

-   Once referendum deletions are possible on production servers, extend tests to modify every single data field individually.

-   Once [issue #82](https://github.com/ccmdesign/c2d-app/issues/82) is fixed, remove/adapt all remaining code handling `country_code_historical` and
    `is_past_jurisdiction` (especially the sudd.ch-related fns have to be overhauled)

-   As soon as [issue #57](https://github.com/ccmdesign/c2d-app/issues/57) is resolved, properly process the question variables (and adapt codebook).

-   Implement fn to rename file attachments as soon as [issue #69](https://github.com/ccmdesign/c2d-app/issues/69) is resolved.
