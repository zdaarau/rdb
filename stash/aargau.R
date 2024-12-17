data_rdb_aargau <-
  readxl::read_excel("19-AG-Abstimmungen-1888-1971.xlsx") %>%
  dplyr::mutate(date = clock::date_parse(x = Datum,
                                         format = "%d.%m.%Y"),
                title_en = deeplr::translate2(text = Vorlage,
                                              auth_key = Sys.getenv("DEEPL_TOKEN"),
                                              target_lang = "EN",
                                              source_lang = "DE",
                                              preserve_formatting = TRUE)) %>%
  dplyr::select(date,
                title_de = Vorlage,
                title_en,
                electorate_total = Stimmberechtigte,
                votes_total = "Eingegangene Stimmzettel",
                votes_yes = "Anzahl JA-Stimmen",
                votes_no = "Anzahl NEIN-Stimmen",
                votes_empty = Leer)
