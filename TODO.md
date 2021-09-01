# TODOs

## Reported to [CCM Design](https://github.com/ccmdesign/c2d-app/issues/)

-   Publish code under AGPL \>= 3, see [issue \#26](https://github.com/ccmdesign/c2d-app/issues/26)

    We should then make the repository public!

-   C2D Admin Front-end: Add possibility to filter by draft status (binary) and color draft rows (e.g. in orange) -\> see [issue
    \#26](https://github.com/ccmdesign/c2d-app/issues/27)

-   C2D Website: Lizenzierung der Daten fehlt (betrifft auch den Download via c2d-Paket)! [ODC-ODbL](https://opendatacommons.org/licenses/odbl/summary/) würde
    sich anbieten. -\> see [issue \#37](https://github.com/ccmdesign/c2d-app/issues/37)

    Once this is implemented, the same license terms should be added to the c2d package documentation!

-   Introduce `date_time_last_edited` holding the timestamp of a referendum entry's last edit. -\> see [issue
    \#29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Add `id_official` and `id_sudd`! Then I can populate them with the (corrected) data from the former `number` variable and `number` can be deleted. -\> see
    [issue \#29](https://github.com/ccmdesign/c2d-app/issues/29)

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

    -\> see [issue \#29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Introduce `is_past_jurisdiction` signifying if the relevant [jurisdiction](https://en.wikipedia.org/wiki/Jurisdiction_(area)) where the referendum took
    place still exists (`FALSE`) or not (`TRUE`) -\> see [issue \#29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Introduce `country_code_historical` that holds the [ISO 3166-3](https://en.wikipedia.org/wiki/ISO_3166-3) code for referendums in countries that don't exist
    anymore (see also [this site by Statistics Canada](https://www.statcan.gc.ca/eng/subjects/standard/sccai/2011/scountry-desc); also informative:
    <https://en.wikipedia.org/wiki/United_Nations_list_of_Non-Self-Governing_Territories>); ISO 3166-3 seems to only assign codes for countries that ceased to
    exist since 1974 -\> is there any classification for older historical entities? -\> see [issue \#29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Introduce `question` holding the referendum question 1:1 as it was asked and `question_en` containing an English translation; open question: what to do when
    the question was officially asked in multiple languages like in CH? -\> see [issue \#29](https://github.com/ccmdesign/c2d-app/issues/29)

-   Outsource institutional variables into separate database/MongoDB collection and adapt everything. -\> see [issue
    \#42](https://github.com/ccmdesign/c2d-app/issues/42)

-   Extend the set of variables so the `remarks` field isn't overloaded anymore. Possible extensions (taken from Louis' `remarks` structure (cf.
    `~/Arbeit/ZDA/Lokal/C2D-Datenbank/Materialen von Mayowa/Intl_Vorgehen_Abstimmungseingabe.docx`)):

    -   [ ] Background information on the vote (most important actors and events (sudd.ch, Wikipedia, NZZ etc.), content/main points)
    -   [x] Voting question; original language
    -   [x] Voting question; English (translation if necessary)
    -   [ ] Legal basis
    -   [ ] Name of the institution in original language
    -   [ ] Specialities of the institution (e.g. special quorum or 2 collecting periods)
    -   [ ] Specialities of the result (e.g. contradictory numbers)

-   `tags`: Adapt back-end to apply the same 3-tier tags logic that the R package does:

    -   Parent tags should be implicit, i.e. it should be impossible to select a parent tag and one of its respective childs tags at the same time (selecting a
        child tag should always result in implicit selection of its parent (e.g. in a different (e.g. faded) color)).
    -   The upper limit of 3 tags should refer to *main* tags (i.e. excluding any implicit parent tags).
    -   Based on the user's selection of *main* tags, parent tags should automatically be derived from child tags based on the [hierarchical tag
        structure](https://github.com/ccmdesign/c2d-app/blob/master/ch.c2d.admin/web/themes.json) and all the tags should be assigned to the 3 variables
        `tags_tier_1`, `tags_tier_2`, `tags_tier_3`.

    -\> see [issue \#41](https://github.com/ccmdesign/c2d-app/issues/41)

-   Standardize `subnational_entity_name`; [ISO 3166-2 country subdivision names](https://www.iso.org/obp/ui/#iso:std:iso:3166:-2:ed-4:v1:en) (definition in
    chap. 3.29) seem suitable (mapping codes \<-\> names in R via `ISOcodes::ISO_3166_2`; note that for some subdivisions, different names exist for multiple
    languages, e.g. some [Swiss cantons](https://www.iso.org/obp/ui/#iso:code:3166:CH); `ISOcodes::ISO_3166_2` only tracks one name (the most "native" one per
    subdivision, I guess))

    -\> see [issue \#44](https://github.com/ccmdesign/c2d-app/issues/44)

## Internal (at least for now)

-   Rethink standardization of `country_name`. Current problem: standardization happens only when creating/editing entries. Thus, it's not consistent, e.g. for
    `country_code == "GB"` there are entries from before the relaunch with `country_name = "United Kingdom"`, and there are newer entries with the auto-deduced
    `country_name = "United Kingdom of Great Britain and Northern Ireland"`.

    See [`countrycode::codelist`](https://vincentarelbundock.github.io/countrycode/reference/codelist.html) for possible standards; [ISO 3166 English short
    country names](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) (`countrycode::codelist$iso.name.en`) seem most promising.

    Ideally, this would be done in the API back-end so `country_name` is determined at request time if possible.

    -\> see [issue \#43](https://github.com/ccmdesign/c2d-app/issues/43) for a closed (and partially invalid) first problem report (need to submit a new one).

-   According to Uwe, we only capture "official"/"authorized" votings, but there are already inofficial ones present in the database like [this
    one](https://c2d.ch/referendum/HU/5bbbfee992a21351232e4f37) for which sudd.ch [reports](https://sudd.ch/event.php?id=hu042008):

    > Diese Abstimmung ist nicht offiziell und wird von niemandem anerkannt.

    Instead of not capturing such votings, it would be superior to introduce another variable indicating the status of a voting (official, inofficial, ...);
    currently we only have an *institutional* variable `legal_basis_type` (formerly `official_status`) which measures a completely different thing. Maybe name
    this new variable simply `status`?

-   We need a proper way to capture referendums with other or more than yes-or-no answer options. This includes

    -   other options than yes/no (e.g. [this one](https://sudd.ch/event.php?id=cl022020))
    -   multiple options (e.g. [like this one](https://sudd.ch/event.php?id=bq012014))
    -   preference / hierarchy information, i.e. whether or not multiple choices at the same time are allowed (i.e. whether or not options are mutually
        exclusive) -- and if so -- how ambiguities are resolved (e.g. by an additional preference list)

    We would also need to decide if counterproposals are simply to be included as additional "options" or if they are to be captured as separate entries
    (recommended); if the latter, we should introduce an additional variable `interdependent_ids` or the like to link to the "sibling" entries.

    Additionally,

    -   the `result` variable needs to be changed to hold the option that won the referendum and
    -   the `votes_yes` and `votes_no` (as well as the same sub-vars in `votes_per_subterritory`) variables need to be replaced by a single nested (list-type)
        variable `votes_substantive` that holds a subfield with the number of votes per option (named by the option?).

-   There is obviously not much consistency in how the referendum titles in the three languages are captured. According to the guidelines to add Swiss votings
    (`~/Arbeit/ZDA/Lokal/C2D-Datenbank/Materialen von Mayowa/CH_Vorgehen_Abstimmungseingabe.docx`), the `title_de` (and `title_fr` if one exists) are the
    official titles by the authorities and `title_en` is a translation of the German one. But

    -   the Swiss authorities (sometimes) also translate the title to English themselves
        ([example](https://www.admin.ch/gov/en/start/documentation/votes/20181125/horned-cow-initiative.html)).
    -   the guidelines to add international votings (`~/Arbeit/ZDA/Lokal/C2D-Datenbank/Materialen von Mayowa/Intl_Vorgehen_Abstimmungseingabe.docx`) don't say
        anything about the titles; but sometimes there's a German title for countries where almost certainly no official German version exists (e.g. Venezuela).

    Therefore, we should define a better/stricter policy how titles are captured (and identify existing entries violating this policy, so they can be
    corrected).

-   C2D website: Möglichkeit zum Report falscher/fehlender Daten schaffen! Bevor CCM Design damit beauftragt wird, sollten wir definieren, wie ungefähr das
    aussehen soll. Bspw. einfach via HTML-Formular mit geeigneten Feldern (je nach Seite, von dem es aufgerufen wird, bereits vorbefüllt (`country_code`,
    `level`, `id` etc.))?

-   C2D website: The about text should be overhauled.

-   C2D website: The listing of referendums should be overhauled. It currently lacks important information, e.g. `level`.

-   C2D admin front-end: Louis' Dokument `~/Arbeit/ZDA/Lokal/C2D-Datenbank/Materialen von Mayowa/Intl_Louis/3_Test_Datenbank.docx`

-   MongoDB/API: Track atomic edit history, traceable by author, and make it visually inspectable (some kind off diff viewer would be cool). On top of this,
    some method to easily undo specific or all edits by a specific user account should be added.

    See [issue \#34](https://github.com/ccmdesign/c2d-app/issues/34) (point 3) for a tentative request and [@liviass
    answer](<https://github.com/ccmdesign/c2d-app/issues/34#issuecomment-852566636>) about an already existing events collection (with no API endpoint so far).

-   MongoDB: optimize order of subvariables (`files` and `context.votes_per_canton`); doing this post-hoc in R is slow/inefficient, so getting the JSON in the
    desired order directly from the API would be cool...

    but is this actually possible? generally, the order of variables in the returned JSON seems random: compare e.g. `date` of
    [here](https://services.c2d.ch/referendums/6102ae4ec72633da60229941) vs. [here](https://services.c2d.ch/referendums/604b33cb4132d76d38bfe97b)

### Content

-   Bei verschiedenen Abstimmungen meldet sudd.ch

    > "id=..." ist gelöscht , weil keine Volksabstimmung stattgefunden hat.

    Betroffen sind die folgenden Abstimmungen:

    -   [Ägypten 1976-06-10](https://sudd.ch/event.php?id=eg011976)
    -   [New Zealand 1931-12-02](https://sudd.ch/event.php?id=nz011931) (3 Einträge in der C2D-Datenbank, jeweils einer pro Option)
    -   [Puerto Rico 1952-11-04 (3. Abstimmungsvorlage "Abolition of certain social rights")](https://sudd.ch/event.php?lang=de&id=pr041952)

    Falls in diesen Fällen tatsächlich keine Abstimmungen stattfanden, sollten die Einträge aus der C2D-Datenbank entfernt werden!

    TODO: Via R alle betroffenen Referenden in unserer Datenbank ausfindig machen.

-   Sobald via Admin-Interface [nach Draft-Status gefiltert werden kann](https://github.com/ccmdesign/c2d-app/issues/27), sollten die existierenden Drafts
    geprüft werden -\> entweder vervollständigen und freischalten oder löschen!

-   Clean `id_official`; there are likely erroneous entries or ones that don't designate an `id_official` but another kind of ID; entries to double-check:

    ``` {.r}
    c2d::referendums() %>% dplyr::filter(stringr::str_detect(string = id_official, pattern = "\\D") | !(country_code == "CH" & level == "national") & !is.na(id_official))
    ```

    Plus: What does `id_official = "0"` mean?

-   Voting with `id == "5bbbfee992a21351232e4f37"` (Romania 2008-02-01) was limited to the region
    [Szeklerland](https://en.wikipedia.org/wiki/Sz%C3%A9kely_Land), therefore `subnational_entity` should be set to `Székely Land`

-   **`municipality`** scheint inkonsistent zugewiesen; enthält Werte, die klar eine Gemeinde bezeichnen (bspw. `"London"`), aber auch solche wie
    [`"Republic of Serbian Krajina until 1991"`](https://de.wikipedia.org/wiki/Republik_Serbische_Krajina) oder
    [`Republic of Serbian People (1963-1992)`](https://de.wikipedia.org/wiki/Sozialistische_F%C3%B6derative_Republik_Jugoslawien#Sozialistische_F%C3%B6derative_Republik_Jugoslawien_(1963%E2%80%931992))...
    bei letzteren sollte

    -   der passende [`country_code_historical` für "Yugoslavia"](https://en.wikipedia.org/wiki/ISO_3166-3#Current_codes) gesetzt werden
    -   der `country_code = "CS"` für den Folgestaat "Serbia and Montenegro" gesetzt werden (oder besser leer lassen? TBD!)
    -   `is_past_jurisdiction = TRUE` gesetzt werden
    -   den gegenwärtigen Wert in `municipality` stattdessen in `subnational_entity_name` eintragen

-   A total of 860 referendums don't have a `type` set though it's a mandatory field (at least in the C2D admin interface) -\> the missing `type`s should be
    traced and added ASAP!

-   [Silagadze & Gherghina (2019)](https://link.springer.com/content/pdf/10.1057/s41304-019-00230-4.pdf) (S. 467) detected some referendums that are missing in
    the database -\> systematically check/add these!

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

-   Systematically inspect/handle all `applicability_constraint` violations (see `validate_referendums(check_applicability_constraint = TRUE)`).

-   Systematically check if variables that are "completely dependent" on other variables (like `inst_trigger_actor` on `inst_trigger_type`) are correctly
    filled.

    E.g. is `inst_trigger_type` missing for referendums with IDs `5cb82f07cb48652399618eb1` and `6080ef7d4132d76d38bfe9e0` although `inst_trigger_actor` is
    present!

    If the "completely dependent" property of these variables really holds, we should auto-fill them in the back-end and avoid the possibility of manual
    changes.

-   Systematically check if all votes in the `sudd.ch` database are included in the C2D database -\> parse `https://sudd.ch/list.php?mode=allrefs` (the
    `id_sudd` is part of the link in the last column)

-   According to the guidelines in `~/Arbeit/ZDA/Lokal/C2D-Datenbank/Materialen von Mayowa/CH_Vorgehen_Abstimmungseingabe.docx`, the PDF `files` of
    `country_code == "CH"` entries must be named consistently `Voting_brochure_CH/Kantonskürzel_Jahr_Monat_Tag` ("Abstimmungsbroschüre"") and
    `Results_CH/Kantonskürzel_Jahr_Monat_Tag` (results) -\> check if this is actually always the case!

-   check `country_code` for obsolete codes, i.e. check if

    ``` {.r}
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

### c2d R package

-   Implement fn to delete referendums once [issue \#45](https://github.com/ccmdesign/c2d-app/issues/45) is resolved.

-   Automated vote entry creation by feeding scraped data to `c2d::add_referendums()`.

-   Funktion schreiben zum Hinzufügen der von Uwe favorisierten Weltregionen:

    ![scan](https://i.imgur.com/88H2TZz.jpeg)

    [`countrycode::codelist$region23`](https://vincentarelbundock.github.io/countrycode/reference/codelist.html) (Weltbankregionen) oder
    `countrycode::codelist$un.regionsub.name` ([UN-Regionen](https://en.wikipedia.org/wiki/United_Nations_geoscheme)) scheint eine guter Start -\> dann einfach
    noch abändern, sodass Uwe's Spezialwünsche erfüllt sind!

### Miscellaneous

-   Die Datenbank braucht ein Logo! (Dann könnten auch passende Favicons [generiert werden](https://realfavicongenerator.net/)!)

-   Harvard Dataverse näher anschauen (Uwe meint, die C2D-Datenbank dort "aufzunehmen", könnte passen) und vergleichen mit [Zenodo](https://zenodo.org/) (siehe
    FA-Notizen).

    Abklären:

    -   *Lizenzanforderungen?* Default für Uploads ist CC0, aber es kann eine abweichende Lizenz definiert werden (es finden sich Beispiele mit ODbL 1.0!);
        darüber hinaus gelten nicht-rechtlich-bindende [*community norms*](https://dataverse.org/best-practices/dataverse-community-norms) (viel besserer Ansatz
        als in FORSbase!)

    -   Datensätze tatsächlich hinterlegt oder nur Referenzen?

-   Der C2D-Link auf der [ZDA-Webseite](https://www.zdaarau.ch/en/applications) sollte auf HTTP**S** geändert werden!

### Database renaming

-   Bislang gilt: *C2D* wird als alleiniger Name für die Datenbank bestehen bleiben, sollte die C2D-Abteilung, wie von Andreas Glaser beabsichtigt, umbenannt
    werden. Dies weil die Datenbank unter diesem Kürzel angeblich bereits eine gewisse Bekanntheit erlangt hat. Allerdings taugt "C2D" beim besten Willen nicht
    als Akronym für eine Datenbank...

    Ich würde daher stattdessen eine zügige Umbenennung in

    -   **D3** für ***D**atabase on **D**irect **D**emocracy* nahelegen! Die Domain `d3.vote` wäre noch zu haben (1. Jahr USD 650.-, danach USD 65.-/Jahr). Im
        Politik-Bereich ist `D3` bislang nicht besetzt; alles ziemlich unverfänglich, wofür [D3 steht](https://en.wikipedia.org/wiki/D3) (am nächsten käme noch
        die JavaScript-Datenvisualisierungs-Library [D3.js](https://en.wikipedia.org/wiki/D3.js), short for *Data-Driven Documents*).

    -   oder -- falls *Direct Democracy* vermieden werden soll im Namen (bspw. wegen [starker Vereinnahmung durch politische
        Bewegungen](https://en.wikipedia.org/wiki/Direct_democracy_(disambiguation))) -- **RDB** für ***R**eferendum **D**ata**b**ase*. Die Domain `rdb.vote`
        wäre noch zu haben (USD 95.34/Jahr). Im Politik-Bereich ist `RDB` bislang kaum besetzt; alles ziemlich unverfänglich, wofür RDB [international
        steht](https://en.wikipedia.org/wiki/RDB); auch im [deutschsprachigen Raum](https://de.wikipedia.org/wiki/RDB) gibt es keine problematische Konkurrenz
        (am ehesten noch [diese Rechtsdatenbank](https://rdb.manz.at/)).

    Die alte Domain `c2d.ch` könnten wir einige Jahre weiter halten und einfach auf die neue umleiten.

### Open questions / suggestions

#### Mit Irina besprechen

-   Kann mir jemand die genaue Bedeutung von `inst_object_revision_extent` sowie den `*precondition*`-Variablen erklären (insb. aus `inst_precondition_decision`
    werde ich nicht schlau...)?

-   Stimmen die Definitionen im Codebook so? Insb.:

    -   `committee_name`
    -   `type` und alle `inst_*`-Variablen

-   `inst_quorum_turnout` sollte standardisiert werden -\> was wäre eine geeignete, abschliessende Menge an Werten?

-   Was ist der Nutzen/zusätzliche Informationsgehalt von `inst_is_counter_proposal` sowie `inst_is_assembly`? Ob ein Referendum ein `"counter proposal"` bzw.
    ein `"citizens' assembly"` ist, wird ja bereits in `type` erfasst.

    Diesbezüglich gilt anzumerken, dass in der Datenbank

    -   21 Fälle enthalten sind, bei denen `inst_is_counter_proposal == TRUE`, aber `type != "counter proposal"`.
    -   3 Fälle enthalten sind, bei denen `inst_is_assembly == TRUE`, aber `type != "citizens' assembly"`.

    Sind das einfach Kodierungsfehler?

-   Woher genau stammt die Tag-Hierarchy? Ist sie "custom"?

    Falls ja, sollten wir

    -   den `tag_tier_3` "homosexuals" wohl etwas breiter fassen, bspw. "sexual orientation / gender identity".
    -   den `tag_tier_3` "compensation for loss of earnings for persons on military service or civil protection duty" kürzen!

-   `inst_object_legal_level` sollte m. E. in Relation zu `level` stehen, tut es aber nicht. Dementsprechend kann `inst_object_legal_level` mehrdeutig sein
    (Beispiel: Ist `inst_object_legal_level = "law"` lokales, kantonales oder nationales Recht bei Referendum auf CH-Gemeindeebene?)

    Wir sollten das daher ändern (sprich auf *eindeutige* Weise erfassen. Vorschläge?

    Würde dieses Problem behoben, könnte `inst_object_legal_level` vermutlich auch als `ordinal_ascending` klassifiziert werden.

-   Ist `position_government` (ehemals `recommendation`) immer die Empfehlung der Regierung? Oder immer des Parlamentes? Oder manchmal dies, manchmal jenes?

    Zudem: Die Variable kennt gegenwärtig eig. 3 Ausprägungen, ich behandle den Wert `"None"` allerdings als `NA`, weil das gegenwärtige
    [Admin-Portal](https://admin.c2d.ch/) keine `NA`s zulässt, sprich die Coder bei Unbekanntheit des Wertes gezwungen sind, `"None"` anzugeben. Wie siehst du
    das?

-   Völkerrechtlich umstrittene Gebiete: Es gibt bislang keine explizite C2D-Policy dazu, wir müssten daher etwas definieren.

    Bspw. werden

    -   alle Abstimmungen, die die [Republik Kosovo](https://de.wikipedia.org/wiki/Kosovo) betreffen, unter dem `country_name` *Serbia* geführt...
    -   für die Abstimmungen in Taiwan uneinheitliche `country_name`'s verwendet, für die Abstimmungen am 2018-11-24 *Taiwan, Province of China*, für die
        anderen einfach *Taiwan*...

    Pragmatisch wäre, einfach die Handhabung der offiziellen/diplomatischen Schweiz zu übernehmen. Wie siehst du das?

-   Zufällig irgendeine Idee, was `id_official = "0"` (ehemals `number`) zu bedeuten hat?

-   Currently, `inst_trigger_threshold` is a free text field which is really bad for analysis since no coding consistency at all is enforced. Instead, we should
    define, in what way the same information could be captured in a more systematic way (splitting it into two vars `inst_trigger_threshold_relative` and
    `inst_trigger_threshold_absolute` might make sense), introduce the new variable and then convert the old values to the new format.

    Was meint Irina?

#### Sonstige

-   Are `id_sudd`s stable over time? Maybe contact the creator [Beat Müller](mailto:beat@sudd.ch) and ask?

-   Bei der Abstimmung *Norfolk Island 1980-07-10* meint sudd.ch, sie habe stattdessen [1979-07-10
    stattgefunden](https://sudd.ch/event.php?lang=de&id=nf011979). Falls sudd.ch Recht hat, sollte das korrigiert werden.

-   Die Abstimmungen *Netherlands 2005-04-08* und *2014-12-17* fanden genau genommen auf [Sint Eustatius](https://de.wikipedia.org/wiki/Sint_Eustatius) statt,
    siehe sudd.ch-Einträge ([1](https://sudd.ch/event.php?id=an022005), [2](https://sudd.ch/event.php?id=bq012014)); Sint Eustatius ist zwar eine [Besondere
    Gemeinde der Niederlande](https://de.wikipedia.org/wiki/Karibische_Niederlande), besitzt aber einen eigenen ISO-Ländercode (BQ-SE) etc.

    Sollte daher als `country_name` nicht besser *Sint Eustatius* eingetragen werden? Andernfalls sollte `subnational_entity` auf `"Sint Eustatius"` gesetzt
    werden, da ja nicht die gesamte Niederlande abstimmen konnte!

-   Die Abstimmungen *France 2006-02-23* und *2006-09-06* beziehen sich auf Referenden in [Sark](https://de.wikipedia.org/wiki/Sark), `country_name` sollte
    daher auf `"United Kingdom"` oder (besser?) [`"Guernsey"`](https://de.wikipedia.org/wiki/Sark#Gesetzgebung_und_Autonomie) gesetzt werden und
    `subnational_entity = "Sark"`!

-   Genauer abklären, inwieweit man Angaben von Swissvotes integrieren oder linken könnte. Evtl. Techniker hinter Swissvotes kontaktieren, um herauszufinden,
    mit welchen Weiterentwicklungen zu rechnen ist (Stichwort: API!); ein Blick in den Quellcode des [swissdd](https://politanch.github.io/swissdd/)-R-Pakets
    könnte womöglich ganz aufschlussreich sein!

-   C2D Website: Ditch the `by ccm.design` promo in the footer?
