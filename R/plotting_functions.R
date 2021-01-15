#' plotting method for objects of class "tri.surf.points"
#'
#' @param x an object of class "tri.surf.points"
#' @param style the type of plot to generate. There are currently 2 options, "points" and "triangulation". "points" is the default and just plots the interior and perimeter points. "triangulation" plots the delaunay triangulation wireframe with centroids highlighted.
#' @param ... Additional plotting parameters to be passed to plot.default
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @export
plot.tri.surf.points <- function(x, style = "points",...){
  if(style == "points"){
    plot(x$perimeter, ylim = rev(range(x$perimeter[,2])), ...)
    points(x$interior, ...)
  }

  if(style == "triangulation"){
    tri.object <- rbind(x$perimeter[x$point.map,], x$interior)
    are.you.in <- point.in.polygon(x$centroids[,1], x$centroids[,2], x$perimeter[x$point.map,1], x$perimeter[x$point.map,2]) #index for out of boundary triangles caused by concavities
    plot(x$perimeter, typ = "n", ylab = "", xlab = "", axes = F, ylim = rev(range(x$perimeter[,2])), ...)
    points(x$centroids[are.you.in == 1,], col = 2, pch = 19, cex = .25, ...)

    for(j in c(1:nrow(triangles(x$final.mesh)))[are.you.in==1]){
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,2],]))
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,3],]))
      lines(rbind(tri.object[triangles(x$final.mesh)[j,2],], tri.object[triangles(x$final.mesh)[j,3],]))
    }
  }

}

#' plotting individual specimens after color sampling
#'
#' @param x an object of class "tri.surf.points". If using this function after color sampling, it will be object$delaunay
#' @param individual which individual from your landmark dataframe you'd like to plot
#' @param visualization_type plot raw "sampled" color or "calibrated" color? Sampled is the default.
#' @param ... Additional plotting parameters to be passed to plot.default
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @export
plot.mesh.colors <- function(mesh.colors.object, individual = 1, visualization_type = "sampled"){
  if(visualization_type == "sampled"){
  plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$sampled.color[,,individual]), pch = 19, asp = 1)
  } else if(visualization_type == "calibrated"){
    plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$calibrated.color[,,individual]), pch = 19, asp = 1)
  } else if(visualization_type == "linearized"){
    plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$linearized.color[,,individual]), pch = 19, asp = 1)
  }
  }

#' plotting individual specimens before AND after color sampling | select individual or 3 random side by side individuals
#'
#' @param x an object of class "tri.surf.points". If using this function after color sampling, it will be object$delaunay
#' @param individual which individual from your landmark dataframe you'd like to plot
#' @param visualization_type plot raw "sampled" color or "calibrated" color? Sampled is the default.
#' @param ... Additional plotting parameters to be passed to plot.default
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @export
plot.calibrated.mesh.colors <- function(mesh.colors.object, individual = 1, visualization_type = "calibrated"){
  if(visualization_type == "diagnostic"){
    par(mfrow = c(2,1))
    plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$calibrated[,,individual]), pch = 19, asp = 1)
    plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$sampled.color[,,individual]), pch = 19, asp = 1)
  } else if(visualization_type == "calibrated"){
    plot(mesh.colors.object$delaunay, col = rgb(mesh.colors.object$calibrated[,,individual]), pch = 19, asp = 1)
  }
  }


