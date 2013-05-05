#!/bin/bash

TMP_DIR=/tmp/buildbooks
BOOKNAME=Book
EXPECTED_ARGS=2

if [ "$#" -lt ${EXPECTED_ARGS} ]
then
  echo ERROR! Expected more arguments.
	exit 1
fi

# Get the suffix on the directory
DIR_SUFFIX=$1
LOCK_FILE=${TMP_DIR}${DIR_SUFFIX}.lock

# echo ${LOCK_FILE}

shift

# Check and create a lock file to make sure builds don't overlap
if [ -f ${LOCK_FILE} ]
then
	date >> build_original_books_error.log
	echo "ERROR! ${LOCK_FILE} exists, consider increasing the time between builds." >> build_original_books_error.log
	exit 1
else
	touch ${LOCK_FILE}
fi

while (( "$#" ))
do
        # Extract the language and CSP id from the
        # command line argument
        CSPID=$1

        # Shift the arguments down
        shift

	# Start with a clean temp dir for every build
	if [ -d ${TMP_DIR}${DIR_SUFFIX} ]
	then
		rm -rf ${TMP_DIR}${DIR_SUFFIX}
	fi
	
	mkdir ${TMP_DIR}${DIR_SUFFIX}

	# Enter the temp directory
	pushd ${TMP_DIR}${DIR_SUFFIX}

		date > build.log

		echo "csprocessor build --server --show-report --editor-links --permissive --output ${BOOKNAME}.zip ${CSPID} >> build.log"
		csprocessor build --server --show-report --editor-links --permissive --output ${BOOKNAME}.zip ${CSPID} >> build.log
		
		# If the csp build failed then continue to the next item
		if [ $? != 0 ]
		then
			if [ -d /var/www/html/${CSPID} ]
                        then
	                        rm -rf /var/www/html/${CSPID}
                        fi

			mkdir /var/www/html/${CSPID}
			cp build.log /var/www/html/${CSPID}

			continue
		fi		

		unzip ${BOOKNAME}.zip

		# The zip file will be extracted to a directory name that 
		# refelcts the name of the book. We don't know this name,
		# but we can loop over the subdirectories and then break
		# once we have processed the first directory.
		for dir in ./*/
		do

			# Enter the extracted book directory
			pushd ${dir}

				echo 'publican build --formats=html-single --langs=en-US &> publican.log'

				publican build --formats=html-single --langs=en-US &> publican.log

				if [ -d /var/www/html/${CSPID} ] || [ -e /var/www/html/${CSPID} ]
				then
					rm -rf /var/www/html/${CSPID}
				fi

				mkdir /var/www/html/${CSPID}
				cp -R tmp/en-US/html-single/. /var/www/html/${CSPID}

				cp publican.log /var/www/html/${CSPID}

			popd
			
			# we only want to process one directory
			break

		done

		cp build.log /var/www/html/${CSPID}

	popd
done

# remove the lock file
rm -f ${LOCK_FILE}
