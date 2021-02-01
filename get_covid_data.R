swiss_data <- httr::GET("https://covid19-rest.herokuapp.com/api/openzh/v1/country/CH") %>%
  httr::content(as = "parsed") %>% 
  pluck("records") %>% 
  map_dfr(magrittr::extract, c("date", 
                               "abbreviation_canton_and_fl",
                               "ncumul_tested_fwd",
                               "ncumul_conf_fwd",
                               "ncumul_hosp_fwd",
                               "ncumul_deceased_fwd"
  )) %>% 
  mutate(date = lubridate::ymd(date))

# load population

pop <- readxl::read_excel("data/Population_Size_BFS.xlsx") %>% 
  group_by(ktn) %>% 
  summarise(population = sum(pop_size))


# calculate incidence

latest_swiss_data <- swiss_data %>% 
  left_join(pop,  c("abbreviation_canton_and_fl" = "ktn")) %>% 
  mutate(incidence = (ncumul_conf_fwd/population)*100000) %>% 
  filter(date == max(date))

write_csv(latest_swiss_data, "data/latest_swiss_data.csv")