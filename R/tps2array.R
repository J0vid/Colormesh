#' read TPS files and convert data to an array
#'
#' @param data A .TPS file
#' @return A matrix of the landmarks for each observation
#' @export
tps2array <- function(data){
  # Reads the .tps file format produced by TPSDIG
  # (http://life.bio.sunysb.edu/morph/ into a single data frame
  # USAGE: R> read.tps("filename.tps")
  a = readLines(data) # so we can do some searching and indexing
  LM = grep("LM", a) # find the line numbers for LM
  ID.ind = grep("ID", a) # find the line numbers for ID
  # and the ID values, SCALE values, and image names
  ID = gsub("(ID=)(.*)", "\\2", grep("ID", a, value=T))
  SCALE = gsub("(SCALE=)(.*)", "\\2", grep("SCALE", a, value=T))
  images = basename(gsub("(IMAGE=)(.*)", "\\2", a[ID.ind - 1]))
  # FOR EACH LOOP
  skip = LM # set how many lines to skip
  # and how many rows to read
  nrows = as.numeric(gsub("(LM=)(.*)", "\\2", grep("LM", a, value=T)))
  l = length(LM) # number of loops we want

  landmarks = vector("list", l) # create an empty list

  for (i in 1:l) {
    landmarks[i] = list(data.frame(
      read.table(file=data, header=F, skip=LM[i],
                 nrows=nrows[i], col.names=c("X", "Y")),
      IMAGE = as.character(images[i]),
      ID = ID[i],
      SCALE = SCALE[i]))
  }

  tpsfile <- do.call(rbind, landmarks) # rbind the list items into a data.frame

  #this function assumes unique image names!
  # arrayname <- substr(unique(tpsfile$IMAGE), 1, nchar(as.character(unique(tpsfile$IMAGE))) - 4)
  arrayname <- as.character(unique(tpsfile$IMAGE))
  Nlandmarks <- sum(tpsfile$ID == unique(tpsfile$ID)[1])
  # ID.nums <- rep(0, length(tpsfile$ID))
  coord.array <- array(dim = c(Nlandmarks, 2, length(arrayname)))
  # for (i in 0:(length(tpsfile$ID)/Nlandmarks)) {
  #   ID.nums[((i * Nlandmarks) + 1):(((i + 1) * Nlandmarks) +
  #                                     1)] = rep(i, length(Nlandmarks))
  # }
  for (ind in 1:length(coord.array[1, 1, ])) {
    coord.array[, , ind] = as.matrix(tpsfile[tpsfile$ID == unique(tpsfile$ID)[ind],
                                             1:2])
  }

  if(dim(coord.array)[3] == 1){ dimnames(coord.array)[[3]] <- list(arrayname)
  } else{dimnames(coord.array)[[3]] <- (arrayname)}

  return(coord.array)

}

