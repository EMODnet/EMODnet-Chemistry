include("/home/uniliege01/workspace/ctroupin/EMODnet-Chemistry/julia/emodnetchemistry.jl")
using NCDatasets


# Flags for processing (set to true if modifications have to be applied)
flag_deepest = false
flag_attrib_din = true

# Files and directories
datadir = "/production/apache/data/emodnet-domains/By sea regions/Northeast Atlantic Ocean/"
datafilelist = get_file_list(datadir)

function get_varname(datafile::String)
  varname = replace(basename(datafile), ".4Danl.nc" => "")
  return varname::String
end

# 1. Add deepest depth
if deepest
  @info("Adding deepest depth")
  for datafile in datafilelist
    @info("Working on file $(basename(datafile))")
    varname = get_varname(datafile)
    @info("Variable: $(varname)")
  
    # Check if the variable is available in the file
    NCDatasets.Dataset(datafile, "r") do nc
      varlist = keys(nc)
      if varname in varlist
        @debug("OK")
      else
        @warn("Variable not available in file")
      end
    end

    @info("Adding deepest depth for variable $(varname) in file $(basename(datafile))")

    add_deepest_depth(datafile, varname)
  end
end
  
# 2. Attributes relative to DIN

if flag_attrib_din
  datafile = get_file_list("/production/apache/data/emodnet-domains/By sea regions/Northeast Atlantic Ocean/", "Water_body_dissolved_inorganic_nitrogen_(DIN)")
  for datafile in datafilelist
    @info("Working on file $(basename(datafile))")
    varname = get_varname(datafile)
    @info("Variable: $(varname)")

  end

end
