# 1. Global script
# Description: 

# 2. Installing necessary libraries and setting options
# devtools::install_github("tati-micheletti/usefun")

# 2a. Libraries
# library("usefun")
library("LandR")
library("SpaDES.core")
library("SpaDES.tools")
library("quickPlot")
library("reproducible")
library("raster")

# 2b. Options
opts <- options(
  "spades.recoveryMode" = 2,
  "LandR.assertions" = FALSE,
  "LandR.verbose" = 1,
  "reproducible.useMemoise" = TRUE, # Brings cached stuff to memory during the second run
  "reproducible.useNewDigestAlgorithm" = TRUE,  # use the new less strict hashing algo
  "reproducible.useCache" = TRUE,
  "pemisc.useParallel" = TRUE
)

# 3. Project structure

# 4. Setting paths
inputDirectory <- reproducible::checkPath(file.path(getwd(), "inputs"), create = TRUE)
outputDirectory <- reproducible::checkPath(file.path(getwd(), "outputs"), create = TRUE)
modulesDirectory <- reproducible::checkPath(file.path(getwd(), "modules"), create = TRUE)
cacheDirectory <- reproducible::checkPath(file.path(getwd(), "cache"), create = TRUE)

setPaths(cachePath = cacheDirectory,
         modulePath = c(modulesDirectory, 
                        file.path(modulesDirectory, "scfm/modules")),
         inputPath = inputDirectory,
         outputPath = outputDirectory)
paths <- getPaths()

# 5. Time
times <- list(start = 0, end = 20)

# 6. Modules
modules <- as.list(
  c("Boreal_LBMRDataPrep",
    "Biomass_core")
  )

# 7. Parameters
successionTimestep <- 1L
parameters <- list(
  Biomass_core = list(
    ".plotInitialTime" = times$start
    , "sppEquivCol" = "Boreal"
    , "successionTimestep" = successionTimestep*10
    , ".useCache" = TRUE 
    , ".useParallel" = FALSE
  )
)

parameters <- list(
  Biomass_core = list(
    ".plotInitialTime" = times$start
    , "sppEquivCol" = "Boreal"
    , "successionTimestep" = successionTimestep*10
    , ".useCache" = TRUE 
    , ".useParallel" = FALSE
  ),
  Biomass_regeneration = list(
    "fireTimestep" = successionTimestep,
    "fireInitialTime" = times$start
  )
)
# 8. Objects


# 9. SimInit and the simList


# 10. `spades()`


# 11. Checking your outputs



  #.progress = list(type = "text", interval = 1), # for a progress bar
  ## If there are further modules, each can have its own set of parameters:
  #module1 = list(param1 = value1, param2 = value2),
  #module2 = list(param1 = value1, param2 = value2)
)


# Generate study area
polyMatrix <- matrix(c(-118.269387, 61.783558), ncol = 2)
areaSize <- 10000000
set.seed(2020)
studyArea <- SpaDES.tools::randomPolygon(x = polyMatrix, hectares = areaSize) # Create Random polygon in southern Ontario
plot(studyArea)

# Providing options and setting paths

# Biomass_core
modules <- list(moduleName)
objects <- list()

#modulePath changed so I can edit in LBMR project
#spadesModulesDirectory <- dirname(getwd())


mySim <- simInit(times = times, params = parameters, modules = modules, objects = objects, paths = paths)

dev()
mySimOut <- spades(mySim, debug = TRUE)