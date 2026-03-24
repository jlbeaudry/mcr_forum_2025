# MID-CAREER RESEARCHER FORUM WITH DVC(R) (July 2025)
# PREPROCESSING DATA SCRIPT
# JEN BEAUDRY

#### LOAD LIBRARY ####

library(here)
library(tidyverse)

source(here("..", "functions", "read_qualtrics.R"))
source(here("..", "functions", "meta_rename.R"))


#### LOAD DATA ####

df <- here::here("data", "mcr_forum_raw_data.csv") %>%
  read_qualtrics(legacy = FALSE) %>%
  select(-c("start_date":"user_language")) %>%
  mutate(id = 1:n()) %>%
  relocate(id)


# load metadata

meta <- read_csv(here::here("data", "mcr_forum_metadata.csv"), lazy = FALSE) %>%
      filter(old_variable != "NA", old_variable != "exclude") # remove the instruction variables

# combine all item text labels into the short column

meta <- meta %>%
  mutate(item_text_short = ifelse(is.na(item_text_short), item_text, item_text_short))

##### RECODE VARIABLES #####

  # recode variable labels according to metadata

df <- meta_rename(df = df, metadata = meta, old = old_variable, new = new_variable)

#### MISSING DATA ####

df <- df %>%
  mutate(missing_data = rowSums(is.na(df)))

df <- df %>%
  filter(missing_data < 5)

#### WRITE DATA ####

# when done preprocessing, write the data to new files
# row.names gets rid of the first column from the dataframe.

write.csv(df, here::here("data", "ecr_forum_processed.csv"), row.names = FALSE)



