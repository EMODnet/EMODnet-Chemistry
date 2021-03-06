# Data product visualisation

## Web Map Service

The analysed field generated by [`DIVA`](https://github.com/gher-ulg/DIVA) (Data-Interpolating Variational Analysis) can be visualised using the [WMS](http://www.opengeospatial.org/standards/wms) protocol which supports the following requests:

### GetCapabilities

This request is used to provide all layers of the map server. To every parameter and to every region corresponds a different WMS layer. An example of such a request would be:

http://ec.oceanbrowser.net/emodnet/Python/web/wms?request=GetCapabilities&service=WMS&version=1.3.0

### GetMap

This request allows the extraction of a horizontal section of the 4D netCDF file at the specified depth and time ([Example URL](http://ec.oceanbrowser.net/emodnet/Python/web/wms?LAYERS=North%20Sea%2FAutumn%20(September-November)%20-%206-years%20running%20averages%2FWater_body_chlorophyll-a.4Danl.nc*Water_body_chlorophyll-a_L2&STYLES=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A0.224986%2Bvmax%3A5%2Bncontours%3A40&TRANSPARENT=true&FORMAT=image%2Fpng&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&ELEVATION=-0.0&TIME=2000&SRS=EPSG%3A4326&BBOX=45,0,67.5,22.5&WIDTH=512&HEIGHT=512)).

![WMS](http://ec.oceanbrowser.net/emodnet/Python/web/wms?LAYERS=North%20Sea%2FAutumn%20(September-November)%20-%206-years%20running%20averages%2FWater_body_chlorophyll-a.4Danl.nc*Water_body_chlorophyll-a_L2&STYLES=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A0.224986%2Bvmax%3A5%2Bncontours%3A40&TRANSPARENT=true&FORMAT=image%2Fpng&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&ELEVATION=-0.0&TIME=2000&SRS=EPSG%3A4326&BBOX=45,0,67.5,22.5&WIDTH=512&HEIGHT=512)


By default, the axis are not displayed on a map. This can be activated by setting the parameter `DECORATED` to `true` ([Example URL](http://ec.oceanbrowser.net/emodnet/Python/web/wms?LAYERS=North%20Sea%2FAutumn%20(September-November)%20-%206-years%20running%20averages%2FWater_body_chlorophyll-a.4Danl.nc*Water_body_chlorophyll-a_L2&STYLES=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A0.224986%2Bvmax%3A5%2Bncontours%3A40&TRANSPARENT=true&FORMAT=image%2Fpng&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&ELEVATION=-0.0&TIME=2000&SRS=EPSG%3A4326&BBOX=45,0,67.5,22.5&WIDTH=512&HEIGHT=512&decorated=true)).

![Example URL](http://ec.oceanbrowser.net/emodnet/Python/web/wms?LAYERS=North%20Sea%2FAutumn%20(September-November)%20-%206-years%20running%20averages%2FWater_body_chlorophyll-a.4Danl.nc*Water_body_chlorophyll-a_L2&STYLES=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A0.224986%2Bvmax%3A5%2Bncontours%3A40&TRANSPARENT=true&FORMAT=image%2Fpng&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&ELEVATION=-0.0&TIME=2000&SRS=EPSG%3A4326&BBOX=45,0,67.5,22.5&WIDTH=512&HEIGHT=512&decorated=true)

The `GetMap` can also be used to extract a vertical section ([Example URL](http://ec.oceanbrowser.net/emodnet/Python/web/wms_vert?LAYERS=Mediterranean%20Sea%2FSummer%20(July-September)%20-%206-years%20running%20averages%2FWater_body_dissolved_oxygen_concentration.4Danl.nc*Water_body_dissolved_oxygen_concentration_L2&STYLES=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A163.812552691%2Bvmax%3A260.829413252%2Bncontours%3A40&FORMAT=image%2Fpng&TRANSPARENT=true&RATIO=0.0038709759611184266&SECTION=1.328125%2C38.9921875%7C5.01953125%2C41.98046875%7C9.0625%2C43.03515625&TIME=2000&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG%3A4326&BBOX=715.16523453802,-702.85195100572,1430.330469076,12.313283532303&WIDTH=256&HEIGHT=256)). The path of the section is encoded in the `SECTION` parameter: the longitude and latitude are separated by a comma and the coordinates by the pipe-symbol (`|`). The x-axis corresponds to the distance in arc degrees along the section (the first point is the origin) and the y-axis in the depth in meters. The parameter `RATIO` defines the aspect ratio of the vertical section.

![Example URL](http://ec.oceanbrowser.net/emodnet/Python/web/wms_vert?LAYERS=Mediterranean%20Sea%2FSummer%20(July-September)%20-%206-years%20running%20averages%2FWater_body_dissolved_oxygen_concentration.4Danl.nc*Water_body_dissolved_oxygen_concentration_L2&STYLES=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A163.812552691%2Bvmax%3A260.829413252%2Bncontours%3A40&FORMAT=image%2Fpng&TRANSPARENT=true&RATIO=0.0038709759611184266&SECTION=1.328125%2C38.9921875%7C5.01953125%2C41.98046875%7C9.0625%2C43.03515625&TIME=2000&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG%3A4326&BBOX=715.16523453802,-702.85195100572,1430.330469076,12.313283532303&WIDTH=512&HEIGHT=512&decorated=true)

Images can be returned in raster (PNG) or vector image formats (SVG, EPS, PDF). They can also be saved as a KML file so that the current layer can be visualized in programs like Google Earth and combined with other information imported in such programs.
By providing multiple time instances, the web map server can also return animation in the [WebM](https://www.webmproject.org/) or MP4 formats using this GetMap request ([Example URL](http://ec.oceanbrowser.net/emodnet/Python/web/wms?&layers=North%20Sea%2FAutumn%20(September-November)%20-%206-years%20running%20averages%2FWater_body_chlorophyll-a.4Danl.nc*Water_body_chlorophyll-a_L2&request=GetMap&width=800&height=500&bbox=-5.600586%2C49.289606%2C15.493164%2C62.253474&transparent=true&decorated=true&crs=CRS%3A84&version=1.3.0&styles=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A0.224986%2Bvmax%3A8.34064%2Bncontours%3A40&format=video%2Fwebm&elevation=-0.0&time=1983%2C1984%2C1985%2C1986%2C1987%2C1988%2C1989%2C1990%2C1991%2C1992%2C1993%2C1994%2C1995%2C1996%2C1997%2C1998%2C1999%2C2000%2C2001%2C2002%2C2003%2C2004%2C2005%2C2006%2C2007%2C2008%2C2009%2C2010%2C2011%2C2012%2C2013%2C2014%2C2015&title=Water%20body%20chlorophyll-a%20masked%20using%20relative%20error%20threshold%200.5%0Adepth%3A%20-0.0%20meters&basemap=shadedrelief&rate=2). As the animations are generated dynamically, it usually takes a couple of minutes to create them. The frame rate of the animation is controlled through the parameter `rate`.


### GetFeatureInfo

This request returns a simple XML file with the underlying value of the analysed field ([Example URL](http://ec.oceanbrowser.net/emodnet/Python/web/wms?LAYERS=North%20Sea%2FAutumn%20(September-November)%20-%206-years%20running%20averages%2FWater_body_chlorophyll-a.4Danl.nc*Water_body_chlorophyll-a_L2&STYLES=cmap%3Ajet%2Binverted%3Afalse%2Bmethod%3Apcolor_flat%2Bvmin%3A0.224986%2Bvmax%3A8.34064%2Bncontours%3A40&TRANSPARENT=true&FORMAT=image%2Fpng&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&ELEVATION=-0.0&TIME=2000&SRS=EPSG%3A4326&EXCEPTIONS=application%2Fvnd.ogc.se_xml&BBOX=-5.600586%2C49.289606%2C15.493164%2C62.253474&X=342&Y=406&INFO_FORMAT=application%2Fvnd.ogc.gml&QUERY_layers=North%20Sea%2FAutumn%20(September-November)%20-%206-years%20running%20averages%2FWater_body_chlorophyll-a.4Danl.nc*Water_body_chlorophyll-a_L2&WIDTH=960&HEIGHT=590)).

However, the WMS standards (in version 1.1.1 and 1.3.0) are not completely adequate for ocean analyses. A WMS allows one to represent a data set according to a list of different styles. A legend is attributed to each style which for scalar is colorbar. The legend for a given style is represented by a link to an image.

A single legend is used for the entire data set (for all depth layers and time instances in particular). However the ocean is strongly stratified and a unique legend does not provide sufficient contrast because the ocean properties at depth are often very different from the properties near the surface. The solution is to make the legend dynamic so that it can be adjusted based on a range of values at a specified depth and time.

## OPeNDAP

[OPeNDAP](https://www.opendap.org/) allows one to download and subset gridded datasets. The OPeNDAP product is nowadays included in the netCDF library so that most programs able to read netCDF files can also access remote datasets over OPeNDAP and download only the actual required data subset.

A [Jupyter notebook](src/EMODNET-chemistry.ipynb) illustrates the use of an EMODNET-Chemistry product using OPeNDAP. To run this example, it is necessary to install the following (free) software packages:

* Julia available from https://julialang.org/downloads/. The code is tested with the version 0.6 of Julia.
* Some Julia packages ([NCDatasets](https://github.com/Alexander-Barth/NCDatasets.jl), [PyPlot](https://github.com/JuliaPy/PyPlot.jl) and [IJulia](https://github.com/JuliaLang/IJulia.jl)), which can be installed with these commands once you have started Julia:

```julia
Pkg.add("NCDatasets.jl")
Pkg.add("PyPlot")
Pkg.add("IJulia")
```
