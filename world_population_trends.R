geo_data <- read_delim("countries_codes_and_coordinates 3.csv", delim = ";", col_types = cols())
map_data  <- merge(europe_df, geo_data, by = "country_code", all.x = TRUE)
View(map_data)
# add numeric value to income classes
unique_groups <- unique(map_data$income_group.y)
unique_groups
mapping <- c("Lower middle income" = 1, "Upper middle income"= 2, "High income" = 3)
map_data$value <- mapping[map_data$income_group.y]
mybins <- seq(0, 4, by=1)
mypalette <- colorBin(palette = "YlOrBr", domain=map_data$value, na.color="transparent", bins=mybins)

mytext <- paste(
  "Country: ", map_data$table_name, "<br/>", 
  "Population: ", map_data$"2020", "<br/>", 
  "Income Group: ", map_data$income_group.y, sep=""
) %>%
  lapply(htmltools::HTML)
# Define a scaling factor for adjusting bubble size
scaling_factor <- 0.001  # Experiment with different values


# Final Map
m <- leaflet(map_data) %>% 
  addTiles()  %>% 
  setView( lat = 53, lng = 9, zoom = 3) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addCircleMarkers(~longitude, ~latitude, 
                   fillColor = ~mypalette(value), fillOpacity = 0.7, color="transparent", radius = ~scaling_factor * sqrt(`2020`),  # Adjust the size based on the square root of the population, stroke=FALSE,
                   label = mytext,
                   labelOptions = labelOptions( style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px", direction = "auto")
  ) %>%
  addLegend( pal = mypalette, values = ~value, opacity = 0.9, labels = ~income_group.y, position = "bottomright" )

m #this code kind of works

m1 <- leaflet(map_data) %>% 
  addTiles()  %>% 
  setView(lat = 53, lng = 9, zoom = 3) %>%
  addProviderTiles("USGS_USImageryTopo")%>%
  addCircleMarkers(~longitude, ~latitude)
m1

head(map_data)



# Define a minimum radius for the bubbles
min_radius <- 5

# Final Map
m <- leaflet(map_data) %>% 
  addTiles()  %>% 
  setView( lat = 53, lng = 9, zoom = 3) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addCircleMarkers(~longitude, ~latitude, 
                   fillColor = ~mypalette(value), fillOpacity = 0.7, color="transparent",
                   radius = ~ifelse(scaling_factor * sqrt(`2020`) < min_radius, min_radius, scaling_factor * sqrt(`2020`)),
                   label = mytext,
                   labelOptions = labelOptions( style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px", direction = "auto")
  ) %>%
  addLegend( pal = mypalette, values = ~value, opacity = 0.9, labels = ~income_group, position = "bottomright" )

m




#adding averages to the table 
europe_population <- rename(europe_population, "2010s" = "2010")
View(europe_population)
europe_population_2 <- select(europe_population, -c("1960", "1970", "1980", "1990", "2000"))
View(europe_population_2)
map_data <- merge(map_data, europe_population_2, by = "table_name")

#map version with averages
# Define the income groups and corresponding colors
value <- c("1", "2", "3")
colors <- c("#fee08b", "#d73027", "#4575b4")

mypalette <- colorFactor(palette = colors, domain = value)


mytext <- paste(
  "Country: ", map_data$table_name, "<br/>", 
  "Population: ", map_data$"2020", "<br/>", 
  "Income Group: ", map_data$income_group.y, "<br/>",
  "Avg Population in 2010s:", map_data$"2010s"
) %>%
  lapply(htmltools::HTML)
# Define a scaling factor for adjusting bubble size
scaling_factor <- 0.001  # Experiment with different values
# Define a minimum radius for the bubbles
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
            values = ~value, title = "Income Group", labels = ~map_data$income_group.y, position = "bottomleft" )

m

value <- c("1", "2", "3")
colors <- c("#fee08b", "#d73027", "#4575b4")
mypalette <- colorFactor(palette = colors, domain = value)


mytext <- paste(
  "Country: ", map_data$table_name, "<br/>", 
  "Population: ", map_data$"2020", "<br/>", 
  "Income Group: ", map_data$income_group.y, "<br/>",
  "Avg Population in 2010s:", map_data$"2010s"
) %>%
  lapply(htmltools::HTML)
# Define a scaling factor for adjusting bubble size
scaling_factor <- 0.001  # Experiment with different values
# Define a minimum radius for the bubbles
min_radius <- 5


m <- leaflet(map_data) %>% 
  addTiles()  %>% 
  setView( lat = 53, lng = 9, zoom = 2.5) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addCircleMarkers(lng = ~longitude, lat = ~latitude, color = ~ palette(value), fillOpacity = 0.7, color="transparent",
                   radius = ~ifelse(scaling_factor * sqrt(`2020`) < min_radius, min_radius, scaling_factor * sqrt(`2020`)),
                   label = mytext,
                   labelOptions = labelOptions( style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px", direction = "auto")
  ) %>%
  addLegend(pal = mypalette,
            values = ~income_group.y, title = "Income Group", labels = ~income_group.y, position = "bottomleft" )

m