# define legal instruments data
data_legal_instruments <-
  tibble::tibble(administrative_unit_id = character(),
                 hierarchy_level = character(),
                 language_code = character(),
                 title = character(),
                 abbreviation = character()) |>
  tibble::add_row(administrative_unit_id = "CH",
                  hierarchy_level = "constitution",
                  language_code = "de",
                  title = "Bundesverfassung der Schweizerischen Eidgenossenschaft",
                  abbreviation = "BV") |>
  tibble::add_row(administrative_unit_id = "LI",
                  hierarchy_level = "constitution",
                  language_code = "de",
                  title = "Verfassung des Fürstentums Liechtenstein",
                  abbreviation = "LV") |>
  tibble::add_row(administrative_unit_id = "PL",
                  hierarchy_level = "law",
                  language_code = "pl",
                  title = "Ustawa z dnia 6 maja 1987 r. o konsultacjach społecznych i referendum",
                  abbreviation = "U-KSR") |>
  tibble::add_row(administrative_unit_id = "IE",
                  hierarchy_level = "constitution",
                  language_code = "en",
                  title = "Constitution of Ireland",
                  abbreviation = "CI")

# define legal norms data
data_legal_norms <-
  tibble::tibble(id = integer(),
                 legal_instrument_display = character(),
                 clause = character(),
                 text = character(),
                 url = character(),
                 valid_from = vctrs::new_date(),
                 valid_to = vctrs::new_date()) |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 138",
                  text = "100 000 Stimmberechtigte können innert 18 Monaten seit der amtlichen Veröffentlichung ihrer Initiative eine Totalrevision der Bundesverfassung vorschlagen.\n\nDieses Begehren ist dem Volk zur Abstimmung zu unterbreiten.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_138") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 139 par. 1–3",
                  text = "100 000 Stimmberechtigte können innert 18 Monaten seit der amtlichen Veröffentlichung ihrer Initiative eine Teilrevision der Bundesverfassung verlangen.\n\nDie Volksinitiative auf Teilrevision der Bundesverfassung kann die Form der allgemeinen Anregung oder des ausgearbeiteten Entwurfs haben.\n\nVerletzt die Initiative die Einheit der Form, die Einheit der Materie oder zwingende Bestimmungen des Völkerrechts, so erklärt die Bundesversammlung sie für ganz oder teilweise ungültig.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_139") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 139 par. 4",
                  text = "Ist die Bundesversammlung mit einer Initiative in der Form der allgemeinen Anregung einverstanden, so arbeitet sie die Teilrevision im Sinn der Initiative aus und unterbreitet sie Volk und Ständen zur Abstimmung. Lehnt sie die Initiative ab, so unterbreitet sie diese dem Volk zur Abstimmung; das Volk entscheidet, ob der Initiative Folge zu geben ist. Stimmt es zu, so arbeitet die Bundesversammlung eine entsprechende Vorlage aus.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_139") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 139 par. 5",
                  text = "Eine Initiative in der Form des ausgearbeiteten Entwurfs wird Volk und Ständen zur Abstimmung unterbreitet. Die Bundesversammlung empfiehlt die Initiative zur Annahme oder zur Ablehnung. Sie kann der Initiative einen Gegenentwurf gegenüberstellen.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_139") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 139b",
                  text = "Die Stimmberechtigten stimmen gleichzeitig über die Initiative und den Gegenentwurf ab.\n\nSie können beiden Vorlagen zustimmen. In der Stichfrage können sie angeben, welcher Vorlage sie den Vorrang geben, falls beide angenommen werden.\n\nErzielt bei angenommenen Verfassungsänderungen in der Stichfrage die eine Vorlage mehr Volks- und die andere mehr Standesstimmen, so tritt die Vorlage in Kraft, bei welcher der prozentuale Anteil der Volksstimmen und der prozentuale Anteil der Standesstimmen in der Stichfrage die grössere Summe ergeben.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_139_b") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 140 par. 1a",
                  text = "Volk und Ständen werden zur Abstimmung unterbreitet: die Änderungen der Bundesverfassung;",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_140") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 140 par. 1b",
                  text = "Volk und Ständen werden zur Abstimmung unterbreitet: der Beitritt zu Organisationen für kollektive Sicherheit oder zu supranationalen Gemeinschaften;",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_140") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 140 par. 1c",
                  text = "Volk und Ständen werden zur Abstimmung unterbreitet: die dringlich erklärten Bundesgesetze, die keine Verfassungsgrundlage haben und deren Geltungsdauer ein Jahr übersteigt; diese Bundesgesetze müssen innerhalb eines Jahres nach Annahme durch die Bundesversammlung zur Abstimmung unterbreitet werden.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_140") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 140 par. 2a",
                  text = "Dem Volk werden zur Abstimmung unterbreitet: die Volksinitiativen auf Totalrevision der Bundesverfassung;",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_140") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 140 par. 2b",
                  text = "Dem Volk werden zur Abstimmung unterbreitet: die Volksinitiativen auf Teilrevision der Bundesverfassung in der Form der allgemeinen Anregung, die von der Bundesversammlung abgelehnt worden sind;",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_140") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 140 par. 2c",
                  text = "Dem Volk werden zur Abstimmung unterbreitet: die Frage, ob eine Totalrevision der Bundesverfassung durchzuführen ist, bei Uneinigkeit der beiden Räte.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_140") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 141 par. 1a",
                  text = "Verlangen es 50 000 Stimmberechtigte oder acht Kantone innerhalb von 100 Tagen seit der amtlichen Veröffentlichung des Erlasses, so werden dem Volk zur Abstimmung vorgelegt: Bundesgesetze",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_141") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 141 par. 1b",
                  text = "Verlangen es 50 000 Stimmberechtigte oder acht Kantone innerhalb von 100 Tagen seit der amtlichen Veröffentlichung des Erlasses, so werden dem Volk zur Abstimmung vorgelegt: dringlich erklärte Bundesgesetze, deren Geltungsdauer ein Jahr übersteigt;",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_141") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 141 par. 1c",
                  text = "Verlangen es 50 000 Stimmberechtigte oder acht Kantone innerhalb von 100 Tagen seit der amtlichen Veröffentlichung des Erlasses, so werden dem Volk zur Abstimmung vorgelegt: Bundesbeschlüsse, soweit Verfassung oder Gesetz dies vorsehen;",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_141") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 141 par. 1d no. 1",
                  text = "Verlangen es 50 000 Stimmberechtigte oder acht Kantone innerhalb von 100 Tagen seit der amtlichen Veröffentlichung des Erlasses, so werden dem Volk zur Abstimmung vorgelegt: völkerrechtliche Verträge, die: unbefristet und unkündbar sind,",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_141") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 141 par. 1d no. 2",
                  text = "Verlangen es 50 000 Stimmberechtigte oder acht Kantone innerhalb von 100 Tagen seit der amtlichen Veröffentlichung des Erlasses, so werden dem Volk zur Abstimmung vorgelegt: völkerrechtliche Verträge, die: den Beitritt zu einer internationalen Organisation vorsehen,",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_141") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 141 par. 1d no. 3",
                  text = "Verlangen es 50 000 Stimmberechtigte oder acht Kantone innerhalb von 100 Tagen seit der amtlichen Veröffentlichung des Erlasses, so werden dem Volk zur Abstimmung vorgelegt: völkerrechtliche Verträge, die: wichtige rechtsetzende Bestimmungen enthalten oder deren Umsetzung den Erlass von Bundesgesetzen erfordert.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_141") |>
  tibble::add_row(legal_instrument_display = "CH: BV",
                  clause = "art. 142",
                  text = "Die Vorlagen, die dem Volk zur Abstimmung unterbreitet werden, sind angenommen, wenn die Mehrheit der Stimmenden sich dafür ausspricht.\n\nDie Vorlagen, die Volk und Ständen zur Abstimmung unterbreitet werden, sind angenommen, wenn die Mehrheit der Stimmenden und die Mehrheit der Stände sich dafür aussprechen.\n\nDas Ergebnis der Volksabstimmung im Kanton gilt als dessen Standesstimme.\n\nDie Kantone Obwalden, Nidwalden, Basel-Stadt, Basel-Landschaft, Appenzell Ausserrhoden und Appenzell Innerrhoden haben je eine halbe Standesstimme.",
                  url = "https://www.fedlex.admin.ch/eli/cc/1999/404/de#art_142") |>
  tibble::add_row(legal_instrument_display = "LI: LV",
                  clause = "art. 64 par. 4",
                  text = "Ein die Verfassung betreffendes Initiativbegehren kann nur von wenigstens 600 wahlberechtigten Landesbürgern oder wenigstens vier Gemeinden gestellt werden.",
                  url = "https://www.gesetze.li/konso/1921.015",
                  valid_from = clock::date_parse("1921-10-24"),
                  valid_to = clock::date_parse("1947-12-29")) |>
  tibble::add_row(legal_instrument_display = "LI: LV",
                  clause = "art. 64 par. 4",
                  text = "Ein die Verfassung betreffendes Initiativbegehren kann nur von wenigstens 900 wahlberechtigten Landesbürgern oder wenigstens vier Gemeinden gestellt werden.",
                  url = "https://www.gesetze.li/konso/1921.015",
                  valid_from = clock::date_parse("1947-12-30"),
                  valid_to = clock::date_parse("1984-08-23")) |>
  tibble::add_row(legal_instrument_display = "LI: LV",
                  clause = "art. 64 par. 4",
                  text = "Ein die Verfassung betreffendes Initiativbegehren kann nur von wenigstens 1500 wahlberechtigten Landesbürgern oder wenigstens vier Gemeinden gestellt werden.",
                  url = "https://www.gesetze.li/konso/1921.015",
                  valid_from = clock::date_parse("1984-08-24")) |>
  tibble::add_row(legal_instrument_display = "PL: U-KSR",
                  clause = "art. 19 par. 1",
                  text = "Wynik referendum jest rozstrzygający, jeżeli za jednym y rozwiązań w sprawie poddanej pod głosowanie opowiedziała się więcej niż połowa uprawnionych do wzięcia udziału w referendum.",
                  url = "https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU19870140083",
                  valid_from = clock::date_parse("1987-05-06")) |>
  tibble::add_row(legal_instrument_display = "IE: CI",
                  clause = "art. 47 par. 1",
                  text = "Every proposal for an amendment of this Constitution which is submitted by Referendum to the decision of the people shall, for the purpose of Article 46 of this Constitution, be held to have been approved by the people, if, upon having been so submitted, a majority of the votes cast at such Referendum shall have been cast in favour of its enactment into law.",
                  url = "https://www.irishstatutebook.ie/eli/cons/en/html#part16",
                  valid_from = clock::date_parse("1937-12-29")) |>
  dplyr::mutate(valid_from = dplyr::if_else(is.na(valid_from),
                                            clock::date_parse("0101-01-01"),
                                            valid_from))
# define referendum types data
data_rfrnd_types <-
  tibble::tibble(id = integer(),
                 is_draft = logical(),
                 administrative_unit_id = character(),
                 title = character(),
                 valid_from = vctrs::new_date(),
                 valid_to = vctrs::new_date(),
                 trigger_actor_label = character(),
                 trigger_threshold_count = integer(),
                 are_empty_votes_counted = logical(),
                 quorum_turnout = numeric()) |>
  tibble::add_row(title = "citizen's initiative for a total revision of the constitution") |>
  tibble::add_row(title = "citizen's initiative with a formulated proposal for a partial revision of the constitution") |>
  tibble::add_row(title = "citizen's initiative with a general proposal for a partial revision of the constitution") |>
  tibble::add_row(title = "total revision of the constitution in case of disagreement between the houses of parliament") |>
  tibble::add_row(title = "partial or total revision of the constitution by the parliament") |>
  tibble::add_row(title = "accession to collective security organizations or supranational bodies") |>
  tibble::add_row(title = "federal laws that are declared urgent, have no constitutional basis, and are valid for more than one year") |>
  tibble::add_row(title = "federal laws (that are not declared urgent and valid for less than one year)",
                  trigger_actor_label = "citizens") |>
  tibble::add_row(title = "federal laws that are declared urgent and are valid for more than one year",
                  trigger_actor_label = "citizens") |>
  tibble::add_row(title = "federal decisions where the constitution or the law requires a referendum vote",
                  trigger_actor_label = "citizens") |>
  tibble::add_row(title = "international treaties that are unlimited in time and cannot be terminated",
                  trigger_actor_label = "citizens") |>
  tibble::add_row(title = "international treaties for accession to international organizations",
                  trigger_actor_label = "citizens") |>
  tibble::add_row(title = "international treaties that contain important legislative provisions or whose implementation requires the enactment of federal laws",
                  trigger_actor_label = "citizens")

data_rfrnd_types$is_draft <- TRUE
data_rfrnd_types$administrative_unit_id <- "CH"
data_rfrnd_types$are_empty_votes_counted <- FALSE
data_rfrnd_types$quorum_turnout <- 0.0

data_rfrnd_types %<>%
  tibble::add_row(is_draft = TRUE,
                  administrative_unit_id = "LI",
                  title = "constitutional initiative",
                  valid_from = clock::date_parse("1921-10-24"),
                  valid_to = clock::date_parse("1947-12-29"),
                  trigger_actor_label = "citizens",
                  trigger_threshold_count = 600L,
                  are_empty_votes_counted = FALSE,
                  quorum_turnout = 0.0) %>%
  tibble::add_row(is_draft = TRUE,
                  administrative_unit_id = "LI",
                  title = "constitutional initiative",
                  valid_from = clock::date_parse("1947-12-30"),
                  valid_to = clock::date_parse("1984-08-23"),
                  trigger_actor_label = "citizens",
                  trigger_threshold_count = 900L,
                  are_empty_votes_counted = FALSE,
                  quorum_turnout = 0.0) %>%
  tibble::add_row(is_draft = TRUE,
                  administrative_unit_id = "LI",
                  title = "constitutional initiative",
                  valid_from = clock::date_parse("1984-08-24"),
                  trigger_actor_label = "citizens",
                  trigger_threshold_count = 1500L,
                  are_empty_votes_counted = FALSE,
                  quorum_turnout = 0.0) %>%
  tibble::add_row(is_draft = TRUE,
                  administrative_unit_id = "PL",
                  title = "governmental referendum",
                  are_empty_votes_counted = FALSE,
                  quorum_turnout = 0.5) %>%
  tibble::add_row(is_draft = TRUE,
                  administrative_unit_id = "IE",
                  title = "mandatory referendum",
                  are_empty_votes_counted = FALSE,
                  quorum_turnout = 0.0) %>%
  dplyr::mutate(valid_from = dplyr::if_else(is.na(valid_from),
                                            clock::date_parse("0101-01-01"),
                                            valid_from))
connection <- rdb::connect()

# write data to DB
rdb::update_tbl(data = data_legal_instruments,
                tbl_name = "legal_instruments",
                sweep = TRUE,
                connection = connection,
                disconnect = FALSE)

rdb::update_tbl(data = data_legal_norms,
                tbl_name = "legal_norms",
                sweep = TRUE,
                connection = connection,
                disconnect = FALSE)

rdb::update_tbl(data = data_rfrnd_types,
                tbl_name = "referendum_types",
                sweep = TRUE,
                connection = connection,
                disconnect = FALSE)

# retrieve newly written data
data_legal_norms <- rdb::read_tbl("legal_norms",
                                  connection = connection,
                                  disconnect = FALSE)
data_rfrnd_types <- rdb::read_tbl("referendum_types",
                                  connection = connection,
                                  disconnect = FALSE)
# define junction tbl data
# NOTE: for the IDs below it's assumed the data above was written exactly in the order as defined and the tbls were empty before
data_rfrnd_types_legal_norms <-
  tibble::tibble(referendum_type_id = integer(),
                 legal_norm_id = integer()) |>
  # CH
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative for a total revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative for a total revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 138") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative for a total revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 140 par. 2a") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a formulated proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a formulated proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 139b") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a formulated proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 139 par. 1–3") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a formulated proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 139 par. 5") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a formulated proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 140 par. 1a") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a general proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a general proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 139 par. 1–3") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a general proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 139 par. 4") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "citizen's initiative with a general proposal for a partial revision of the constitution") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 140 par. 2b") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "total revision of the constitution in case of disagreement between the houses of parliament") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "total revision of the constitution in case of disagreement between the houses of parliament") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 140 par. 2c") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "partial or total revision of the constitution by the parliament") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "partial or total revision of the constitution by the parliament") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 140 par. 1a") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "accession to collective security organizations or supranational bodies") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "accession to collective security organizations or supranational bodies") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 140 par. 1b") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal laws that are declared urgent, have no constitutional basis, and are valid for more than one year") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal laws that are declared urgent, have no constitutional basis, and are valid for more than one year") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 140 par. 1c") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal laws (that are not declared urgent and valid for less than one year)") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal laws (that are not declared urgent and valid for less than one year)") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 141 par. 1a") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal laws that are declared urgent and are valid for more than one year") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal laws that are declared urgent and are valid for more than one year") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 141 par. 1b") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal decisions where the constitution or the law requires a referendum vote") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "federal decisions where the constitution or the law requires a referendum vote") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 141 par. 1c") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "international treaties that are unlimited in time and cannot be terminated") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "international treaties that are unlimited in time and cannot be terminated") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 141 par. 1d no. 1") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "international treaties for accession to international organizations") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "international treaties for accession to international organizations") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 141 par. 1d no. 2") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "international treaties that contain important legislative provisions or whose implementation requires the enactment of federal laws") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 142") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "CH" & title == "international treaties that contain important legislative provisions or whose implementation requires the enactment of federal laws") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "CH: BV" & clause == "art. 141 par. 1d no. 3") |>
                    _$id) |>
  # IE
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "IE" & title == "mandatory referendum") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "IE: CI" & clause == "art. 47 par. 1") |>
                    _$id) |>
  # LI
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "LI" & title == "constitutional initiative" & valid_from == "1921-10-24") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "LI: LV" & clause == "art. 64 par. 4" & valid_from == "1921-10-24") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "LI" & title == "constitutional initiative" & valid_from == "1947-12-30") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "LI: LV" & clause == "art. 64 par. 4" & valid_from == "1947-12-30") |>
                    _$id) |>
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "LI" & title == "constitutional initiative" & valid_from == "1984-08-24") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "LI: LV" & clause == "art. 64 par. 4" & valid_from == "1984-08-24") |>
                    _$id) |>
  # PL
  tibble::add_row(referendum_type_id =
                    data_rfrnd_types |>
                    dplyr::filter(administrative_unit_id == "PL" & title == "governmental referendum") |>
                    _$id,
                  legal_norm_id =
                    data_legal_norms |>
                    dplyr::filter(legal_instrument_display == "PL: U-KSR" & clause == "art. 19 par. 1") |>
                    _$id)

dplyr::rows_insert(x = dplyr::tbl(src = connection,
                                  from = dbplyr::in_schema(schema = rdb:::pg_schema,
                                                           table = "referendum_types_legal_norms")),
                   y = data_rfrnd_types_legal_norms,
                   by = c("referendum_type_id", "legal_norm_id"),
                   conflict = "ignore",
                   copy = TRUE,
                   in_place = TRUE)

DBI::dbDisconnect(conn = connection)
