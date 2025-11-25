 function [meanData stdData histData xctr yctr xbin ybin] = gridding_tool(xv,yv,vv,xx,yy)
 % 2D gridding tool:
 % Given 3 vectors of scattered values xv, yv and vv, grids them
 % using the bin boundaries given by the gridpoints at xx, yy  
 % Also provides the standard deviation and straight count of the data (2D histogram)
 % Grid will be referred at the centers of bins, here just an arithmetic mean
 % NOTE: requires /matlabpathfiles/histcn.m
 %------------------------------------------
 % Usage:
 % [meanData stdData histData xctr yctr xbin ybin] = gridding_tool(xv,yv,vv,xx,yy)
 %------------------------------------------

 histData = histcn([xv(:) yv(:)],xx,yy);
 meanData = histcn([xv(:) yv(:)],xx,yy,'AccumData',vv(:),'Fun',@mean);
 stdData = histcn([xv(:) yv(:)],xx,yy,'AccumData',vv(:),'Fun',@std);

 % Reshape
 histData = histData';
 meanData = meanData';
 stdData = stdData';

 meanData(histData==0) = nan;
 stdData(histData==0) = nan;
 
 xctr = (xx(1:end-1)+xx(2:end))/2;
 yctr = (yy(1:end-1)+yy(2:end))/2;
 xbin = xx;
 ybin = yy;

