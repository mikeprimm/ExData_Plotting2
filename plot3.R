# Get libraries
library(ggplot2)
# Make directory for work data
dir.create("./data", showWarnings=FALSE)
# URL for data source
URL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
# If data set not downloaded already, fetch it
if (!file.exists("./data/exdata-data-NEI_data.zip")) {
  download.file(URL, destfile = "./data/exdata-data-NEI_data.zip", method="curl")
}
# If data set not extracted already, extract it
if (!file.exists("./data/summarySCC_PM25.rds")) {
  unzip("./data/exdata-data-NEI_data.zip", exdir="./data")
}
# Read NEI summary data
NEI <- readRDS("./data/summarySCC_PM25.rds")
# Read Source Classification Code data
SCC <- readRDS("./data/Source_Classification_Code.rds")

# Reduce to just Baltimore City
baltimoreCityNEI <- NEI[NEI$fips == "24510",]
# Aggregate by year and type
totByYearAndType <- aggregate(baltimoreCityNEI$Emissions, by=list(year=baltimoreCityNEI$year, type=baltimoreCityNEI$type), sum)

# And do simple plot of values to show trend
png(filename='plot3.png', width=480, height=480)
# Create plot
gp <- ggplot(totByYearAndType, aes(factor(year), x, fill=year)) + facet_grid(. ~ type)
# Add labels
gp <- gp + labs(title = "Total Emissions by Type for Baltimore City", x="Year", y="Total Emissions (tons)")
# Add bar graph
gp <- gp + geom_bar(stat='identity')
# Disable legend
gp <- gp + guides(fill = FALSE)
# Render it
gp
# And close the device
dev.off()
