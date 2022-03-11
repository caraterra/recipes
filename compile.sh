#!/bin/sh

input_format="markdown"
input_format_ext="md"
output_format="pdf"
output_format_ext="pdf"

author=$(git config user.name || echo "$USER")
author_first=$(echo "$author" | cut -d' ' -f1)
title="${author_first}'s Cookbook"

old_cwd="$PWD"
new_cwd=$(printf "%s" "$0" | sed "s/\/\w\+\.\?\w\+$//g")
output_dir="output"
cd "$new_cwd" || exit 1

[ -d $output_dir ] || mkdir -p $output_dir

# Compiles all input files into a single output file in alphabetical order if
# no arguements are passed

# Compiles given input files into individual output files if filenames are passed
if [ "$#" -eq "0" ]
then
	tmpfile=$(mktemp)

	{
		echo "---";
		printf "title: %s\n" "$title";
		printf "author: %s\n" "$author";
		echo "---";
	} >> "$tmpfile"

	for file in *."$input_format_ext"
	do
		printf "%s" "$file" | grep -qv '^[A-Z]\+\(\..\+\)\?$'
		match=$?
		[ -s "$file" ] && [ -f "$file" ] && [ "$match" -eq 0 ] && {
			printf "Appending %s to the output file\n" "$file"
			printf "\n\pagebreak\n\n" >> "$tmpfile"
			cat "$file" >> "$tmpfile"
		}
	done

	pandoc --quiet --standalone --toc --toc-depth 1 "$tmpfile" \
		-f "$input_format" -t "$output_format" -o "$output_dir/all.$output_format_ext"

	rm -f "$tmpfile"
else
	for file in "$@"
	do
		if [ -f "$file" ]
		then
			ofile=$(printf "%s" "$file" | sed "s/\.$input_format_ext/\.$output_format_ext/g")
			pandoc --quiet --standalone "$file" -f "$input_format" -t "$output_format" -o "$output_dir/$ofile"
			printf "%s -> %s\n" "$PWD/$file" "$PWD/$output_dir/$ofile"
		else
			printf "File %s does not exist. Skipping...\n" "$PWD/$file"
		fi
	done
fi

cd "$old_cwd" || exit 1
