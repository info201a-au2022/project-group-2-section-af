# This following code was used to slim down the original data files to the 
# filtered datasets that are stored in the data folder

library(tidyverse)
library(dplyr)

# load data
compiled <- read_csv("../../bigdata/US_Fires_Compiled.csv")

# create df that has the year of fire, overall total fires for that year, and number of fires per 
# fire size class for that year 
tot_fires_per_yr <- compiled %>% select(fire_year) %>% group_by(fire_year) %>% summarise(num_fires = n()) %>%
  mutate(fire_size_class = "overall")
num_fires_by_class_per_year <- compiled %>% select(fire_year, fire_size_class) %>% group_by(fire_year, fire_size_class) %>%
  summarise(num_fires = n())
fire_freq_per_yr <- bind_rows(tot_fires_per_yr, num_fires_by_class_per_year)
write.csv(fire_freq_per_yr,"../data/US_Fire_Freq_Per_Year.csv", row.names = FALSE)


# create df that has year with state and number of fires for that year in that state.

map_state_fires <- compiled %>% select(state, fire_year) %>%
  group_by(state, fire_year) %>%
  mutate(total_fires = sum(state == state)) %>%
  distinct()
map_state_fires$stat_cause_descr <- "All"

map_state_fires_causes <- compiled %>% select(state, fire_year, stat_cause_descr) %>%
  group_by(state, fire_year, stat_cause_descr) %>%
  mutate(total_fires = sum(state == state)) %>%
  distinct()

map_state_fires_n_causes <- bind_rows(map_state_fires, map_state_fires_causes)

write.csv(map_state_fires_n_causes,"../data/US_State_Fire_Year_New.csv", row.names = FALSE)


# create df that has statistical causes and number of fires caused

common_causes <- compiled %>% 
  select(fire_year, stat_cause_descr) %>%
  group_by(fire_year) %>% 
  count(stat_cause_descr)

common_causes <- rename(common_causes, num_fires_caused = n,
                        statistical_cause = stat_cause_descr)

write.csv(common_causes, "../data/US_Fire_Causes.csv", row.names = FALSE)