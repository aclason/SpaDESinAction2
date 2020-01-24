# Running preambule for scfm: 
library("reproducible")
Require(packages = "PredictiveEcology/LandR", install_githubArgs = list(ref = "development"))
Require(packages = "PredictiveEcology/quickPlot", install_githubArgs = list(ref = "development"))
Require(packages = "PredictiveEcology/SpaDES.tools", install_githubArgs = list(ref = "development"))
Require(packages = "PredictiveEcology/SpaDES.experiment", install_githubArgs = list(ref = "master"))
Require(packages = "raster")
Require(packages = "data.table")
options(
  "spades.recoveryMode" = 2,
  "spades.lowMemory" = TRUE,
  "LandR.assertions" = FALSE,
  "LandR.verbose" = 1,
  "reproducible.useMemoise" = TRUE, # Brings cached stuff to memory during the second run
  "reproducible.useNewDigestAlgorithm" = TRUE,  # use the new less strict hashing algo
  "reproducible.useCache" = TRUE,
  "pemisc.useParallel" = FALSE
)
inputDirectory <- checkPath(file.path(getwd(), "inputs"), create = TRUE)
outputDirectory <- checkPath(file.path(getwd(), "outputs"), create = TRUE)
modulesDirectory <- checkPath(file.path(getwd(), "modules"), create = TRUE)
cacheDirectory <- checkPath(file.path(getwd(), "cache"), create = TRUE)

setPaths(cachePath = cacheDirectory,
         modulePath = c(modulesDirectory, 
                        file.path(modulesDirectory, "scfm/modules")),
         inputPath = inputDirectory,
         outputPath = outputDirectory)
modulesFireCalibration <- c("scfmLandcoverInit",
                            "scfmRegime",
                            "scfmDriver")
times <- list(start = 0, end = 10)
parameters <- list(
  scfmRegime = list(
    "fireCause" = "L"),
  scfmDriver = list(
    "targetN" = 1000)
)
# load studyArea
studyArea <- readRDS(file.path(getPaths()$inputPath, "studyArea.rds"))

# NWT land cover classes -- base map to locate study area and be the reference raster (i.e. resolution, crs and extent)
regionMap <- Cache(reproducible::prepInputs, 
                   url = "https://drive.google.com/open?id=1WhL-DxrByCbzAj8A7eRx3Y1FVujtGmtN",
                   targetFile = "LCC2005_V1_4a_BCR6_NWT.tif",
                   destinationPath = getPaths()$inputPath,
                   fun = "raster::raster", 
                   userTags = "objectName:regionMap")
Plot(regionMap, title = "The NWT"); Plot(studyArea, addTo = "regionMap", title = "The NWT")
RTM <- Cache(reproducible::prepInputs, 
             url = "https://drive.google.com/open?id=1WhL-DxrByCbzAj8A7eRx3Y1FVujtGmtN", 
             studyArea = studyArea,
             targetFile = "LCC2005_V1_4a_BCR6_NWT.tif",
             destinationPath = getPaths()$inputPath,
             fun = "raster::raster", 
             userTags = "objectName:regionMapCropped", overwrite = TRUE)
objects <- list(
  "rasterToMatch" = RTM,
  "rasterToMatchLarge" = RTM,
  "vegMap" = RTM,
  "studyArea" = studyArea,
  "LCC05" = raster(file.path(getwd(), "inputs/LCC2005_V1_4a.tif"))
)
scfmCalibration <- simInitAndSpades(times = times, 
                         objects = objects,
                         params = parameters,
                         modules = as.list(modulesFireCalibration),
                         paths = getPaths(),
                         loadOrder = modulesFireCalibration,
                         debug = 1)

flammableMap <- saveRDS(scfmCalibration$flammableMap, file.path(getPaths()$inputPath, "flammableMap.rds"))
landscapeAttr <- saveRDS(scfmCalibration$landscapeAttr, file.path(getPaths()$inputPath, "landscapeAttr.rds"))
scfmDriverPars <- saveRDS(scfmCalibration$scfmDriverPars, file.path(getPaths()$inputPath, "scfmDriverPars.rds"))

