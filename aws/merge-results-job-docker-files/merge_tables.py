import os, fnmatch
from starfish import IntensityTable

filenames = []
listOfFiles = os.listdir('.')
pattern = "*.nc"
for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
            filenames.append(entry)

# load files into memory and concat them
decoded_intensity_tables = map(IntensityTable.open_netcdf, filenames)
merged_table = IntensityTable.concatenate_intensity_tables(decoded_intensity_tables)
merged_table.to_netcdf("merged_decoded_fovs.nc")