# Analysis of 311 Calls in San Francisco Proper
## Are San Franciscans Misusing the 311 Request Line in
## the name of Property Values? 

# Primarily focusing on the use of the 311 app to spam 
# SF Municipal departments with homelessness complaints
# in the name of maintaining/increasing property values

# Glabal Utilities/Design specs
color_scheme <- c("#09C2FF", "#004E68", "#09C2FF", "#004E68", "#ff0000",
  "#ff0000", "#09C2FF", "#004E68", "#09C2FF", "#004E68")

library(ggplot2)
library(dplyr)
library(scales)

casesData <- read.csv('../data/311_Cases.csv')

length(unique(casesData$Category))
# There are 102 unique categories of 311 requests

numTotalCases <- casesData %>%
  group_by(Category) %>%
  summarise(total = n())
numTotalCases <- numTotalCases[order(numTotalCases$total, decreasing = TRUE),]
cat_tbl <- table(numTotalCases$Category)
cat_levels <- names(cat_tbl)[order(cat_tbl)]
numTotalCases$Category2 <- factor(numTotalCases$Category, levels = numTotalCases$Category)
# Over the course of 10 years, homless concerns were the 5th most requests
# received by the 311 app

ggplot(head(numTotalCases, 10), aes(Category2, total)) + 
  geom_bar(stat = 'identity', fill = color_scheme) + 
  scale_y_continuous(labels = comma) +
  ggtitle('Total Count of 311 Requests (2008 - 2018)') + xlab('Category') +
  ylab('Total') + coord_flip()
# Together Homeless Concerns and Encampments are 3rd (293208)

casesData$year <- as.numeric(substring(casesData$Opened, 7, 10))
length(unique(casesData$year)) == 11 # Check

yearlyGrowth <- casesData %>%
  group_by(Category, year) %>%
  summarise(yearly_totals = n()) 

encampments <- yearlyGrowth[yearlyGrowth$Category == 'Encampments',]
homeless <- yearlyGrowth[yearlyGrowth$Category == 'Homeless Concerns',]
streetCleaning <- yearlyGrowth[yearlyGrowth$Category == 'Street and Sidewalk Cleaning',]

encampmentsGrowth <- c(NA,
  (encampments$yearly_totals[2:(nrow(encampments) - 1)] - 
    encampments$yearly_totals[1:(nrow(encampments) - 2)]) / 
      (encampments$yearly_totals[1:(nrow(encampments) - 2)]), NA)
homelessGrowth <- c(NA,
  (homeless$yearly_totals[2:(nrow(homeless) - 1)] - 
    homeless$yearly_totals[1:(nrow(homeless) - 2)]) / 
      (homeless$yearly_totals[1:(nrow(homeless) - 2)]), NA)
streetCleaningGrowth <- c(NA,
  (streetCleaning$yearly_totals[2:(nrow(streetCleaning) - 1)] - 
    streetCleaning$yearly_totals[1:(nrow(streetCleaning) - 2)]) / 
      (streetCleaning$yearly_totals[1:(nrow(streetCleaning) - 2)]), NA)

encampments$growth <- encampmentsGrowth
homeless$growth <- homelessGrowth
streetCleaning$growth <- streetCleaningGrowth

consolidatedGrowthTable <- rbind(encampments, homeless, streetCleaning)  

ggplot(consolidatedGrowthTable, aes(year, growth, fill = Category)) + 
  geom_bar(stat = 'identity', position = 'dodge') +
  xlab('Year') + ylab('Growth (YoY)') + 
  ggtitle('Year-Over-Year Growth in Homelessness-Related Complaints') + 
  scale_x_discrete(limits = seq(2009, 2017, by = 1))

# Homeless complaints per neighborhood
byNeighborhood <- casesData[casesData$Category == 'Homeless Concerns',] %>%
  group_by(Neighborhood) %>%
  summarise(total_by_neighborhood = n())
# Some neighborhoods are not provided (these are excluded from further analysis)

cat_tbl2 <- table(byNeighborhood$Neighborhood)
cat_levels2 <- names(cat_tbl2)[order(cat_tbl2)]
byNeighborhood$Neighborhood2 <- factor(byNeighborhood$Neighborhood, levels = byNeighborhood$Neighborhood)
byNeighborhood <- byNeighborhood[byNeighborhood$Neighborhood2 != '',]
byNeighborhood <- byNeighborhood[order(byNeighborhood$total_by_neighborhood, decreasing = TRUE),]

color_scheme2 <- c("#09C2FF", "#004E68", "#09C2FF", "#004E68", "#09C2FF",
  "#004E68", "#09C2FF", "#004E68", "#09C2FF", "#004E68")

ggplot(head(byNeighborhood, 10), aes(Neighborhood2, total_by_neighborhood)) + 
  geom_bar(stat = 'identity', fill = color_scheme2) + 
  scale_y_continuous(labels = comma) +
  ggtitle('Total Count of 311 Requests by Neighborhood (2008 - 2018)') + xlab('Neighborhood') +
  ylab('Total') + coord_flip()

byYear <- casesData %>%
  group_by(year) %>%
  summarise(total = n())
byYear$year <- as.integer(byYear$year)
byYear <- byYear[2:10,]

ggplot(byYear, aes(year, total)) +
  geom_line(color = '#09C2FF') + xlim(c(2009, 2017)) + 
  ggtitle('Total Number of Requests by Year') + 
  xlab('Year') + ylab('Total') +
  scale_y_continuous(labels = comma) + 
  scale_x_discrete(limits = seq(2009, 2017, by = 1))

byYear_homeless <- casesData[casesData$Category == 'Homeless Concerns',]
byYear_hmless <- byYear_homeless %>%
  group_by(year) %>%
  summarise(total = n())
byYear_hmless<- byYear_hmless[2:10,]
ggplot(byYear_hmless, aes(year, total)) +
  geom_line(color = '#004E68') + xlim(c(2009, 2017)) + 
  ggtitle('Total Number of Homeless Concerns by Year') + 
  xlab('Year') + ylab('Total') +
  scale_y_continuous(labels = comma) + 
  scale_x_discrete(limits = seq(2009, 2017, by = 1))
