"""
Example of script to merge the observations containing in a list of netCDF files
and write them in a new file.

The 2 main inputs to modify are:
1) `datafilelist`: a list of file paths
2) `datafilemerge`: the path of a netCDF file into which the combined observations
will be written.

Typically, `datafilemerge` would be a file obtained following these
[instructions](https://github.com/gher-ulg/EMODnet-Chemistry/blob/master/doc/merging_netCDF.md),
after the command
```bash
ncks -x -v obslon,obslat,obsdepth,obstime,obsid inputfile.nc outputfile.nc
```

If you get the error
`ERROR: LoadError: NetCDF error: NetCDF: String match to name in use (NetCDF error code: -42)`,
this is probably due the fact that the variables you want to create (obslon, obslat etc)
have not been removed from the file.
"""

using NCDatasets
using PyPlot
using DataStructures
using Dates

datadir = "/media/ctroupin/My Passport/data/EMODnet/Eutrophication/Products/BlackSea"
datafilelist = [joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Autumn.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Spring.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Summer.4Danl.nc"),
                joinpath(datadir, "Water_body_dissolved_oxygen_concentration_Winter.4Danl.nc"),
               ]
datafilemerge = joinpath(datadir, "Water_body_dissolved_oxygen_concentration_year.nc")

"""
    read_obs(datafile)

Read the observations from a netCDF file.

## Example
```julia-repl
julia> obslon, obslat, obsdepth, obstime, obsid = read_obs(datafile)
```
"""
function read_obs(datafile::String)

    NCDatasets.Dataset(datafile, "r") do nc

        obslon = Float64.(nc["obslon"][:])
        obslat = Float64.(nc["obslat"][:])
        obsdepth = Float64.(nc["obsdepth"][:])
        obstime = nc["obstime"][:]
        obsid = nc["obsid"][:]

        return obslon::Vector{Float64}, obslat::Vector{Float64},
        obsdepth::Vector{Float64}, obstime::Vector{DateTime},
        obsid::Matrix{Char}

    end
end

"""
    read_obs(filelist)

Read the observations from a list of netCDF files.

## Example
```julia-repl
julia> obslon, obslat, obsdepth, obstime, obsid = read_obs(datafilelist)
```
"""
function read_obs(datafilelist::Vector{String})

    # Empty vectors
    obslon = Vector{Float64}(undef, 0)
    obslat = Vector{Float64}(undef, 0)
    obsdepth = Vector{Float64}(undef, 0)
    obstime = Vector{DateTime}(undef, 0)
    obsid = Matrix{Char}(undef, 0, 0)

    for datafile in datafilelist
        @debug("Working on $(datafile)")
        NCDatasets.Dataset(datafile, "r") do nc

            obslon_n, obslat_n, obsdepth_n, obstime_n, obsid_n = read_obs(datafile)

            # Append the coordinate arrays
            append!(obslon, obslon_n);
            append!(obslat, obslat_n);
            append!(obsdepth, obsdepth_n);
            append!(obstime, obstime_n);

            obsid = merge_obsids(obsid, obsid_n)
        end
    end

    return obslon::Vector{Float64}, obslat::Vector{Float64},
    obsdepth::Vector{Float64}, obstime::Vector{DateTime},
    obsid::Matrix{Char}

end

"""
    merge_obsids(obsid1, obsid2)

Merge two arrays of observations

## Example
```julia-repl
julia> obsid = merge_obsids(obsid_old, obsid_new)
```
"""
function merge_obsids(obsid1::Matrix{Char}, obsid2::Matrix{Char})
    idlen1, nobs1 = size(obsid1)
    idlen2, nobs2 = size(obsid2)
    @debug(idlen1, idlen2, nobs1, nobs2);

    # Allocate new matrix for obsid
    obsid = Array{Char, 2}(undef, maximum((idlen1, idlen2)), nobs1 + nobs2);
    # Merge obsid's
    obsid[1:idlen1, 1:nobs1] = obsid1;
    obsid[1:idlen2, nobs1+1:nobs1 + nobs2] = obsid2;
    @debug(size(obsid));

    return obsid::Matrix{Char}
end


"""
    write_obs(datafile)

Write the new observations to a netCDF file from which the variables
corresponding to the observations (obslon, obslat etc) have been removed.

## Example
```julia-repl
julia> write_obs("merged.nc", obslon, obslat, obsdepth, obstime, obsid)
```
"""
function write_obs(datafile::String, obslon::Vector{Float64}, obslat::Vector{Float64},
    obsdepth::Vector{Float64}, obstime::Vector{Dates.DateTime},
    obsid::Matrix{Char})

    idlen, nobs = size(obsid)

    # Write in the new file
    NCDatasets.Dataset(datafile, "a") do nc
        nc.dim["idlen"] = idlen
        nc.dim["observations"] = nobs

        ncobsdepth = defVar(nc,"obsdepth", Float64, ("observations",),
            attrib = OrderedDict(
                        "units" => "meters",
                        "positive" => "down",
                        "long_name" => "depth of the observations",
                        "standard_name" => "depth"
                    )
                )

        ncobsid = defVar(nc,"obsid", Char, ("idlen", "observations"),
            attrib = OrderedDict(
                "long_name" => "observation identifier",
                "coordinates" => "obstime obsdepth obslat obslon",
                )
            )

        ncobslat = defVar(nc,"obslat", Float64, ("observations",),
            attrib = OrderedDict(
                "units" => "degrees_north",
                "long_name" => "latitude of the observations",
                "standard_name" => "latitude"
                )
            )

        ncobslon = defVar(nc,"obslon", Float64, ("observations",),
            attrib = OrderedDict(
                "units" => "degrees_east",
                "long_name" => "longitude of the observations",
                "standard_name" => "longitude"
                )
            )

        ncobstime = defVar(nc,"obstime", Float64, ("observations",),
            attrib = OrderedDict(
                "units" => "days since 1900-01-01 00:00:00",
                "long_name" => "time of the observations",
                "standard_name" => "time"
                )
            )

        ncobslon[:] = obslon
        ncobslat[:] = obslat
        ncobsdepth[:] = obsdepth
        ncobstime[:] = obstime
        ncobsid[:] = obsid;

        return
    end;
end;


# Main
# -----


# Read observations from the file list
obslon, obslat, obsdepth, obstime, obsid = read_obs(datafilelist);

# Write the file
write_obs(datafilemerge, obslon, obslat, obsdepth, obstime, obsid)
