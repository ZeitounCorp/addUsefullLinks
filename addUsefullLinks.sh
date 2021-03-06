#!/bin/bash


#---------Defining colors for the outputs
RED='\033[0;31m'
BLUE='\033[0;34m'
GREY='\033[1;30m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
#---------End defining colors area

#----------Global Variable definition area
currentTime=`date +%T`
dayDate=`date '+%A %d-%B, %Y'`
cliConfFile=~/.pu_links_lz
confFolder="Projects_Usefull_Links"

#----------Create New Project
createNewProject() {
echo -e "${BLUE}What Should be the name of the project ?${NC} \n"
read project_name
while [ "$project_name" == "" ]; do
  echo -e "${RED}Invalid empty option${NC} \n"
  read project_name
done;
echo -e "${GREY}Creating Project "$project_name" @ ~/$confFolder/$project_name.txt...${NC} \n"
touch ~/$confFolder/$project_name.txt
echo "$project_name" >> $cliConfFile
echo -e "${BLUE}The project $project_name has been successfully created ${NC}"
echo "Created new project Named: $project_name on $dayDate at $currentTime" >> ~/$confFolder/.logs
editLinks "$project_name"
}

#--------List Project links
listThisProjLinks() {
while read filename;
 do
    if [ "$filename" != "" ];
      then
	if [ "$filename" == "Q" ]; then
	  echo -e "${RED}Quitting..${NC}"
	  break;
	fi
        LINK_FILE=$(checkIfLinksFile "$filename")
	if [ "$LINK_FILE" -eq 0 ]; then
	  echo -e "${BLUE}Here are the links already saved for project "$1":${NC} \n"
	  cat -n ~/$confFolder/$filename.txt
 	  echo -e "${BLUE}Enter the name of the project you want to visualize, (enter Q to quit):${NC} \n"
	else 
	  echo -e "${RED}No Project named $filename ${NC}"
	fi;
     else
      echo -e "${RED}Invalid empty option${NC}"
     fi
 done
}

#--------Edit the links for $1 project
editLinks() {
echo -e "${BLUE}Here are the links already saved for project "$1":${NC} \n"
cat -n ~/$confFolder/$1.txt
echo -e "${GREY}You are pleased to add more: (ONE/ Line, empty line will stop asking for more links)${NC} \n"
while read link;
do
   if [ "$link" != "" ];
     then
	echo "$link" >> ~/$confFolder/$1.txt
	echo "Added new link to: $1 on $dayDate at $currentTime" >> ~/$confFolder/.logs
     else
      break;
   fi   
done
}

#---------Check if link file for this project exists
checkIfLinksFile() {
if [[ -f ~/$confFolder/$1.txt ]]; then
  echo 0
else
  echo 1
fi
}

#----------List All Available Projects
listProjects() {
local i=0
for OUTPUT in $(cat $cliConfFile)
  do
    i=$[$i + 1]
    echo -e "${GREY}"$i"-> $OUTPUT${NC}"
  done
echo -e "${GREY}"$[$i + 1]"-> New Project${NC}"
echo -e "${GREY}"$[$i + 2]"-> List Links${NC}"
echo -e "${GREY}"$[$i + 3]"-> Exit${NC}"
echo -e "${BLUE}Enter the name of the projects you want to edit, "$[$i + 1]" to create a new one or "$[$i + 3]" to quit:${NC}"

while read opt;
do
   if [ "$opt" != "" ];
     then
	if [ "$opt" != "$[$i + 1]" ] && [ "$opt" != "$[$i + 2]" ] && [ "$opt" != "$[$i + 3]" ] 
	then
  	  LINK_FILE=$(checkIfLinksFile "$opt")
	  if [ "$LINK_FILE" -eq 0 ]; then
	    editLinks "$opt"
	    break;
	  else 
	    echo -e "${RED}No Project named $opt ${NC}maybe you should create one (type $[$i + 1])"
	  fi 
	elif [ "$opt" == "$[$i + 1]" ]; then
	  createNewProject
	  break;
	elif [ "$opt" == "$[$i + 3]" ]; then
	  echo -e "${RED}Quitting..${NC}"
	  break;
	elif [ "$opt" == "$[$i + 2]" ]; then
	  echo -e "${BLUE}Enter the name of the project you want to visualize, (enter Q to quit):${NC} \n"
 	  listThisProjLinks
	  break;
	fi
     else
      echo -e "${RED}Invalid empty option${NC}"
   fi   
done
}

#----------Generate conf folder
genConfFolder() {
  mkdir ~/$confFolder && touch ~/$confFolder/README.txt
  echo "This folder has been auto-generated by command addUsefullLinks, it will hold all your projects' links inside a text document named after your project, Hope you will find it easy to use" >> ~/$confFolder/README.txt
  touch ~/$confFolder/.logs
  echo "Started Using addUsefullLinks at $currentTime on $dayDate" >> ~/$confFolder/.logs
}

#--------Check if cliConfFile is empty
pu_links_lz_empt() {
if [ -s "$cliConfFile" ] 
then
 	#--Will return 1
	echo "$?"
else
	#--Will return 0
	echo "$?"
fi
}

#--------Main Function
cli_activate() {
local emptyFile=$(pu_links_lz_empt)

if [ "$emptyFile" -gt 0 ]
then
  echo -e "${RED}No Projects yet... Launching the cli to create one ${NC}"
  createNewProject
else
  listProjects
fi
}
#--------End Main Function

#---------Check If file ~/.pu_links_lz 
#---------(where will be registered all projects name and path)
#---------On first launch will generate the file and the folder responsible for holding links

if [[ -f "$cliConfFile" ]]; then
    cli_activate
else 
    echo -e "${BLUE}Generating the config file ("$cliConfFile") for first launch ${NC}"
      touch "$cliConfFile"
    echo -e "${GREY}Generating the folder that will hold your projects' usefull links ${NC}"
      genConfFolder
    cli_activate
fi
