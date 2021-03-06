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

# Get SCC codes that correspond to different types of vehicles
VehicleSCC <- SCC[grep("Vehicle",SCC$SCC.Level.Two),]$SCC

# Reduce to just those vehicle sources in Baltimore City
BaltimoreCityNEI <- NEI[NEI$fips == "24510",]
VehicleNEI <- BaltimoreCityNEI[BaltimoreCityNEI$SCC %in% VehicleSCC,]

# Aggregate by year
totByYear <- aggregate(Emissions ~ year, data=VehicleNEI, sum)

# And do simple plot of values to show trend
png(filename='plot5.png', width=480, height=480)
# Create plot
gp <- ggplot(totByYear, aes(factor(year), Emissions, fill=year))
# Add labels
gp <- gp + labs(title = "Total PM2.5 Emissions by Motor Vehicles for Baltimore City", x="Year", y="Total PM2.5 Emissions (tons)")
# Add bar
gp <- gp + geom_bar(stat="identity")
# Disable legend
gp <- gp + guides(fill = FALSE)
# Render it
gp
# And close the device
dev.off()
