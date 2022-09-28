#!/usr/bin/bash
#
# help create sample packs by renaming and removing

name=""
type=""
TARGET_DIR=""
fixed=()
numArgs=0

dryrun='false'
convert='false'
sampleCount=1

print_help()
{
   # Prints a help message to the user
   echo "Usage: ./sampleHelper.sh [-h|-d|-c] NAME SAMPLETYPE DIRECTORY"
   echo ""
   echo "NAME: Your name. Whatever you want to be in front of the sample type"
   echo "SAMPLETYPE: Whatever type of sample you want to label these as (kick, snare, bass)"
   echo "DIRECTORY: A path to the folder you want to perform the conversion in (use absolute path to be safe)"
   echo "   -h: Help. Prints this help message and exits"
   echo "   -d: Dry run. Prints what the changes would be but does not execute the changes"
   echo "   -c: Convert. Converts the files to a specified type (.wav,mp3...) Desired type should be included after diectory"
   exit 1
#    echo "   for example: ./sampleHelper.sh -c Flood Snare DIECTORY wav"
}

while [ $# -gt 0 ] ; do
    nextarg="$1"
    shift
    case $nextarg in
        '-h')
            print_help
            ;;
        '-d')
            echo 'Performing dry run'
            dryrun='true'
            ;;
        '-c')
            echo 'Converting files...'
            convert='true'
            ;;
        *)
            fixed+=("$nextarg")
            ((numArgs++))
            ;;
    esac
done

if [ $numArgs -lt 1 ] ; then
    echo "No arguments given" 
    print_help
elif [ $numArgs -lt 2 ] ; then
    echo "Only name is given"
    print_help
elif [ $numArgs -lt 3 ] ; then
    echo "Only directory given" 
    print_help
fi
    name=${fixed[0]}
    type=${fixed[1]}
    TARGET_DIR=${fixed[2]}

    #0 = dryrun
    #1 =  normal
    #2 = convert use read

if [ "$convert" == 'true' ]
    then
    echo "What file type would you like to covert to?"
    echo -n "do not include a '.' (for example type 'wav' instead of '.wav'): "
    read -r fileType

    for i in "$TARGET_DIR"/*
        do
            #fileType=echo i | grep -i .
            if [ -f "$i" ]
            then
                new_name="${name} ${type} ${sampleCount}.${fileType}"
                    if [[ $dryrun = 'false' ]]
                    then
                        ./bin/ffmpeg -i "$i" -vn -loglevel panic -ar 44100 -ac 2 -b:a 320k "$TARGET_DIR/$new_name" && echo "converted $i to $TARGET_DIR/$new_name" && rm "$i" #<--
                        #mv  "$TARGET_DIR/$new_name" "$new_name" || rm "/$new_name"
                    else
                        echo "Would rename and convert $i to $new_name"
                    fi
            fi
        ((sampleCount=sampleCount+1))
        done

else

    for i in "$TARGET_DIR"/*
        do
            
            if [ -f "$i" ]
            then
                fileType="${i##*.}"
                new_name="${name} ${type} ${sampleCount}.${fileType}"
                    if [[ $dryrun = 'false' ]]
                    then    
                        # ffmpeg -i "$i" -vn -loglevel panic -ar 44100 -ac 2 -b:a 320k "$TARGET_DIR/$new_name" && echo "renamed $i to $TARGET_DIR/$new_name"   #|| rm "$TARGET_DIR/$i" #<--
                        mv  "$i" "$TARGET_DIR/$new_name" && echo "converted $i to $TARGET_DIR/$new_name"
                    else
                        echo "Would rename $i to $new_name"
                    fi
            fi
        ((sampleCount=sampleCount+1))
        done

fi
