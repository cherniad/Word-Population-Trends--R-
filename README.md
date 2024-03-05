# Word Population Trends (R)

__Introduction__ 

 The purpose of this project is, to explore the population dynamics in European and Asian Countries and display the results on the interactive map.
 
__Libraries used:__
- tidyverse
- lubridate
- ggplot2
- dplyr

__Steps:__

1. Load and merge population_yearly_stats.csv and income_info.csv in one dataframe

2. Process the data:
     a) drop the columns not needed for the model
     b) rename the columns
     c) check NaN values and drop the rows if not needed for the analysis 

3. Group the columns by decades and calculate the average by each decade 

4. Load countries_codes_and_coordinates 3.csv to use for the interactive map

5. Create the interactive map:
           a) the size of bins is determined by the population of the country
           b) the colour of bins corresponds to the income group
           c) cursor analysis show the information about country name, population, income group and average population in the last decade

  _Preview:_

  
![1](https://github.com/cherniad/Word-Population-Trends--R-/assets/129260187/ab2766b7-16ce-4609-921b-f104cc87967f)

  _Link:_

  https://184a0d0831b143e7a56c07a792b087ba.app.posit.cloud/file_show?path=%2Ftmp%2FRtmphYqxP7%2Fviewer-rpubs-115229a6177.html



__Results and Learning Outcomes__ 

The code could be used for the market research, allocating resources and policy development, all of which require insights into the demographic developments to make informed decisions. In the future, it is possible to investigate how income group affects a country's population growth and explore the demographic trends in individual countries. 
 
 
