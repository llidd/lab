#!bin/bash
rm -r PNPI
tar xpvzf PNPI.tar.gz 
oldstring='10.10.7.1'
newstring='10.10.7.1'
grep -rl $oldstring PNPI/ | xargs sed -i "s/$oldstring/$newstring/g"
grep -rl $oldstring Scripts/ | xargs sed -i "s/$oldstring/$newstring/g"
