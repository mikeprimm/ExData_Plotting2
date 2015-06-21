# Get libraries
library(ggplot2)
library(grid)
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
# Build sets for each city, reduced to just vehicle data
BaltimoreCityNEI <- NEI[NEI$fips == "24510",]
BaltimoreVehicleNEI <- BaltimoreCityNEI[BaltimoreCityNEI$SCC %in% VehicleSCC,]
LANEI <- NEI[NEI$fips == "06037",]
LAVehicleNEI <- LANEI[LANEI$SCC %in% VehicleSCC,]
# Aggregate by year
BaltimoreTotByYear <- aggregate(Emissions ~ year, data=BaltimoreVehicleNEI, sum)
LATotByYear <- aggregate(Emissions ~ year, data=LAVehicleNEI, sum)
# Label them
BaltimoreTotByYear$City <- 'Baltimore City'
LATotByYear$City <- "Los Angeles"
# Compute change in values since 1999 values for each city
Balt1999Tot <- BaltimoreTotByYear[BaltimoreTotByYear$year == 1999,]$Emissions
LA1999Tot <- LATotByYear[LATotByYear$year == 1999,]$Emissions
BaltimoreTotByYear$EmissionsChange <- 100.0 * (BaltimoreTotByYear$Emissions - Balt1999Tot) / Balt1999Tot
LATotByYear$EmissionsChange <- 100.0 * (LATotByYear$Emissions - LA1999Tot) / LA1999Tot

# Append them
totByYear <- rbind(BaltimoreTotByYear, LATotByYear)

# And do simple plot of values to show trend
png(filename='plot6.png', width=480, height=960)
# Create plot
gp <- ggplot(totByYear, aes(factor(year), Emissions, fill=year)) + facet_grid(. ~ City)
# Add labels
gp <- gp + labs(title = "Total Motor Vehicle Emissions for Baltimore City and LA Counties", x="Year", y="Total Emissions (tons)")
# Add bar graph
gp <- gp + geom_bar(stat='identity')
# Disable legend
gp <- gp + guides(fill = FALSE)

# Do second plot for change rates
gp2 <- ggplot(totByYear, aes(factor(year), EmissionsChange, fill=year)) + facet_grid(. ~ City)
# Add labels
gp2 <- gp2 + labs(title = "% Change in M.V. Emissions for Baltimore City and LA Counties", x="Year", y="Change since 1999 (%)")
# Add bar graph
gp2 <- gp2 + geom_bar(stat='identity')
# Disable legend
gp2 <- gp2 + guides(fill = FALSE)

# Render them
grid.newpage()
layout <- matrix(c(1,2), nrow=2, byrow=TRUE)
pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
matchidx <- as.data.frame(which(layout == 1, arr.ind = TRUE))
print(gp, vp = viewport(layout.pos.row = matchidx$row,
                        layout.pos.col = matchidx$col))
matchidx <- as.data.frame(which(layout == 2, arr.ind = TRUE))
print(gp2, vp = viewport(layout.pos.row = matchidx$row,
                        layout.pos.col = matchidx$col))
popViewport()

# And close the device
dev.off()
