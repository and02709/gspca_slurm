args <- commandArgs()
# define arguments
setwd <- args[6]
#groupdf <- args[7]
#gparams <- args[8]

fpath <- paste(setwd, "temp/cv_outputs/",sep="")
file.list <- list.files(fpath,".txt")
file.path.list <- paste0(fpath,file.list)

#groups <- read.table(file=groupdf, header=F) |> as.matrix() |> as.vector()
#nonzero.groups <- read.table(file=gparams, header=F) |> as.matrix() |> as.vector()

parampath <- paste(setwd, "temp/param.txt",sep="")
paramgrid <- read.table(file=parampath, header=T)
n.gr <- length(unique(paramgrid$gr.arg))
n.folds <- length(unique(paramgrid$fold.arg))

read_cv_func <- function(x){
  temp.obj <- read.table(file=x,header=T)
  return(temp.obj)
}
cv.list <- lapply(file.path.list,read_cv_func)
cv.obj <- do.call(rbind.data.frame,cv.list)
cv.mat <- cv.obj[order(cv.obj$job),]
cv.mat <- cv.mat[,-1]

metric.matrix <- sgmeth2::mat.fill(param.grid=cv.mat,n.sp=n.gr,n.folds=n.folds)
cv.metric <- apply(metric.matrix,1,mean)
gpath <- paste(setwd, "temp/garg.txt",sep="")
g.arg <- read.table(gpath, header=T)
cv.df <- data.frame(nonzero.groups=g.arg,cv.metric=cv.metric)
colnames(cv.df) <- c("groups","cv.metric")
best.metric <- min(cv.df$cv.metric)
best.group.param <- cv.df$groups[which(cv.df$cv.metric==best.metric)]

cat("best cv metric: ",best.metric,"\n")
cat("best group parameter: ",best.group.param,"\n")
