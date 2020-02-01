#!/bin/bash

# draft for a automatic rebuild, by David Va

# Current updates

curl -f -o packages https://cdn.download.clearlinux.org/current/source/package-sources
cut -f1 packages | LC_ALL=C sort > packages.new && mv packages.new packages

# OR

# version of bundle "32220" (based in tags)
# Show current bundle version (https://cdn.download.clearlinux.org/latest)

# curl -f -o packages https://cdn.download.clearlinux.org/releases/32220/clear/source/package-sources
# cut -f1 packages | LC_ALL=C sort > packages.new && mv packages.new packages

# Search our BuildRequires:

rpmspec --parse *.spec | grep -i "BuildRequires:" | sed -e 's|[Bb]uild[Rr]equires:||g' | sed -e 's|>=||g' | sed -e 's|<=||g' |  tr -d '\t' | sed -e 's/^ *//' | LC_ALL=C sort > BuidRequires.txt



# Compare with bundle 
# maybe; diff -q packages BuidRequires.txt
# Or some lines with "while"
# if some line in BuidRequires.txt exist in "packages"; then
# ....rebuild rpm
#fi


while IFS= read -r line; do
        # display $line or do something with $line

if grep -Fxq "$line" packages
then
    # Build requires updated found
echo "Update found in $line, starting the rebuild..."
exit
else
    # Build requires not found
echo "..... not updates foud for a rebuild for $line"
fi

done <"BuidRequires.txt"

