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
modulesFireCalibration <- c("group_scfm")
times <- list(start = 0, end = 1)
successionTimestep <- 1L
parameters <- list(
  scfmDriver = list(
    "targetN" = 1000),
  scfmLandcoverInit = list(
    ".plotInitialTime" = times$start
  ),
  scfmRegime = list(
    "fireCause" = "L"
  ),
  scfmSpread = list(
    "pSpread" = 0.235,
    "returnInterval" = successionTimestep,
    "startTime" = times$start,
    ".plotInitialTime" = times$start+1,
    ".plotInterval" = successionTimestep
  )
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
  # "vegMap" = RTM,
  "studyArea" = studyArea,
  # "fireRegimePolys " = studyArea,
  "LCC05" = raster(file.path(getwd(), "inputs/LCC2005_V1_4a.tif"))
)
scfmCalibration <- simInit(times = times, 
                         objects = objects,
                         params = parameters,
                         modules = as.list(modulesFireCalibration),
                         paths = getPaths(),
                         loadOrder = modulesFireCalibration)
scfmCalibration2 <- spades(scfmCalibration,
                           debug = 1)


flammableMap <- saveRDS(scfmCalibration2$flammableMap, file.path(getPaths()$inputPath, "flammableMap.rds"))
landscapeAttr <- saveRDS(scfmCalibration2$landscapeAttr, file.path(getPaths()$inputPath, "landscapeAttr.rds"))
scfmDriverPars <- saveRDS(scfmCalibration2$scfmDriverPars, file.path(getPaths()$inputPath, "scfmDriverPars.rds"))
scfmRegimePars <- saveRDS(scfmCalibration2$scfmRegimePars, file.path(getPaths()$inputPath, "scfmRegimePars.rds"))
fireRegimePolys <- saveRDS(scfmCalibration2$fireRegimePolys, file.path(getPaths()$inputPath, "fireRegimePolys.rds"))
firePoints <- saveRDS(scfmCalibration2$firePoints, file.path(getPaths()$inputPath, "firePoints.rds"))
