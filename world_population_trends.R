install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")
library(tidyverse)
library(lubridate)
library(ggplot2)

# Loading and inspecting the data
yearly_stats <- read_csv("population_yearly_stats.csv")
income <- read_csv("income_info.csv")
colnames(yearly_stats)
colnames(income)

# Merging them in one dataframe by country code
stats_df <- merge(yearly_stats, income, by = "Country Code", all.x = TRUE) 
glimpse(stats_df)
colnames(stats_df)

# Renaming columns to make them consistent
stats_df <- rename(stats_df, "country_code" = "Country Code", 
                   "indicator_name" = "Indicator Name",
                   "indicator_code" = "Indicator Code",
                   "region" = "Region",
                   "income_group" = "IncomeGroup",
                   "special_notes" = "SpecialNotes",
                   "table_name" = "TableName")

# Inspecting the dataframe and look for inconguencies
str(stats_df)

# There are some null values in region, income_group and special_notes
# We won't need special notes for this analysis, so dropping the column

stats_df = subset(stats_df, select = -c(special_notes))

# Inspecting the final table
colnames(stats_df)  # List of column names
nrow(stats_df)  # How many rows are in data frame?
dim(stats_df)  # Dimensions of the data frame?
head(stats_df)  # See the first 6 rows of data frame

# Inspecting the countries where region has a null value to determine whether we need those for the analysis or not
df_null_region <- stats_df[stats_df$region == "null" | stats_df$region == "", ]
view(df_null_region)

# All the codes that have null in region refer to the union and specific regions 
# but not to the countries, so we will drop those rows

stats_df2<-subset(stats_df, region!="null")
stats_df2
nrow(stats_df2) 

# Identifying unique values in the region column
region_table <- table(stats_df2$region)
region_table
# We're going to use only countries from Europe & Central Asia,
# so creating a new table 
europe_df <- stats_df2[stats_df2$region == "Europe & Central Asia",]
europe_df
# Info about the table
colnames(europe_df)  
nrow(europe_df)  
dim(europe_df)  
head(europe_df)
str(europe_df)

# There are no null values

duplicated(europe_df) #Checking if there are any duplicates

# Calculating the average population for every decade for each country 

# Dropping region, indicator_name and indicator_code columns
europe_df <- subset(europe_df, select = -c(region, indicator_name, indicator_code))
view(europe_df)
# Changing index of table_name and income_group
europe_df2 <- europe_df[, c(1, 64, 63, 2:62)]
view(europe_df2)

# I want to use only decades, so dropping the column 2020 by index
which(colnames(europe_df2) == "2020") 
europe_df3<- europe_df2[,-63]
view(europe_df3)

# Group columns by decades
library(dplyr)
europe_df_decades <- europe_df3 %>%
  gather(year, value, -country_code, -table_name, -income_group) %>%
  mutate(decade = as.integer(substring(as.character(year), 1, 3)) * 10) %>%
  group_by(country_code, table_name, decade) %>%
  summarize(mean_value = mean(as.numeric(value), na.rm = TRUE)) 
# Creating a new table with country code, table name, averages by decades, and income group
result_table <- europe_df_decades %>%
  pivot_wider(names_from = decade, values_from = mean_value) %>%
  left_join(select(europe_df3, country_code, table_name, income_group), by = c("country_code", "table_name"))

df_averages_by_decades <- result_table%>%
  mutate(across(starts_with(c("1", "2")), ~ format(round(., 0), big.mark = ",", scientific = FALSE)))
view(df_averages_by_decades) 

# Adding -s after each decade (e.g. 2010s)

df_averages_by_decades <- df_averages_by_decades %>%
rename_with(~ paste0(.x, "s"), -c(country_code, table_name, income_group))

# Creating the interactive map 
geo_data <- read_delim("countries_codes_and_coordinates 3.csv", delim = ";", col_types = cols())                                                                            
map_data  <- merge(europe_df3, geo_data, by = "country_code", all.x = TRUE)
map_data <- rename(map_data, "latitude" = "Latitude (average)", 
                   "longitude" = "Longitude (average)")
map_data <- merge(map_data, df_averages_by_decades, by = "table_name")
View(map_data)

# Defining the income groups and corresponding colors
value <- c("1", "2", "3")
colors <- c("#fee08b", "#d73027", "#4575b4")
# Mapping numeric values to income group names
income_group_names <- c("1" = "Lower Middle Income", "2" = "Upper Middle Income", "3" = "High Income")
mypalette <- colorFactor(palette = colors, domain = value)

mytext <- paste(
  "Country: ", map_data$table_name, "<br/>", 
  "Population: ", map_data$"2020", "<br/>", 
  "Income Group: ", map_data$income_group.y, "<br/>",
  "Avg Population in 2010s:", map_data$"2010s"
) %>%
  lapply(htmltools::HTML)
# Defining a scaling factor for adjusting bubble size
scaling_factor <- 0.001  # Experiment with different values
# Defining a minimum radius for the bubbles
min_radius <- 5

# Final Map
m <- leaflet(map_data) %>% 
  addTiles()  %>% 
  setView( lat = 53, lng = 9, zoom = 2.5) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addCircleMarkers(~longitude, ~latitude, 
                   fillColor = ~mypalette(value), fillOpacity = 0.7, color="transparent",
                   radius = ~ifelse(scaling_factor * sqrt(`2020`) < min_radius, min_radius, scaling_factor * sqrt(`2020`)),
                   label = mytext,
                   labelOptions = labelOptions( style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px", direction = "auto")
  ) %>%
  addLegend(pal = mypalette,
            values = value, title = "Income Group", labels = income_group_names, position = "bottomleft" )

m
  