#!/bin/bash -i
# Filename Chnager (fnc) by Kelvin Onuchukwu 
# Initial: Nov 2021; Last update: Dec 2021
# N.B: This project is a work in progress. To contribute to this project, visit the Contributing.md file for basic guidelines. 

trap func exit
function func()
{
	rm ~/tmp/error.log 2> /dev/null
        rm ~/tmp/temp.txt   2> /dev/null
	#Remove ~/tmp deirectory only if it is empty
	find ~/tmp -maxdepth 0 -empty -exec rmdir  ~/tmp {} \; 2> /dev/null
}

function Temp_dir () 
{
# check if ~/tmp directory exists 
if [[ -d ~/tmp ]] 
then 
     :
else 
mkdir ~/tmp
fi
} 

function Init ()
{
# The init function essentially checks if the user is running the script for the first time.
# If so, it creates an alias 'fnc', so the user can run this script from any directory within their filesystem by simply typing 'fnc'. 
# Check whether script is running for the first time on the local machine. 
Temp_dir
if [[ -f ~/filename-changer/.init.txt ]] 
then
	echo -e "fnc.sh: No option selected. \nTry fnc -h for more information"
exit 0
else
        touch ~/filename-changer/.file_inodes.log 2>/dev/null
        touch ~/filename-changer/.history_page.log 2>/dev/null
echo -e "Hi, welcome $USER. \tI hope you enjoy using this program."
sleep 2
echo -e "Create an alias fnc to run this script anywhere from the command line."
read -p "y/n? " ans 
if [[ $ans == y ]] || [[ $ans == yes ]] 
then
echo "alias fnc='bash ~/filename-changer/fnc.sh'" >> ~/.bash_aliases
# Expand aliases defined in the shell
shopt -s expand_aliases
source ~/.bash_aliases
sleep 1
echo -e "Alias fnc has been created for command 'bash ~/filename-changer'. \nYou can now execute this program by typing 'fnc' anywhere on your terminal. \nIf you move this directory at any point in time, please be sure to update your .bash_aliases and .bashrc files as appropriate."
elif [[ $ans == n ]] || [[ $ans == no ]] 
then
	echo -e "Please restart the script with an option. \nTry fnc -h for more information."
       echo "To stop this display, create an empty ".init.txt" file in the ~/filename-changer directory."
	exit
else 
	echo "fnc.sh: Invalid input. Restart the script and try again."
exit
fi
fi
touch ~/filename-changer/.init.txt
exit 1
}

#####################################################GETOPTS FUNCTIONS########################################################################
function First() 
{
var1=`ls`
for i in $var1
do
	j=`echo $i | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1'` 
	mv -v $i $j 2> ~/tmp/error.log
	logger $0: `cat ~/tmp/error.log 2>/dev/null`
done
exit 0
} 

function Help() 
{
less ~/filename-changer/.manual_page.txt
exit 0
} 

function History() 
{
# Check if file is empty or not 
if [ -s ~/filename-changer/.history_page.log ]; then   
echo -e "Press c to clear history t\Press d to view history" 
read ans
if [[ $ans == c ]] || [[ $ans == C ]]; then
rm ~/filename-changer/.history_page.log 2>/dev/null
rm ~/filename-changer/.file_inodes.log 2>/dev/null
touch ~/filename-changer/.history_page.log
touch ~/filename-changer/.file_inodes.log
echo "History cleared."
exit
elif [[ $ans == d ]] || [[ $ans == D ]]; then 
	awk -f ~/filename-changer/history.awk ~/filename-changer/.history_page.log
exit 0
else
       echo "fnc.sh: Unrecognised input. Exiting program..."
exit 0
fi
else 
      echo "You have no history yet."
exit 0
fi
} 

function Uppercase() 
{
var1=`ls`
for i in $var1
do
	mv -v $i `tr '[:lower:]' '[:upper:]' < <(echo "$i")` 2> ~/tmp/error_log.txt
	logger $0: `cat ~/tmp/error.log 2>/dev/null`
done
if [ $? == 0 ]
then
	:
else
	echo "fnc.sh: Error code $?, Please use journalctl to view log"
fi
exit
} 

function Extension() 
{
echo "Check out common file extensions before proceeding"
read -p "yes or no? " ans 
if [[ $ans == y ]] || [[ $ans == yes ]] 
then 
less  ~/filename-changer/file_extensions.txt 
fi
echo -e "Input the new file extension \tDo not include '.'" 
read ext
var1=`ls`
for i in $var1
do
j=$(echo "$i" | cut -f 1 -d '.') 
mv -v $i $j.$ext 2>/dev/null
done
exit 0
} 


function Lowercase()
{
var1=`ls`
for i in $var1
do
	mv -v $i `tr '[:upper:]' '[:lower:]' < <(echo "$i")` 2> ~/tmp/error_log.txt
	logger $0: `cat ~/tmp/error.log 2>/dev/null`
done
if [ $? == 0 ]
then
	:
else
	echo "fnc.sh: Error code $?, Please use journalctl to view log"
fi
exit
}

function Path()
{
	echo "Please enter the ABSOLUTE Directory path for the files(e.g /home/$USER/Videos):"
	read path
	if [ -d $path ]
	then
		cd $path
		PS3="Choose how you wish to alter the filenames in this directory: "
                echo "Press a number to select an option." 
		select opt in extension glob uppercase lowercase quit
		do
			case $opt in
				extension)
					Extension
					;;
				first-letter)
					First
					;;
				glob)
					Glob
					;;
				uppercase)
					Uppercase
					;;
				lowercase)
					Lowercase
					;;
				quit)
					exit 0
					;;
				*)
					echo -e "fnc.sh: Invalid option selected. \nTry fnc -h for more information \nfnc.sh: Exiting program..."
					exit 1
				esac
			done

else 
	echo -e "fnc.sh: $path does not exist as a directory on this system! "
	fi
	exit
}

#function Revert() 
#{
echo "Enter current filename: "
read name
# Check if file exists
if [ `grep -q $name ~/filename-changer/.history_page.log` ]
then
	# Get the whole line and cut out the second field
	old=$(grep -w $name ~/filename-changer/.history_page.log || cut -d: -f 2)
	new=$(grep -w $name ~/filename-changer/.history_page.log || cut -d: -f 3)
	mv -v $new $old 2> .error.log


#} 

#function Random() 
#{
#} 

function Update() 
{ 
echo "fnc.sh: Connecting to remote repository..."
sleep 1
             git pull ~/filename-changer
        if [[ $? == 0 ]] 
		then
			:
        else 
        echo -e "fnc.sh: Program cannot be updated at this time. \nfnc.sh: Please check your network connection and try again."
	exit
fi
exit 
} 

function Version() 
{
echo  "fnc.sh: Filename-Changer (fnc)"
echo  "Author: Kelvin Onuchukwu" 
echo  "Version 2.0"
# Highlight and underline the Weblink
echo -e "For more info, visit \e[4mhttps://github.com/Kelvinskell/filename-changer\e[10m"
exit
} 

##############################################################################################################################################

# Specify silent error checking 
# Specify functions for different options
while getopts ":cCeEgGhHiIlLpPrRvVzZ" options
do
	case ${options} in
	       	c) 
			# Change first letter in filename to uppercase
			# This will only change the first letter in the filename and will not affect other characters that make up the filename.
			# For instance, if your filename is "BOY.txt", this option will do nothing to the filename since the first character is already in uppercase.
			Temp_dir 
			First
			;;
		 C)
			 # Change filename to uppercase
			Temp_dir
			Uppercase
			;;
		e | E)
			# Change file extension
			Temp_dir
			Extension
			;;
		h)
			# Display manual page
			Temp_dir
			Help
			;;
		H)
			# Display history
			Temp_dir
			History 
			;;
		l | L)
			# Change filenames in current directory to lowercase characters
			Temp_dir
			Lowercase
			;;
		p | P)
			# Specify absolute path to directory containing files of interest
			Temp_dir
			Path
			;;
		r | R)
			# Generate random names for files
			Temp_dir
			Random
			;;
                v) 
		        # Display version information
			Temp_dir
                        Version 
                        ;;
                V) 
			# Update to the latest version
			Temp_dir
                        Update
                        ;;
		z | Z)
			# Revert filename to the last known name
			Temp_dir
			Revert
			;;
		*)
		        # Wrong option selection
             echo -e "fnc.sh: Invalid option. \nTry fnc -h for more information"
	     exit 1
		esac
	done

	# Call the Init function if no argument is used.
	Init
