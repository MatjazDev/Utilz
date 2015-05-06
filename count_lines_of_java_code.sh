#!/bin/bash
# +-----------------------------------------------+
# | Java project lines of code counter            |
# +-----------------------------------------------+
# | Author: Matjaž <dev@matjaz.it> matjaz.it      |
# | v2.8.1 2015-05-06                             |
# +-----------------------------------------------+
# | DESCRIPTION AND USAGE                         |
# +-----------------------------------------------+
# Counter of the lines of code of a Java (Maven) project with various 
# details. It should be called in the root folder of the project, where 
# the src and target directories and the pom.xml files are.
# Simply run it without arguments with:
#     $ ./count_lines_of_code.sh
# or
#     $ bash count_lines_of_code.sh
# The data is stored in target/project_stats.txt and 
# target/files_stats.txt, while project_stats.txt is printed on screen.
#
# +-----------------------------------------------+
# | SOFTWARE LICENCE                              |
# +-----------------------------------------------+
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.


# +-----------------------------------------------+
# | INITIAL SETUP AND VARIABLES INITIALIZATION    |
# +-----------------------------------------------+
printf "%s\r" "Initializing..."

# Output files
files_output="target/files_stats.txt"
project_output="target/project_stats.txt"

# Strings
header="| Project statistics on $(date -u '+%Y-%m-%d %H:%M:%S UTC') |"
divider="+-----------------------------------------------+"
divider_plus="+-----------------------------------------------+"

# Needed for a unique floating point symbol (dot)
export LC_NUMERIC="en_US.UTF-8"

function float_ratio() {
	# Call bc to perform the float division
	# Round it to 2 decimals and print printf
	printf "%.2f\n" $(bc -l <<< "$1/$2")
}

# Counters for the data about the whole project that sum data of single files
declare -i project_all_lines=0
declare -i project_empty_lines=0
declare -i project_non_empty_lines=0
declare -i project_non_empty_javadoc_lines=0
declare -i project_empty_javadoc_lines=0
declare -i project_javadoc_blocks=0
declare -i project_javadoc_header_footer_lines=0
declare -i project_all_javadoc_lines=0
declare -i project_doubleslash_comment_lines=0
declare -i project_code_lines=0
declare -i project_java_files=$(find . -name '*.java' | grep -c '')
declare -i i=0

# Delete old files data and write the header
echo -e "$divider\n$header\n$divider_plus" > $files_output
printf "%9s | %s\n" \
	'Project' ${PWD##*/} \
	>> $files_output

# +-----------------------------------------------+
# | DATA GATHERING FOR EACH JAVA FILE IN PROJECT  |
# +-----------------------------------------------+
for file in $(find ./src -name '*.java')
do
	# +-----------------------------------------------+
	# | PRINT STATUS OF THE ANALYSIS                  |
	# +-----------------------------------------------+
	(( i += 1 ))
	printf "Analyzing files %5.2f%%...\r" \
		$(float_ratio $i*100 $project_java_files)


	# +-----------------------------------------------+
	# | GATHER DATA FOR THE CURRENT FILE              |
	# +-----------------------------------------------+
	all_lines=$( \
		# Simply count all lines, regardless of content (if any)
		grep -c '' $file
		)
	(( project_all_lines += all_lines ))

	empty_lines=$(
		# Count lines with only whitespace characters, including empty ones
		grep -c '^\s*$' $file
		)
	(( project_empty_lines += empty_lines ))

	non_empty_lines=$((
		all_lines - empty_lines
		))
	(( project_non_empty_lines += non_empty_lines ))

	non_empty_javadoc_lines=$( \
		# ^\s*\*[^/] = lines that begin with 0 or more whitespace characters,
		# exaclty one asterisk not followed by the slash.
		# Those lines have text after the *.
		grep -c '^\s*\*[^/]' $file 
		)
	(( project_non_empty_javadoc_lines += non_empty_javadoc_lines ))

	empty_javadoc_lines=$( \
		# ^\s*\*\s*$ = lines beginning with 0 or more whitespace characters,
		# exactly one asterisk followed by 0 or more whitespace character until
		# the end of the line
		grep -c '^\s*\*\s*$' $file
		)
	(( project_empty_javadoc_lines += empty_javadoc_lines ))

	javadoc_blocks=$( \
		# ^\s*/\*\* = lines beginning with 0 or more whitespace characters,
		# followed by the header of JavaDoc code '/**'
		grep -c '^\s*/\*\*' $file
		)
	(( project_javadoc_blocks += javadoc_blocks ))

	javadoc_header_footer_lines=$(( \
		2 * javadoc_blocks
		))
	(( project_javadoc_header_footer_lines += javadoc_header_footer_lines ))

	all_javadoc_lines=$((
		javadoc_header_footer_lines + empty_javadoc_lines + non_empty_javadoc_lines
		))
	(( project_all_javadoc_lines += all_javadoc_lines ))

	doubleslash_comment_lines=$( \
		# ^\s*//.* = lines beginning with 0 or more whitespace characters,
		# followed by a double slash and 0 or more characters of any kind.
		grep -c '^\s*//.*' $file
		)
	(( project_doubleslash_comment_lines += doubleslash_comment_lines ))

	code_lines=$((
		all_lines - all_javadoc_lines - doubleslash_comment_lines - empty_lines
		))
	(( project_code_lines += code_lines ))

	javadoc_code_ratio=$( \
		float_ratio $all_javadoc_lines $code_lines
	    )

	javadoc_alllines_ratio=$( \
		float_ratio $all_javadoc_lines $all_lines
	    )

	code_alllines_ratio=$( \
		float_ratio $code_lines $all_lines
	    )

	empty_alllines_ratio=$( \
		float_ratio $empty_lines $all_lines
		)


	# +-----------------------------------------------+
	# | SAVE GATHERED DATA FOR EACH JAVA FILE         |
	# +-----------------------------------------------+
	# Append the name of the current file
	echo "$divider_plus" >> $files_output

	# Append the gathered data from the current file in a pretty format
	printf "%9s | %-23s\n" \
		'File' $file \
		$all_lines 'All lines' \
		$non_empty_lines 'Non empty lines' \
		$empty_lines 'Empty lines' \
        $code_lines 'Java code lines' \
		$javadoc_blocks 'JavaDoc blocks' \
		$empty_javadoc_lines 'Empty JavaDoc lines' \
		$non_empty_javadoc_lines 'Non-empty JavaDoc lines' \
		$all_javadoc_lines 'All JavaDoc lines' \
		$doubleslash_comment_lines '// comment lines' \
		$empty_alllines_ratio 'Empty/All lines' \
		$javadoc_alllines_ratio 'JavaDoc/All lines' \
		$code_alllines_ratio 'Code/All lines' \
		$javadoc_code_ratio 'JavaDoc/Code' \
		>> $files_output
done

# +-----------------------------------------------+
# | OTHER DATA GATHERING FOR THE WHOLE PROJECT    |
# +-----------------------------------------------+
pom_lines=$( \
	grep -c '' pom.xml
    )

commits=$( \
	# Returns the number of commits on the current branch
	git rev-list HEAD --count
    )

current_branch=$( \
	# Returns the name of the current branch
	git rev-parse --abbrev-ref HEAD
    )

project_javadoc_code_ratio=$( \
	float_ratio $project_all_javadoc_lines $project_code_lines
	)

project_javadoc_alllines_ratio=$( \
	float_ratio $project_all_javadoc_lines $project_all_lines
    )

project_code_alllines_ratio=$( \
	float_ratio $project_code_lines $project_all_lines
    )

project_empty_alllines_ratio=$( \
	float_ratio $project_empty_lines $project_all_lines
	)

project_code_commits_ratio=$( \
	float_ratio $project_code_lines $commits
	)

# +-----------------------------------------------+
# | SAVE GATHERED DATA FOR THE WHOLE PROJECT      |
# +-----------------------------------------------+
# Delete old data and write the header. ${PWD##*/} evaluets the full path 
# current directory to its value = just the name of the directory
echo -e "$divider\n$header\n$divider_plus" > $project_output

# Append the gathered data for the whole project in a pretty format
printf "%9s | %s\n" \
	'Project' ${PWD##*/} \
	$commits "commits on current branch $current_branch" \
	$pom_lines 'POM file lines' \
	$project_java_files 'Java files' \
	$project_all_lines 'All lines' \
	$project_non_empty_lines 'Non empty lines' \
	$project_empty_lines 'Empty lines' \
    $project_code_lines 'Java code lines' \
	$project_javadoc_blocks 'JavaDoc blocks' \
	$project_empty_javadoc_lines 'Empty JavaDoc lines' \
	$project_non_empty_javadoc_lines 'Non-empty JavaDoc lines' \
	$project_all_javadoc_lines 'All JavaDoc lines' \
	$project_doubleslash_comment_lines '// comment lines' \
	$project_empty_alllines_ratio 'Empty/All lines' \
	$project_javadoc_alllines_ratio 'JavaDoc/All lines' \
	$project_code_alllines_ratio 'Code/All lines' \
	$project_javadoc_code_ratio 'JavaDoc/Code' \
	$project_code_commits_ratio 'Code Lines/Commit' \
	>> $project_output

# Print the project result immediatly
cat $project_output
exit 0
