#' plotting method for objects of class "tri.surf.points"
#'
#' @param x an object of class "tri.surf.points"
#' @param style the type of plot to generate. There are currently 2 options, "points" and "triangulation". "points" is the default and just plots the interior and perimeter points. "triangulation" plots the delaunay triangulation wireframe with centroids highlighted.
#' @param ... Additional plotting parameters to be passed to plot.default
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @method plot tri.surf.points
#' @export
plot.tri.surf.points <- function(x, style = "points", corresponding.image, wireframe.color = "black", point.color = "red",...){
  if(style == "points"){
    # par(mfrow = c(1,1))
    plot(x$perimeter, ylim = rev(range(x$perimeter[,2])), asp = 1, xlab = "", ylab = "", ...)
    points(x$interior, ...)
  }

  if(style == "interior"){
    # par(mfrow = c(1,1))
    plot(x$interior, ylim = rev(range(x$perimeter[,2])), asp = 1, xlab = "", ylab = "", ...)
  }

  if(style == "perimeter"){
    # par(mfrow = c(1,1))
    plot(x$perimeter, ylim = rev(range(x$perimeter[,2])), asp = 1, xlab = "", ylab = "", ...)
  }

  if(style == "triangulation"){
    # par(mfrow = c(1,1))
    tri.object <- rbind(x$perimeter[x$point.map,], x$interior)
    are.you.in <- point.in.polygon(x$centroids[,1], x$centroids[,2], x$perimeter[x$point.map,1], x$perimeter[x$point.map,2]) #index for out of boundary triangles caused by concavities
    plot(x$perimeter, typ = "n", ylab = "", xlab = "", asp = 1, axes = F, ylim = rev(range(x$perimeter[,2])), ...)
    points(x$centroids[are.you.in == 1,], col = point.color, pch = 19, cex = .25, ...)

    for(j in c(1:nrow(triangles(x$final.mesh)))[are.you.in==1]){
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,2],]), col = wireframe.color)
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,3],]), col = wireframe.color)
      lines(rbind(tri.object[triangles(x$final.mesh)[j,2],], tri.object[triangles(x$final.mesh)[j,3],]), col = wireframe.color)
    }
  }

  if(style == "overlay"){
    # par(mfrow = c(1,1))
    plot(corresponding.image, axes = F)
    tri.object <- rbind(x$perimeter[x$point.map,], x$interior)
    are.you.in <- point.in.polygon(x$centroids[,1], x$centroids[,2], x$perimeter[x$point.map,1], x$perimeter[x$point.map,2]) #index for out of boundary triangles caused by concavities
    points(x$centroids[are.you.in == 1,], col = point.color, pch = 19, cex = .25, ...)

    for(j in c(1:nrow(triangles(x$final.mesh)))[are.you.in==1]){
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,2],]), col = wireframe.color, lwd = .5)
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,3],]), col = wireframe.color, lwd = .5)
      lines(rbind(tri.object[triangles(x$final.mesh)[j,2],], tri.object[triangles(x$final.mesh)[j,3],]), col = wireframe.color, lwd = .5)
    }

  }

}

#' plotting individual specimens after color sampling
#'
#' @param mesh.colors.object an object of class "tri.surf.points". If using this function after color sampling, it will be object$delaunay
#' @param individual which individual from your landmark dataframe you'd like to plot
#' @param style plot raw "sampled" color or "calibrated" color? Sampled is the default.
#' @param ... Additional plotting parameters to be passed to plot.default
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @method plot mesh.colors
#' @export

plot.mesh.colors <- function(mesh.colors.object, individual = 1, style = "interior", ...){
  if(style == "interior"){
    par(mfrow = c(1,1))
    plot(mesh.colors.object$delaunay, style = "interior", col = rgb(mesh.colors.object$sampled.color[,,individual]), pch = 19)
  } else if(style == "perimeter"){
    par(mfrow = c(1,1))
    plot(mesh.colors.object$delaunay, style = "perimeter", col = rgb(mesh.colors.object$sampled.perimeter[,,individual]), pch = 19)
  } else if(style == "points"){
    par(mfrow = c(1,1))
    plot(mesh.colors.object$delaunay, style = "interior", col = rgb(mesh.colors.object$sampled.color[,,individual]), pch = 19)
    points(mesh.colors.object$delaunay$perimeter, col = rgb(mesh.colors.object$sampled.perimeter[,,individual]), pch = 19)
  }  else if(style == "comparison"){
    par(mfrow = c(1,1))
    image.files <- list.files(mesh.colors.object$imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP")
    tmp.image <- load.image(paste0(mesh.colors.object$imagedir, image.files[grepl(mesh.colors.object$image.names[individual], image.files)]))
    # implot(tmp.image, points(mesh.colors.object$delaunay$interior[,1], mesh.colors.object$delaunay$interior[,2], col = rgb(mesh.colors.object$sampled.color[,,individual]), pch = 19))
    par(mfrow = c(2,1),
        oma = c(2.5,2.5,1,1),
        mar = c(0,0,3.5,3.5))
    plot(tmp.image, axes = F)
    plot(mesh.colors.object$delaunay$interior[,1], -mesh.colors.object$delaunay$interior[,2] + dim(tmp.image)[2], col = rgb(mesh.colors.object$sampled.color[,,individual]), pch = 19, asp = 1, axes = F, xlab = "", ylab = "")
  }
  }

#' plotting individual specimens before AND after color sampling | select individual or 3 random side by side individuals
#'
#' @param mesh.colors.object an object of class "calibrated.mesh.colors".
#' @param individual which individual from your landmark dataframe you'd like to plot
#' @param style options include "interior", "perimeter", "points", and "comparison".
#' @param ... Additional plotting parameters to be passed to plot.default
#' @return A plot of calibrated mesh colors
#' @method plot calibrated.mesh.colors
#' @export
plot.calibrated.mesh.colors <- function(mesh.colors.object, individual = 1, style = "interior", ...){
  #interior, perimeter, all points plots
  if(style == "perimeter"){
    par(mfrow = c(1,1))
    plot(mesh.colors.object$delaunay$perimeter, col = rgb(mesh.colors.object$calibrated.perimeter[,,individual]), pch = 19, asp = 1, ylim = rev(range(mesh.colors.object$delaunay$perimeter[,2])), ylab = "", xlab = "")
  } else if(style == "comparison"){
    par(mfrow = c(2,1),
        oma = c(2.5,2.5,1,1),
        mar = c(0.5,0.5,3.5,3.5))

    plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$calibrated[,,individual]), pch = 19, main = "Calibrated")
    plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$sampled.color[,,individual]), pch = 19, main = "Raw sampled")
  } else if(style == "interior"){
    par(mfrow = c(1,1))
    plot(mesh.colors.object$delaunay, style = "interior", col = rgb(mesh.colors.object$calibrated[,,individual]), pch = 19)
    }else if(style == "points"){
      par(mfrow = c(1,1))
      plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$calibrated[,,individual]), pch = 19)
      points(mesh.colors.object$delaunay$perimeter, col = rgb(mesh.colors.object$calibrated.perimeter[,,individual]), pch = 19)
    } else if(style == "differences"){
      par(mfrow = c(1,1))
      num.breaks <- 100
      bright.diffs <- colorRampPalette(c("black", "white"))(num.breaks)
      cal.uncal <- mesh.colors.object$calibrated[,,individual] - mesh.colors.object$sampled.color[,,individual]
      plot(mesh.colors.object$delaunay, col = bright.diffs[cut(cal.uncal, num.breaks)], pch = 19)
  }
  }
