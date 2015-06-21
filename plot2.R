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

# Total all PM25 emissions by year
totByYear <- aggregate(Emissions ~ year, data=baltimoreCityNEI, sum)
# Convert to kilotons (avoid E notation)
totByYear$Emissions <- totByYear$Emissions / 1000.0

# And do simple plot of values to show trend
png(filename='plot2.png', width=480, height=480)
with(totByYear, plot(Emissions ~ year, type="b", xlab="Year", ylab="Total PM25 Emissions (kilotons)", main="Total Emissions from PM2.5 for Baltimore City (1999-2008)"))
# And close the device
dev.off()
