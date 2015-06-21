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

# Get SCC codes that correspond to different types of coal burning
CoalSCC <- SCC[grep("Fuel Comb.*Coal",SCC$EI.Sector),]$SCC

# Reduce to just those coal burning sources
CoalNEI <- NEI[NEI$SCC %in% CoalSCC,]
# Aggregate by year and type
totByYear <- aggregate(Emissions ~ year, data=CoalNEI, sum)

# And do simple plot of values to show trend
png(filename='plot4.png', width=480, height=480)
# Create plot
gp <- ggplot(totByYear, aes(factor(year), Emissions/1000.0, fill=year))
# Add labels
gp <- gp + labs(title = "Total PM2.5 Emissions by Coal Combustion for United States", x="Year", y="Total PM2.5 Emissions (kilotons)")
# Add bar graph
gp <- gp + geom_bar(stat="identity")
# Disable legend
gp <- gp + guides(fill = FALSE)
# Render it
gp
# And close the device
dev.off()
