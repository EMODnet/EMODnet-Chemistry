using NCDatasets
using Dates
using Glob
using DIVAnd
using Test
include("MergingClim.jl")

# Merge the 4 seasonal file into a unique, annual file for each variable and each season.
# The record variable (time) has already been created.
#
# 1. Loop on the regions
# 2. Loop on the variables
# 3. List the files corresponding to the variable and the region
# 4. Process the list of files


# User inputs
# ------------

hostname = gethostname()
if hostname == "ogs04"
	@info "Working in production server"
	outputbasedir = "/production/apache/data/emodnet-test-charles/merged"
	databasedir = "/production/apache/data/emodnet-domains/By sea regions"
elseif hostname == "GHER-ULg-Laptop"
	outputbasedir = "/data/EMODnet/Chemistry/merged/"
	databasedir = "/data/EMODnet/Chemistry/prod/"
elseif hostname == "gherdivand"
	outputbasedir = "/home/ctroupin/data/EMODnet/merged"
	databasedir = "/home/ctroupin/data/EMODnet/By sea regions"
else
	@error("Unknown host")
end

isdir(outputbasedir) ? @debug("Already exists") : mkpath(outputbasedir);
# Splitdir is an intermediate directory where all the individual files are stored
splitdir = joinpath(outputbasedir, "split/")

regionlist = readdir(databasedir);
varnamelist = ["chlorophyll-a", "silicate", "oxygen_concentration", "phosphate", "nitrogen"]

# Loop on regions
for region in regionlist[3:3]
	@info("Working on region $(region)")
	regionstring = replace(region, " "=>"_")
	regiondir = joinpath(databasedir, region)
	isdir(regiondir) ? @debug("Directory exists") : @warn("Directory does not exist")

	seasonlist = readdir(regiondir, join=true)
	seasonlist = seasonlist[isdir.(seasonlist)]
	seasondir = seasonlist[1]

	# Generate a list of files from the first season directory
	# (since the file names are the same for each season)
	datafilelist = basename.(glob("*.nc", seasondir))
	#@show(datafilelist);
	nfiles = length(datafilelist)
	@info("Found $(nfiles) variables");

	# Create new output directory
	outputdir = joinpath(outputbasedir, region)
	isdir(outputdir) ? @debug("Already exists") : mkpath(outputdir);
	isdir(splitdir) ? @debug("Already exists") : mkpath(splitdir);	
        @info("Output directory: $(outputdir)");
 
	# Now for each variable we construct the path of the 4 files (one per season)
	for variable in datafilelist[3:3]
		@info("Working on variable $(variable)");
			
		# Ensure the intermediate directory is there
		# (cause delete it at the end of the loop)
	        isdir(splitdir) ? @debug("ok") : mkpath(splitdir);
	
		# Create the name of the new output file
		outputfile = joinpath(outputdir, variable)
		@info("Creating new output file $(outputfile)");

		# Generate a list of file path for: 1 region and 1 variable (and hence 4 seasons)
		datafilepaths = [joinpath(databasedir, region, season, variable) for season in seasonlist];

		# TODO check if the dimensions are the same in the 4 files
		# if not: cannot be merged using nco; need manual editing.

		# Loop on all the 4 files
		for datafile in datafilepaths

		    # Open the netCDF and loop on the time instances 
		    # to create new files
           	    NCDatasets.Dataset(datafile, "r") do ds
                	for (ii, tt) in enumerate(ds["time"][:])
                            timesuffix = Dates.format(tt, "yyyymmdd")
                            splitfile = joinpath(splitdir, "$(regionstring)_$(variable)_$(timesuffix).nc")
                            nckscommand = `ncks -d time,$(ii-1) "$(datafile)" $(splitfile)`;
                    
                            if isfile(splitfile)
                                @debug("The output file has already been created")
                            else
                                run(nckscommand);
                                @debug("ok");
			    end
                        end

                    end
                end
		splitfiles = Glob.glob("*.nc*", splitdir)
		ncrcatcommand = `ncrcat -h $(splitfiles) "$(outputfile)"`;
	        
                # Merge all the individual files into a single one	
		if isfile(outputfile)
			@info("The output file has already been created")
		else
			run(ncrcatcommand);
			@debug("ok");
		end

		@info("Cleaning intermediate files")
		rm(splitdir, recursive=true)

		@info("input: $(datafilepaths)");
		@info("output: $(outputfile)");


		# Remove the observation-related variables
		nckscommand = `ncks -O -x -v obslon,obslat,obsdepth,obstime,obsid "$(outputfile)" "$(outputfile)"`
		run(nckscommand);

		# Read observations from the file list
		@time obslon, obslat, obsdepth, obstime, obsid = MergingClim.read_obs(datafilepaths);

		# Ensure unique observations
		obslon_u, obslat_u, obsdepth_u, obstime_u, obsid_u = MergingClim.unique_obs(obslon, obslat, obsdepth, obstime, obsid);

		# Write the file
		MergingClim.write_obs(outputfile, obslon_u, obslat_u, obsdepth_u, obstime_u, obsid_u);
	
	end

end
