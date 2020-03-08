#!/bin/bash
clear

if [ -z $@ ]; then
	export TARGET_DATE=$(date +"%Y%m%d");
else
	export TARGET_DATE=$@;
fi 

export DEVICE=zerofltexx
export SYSTEM_PATH=/home/benlue/android/lineage
export OUTPUT_PATH=$SYSTEM_PATH/out/target/product/$DEVICE
export FILENAME="lineage-17.1-$TARGET_DATE-UNOFFICIAL-$DEVICE.zip"
export SEARCH_FILENAME="lineage-17.1-$TARGET_DATE-UNOFFICIAL-$DEVICE.zip"
export ROMTYPE="unofficial"
export VERSION="17.1"

cd $SYSTEM_PATH

echo $OUTPUT_PATH
echo $FILENAME
echo $SEARCH_FILENAME

if [ -e $OUTPUT_PATH/$SEARCH_FILENAME  ]; then
	
	echo "Starte Upload"	

	mv $OUTPUT_PATH/$SEARCH_FILENAME $OUTPUT_PATH/$FILENAME	

	md5sum $OUTPUT_PATH/$FILENAME > $OUTPUT_PATH/$FILENAME".md5sum"	
	
else
	ls $OUTPUT_PATH/$SEARCH_FILENAME
	
fi

if [ -e $OUTPUT_PATH/$FILENAME ]; then
	
	echo "Erstelle MD5-Prüfsummmendatei"
			
	MD5SUM=$(cat $OUTPUT_PATH/$FILENAME".md5sum" | awk '{ print $1 }')	
	FILESIZE=$(stat -c%s $OUTPUT_PATH/$FILENAME )	
	
	URL="https://los-legacy.de/$DEVICE/$FILENAME"
	DATETIME=$(date -u +"%F %H:%M:%S")
	
	echo
	echo "Übertrage Rom in Datenbank"
	echo "URL: $URL"
	echo "Filename: $FILENAME"
	echo "Device: $DEVICE"
	echo "Storage Directory: $STORAGE_DIR"
	echo "OS Version: $VERSION"
	echo "$DATETIME"
	echo "Romtype: $ROMTYPE"
	echo "MD5SUM: $MD5SUM"
	echo "SIZE: $FILESIZE"
	
	NO_SUCCESS=1	
	while [ "$NO_SUCCESS" != "0" ]; do
		echo "Rom: $FILENAME wird hochgeladen"
		scp $OUTPUT_PATH/$FILENAME $USER@los-legacy.de:/var/www/html/files/$DEVICE/
		NO_SUCCESS=$?;
	done
	
	NO_SUCCESS=1
	while [ "$NO_SUCCESS" != "0" ]; do
		echo "md5 File: $FILENAME.md5sum wird hochgeladen"
		scp $OUTPUT_PATH/$FILENAME.md5sum $USER@los-legacy.de:/var/www/html/files/$DEVICE/
		NO_SUCCESS=$?;		
	done	
	
	echo "Entferne ggfs. bereits eingetragenes Build von heute"
	echo "cd /opt/lineageos_updater && FLASK_APP=/opt/lineageos_updater/app.py flask delrom -f $FILENAME"

	NO_SUCCESS=1
	while [ "$NO_SUCCESS" != "0" ]; do
		ssh $USER@los-legacy.de "cd /opt/lineageos_updater && FLASK_APP=/opt/lineageos_updater/app.py flask delrom -f $FILENAME"
		NO_SUCCESS=$?;
	done

	echo "Veröffentliche Build von heute"
	echo "cd /opt/lineageos_updater && FLASK_APP=/opt/lineageos_updater/app.py flask addrom --filename $FILENAME --device $DEVICE --version $VERSION --datetime \""$DATETIME"\" --romtype $ROMTYPE --md5sum $MD5SUM --size "$FILESIZE" --url $URL"

	NO_SUCCESS=1
	while [ "$NO_SUCCESS" != "0" ]; do		
		ssh $USER@los-legacy.de "cd /opt/lineageos_updater && FLASK_APP=/opt/lineageos_updater/app.py flask addrom --filename $FILENAME --device $DEVICE --version $VERSION --datetime \""$DATETIME"\" --romtype $ROMTYPE --md5sum $MD5SUM --size "$FILESIZE" --url $URL"
		NO_SUCCESS=$?;	
	done
fi
