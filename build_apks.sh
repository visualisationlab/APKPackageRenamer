#!/bin/bash

common_name=$1

# Loop through all APK files in the folder
for apk in *.apk; do
    # Extract common name and specific part
    base_name=$(basename "$apk" .apk)  # Remove .apk extension
    specific_part=$(echo "$base_name" | cut -d '-' -f3)  # Extract specific part
    # Define output directory
    output_dir="${base_name}-Decompiled"

    # Run apktool
    echo "Decompiling $apk -> $output_dir"
    apktool d "$apk" -o "$output_dir"
done

echo "Decompilation completed. for $specific_part"

for dir in *-Decompiled/; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
        group_name=$(echo "$dir" | cut -d '-' -f3)  # Extract specific part
        year=$(echo "$dir" | cut -d '-' -f2)  # Extract specific part
        echo "Found directory: $dir"
        echo "For group name: $group_name"

        MANIFEST_FILE="$dir/AndroidManifest.xml"

        if [ -f "$MANIFEST_FILE" ]; then
            echo "Editing $MANIFEST_FILE"

            current_package=$(grep -oP 'package="\K[^"]*' "$MANIFEST_FILE")
            new_package_name="com.$common_name.$group_name"
            
            echo "Current Package name: $current_package"
            
            sed -i "s|$current_package|$new_package_name|g" "$MANIFEST_FILE"

            echo "Updated package name in $MANIFEST_FILE"
        else
            echo "AndroidManifest.xml not found in $dir"
        fi
    fi
done

echo "Replacing Package name in Android Manifest completed."

for dir in *-Decompiled/; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
        group_name=$(echo "$dir" | cut -d '-' -f3)
        apktool b $dir -o $common_name-$group_name-Recompiled.apk
    fi
done

echo "Created Recompiled apk's"

echo "Aligning apk's"

for apk in *-Recompiled.apk; do
    # Extract common name and specific part
    base_name=$(basename "$apk" .apk)  # Remove .apk extension
    specific_part=$(echo "$apk" | cut -d '-' -f3)  # Extract specific part

    echo "Aligning: $specific_part"
    zipalign -p -f -v 4 $common_name-$specific_part-Recompiled.apk $common_name-$specific_part-Aligned.apk
done

echo "All APK's Aligned"

echo "Sign APK's"

for apk in *-Aligned.apk; do
    # Extract common name and specific part
    base_name=$(basename "$apk" .apk)  # Remove .apk extension
    specific_part=$(echo "$apk" | cut -d '-' -f3)  # Extract specific part

    echo "Signing: $specific_part"
    apksigner sign --ks my-release-key.keystore --ks-pass pass:var4good --out $common_name-$specific_part-Final.apk $common_name-$specific_part-Aligned.apk
done

echo "All Done!"