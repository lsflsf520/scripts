#!/bin/sh
home_dir="/home/deployer"
previewWord_dir="$home_dir/previewWord"
SimpleWord_dir="$home_dir/SimpleWord"
WordMagazine_dir="$home_dir/WordMagazine"
PdfSpecialTrainingMagazine_dir="$home_dir/PdfSpecialTrainingMagazine"
PdfSprintMagazine_dir="$home_dir/PdfSprintMagazine"

if [ ! -d "$previewWord_dir"  ];then
  echo "$previewWord_dir is not exists, then exit."
  break
 else
  find $previewWord_dir  -depth  -type f  -name '*.pdf'  -mtime +7 -exec rm -rf {} \;
  find $previewWord_dir  -depth  -type f  -name '*.docx'  -mtime +7 -exec rm -rf {} \;
  find $previewWord_dir  -depth  -type f  -name '*.html'  -mtime +7 -exec rm -rf {} \;
  echo "$previewWord_dir,cleanup has been completed!"
fi

if [ ! -d "$SimpleWord_dir"  ];then
  echo "$SimpleWord_dir is not exists, then exit."
  break
 else
  find $SimpleWord_dir  -depth  -type f  -name '*.pdf'  -mtime +7 -exec rm -rf {} \;
  find $SimpleWord_dir  -depth  -type f  -name '*.docx'  -mtime +7 -exec rm -rf {} \;
  find $SimpleWord_dir  -depth  -type f  -name '*.html'  -mtime +7 -exec rm -rf {} \;
  echo "$SimpleWord_dir,cleanup has been completed!"
fi

if [ ! -d "$WordMagazine_dir"  ];then
  echo "$WordMagazine_dir is not exists, then exit."
  break
 else
  find $WordMagazine_dir  -depth  -type f  -name '*.pdf'  -mtime +7 -exec rm -rf {} \;
  find $WordMagazine_dir  -depth  -type f  -name '*.docx'  -mtime +7 -exec rm -rf {} \;
  find $WordMagazine_dir  -depth  -type f  -name '*.html'  -mtime +7 -exec rm -rf {} \;
  echo "$WordMagazine_dir,cleanup has been completed!"
fi


if [ ! -d "$PdfSpecialTrainingMagazine_dir"  ];then
  echo "$PdfSpecialTrainingMagazine_dir is not exists, then exit."
  break
 else
  find $PdfSpecialTrainingMagazine_dir  -depth  -type f  -name '*.pdf'  -mtime +15 -exec rm -rf {} \;
  find $PdfSpecialTrainingMagazine_dir  -depth  -type f  -name '*.docx'  -mtime +15 -exec rm -rf {} \;
  find $PdfSpecialTrainingMagazine_dir  -depth  -type f  -name '*.html'  -mtime +15 -exec rm -rf {} \;
  echo "$PdfSpecialTrainingMagazine_dir,cleanup has been completed!"
fi


if [ ! -d "$PdfSprintMagazine_dir"  ];then
  echo "$PdfSprintMagazine_dir is not exists, then exit."
  break
 else
  find $PdfSprintMagazine_dir  -depth  -type f  -name '*.pdf'  -mtime +15 -exec rm -rf {} \;
  find $PdfSprintMagazine_dir  -depth  -type f  -name '*.docx'  -mtime +15 -exec rm -rf {} \;
  find $PdfSprintMagazine_dir  -depth  -type f  -name '*.html'  -mtime +15 -exec rm -rf {} \;
  echo "$PdfSprintMagazine_dir,cleanup has been completed!"
fi

echo "clear done" `date +%Y%m%d-%T` >> $home_dir/scripts/clear_data.log

