#!/bin/sh
set -e

archs=(arm64 armv7 i386 x86_64)
libraries="${@:1:$#-1}"
output="${@: -1}"
output_dir=$(dirname ${output})
output_name=$(basename ${output} .a)
temp_dir="${output_dir}/intermediate"

echo "Combining ${libraries[@]} to ${output}"

mkdir -p $temp_dir

for library in ${libraries[@]}; do
    lipo -info $library

    library_name=$(basename ${library} .a)
    # Extract individual architectures for this library
    for arch in ${archs[@]}; do
        lipo -extract $arch $library -o "${temp_dir}/${library_name}_${arch}.a"
    done
done

# Combine results of the same architecture into a library for that architecture
source_combined=""
for arch in ${archs[@]}; do
    source_libraries=""

    for library in ${libraries[@]}; do
        library_name=$(basename ${library} .a)
        source_libraries="${source_libraries} ${temp_dir}/${library_name}_${arch}.a"
    done

    libtool -static ${source_libraries} -o "${temp_dir}/${output_name}_${arch}.a"
    source_combined="${source_combined} ${temp_dir}/${output_name}_${arch}.a"
done

# Merge the combined library for each architecture into a single fat binary
lipo -create $source_combined -o $output

# Delete intermediate files
rm -rf $temp_dir

# Show info on the output library as confirmation
echo "Combination complete."
lipo -info $output
